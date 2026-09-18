# Agent desktops

Agent desktops let Claude Code, Codex, and other MCP clients open browsers, take screenshots, and work in the background while you keep using your desktop.

```sh
omarchy install ai agent-desktop
```

Restart your agent CLI and ask it to use the agent-desktop skill. The first active desktop opens **Agent Desktops**, a borderless native viewer with up to eight screens per page. Closing it leaves agents running. Open it from the app launcher whenever you want to watch. With no sessions, it displays **No active desktops**.

Each screen keeps its session name, project favicon, host, status, and **Chat** button at the bottom. **Take control** lets you interact; **Escape** returns to watch mode. Related desktops share a colored border. With supported T3 sessions, Chat opens that conversation beside all of its desktops. Markdown history loads recent messages first, with older messages available on demand. Replies continue the same agent, even after its desktop closes.

Use `--monitor DP-1` during installation to place the overview on a chosen monitor. Disable automatic opening with `systemctl --user disable --now agent-desktops-watch.service`. Desktops close when their agent releases them or after 30 minutes without an agent call. Watching does not renew this timer. Open desktops block idle sleep and normal suspend.

The default setup runs locally and needs no T3 or network gateway. Optional fleet configuration connects other machines; an optional private web dashboard includes built-in Markdown chat. Desktop isolation separates input and browser profiles, not filesystem access or shell commands.

See the [package guide](../default/agent-desktop/README.md) for dependencies, MCP registration, T3 support, fleet setup, and removal.
