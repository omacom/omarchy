# Monitors

Omarchy assumes you're running on a 2x-capable retina-class display by default. This is what you need to get those nice, crisp programmer fonts. It's what almost all new premium laptops with high-resolution screens are optimized for. It's what you'd want to run on a 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) or 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

But if you're not running a display with a PPI of 218 or above, you'll want to change the monitor settings. For example, if you have a 27" or 32" 4K, you can use fractional scaling by opening `~/.config/hypr/monitors.lua` (via _Setup > Monitors_ in the Omarchy menu) and switching to the recommendation for that combo:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

If you're using a 1080p or 1440p display, you'll probably just want to use 1x scaling, so you can use:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Changes to `GDK_SCALE` apply to applications started after the change (and GTK only honors whole numbers, so keep it at the nearest integer of your monitor scale). So make sure you quit the windows that you have that are oversized after the change (or close all windows with `Ctrl + Alt + Del`!).

You can also quickly step through the major monitor scaling ratios (1x, 1.25x, 1.6x, 2x, 3x, 4x) using `Super + /` to go higher and `Super + Alt + /` to go lower. If you have the default configuration, these changes will also persist past reboot.

### Making text bigger or smaller

Monitor scaling changes the size of everything. If all you want is bigger or smaller _text_, there's a single knob for that:

```
omarchy display text size 14
```

That takes a pixel size between 9 and 20, and moves the Omarchy shell, GTK applications, and your terminal together, so the whole desktop stays in proportion. Run it without an argument to see where you're at, and `omarchy display text size reset` to go back to the default. Foot is the one straggler: it has no way to reload its config, so running terminals keep their old size until you open a new one.

### Extending and mirroring laptop displays

When you connect an external screen to your laptop, the display is automatically extended. But you can change that to mirroring instead using _Trigger > Hardware_ in the Omarchy menu or `Super + Ctrl + Alt + Delete`. This is especially helpful if that external screen is a projector, and you want to show something while working.

When you're extending, closing the lid on the laptop will automatically turn off the internal screen. Opening the lid will turn it back on. You can also control this manually using _Trigger > Hardware_ in the Omarchy menu or `Super + Ctrl + Delete`.

### Arranging multiple screens

Open the **Display** panel from the monitor icon in the bar or with `Super + Ctrl + D`. With at least two enabled screens, a collapsed **Arrangement** row appears below **DISPLAYS**. Click the row or its right-hand chevron to open the controls; click again to close them. The row is hidden with only one enabled screen.

Drag the numbered screens in the diagram to match the monitors on your desk. Nearby edges and top, center or bottom alignment snap into place, with a guide showing the shared edge. You can also use offsets between those alignments. Screens cannot overlap. Every screen must share an edge with the layout before Apply is available. You can move several screens in the draft to close existing gaps. Select and move another screen to build the whole arrangement before applying. **Discard changes** returns the diagram to the current layout without moving your screens. **Refresh** rereads the connected screens.

**Identify screens** shows the matching number, display name and connector on each physical screen for four seconds. Clicking again restarts the timer. Identification does not change the layout.

Click **Apply layout** to apply and save the arrangement immediately. No second confirmation is needed, and the saved layout stays in place when you close the panel. If applying fails, the previous configuration and live layout are restored.

Open **Position controls** for preset placements. Choose the screen to move and its reference screen, then choose **Left**, **Right**, **Above** or **Below**. For left/right placement, **Align screens** offers **Top**, **Center** or **Bottom**. For above/below placement, it offers **Left**, **Center** or **Right**. Defaults are top and left alignment. You can also enter exact logical **X** and **Y** coordinates for the selected screen. These edit the preview; they do not move physical screens until Apply. To make precise adjustments with the keyboard, navigate to the diagram and press Enter. Arrow keys move the selected screen one logical pixel; Enter or Escape finishes editing. Changes remain a preview until Apply.

Arrangement supports multiple external screens and desktops without a laptop screen. Scaling and rotation are accounted for. If the screens change before Apply, refresh and arrange them again.

You can also arrange screens from the terminal:

```bash
omarchy hyprland monitor position DP-1 eDP-1 left --align bottom
omarchy hyprland monitor position DP-2 DP-1 above --align right --dry-run
```

The command saves positions in `~/.config/hypr/monitors.lua`, preserving the other fields in your monitor rules, and keeps a backup at `monitors.lua.bak.monitor-position`. Screens using a fallback or description rule get explicit connector rules with the same options. These rules take precedence over the fallback afterward, so edit their scale fields individually if needed. Mirrored screens, overlapping layouts and disconnected layouts are rejected. Turn mirroring off first, or move an obstructing screen before moving another into its place. If applying the layout fails, the previous configuration is restored. Saving and recovery detect concurrent config edits and retain conflicting file versions beside `monitors.lua` instead of discarding them. The error gives their paths. Monitor rules built through helpers or conditional Lua code must be arranged manually. Fallback and description rules with computed option expressions need explicit connector rules before using this command.

Hyprland works great with multiple screens. Read more about how to lay them out in [the Hyprland monitor documentation](https://wiki.hypr.land/Configuring/Basics/Monitors/). You can [bind specific workspaces to specific monitors](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) as well. In Omarchy, these rules go in `~/.config/hypr/monitors.lua` as `hl.monitor` entries — the file ships with commented examples for pinning a specific monitor to a resolution, position, and rotation.

You can also checkout [Hyprmon](https://github.com/erans/hyprmon/), if you'd like a TUI to help you with the positioning of multiple screens.

### Controlling brightness

Monitor brightness is controlled by the dedicated function keys for brightness up/down. If you hold down shift while pressing these, you'll go to maximum or minimum brightness. The keys control the display you're focused on, so external monitors that speak DDC/CI are adjusted the same way as the laptop screen.

### Apple Displays

If you're using an Apple display, the regular keyboard brightness keys will also automatically work, if you're focused on the Apple display. This is done through the `asdcontrol` command.

Note that if you're using an Apple 6K XDR display, you may see a phantom screen in your `hyprctl monitors` listing. You can turn this off with something like `hl.monitor({ output = "DP-2", disabled = true })` via _Setup > Monitors_.

On Intel machines, you should be connecting to Apple displays using a regular Thunderbolt cable. On other machines without Thunderbolt, you'll typically have to use a [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) to make it work.
