---
name: omarchy
description: >
  REQUIRED for end-user customization of an Omarchy desktop, and when editing ANY file in ~/.config/
  (hypr, omarchy, alacritty, foot, kitty, ghostty). Triggers: Hyprland, keybindings, monitors, window
  rules, gaps, borders, blur, opacity, animations, workspaces, the bar, dock and widgets, themes, fonts,
  backgrounds, terminal config, default apps (browser, terminal, editor), web apps, installing software,
  environment variables, keyboard layouts, language, power profiles, night light, idle, lock screen,
  screenshots, screen recording, reminders, and user-facing omarchy commands. Not for Omarchy source
  development (`omarchy dev link`). Making a new theme, shell plugin, app, or game follows
  omarchy-make-theme, omarchy-make-plugin, omarchy-make-app, or omarchy-make-game instead, and
  reporting a bug or contributing upstream follows omarchy-contribute.
---

# Omarchy Skill

Manage [Omarchy](https://omarchy.org/) Linux systems - a beautiful, fun, agentic Arch Linux distribution with Hyprland.

This skill is for end-user customization on installed systems.
It is not for contributing to Omarchy source code.

## Topic Guides

Deeper instructions for common areas live next to this file. Read the
matching guide before starting:

- [`hyprland.md`](hyprland.md) - keybindings, monitors, window look and feel, keyboard and touchpad, window rules
- [`shell.md`](shell.md) - the Omarchy shell: bar layout, dock, built-in widgets, idle behavior
- [`theming.md`](theming.md) - switching and tweaking themes, backgrounds, fonts, icons, and the boot screen
- [`apps.md`](apps.md) - default apps, web app and TUI launchers, installing and removing software
- [`system.md`](system.md) - environment variables, toggles, language, power, network, audio, security, updates
- [`hooks.md`](hooks.md) - automation hooks that run on system events
- [`capture.md`](capture.md) - screenshots, screen recordings, OCR and QR capture, and file sharing

Making something new has a skill of its own: `omarchy-make-theme`, `omarchy-make-plugin`, `omarchy-make-app`, and `omarchy-make-game`. Reporting a bug or contributing a fix upstream follows `omarchy-contribute`.

## Critical Safety Rules

For privileged commands, follow the Privilege Escalation rules below: `sudo` when a terminal is available for the password prompt, `pkexec` with a reason for its dialog when it is not. Do not wrap commands that already manage privilege elevation themselves.

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

If the request is to develop Omarchy itself, this skill is out of scope. Follow repository development instructions instead of this skill.

## Privilege Escalation

For an interactive script or command run in a visible terminal, use `sudo` for
privileged work. Omarchy may grant passwordless `sudo` access to particular
commands, and the terminal is the appropriate place to request a password
when one is needed.

Use `pkexec` only when the caller cannot interact with a terminal or cannot
enter a password there, such as a command launched by an agent or a graphical
background process. Do not replace `sudo` with `pkexec` merely because a
command changes system state.

The one exception is installing an app Omarchy curates (a coding agent, an
_Install > CLI_ tool, `gh`, an AI desktop app): use `omarchy-pkg-add-curated`,
from a terminal or not. Its polkit action is what lets the machine's own
session install without a password while SSH still asks, which `sudo` can't
tell apart.

When you run `pkexec` yourself, give the password dialog a reason. Without one, the dialog shows who is asking (when it can tell) and the command, shortened once the command gets long. That tells the person what will run, but not why. Set the reason directly before `pkexec`, in the same shell command, using one array for both:

```bash
cmd=(install -d -m 0755 /etc/myapp)
omarchy-shell -q omarchy.polkit expect "${cmd[*]}" "Claude needs a system configuration directory for MyApp"
pkexec "${cmd[@]}"
```

The reason appears only on a prompt whose command line matches the one you gave it. That is the command after `pkexec`, with each argument joined by single spaces. A bare program name also matches the full path pkexec finds for it. Keep `pkexec`'s own options out of the array (`pkexec --user postgres "${cmd[@]}"`), because they are not part of the command line. The array keeps the two in step. Typing the command twice may not match, because globs, `$` and quoting expand differently inside a string. If they don't match, nothing fails: the dialog just has no reason. The reason replaces the line that names who is asking, and it is shown on a single line, so name yourself and keep it short. Your command still appears on its own line beneath the reason, so don't repeat it. A reason is used once, by the next matching prompt within a minute, and only the latest one is kept. Give each `pkexec` its own reason, and run them one at a time.

## System Architecture

Omarchy is built on:

| Component | Purpose | Config Location |
|-----------|---------|-----------------|
| **Arch Linux** | Base OS | `/etc/`, `~/.config/` |
| **Hyprland** | Wayland compositor/WM | `~/.config/hypr/` |
| **Omarchy shell** | Bar, dock, notifications, panels, OSD (Quickshell) | `~/.config/omarchy/shell.json` |
| **Launcher/menus** | Quickshell menu | `~/.config/omarchy/extensions/omarchy-menu.jsonc` |
| **foot** (default), Alacritty, Kitty, Ghostty | Terminals | `~/.config/<terminal>/` |
| **UWSM** | Session and its environment | `~/.config/uwsm/env.d/` |

The default apps are foot, Google Chrome, Plain (editor), Folio (files), and Omaview (images, video, music); [`apps.md`](apps.md) has the full list and how to change each.

## Command Discovery

Omarchy ships a single `omarchy` CLI that dispatches to all `omarchy-*` binaries via `omarchy <group> <action>`. Always prefer this form — it is self-documenting and stable. The underlying `omarchy-*` binaries still exist on `PATH` and remain safe to read for source. The one exception is diagnostics: run `omarchy-debug --no-sudo --print` directly. On a package install it lives outside the directory the `omarchy` router searches, so `omarchy debug` can fail there with "Unknown Omarchy command".

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

Run `omarchy --help` for the full list. The most common groups:

| Group | Purpose | Example |
|-------|---------|---------|
| `omarchy default` | Default browser, terminal, editor, dictation, agent | `omarchy default browser firefox` |
| `omarchy refresh` | Reset config to defaults (backs up first) | `omarchy refresh shell` |
| `omarchy restart` | Restart a service/app | `omarchy restart shell` |
| `omarchy toggle` | Toggle feature on/off | `omarchy toggle idle` |
| `omarchy theme` | Theme and background | `omarchy theme set <name>` |
| `omarchy font` / `icons` | Monospace font, app icon set | `omarchy font set <name>` |
| `omarchy bar` / `dock` | Bar and dock layout | `omarchy bar position bottom` |
| `omarchy hyprland` | Windows, monitors, layouts | `omarchy hyprland monitor scaling --monitor DP-1 1.5` |
| `omarchy display` | Text scaling everywhere | `omarchy display text size 14` |
| `omarchy device` | Touchpad, touchscreen, keyboard top row | `omarchy device touchpad off` |
| `omarchy plugin` | Manage/clone shell plugins | `omarchy plugin clone omarchy.clock` |
| `omarchy hook` | Install automation hooks | `omarchy hook install theme-set <script>` |
| `omarchy install` / `remove` | Curated software installers | `omarchy install browser firefox` |
| `omarchy pkg` | Package management | `omarchy pkg add <pkg>` |
| `omarchy webapp` / `tui` | Launchers for web apps and terminal apps | `omarchy webapp install` |
| `omarchy launch` | Launch apps | `omarchy launch browser` |
| `omarchy capture` | Screenshots, recordings, OCR, QR | `omarchy capture screenshot` |
| `omarchy language` / `region` | Display language, date and number formats | `omarchy language da` |
| `omarchy powerprofiles` | Power profile per power source | `omarchy powerprofiles set battery power-saver` |
| `omarchy setup` | Interactive setup wizards | `omarchy setup security fingerprint` |
| `omarchy agent` | Coding agents, accounts, local models | `omarchy agent account list` |
| `omarchy reminder` | Desktop notification reminders | `omarchy reminder 15 "Pickup Jack"` |
| `omarchy update` / `snapshot` | System updates and snapshots | `omarchy update` |

## Configuration Locations

Hyprland config lives in `~/.config/hypr/` — see [`hyprland.md`](hyprland.md).
The Omarchy shell (bar, notifications, plugins, idle) is configured in
`~/.config/omarchy/shell.json` — see [`shell.md`](shell.md).

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
| git | `~/.config/git/config` (name and email: `omarchy setup git`) |
| tmux | `~/.config/tmux/tmux.conf` (`omarchy restart tmux`) |
| Shell aliases and exports | `~/.bashrc` |
| Desktop environment variables | `~/.config/uwsm/env.d/` (see [`system.md`](system.md)) |
| Which app opens a file type | `~/.config/mimeapps.list` (see [`apps.md`](apps.md)) |

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
omarchy-debug --no-sudo --print # Debug info (ALWAYS use these flags)
omarchy system lock             # Lock screen
omarchy system shutdown         # Shutdown
omarchy system reboot           # Reboot
omarchy system logout           # Log out
omarchy system firmware         # Reboot into the BIOS/UEFI setup
```

**IMPORTANT:** Always run `omarchy-debug` with `--no-sudo --print` flags to avoid interactive sudo prompts that will hang the terminal.

## Troubleshooting

```bash
# Get debug information (ALWAYS use these flags to avoid interactive prompts)
omarchy-debug --no-sudo --print

# Reset specific config to defaults
omarchy refresh <app>

# Refresh specific config file
# config-file path is relative to ~/.config/
# eg. `omarchy refresh config hypr/hyprland.lua` will refresh ~/.config/hypr/hyprland.lua
omarchy refresh config <config-file>

# Reset every Omarchy config in $HOME to defaults (destructive)
omarchy reinstall configs

# Reinstall all Omarchy packages and reset every config (nuclear option;
# interactive, needs sudo and a visible terminal, offers a reboot)
omarchy reinstall
```

Both reinstalls wipe customizations: confirm with the user before running either.

## Decision Framework

When user requests system changes:

1. **Is it a stock omarchy command?** Use it directly
2. **Is it a config edit?** Edit in `~/.config/`, never `/usr/share/omarchy/`
3. **Is it a theme customization?** Follow [`theming.md`](theming.md); overlay or fork into `~/.config/omarchy/themes/`, never edit a stock theme
4. **Is it automation?** Follow [`hooks.md`](hooks.md); use `omarchy hook install` and the hook `.d` directories
5. **Is it a package install?** Prefer a curated `omarchy install ...` when one exists, else `omarchy pkg add <pkgs...>` (or `omarchy pkg aur add <pkgs...>` for AUR-only packages); see [`apps.md`](apps.md)
6. **Is it which app opens something?** Use `omarchy default ...` or `xdg-mime`; see [`apps.md`](apps.md)
7. **Is it an environment variable?** `~/.bashrc` for terminals, `~/.config/uwsm/env.d/` for the desktop; see [`system.md`](system.md)
8. **Is it built-in shell/plugin code?** Follow [`shell.md`](shell.md); clone it with `omarchy plugin clone`, never edit the packaged copy
9. **Unsure if command exists?** Run `omarchy commands` (or `omarchy <group> --help` for one group)

### Reminder Requests

When the user asks to set a reminder, use `omarchy reminder <minutes> [message]` directly. Convert natural language durations to minutes and title-case short reminder labels when appropriate.

```bash
omarchy reminder 15 "Pickup Jack"
omarchy reminder 60 "Check laundry"
omarchy reminder show
omarchy reminder clear
```

## Out of Scope

This skill intentionally does not cover Omarchy source development. Do not use this skill for:
- Editing files in `/usr/share/omarchy/` (`bin/`, `config/`, `default/`, `shell/`, `themes/`, `migrations/`, etc.)
- Creating or editing migrations
- Running `omarchy dev ...` commands

## Example Requests

- "Change my theme to catppuccin" -> `omarchy theme set catppuccin`
- "Add a keybinding for Super+E to open file manager" -> Check existing bindings first, then use `o.rebind` to replace one or `o.bind` to add one in `~/.config/hypr/bindings.lua`
- "Configure my external monitor" -> `omarchy hyprland monitor scaling|resolution|rotate --monitor <name> ...`; edit `~/.config/hypr/monitors.lua` only for the extras in hyprland.md (disabled outputs, 10-bit, VRR, unlisted modes)
- "Make the window gaps smaller" -> Edit `~/.config/hypr/looknfeel.lua` (`omarchy hyprland window gaps toggle` turns them off entirely)
- "Make windows square" -> `omarchy hyprland corners sharp`
- "Turn on night light" -> `omarchy toggle nightlight` (for a schedule, see `system.md`: hyprsunset must also be started from `autostart.lua`)
- "Make Firefox my default browser" -> `omarchy default browser firefox` (installs it first if it's missing)
- "Use Ghostty instead of foot" -> `omarchy install terminal ghostty` (installs it and makes it the default)
- "Open PDFs in another app" -> `xdg-mime default <app>.desktop application/pdf`
- "Add YouTube as an app" -> `omarchy webapp install "YouTube" https://youtube.com <icon-url>`
- "Show a 12-hour clock" -> `omarchy bar set omarchy.clock format "h:mm AP"`
- "Move the bar to the bottom" -> `omarchy bar position bottom`
- "Keep my laptop awake" -> `omarchy toggle idle stay-awake`
- "Add a Danish keyboard layout" -> `kb_layout = "us,dk"` in `~/.config/hypr/input.lua` (or `omarchy setup keyboard`)
- "Set an environment variable for all apps" -> A file in `~/.config/uwsm/env.d/`, applied at next login
- "Make text bigger everywhere" -> `omarchy display text size <9-20>`
- "Set a reminder to pickup jack in 15 minutes" -> `omarchy reminder 15 "Pickup Jack"`
- "Show my reminders" -> `omarchy reminder show`
- "Clear all reminders" -> `omarchy reminder clear`
- "Customize the catppuccin theme colors" -> Overlay: put an edited `colors.toml` in `~/.config/omarchy/themes/catppuccin/`, then re-apply the theme (see `theming.md`)
- "Run a script every time I change themes" -> Install it with `omarchy hook install theme-set <script>`
- "Change how workspace labels are rendered" -> Clone `omarchy.workspaces`, which switches the bar to `<username>.workspaces`, then edit the clone
- "Lock after ten minutes" -> Set `idle.lock` to `600` in `~/.config/omarchy/shell.json`
- "Reset shell/bar to defaults" -> `omarchy refresh shell`
- "Record my screen" -> `omarchy screenrecord --fullscreen`, then `omarchy screenrecord --stop-recording` (see `capture.md`)
- "Report this bug to Omarchy" -> Follow the omarchy-contribute skill
