# Agent desktop

Give an agent its own desktop window for browser and GUI work. It can inspect screenshots, click, type, and launch apps without directing that input at your current window. Desktops open on demand without taking initial focus. Click a desktop window when you want to interact with it yourself.

This package includes the Hyprland launcher, nested compositor configuration, authenticated Model Context Protocol (MCP) server, CLI helper, and agent skill. It requires a graphical Hyprland session with Lua configuration, systemd user services, Node.js 20 or later, npm, Python 3, jq, grim, wtype, wlrctl, Xwayland, and notify-send. Tested on Hyprland 0.56.2.

## Install for agent CLIs

On Omarchy with this integration installed:

```sh
omarchy install ai agent-desktop
```

To select a monitor, find its output name with `hyprctl monitors`, then:

```sh
omarchy install ai agent-desktop --monitor DP-1
```

Without `--monitor`, normal window placement applies, with initial focus disabled. The generated rule matches aquamarine windows before the launcher adds their agent tags. You can still click, resize and move them. The rule also applies to other nested compositors using the same aquamarine class and title.

From a standalone checkout, install the dependencies above and run `python3 install.py` from this package directory. Run it as your normal user, not root. `--port 7873` selects the authenticated loopback endpoint. `--no-start` writes setup files but leaves the service and compositor unchanged; it is useful for staging, not a completed running installation.

The installer copies the package into `~/.local/share/agent-desktop/package`, installs locked npm dependencies there, and adds:

- `~/.local/bin/agent-desktop` as the CLI helper.
- `~/.codex/skills/agent-desktop` and `~/.claude/skills/agent-desktop` as skill links.
- `~/.config/hypr/agent-desktop.lua`, loaded by one added `require` in `hyprland.lua`.
- `hypr-desktop.service`, enabled for your graphical session.
- A private random token and endpoint files in `~/.local/share/hypr-desktop`.

Existing foreign installations and modified generated files are refused rather than overwritten. Release active desktops before updating. Previous runtime copies are retained after a successful update.

Restart Claude Code or Codex from your terminal. Ask it to use the agent-desktop skill to open a browser. The skill works immediately through the CLI helper; native MCP registration is optional.

```sh
agent-desktop tool status '{}'
journalctl --user -u hypr-desktop
```

The service listens only on `127.0.0.1`. This setup does not expose a network endpoint or require Tailscale. Possession of its token allows executing commands as your user. It is input and profile separation, not a filesystem or security sandbox.

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

## Operation

An agent claims a desktop and receives a handle. All later calls use that handle. Release stops its compositor and managed apps. Thirty minutes without an agent call triggers cleanup within the next minute, even if you have been clicking inside the window. Browser profiles remain available for reuse.

The actual rendering output is a 2560×1440 headless output. The visible window mirrors it, allowing captures to continue while the window is hidden. Each nest sets `HYPRLAND_NO_SD_VARS=1` so it cannot replace the graphical session's environment in systemd.

## Tests

```sh
cd mcp
npm ci --ignore-scripts
npm test
```

Installer tests run with `python3 -m unittest discover -s test` from this package directory. They use temporary home directories and do not reload your real session. Live GUI checks must be announced and use their own claimed desktop; never stop another agent's desktop to run a test.

## Remove the integration

Release your agent desktops first. Disable the service with `systemctl --user disable --now hypr-desktop.service`. Remove the `require("hypr.agent-desktop")` line added to `~/.config/hypr/hyprland.lua`, then remove the generated `~/.config/hypr/agent-desktop.lua` and `~/.config/systemd/user/hypr-desktop.service` files. Remove the three installed symlinks listed above after checking that they still point into `~/.local/share/agent-desktop/package`.

Run `systemctl --user daemon-reload`, `hyprctl reload`, and `hyprctl configerrors`. If you added native MCP registration, remove it with `codex mcp remove hypr-desktop` or `claude mcp remove --scope user hypr-desktop`. Remove any optional T3 environment drop-in or shell export you added. The runtime, browser profiles, token, and installation manifest remain in their state directories so they can be restored or removed separately.
