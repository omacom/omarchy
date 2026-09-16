# Remembering desktop applications

Session persistence is opt-in through `omarchy-setup-session`. Setup links the shipped user unit from `default/session/` into the user's unit directory and enables it. The unit is not enabled during first run and adds no dependency on a coordinated package manifest change: `omarchy-settings` already ships `default/**`.

The helper in `default/session/session.py` stores a private, schema-versioned JSON snapshot under `$XDG_STATE_HOME/omarchy/session/last.json`. A temporary file, fsync, and rename keep a failed save from damaging the last complete snapshot. Only desktop-entry identity, class, and positive workspace ID are retained. Desktop discovery follows XDG data directories and user overrides, including hidden entries; class matching is literal.

At graphical login the unit claims the Hyprland instance in `$XDG_RUNTIME_DIR/omarchy-session/restored` before launching, so restarting the service cannot launch the same session repeatedly. Applications start through `uwsm-app -- gtk-launch`, matching the app launcher: restored applications belong to their own scopes rather than the session watcher's cgroup. Running applications are skipped and each desktop entry is launched at most once. The first matching window moves to its saved workspace through the Lua dispatcher.

The watcher saves every 30 seconds. Automatic empty snapshots are ignored; explicit Save can record an empty session. Omarchy's reboot, shutdown, and logout commands request a final snapshot before closing windows and freeze further automatic saves. Failed power scheduling cancels the freeze. The snapshot request is bounded and cannot prevent power actions from proceeding. Shutdown outside these commands uses the most recent periodic snapshot; it cannot guarantee capturing the exact desktop before teardown.

No application documents, tabs, terminal jobs, process arguments, window titles, precise tiled layout, floating geometry, or special workspaces are persisted. These limits appear in the user manual and setup flow. The service does not attempt checkpoint/restore of processes or synchronize session state across machines.

Focused tests exercise minimal/private state, desktop-entry resolution and overrides, invalid state, compositor failure, duplicate avoidance, skipped applications, logout freezing, and once-per-login restoration. The graphical acceptance test checks the actual menu and a desktop-entry launch in a disposable Omarchy VM; a real logout/reboot pass is required before calling the lifecycle verified.
