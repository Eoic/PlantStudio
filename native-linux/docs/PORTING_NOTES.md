# PlantStudio Native Linux Port Notes

This workspace is the active Lazarus/FPC Linux port.

## Current scope

- Native Lazarus application project
- Containerized Ubuntu 24.04 + Lazarus 3.0 build path
- Scriptable CLI for smoke and screenshot verification
- Linux/XDG platform path helper
- Real text `.pla` metadata loading for:
  - `offset=`
  - `scale=`
  - `concentrated=`
  - `orientation (top/side)=`
  - `boxes=`
  - plant names from `[name] start PlantStudio plant <v...>`
- Verified PNG artifact output at `artifacts/native-linux-viewer.png`

## Implemented pieces

- `native-linux/app/plantstudio_native.lpi`
  Native Lazarus project.
- `native-linux/app/mainform.pas`
  Early native main window with plant list sidebar, grow/rotate controls, CLI
  flags, and screenshot support.
- `native-linux/app/psplatform.pas`
  Linux config-path handling with XDG defaults.
- `native-linux/app/usstream.pas`
  First directly imported archival PlantStudio helper unit, used for text
  parsing.
- `native-linux/app/psplanttext.pas`
  Native parser for top-level PlantStudio text plant-library metadata.
- `scripts/build-native-image.sh`
  Builds the native toolchain container.
- `scripts/build-native-linux.sh`
  Compiles the native Linux binary in the container.
- `scripts/test-native-linux.sh`
  Runs a headless smoke check under `Xvfb`.
- `scripts/capture-native-linux.sh`
  Produces a PNG proof image.

## Verified commands

- `scripts/build-native-image.sh`
- `SKIP_IMAGE_BUILD=1 scripts/build-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/test-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/capture-native-linux.sh`

## Next porting steps

- Bring over the next text-path Pascal units needed for richer `.pla` loading.
  Immediate candidates are string helpers from `usupport.pas` and the plant
  text loader logic from `uplant.pas`.
- Replace placeholder plant rendering with real PlantStudio drawing code.
  The likely first traversal/drawing cluster is `uturtle.pas`,
  `Udrawingsurface.pas`, and the minimal supporting math/support units they
  require.
- Start carving Linux-compatible replacements for Windows-bound services in
  `udomain.pas`, `ufiler.pas`, and `ubitmap.pas`.
- Port the original main workflow incrementally after the real loader and draw
  path exist, rather than trying to make `Umain.pas` compile in one jump.
