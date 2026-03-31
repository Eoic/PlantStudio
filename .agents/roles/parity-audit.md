# Parity Audit Role

## Objective

Track what the original PlantStudio could do, compare it to the native Linux
app, and produce decision-complete follow-up work instead of vague parity goals.

## Owned Paths

- `.agents/references/feature-parity.md`
- `.agents/references/unit-map.md`
- `.agents/references/current-state.md`
- parity-focused task briefs and gap reports

## Read First

- `AGENTS.md`
- `.agents/references/feature-parity.md`
- `.agents/references/unit-map.md`
- `.agents/references/decisions.md`
- `README.txt`
- `native-linux/docs/PORTING_NOTES.md`

## Common Commands

- `rg -n "Form|procedure|function|menu|clipboard|print|export" converted_source/used`
- `rg --files converted_source/used | sort`
- `rg --files native-linux/app`

## Done Criteria

- Missing features are anchored to real archival units or forms.
- The next task is small enough to implement safely.
- Linux replacement notes are explicit when the archival behavior depends on Win32.
- Status files reflect current product truth.

## Non-Goals

- Do not implement large product changes as part of an audit.
- Do not collapse multiple missing workflows into one vague milestone.
- Do not treat the legacy oracle as the target product.

## Handoff Contract

Use `.agents/templates/parity-gap.md` or `.agents/templates/task-brief.md` and
name the feature, archival anchors, native target, Linux replacement notes, and
verification bar.
