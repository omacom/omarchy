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

You can also quickly step through the major monitor scaling ratios (1x, 1.25x, 1.6x, 2x, 3x, 4x) using `Super + /` to go higher and `Super + Alt + /` to go lower. These changes save per-display rules in `monitors.lua` and persist past reboot. Global GTK scaling stays unchanged; edit `omarchy_gdk_scale` separately when needed.

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

Open the display popup in the top bar and choose the settings icon at the top right (its tooltip reads **Advanced settings**) to open the settings popup. Its tabs cover arrangement, display modes, and workspace assignments.

- **Arrangement:** drag screens; nearby edges snap together. Enter precise X/Y positions or place a screen left, right, above, or below another.
- **Displays:** select a screen, resolution, supported refresh rate, and orientation.
- **Workspaces:** review each monitor's assigned workspaces and choose one monitor per numbered workspace. Moving an assigned workspace requires confirmation; canceling leaves its owner unchanged. Add extra workspace numbers from 1 to 99 without duplicate rows.

Choose **Preview** to try the layout. Choose **Keep changes** within 20 seconds to save it, or **Revert** to restore the previous layout. The confirmation popup stays open when the bar popup closes or a screen moves. If you close the popup or the shell restarts, an unconfirmed preview still reverts automatically. Reopening the popup during a preview restores its confirmation controls. Saved monitor and workspace rules live in a marked block at the end of `~/.config/hypr/monitors.lua`; existing personal settings remain outside that block. The editor arranges enabled, extended displays; enable screens or turn off mirroring before arranging them.

Changing scale, resolution, or orientation preserves the nearest neighboring displays' gaps and edge alignment. The laptop display stays fixed when present; otherwise, the display closest to the coordinate origin is the anchor. If a resize cannot preserve all touching edges without overlap, adjust **Arrangement** first. Scaling saves explicit per-display rules and leaves global GTK scaling defaults untouched. Saved rules for unplugged displays are retained. Text size changes do not move displays.

Hyprland works great with multiple screens. Read more about how to lay them out in [the Hyprland monitor documentation](https://wiki.hypr.land/Configuring/Basics/Monitors/). You can [bind specific workspaces to specific monitors](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) as well. In Omarchy, these rules go in `~/.config/hypr/monitors.lua` as `hl.monitor` entries — the file ships with commented examples for pinning a specific monitor to a resolution, position, and rotation.

You can also checkout [Hyprmon](https://github.com/erans/hyprmon/), if you'd like a TUI to help you with the positioning of multiple screens.

### Controlling brightness

Monitor brightness is controlled by the dedicated function keys for brightness up/down. If you hold down shift while pressing these, you'll go to maximum or minimum brightness. The keys control the display you're focused on, so external monitors that speak DDC/CI are adjusted the same way as the laptop screen.

### Apple Displays

If you're using an Apple display, the regular keyboard brightness keys will also automatically work, if you're focused on the Apple display. This is done through the `asdcontrol` command.

Note that if you're using an Apple 6K XDR display, you may see a phantom screen in your `hyprctl monitors` listing. You can turn this off with something like `hl.monitor({ output = "DP-2", disabled = true })` via _Setup > Monitors_.

On Intel machines, you should be connecting to Apple displays using a regular Thunderbolt cable. On other machines without Thunderbolt, you'll typically have to use a [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) to make it work.
