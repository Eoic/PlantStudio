---
name: plantstudio-parity-audit
description: Turn a missing PlantStudio Linux feature into a decision-complete parity task by anchoring it to archival forms or units and native target paths.
metadata:
  short-description: Convert missing Linux features into parity task briefs
---

# PlantStudio Parity Audit

Use this skill when the need is not direct implementation but precise parity
scoping: what is missing, where it lives in the archival source, and what the
native Linux target should be.

## Read First

- `AGENTS.md`
- `.agents/references/feature-parity.md`
- `.agents/references/unit-map.md`
- `.agents/references/decisions.md`
- `.agents/roles/parity-audit.md`

## Workflow

1. Name one missing feature or workflow only.
2. Find the archival units or forms that define it.
3. Decide the native target path and owner role.
4. Note Linux-native replacements for any Windows-era assumptions.
5. Write a task brief or parity-gap note with exact acceptance commands.
6. Update parity references if the inventory itself changed.

## Common Traps

- Bundling multiple unrelated missing workflows together
- Naming a feature without archival anchors
- Ignoring Linux replacements for help, printing, clipboard, or browser launch

## Expected Output

- A single decision-complete parity task brief
- Clear archival anchors and native ownership
- Acceptance criteria with build, smoke, and artifact expectations
