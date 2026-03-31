# Current State

Last refreshed: 2026-04-01

## Active Product State

- `native-linux/` is the active Linux application workspace.
- The native app is a real Lazarus/FPC build, not just a placeholder window.
- The native shell currently supports:
  - loading a text `.pla` file via CLI
  - selecting a plant from the sidebar
  - rendering through the native turtle and TDO path
  - scripted grow and rotate arguments
  - headless PNG proof generation
- The legacy GTK viewer remains available as an oracle under `for-olpc-python/`.

## Documented Working Commands

Validated during the agent-scaffold pass:

- `bash -n scripts/*.sh`
- `python /home/karolis/.codex/skills/.system/skill-creator/scripts/quick_validate.py .agents/skills/plantstudio-native-port`
- `python /home/karolis/.codex/skills/.system/skill-creator/scripts/quick_validate.py .agents/skills/plantstudio-rendering-debug`
- `python /home/karolis/.codex/skills/.system/skill-creator/scripts/quick_validate.py .agents/skills/plantstudio-linux-harness`
- `python /home/karolis/.codex/skills/.system/skill-creator/scripts/quick_validate.py .agents/skills/plantstudio-parity-audit`
- `SKIP_IMAGE_BUILD=1 scripts/test-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/capture-native-linux.sh`

Canonical product verification paths:

- `scripts/build-native-image.sh`
- `SKIP_IMAGE_BUILD=1 scripts/build-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/test-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/capture-native-linux.sh`
- `scripts/build-legacy-image.sh`
- `SKIP_IMAGE_BUILD=1 scripts/test-legacy-viewer.sh`
- `SKIP_IMAGE_BUILD=1 scripts/capture-legacy-screenshot.sh`

## Current Gaps

- Full document open, save, and edit parity is still missing.
- The main native shell is not yet equivalent to archival `Umain`.
- Secondary forms such as breeder, wizard, time series, and TDO editors are
  not ported.
- Export, printing, help, drag-and-drop, and browser integration are not at
  parity.
- The archival platform and compatibility layer is still incomplete.

## Next Recommended Work Tracks

1. Port the next archival core cluster needed for document and editing parity.
2. Expand the native shell from preview-plus-controls into the real main
   PlantStudio workflow.
3. Formalize render regression comparison between the native app and the
   legacy oracle.
4. Inventory and schedule secondary forms in parity order instead of ad hoc.

## Maintenance Rule

If your task changes the native product, parity status, or verification path,
update this file in the same change.
