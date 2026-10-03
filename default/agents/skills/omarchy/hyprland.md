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

## One-Off Changes: the `omarchy hyprland` Group

Check this group before editing a Lua file — several common requests are already
commands. Full list: `omarchy hyprland --help`.

```bash
omarchy hyprland monitor scaling [up|down|SCALE]      # Show, set, or adjust focused monitor scale
omarchy hyprland monitor internal <on|off|toggle|recover>
omarchy hyprland monitor internal mirror <on|off|toggle|recover>
omarchy hyprland window gaps toggle                   # No gaps / default gaps
omarchy hyprland window transparency toggle
omarchy hyprland workspace layout toggle              # dwindle <-> scrolling
omarchy hyprland window pop [width height x y]        # Pop a tile out to a fixed position
omarchy hyprland window close all
omarchy hyprland focus app <app-name>
omarchy hyprland toggle <flag-name> [on|off|toggle]   # Persistent Hyprland flags
```

These change state now. Anything that should survive a reboot or an update still
belongs in the Lua files below.

## Lua API

Two namespaces are available in these files. Read the right source rather than
guessing an API that isn't there.

**`o.*` — Omarchy's helpers**, defined in `$OMARCHY_PATH/default/hypr/helpers.lua`
and loaded for you by `require("default.hypr.helpers")`:

```lua
o.bind(keys, description, dispatcher, options)
o.bind_toggle(keys, description, toggle, options)  -- runs omarchy-toggle-<toggle>
o.launch(command)                                 -- returns "uwsm-app -- <command>"
o.launch_sole(match, command)                     -- launch-or-focus
o.launch_webapp(url) / o.launch_webapp_sole(name, url)
o.notify(message)                                 -- omarchy-notification-send -u low
o.window(match, rules)                            -- window rules, see below
o.exec_on_start(command)                          -- run a shell command at Hyprland start
o.launch_on_start(command)                        -- exec_on_start(o.launch(command)); for autostart.lua
```

`o.bind`'s third argument is a command string, a Lua function callback (the
stock bindings use callbacks — they run directly in the config), or a table
taking one of
`launch`, `focus` + `launch`, `webapp` (+ `focus`), `tui` (+ `focus`), `omarchy`.
Anything else is passed through to `hl.bind` untouched.

**`hl.*` — Hyprland's own Lua config API**, not Omarchy's. Documented upstream:

- Lua utilities: https://wiki.hypr.land/configuring/core/advanced-configuration/lua-utilities
- Keybinds: https://wiki.hypr.land/Configuring/Basics/Binds

Stock Omarchy configs use `hl.bind`, `hl.unbind`, `hl.dsp` / `hl.dispatch`,
`hl.monitor`, `hl.window_rule`, `hl.layer_rule`, `hl.env`, `hl.on`, `hl.timer`,
`hl.config`, `hl.curve`, `hl.gesture`.

Bind callbacks run on the compositor event loop and must not block: no
`io.popen`, sleeps, network or clipboard tools inside one. Hand `o.bind` a
command string instead and let it run as a dispatcher.

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

Edit `~/.config/hypr/monitors.lua`. Format:
```lua
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144", position = "1920x0", scale = 1 })
```

List monitors and supported modes: `hyprctl monitors all`

## Window Rules

**CRITICAL: Hyprland window rules syntax changes frequently between versions.**

Before writing ANY window rules, you MUST fetch the current documentation from the official Hyprland wiki:
- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

DO NOT rely on cached or memorized window rule syntax. The format has changed multiple times and using outdated syntax will cause errors or unexpected behavior.

Window rules go in `~/.config/hypr/hyprland.lua` or a required Lua module. Prefer Omarchy's `o.window(match, rules)` helper — see examples in `$OMARCHY_PATH/default/hypr/windows.lua`.
