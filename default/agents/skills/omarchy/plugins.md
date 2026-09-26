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

Use the `omarchy bar` group to move and manage widgets:

```bash
omarchy bar move omarchy.clock --section right
```

For layout edits beyond what the commands cover, edit the bar configuration
in `~/.config/omarchy/shell.json`; it hot-reloads on save.

## Floating Bar

`"floating": true` in the `bar` block of `~/.config/omarchy/shell.json` lifts
the bar off the screen edge and rounds it like the windows. It is opt-in:
unset, the bar stays flush as it always has. It applies on save.

- With no theme margin the bar floats inside the gap above the windows: half
  of Hyprland's `gaps_out` from the screen edge, so the gap above the bar
  matches the gap below it, and the full `gaps_out` at its ends, so they line
  up with the windows. Windows do not move when floating is toggled; the gap
  follows Hyprland's `gaps_out`, so change that rather than adding a bar
  setting.
- Theme keys in the `[bar]` section of `~/.config/omarchy/shell.toml` (or a
  theme's `shell.toml`): `margin` (`N`, `"Y X"`, `"T X B"`, `"T R B L"`) and
  `radius`. A non-zero `margin` floats the bar on its own; `"floating": false`
  keeps it flush anyway.
- Combine with `omarchy bar transparent true` to drop the bar background.

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
