# PlantStudio Unit Map

Status values:

- `native`: already active in `native-linux/app/`
- `partial`: partially represented in the native port
- `planned`: not yet ported, but on the parity path
- `archive-only`: reference only for now

## Platform And Compatibility

| Archival unit | Native target | Status | Owner | Notes |
| --- | --- | --- | --- | --- |
| `usstream.pas` | `native-linux/app/usstream.pas` | native | archival-core-port | Imported helper already active |
| `usupport.pas` | `native-linux/app/pssupport.pas` | partial | archival-core-port | Native helper surface, not full archival port |
| `udomain.pas` | `native-linux/app/psplatform.pas` plus future domain shim | planned | archival-core-port | Replace Win32 path and service assumptions |
| `ufiler.pas` | future native stream or filer shim | planned | archival-core-port | Needed for broader save/load parity |
| `ubitmap.pas` | future native bitmap adapter | planned | rendering-tdo | Replace printer, clipboard, DIB, and cache logic |
| `ucollect.pas` | future list or collection shim | planned | archival-core-port | Keep only semantics needed by active clusters |

## Model And Growth

| Archival unit | Native target | Status | Owner | Notes |
| --- | --- | --- | --- | --- |
| `uplant.pas` | `native-linux/app/psplantmodel.pas` | partial | archival-core-port | Real model path exists, parity not complete |
| `Uparams.pas` | future native parameter manager | planned | archival-core-port | Needed for deeper model parity |
| `umakepm.pas` | future native parameter bootstrap | planned | archival-core-port | Builds parameter catalog |
| `usection.pas` | future native section manager | planned | archival-core-port | Needed for parameter and UI parity |
| `upart.pas` | curated native subtree | planned | archival-core-port | Plant-part behavior |
| `uintern.pas` | curated native subtree | planned | archival-core-port | Internal traversal and growth |
| `uleaf.pas` | curated native subtree | planned | archival-core-port | Leaf growth and draw behavior |
| `umerist.pas` | curated native subtree | planned | archival-core-port | Meristem logic |
| `uinflor.pas` | curated native subtree | planned | archival-core-port | Inflorescence logic |
| `ufruit.pas` | curated native subtree | planned | archival-core-port | Fruit logic |
| `utravers.pas` | curated native subtree | planned | archival-core-port | Traversal logic |
| `urandom.pas` | curated native subtree | planned | archival-core-port | Deterministic growth support |
| `uamendmt.pas` | curated native subtree | planned | archival-core-port | Amendment support |
| `utransfr.pas` | curated native subtree | planned | archival-core-port | Transform support |
| `umath.pas` | `native-linux/app/ps3dtypes.pas` plus future math helpers | partial | rendering-tdo | Geometry path still incomplete |

## Rendering, Turtle, And TDO

| Archival unit | Native target | Status | Owner | Notes |
| --- | --- | --- | --- | --- |
| `uturtle.pas` | `native-linux/app/psturtle.pas` | partial | rendering-tdo | Active render path, not full archival parity |
| `Udrawingsurface.pas` | `native-linux/app/psdrawingsurface.pas` | partial | rendering-tdo | Bound to Lazarus canvas |
| `Utdo.pas` | `native-linux/app/pstdo.pas` | partial | rendering-tdo | TDO path exists, more parity work remains |
| `U3dsupport.pas` | `native-linux/app/ps3dtypes.pas` plus future helpers | partial | rendering-tdo | Geometry and support subset only |
| `U3dexport.pas` | future native export layer | planned | rendering-tdo | Export parity later |

## Main UI And Workflow

| Archival unit or form | Native target | Status | Owner | Notes |
| --- | --- | --- | --- | --- |
| `Umain.pas` | `native-linux/app/mainform.pas` | partial | native-ui-shell | New shell, not form parity |
| startup settings and config | `native-linux/app/psplatform.pas` | partial | native-ui-shell | XDG pathing exists |
| plant list and preview | `mainform.pas` | partial | native-ui-shell | Active, but not full editing workflow |
| open, save, close, edit tools | future shell work | planned | native-ui-shell | Needs true workflow parity |
| undo and redo stack | future shell plus core port | planned | native-ui-shell | Not yet active |
| clipboard workflows | future Linux adapter | planned | native-ui-shell | Replace Win32 clipboard assumptions |

## Secondary Forms And Feature Areas

| Feature area | Archival anchor | Status | Owner | Notes |
| --- | --- | --- | --- | --- |
| breeder | breeder-related archival form units | archive-only | parity-audit | Inventory first, then port |
| time series | time-series archival form units | archive-only | parity-audit | Inventory first, then port |
| wizard | wizard archival units | archive-only | parity-audit | Inventory first, then port |
| TDO editor and mover | TDO-related form units | archive-only | parity-audit | Depends on rendering parity |
| options, about, welcome, debug | form units under archival tree | archive-only | parity-audit | Linux replacements or Lazarus ports needed |
| bitmap, nozzle, and export dialogs | export-related units | archive-only | parity-audit | After core draw parity |
| help and browser launch | UI integration units | archive-only | parity-audit | Replace `.hlp` and ShellExecute assumptions |
