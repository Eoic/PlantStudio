# Fixed Project Decisions

## Product Direction

- The end product is a full-featured Linux PlantStudio.
- The native Lazarus/FPC app is the primary path.
- The legacy GTK path is a regression oracle only.
- Functional parity comes before any redesign or icon refresh.

## Source Hierarchy

- `native-linux/` is live product code.
- `converted_source/used/` is the archival behavior reference.
- `for-olpc-python/` and `for-jython/` are historical reference paths.

## Porting Style

- Prefer curated ports of archival behavior clusters over wholesale form or unit resurrection.
- Replace Windows-bound services behind Linux-native adapters.
- Avoid pulling old UI globals, clipboard hooks, printer code, or help-file assumptions directly into the native shell.
- Keep write sets narrow and aligned to role ownership.

## Linux Replacements

- Settings paths use XDG defaults.
- Browser launch should be Linux-native, not `ShellExecute`.
- Help content should become HTML or bundled local docs, not `.hlp`.
- Clipboard should use Lazarus or Linux-native clipboard APIs.
- Printing should use Lazarus printer support on Linux or CUPS-backed behavior.
- Drag-and-drop should use Lazarus event support, not Win32 message plumbing.

## Licensing And Feature Gating

- Linux builds should ship with full functionality enabled.
- Historical registration or export throttling is retired for the Linux port.
- Registration UI, if preserved, is historical or informational only.

## Verification Policy

- Rendering and UI changes need a reproducible command and PNG proof when practical.
- Any task that changes project status must update:
  - `.agents/references/current-state.md`
  - `.agents/references/feature-parity.md`
  - `.agents/references/unit-map.md`
