# Hyprland Configuration

Read this before changing keybindings, monitors, window rules, or any other
Hyprland (window manager) configuration.

Omarchy configures Hyprland in Lua. User files are loaded after Omarchy's
defaults, so overrides go here:

```
~/.config/hypr/
├── hyprland.lua       # Main config (loads Omarchy defaults, then user files)
├── bindings.lua       # Keybindings
├── monitors.lua       # Display configuration
├── input.lua          # Keyboard/mouse settings
├── looknfeel.lua      # Appearance (gaps, borders, animations)
├── autostart.lua      # Startup applications
├── hyprsunset.conf    # Night light / blue light filter
└── xdph.conf          # Screen sharing / desktop portal
```

**Key behaviors (the `.lua` files):**
- Hyprland auto-reloads on config save (no restart needed for most changes)
- Use `hyprctl reload` to force reload
- After ANY Hyprland Lua config change, validate with `hyprctl reload` followed by `hyprctl configerrors`
- If `hyprctl configerrors` reports errors, address them and rerun validation until clean or until a real blocker is identified
- Use `omarchy refresh hyprland` to reset the Lua config files to defaults

The two `.conf` files are read by separate processes, so `hyprctl` neither
applies nor validates them:
- `hyprsunset.conf` (night light): apply changes with `omarchy restart hyprsunset`; reset with `omarchy refresh hyprsunset`
- `xdph.conf` (screen-sharing portal): applies when the portal restarts, e.g. on next login

## Keybindings

Edit `~/.config/hypr/bindings.lua`. Format:
```lua
o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")
o.bind("SUPER + B", "Browser", { launch = "chromium" })  -- launch wraps with uwsm-app
o.bind("SUPER + M", "Theme menu", { menu = "theme" })     -- toggle an Omarchy menu route
o.bind("SUPER + N", "Network", { panel = "omarchy.network" })  -- toggle a shell panel
```

Prefer `{ menu = ... }` and `{ panel = ... }` over running `omarchy-menu toggle ...` or `omarchy-shell shell toggle ...` as a command. Routes and panels listed in `$OMARCHY_PATH/default/omarchy/shortcuts` go straight to the running shell as Hyprland global shortcuts, with no process started on each press; any other route or panel still works, through the command.

View current bindings: `omarchy menu keybindings --print`

**IMPORTANT: When re-binding an existing key:**

1. First check existing bindings: `omarchy menu keybindings --print`
2. If the key is already bound, use `o.rebind(...)` to remove the existing binding and add its replacement. It takes the same arguments as `o.bind(...)`.
3. Inform the user what the key was previously bound to

Example - rebinding SUPER+F (which is bound to fullscreen by default):
```lua
-- Replace SUPER+F (was: fullscreen) with the file manager.
o.rebind("SUPER + F", "File manager", { launch = "nautilus" })
```

Tell the user which action was replaced. Use `hl.unbind(...)` to remove a binding without replacing it.

## Display/Monitors

Set a monitor's scale, resolution and position with the commands the monitor panel uses. They apply at once and save the choice for that physical monitor in `~/.local/state/omarchy/monitors/settings`, which wins over `monitors.lua`:
```bash
omarchy hyprland monitor scaling --monitor DP-1 1.6
omarchy hyprland monitor resolution --monitor DP-1 3840x2160
omarchy-hyprland-monitor-layout eDP-1=0x0 DP-1=1280x0   # logical pixels, after scale
```

Edit `~/.config/hypr/monitors.lua` only for what those don't cover: rotation (`transform`), a mode the monitor panel doesn't offer, keeping a monitor off (`disabled = true`), 10-bit color, variable refresh rate, the default scale for monitors without a choice, or `GDK_SCALE`. The file ships with commented examples. Format:
```lua
hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
```

List monitors and supported modes: `hyprctl monitors all`

## Window Rules

**CRITICAL: Hyprland window rules syntax changes frequently between versions.**

Before writing ANY window rules, you MUST fetch the current documentation from the official Hyprland wiki:
- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

DO NOT rely on cached or memorized window rule syntax. The format has changed multiple times and using outdated syntax will cause errors or unexpected behavior.

Window rules go in `~/.config/hypr/hyprland.lua` or a required Lua module. Prefer Omarchy's `o.window(match, rules)` helper — see examples in `$OMARCHY_PATH/default/hypr/windows.lua`.
