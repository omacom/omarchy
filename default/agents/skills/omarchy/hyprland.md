# Hyprland Configuration

Use this guide for keybindings, monitors, window rules, input, appearance,
night light, and screen-sharing portal configuration.

## User Configuration

Omarchy configures Hyprland in Lua. User files load after packaged defaults, so
put overrides under `~/.config/hypr/`:

```text
~/.config/hypr/
├── hyprland.lua       # Main config and additional modules
├── bindings.lua       # Keybindings
├── monitors.lua       # Displays
├── input.lua          # Keyboard and pointer input
├── looknfeel.lua      # Gaps, borders, and animations
├── autostart.lua      # Startup applications
├── hyprsunset.conf    # Night light
└── xdph.conf          # Screen sharing and desktop portal
```

Read matching defaults and helper examples under `$OMARCHY_PATH/default/hypr/`
before writing an override.

## Lua Change Loop

1. Edit the narrowest matching user Lua file.
2. Run `hyprctl reload`.
3. Run `hyprctl configerrors`.
4. Resolve every reported error and repeat the reload and error check.
5. Exercise the changed binding, monitor, rule, input, or visual behavior.

A Lua change is complete when `hyprctl configerrors` is empty and the requested
behavior has been observed. If the harness cannot observe the desktop, report
the visual or interactive check as unverified.

## Process-Owned `.conf` Files

Hyprland does not apply or validate these files:

- `hyprsunset.conf` — apply with `omarchy restart hyprsunset`; reset with `omarchy refresh hyprsunset`.
- `xdph.conf` — applies when the desktop portal restarts, normally at the next login.

A `.conf` change is complete when its owning process has restarted and the
night-light or screen-sharing behavior has been exercised.

## Keybindings

Inspect current bindings first:

```bash
omarchy menu keybindings --print
```

Write user bindings in `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")
o.bind("SUPER + B", "Browser", { launch = "chromium" })
o.bind("SUPER + M", "Theme menu", { menu = "theme" })
o.bind("SUPER + N", "Network", { panel = "omarchy.network" })
```

Prefer `{ menu = ... }` and `{ panel = ... }` over running `omarchy-menu toggle
...` or `omarchy-shell shell toggle ...` as a command. Routes and panels listed
in `$OMARCHY_PATH/default/omarchy/shortcuts` go straight to the running shell
as Hyprland global shortcuts; any other route or panel still works, through the
command.

When the key is already bound, use `o.rebind(...)`, which takes the same
arguments as `o.bind(...)`, and tell the user what the key previously did. Use
`hl.unbind(...)` only to remove a binding without replacing it:

```lua
o.rebind("SUPER + F", "File manager", { launch = "nautilus" }) -- Previously fullscreen
```

Keybinding work is complete when the old action no longer fires, the new action
does fire, and the user has been told about the replacement.

## Monitors

List connected outputs and supported modes before editing:

```bash
hyprctl monitors all
```

Write monitor overrides in `~/.config/hypr/monitors.lua`:

```lua
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144", position = "1920x0", scale = 1 })
```

Monitor work is complete when `hyprctl monitors all` reports the requested
mode, position, and scale for every affected output.

## Window Rules

Window-rule syntax changes frequently. Record the installed release with
`hyprctl version`, then use documentation or source matching that release.
Treat the current official documentation as authoritative only after confirming
that it covers the installed version:

<https://wiki.hypr.land/Configuring/Window-Rules/>

Prefer Omarchy's `o.window(match, rules)` helper and inspect current examples in
`$OMARCHY_PATH/default/hypr/windows.lua`. Put user rules in
`~/.config/hypr/hyprland.lua` or a Lua module it requires.

Window-rule work is complete when matching remains limited to the target window
and the Lua change loop is clean.

## Recovery

With user confirmation, reset the shipped user Lua files (`hyprland.lua`,
`bindings.lua`, `monitors.lua`, `input.lua`, `looknfeel.lua`, `autostart.lua`)
with the command below. Additional user modules are left untouched. It also
resets the toggle state in `~/.local/state/omarchy/toggles/hypr/flags.lua`,
without a backup.

```bash
omarchy refresh hyprland
```

Reset `hyprsunset.conf` separately with `omarchy refresh hyprsunset`. Confirm the
backups of files that differed, reload the owner, and repeat the relevant completion checks.
