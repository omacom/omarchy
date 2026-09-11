# Agent desktops

Agents work in background Hyprland desktops. **Agent Desktops** shows up to eight live screens per page in one borderless native window. Closing the viewer leaves the agents running. An empty viewer says **No active desktops**.

The first active desktop opens the viewer automatically. Further claims join the active batch without reopening or refocusing it. If you close the viewer, it stays closed until all known desktops end and another starts. Open **Agent Desktops** from the app launcher whenever you want to watch. Disable automatic opening with `systemctl --user disable --now agent-desktops-watch.service`; installing again enables the managed watcher.

Each screen keeps its session name, project favicon, host, status, and **Chat** button at the bottom. Verified conversations share a colored border. Chat brings all related desktops into a focused viewer beside a separate Markdown conversation window. Recent messages load first; older history loads on demand. Drafts survive switching conversations, retries retain their message identity, and chat continues the original thread after its desktop closes. **All desktops** restores the overview. Waiting-for-input notifications open the matching conversation while the app runs.

**Take control** enables human input; **Lock input** or **Escape** returns to watch mode. Agents can continue working in either state. Small tiles use reduced streaming quality; focused and controlled tiles use full quality. Offline machines retain their last known tiles until a successful refresh confirms closure.

## Install

```sh
omarchy install ai agent-desktop
```

Optional `--monitor DP-1` places the native overview on that monitor without taking initial focus. Find output names with `hyprctl monitors`. `--port 7873` selects the local MCP port. `--no-start` stages a first installation without starting services or reloading Hyprland.

The package requires a graphical Hyprland session with Lua configuration, Node.js 20+, npm, Python 3, PyGObject, GTK 3, WebKitGTK 4.1, WayVNC, jq, grim, wtype, wlrctl, Xwayland, and systemd user services. The Omarchy command installs dependencies. T3 is optional; plain MCP clients can use desktops without it.

Installation copies the runtime to `~/.local/share/agent-desktop/package` and adds:

- `~/.local/bin/agent-desktop` for agent tools and `~/.local/bin/agent-desktops` for the native viewer.
- The Agent Desktops application entry and Claude/Codex skill links.
- `~/.config/hypr/agent-desktop.lua`, loaded by one `require` in `hyprland.lua`.
- `hypr-desktop.service` and `agent-desktops-watch.service` for the graphical session.
- A private random token and local endpoint files in `~/.local/share/hypr-desktop`.

Existing foreign files and modified generated configuration are refused. Release active desktops and close the viewer before updating. Failed setup restores the previous managed configuration; previous runtime copies are retained after successful updates. Restart agent CLIs to discover the skill.

```sh
agent-desktop tool status '{}'
journalctl --user -u hypr-desktop -u agent-desktops-watch
```

The MCP listens only on loopback and requires its private token. It can run commands as the logged-in user. Desktop separation covers GUI input and browser profiles, not filesystem permissions. Claimed desktops inhibit idle and normal suspend until released or expired. Thirty minutes without an agent call triggers cleanup within the next minute; watching or human input does not renew a lease. Browser profiles are retained for reuse.

The nested compositor renders to a 2560×1440 headless output. Its Wayland mirror output is disabled before mapping, so no separate desktop windows appear. `HYPRLAND_NO_SD_VARS=1` prevents a nest from replacing the real session environment.

## Optional native MCP registration

The CLI fallback and native tools call the same server. For Codex, export the token in the terminal that will launch Codex, then register the endpoint:

```sh
export HYPR_DESKTOP_TOKEN="$(cat "$HOME/.local/share/hypr-desktop/token")"
codex mcp add hypr-desktop --url "$(cat "$HOME/.local/share/hypr-desktop/local-url")" --bearer-token-env-var HYPR_DESKTOP_TOKEN
codex
```

Repeat the export in new terminals, or add that export to your shell's personal startup configuration. The registration contains the environment variable name; the token stays in its private state file.

For Claude Code, its native HTTP registration accepts a header:

```sh
claude mcp add --scope user --transport http hypr-desktop "$(cat "$HOME/.local/share/hypr-desktop/local-url")" --header "Authorization: Bearer $(cat "$HOME/.local/share/hypr-desktop/token")"
```

Claude stores the supplied header in its user configuration. Keep that file private. Restart the CLI after registration. Other MCP clients can use the same URL and bearer header; their configuration formats vary.

## T3 Code integration

Install and verify the package using the CLI instructions first. T3 uses the agent provider's configuration and skills on the machine running its server. If T3 runs elsewhere, installing this package on your laptop alone does not configure that server. The local-only setup here assumes T3 and Hyprland run under the same user on the same machine.

The shell fallback needs no token environment variable. For Codex's native MCP tools, the T3 server must inherit `HYPR_DESKTOP_TOKEN` when it starts. Export it in the launching shell before starting T3. For a systemd-managed T3 server, generate a private environment file without printing the token:

```sh
(umask 077; printf 'HYPR_DESKTOP_TOKEN=%s\n' "$(cat "$HOME/.local/share/hypr-desktop/token")" > "$HOME/.local/share/hypr-desktop/t3.env")
```

