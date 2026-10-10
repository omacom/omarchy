# Automation Hooks

Use this guide for scripts triggered by theme changes, updates, boot, battery, or
other Omarchy events.

## Hook Shape

Hooks live under `~/.config/omarchy/hooks/`:

```text
~/.config/omarchy/hooks/<name>       # Optional legacy single script; runs first
~/.config/omarchy/hooks/<name>.d/    # Independent scripts; run in filename order
```

Install a script into the directory form:

```bash
omarchy hook install <name> <script>
```

The installer copies the script and makes the installed copy executable. Use a
portable `#!/bin/bash` script and handle the event arguments documented below.

| Event | Timing and arguments |
|---|---|
| `battery-low` | Low battery; percentage in `$1` |
| `font-set` | After a font change; font name in `$1` |
| `post-boot` | After the desktop starts |
| `post-update` | After system packages, migrations, orphan-package cleanup, and service restarts; before Mise and AUR updates |
| `pre-refresh-pacman` | After `omarchy refresh pacman` rewrites the package configuration, before it updates packages |
| `theme-set` | After a theme change; theme slug in `$1` |

`pre-refresh-pacman` runs behind the no-update wrapper with the sudo timestamp
revoked before and after it, so a hook that invokes `sudo` authenticates for
itself and none of that authorization carries into the package transaction.
Custom repositories and `IgnorePkg` entries it writes shape that transaction.

## Implementation Loop

1. Inspect existing scripts under the target hook name so the new script has one responsibility and a distinct filename.
2. When the script is safe to run outside its event, run it directly with representative arguments.
3. Install it with `omarchy hook install`.
4. Trigger the real event when doing so is safe. `omarchy hook <name> [args...]` runs every script for that event, not only the new one, and none of the environment the event sets up — `pre-refresh-pacman` loses its sudo revocation and no-update wrapper — so use it only when every script for the event is safe to run that way.
5. Observe the intended side effect and inspect any script output or logs.

Example:

```bash
#!/bin/bash
set -e

theme_name=$1
printf 'Theme changed to: %s\n' "$theme_name"
```

Hook work is complete when the installed copy exists under the intended
`<name>.d/`, a safe representative execution exits successfully, and the
intended side effect has been observed. Report any real event that was unsafe or impractical
to trigger as unverified.

## Recovery

Disable a hook by moving its user-owned script outside the hook directory;
restore it by moving the same file back. Obtain confirmation before deleting a
user script. Recovery is complete when the script is no longer under the hook
directory and the other scripts for that event remain in place.
