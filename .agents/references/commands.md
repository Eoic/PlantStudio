# Canonical Commands

Run commands from repo root unless noted otherwise.

## Native Linux Path

Build the native toolchain image:

```bash
scripts/build-native-image.sh
```

Build the native binary in the container:

```bash
SKIP_IMAGE_BUILD=1 scripts/build-native-linux.sh
```

Run the headless native smoke test:

```bash
SKIP_IMAGE_BUILD=1 scripts/test-native-linux.sh
```

Capture the native proof PNG:

```bash
SKIP_IMAGE_BUILD=1 scripts/capture-native-linux.sh
```

Current native proof artifact:

- `artifacts/native-linux-viewer.png`

Current sample file used by native harness:

- `for-olpc-python/test.pla`

## Native CLI Flags

The current shell parses these flags in `native-linux/app/mainform.pas`:

```text
--file <path>
--quit-after-load
--quit-after-render
--screenshot <png-path>
--plant-index <n>
--grow <days>
--rotate-y <degrees>
```

## Legacy Oracle Path

Build the legacy image:

```bash
scripts/build-legacy-image.sh
```

Run the legacy smoke test:

```bash
SKIP_IMAGE_BUILD=1 scripts/test-legacy-viewer.sh
```

Capture the legacy proof PNG:

```bash
SKIP_IMAGE_BUILD=1 scripts/capture-legacy-screenshot.sh
```

Run the legacy viewer interactively:

```bash
scripts/run-legacy-viewer.sh
```

Current legacy proof artifact:

- `artifacts/legacy-viewer.png`

## Useful Repo Inspections

Find active native Pascal files:

```bash
rg --files native-linux/app
```

Search archival units:

```bash
rg -n "symbol-or-behavior" converted_source/used
```

Compare current native CLI wiring:

```bash
rg -n -- "--file|--quit-after-load|--quit-after-render|--screenshot|--plant-index|--grow|--rotate-y" native-linux/app/mainform.pas
```

## Verification Expectations

- Rendering or shell changes: run the native smoke path and capture a PNG.
- Harness changes: run the affected wrapper script directly.
- Oracle-related changes: rerun the legacy smoke or screenshot path.
- Documentation-only changes: verify referenced commands and paths still exist.
