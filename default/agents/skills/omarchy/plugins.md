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

## Bar Appearance

Bar-wide look is set with `omarchy bar` too; each writes `bar.<key>` in
`shell.json` and applies live. Everything here is opt-in: unset, the bar looks
as it always has.

```bash
omarchy bar position top                    # top|bottom|left|right
omarchy bar transparent true                # true|false|toggle: bar background off
omarchy bar pills section                   # off|section|widget|toggle
omarchy bar floating true                   # true|false|toggle
```

- `pills` gives widgets their own background. `section` joins neighbouring
  widgets into one pill; a spacer ends it, even `{"id": "omarchy.spacer",
  "size": 0}`, and so does a change of `"group": "<name>"` between neighbours.
  `widget` gives every widget its own pill. `"pill": false` on a layout entry
  keeps that widget off pills.
- `floating` lifts the bar into the gap above the windows: half of
  Hyprland's `gaps_out` from the screen edge, so the gap above the bar
  matches the gap below it, and the full `gaps_out` at its ends, so it lines
  up with the windows. Windows do not move when it is toggled, and the corners
  follow the windows'. The gap follows Hyprland's `gaps_out`; change that
  rather than adding a bar setting.
- "Floating pills" is `transparent true`, `pills section`, `floating true`.
- Right-click empty bar space has switches for the background, floating, and
  pills.
- `pills toggle` and `floating toggle` ask the running bar, so they start from
  what it shows, theme defaults included, and pills come back in the last mode
  used since the shell started. With no shell running they flip `shell.json`
  (pills between `off` and `section`).

Theme-level keys go in the `[bar]` section of `~/.config/omarchy/shell.toml`
(or a theme's `shell.toml`) and apply on save. A theme can turn features on
by default; `shell.json` still wins.

- Floating: `margin` (`N`, `"Y X"`, `"T X B"`, `"T R B L"`; non-zero floats
  the bar unless `bar.floating` is false) and `radius`.
- Pills: `pills` (default mode), `pill`, `pill-alpha`, `pill-text`,
  `pill-border`, `pill-border-alpha`, `pill-radius`, `pill-inset`,
  `pill-padding`, `pill-gap`.

Unset, pills use the bar colours and Hyprland's rounding. The theme template
lists every key with an example: `$OMARCHY_PATH/default/themed/shell.toml.tpl`.
Blur behind the bar is a Hyprland layer rule on the `omarchy-bar` namespace,
not a bar setting; see `hyprland.md`.

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
