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
├── post-update.d/          # After system packages, migrations, and service restarts
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

Both update-related hooks run as your user. `post-update` runs after system packages, migrations, and service restarts, before mise and AUR updates. The update's sudo authorization is still active during this hook and mise, so commands allowed by your sudo policy may reuse it without another password prompt. Omarchy ends that authorization before running AUR updates and revokes it again on exit.

`pre-refresh-pacman` runs after `omarchy refresh pacman` re-syncs the package config and before the package transaction, so custom repositories and `IgnorePkg` entries shape that transaction. This hook runs after the refresh clears its sudo timestamp, behind the no-update wrapper. Its privileged commands must request their own authorization without publishing a reusable timestamp, and the refresh revokes the timestamp again before continuing.
