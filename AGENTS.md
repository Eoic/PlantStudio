# PlantStudio Agent Guide

## Mission

The goal of this repository is a full-featured Linux PlantStudio with feature
parity to the historical Delphi application. Reach parity first. Modernize the
GUI, icons, and workflows only after the Linux application can do the same
useful work as the original.

## Source Of Truth

Use the repo in this order:

1. `native-linux/`
   The active product and only place for ongoing Linux product evolution.
2. `converted_source/used/`
   The archival Pascal behavior reference and the source for curated ports.
3. `for-olpc-python/`
   Legacy regression oracle for plant loading and drawing behavior.
4. `for-jython/`
   Historical reference only.

Do not turn the archival Delphi tree into the live app. Port curated behavior
from it into the native workspace.

## Repo Map

- `native-linux/app/`: Lazarus/FPC application, current Linux entrypoint
- `native-linux/docs/`: native port notes
- `scripts/`: native and legacy build, smoke, and screenshot harnesses
- `converted_source/used/`: archival Pascal units and forms
- `for-olpc-python/`: legacy GTK proof-of-life and sample `.pla` files
- `linux-legacy/`: legacy runtime container
- `artifacts/`: generated PNG proofs and other non-source outputs
- `.agents/`: agent roles, references, skills, and handoff templates

Start every non-trivial task by reading:

1. `.agents/references/current-state.md`
2. `.agents/references/decisions.md`
3. `.agents/references/commands.md`
4. The role brief in `.agents/roles/` that matches your work

## Default Workflow

1. Confirm the feature or subsystem in `.agents/references/feature-parity.md`.
2. Map archival source units to native targets in `.agents/references/unit-map.md`.
3. Pick one role and keep the write set narrow.
4. Prefer curated ports into `native-linux/app/` over wholesale imports.
5. Verify with a reproducible command, and produce a PNG when rendering or UI
   behavior changes.
6. Update `.agents/references/current-state.md`, `feature-parity.md`, and
   `unit-map.md` when the task changes project status.

## Non-Negotiable Rules

- Parity before redesign.
- `native-linux/` is the live app. Do not grow new product logic under the
  legacy Python or Jython trees.
- Keep `converted_source/used/` effectively read-only except for explicit
  annotations the user asked for.
- Prefer behavior-preserving ports over speculative rewrites.
- Any task that changes rendering or UI behavior must end with:
  - a reproducible command
  - a clear statement of what changed
  - a PNG artifact when practical
- Avoid mixed ownership. If multiple agents work in parallel, assign disjoint
  path ownership first.

## Canonical Commands

Native:

- `scripts/build-native-image.sh`
- `SKIP_IMAGE_BUILD=1 scripts/build-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/test-native-linux.sh`
- `SKIP_IMAGE_BUILD=1 scripts/capture-native-linux.sh`

Legacy oracle:

- `scripts/build-legacy-image.sh`
- `SKIP_IMAGE_BUILD=1 scripts/test-legacy-viewer.sh`
- `SKIP_IMAGE_BUILD=1 scripts/capture-legacy-screenshot.sh`
- `scripts/run-legacy-viewer.sh`

Current native CLI flags in `native-linux/app/mainform.pas`:

- `--file`
- `--quit-after-load`
- `--quit-after-render`
- `--screenshot`
- `--plant-index`
- `--grow`
- `--rotate-y`

## Acceptance Bar

A task is not done until:

- the change is implemented in the correct workspace
- the relevant build or smoke path passes
- rendering changes have visual proof when applicable
- the parity ledger and current-state references are updated
- the handoff names the exact command used for verification

## Agent Scaffold

- `.agents/references/`: durable project context
- `.agents/roles/`: role-specific briefs and path ownership
- `.agents/templates/`: reusable task and handoff formats
- `.agents/skills/`: repo-local procedural skills

Use the coordinator role to decompose work. Use a specialized role only when
its owned paths match the intended write set.
