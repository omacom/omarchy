# mise and where tools go

Read this before adding a tool to Omarchy, or before changing how Omarchy uses mise.

## Omarchy declares no mise tools

mise manages the language runtimes a user sets up from _Install > Development_ (`omarchy-install-dev-env`), each one written to the user's own config with `mise use --global`. Omarchy installs nothing through mise on its own, and ships no lazy tools or auto-install stubs: `etc/mise/conf.d/omarchy-tools.toml` declares nothing, and stays only because older migrations wait for it to exist.

Every other tool is a package in omacom/omarchy-pkgs, updated by `omarchy update` like the rest of the system:

- A tool everyone gets goes in `install/omarchy-base.packages` (`uv`, `nodejs`, `playwright-cli`).
- A coding agent is a package on the fast ring, which publishes each upstream release to every channel within the hour. It is installed explicitly, from _Install > AI > CLI_ or by picking it in the agents panel, through `omarchy-install-ai-cli`, which maps the agent's command to its package. Add a new agent there, under `install.ai.cli` and `remove.ai.cli` in the menu, in `omarchy-default-agent`, and in `omarchy-agent`.
- Any other optional CLI goes under _Install > CLI_ and _Remove > CLI_ (GitHub, which is gh and ghui, Hunk, Basecamp, Cloudflare, HEY); gh also comes with _Setup > Git_.
- A package turns off the tool's own updater, since pacman owns updates.

Don't split a kind of tool between mise and packages, and don't add a mise declaration to get a tool installed.

## What Omarchy still asks of mise

- `etc/mise/conf.d/omarchy.toml` holds settings, such as keeping the version a running process uses when `mise up` upgrades it.
- `omarchy update` runs `omarchy-update-mise` for the runtimes the user set up.

Account switching for `claude`, `codex` and `grok` is Omarchy's own, not mise's: `omarchy-agent-account-dispatch` writes a dispatcher into `~/.local/share/omarchy/agent-accounts/bin` for each of them that is installed, running `omarchy-agent-account-exec`, and `default/bash/env-bootstrap` puts that directory first on PATH, so every session, script and editor runs as the selected subscription account. There is no dispatcher for a CLI that isn't installed: installing or removing an agent through Omarchy rewrites them, and one whose CLI was removed some other way takes itself away the next time it runs.

## Leave the user's config alone

`~/.config/mise/config.toml` is the user's. Omarchy writes to it only when the user asks for a runtime from _Install > Development_, and a migration may hand a tool Omarchy no longer ships to it, so the tool keeps working as the user's own.
