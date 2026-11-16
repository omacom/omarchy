# Monitors

Omarchy assumes you're running on a 2x-capable retina-class display by default. This is what you need to get those nice, crisp programmer fonts. It's what almost all new premium laptops with high-resolution screens are optimized for. It's what you'd want to run on a 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) or 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

But if you're not running a display with a PPI of 218 or above, you'll want to change the monitor settings. For example, if you have a 27" or 32" 4K, you can pick a fractional scale for it from the monitor panel in the top bar, or set the default for every monitor by opening `~/.config/hypr/monitors.lua` and switching to the recommendation for that combo:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

If you're using a 1080p or 1440p display, you'll probably just want to use 1x scaling, and the same for GTK and X11 apps, so you can use:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Changes to `GDK_SCALE` apply to applications started after the change (and GTK only honors whole numbers, so keep it at the nearest integer of your monitor scale). So make sure you quit the windows that you have that are oversized after the change (or close all windows with `Ctrl + Alt + Del`!).

You can also quickly step through the major monitor scaling ratios (1x, 1.25x, 1.6x, 2x, 3x, 4x) using `Super + /` to go higher and `Super + Alt + /` to go lower, or pick one from the monitor panel in the top bar. These change only the monitor you're focused on, so a laptop screen and an external display can each have their own scale. The panel also sets each monitor's resolution, refresh rate and rotation. Your choices are saved for that physical monitor in `~/.local/state/omarchy/monitors/settings`, so they persist past reboot and follow the monitor to whichever port or dock it's plugged into next. They take precedence over any rule for the same monitor in `~/.config/hypr/monitors.lua`, which Omarchy never edits. If you'd rather set your monitors entirely in that file, add `omarchy_monitor_panel_settings = false` to it, and the panel's changes will last only until Hyprland reloads. Since `GDK_SCALE` is one value for all screens, a chosen scale sets it from the monitor with the lowest scale, so X11 apps come out a little small on the denser screen rather than oversized on the other.

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

Hyprland works great with multiple screens. The monitor panel in the top bar draws them where they sit: drag one against the side of another to move it there, and the arrangement is saved with each monitor's other settings. For anything the panel doesn't cover, read more about how to lay them out in [the Hyprland monitor documentation](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy, these go in `~/.config/hypr/monitors.lua` as `hl.monitor` entries — the file ships with commented examples for keeping a monitor off, modes the panel doesn't offer, 10-bit color, and variable refresh rate.

Every monitor has workspaces 1 through 10 of its own, so `Super + 1` always means the first workspace of the monitor you're on. Behind the scenes, Hyprland still numbers workspaces across all monitors: your laptop screen (or first monitor) gets 1–10, the next monitor 11–20, and so on, and each monitor keeps its block every time you plug it in. Use those numbers if you write [workspace rules](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) or window rules for a specific monitor, so workspace 12 is the second workspace of your second monitor. `~/.local/state/omarchy/monitors/workspaces` lists which block each monitor has.

The arrow keys work across monitors that share an edge in your layout. Screens that only touch at a corner, or that have a gap between them, aren't neighbors, so use `Ctrl + Alt + Tab` to get between them.

| Hotkey | Across monitors |
| --- | --- |
| `Super + Arrow` | Moves focus to the monitor on that side once there's no window left in that direction |
| `Super + Shift + Arrow` | Swaps with a window on the monitor on that side |
| `Super + Alt + Arrow` | Moves the window into a group on the monitor on that side |
| `Super + Shift + Ctrl + Arrow` | Moves the window to the monitor on that side, onto the workspace it's showing |
| `Super + Shift + Alt + Arrow` | Moves the workspace to the monitor on that side, keeping its number if it's free |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Moves focus to the next or previous monitor, whatever the layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Stay on the monitor you're on |

You can also checkout [Hyprmon](https://github.com/erans/hyprmon/), if you'd like a TUI to help you with the positioning of multiple screens.

### Controlling brightness

Monitor brightness is controlled by the dedicated function keys for brightness up/down. If you hold down shift while pressing these, you'll go to maximum or minimum brightness. The keys control the display you're focused on, so external monitors that speak DDC/CI are adjusted the same way as the laptop screen.

### Apple Displays

If you're using an Apple display, the regular keyboard brightness keys will also automatically work, if you're focused on the Apple display. This is done through the `asdcontrol` command.

Note that if you're using an Apple 6K XDR display, you may see a phantom screen in your `hyprctl monitors` listing. You can turn this off with something like `hl.monitor({ output = "DP-2", disabled = true })` in `~/.config/hypr/monitors.lua`.

On Intel machines, you should be connecting to Apple displays using a regular Thunderbolt cable. On other machines without Thunderbolt, you'll typically have to use a [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) to make it work.
