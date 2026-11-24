# mise-managed tools

Read this before adding or changing a mise-managed tool. Default tools belong in `etc/mise/conf.d/omarchy-tools.toml`, which the settings package installs; `install/user/mise.sh` creates their native mise shims during user setup.

## What belongs in mise

mise keeps language runtimes and the tools that run on them: Node.js, and npm tools such as Playwright and Cloudflare's `cf`. Everything else is a package in omacom/omarchy-pkgs, updated by `omarchy update` like the rest of the system. That includes every coding agent and standalone CLI (`gh`, `uv`, `hunk`, `ghui`, `basecamp`, `hey`).

- A coding agent is a package on the fast ring, which publishes each upstream release to every channel within the hour. It is installed explicitly, from _Install > AI > CLI_ or by picking it in the agents panel, through `omarchy-install-ai-cli`, which maps the agent's command to its package. Add a new agent there, under `install.ai.cli` and `remove.ai.cli` in the menu, in `omarchy-default-agent`, and in `omarchy-agent`.
- A CLI everyone gets goes in `install/omarchy-base.packages`.
- A package turns off the tool's own updater, since pacman owns updates.

Don't split a kind of tool between mise and packages.

## Leave the user's config alone

Omarchy does not write `~/.config/mise/config.toml`; it is the user's, for overriding what Omarchy ships. Settings go in `etc/mise/conf.d/omarchy.toml`, which still loads after a user opts out of the default tools, and tools in `omarchy-tools.toml`. A command that installs a default tool runs `mise install <tool>` when `omarchy-mise-default-tools declares <tool>`, and `mise use -g` only for a user who opted out. `mise use -g` on a declared tool would copy the declaration's options, `lazy = true` included, into the user's config.

## Declare a default tool

Use a registry shorthand and set `lazy = true` so the first command invocation installs the tool. Follow the existing defaults' release policy: `minimum_release_age = "0s"` makes new releases eligible immediately.

```toml
[tools]
node = { version = "latest", lazy = true, minimum_release_age = "0s" }
```

Lazy defaults need mise 2026.10.11 or newer. Older releases install every lazy tool nobody has run yet. Before 2026.10.11, a bare `mise upgrade`, which `omarchy update` and `mup` run, does it. In 2026.10.7 and 2026.10.8, the `auto_update` check a shell prompt starts did it too.

Backend options go inside a tool's table, never in a `"tool[...]"` key: mise drops bracket options from a key whose value is a table, so a tool declared that way installs without them.

## Choose the registry name

Before adding a GitHub- or Aqua-backed tool, run `mise registry <name>` and inspect the result. The tool name and command may differ.

Use the registry shorthand instead of an explicit `github:` or `aqua:` backend. Shorthands let mise use <https://mise-versions.jdx.dev> for cached version and public GitHub release metadata, reducing GitHub API requests during installation and updates.

If a GitHub- or Aqua-backed tool has no registry entry, request one upstream with the repository or package URL and the required command name. Wait for that entry before adding the tool to Omarchy; do not substitute an explicit `github:` or `aqua:` declaration.

## Handle backend exceptions

Other explicit backends, such as `pipx:`, may be used when their behavior or options are required. Check that a shorthand refers to the intended tool: `cf` names Cloud Foundry in mise's registry, so Omarchy uses `npm:cf` for the Cloudflare CLI.

When an explicit backend has no registry binary metadata, declare the commands mise should create lazy shims for:

```toml
[tools]
"npm:cf" = { version = "latest", lazy = true, lazy_bins = ["cf"], minimum_release_age = "0s" }
```

A registry shorthand whose first backend is `npm:` and whose registry entry lists its commands (`mise registry --json`) also goes in `auto_install_disable_tools` in the `[settings]` of `omarchy-tools.toml`, not `omarchy.toml`: it must go with the declarations when a user opts out, or it would stop a tool the user declares themselves from installing. mise's shim installs such a tool on its own, without the lazy Node it needs, and fails; kept out of the shim's automatic install, its first command takes the lazy install, which brings Node with it. Explicit `npm:` keys and entries that list no command already take the lazy install. The list can go once mise takes the lazy install for these.

After changing declarations, verify that `mise reshim --system` creates the expected commands in an isolated test environment. Test first-use installation as well as an already-installed tool; a declaration alone does not prove its shim works.
