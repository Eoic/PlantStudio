---
name: plantstudio-linux-harness
description: Work on PlantStudio's native and legacy Linux build, smoke, Xvfb, and screenshot wrappers without breaking reproducible verification flows.
metadata:
  short-description: Maintain native and legacy Linux verification harnesses
---

# PlantStudio Linux Harness

Use this skill when the task touches container files, wrapper scripts, Xvfb
lifecycle, screenshot capture, or verification ergonomics.

## Read First

- `AGENTS.md`
- `.agents/references/commands.md`
- `.agents/references/current-state.md`
- `.agents/roles/linux-harness.md`

## Workflow

1. Identify whether the change affects the native path, the legacy oracle, or both.
2. Keep public wrapper scripts stable unless a deliberate interface change is required.
3. Verify script syntax first, then run the affected smoke or screenshot path.
4. Preserve cleanup behavior and artifact expectations.
5. Update command docs and current-state notes if the workflow changed.

## Common Traps

- Breaking one runtime path while only testing the other
- Changing artifact names or paths without updating docs
- Leaving implicit environment assumptions undocumented

## Expected Output

- Reproducible wrapper behavior
- Clear verification notes
- Updated command documentation if the interface changed
