# Overlay output recovery

Run `bash test/shell.d/overlay-output-recovery-test.sh` from the checkout. The test loads the checkout's real `shell/Ui/OverlayWindow.qml` into a small Quickshell fixture inside a separate nested Hyprland compositor. It never removes, disables, or focuses an output in the parent desktop. Both child processes are stopped on success or failure.

The test requires a reachable Wayland compositor, Hyprland with Lua configuration, Quickshell, wtype, and Python. The shell wrapper reports a skip when the compositor or a required tool is unavailable. Once started, runtime failures fail the test. The nested compositor uses the Wayland backend (`AQ_DRM_DEVICES=/dev/null`); its removable Wayland outputs use the parent's buffer modifiers, avoiding NVIDIA's unsupported linear-buffer allocation for nested headless outputs.

Each run removes a second output three times while the overlay is parked and three times while it is open. It checks the actual layer namespace, remaining output, layer number, dimensions, parked keyboard mode, and delivery of a key after recovery. It also disables and restores the only output, checking the zero-output interval and stable visibility-change counts. The wrapper uses a fresh nested compositor for the parked and open zero-output cases, avoiding repeated FALLBACK transitions in the nested backend. No shell restart or plugin reload is used to recover the overlay.

The existing first-show-after-moving-output behavior tracked in #13562 is outside this test. The fixture parks and reopens on the removable output before removing it, so that separate bug cannot mask the output-recovery result.

To retain command receipts, compositor and fixture logs, and screenshots when `grim` is installed:

```bash
python test/shell.d/fixtures/overlay-output-recovery/run.py "$PWD" --artifacts /tmp/overlay-parked
python test/shell.d/fixtures/overlay-output-recovery/run.py "$PWD" --zero-output-open --artifacts /tmp/overlay-open
```

For a negative control, pass `--overlay /path/to/OverlayWindow.qml`. Unmodified `quattro` and the recovery implementation with its explicit `visible = false` removed both fail when the parked surface's output is removed. The fixture imports the selected file itself; it does not match source text or mock the screen-removal signal.
