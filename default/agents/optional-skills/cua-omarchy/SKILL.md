---
name: cua-omarchy
description: Operate native applications with Cua Driver on Omarchy and Hyprland, or diagnose its packaged installation and Wayland session. Complements the upstream cua-driver skill; use for computer-use tasks, not general desktop customization or plugin development.
---

# Cua on Omarchy

Read the companion upstream skill, `cua-driver`, and its Linux guide for the action loop and tool contracts; `cua-driver skills install` links it beside this one. This skill adds the Omarchy package and Hyprland checks. If the companion is missing, inspect the installed CLI's help and schemas, and install its skills when setup is part of the requested task.

## Establish the running driver

Omarchy installs the driver as the `cua-driver-bin` package, so `command -v cua-driver` should resolve to `/usr/bin/cua-driver`, a link to `/usr/lib/cua-driver/cua-driver`. For setup, diagnosis, or a changed installation, check `readlink -f` of that path, `cua-driver --version`, and `pacman -Q cua-driver-bin`; `pacman -Qo` on the resolved executable establishes package ownership. A user-local link may legitimately point at the packaged binary, so its location alone does not identify a custom build.

Check `cua-driver status` and the executable of the actual serving process when runtime behavior disagrees with the CLI: an older local service or an existing MCP connection can still run a different binary. Inspect the relevant unit names and executable paths; do not dump whole process environments or configuration files. A skill refresh does not reconnect MCP clients or change their configured executable.

An executable link ending in `(deleted)` means its inode was replaced, not necessarily that the running bytes differ. Compare `sha256sum /proc/<serving-pid>/exe` with the resolved packaged executable before diagnosing version drift or proposing a restart.

Use the desktop user's Wayland session and session bus. The native backend needs `CUA_DRIVER_RS_ENABLE_WAYLAND=1` in the environment of the process serving the calls; exporting it in a new shell does not change an already running daemon. Inspect a service's configuration before changing it, and restart only the service the task covers.

Run `cua-driver doctor` or `cua-driver call health_report '{}'` for diagnostics. Passing AT-SPI and Wayland checks establishes prerequisites, not successful window capture, input, or focus preservation. If a command is unavailable, consult `cua-driver --help` and `cua-driver describe <tool>` for this installation.

## Target and verify on Hyprland

Obtain the current `pid` and `window_id` from `list_windows` and select the intended window explicitly. Hyprland addresses from `hyprctl -j clients` help with diagnosis but are not interchangeable with Cua's window IDs. After launching an application, enumerate its windows rather than assuming the launch result includes them.

Take `get_window_state` for that exact target before acting. Prefer a returned `element_token`, or use `element_index` with its matching `snapshot_id`. Re-snapshot after an action and use the new handles. Keep a multi-call workflow on one persistent MCP connection as described upstream; a repeated session label across one-shot CLI processes does not preserve its lifecycle. Use only session parameters the current schemas advertise, and end sessions the workflow owns when finished.

To exercise a running service over persistent MCP, pass the endpoint reported by `cua-driver status` to `cua-driver mcp --socket <endpoint>`. Bare `mcp` on Linux owns a separate runtime, so its results say nothing about that service.

Read `hyprctl -j monitors` when diagnosing geometry: negative desktop origins are valid, and fractional scale means compositor coordinates and screenshot pixels are different domains. Use coordinates from the returned window PNG directly for window pixel actions; do not add monitor offsets or multiply by scale. If the display layout changes, take a fresh snapshot. A null `z_index`, `is_on_screen`, or a launch result's `active` flag does not establish keyboard focus; use the compositor's active window for diagnostic comparison.

Hyprland's capture and virtual-input protocols do not guarantee exact capture of an arbitrary window or background raw input. If the driver cannot establish the target surface, use the accessibility result when it suffices; do not treat an output crop as proof of that window's pixels or dispatch pixel actions against unproven capture.

Honor `background_unavailable`, `surface_identity_unproven`, and other capability refusals. Foreground delivery can affect focus, workspace, and the real pointer, so use it within the user's existing foreground authorization or obtain it. Do not bypass a refusal with `hyprctl` focus dispatches or generic input injection. Verify the requested postcondition from fresh state; a delivery acknowledgment alone is insufficient.

An `unverifiable` result with a foreground escalation hint is not proof that input failed: a native GTK entry can show the typed text while its fresh AT-SPI tree still omits the value. Inspect a fresh screenshot before repeating text or advancing the delivery mode. If the pixels already satisfy the task, stop. If capture is unavailable, retain the uncertainty instead of replaying input that may have been delivered.

## The Hyprland plugin

Omarchy's Cua install also installs the `cua-hyprland-plugin` package when the package channel carries it. Installing it loads nothing: the module sits at `/usr/lib/cua/hyprland/cua-hyprland-plugin.so` until the user loads it in a session, and enabling its input route is a further explicit step that changes the keymap. Check `hyprctl -j plugin list` and `hyprctl -j cua:status` before attributing any behavior to the plugin; a loaded module, a healthy probe, and successful delivery are separate evidence. Do not load, unload, or reconfigure it as part of a computer-use task: that is the user's call, and hot replacing a mapped module is unsupported.

## Maintain the package and skills separately

The packaged driver updates through `omarchy update`; its own self-updater is disabled and declines. Do not replace it with a vendor bootstrap or a remembered custom-build path to repair a skills problem.

Run skills management as the desktop user: `cua-driver skills status` reports the upstream pack and its agent links, and `cua-driver skills update` refreshes that pack in place. The installer removes its destination before downloading a replacement, so back up local edits to the upstream directory first, and keep this companion out of it: this skill is a link into `$OMARCHY_PATH` and updates with Omarchy. Newly installed skills may need a new agent session to be discovered.

For tests, use a disposable application and keep screenshots limited to that target. Record discovery, capture, semantic input, raw input, and focus/cursor checks separately. Input into an already focused window does not prove input to an unfocused or occluded window, and before/after focus samples do not prove the absence of transient focus changes.
