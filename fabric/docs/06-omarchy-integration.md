# Omarchy integration and contributing back

Studied against `omacom/omarchy` on the `quattro` branch (2026-11-22). The fabric now lives in `fabric/` on the `fabric/main` branch of a fork of Omarchy ([dereksgithub/omarchy](https://github.com/dereksgithub/omarchy)), so the tree around it is Omarchy itself. Omarchy 4 is an agentic distribution: coding-agent launchers, shared skills in `~/.agents/skills`, an agents panel, local models. It has no smart-home, IoT or MCP device layer, so the fabric adds a new area rather than competing with anything in it.

## What plugs in where

Every piece follows a mechanism Omarchy already has, so nothing in Omarchy needs patching to try it.

| Piece | Omarchy mechanism | In this repo |
|---|---|---|
| Installer | `omarchy-install-*` scripts with `# omarchy:` metadata, `omarchy-pkg-add`, bash conventions from AGENTS.md | `omarchy/bin/omarchy-install-fabric` |
| Bar widget | Quickshell shell plugin in `~/.config/omarchy/plugins/<id>/` with a manifest, `BarWidget.qml` and `i18n/` | `omarchy/plugin/fabric.status/` |
| Approvals as notifications | `omarchy-notification-send ... --action <label> <program>` | `src/omarchy_fabric/console.py` |
| Menu | `~/.config/omarchy/extensions/omarchy-menu.jsonc` overlay | `omarchy/menu/fabric.jsonc` |
| Theme-synced lights | `omarchy-hook theme-set <name>` with drop-ins in `~/.config/omarchy/hooks/theme-set.d/` | `omarchy/hooks/theme-set` |
| Agent knowledge | Skills in `~/.agents/skills` and each harness's skills dir | `omarchy/skills/omarchy-fabric/SKILL.md` |
| Agent access | `claude mcp add`, `codex mcp add` | done by the installer |
| Services | user units under `graphical-session.target` (uwsm) | `omarchy/systemd/` |

Design rules taken from Omarchy's AGENTS.md and shell guide:

- **No polling in the shell.** The widget watches `$XDG_RUNTIME_DIR/omarchy-fabric/status.json` with a `FileView`; `ofab console` rewrites it on fabric events. An idle shell starts no processes.
- **Plugin text is untrusted.** Every `Text` uses `Text.PlainText`, strings are clipped, and approval ids are matched against the fabric's fixed alphabet before they reach a command line.
- **Translations**: the widget ships `i18n/en.json`, which Omarchy falls back to for its other 49 languages.
- **Platform names**: the node is `aarch64` in Omarchy's terms; we don't invent spellings.
- **Notifications go through `omarchy-notification-send`**, never `notify-send` directly (`notify-send` is only a fallback off Omarchy).

## Not verified yet

The QML widget, the menu overlay and the installer were written against Omarchy's docs and source but have not run on an Omarchy machine (this round was built on macOS). On Omarchy, check them with:

```bash
omarchy plugin validate ~/.config/omarchy/plugins/fabric.status
```

```bash
omarchy agent look plugin ~/.config/omarchy/plugins/fabric.status
```

Hyprland's config is Lua in Omarchy 4, so no hotkey is installed yet; the menu entry and the bar cover it until a binding is chosen by the plane rules in Omarchy's hotkeys manual.

## Branches on the fork

| Branch | Role |
|---|---|
| `quattro` | An exact mirror of Omarchy's `quattro`. Never commit to it; keep it current with GitHub's "Sync fork" or `gh repo sync dereksgithub/omarchy`. |
| `fabric/main` | The fabric's main branch. Clone this one. |
| `fabric/round-N` and other topic branches | One round or topic of work, cut from `fabric/main` and merged back by a pull request inside the fork. |

Open those pull requests with an explicit base: GitHub points a fork's pull requests at the parent repository by default, which would send them to Omarchy itself.

```bash
gh pr create --repo dereksgithub/omarchy --base fabric/main --head fabric/round-N
```

When Omarchy's `quattro` moves on, sync the fork's `quattro`, then merge it into `fabric/main`. Nothing outside `fabric/` differs between the two, so the merge is clean.

## Contributing back: what and in what order

Omarchy prefers small, atomic changes that follow its conventions, and it fixes platform gaps upstream before working around them. So the plan goes from most to least generally useful:

1. **Pi 5 findings (H20).** The Pi 5 is untested upstream and we have one. Boot Omarchy's ARM build on it, record what works (display, Wi-Fi, audio, GPIO, the shell), and file issues or fixes for the `aarch64` platform. This helps every Pi owner and is the most valuable thing we can give.
2. **A generic "register an MCP server with every agent" helper.** Omarchy already links instructions and skills into every harness (`omarchy-agent-instructions`, `omarchy-agent-skills-link`), but each harness keeps its own MCP config. A small `omarchy agent mcp add <name> -- <command>` that knows each harness's format is useful far beyond the fabric.
3. **Publish the bar widget as its own repo** (`manifest.json` at the root) so anyone can `omarchy plugin add` it. No upstream change needed.
4. **Propose `omarchy-install-fabric`** (Install > AI, or a new smart-home entry) once the fabric has run on real hardware for a while. The script is already written to upstream conventions.
5. **Join the Omarchy Server plan** (`plans/server.md`): a headless edition with a BBS-style home menu is the natural home for the fabric node, and a `[F] Fabric` door (status, approvals, audit) fits its door model.

None of these PRs carries the whole `fabric/` folder. The folder lives on the fork's branch so the project and Omarchy sit side by side; each upstream PR takes only the small piece it needs, through Omarchy's own process: fork, follow its AGENTS.md, run `./test/all`, then `gh pr create` against `quattro`.

Outside Omarchy, the prior art suggests talking to **ha-mcp** about a shared approval format, and following the W3C WoT Working Group's new work on agents acting on the physical world.
