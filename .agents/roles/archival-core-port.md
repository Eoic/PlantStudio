# Archival Core Port Role

## Objective

Port curated archival Pascal behavior into the native workspace while removing
Win32 assumptions and keeping the native shell decoupled from Delphi globals.

## Owned Paths

- `native-linux/app/` core and compatibility units
- Curated archival subtree or native shims created for model, parameter, and
  stream behavior

## Read First

- `AGENTS.md`
- `.agents/references/architecture.md`
- `.agents/references/unit-map.md`
- `.agents/references/decisions.md`
- Relevant units under `converted_source/used/`

## Common Commands

- `rg -n "class|procedure|function|type" converted_source/used/uplant.pas converted_source/used/Uparams.pas converted_source/used/umakepm.pas converted_source/used/usection.pas`
- `rg -n "Windows|WinTypes|WinProcs|LZExpand" converted_source/used`
- `SKIP_IMAGE_BUILD=1 scripts/build-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/test-native-linux.sh`

## Done Criteria

- The ported slice compiles under the native build path.
- The port preserves archival behavior for the scoped feature.
- No new dependency on Delphi global forms or Win32-only services is introduced.
- Relevant maps in `.agents/references/` are updated.

## Non-Goals

- Do not bulk-copy the archival app into `native-linux/`.
- Do not port UI code under the guise of core logic.
- Do not preserve obsolete Windows service patterns when a native shim is needed.

## Handoff Contract

Name the archival units used, the new native ownership boundary, the exact
build or smoke command run, and any remaining Win32 assumptions still blocking
the next slice.
