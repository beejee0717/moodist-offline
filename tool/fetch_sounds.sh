#!/usr/bin/env bash
# Downloads Moodist audio assets from the upstream repo at a pinned commit
# into assets/sounds/, so the app can bundle them and run fully offline.
#
# Upstream: https://github.com/remvze/moodist (code: MIT; sounds: Pixabay
# Content License / CC0 — see CREDITS.md).
set -euo pipefail

UPSTREAM_SHA="11c0be2200116a3635880d600fd6953899cc51a3"
RAW="https://raw.githubusercontent.com/remvze/moodist/${UPSTREAM_SHA}/public/sounds"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${ROOT}/assets/sounds"

# category/file list (84 catalog sounds; alarm.mp3 and silence.wav excluded)
FILES="
nature/river.mp3 nature/waves.mp3 nature/campfire.mp3 nature/wind.mp3
nature/howling-wind.mp3 nature/wind-in-trees.mp3 nature/waterfall.mp3
nature/walk-in-snow.mp3 nature/walk-on-leaves.mp3 nature/walk-on-gravel.mp3
nature/droplets.mp3 nature/jungle.mp3
rain/light-rain.mp3 rain/heavy-rain.mp3 rain/thunder.mp3 rain/rain-on-window.mp3
rain/rain-on-car-roof.mp3 rain/rain-on-umbrella.mp3 rain/rain-on-tent.mp3
rain/rain-on-leaves.mp3
animals/birds.mp3 animals/seagulls.mp3 animals/crickets.mp3 animals/wolf.mp3
animals/owl.mp3 animals/frog.mp3 animals/dog-barking.mp3 animals/horse-gallop.mp3
animals/cat-purring.mp3 animals/crows.mp3 animals/whale.mp3 animals/beehive.mp3
animals/woodpecker.mp3 animals/chickens.mp3 animals/cows.mp3 animals/sheep.mp3
urban/highway.mp3 urban/road.mp3 urban/ambulance-siren.mp3 urban/busy-street.mp3
urban/crowd.mp3 urban/traffic.mp3 urban/fireworks.mp3
places/cafe.mp3 places/airport.mp3 places/church.mp3 places/temple.mp3
places/construction-site.mp3 places/underwater.mp3 places/crowded-bar.mp3
places/night-village.mp3 places/subway-station.mp3 places/office.mp3
places/supermarket.mp3 places/carousel.mp3 places/laboratory.mp3
places/laundry-room.mp3 places/restaurant.mp3 places/library.mp3
transport/train.mp3 transport/inside-a-train.mp3 transport/airplane.mp3
transport/submarine.mp3 transport/sailboat.mp3 transport/rowing-boat.mp3
things/keyboard.mp3 things/typewriter.mp3 things/paper.mp3 things/clock.mp3
things/wind-chimes.mp3 things/singing-bowl.mp3 things/ceiling-fan.mp3
things/dryer.mp3 things/slide-projector.mp3 things/boiling-water.mp3
things/bubbles.mp3 things/tuning-radio.mp3 things/morse-code.mp3
things/washing-machine.mp3 things/vinyl-effect.mp3 things/windshield-wipers.mp3
noise/white-noise.wav noise/pink-noise.wav noise/brown-noise.wav
binaural/binaural-alpha.wav binaural/binaural-beta.wav binaural/binaural-delta.wav
binaural/binaural-gamma.wav binaural/binaural-theta.wav
"

count=0
for rel in $FILES; do
  out="${DEST}/${rel}"
  mkdir -p "$(dirname "$out")"
  if [ -s "$out" ]; then
    echo "skip (exists)  $rel"
  else
    echo "download       $rel"
    curl -fSL --retry 3 -o "$out" "${RAW}/${rel}"
  fi
  count=$((count + 1))
done

echo "---"
echo "files expected: $count"
echo "files on disk:  $(find "$DEST" -type f \( -name '*.mp3' -o -name '*.wav' \) | wc -l)"
du -sh "$DEST"

# Convert downloads into seamless OGG loops (see make_seamless_loops.py).
# Without this step the app still works, but loops have an audible seam.
if python3 -c "import miniaudio, soundfile, numpy" 2>/dev/null; then
  python3 "${ROOT}/tool/make_seamless_loops.py" "$DEST"
else
  echo "WARNING: python deps for seamless loops not found; keeping .mp3/.wav."
  echo "To enable: pip install -r tool/requirements-audio.txt"
  echo "then run: python3 tool/make_seamless_loops.py assets/sounds"
  echo "and point lib/data/sound_catalog.dart asset paths at the .ogg files."
fi
