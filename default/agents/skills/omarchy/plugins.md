# Omarchy Shell: Bar, Plugins, and Idle

Read this before changing the status bar, notifications, shell plugins,
widgets, or idle/lock behavior.

The bar, notification daemon, settings panel, and assorted overlays all run
inside a single long-running Quickshell process (`omarchy-shell`).

```
~/.config/omarchy/shell.json             # User overrides: bar, plugins, idle
~/.config/omarchy/plugins/<plugin-id>/   # User-owned shell plugins
$OMARCHY_PATH/config/omarchy/shell.json  # Canonical defaults
```

The shell hot-reloads `shell.json` on save — no restart needed for layout
changes. `idle.screensaver` and `idle.lock` are seconds since user idle began.

**Commands:** `omarchy restart shell`, `omarchy refresh shell`

## Bar Layout

The `omarchy bar` group covers the whole widget layout. Full syntax (from
`omarchy bar --help`):

```bash
omarchy bar position top                     # top|bottom|left|right
omarchy bar transparent true                 # true|false|toggle
omarchy bar put omarchy.keyboard-layout --after omarchy.clock   # place relative (--before/--after, never both)
omarchy bar move omarchy.clock --section center --index 0       # place by section (left|center|right), index, or --before/--after
omarchy bar set omarchy.clock format HH:mm   # per-widget setting; --json passes the value as JSON
omarchy bar use local.neon-bar               # switch the active bar layout
omarchy bar reset                            # return to the built-in Omarchy bar
omarchy bar defaults                         # restore the default bar and service widgets
```

For layout edits beyond what the commands cover, edit the bar configuration
in `~/.config/omarchy/shell.json`.

## Customizing Built-In Plugins and Widgets

To customize a built-in bar widget, never edit `$OMARCHY_PATH/shell/plugins/`.
Clone it into the user plugin directory instead:

```bash
omarchy plugin clone omarchy.workspaces
# Edit ~/.config/omarchy/plugins/<username>.workspaces/; saved changes reload automatically.
```

Cloning switches the bar to the cloned copy (e.g. `<username>.workspaces`),
which is yours to edit and survives updates.

Saving a file anywhere under `~/.config/omarchy/plugins/` reloads plugin code
automatically. If a change somehow fails to apply, force a reload with
`omarchy-shell shell rescanPlugins`.

## Idle and Lock

Set `idle.screensaver` and `idle.lock` in `~/.config/omarchy/shell.json`,
in seconds since user idle began. Example: "lock after ten minutes" means
setting `idle.lock` to `600`.

To stop the system from idling at all (keep-awake), use
`omarchy toggle idle stay-awake` (`allow-idle` re-enables idle behavior,
`status` reports the current state, bare `omarchy toggle idle` flips it).
