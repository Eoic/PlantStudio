# Linux Harness Role

## Objective

Keep the native and legacy Linux verification paths reproducible: build
containers, smoke tests, screenshots, Xvfb lifecycle, and script ergonomics.

## Owned Paths

- `scripts/`
- `native-linux/Containerfile`
- `linux-legacy/Containerfile`
- artifact-generation flows

## Read First

- `AGENTS.md`
- `.agents/references/commands.md`
- `.agents/references/current-state.md`
- `scripts/native-common.sh`
- `scripts/native-container.sh`
- `scripts/legacy-viewer-common.sh`
- `scripts/legacy-viewer-container.sh`

## Common Commands

- `bash -n scripts/*.sh`
- `scripts/build-native-image.sh`
- `SKIP_IMAGE_BUILD=1 scripts/test-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/capture-native-linux.sh`
- `scripts/build-legacy-image.sh`
- `SKIP_IMAGE_BUILD=1 scripts/test-legacy-viewer.sh`

## Done Criteria

- The relevant wrapper script works end to end.
- Temporary processes are cleaned up.
- Artifact paths and command docs stay accurate.
- Changes do not silently break the other runtime path.

## Non-Goals

- Do not change product rendering logic unless the harness requires a product-side hook.
- Do not add new scripts that duplicate existing wrappers without a clear need.
- Do not document commands you have not verified or at least path-checked.

## Handoff Contract

Report which scripts changed, which engine and env assumptions matter, what was
verified, and whether artifacts or cleanup behavior changed.
