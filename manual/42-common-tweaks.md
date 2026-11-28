# Common tweaks

This is a collection of common tailorings to the Omarchy setup. Know that it might occasionally be necessary for system updates to restore certain configs to their original condition. If this happens, your changes won't be lost, but put in a `.bak.<timestamp>` file next to the original.

If you screw something up, you can restore individual configs to their original setup via _Update > Config_ in the Omarchy menu. If you _really_ screw everything up, you can reset all configs via `omarchy reinstall configs`, or reinstall every default package and config with `omarchy reinstall`.

### Reveal all tray icons all the time

By default, tray icons, like Dropbox, 1password, or Steam, are hidden behind the tray expander arrow, which reveals them when you hover it. If you'd like to have them exposed all the time, right-click the expander arrow to open the tray icon manager, then pin the icons you want to keep visible (you can also hide the ones you never want to see).

### Rounded window corners

Omarchy's default design is one of square corners, but if you like to soften that up a bit, pick _Appearance > Windows > Window Corners > Rounded Corners_ in the Omarchy menu, or run `omarchy hyprland corners rounded`. _Theme Corners_ goes back to whatever the theme uses. To pick your own radius, stay on _Theme Corners_ (`omarchy hyprland corners theme`), since Rounded and Sharp load after your config and override it, and uncomment rounding in `~/.config/hypr/looknfeel.lua`:

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