Add `EnvironmentFile=%h/.local/share/hypr-desktop/t3.env` under `[Service]` in a drop-in for your T3 user unit. Restart that unit from a terminal outside the T3 session. Use your actual unit name; do not assume everyone has a `t3code.service`. A desktop-launched T3 app needs the variable in its graphical login environment and a complete app restart.

For T3 installations that set `T3_BOOT_SERVICE_UNIT` and load Bash startup files, this optional line in your own `.bashrc` strips real desktop names from ordinary agent shells:

```sh
[ -n "${T3_BOOT_SERVICE_UNIT:-}" ] && unset WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE
```

Place it before any early return for non-interactive shells. Restart the T3 server after changing its captured shell environment. The MCP still finds the real compositor through systemd's user environment and routes app input into the nested desktop. This opt-in guard is not a sandbox and is not needed for the basic CLI setup.

## Conversation ownership

Chat requires a local T3 installation with paginated orchestration history and the `t3 auth session` CLI. The resolver reads local T3 project/session metadata and matches actual Claude/Codex desktop-claim tool receipts. It never guesses from matching titles or desktop numbers. Ambiguous or unsupported sessions remain viewable with Chat unavailable. Other MCP clients retain desktop tools; their transcript formats are not currently resolved. OpenCode can discover the installed Claude-compatible skill.

The default T3 data location is `~/.t3/userdata/state.sqlite`, with the server at `127.0.0.1:3773`. T3-issued temporary sessions are revoked when the viewer/server closes. Sends preserve the thread's original model and interaction settings. No full-thread search is included.

## Optional fleet viewing

The default installation needs no network gateway or fleet configuration. To connect machines, first expose each machine's existing loopback MCP service through your own authenticated HTTPS/private-network setup. This installer configures no DNS, VPN, firewall, or proxy. Each peer still requires its own bearer token.

On the machine acting as the hub, create `~/.local/share/hypr-desktop/viewer-peers.json`:

```json
[
  {"id":"desktop-a","url":"https://desktop-a.example.com","tokenFile":"desktop-a-token"},
  {"id":"desktop-b","url":"https://desktop-b.example.com","tokenFile":"desktop-b-token"}
]
```

Transfer the existing peer tokens privately into those files, mode 0600. Relative token paths resolve beside `viewer-peers.json`. Choose unique lowercase host IDs; a hub's own ID is its short hostname. Set `HYPR_DESKTOP_HOSTS` to the comma-separated proxy hostnames accepted by each MCP service. Restart only the MCP service from a terminal outside it. Discovery and streams pass through the hub; browser clients never receive peer tokens.

To use a remote hub in the native viewer and its automatic-opening watcher, create `~/.config/agent-desktops/fleet.json`:

```json
{"url":"https://desktop-hub.example.com","tokenFile":"/absolute/path/to/private/hub-token"}
```

Without this file, both use the installed local endpoint and token, including a custom port. Configured remote URLs require HTTPS; plain HTTP is accepted only on localhost or 127.0.0.1. Close and reopen the viewer and restart its watcher after changing this optional configuration. Offline hosts do not rearm automatic opening until their known desktops have ended.

## Optional private web dashboard

The same runtime includes a responsive dashboard with grouped desktops and built-in Markdown chat. It is disabled by default. Enable it only behind your own trusted private gateway by setting `AGENT_DESKTOP_VIEWER_ORIGINS=https://desktops.example.com` and adding that hostname to `HYPR_DESKTOP_HOSTS` in a user service drop-in. Restart the MCP service afterward. The listener remains on loopback.

Anyone allowed through that gateway can watch/control the fleet and continue its verified conversations. The web routes rely on the gateway's access boundary; they have no separate login. Agent and peer routes remain bearer-authenticated. Same-origin writes, signed conversation bindings, sanitized Markdown, and stale-generation checks protect routing inside that boundary. The web dashboard keeps chat beside the selected desktop group on wide screens and uses tabs on phones. Closing a screen preserves its opened chat until dismissed.

## Tests

Run `npm ci --ignore-scripts && npm test` in both `mcp/` and `app/`. Run `python3 -m unittest discover -s test` and `python3 -m unittest discover -s app/test` from this package directory. Tests cover ownership, authenticated HTTP, stream lifetime, responsive layouts, long Markdown history, retries, native navigation, automatic opening, and installer rollback. Installer tests use temporary directories and do not reload the real session. Announce live GUI checks and use only their own claimed desktops.

## Remove

Release your desktops and close the viewer. Disable both managed services:

```sh
systemctl --user disable --now agent-desktops-watch.service hypr-desktop.service
```

Remove the `require("hypr.agent-desktop")` line from `~/.config/hypr/hyprland.lua`, its generated `agent-desktop.lua`, both generated service files, and `~/.local/share/applications/org.omarchy.AgentDesktops.desktop`. Remove the two CLI links and Claude/Codex skill links after checking that they still point into this package. Run `systemctl --user daemon-reload`, `hyprctl reload`, and `hyprctl configerrors`.

Remove optional native MCP registrations, T3 environment overrides, fleet config, or gateway routes you added. Runtime backups, browser profiles, tokens, and the installation manifest remain in their state directories for separate retention or removal.
