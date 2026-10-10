# Omarchy Shell: Bar, Plugins, and Idle

Read this before changing the status bar, notifications, shell plugins,
widgets, or idle/lock behavior.

The bar, notification daemon, settings panel, and assorted overlays all run
inside a single long-running Quickshell process (`omarchy-shell`).

```
~/.config/omarchy/shell.json             # User overrides: bar, plugins, idle
~/.config/omarchy/plugins/<plugin-id>/   # User-owned shell plugins
$OMARCHY_PATH/config/omarchy/shell.json  # Canonical defaults
```

The shell hot-reloads `shell.json` on save — no restart needed for layout
changes. `idle.screensaver` and `idle.lock` are seconds since user idle began.

**Commands:** `omarchy restart shell`, `omarchy refresh shell`

## Bar Layout

Use the `omarchy bar` group to move and manage widgets:

```bash
omarchy bar move omarchy.clock --section right
```

For layout edits beyond what the commands cover, edit the bar configuration
in `~/.config/omarchy/shell.json`; it hot-reloads on save.

## Customizing Built-In Plugins and Widgets

To customize a built-in bar widget, never edit `$OMARCHY_PATH/shell/plugins/`.
Clone it into the user plugin directory instead:

```bash
omarchy plugin clone omarchy.workspaces
# Edit ~/.config/omarchy/plugins/<username>.workspaces/; saved changes reload automatically.
```

Cloning switches the bar to the cloned copy (e.g. `<username>.workspaces`),
which is yours to edit and survives updates.

Saving a file anywhere under `~/.config/omarchy/plugins/` reloads plugin code
automatically. If a change somehow fails to apply, force a reload with
`omarchy-shell shell rescanPlugins`.

## Managing Installed Plugins

Use the `omarchy plugin` group for the whole lifecycle of installed plugins:

```bash
omarchy plugin list
omarchy plugin add <git-url> --enable --yes # installs third-party code
omarchy plugin enable <id> [placement]
omarchy plugin disable <id>      # keep it installed, unload it
omarchy plugin remove <id> --yes # disable, back up (non-git), delete, rescan
omarchy plugin update [id] --yes # update git-managed plugins
```

`add`, `update`, and `remove` ask for confirmation, and without a terminal
they exit with "refusing to continue without confirmation; pass --yes".
`add` and `update` pull third-party code that runs unsandboxed inside
`omarchy-shell`, so get the user's OK before passing `--yes` to them.

Prefer these over hand-editing `~/.config/omarchy/shell.json` or deleting
plugin folders to add or remove plugins: `remove` disables the plugin over
IPC, backs up non-git plugins, and rescans the plugin directory. Hand edits
skip all of that and risk mangling unrelated `shell.json` values.

## Idle and Lock

Set `idle.screensaver` and `idle.lock` in `~/.config/omarchy/shell.json`,
in seconds since user idle began. Example: "lock after ten minutes" means
setting `idle.lock` to `600`.
