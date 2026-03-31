---
name: plantstudio-native-port
description: Port one archival PlantStudio Pascal behavior cluster into the native Linux workspace, keeping write sets narrow and avoiding resurrection of the old Delphi main-form stack.
metadata:
  short-description: Port curated archival Pascal clusters into the native app
---

# PlantStudio Native Port

Use this skill when the task is to port one bounded archival Pascal slice into
`native-linux/app/`.

## Read First

- `AGENTS.md`
- `.agents/references/architecture.md`
- `.agents/references/unit-map.md`
- `.agents/references/decisions.md`
- `.agents/roles/archival-core-port.md`

## Workflow

1. Identify the smallest archival behavior cluster that can satisfy the task.
2. Confirm the target ownership boundary in `native-linux/app/`.
3. Replace Win32 dependencies with native shims instead of dragging them in.
4. Keep the shell decoupled from Delphi global forms and old UI state.
5. Verify with the native build or smoke path.
6. Update `unit-map.md`, `feature-parity.md`, and `current-state.md` if status changed.

## Common Traps

- Porting a whole form or huge dependency chain when only one behavior cluster is needed
- Leaving new code dependent on `Windows`, `WinTypes`, `WinProcs`, or old form globals
- Treating the archival tree as live code instead of a reference source

## Expected Output

- A narrow native port with explicit archival anchors
- Reproducible verification commands
- Updated status references when capability changed
