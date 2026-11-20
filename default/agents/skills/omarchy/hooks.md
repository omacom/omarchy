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
├── post-update.d/          # Late in `omarchy update`, after packages, migrations and service restarts
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

Both package hooks run as your user with your PATH. `post-update` runs inside `omarchy update`'s sudo authorization, so a hook that invokes `sudo` does not prompt again; it comes after the system packages, migrations and service restarts, and before mise tools, AUR packages and the boot-file check. `pre-refresh-pacman` runs inside `omarchy refresh pacman` (which channel switches and `omarchy reinstall` use, not `omarchy update`), right after it writes the new package config with sudo and before the package transaction, so custom repositories and `IgnorePkg` entries shape that transaction.
