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

## Plugin UI Safety

Plugins run inside Omarchy's long-lived, unsandboxed shell. Treat text from network responses, files, IPC, settings, environment variables, and command output as untrusted.

- QML `Text` defaults to `Text.AutoText`. Do not bind untrusted data to an AutoText sink: markup-shaped input such as `<img src="https://example.invalid/tracker">` can be interpreted as rich text and load a resource.
- For display text owned by the plugin, set `textFormat: Text.PlainText`. Prefer a local `PlainText` component when the plugin has multiple text elements.

```qml
Text {
  textFormat: Text.PlainText
  text: modelData.name
}
```

- When passing dynamic text to an Omarchy-owned component whose internal `Text` format the plugin cannot set, neutralize markup in the plugin first with a helper of its own, and add a regression test; Omarchy ships no such helper. Never edit the packaged component to add a plain-text option: that belongs in a pull request to Omarchy.
- Bound and validate downloaded data before displaying or saving it: limit response and collection sizes, string lengths, identifiers, and timestamps.
- Keep network access explicit. Use fixed HTTPS sources, timeouts, response-size limits, and validation. For periodic background refreshes, disclose the behavior and let users enable or disable it. Never execute downloaded content or interpolate untrusted values into shell commands.
- Add regression coverage for markup-shaped input and every shared tooltip or notification sink that receives dynamic text.

## Translations

Omarchy runs in 50 languages, and a plugin should follow the one picked under Setup > Language the way the built-in plugins do: live, without a shell restart. Ship the plugin's strings as flat JSON catalogs in an `i18n/` directory beside its QML, one file per Omarchy language code (`en.json`, `da.json`, `pt-BR.json`; `$OMARCHY_PATH/default/i18n/locales.json` lists all 50), and read them through `Commons.Translations`:

```qml
import qs.Commons as Commons

Item {
  Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  Text {
    textFormat: Text.PlainText
    text: strings.tn("panel.items", count).arg(Commons.I18n.formatNumber(count))
  }
}
```

```json
{ "panel.items": { "one": "%1 item", "other": "%1 items" } }
```

- A string missing from the current language falls back to its base language (`pt-BR` to `pt`), then to `en.json`, then to the key, so a plugin can ship English alone and add languages one file at a time.
- Keep each string whole with `%1` placeholders filled by `.arg()`; never glue translated fragments into a sentence, since other languages reorder words.
- A string that counts something is a plural entry, an object keyed by CLDR category, read with `strings.tn(key, count)`. English needs `one` and `other`; each translation supplies the categories its language uses (Russian `one`, `few`, `many`, `other`; Arabic six; Japanese only `other`; the rules are in `$OMARCHY_PATH/shell/Commons/Plural.js`).
- Write displayed numbers with `Commons.I18n.formatNumber(value, decimals)` so they take the language's decimal separator and digits (`13,1` in Danish).
- Arabic, Hebrew, Persian, and Urdu mirror the layout. A plugin built on `KeyboardPanel` or `PopupCard` is mirrored for free; anything it positions by explicit `x` should follow `LayoutMirroring.enabled`, glyphs that mean back or forward should swap with `Commons.I18n.rightToLeft`, and Left/Right keys should go through `Util.readingKey(event)`.
- Keep calls to `strings.t(...)` inside bindings so a language switch re-renders them. Text built once when something happens keeps the old language until it is rebuilt.
- Format dates with `Qt.locale(Commons.I18n.formatLocale)`, not `Qt.formatDate` or a bare `Qt.locale()`: those follow the locale the shell started with, which changes only when it restarts.
- Keep brand names, units, and keyboard keys as they are, and leave log and diagnostic output in English.
- Use `strings.t()` only for the plugin's own text. `Commons.I18n` holds Omarchy's catalog, which can rename or drop its keys in any update.

## Bar Layout

Use the `omarchy bar` group to move and manage widgets:

```bash
omarchy bar move omarchy.clock --section right
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
omarchy bar position top                    # top|bottom|left|right
omarchy bar background none                 # opaque|glassy|none|cycle
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
  it lines up with the windows. Windows do not move when it is toggled (with
  `gaps_out` up to 50 for the stock bar), and the corners follow the
  windows'. The gap follows Hyprland's `gaps_out`; change that rather than
  adding a bar setting.
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
