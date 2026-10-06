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
├── battery-low.d/          # Low battery (percentage in $1)
├── font-set.d/             # After font change (font name in $1)
├── post-boot.d/            # After the desktop starts
├── post-update.d/          # At the end of `omarchy update`, after privileged work
├── pre-refresh-pacman.d/   # After `omarchy refresh pacman` re-syncs the package config, before it updates packages
└── theme-set.d/            # After theme change (theme slug in $1)
```

Example hook script:
```bash
#!/bin/bash
THEME_NAME=$1
echo "Theme changed to: $THEME_NAME"
# Add custom actions here
```

Update-related hooks run as your user after Omarchy invalidates its sudo timestamp, behind the no-update wrapper. A hook that invokes `sudo` must therefore request its own explicit authorization, and Omarchy revokes the timestamp again before continuing. `post-update` runs after every sudo-capable update stage. `pre-refresh-pacman` runs after `omarchy refresh pacman` re-syncs the package config and before the package transaction, so custom repositories and `IgnorePkg` entries shape that transaction; every later privileged command still authenticates without publishing a reusable timestamp, so a detached child left behind by the hook has nothing to wait for.
