# Automation Hooks

Read this before setting up scripts that run on system events (theme changes,
updates, boot, low battery, etc.).

Hooks live in `~/.config/omarchy/hooks/<name>.d/` — one directory per event,
holding any number of independent scripts. Install with
`omarchy hook install <name> <script>` (copies the script in and makes it
executable). The runner also executes a flat `~/.config/omarchy/hooks/<name>`
file first, if one exists.

```
~/.config/omarchy/hooks/
├── agent-launch.d/         # Before `omarchy agent` replaces itself (harness in $1, cwd in $2)
├── battery-low.d/          # Low battery (percentage in $1)
├── font-set.d/             # After font change (font name in $1)
├── post-boot.d/            # After the desktop starts
├── post-update.d/          # At the end of `omarchy update`, after privileged work
├── pre-refresh-pacman.d/   # After `omarchy refresh pacman` re-syncs the package config, before it updates packages
└── theme-set.d/            # After theme change (theme slug in $1)
```

`agent-launch` has a five-second deadline for the whole run, including the flat hook and every script in `agent-launch.d` in sequence. A hook that ignores termination is killed one second later; later scripts may never run. Keep these hooks short or hand longer work to a background service. Hook stdout and stderr are discarded so background work can keep its output descriptors without blocking launch or being terminated by a closed logging pipe. Failed hook runs and timeouts produce a status diagnostic in the system journal under `omarchy-agent-hook`; read those with `journalctl -t omarchy-agent-hook`. For successful-hook troubleshooting, write explicitly to your own log or use `logger` inside the hook. Hook input is isolated from the agent terminal, and failures still allow the agent to start.

Example hook script:
```bash
#!/bin/bash
THEME_NAME=$1
echo "Theme changed to: $THEME_NAME"
# Add custom actions here
```

Update-related hooks run as your user after Omarchy invalidates its sudo timestamp, behind the no-update wrapper. A hook that invokes `sudo` must therefore request its own explicit authorization, and Omarchy revokes the timestamp again before continuing. `post-update` runs after every sudo-capable update stage. `pre-refresh-pacman` runs after `omarchy refresh pacman` re-syncs the package config and before the package transaction, so custom repositories and `IgnorePkg` entries shape that transaction; every later privileged command still authenticates without publishing a reusable timestamp, so a detached child left behind by the hook has nothing to wait for.
