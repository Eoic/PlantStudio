# PlantStudio Legacy Linux Viewer

This repo now includes a reproducible Linux proof-of-life path for the legacy
`for-olpc-python` viewer using Ubuntu 18.04, Python 2.7, and PyGTK 2 inside a
container.

## Requirements

- `podman` or `docker`

By default the scripts use `podman`. Set `CONTAINER_ENGINE=docker` to switch.

## Build The Image

```bash
scripts/build-legacy-image.sh
```

## Headless Verification

This starts a fixed-display `Xvfb` server in the container, launches the
viewer, waits for startup, and then shuts everything down cleanly.

```bash
scripts/test-legacy-viewer.sh
```

## Screenshot Capture

This captures a PNG proof of the rendered viewer window at
`artifacts/legacy-viewer.png`.

```bash
scripts/capture-legacy-screenshot.sh
```

## Interactive Run

This forwards the host X11 display into the container and starts the viewer.

```bash
scripts/run-legacy-viewer.sh
```

If your X server denies the connection, allow local container clients first:

```bash
xhost +local:
```

## Scope

This is a legacy-runtime proof of life, not a modernized port. It targets the
OLPC GTK viewer path only and leaves the larger Lazarus/FPC native port for
future work.
