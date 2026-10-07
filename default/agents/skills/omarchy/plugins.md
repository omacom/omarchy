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

## Bar Pills

`"pills"` in the `bar` block of `~/.config/omarchy/shell.json` gives widgets
their own background, so the bar background can be dropped
(`omarchy bar transparent true`) and the widgets still sit on something. It is
opt-in: unset or `"off"`, the bar looks as it always has. It applies on save.

- `"section"` joins neighbouring widgets into one pill; a spacer ends it, even
  `{"id": "omarchy.spacer", "size": 0}`, and so does a change of
  `"group": "<name>"` between neighbours. `"widget"` gives every widget its
  own pill. `"pill": false` on a layout entry keeps that widget off pills.
- Theme keys in the `[bar]` section of `~/.config/omarchy/shell.toml` (or a
  theme's `shell.toml`): `pills` (a default mode; `shell.json` wins), `pill`,
  `pill-alpha`, `pill-text`, `pill-border`, `pill-border-alpha`,
  `pill-radius`, `pill-inset`, `pill-padding`, `pill-gap`. Unset, pills use
  the bar colours and Hyprland's rounding. The theme template lists them with
  examples: `$OMARCHY_PATH/default/themed/shell.toml.tpl`.
- Blur behind the bar is a Hyprland layer rule, not a bar setting; see
  `hyprland.md`.

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
