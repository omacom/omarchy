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
├── post-update.d/          # Near the end of `omarchy update`, inside its sudo authorization, before mise and AUR
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

Update-related hooks run as your user, on opposite sides of the update's sudo boundary. `post-update` runs inside `omarchy update`'s single shared sudo authorization, after packages, migrations and service restarts and before mise, so a `sudo` in it does not prompt and the hook has the same root access as the update; AUR builds and the boot check follow it, after that authorization is revoked. `pre-refresh-pacman` runs cold: after Omarchy invalidates its sudo timestamp, behind the no-update wrapper, so a hook that invokes `sudo` must request its own explicit authorization, and Omarchy revokes the timestamp again before continuing. It runs after `omarchy refresh pacman` re-syncs the package config and before the package transaction, so custom repositories and `IgnorePkg` entries shape that transaction; every later privileged command in that refresh still authenticates without publishing a reusable timestamp, so a detached child left behind by the hook has nothing to wait for during it. A channel switch then runs `omarchy update`, which opens its own shared authorization, so that guarantee ends where the update begins.
