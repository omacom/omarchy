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

## Check What Exists Before Building

Before writing a new plugin, widget, overlay, or shell feature, or reaching for config that a plugin might cover, check in this order and stop at the first thing that covers the request:

1. **Already on the system.** Omarchy ships many first-party plugins, and some of them are installed but disabled.

   ```bash
   omarchy plugin list                  # ID, STATE (enabled/disabled), SOURCE, KINDS, NAME
   omarchy menu keybindings --print     # the feature may already have a hotkey
   omarchy commands                     # or a stock command
   ```

   If it is enabled, tell the user how to use it (e.g. its hotkey). If it is disabled, offer `omarchy plugin enable <id>`. If it nearly fits, offer `omarchy plugin clone <id>` (see below). Do not suggest a marketplace plugin for something Omarchy already does unless the user asks for an alternative.

2. **The community marketplace** at https://plugins.omarchy.org/. Also search here when the request could be done in config (Hyprland, hypridle, shell.json) but a plugin might do it too, for example a custom lock screen; in that case offer both options. Always search when the config route only partly does what was asked (e.g. hyprsunset profiles use fixed times, not real sunset). The site is backed by a public JSON catalog, so search it directly:

   ```bash
   q='gpu|temp|temperature|thermal'   # whole words, |-separated; include synonyms
   curl -fsSL https://plugins.omarchy.org/catalog.json | jq -r --arg q "$q" '
     [.plugins[]
      | select([.id, .name, .description, (.tags | join(" "))] | join(" ")
               | test("\\b(" + $q + ")\\b"; "i"))]
     | sort_by([(.verificationStatus != "verified"), -(.stars // 0)])
     | .[:15][]
     | "\(.id)\t\(.kind)\t\(.verificationStatus // "unknown")\t★\(.stars // 0)\t\(if .installAvailable then .installCommand else "manual: " + .repo end)\n    \(.description)"'
   ```

   Matching is by whole word, so `mic` does not match "ergonomic"; list each word form you want (`mic|microphone`). Results come back verified first, then by stars, capped at 15. If nothing relevant turns up, retry with synonyms before concluding there is no plugin.

When the marketplace has matches:

- Show them to the user (id, description, verified or not, stars, repo) and ask whether to install one before building anything.
- Prefer `verified` entries. Before installing a plugin, look at its repo, because it runs code inside the shell.
- Check that the plugin fits this machine before recommending it: a desktop or laptop, GPU vendor (`lspci | grep -i vga`), battery present (`ls /sys/class/power_supply`), and whether any required daemon or tool is installed (e.g. docker, tailscale). Drop plugins built for other hardware (e.g. vendor-specific laptop widgets) and say why.
- Install with the entry's `installCommand` (`omarchy plugin add <git-url> --enable`). When `installAvailable` is false, the entry is a suite or needs manual setup: point the user to its `repo` and `installNote`.
- If a plugin is close but not exact, suggest installing it and changing it rather than writing a new one from scratch.
- Build a new plugin only when nothing fits or the user asks for one.

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

## Idle and Lock

Set `idle.screensaver` and `idle.lock` in `~/.config/omarchy/shell.json`,
in seconds since user idle began. Example: "lock after ten minutes" means
setting `idle.lock` to `600`.
