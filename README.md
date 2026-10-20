# Moodist (offline Flutter port)

Ambient sounds for focus and calm — an Android Flutter port of the
open-source [Moodist](https://github.com/remvze/moodist) web app.
All 84 sounds are bundled inside the app, so it works with **no internet
connection at all**: the release APK does not even declare the
`INTERNET` permission.

## Install

Grab the APK for your phone's CPU (most phones: `arm64-v8a`) from
`build/app/outputs/flutter-apk/` after building, copy it to the phone,
and open it to sideload:

- `app-arm64-v8a-release.apk` (~141 MB) — modern 64-bit phones
- `app-armeabi-v7a-release.apk` (~138 MB) — older 32-bit phones
- `app-x86_64-release.apk` (~142 MB) — emulators
- `app-release.apk` (~176 MB) — universal, works everywhere

## Features

- 84 ambient sounds in 8 categories (Nature, Rain, Animals, Urban,
  Places, Transport, Things, Noise), layered into custom mixes
- Per-sound volume sliders, master volume, smooth fade in/out
- Background and lock-screen playback with media notification controls
- Sleep timer (5–60 min or custom) with a 20-second fade-out
- Presets: save, rename, delete, and reapply mixes
- Favorites and search
- Your last mix, favorites, and presets persist on-device

## Build from source

The sound files are not committed to this repo (see `CREDITS.md`).
Fetch them once from the upstream project, then build:

```sh
pip install -r tool/requirements-audio.txt   # one-time, for seamless-loop processing
./tool/fetch_sounds.sh   # downloads 89 sounds, converts them to seamless .ogg loops (~75 MB)
flutter pub get
flutter build apk --release --split-per-abi
```

The fetch script trims MP3 padding and crossfades each file's tail
into its head (`tool/make_seamless_loops.py`), so loops have no
audible seam or dip when they restart.

Release builds are signed with `android/upload-keystore.jks`
(credentials in `android/key.properties`). Both files are git-ignored;
back them up — future updates must use the same key or Android will
refuse to install over the old version.

### Sound assets

`assets/sounds/` (89 files, ~116 MB) comes from the upstream project at
the commit pinned in `tool/fetch_sounds.sh`. Re-run that script to
re-download. See `CREDITS.md` for licensing (code: MIT; sounds:
Pixabay Content License / CC0).

## Development

```sh
flutter analyze
flutter test
flutter run          # debug build on a connected device
```

Note: `shared_preferences` is pinned to `2.3.5` with
`shared_preferences_android: 2.3.3` (see `dependency_overrides` in
`pubspec.yaml`) — the 2.5.x Android plugin crashes with
`NoSuchMethodError` on this Flutter/Kotlin combination.
