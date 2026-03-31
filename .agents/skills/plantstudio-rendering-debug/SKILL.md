---
name: plantstudio-rendering-debug
description: Diagnose PlantStudio rendering mismatches in the native Linux port using the native screenshot path, sample .pla files, and archival or legacy-oracle comparisons.
metadata:
  short-description: Debug native PlantStudio render and screenshot mismatches
---

# PlantStudio Rendering Debug

Use this skill when the problem is visual: wrong geometry, wrong fit, wrong
rotation, missing TDOs, or a render regression.

## Read First

- `AGENTS.md`
- `.agents/references/commands.md`
- `.agents/references/unit-map.md`
- `.agents/roles/rendering-tdo.md`
- `native-linux/app/psturtle.pas`
- `native-linux/app/pstdo.pas`

## Workflow

1. Reproduce with one sample `.pla` and a fully specified command line.
2. Capture the current native PNG artifact.
3. Compare behavior against archival intent or the legacy oracle when useful.
4. Localize the bug to fit logic, turtle traversal, TDO parsing, or drawing-surface behavior.
5. Re-run the same smoke or screenshot path after the fix.
6. Record the exact command and visible outcome in the handoff.

## Common Traps

- Changing shell logic before proving the issue is actually in rendering
- Debugging without a fixed sample file and CLI flag set
- Leaving visual changes without a PNG artifact

## Expected Output

- One reproducible render regression case
- A narrow fix in the correct rendering-owned path
- Updated screenshot proof and verification notes
