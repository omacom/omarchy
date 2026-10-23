# Overlay output recovery

Run `bash test/shell.d/overlay-output-recovery-test.sh` from the checkout. The test loads the checkout's real `shell/Ui/OverlayWindow.qml` into a small Quickshell fixture inside a separate nested Hyprland compositor. It never removes, disables, or focuses an output in the parent desktop. Both child processes are stopped on success or failure.

The test requires a reachable parent Hyprland compositor with Lua configuration, Quickshell, wtype, and Python. The shell wrapper reports a skip when the compositor or a required tool is unavailable. Once started, runtime failures fail the test. The nested compositor uses the Wayland backend (`AQ_DRM_DEVICES=/dev/null`); its removable Wayland outputs use the parent's buffer modifiers, avoiding NVIDIA's unsupported linear-buffer allocation for nested headless outputs.

Each run uses uniquely named nested outputs. A temporary parent window rule floats only their `aquamarine` host windows at 800x600, matching the nested monitor configuration. This prevents parent tiling changes from leaving the nested backend's Qt screen geometry stale. The rule is disabled during cleanup and no config files are changed. The backend's generic first output is replaced before the fixture starts, so it never needs a broad window rule.

Each run removes a second output three times while the overlay is closed and three times while it is open. Closed overlays must have no mapped surface, following the lifecycle introduced by #14458. Open overlays must recover on the remaining output with visible content and keyboard input. The test checks the actual layer namespace, remaining output, layer number, dimensions, content readiness, and delivery of a key after recovery. It also disables and restores the only output, checking the zero-output interval and stable visibility-change counts. The wrapper uses a fresh nested compositor for the closed and open zero-output cases, avoiding repeated FALLBACK transitions in the nested backend. No shell restart or plugin reload is used to recover the overlay.

To retain command receipts, compositor and fixture logs, and screenshots when `grim` is installed:

```bash
python test/shell.d/fixtures/overlay-output-recovery/run.py "$PWD" --artifacts /tmp/overlay-closed
python test/shell.d/fixtures/overlay-output-recovery/run.py "$PWD" --zero-output-open --artifacts /tmp/overlay-open
```

For a negative control, pass `--overlay /path/to/OverlayWindow.qml`. Removing the production screen-change handler prevents an open overlay from recovering after its output disappears. The fixture imports the selected file itself; it does not match source text or mock the screen-removal signal.
