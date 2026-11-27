# System: Environment, Toggles, Hardware, and Updates

Read this before setting environment variables or changing idle, power, language, network, audio, security, or update behavior.

## Environment Variables and Shell Setup

- Shell aliases, functions, and exports for terminals go in `~/.bashrc`. Updates never overwrite it.
- Variables the whole desktop should see go in a file in `~/.config/uwsm/env.d/` (e.g. `~/.config/uwsm/env.d/20-mine`, with `export NAME=value` lines). They take effect at the next login. These files run before the desktop starts, so a shell error in one sends the user back to the login screen: keep the syntax plain, and tell the user that moving the file out of `env.d` undoes it.
- Omarchy's own session defaults (`TERMINAL=xdg-terminal-exec`, `EDITOR="omarchy-launch-editor --inline"`, and so on) are in `$OMARCHY_PATH/default/uwsm/default`; override them in `env.d` rather than editing `~/.config/uwsm/default`.

## Toggles

```bash
omarchy toggle idle [stay-awake|allow-idle|status]   # Keep the machine awake (Super+Ctrl+I)
omarchy toggle notification silencing                # Do not disturb
omarchy toggle nightlight                            # Warm the screen now
omarchy toggle screensaver                           # Screensaver on idle
omarchy toggle suspend                               # Suspend in the system menu
omarchy toggle crash-capture                         # "Process crashed" notifications
omarchy crash mute <program> [on|off]                # ...for one program only
```

A scheduled night light needs hyprsunset running from login: set the profiles in `~/.config/hypr/hyprsunset.conf`, add `o.launch_on_start("hyprsunset")` to `~/.config/hypr/autostart.lua`, then `omarchy restart hyprsunset` to start it now.

## Language, Region, and Time

```bash
omarchy language [<code>|list]     # Display language of Omarchy and its apps
omarchy region formats [<code>|list|default]  # How dates, times, numbers, and units are written
omarchy menu timezone              # Pick the timezone
omarchy weather location --set <place>
```

## Power and Sleep

```bash
omarchy powerprofiles list
omarchy powerprofiles set [autodetect|ac|battery] [power-saver|balanced|performance]  # Remembered per power source
omarchy hibernation setup          # Or: omarchy hibernation remove
```

Idle and lock timing is in [`shell.md`](shell.md).

## Network, Bluetooth, and Audio

Network and Bluetooth panels are on Super+Ctrl+N and Super+Ctrl+B, and `nmtui` works for anything they don't cover.

```bash
omarchy dns [Cloudflare|Google|DHCP|Custom]
omarchy network band [auto|2.4|5|6]          # Pin the Wi-Fi band
omarchy network password <interface>         # Print the Wi-Fi password
omarchy network speedtest [down|up]
omarchy bluetooth power <on|off|toggle>
omarchy audio output switch                  # Next output, keeping mute
omarchy audio input mute
omarchy restart audio|bluetooth|wifi|trackpad   # When one gets stuck
```

## Security

```bash
omarchy setup security fingerprint     # Fingerprint for sudo, polkit and the lock screen
omarchy setup security fido2           # Security key for sudo and polkit
omarchy setup security sshd            # SSH server, firewall, and an authorized key
omarchy setup security ssh-agent
omarchy remove security <fingerprint|fido2|sshd|sudoless-docker>
omarchy sudo passwordless [MINUTES|permanent|--disable]
omarchy drive password                 # Change the disk encryption password
```

These are interactive: run them in a terminal the user can see.

## Updates, Snapshots, and Recovery

Always update with `omarchy update`, never `pacman -Syu` or `yay -Syu`: Omarchy's update takes a snapshot first and runs its migrations and config updates with the new packages, and Omarchy blocks a direct system upgrade.

```bash
omarchy update                        # Snapshot, packages, migrations, config updates
omarchy snapshot create               # Or: omarchy snapshot restore
omarchy channel set <stable|rc|edge>  # Which Omarchy release stream to follow
omarchy kernel [list|set <kernel>]    # Kernel Limine boots by default
omarchy update firmware
omarchy setup factory reset           # Back to a fresh install (destructive; confirm with the user first)
```

## AI Agents and Dictation

- `omarchy default agent <name>` picks the coding agent that `omarchy agent` and the bar's agents panel use. Personal rules for every agent go in `~/.agents/AGENTS.md` (`omarchy agent instructions --edit`).
- `omarchy agent account list|add|use` manages Claude, Codex and Grok subscription accounts; `omarchy models use best <text|image|video|music>` runs the recommended open model of that kind on this machine.
- `omarchy agent resume set [--agent <name>] [--session <id>|--continue] [--dir <path>] [--prompt <text>|--prompt-file <path>]` arms a one-shot resume that reopens the coding agent on the next login and disarms itself automatically (`status` inspects it, `off` cancels it). Pass `--session <id>` when you know your current session/conversation ID, `--continue` to rejoin the latest session in `--dir` (supported for `agy`, `claude`, `codex`, `pi`, `opencode`, and `kilo`), or omit both to open a fresh session with a concrete handoff prompt; if the agent needs another reboot, arm it again. On encrypted disks, unattended reboots also need Passwordless Login (`omarchy-setup-security-passwordless-login --active` checks it; never enable it without the user's go-ahead).
- Dictation is Alt+Space, or hold Right Alt to talk; `omarchy default dictation <superwhisper|voxtype|hex>` picks the backend. Superwhisper installs a `superwhisper` skill of its own for its settings.
