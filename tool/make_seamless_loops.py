#!/usr/bin/env python3
"""Turn downloaded Moodist sounds into seamless loops.

Why: the upstream MP3/WAV files do not loop cleanly. MP3 encoders add
padding at both ends, and the audio content itself stops abruptly
instead of flowing back into the start, so the player produces an
audible dip/click every loop (e.g. every ~22 s for heavy-rain.mp3).

What this does per file:
  1. Decode to 44.1 kHz stereo PCM.
  2. Trim digital-silence padding from both ends.
  3. Build a wrap-around crossfade: the output starts with the last
     F seconds fading into the first F seconds, followed by the middle
     of the file. The output (duration - F) then loops continuously:
     its last sample is immediately followed, in the original signal,
     by its first sample.
  4. Encode as OGG Vorbis (gapless-friendly, unlike MP3) next to the
     source, then remove the source file.

Requires: miniaudio, soundfile, numpy (see tool/requirements-audio.txt).

Usage: make_seamless_loops.py [--force] [sounds_dir]
"""

import sys
from pathlib import Path

import numpy as np
import soundfile as sf
import miniaudio

MAX_CROSSFADE_SECONDS = 4.0
CROSSFADE_FRACTION = 0.25
# Samples at/below this magnitude (of int16 full scale) count as the
# digital silence an MP3 encoder pads a file with.
PADDING_THRESHOLD = 2.0 / 32768.0


def trim_padding(samples: np.ndarray) -> np.ndarray:
    """Drop near-zero frames from both ends."""
    magnitude = np.max(np.abs(samples), axis=1)
    nonzero = np.flatnonzero(magnitude > PADDING_THRESHOLD)
    if nonzero.size == 0:
        return samples
    return samples[nonzero[0] : nonzero[-1] + 1]


def make_seamless(samples: np.ndarray, sample_rate: int) -> np.ndarray:
    """Wrap-crossfade so the result loops without a seam."""
    duration = len(samples) / sample_rate
    fade_seconds = min(MAX_CROSSFADE_SECONDS, duration * CROSSFADE_FRACTION)
    fade = int(fade_seconds * sample_rate)
    if fade < 1 or len(samples) <= 2 * fade:
        return samples
    head = samples[:fade]
    tail = samples[-fade:]
    middle = samples[fade:-fade]
    t = np.linspace(0.0, 1.0, fade, dtype=np.float32)[:, None]
    # Equal-power crossfade (ambient content is mostly uncorrelated).
    cross = tail * np.cos(t * np.pi / 2) + head * np.sin(t * np.pi / 2)
    return np.concatenate([cross, middle])


def boundary_jump(samples: np.ndarray) -> float:
    """|first - last| sample jump across the loop point (lower is smoother)."""
    return float(np.max(np.abs(samples[0] - samples[-1])))


def process(path: Path, force: bool) -> None:
    target = path.with_suffix(".ogg")
    if target.exists() and not force:
        print(f"skip (exists)  {target.name}")
        return
    decoded = miniaudio.decode_file(
        str(path),
        output_format=miniaudio.SampleFormat.SIGNED16,
        nchannels=2,
        sample_rate=44100,
    )
    samples = (
        np.frombuffer(decoded.samples, dtype=np.int16)
        .reshape(-1, decoded.nchannels)
        .astype(np.float32)
        / 32768.0
    )
    sample_rate = decoded.sample_rate
    before = len(samples) / sample_rate
    trimmed = trim_padding(samples)
    padding_ms = (len(samples) - len(trimmed)) / sample_rate * 1000
    looped = make_seamless(trimmed, sample_rate)
    looped = np.clip(looped, -1.0, 1.0)
    # Stream in 1-second blocks: one-shot sf.write of a long file
    # segfaults inside libsndfile. Write to a temp file and rename so
    # a crash can never leave a truncated .ogg behind.
    temp = target.with_name(target.name + ".tmp")
    with sf.SoundFile(
        str(temp),
        "w",
        samplerate=sample_rate,
        channels=looped.shape[1],
        format="OGG",
        subtype="VORBIS",
    ) as out:
        for start in range(0, len(looped), sample_rate):
            out.write(looped[start : start + sample_rate])
    temp.rename(target)
    after = len(looped) / sample_rate
    print(
        f"looped {path.name}: {before:.1f}s -> {after:.1f}s "
        f"(trimmed {padding_ms:.0f} ms padding, "
        f"seam jump {boundary_jump(looped):.4f})"
    )
    path.unlink()


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    force = "--force" in sys.argv
    root = Path(args[0]) if args else Path("assets/sounds")
    sources = sorted(
        p for p in root.rglob("*") if p.suffix in (".mp3", ".wav")
    )
    if not sources:
        print(f"no .mp3/.wav files under {root}")
        return 1
    for source in sources:
        process(source, force)
    remaining = [p for p in root.rglob("*") if p.suffix in (".mp3", ".wav")]
    print(f"done: {len(sources)} processed, {len(remaining)} sources left")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
