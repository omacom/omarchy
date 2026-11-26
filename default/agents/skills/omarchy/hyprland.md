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

Edit `~/.config/hypr/bindings.lua`. The defaults it loads live in `$OMARCHY_PATH/default/hypr/bindings/*.lua` and are the best examples. Format:
```lua
o.bind("SUPER + SHIFT + R", "SSH", "xdg-terminal-exec -e ssh your-server")  -- a plain command; xdg-terminal-exec opens the default terminal
o.bind("SUPER + SHIFT + B", "Browser", { omarchy = "browser" })     -- runs omarchy-launch-browser (the default browser)
o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian" })    -- launch wraps with uwsm-app
o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })  -- focus the window if it's already open
o.bind("SUPER + SHIFT + E", "Email", { webapp = "https://app.hey.com" })  -- open a URL as a web app (add focus = true to reuse its window)
o.bind("SUPER + SHIFT + D", "Docker", { tui = "lazydocker" })       -- run a TUI in the default terminal (add focus = true to reuse its window)
o.bind("SUPER + M", "Theme menu", { menu = "theme" })              -- toggle an Omarchy menu route
o.bind("SUPER + N", "Network", { panel = "omarchy.network" })      -- toggle a shell panel
```

Launch the user's chosen defaults through `{ omarchy = "browser" }`, `{ omarchy = "editor" }` and `o.launch_terminal()` rather than naming an app, so the binding follows `omarchy default ...` (see [`apps.md`](apps.md)). `{ omarchy = "files" }` always opens Folio, whatever `inode/directory` is set to; to bind another file manager, name it with `{ launch = ... }`.

Prefer `{ menu = ... }` and `{ panel = ... }` over running `omarchy-menu toggle ...` or `omarchy-shell shell toggle ...` as a command. Routes and panels listed in `$OMARCHY_PATH/default/omarchy/shortcuts` go straight to the running shell as Hyprland global shortcuts, with no process started on each press; any other route or panel still works, through the command.

View current bindings: `omarchy menu keybindings --print`

**IMPORTANT: When re-binding an existing key:**

1. First check existing bindings: `omarchy menu keybindings --print`
2. If the key is already bound, use `o.rebind(...)` to remove the existing binding and add its replacement. It takes the same arguments as `o.bind(...)`.
3. Inform the user what the key was previously bound to

Example - rebinding SUPER+F (which is bound to fullscreen by default):
```lua
-- Replace SUPER+F (was: fullscreen) with the file manager.
o.rebind("SUPER + F", "File manager", { omarchy = "files" })
```

Tell the user which action was replaced. Use `hl.unbind(...)` to remove a binding without replacing it. The bindings for preinstalled apps (Obsidian, Signal, Spotify, the HEY and ChatGPT web apps, and so on) go away with `omarchy remove preinstalls`. To drop only those bindings, uncomment `omarchy_preinstalled_bindings = false` in `~/.config/hypr/hyprland.lua` (above the `require("default.hypr.omarchy")` line, or it's read too late); `omarchy_default_bindings = false` there drops every Omarchy binding.

## Look and Feel

Common appearance changes have commands, which save the choice so `looknfeel.lua` needn't be edited:

```bash
omarchy hyprland corners [theme|sharp|rounded]                 # Window corners
omarchy hyprland window transparency [opaque|transparent|glassy]
omarchy hyprland window gaps toggle                            # No gaps <-> default gaps
omarchy hyprland workspace layout default [dwindle|scrolling|floating]
omarchy toggle fullscreen-desktop                              # Hide the bar and remove gaps together
omarchy toggle animations                                      # Animations, blur and shadows off (slow GPUs)
```

For anything else (gap sizes, border width and colors, blur strength, animation curves), edit `~/.config/hypr/looknfeel.lua`.

## Keyboard, Mouse, and Touchpad

Keyboard layouts, repeat rate, mouse sensitivity, and touchpad behavior go in `~/.config/hypr/input.lua`; it ships with commented examples:

```lua
hl.config({
  input = {
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",  -- Left Alt + Right Alt switches layouts
    touchpad = { natural_scroll = true },
  },
})
```

- `omarchy setup keyboard` picks the layouts interactively, and `omarchy setup input [mozc|hangul|pinyin|chewing|cangjie5]` adds a Japanese, Korean or Chinese input method (fcitx5, configured in `~/.config/fcitx5/`).
- Compose sequences go in `~/.XCompose`; apply with `omarchy restart xcompose`.
- `omarchy device keyboard toprow [mediakeys|fnkeys]` picks what the top row sends; `omarchy device touchpad|touchscreen [on|off|toggle]` turns those off.
- To drop Omarchy's touchpad gestures, uncomment `omarchy_default_gestures = false` in `~/.config/hypr/hyprland.lua`, above the line that loads Omarchy's defaults.

## Display/Monitors

Set a monitor's scale, resolution and position with the commands the monitor panel uses. They apply at once and save the choice for that physical monitor in `~/.local/state/omarchy/monitors/settings`, which wins over `monitors.lua`:
```bash
omarchy hyprland monitor scaling --monitor DP-1 1.6
omarchy hyprland monitor resolution --monitor DP-1 3840x2160@60
omarchy hyprland monitor rotate --monitor DP-1 90
omarchy-hyprland-monitor-layout eDP-1=0x0 DP-1=1280x0   # logical pixels, after scale
omarchy hyprland monitor internal [on|off|toggle]      # The laptop's own display
omarchy hyprland monitor internal mirror [on|off|toggle]  # Mirror it to every external monitor
omarchy display text size [9-20|reset]                 # Scale text in the shell, GTK apps and terminals together
```

Edit `~/.config/hypr/monitors.lua` only for what those don't cover: a mode the monitor panel doesn't offer (it already sets resolution, refresh rate and rotation), keeping a monitor off (`disabled = true`), 10-bit color, variable refresh rate, the default scale for monitors without a choice, or `GDK_SCALE`. The file ships with commented examples. If the user wants that file alone to set their monitors, overriding the monitor panel, add `omarchy_monitor_panel_settings = false` to it. Format:
```lua
hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "auto", scale = 1.5 })
```

List monitors and supported modes: `hyprctl monitors all`

## Window Rules

**CRITICAL: Hyprland window rules syntax changes frequently between versions.**

Before writing ANY window rules, you MUST fetch the current documentation from the official Hyprland wiki:
- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

DO NOT rely on cached or memorized window rule syntax. The format has changed multiple times and using outdated syntax will cause errors or unexpected behavior.

Window rules go in `~/.config/hypr/hyprland.lua` or a required Lua module. Prefer Omarchy's `o.window(match, rules)` helper — see examples in `$OMARCHY_PATH/default/hypr/windows.lua`.
