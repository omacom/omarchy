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

Update-related hooks run as your user, but they differ in whether sudo is already authorized. `pre-refresh-pacman` runs cold, between two timestamp revocations and behind the no-update wrapper, so a hook that invokes `sudo` must request its own explicit authorization and no reusable timestamp is published; a detached child left behind by the hook has nothing to wait for. `post-update` runs inside the update's single shared sudo authorization, which mise also draws on, so a hook that invokes `sudo` there will not prompt. Only the update's own AUR phase is deliberately kept outside that authorization — `omarchy-update` revokes before `omarchy-update-aur-pkgs` and runs it behind the wrapper — but a `post-update` hook that starts AUR build tooling itself does so inside the window while the hook is running; anything the hook detaches in the background may outlive the revocation and prompt for its own authorization. `post-update` runs after every sudo-capable update stage. `pre-refresh-pacman` runs after `omarchy refresh pacman` re-syncs the package config and before the package transaction, so custom repositories and `IgnorePkg` entries shape that transaction. See `docs/update-process.md` for the full ordering.
