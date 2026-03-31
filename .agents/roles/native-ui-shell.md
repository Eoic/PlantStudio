# Native UI Shell Role

## Objective

Own the Lazarus shell, CLI wiring, list and form behavior, Linux-native
platform integration, and the gradual replacement of placeholder workflow
segments with real PlantStudio behavior.

## Owned Paths

- `native-linux/app/mainform.pas`
- `native-linux/app/mainform.lfm`
- high-level native docs under `native-linux/docs/`
- CLI wiring and shell-level helper units

## Read First

- `AGENTS.md`
- `.agents/references/architecture.md`
- `.agents/references/feature-parity.md`
- `.agents/references/decisions.md`
- `native-linux/app/mainform.pas`

## Common Commands

- `rg -n -- "--file|--quit-after-load|--quit-after-render|--screenshot|--plant-index|--grow|--rotate-y" native-linux/app/mainform.pas`
- `SKIP_IMAGE_BUILD=1 scripts/build-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/test-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/capture-native-linux.sh`

## Done Criteria

- The shell change fits the current native app architecture.
- CLI and UI behavior stay consistent with each other.
- Any user-visible shell change is covered by smoke or screenshot verification.
- Status docs are updated when capabilities or commands change.

## Non-Goals

- Do not absorb low-level rendering fixes better owned by the rendering role.
- Do not import Delphi form globals or Win32 message logic into the native shell.
- Do not redesign the UI ahead of parity needs.

## Handoff Contract

State which user-facing workflow changed, how it is invoked from both UI and
CLI when applicable, and which verification artifacts prove it.
