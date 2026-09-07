# Agent desktops

Agent desktops let Claude Code, Codex, and other MCP clients work in separate desktop windows. They can open a browser, take screenshots, and send input to their own window while you keep working.

Install the optional package from a terminal:

```sh
omarchy install ai agent-desktop
```

To open agent windows on a specific monitor, use its name from `hyprctl monitors`:

```sh
omarchy install ai agent-desktop --monitor DP-1
```

New desktops do not take focus. Click one to interact with it yourself. Restart your agent CLI after installation, then ask it to use the agent-desktop skill. Desktops open only when claimed and close when released or after 30 minutes without an agent call.

The MCP service runs locally under your user. This separates input and browser profiles; it does not restrict filesystem access or shell commands.

See the [package setup guide](../default/agent-desktop/README.md) for native MCP registration, dependencies, operation, and T3 Code integration.
