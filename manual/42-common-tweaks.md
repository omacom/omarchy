# Common tweaks

This is a collection of common tailorings to the Omarchy setup. Know that it might occasionally be necessary for system updates to restore certain configs to their original condition. If this happens, your changes won't be lost, but put in a `.bak` file in the same directory.

If you screw something up, you can restore individual configs to their original setup via _Update > Config_ in the Omarchy menu. If you _really_ screw everything up, you can reset all configs via `omarchy-reinstall`.

### Reveal all tray icons all the time

By default, tray icons, like Dropbox, 1password, or Steam, are hidden behind the tray expander arrow, which reveals them when you hover it. To keep every icon in the bar instead, including those of apps you install later, run:

```bash
omarchy bar set omarchy.tray unlisted visible
```

The arrow then shows only while the drawer has something in it, such as a widget you dragged there. Set it back to `drawer` for the default.

To choose icon by icon, pick **Manage tray icons** at the end of any tray icon's right-click menu (or right-click the arrow) and pin the icons you want to keep visible. You can hide the ones you never want to see there too, in either mode.

### Rounded window corners

Omarchy's default design is one of square corners, but if you like to soften that up a bit, you can change `~/.config/hypr/looknfeel.lua` so rounding is no longer commented out:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Remove window gaps

On laptop displays, some people prefer not to waste any pixels on window gaps (or even a top bar, which you can toggle off with `Super + Shift + Space`). You can toggle all gaps and borders off with `Super + Shift + Backspace`, or remove them permanently by removing the comments in this section of `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
