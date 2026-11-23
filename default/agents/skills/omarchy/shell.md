# Omarchy Shell: Bar, Widgets, and Idle

Read this before changing the status bar layout, notifications, built-in
widgets, or idle/lock behavior. Writing a new plugin or widget, or the QML of
a cloned one, follows the omarchy-make-plugin skill.

The bar, dock, notification daemon, settings panel, and assorted overlays all
run inside a single long-running Quickshell process (logged in the journal as
`omarchy-shell`). The `omarchy-shell` command is its IPC client.

```
~/.config/omarchy/shell.json             # User overrides: bar, plugins, idle
~/.config/omarchy/plugins/<plugin-id>/   # User-owned shell plugins
$OMARCHY_PATH/config/omarchy/shell.json  # Canonical defaults
```

The shell hot-reloads `shell.json` on save — no restart needed for layout
changes. `idle.screensaver` and `idle.lock` are seconds since user idle began.

**Commands:** `omarchy restart shell`, `omarchy refresh shell`

## Bar Layout

Use the `omarchy bar` group to move and manage widgets:

```bash
omarchy bar position [top|bottom|left|right]
omarchy bar background [opaque|glassy|none|cycle]
omarchy bar move omarchy.clock --section right
omarchy bar put omarchy.keyboard-layout --after omarchy.clock   # Add a widget
omarchy bar set omarchy.clock format "dddd h:mm AP"             # A widget's own option (here a 12-hour clock)
omarchy bar get omarchy.clock format
omarchy bar reset                                               # Back to the built-in bar
omarchy toggle bar [on|off]                                     # Hide or show it (on hides)
```

For layout edits beyond what the commands cover, edit the bar configuration
in `~/.config/omarchy/shell.json`; it hot-reloads on save.

`bar.layout` has five sections, in the order they run along the bar: `left`,
`centerBegin`, `center`, `centerEnd`, and `right`, plus `tray`, drawn inside
the tray's drawer. `center` is a box in the middle of the bar whose widgets
are centered as one group; `centerBegin` and `centerEnd` hang off its two
edges. Put a widget beside the clock in `centerBegin` or `centerEnd`, not in
`center`, or the clock moves off center.

## Dock

The dock shows on floating workspaces. Its pinned apps are desktop ids (`dock.pinned` in `shell.json`):

```bash
omarchy dock position [top|bottom|left|right]
omarchy dock autohide [on|off|toggle]
omarchy dock pin folio
omarchy dock unpin folio
```

## Customizing Built-In Plugins and Widgets

To customize a built-in bar widget, never edit `$OMARCHY_PATH/shell/plugins/`.
Clone it into the user plugin directory instead:

```bash
omarchy plugin clone omarchy.workspaces
# Edit ~/.config/omarchy/plugins/<username>.workspaces/; saved changes reload automatically.
```

Cloning switches the bar to the cloned copy (e.g. `<username>.workspaces`),
which is yours to edit and survives updates. Follow the omarchy-make-plugin
skill for the QML you write in it.

Saving a file anywhere under `~/.config/omarchy/plugins/` reloads plugin code
automatically. If a change somehow fails to apply, force a reload with
`omarchy-shell shell reloadPlugins`.

## Idle and Lock

Set `idle.screensaver` and `idle.lock` in `~/.config/omarchy/shell.json`,
in seconds since user idle began. Example: "lock after ten minutes" means
setting `idle.lock` to `600`.
