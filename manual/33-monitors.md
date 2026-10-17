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

You can also quickly step through the major monitor scaling ratios (1x, 1.25x, 1.6x, 2x, 3x, 4x) using `Super + /` to go higher and `Super + Alt + /` to go lower. If you have the default configuration, these changes will also persist past reboot. With separate workspaces on, the saved scale belongs to the screen you are using, as described below.

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

Hyprland works great with multiple screens. Read more about how to lay them out in [the Hyprland monitor documentation](https://wiki.hypr.land/Configuring/Basics/Monitors/). You can [bind specific workspaces to specific monitors](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) as well. In Omarchy, these rules go in `~/.config/hypr/monitors.lua` as `hl.monitor` entries — the file ships with commented examples for pinning a specific monitor to a resolution, position, and rotation.

You can also checkout [Hyprmon](https://github.com/erans/hyprmon/), if you'd like a TUI to help you with the positioning of multiple screens.

Workspace numbers are shared across monitors by default, so `Super + 1` always means the same workspace and switching to it brings you to whichever screen that workspace is on. Turn on separate workspaces from _Trigger > Appearance > Separate Workspaces_, or with `omarchy toggle monitor-workspaces`, and each monitor keeps its own workspaces 1–10. `Super + number`, `Super + Tab`, and `Super + scroll` then stay on the monitor you are using. The laptop screen keeps the familiar numbers. A second screen still shows 1–10, stored internally as 11–20, and the numbers stick to that screen's description when you unplug it and plug it back in.

Separate workspaces also keep each screen's scale. The Display panel and `Super + /` change the focused screen and save that size for it, so the built-in display can stay at 2 while a second screen stays at 1.6. A size that would not divide that screen into whole pixels is raised to the next size that does, so 1.5 on a 2560×1440 monitor becomes 1.6. Text size stays one setting for the whole desktop. Turning separate workspaces off removes the per-screen sizes it saved, and every screen follows the shared scale again.

Turning separate workspaces off stops the per-monitor keys and the per-monitor numbering in the bar. It does not move windows back to the shared numbers, so a window that lived on workspace 6 of the second screen is still on internal workspace 16 until you turn separate workspaces on again or move the window yourself. `Super + Shift + Alt + arrows` still tries to send a whole workspace to another monitor, and the pin that keeps each number on its screen will fight that.

### Controlling brightness

Monitor brightness is controlled by the dedicated function keys for brightness up/down. If you hold down shift while pressing these, you'll go to maximum or minimum brightness. The keys control the display you're focused on, so external monitors that speak DDC/CI are adjusted the same way as the laptop screen.

### Apple Displays

If you're using an Apple display, the regular keyboard brightness keys will also automatically work, if you're focused on the Apple display. This is done through the `asdcontrol` command.

Note that if you're using an Apple 6K XDR display, you may see a phantom screen in your `hyprctl monitors` listing. You can turn this off with something like `hl.monitor({ output = "DP-2", disabled = true })` via _Setup > Monitors_.

On Intel machines, you should be connecting to Apple displays using a regular Thunderbolt cable. On other machines without Thunderbolt, you'll typically have to use a [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) to make it work.
