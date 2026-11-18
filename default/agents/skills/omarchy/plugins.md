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

## Making a New Bar Plugin

A bar plugin is a folder `~/.config/omarchy/plugins/<username>.<name>/` (its id, e.g. `alice.counter`) with a manifest, the widget, and its strings:

```json
{
  "schemaVersion": 1,
  "id": "alice.counter",
  "name": "Counter",
  "version": "1.0.0",
  "author": "alice",
  "description": "Counts clicks in the bar",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "BarWidget.qml" },
  "barWidget": { "displayName": "Counter", "description": "Counts clicks in the bar", "category": "Tools", "allowMultiple": false, "defaultSection": "right" }
}
```

`BarWidget.qml` extends `BarWidget` and draws itself with `WidgetButton`, which gives it the bar's font, colors, hover, tooltip, and press feedback. Its `text` is the label (an icon-font glyph or words), `active: true` draws it in the urgent color, and `onPressed` gets the mouse button:

```qml
import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "alice.counter"
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  property int count: 0

  Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: String(root.count)
    tooltipText: strings.t("tooltip")
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) { root.count = 0 } else { root.count++ }
    }
  }
}
```

- Keep state in QML properties and drive time with a `Timer` that runs only while something is counting; an idle widget starts no timers or processes. Don't name a property after one every item already has (`state`, `visible`, `enabled`, `width`, `opacity`): `property int state` collides with the item's own `state`, and assigning to it fails.
- Run commands with `root.bar.run("omarchy-notification-send 'Counter' 'Reached 100'")`.
- Icons are Nerd Font glyphs written straight into the label text, as the built-in widgets do (`text: "󰐊"`). Find one by name in Nerd Fonts' table rather than by drawing the font, preferring the `md-` (Material Design) set the bar uses, then look at the widget to check it:

  ```bash
  curl -s https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/glyphnames.json \
    | jq -r 'to_entries[] | select(.key | test("^md-.*timer")) | "\(.key) \(.value.char)"'
  ```
- A card that opens on click, for details that don't fit the bar, is a `PopupCard` in the widget, the way the media widget shows the playing track. It grows from the widget and fades, closes when the user clicks anywhere else (by calling the widget's `close()`), and mirrors for right-to-left languages. In the counter above, left click opens it and right click resets:

  ```qml
  property bool popupOpen: false
  function close() { popupOpen = false }

  WidgetButton {
    // ...as above, with:
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) { root.count = 0 } else { root.popupOpen = !root.popupOpen }
    }
  }

  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(280))
    contentHeight: popup.fittedContentHeight(column.implicitHeight)

    Column {
      id: column
      width: parent.width
      spacing: Style.space(6)

      Text {
        textFormat: Text.PlainText
        text: strings.t("title")
        color: Commons.Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.subtitle
        font.bold: true
      }
      Text {
        textFormat: Text.PlainText
        text: Commons.I18n.formatNumber(root.count)
        color: Commons.Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.body
      }
    }
  }
  ```

  This needs `import qs.Commons as Commons` beside `import qs.Commons`. A keyboard-driven panel that a hotkey summons is more: `$OMARCHY_PATH/shell/plugins/panels/clock/` is the reference for that, for settings from `shell.json`, and for IPC.

Then check it, look at it, and put it on the bar. `omarchy agent look plugin <dir>` renders the widget in a bar strip with the current theme, without touching the running bar, and lists the QML errors it logged; open the image it prints and fix what looks wrong. Saving any file under the plugin folder reloads it on the bar:

```bash
omarchy plugin validate ~/.config/omarchy/plugins/alice.counter
omarchy agent look plugin ~/.config/omarchy/plugins/alice.counter
omarchy bar put alice.counter --section right
```

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

## Plugin Motion

Motion in a plugin should feel like the rest of the shell. Most of it comes free from Omarchy's kit in `qs.Ui`: a `KeyboardPanel` grows out of its bar icon and fades, morphs into a neighbouring panel in the same bar section, and grows to fit content that arrives late; a `PopupCard` grows and fades; a `Button` gives a little when pressed. Build on those rather than animating your own open and close.

For anything the plugin animates itself, `import qs.Commons` and:

- Give every duration as `Style.duration(ms)`, never a bare number. It returns 0 when the user has turned animations off with `omarchy toggle animations`.
- Ease movement and entrances with `Style.easeOut` (`easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut`) or `Easing.OutCubic`. Never an ease-in curve, no bounce, and linear only for constant motion such as a spinner.
- Keep it under 300ms, with exits shorter than entrances: about 180ms in, 120ms out.
- Never scale from 0; start at 0.95–0.97 with opacity 0.
- Don't animate what a single keystroke opens or dismisses many times a day; it should just appear or go.
- Animate only for a reason: showing where something came from or went, confirming an input, or keeping a change from jumping.

```qml
import QtQuick
import qs.Commons

Item {
  property bool shown: false
  opacity: shown ? 1 : 0
  scale: shown ? 1 : 0.97
  Behavior on opacity { NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
  Behavior on scale {
    NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
  }
}
```

## Translations

Omarchy runs in 50 languages, and a plugin should follow the one picked under Setup > Region > Language the way the built-in plugins do: live, without a shell restart. Ship the plugin's strings as flat JSON catalogs in an `i18n/` directory beside its QML, one file per Omarchy language code (`en.json`, `da.json`, `pt-BR.json`; `$OMARCHY_PATH/default/i18n/locales.json` lists all 50), and read them through `Commons.Translations`:

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
`omarchy-shell shell reloadPlugins`.

## Idle and Lock

Set `idle.screensaver` and `idle.lock` in `~/.config/omarchy/shell.json`,
in seconds since user idle began. Example: "lock after ten minutes" means
setting `idle.lock` to `600`.
