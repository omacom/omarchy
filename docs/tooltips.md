# Tooltips

Omarchy uses one tooltip surface for its bar popup, `PanelToolTip`, and ordinary Qt Quick Controls tooltips. The surface follows the current tooltip palette, theme border specification, configured font and scale. Text wraps at a bounded width. Short opacity transitions use `Style.duration`, so disabling compositor animations also disables tooltip motion.

## Ordinary hints

Existing `Button.tooltipText`, `PanelToolTip`, and Qt Controls `ToolTip.text` consumers keep their APIs. Plain hints do not take keyboard focus and treat their text as plain text. Other controls retain the Fusion style.

```qml
Button {
  text: "Refresh"
  tooltipText: "Refresh the current view"
}
```

## Interactive content

Use `HoverCard` only when a hint needs controls. Its content is loaded when shown and destroyed when closed. Moving from the source into the card keeps it open; leaving both closes it after a short grace period. Hover does not take focus. Call `openForKeyboard()` from a keyboard action to enter the card, use Tab between controls, and Escape to close. Qt Popup manages focus restoration, including clicks on another control.

```qml
Button {
  id: source
  text: "Details"
  Keys.onReturnPressed: details.openForKeyboard()
  HoverCard {
    id: details
    parent: source
    sourceHovered: source.hovered
    content: Component {
      Button { text: "Open details"; onClicked: openDetails() }
    }
  }
}
```

No rich card, extra window, timer, or content tree is created for an ordinary hint. The card's delay timers run only around an interaction; the preference reader uses a file-change signal.

## Appearance preferences

The optional `${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/tooltips.json` file applies to all three hosts and the standalone style provider. Missing settings inherit the theme:

```json
{"shape":"theme","borderMode":"theme","borderColor":"#ffffff"}
```

`shape` accepts `theme`, `square`, or `rounded`. `borderMode` accepts `theme`, `transparent`, or `custom`; custom colors must be `#RRGGBB`. Overrides preserve the theme's border widths. Theme mode preserves gradients and follows subsequent theme changes. Invalid updates retain the last valid appearance; deleting the file restores defaults. Writers should replace the JSON file atomically. These settings never rewrite a theme or Hyprland configuration.

## Independent applications and runtime packaging

Stock Quickshell 0.3.1 forces Fusion before loading an entrypoint unless that entrypoint declares `RespectSystemStyle`. Setting the Qt style in a shell launcher cannot cover existing independent applications. The Omarchy-owned patch in `default/tooltips/` makes that default configurable through `QS_QUICK_CONTROLS_STYLE`, retaining Fusion when the variable is empty or unset and preserving entrypoint overrides. It is a distribution compatibility patch; this change does not require a PR to Quickshell or Hyprland.

The standalone provider is packaged in Qt's standard QML module directory with its own small copy of the required Omarchy primitives. Consumers may replace `QML_IMPORT_PATH` and need not import Omarchy's private UI kit. The private palette reader watches theme files because independent applications do not receive the shell's theme IPC. This covers Omarchy/Qt Quick Controls applications; GTK, browser content, Qt Widgets, and applications choosing their own tooltip implementation keep their respective toolkits.

### Reversible local trial

Run `omarchy install tooltips` from the feature checkout. It builds the pinned Quickshell 0.3.1 source and packages the existing official package payload with the tested runtime and style provider. It copies the currently selected Omarchy release (or the explicit `--base` source) and applies only the tooltip integration, then selects that copy with the existing dev-link mechanism. It does not replace the installed Omarchy source tree or restart the desktop. The original runtime package and previous Omarchy selection read from `/etc/omarchy.conf` are retained for rollback. An explicit `--base` changes only the copy source, never the selection restored on uninstall or failure. A reboot is required for all launchers to inherit the environment.

The installer refuses incompatible runtime versions and requires the original package archive. It uses terminal sudo for package installation and dev-link changes. Run `omarchy install tooltips --uninstall` to restore the previous runtime and selection, then reboot after saving your work. An unrelated later change to the selected Omarchy tree prevents automatic uninstall rather than overwriting that selection. Runtime updates must be reconciled with this compatibility patch before using a different Quickshell release.

## Validation

`bash test/shell.d/tooltips-test.sh` covers native styling, wrapping, theme changes, lazy card lifetime, Qt input events, focus, cancellation, motion, and atomic preference changes. `bash test/shell.d/tooltip-runtime-packaging-test.sh` verifies the generated standalone provider without a consumer UI kit. The stock-runtime boundary is tested separately from the patched-runtime policy; an offscreen input test does not replace real Wayland/manual validation.
