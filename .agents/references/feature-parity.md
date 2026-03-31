# PlantStudio Feature Parity Ledger

Status values:

- `working`: usable in the native Linux app now
- `partial`: visible or started, but not parity-complete
- `missing`: not yet available in the native Linux app

## Core Runtime

| Feature | Status | Notes |
| --- | --- | --- |
| Native Linux build in container | working | `scripts/build-native-image.sh` and `scripts/build-native-linux.sh` |
| Headless native smoke test | working | `scripts/test-native-linux.sh` |
| Native PNG proof | working | `scripts/capture-native-linux.sh` |
| XDG config path handling | working | Native path helper exists |
| Text `.pla` load path | partial | Active, but not full plant-file parity |
| Real plant selection, grow, and rotate in shell | partial | Current native shell supports core controls |

## Main Workflow

| Feature | Status | Notes |
| --- | --- | --- |
| Plant list sidebar and render pane | partial | Works in native shell |
| Open sample `.pla` via CLI | working | Current CLI flags support this |
| Open/save/close full document workflow | missing | Save path and full document model not ported |
| Selection and editing tools | missing | Main editing workflows still absent |
| Undo/redo | missing | No parity stack yet |
| Copy/paste plant or text | missing | Needs Linux clipboard adapter and workflow port |
| Arrangement and composition tools | missing | Not yet ported |
| Notes and metadata editing | missing | Not yet ported |

## Rendering And Growth

| Feature | Status | Notes |
| --- | --- | --- |
| Native turtle draw path | partial | Active, not archival-complete |
| TDO-backed render support | partial | Native TDO path exists |
| Grow by scripted age change | partial | Current shell supports CLI and buttons |
| Rotational render changes | partial | Current shell supports Y rotation |
| Visual regression comparison | partial | Legacy oracle exists, process not yet formalized |
| Export parity from render path | missing | 3D and bitmap export parity pending |

## Secondary Feature Areas

| Feature area | Status | Notes |
| --- | --- | --- |
| Breeder | missing | Not in native app |
| Time series | missing | Not in native app |
| Wizard | missing | Not in native app |
| TDO picker, editor, mover | missing | Native render support exists, UI not ported |
| Options and preferences dialog | missing | Only low-level config path exists |
| About, welcome, debug, program info | missing | No parity dialogs yet |
| Nozzle and animation generation | missing | Not ported |
| Printing | missing | Needs Lazarus/CUPS integration |
| Help content | missing | Needs HTML or bundled doc replacement |
| Browser and OS integration | missing | Needs Linux-native open-url behavior |
| Drag-and-drop open | missing | Needs Lazarus event wiring |

## Legacy Oracle

| Feature | Status | Notes |
| --- | --- | --- |
| Legacy viewer smoke test | working | Containerized proof of life |
| Legacy viewer screenshot | working | `artifacts/legacy-viewer.png` |
| Legacy runtime as product path | missing by design | Keep as oracle only |

## Priority Order

1. Full document and model parity in the native workspace
2. Main workflow parity in the native shell
3. Secondary forms and exports
4. Printing, help, browser launch, drag-and-drop, and other OS integrations
5. Visual redesign and UX modernization
