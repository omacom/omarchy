---
name: omarchy
description: >
  REQUIRED for end-user customization of Linux desktop, window manager, or system config.
  Use when editing any user config under ~/.config/ — notably hypr/, omarchy/,
  the terminals (alacritty/foot/kitty/ghostty), btop, fastfetch, lazygit, starship,
  git — or running a user-facing omarchy command. Triggers: Hyprland, window rules,
  keybindings, monitors, gaps, borders, blur, opacity, omarchy-shell, bar,
  widgets, plugins, hooks, terminal config, themes, backgrounds, fonts,
  notifications, audio/volume, brightness, default browser/terminal/editor,
  display text size, night light, idle, lock screen, screenshots, reminders,
  layer rules, workspace settings, display config. Excludes Omarchy source
  development (repo work, migrations, `omarchy dev ...` workflows).
---

# Omarchy Skill

Manage [Omarchy](https://omarchy.org/) Linux systems - a beautiful, fun, agentic Arch Linux distribution with Hyprland.

This skill is for end-user customization on installed systems. It also covers
routing problems upstream — bug reports and fix PRs — as described in
[`contributing.md`](contributing.md). Developing Omarchy itself is out of
scope — see Out of Scope below.

## When This Skill MUST Be Used

**ALWAYS invoke this skill for end-user requests involving ANY of these:**

- Editing ANY file in `~/.config/hypr/` (window rules, animations, keybindings, monitors, etc.)
- Editing `~/.config/omarchy/shell.json` (status bar layout, widgets)
- Editing terminal configs (alacritty, foot, kitty, ghostty)
- Editing ANY file in `~/.config/omarchy/`
- Window behavior, animations, opacity, blur, gaps, borders
- Layer rules, workspace settings, display/monitor configuration
- Themes, backgrounds, fonts, appearance changes
- User-facing `omarchy` commands (`omarchy theme ...`, `omarchy refresh ...`, `omarchy restart ...`, etc.)
- Screenshots, screen recording, reminders, night light, idle behavior, lock screen

**If you're about to edit a config file in ~/.config/ on this system, STOP and use this skill first.**

## Topic Guides

Deeper instructions for common areas live next to this file. Read the
matching guide before starting:

- [`hyprland.md`](hyprland.md) - keybindings, monitors, window rules, and other Hyprland config
- [`plugins.md`](plugins.md) - the Omarchy shell: bar layout, widgets, plugins, idle behavior
- [`theming.md`](theming.md) - themes, backgrounds, and fonts
- [`hooks.md`](hooks.md) - automation hooks that run on system events
- [`capture.md`](capture.md) - screenshots, screen recordings, OCR text capture, and file sharing
- [`contributing.md`](contributing.md) - reporting Omarchy bugs and submitting fixes upstream

## Critical Safety Rules

For privileged commands, follow the Privilege Escalation rules below: `sudo` when a terminal is available for the password prompt, `pkexec` when it is not. Do not wrap commands that already manage privilege elevation themselves.

**For end-user customization tasks, NEVER modify anything in `/usr/share/omarchy/`** - but READING is safe and encouraged.

This directory is owned by the omarchy package. Any local changes will be
overwritten on the next `omarchy update`.

```
/usr/share/omarchy/     # READ-ONLY - NEVER EDIT (reading is OK)
├── bin/                    # Command source (packaged binaries are on PATH)
├── config/                 # Default config templates
├── themes/                 # Stock themes
├── default/                # System defaults
├── shell/                  # Omarchy shell source and defaults
├── migrations/             # Update migrations
└── install/                # Installation scripts
```

**Reading `/usr/share/omarchy/` is SAFE and useful** - do it freely to:
- Understand how omarchy commands work: `omarchy theme set --help` or `cat $(which omarchy-theme-set)`
- See default configs before customizing: `cat "$OMARCHY_PATH/config/omarchy/shell.json"`
- Check stock theme files to copy for customization
- Reference default hyprland settings: `cat /usr/share/omarchy/default/hypr/*`

**Always use these safe locations instead:**
- `~/.config/` - User configuration (safe to edit)
- `~/.config/omarchy/themes/<custom-name>/` - Custom themes
- `~/.config/omarchy/hooks/` - Custom automation hooks

## Privilege Escalation

For an interactive script or command run in a visible terminal, use `sudo` for
privileged work. Omarchy may grant passwordless `sudo` access to particular
commands, and the terminal is the appropriate place to request a password
when one is needed.

Use `pkexec` only when the caller cannot interact with a terminal or cannot
enter a password there, such as a command launched by an agent or a graphical
background process. Do not replace `sudo` with `pkexec` merely because a
command changes system state.

## System Architecture

Omarchy is built on:

| Component | Purpose | Config Location |
|-----------|---------|-----------------|
| **Arch Linux** | Base OS | `/etc/`, `~/.config/` |
| **Hyprland** | Wayland compositor/WM | `~/.config/hypr/` |
| **Omarchy shell** | Status bar + notifications (Quickshell) | `~/.config/omarchy/shell.json` |
| **Launcher/menus** | Quickshell menu | `~/.config/omarchy/extensions/omarchy-menu.jsonc` |
| **Alacritty/Foot/Kitty/Ghostty** | Terminals | `~/.config/<terminal>/` |
| **Omarchy OSD** | On-screen display | Quickshell plugin |

## Command Discovery

Omarchy ships a single `omarchy` CLI that dispatches to all `omarchy-*` binaries via `omarchy <group> <action>`. Always prefer this form — it is self-documenting and stable. The underlying `omarchy-*` binaries still exist on `PATH` and remain safe to read for source.

```bash
# List every documented command and its summary (--all includes hidden commands)
omarchy commands

# Show the commands inside a group
omarchy theme --help
omarchy refresh --help
omarchy restart --help

# Show help for a specific command (does not execute it)
omarchy theme set --help

# Machine-readable listing (binary, route, summary, args, aliases)
omarchy commands --json

# Read a command's source to understand it
cat $(which omarchy-theme-set)
```

### Command Groups

Run `omarchy commands` for the full list. The most common groups:

| Group | Purpose | Example |
|-------|---------|---------|
| `omarchy refresh` | Reset config to defaults (backs up first) | `omarchy refresh shell` |
| `omarchy restart` | Restart a service/app | `omarchy restart shell` |
| `omarchy hyprland` | Compositor one-offs: monitors, gaps, transparency, workspaces | `omarchy hyprland window gaps toggle` |
| `omarchy toggle` | Toggle feature on/off | `omarchy toggle nightlight` |
| `omarchy theme` | Theme management | `omarchy theme set <name>` |
| `omarchy bar` | Bar layout and widgets | `omarchy bar move omarchy.clock --section right` |
| `omarchy plugin` | Manage/clone shell plugins | `omarchy plugin clone omarchy.clock` |
| `omarchy hook` | Install automation hooks | `omarchy hook install theme-set <script>` |
| `omarchy install` | Install optional software / packages | `omarchy install docker dbs` |
| `omarchy launch` | Launch apps | `omarchy launch browser` |
| `omarchy capture` | Screenshots and recordings | `omarchy capture screenshot` |
| `omarchy notification` | Send desktop notifications | `omarchy notification send "Build done"` |
| `omarchy audio` | Volume, mute, audio outputs/inputs | `omarchy audio output volume raise` |
| `omarchy brightness` | Display and keyboard backlight | `omarchy brightness display +10%` |
| `omarchy display` | Global text size (shell, GTK, terminals) | `omarchy display text size 16` |
| `omarchy default` | Default browser/terminal/editor/agent | `omarchy default browser chromium` |
| `omarchy reminder` | Desktop notification reminders | `omarchy reminder 15 "Pickup Jack"` |
| `omarchy pkg` | Package management | `omarchy pkg add <pkg>` |
| `omarchy setup` | Interactive setup wizards | `omarchy setup security fingerprint` |
| `omarchy update` | System updates | `omarchy update` |

Also available: `bluetooth`,
`weather`, `powerprofiles`, `drive`, `games`, `voxtype` (dictation),
`plymouth` (boot screen), `snapshot` (snapper backups), `dns`, `channel`,
`osd`, `branding`, `remove` (undo an `install`), `mise`, `hibernation`,
`share`, `transcode`, and `hw` (per-model hardware quirks).

## Configuration Locations

Hyprland config lives in `~/.config/hypr/` — see [`hyprland.md`](hyprland.md).
The Omarchy shell (bar, notifications, plugins, idle) is configured in
`~/.config/omarchy/shell.json` — see [`plugins.md`](plugins.md).

### Terminals

```
~/.config/alacritty/alacritty.toml
~/.config/foot/foot.ini
~/.config/kitty/kitty.conf
~/.config/ghostty/config
```

**Command:** `omarchy restart terminal`

### Other Configs

| App | Location |
|-----|----------|
| btop | `~/.config/btop/btop.conf` |
| fastfetch | `/etc/fastfetch/config.jsonc` default; `~/.config/fastfetch/config.jsonc` user override |
| lazygit | `~/.config/lazygit/config.yml` |
| starship | `~/.config/starship.toml` |
| git | `~/.config/git/config` |

## Safe Customization Patterns

### Edit User Config Directly

For simple changes, edit files in `~/.config/`:

```bash
# 1. Read current config
cat ~/.config/hypr/bindings.lua

# 2. Backup before changes
cp ~/.config/hypr/bindings.lua ~/.config/hypr/bindings.lua.bak.$(date +%s)

# 3. Make changes with Edit tool

# 4. Apply changes
# - Hyprland: auto-reloads on save, but MUST validate with `hyprctl reload` and `hyprctl configerrors`
# - Omarchy shell: shell.json and user plugin code under ~/.config/omarchy/plugins/ hot-reload on save
# - Menus/launcher: ~/.config/omarchy/extensions/omarchy-menu.jsonc hot-reloads on save
# - Terminals: apply with `omarchy restart terminal` (reloads running terminals; foot picks changes up in new windows)
```

### Reset to Defaults -- ALWAYS SEEK USER CONFIRMATION BEFORE RUNNING

When customizations go wrong:

```bash
# Reset specific config (creates backup automatically)
omarchy refresh shell
omarchy refresh hyprland

# The refresh command:
# 1. Backs up current config with timestamp
# 2. Copies default from $OMARCHY_PATH/config/
# 3. Restarts the component where the refresh needs it (e.g. `refresh shell`)
```

## System Commands

```bash
omarchy update                  # Full system update
omarchy version                 # Show Omarchy version
omarchy-debug --no-sudo --print # Debug info
omarchy system lock             # Lock screen
omarchy system shutdown         # Shutdown
omarchy system reboot           # Reboot
```

**IMPORTANT:** Always pass `--no-sudo --print` to avoid interactive sudo
prompts that will hang the terminal. Call the `omarchy-debug` binary directly —
it works in every context. The `omarchy debug` route advertised by
`omarchy --help` can fail with `Unknown Omarchy command`: the dispatcher only
finds commands in the directory it was run from, and `omarchy-debug` ships to
`/usr/bin` in a separate package, so it is missing when the dispatcher runs as
`/usr/share/omarchy/bin/omarchy`.

## Troubleshooting

```bash
# Get debug information (see the flag note under System Commands)
omarchy-debug --no-sudo --print

# Reset specific config to defaults
omarchy refresh <app>

# Refresh specific config file
# config-file path is relative to ~/.config/
# eg. `omarchy refresh config hypr/hyprland.lua` will refresh ~/.config/hypr/hyprland.lua
omarchy refresh config <config-file>

# Full reinstall of configs (nuclear option)
omarchy reinstall
```

## Decision Framework

When user requests system changes:

1. **Is it a stock omarchy command?** Use it directly
2. **Is it a config edit?** Edit in `~/.config/`
3. **Is it a theme customization?** Follow [`theming.md`](theming.md); create a NEW custom theme directory
4. **Is it automation?** Follow [`hooks.md`](hooks.md); use `omarchy hook install` and the hook `.d` directories
5. **Is it a package install?** Use `omarchy pkg add <pkgs...>` (or `omarchy pkg aur add <pkgs...>` for AUR-only packages)
6. **Is it built-in shell/plugin code?** Follow [`plugins.md`](plugins.md); clone it with `omarchy plugin clone`, never edit the packaged copy
7. **Unsure if command exists?** Run `omarchy commands` (or `omarchy <group> --help` for one group)

### Reminder Requests

When the user asks to set a reminder, use `omarchy reminder <minutes> [message]` directly. Convert natural language durations to minutes and title-case short reminder labels when appropriate.

```bash
omarchy reminder 15 "Pickup Jack"
omarchy reminder 60 "Check laundry"
omarchy reminder show
omarchy reminder clear
```

## Out of Scope

Developing Omarchy itself: editing the Omarchy source tree, creating or editing
migrations, and running `omarchy dev ...` commands — the repository's own
`AGENTS.md` governs that work. Reporting bugs and submitting a ready fix are
in scope — see [`contributing.md`](contributing.md).

## Example Requests

- "Change my theme to catppuccin" -> `omarchy theme set catppuccin`
- "Add a keybinding for Super+E to open file manager" -> Check existing bindings first, then use `o.rebind` to replace one or `o.bind` to add one in `~/.config/hypr/bindings.lua`
- "Configure my external monitor" -> Edit `~/.config/hypr/monitors.lua`
- "Make the window gaps smaller" -> Edit `~/.config/hypr/looknfeel.lua`
- "Turn on night light" -> `omarchy toggle nightlight` blind-toggles — check `omarchy toggle nightlight --status` first (for time-based schedules, edit `~/.config/hypr/hyprsunset.conf` profiles, then `omarchy restart hyprsunset`)
- "Customize the catppuccin theme colors" -> Overlay: put an edited `colors.toml` in `~/.config/omarchy/themes/catppuccin/`, then re-apply the theme (see `theming.md`)
- "Run a script every time I change themes" -> Install it with `omarchy hook install theme-set <script>`
- "Change how workspace labels are rendered" -> Clone `omarchy.workspaces`, which switches the bar to `<username>.workspaces`, then edit the clone
- "Reset shell/bar to defaults" -> `omarchy refresh shell`
- "Record my screen" -> `omarchy screenrecord --fullscreen`, then `omarchy screenrecord --stop-recording` (see `capture.md`)
- "Report this bug to Omarchy" -> Gather diagnostics and a capture of the problem, then file it (see `contributing.md`)
- "Set Firefox as my default browser" -> `omarchy default browser firefox`
- "Make text bigger everywhere" -> `omarchy display text size 16` (`omarchy display text size reset` restores 12px/1.0/9pt defaults)
- "Send a desktop notification" -> `omarchy notification send "Headline" "Details"`
- "Turn the volume down" -> `omarchy audio output volume lower` (or `+N`/`-N`, `mute-toggle`)
