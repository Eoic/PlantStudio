# PlantStudio Architecture Snapshot

## Product Layout

- `native-linux/` is the active Linux port.
- `converted_source/used/` is the archival Pascal source of truth for missing
  PlantStudio behavior.
- `for-olpc-python/` is a regression oracle for loading and drawing, not the
  product.
- `linux-legacy/` packages the legacy GTK proof-of-life runtime.

## Native Build And Runtime Flow

1. `scripts/build-native-image.sh` builds `native-linux/Containerfile`.
2. `scripts/build-native-linux.sh` runs `scripts/native-container.sh build`.
3. `scripts/test-native-linux.sh` runs `scripts/native-container.sh smoke`.
4. `scripts/capture-native-linux.sh` runs `scripts/native-container.sh screenshot`.

The native binary is built from `native-linux/app/plantstudio_native.lpi` and
copied to `native-linux/build/plantstudio-native` in the container.

## Native App Shape

- `native-linux/app/mainform.pas`
  Lazarus shell, CLI flags, list selection, grow and rotate controls,
  screenshot save path, and paint orchestration.
- `native-linux/app/psplatform.pas`
  Linux platform defaults such as XDG config path handling.
- `native-linux/app/psplanttext.pas`
  Text `.pla` library loading.
- `native-linux/app/psplantmodel.pas`
  Current native plant model and drawing entrypoint.
- `native-linux/app/psturtle.pas`
  Turtle-based rendering support.
- `native-linux/app/pstdo.pas`
  TDO support under the native port.
- `native-linux/app/psdrawingsurface.pas`
  Drawing surface bound to Lazarus `TCanvas`.

## Archival Relationship

The native app is not a recompiled `Umain`. It is a curated shell that ports
behavior cluster by cluster from archival units.

Current high-value archival clusters:

- Platform and compatibility: `udomain.pas`, `ufiler.pas`, `ubitmap.pas`
- Model and growth: `uplant.pas`, `Uparams.pas`, `umakepm.pas`, `usection.pas`
- Rendering: `uturtle.pas`, `Udrawingsurface.pas`, `Utdo.pas`, `U3dsupport.pas`
- Full UI and forms: `Umain.pas` plus secondary dialog units

## Future Architecture Direction

- Keep the native shell thin and Linux-native.
- Port archival behavior in narrow slices with tests and PNG proof.
- Replace Win32 services behind native abstractions instead of importing them
  whole.
- Reach functional parity before visual redesign.
