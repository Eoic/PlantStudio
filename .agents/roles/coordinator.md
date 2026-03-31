# Coordinator Role

## Objective

Break work into narrow, decision-complete tasks and assign the correct role,
skill, and path ownership before edits start.

## Owned Paths

- `.agents/`
- Cross-cutting planning notes and handoff files

## Read First

- `AGENTS.md`
- `.agents/references/current-state.md`
- `.agents/references/feature-parity.md`
- `.agents/references/unit-map.md`
- `.agents/references/decisions.md`

## Common Commands

- `rg --files native-linux/app converted_source/used scripts`
- `rg -n "behavior-or-symbol" converted_source/used`
- `rg -n -- "--file|--quit-after-load|--quit-after-render|--screenshot|--plant-index|--grow|--rotate-y" native-linux/app/mainform.pas`

## Done Criteria

- The task has one clear owner and a narrow write set.
- Dependencies and archival anchors are named explicitly.
- Acceptance commands and artifact expectations are specified.
- Parallel work, if any, uses disjoint write paths.

## Non-Goals

- Do not implement product code just because the task is understood.
- Do not give multiple agents overlapping ownership.
- Do not invent redesign work ahead of parity needs.

## Handoff Contract

Use `.agents/templates/task-brief.md` for delegated work and require the result
to name changed paths, verification commands, artifacts, and next blockers.
