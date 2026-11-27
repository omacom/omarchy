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

## Bar Appearance

Bar-wide look is set with `omarchy bar` too; each writes `bar.<key>` in
`shell.json` and applies live. Everything here is opt-in: unset, the bar keeps
its stock look.

```bash
omarchy bar pills section                   # off|section|widget|toggle
omarchy bar floating true                   # true|false|toggle
```

- `background`: `opaque` draws the bar, `glassy` draws it see-through and
  turns on Hyprland's blur behind it, `none` drops it. `cycle` steps none,
  glassy, opaque. With pills on, `opaque` raises the pills on the bar,
  `glassy` makes them frosted glass with no strip, and `none` gives solid
  pills on the wallpaper.
- `pills` gives widgets their own background. `section` joins neighboring
  widgets into one pill; a spacer ends it, even `{"id": "omarchy.spacer",
  "size": 0}`, and so does a change of `"group": "<name>"` between neighbors.
  `widget` gives every widget its own pill. `"pill": false` on a layout entry
  keeps that widget off pills.
- `floating` moves the bar into the gap between the screen edge and the
  windows: half of Hyprland's `gaps_out` from the screen edge, so the gap is
  the same on both sides of the bar, and the full `gaps_out` at its ends, so
  it lines up with the windows. Windows do not move when it is toggled, and
  the corners follow the windows'. The gap follows Hyprland's `gaps_out`;
  change that rather than adding a bar setting.
- "Floating pills" is `background none`, `pills section`, `floating true`;
  with `background glassy` the floating pills are frosted glass.
- Right-click empty bar space for a card with the background (click to
  cycle it), floating and pills.
- `pills toggle` and `floating toggle` ask the running bar, so they start from
  what it shows, theme defaults included, and pills come back in the last mode
  used since the shell started. With no shell or bar running they flip
  `shell.json` (pills between `off` and `section`). If the shell does not
  answer in time they fail rather than flip, since it may still act; check
  the bar before running them again.

Theme-level keys go in the `[bar]` section of `~/.config/omarchy/shell.toml`
(or a theme's `shell.toml`) and apply on save. A theme can turn features on
by default; `shell.json` still wins.

- Floating: `margin` (`N`, `"Y X"`, `"T X B"`, `"T R B L"`; a margin on an edge
  the bar touches floats it unless `bar.floating` is false) and `radius`.
- Pills: `pills` (default mode), `pill`, `pill-alpha`, `pill-text`,
  `pill-border`, `pill-border-alpha`, `pill-radius`, `pill-inset`,
  `pill-padding`, `pill-gap`.

Unset, pills use the bar colors and Hyprland's rounding. The theme template
lists every key with an example: `$OMARCHY_PATH/default/themed/shell.toml.tpl`.
Frosted pills come from `background glassy`. Blur behind translucent pills
on a clear bar is a Hyprland layer rule on the `omarchy-bar` namespace, not a
bar setting; see `hyprland.md`.

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
