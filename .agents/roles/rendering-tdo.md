# Rendering And TDO Role

## Objective

Own the render path: turtle traversal, TDO handling, drawing-surface behavior,
viewport fitting, screenshot outputs, and visual regressions.

## Owned Paths

- `native-linux/app/psturtle.pas`
- `native-linux/app/pstdo.pas`
- `native-linux/app/psdrawingsurface.pas`
- `native-linux/app/ps3dtypes.pas`
- Screenshot-specific render helpers and related tests

## Read First

- `AGENTS.md`
- `.agents/references/architecture.md`
- `.agents/references/unit-map.md`
- `.agents/references/commands.md`
- `converted_source/used/uturtle.pas`
- `converted_source/used/Udrawingsurface.pas`
- `converted_source/used/Utdo.pas`

## Common Commands

- `SKIP_IMAGE_BUILD=1 scripts/test-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/capture-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/capture-legacy-screenshot.sh`
- `file artifacts/native-linux-viewer.png`

## Done Criteria

- The native render path remains scriptable and headless.
- Rendering changes have an updated PNG proof when practical.
- Any regression investigation names the exact sample `.pla` and CLI flags used.
- Render behavior is compared to archival intent or legacy oracle output when needed.

## Non-Goals

- Do not take ownership of general form wiring or non-render shell behavior.
- Do not push rendering fixes into the legacy app unless the oracle path itself is broken.
- Do not leave a render change without a reproducible screenshot command.

## Handoff Contract

Provide the sample file, command line, artifact path, visible change, and any
remaining mismatch with archival or oracle behavior.
