# omarchy-fabric

> This folder is the fabric inside a fork of Omarchy ([dereksgithub/omarchy](https://github.com/dereksgithub/omarchy), branch `fabric/main`). Run everything below from here; the rest of the tree is Omarchy itself.

**The agent-to-physical layer for [Omarchy](https://omarchy.org).** Your coding agents (Claude Code, Codex, pi, OpenCode...) get to use lights, plugs, thermostats, blinds, locks and sensors, through Matter and Home Assistant, without being able to do anything a person wouldn't sign off on.

Agents never talk to devices. Every physical action goes through one pipeline:

```
resolve -> validate -> policy -> (approval) -> execute -> confirm -> audit
```

- **Risk tiers per command**, adjusted by what a device really is: dimming a lamp just happens; switching on a plug waits for a click on your desktop; unlocking the door waits for someone to press a physical button on the Raspberry Pi node.
- **Don't fight the human**: when a person flips a switch, agents leave that device alone for a while. Origins come from Home Assistant's event context, or are inferred for Matter.
- **Leases** so two agents don't fight over the thermostat, **rate limits and a circuit breaker** for looping agents, an **emergency stop** anyone can press and only a person can undo, and **dry runs**.
- A **tamper-evident audit log** of who asked for what, why, who approved it, and what happened.
- **Backward compatible**: Home Assistant (WebSocket API) and Matter (the OHF Matter Server's WebSocket API) are backends. Nothing replaces them.
- **Omarchy-native**: a Quickshell bar widget, approval notifications with Approve / Deny, a menu, a theme hook that paints your lights in the theme accent, and an agent skill.

Why build it: the device layer and "MCP for Home Assistant" already exist; the governance layer between agents and the physical world does not. See [docs/01-prior-art.md](docs/01-prior-art.md).

## Status

Round 1, built and tested on macOS against a simulated home and protocol-level fakes of Home Assistant and the Matter Server: **37 automated tests pass**, and the CLI, the daemon and MCP over stdio were exercised end to end. **Not yet run:** anything on real hardware or on an Omarchy machine (the bar widget, menu and installer are written against Omarchy's docs and source but unverified), and the Pi 5 node.

## Try it in two minutes (simulator)

From this `fabric/` folder:

```bash
uv venv && uv pip install -e ".[dev]"
```

```bash
.venv/bin/ofab serve
```

In another terminal:

```bash
.venv/bin/ofab things
```

```bash
.venv/bin/ofab do sim:living_room.lamp set_level level=40 --reason "reading light"
```

```bash
.venv/bin/ofab do sim:entrance.front_door unlock --reason "courier at the door"
```

```bash
.venv/bin/ofab approvals
```

Then give an agent the fabric:

```bash
claude mcp add fabric -- "$PWD/.venv/bin/ofab" mcp --agent claude-code
```

Without a config file the fabric runs the built-in simulated home and lets the local console approve T3 actions, and says so in `ofab status`. That's fine for a simulator and wrong for a real lock: real locks belong behind the Pi node's button.

## On Omarchy

```bash
omarchy/bin/omarchy-install-fabric
```

This installs `ofab`, a user service, the bar widget, the menu entries, the theme hook and the agent skill, and registers the MCP server with Claude Code and Codex. Pass `--node ssh://fabric-console` to use a Pi node instead of a local simulator. Details: [docs/06-omarchy-integration.md](docs/06-omarchy-integration.md).

## The Pi 5 node

The recommended setup keeps the radios, the approve button, the kill switch and the audit key on a Raspberry Pi 5 running Raspberry Pi OS, with Home Assistant and the Matter Server in containers. Agents reach it only through SSH keys pinned to their identity. See [docs/05-pi5-runbook.md](docs/05-pi5-runbook.md) and the parts list in [docs/03-hardware-list.md](docs/03-hardware-list.md).

## Docs

| | |
|---|---|
| [01 Prior art](docs/01-prior-art.md) | Are we reinventing the wheel? What exists, the gaps, what we reuse |
| [02 Architecture](docs/02-architecture.md) | Pipeline, capabilities, tiers, policy, approvals, origins, audit, transports, compatibility, threat model, roadmap |
| [03 Hardware list](docs/03-hardware-list.md) | What to buy, in phases, and what each part unlocks |
| [04 Scenarios](docs/04-scenarios.md) | The automated and hardware test scenarios |
| [05 Pi 5 runbook](docs/05-pi5-runbook.md) | Bringing up the node |
| [06 Omarchy integration](docs/06-omarchy-integration.md) | What plugs in where, and the plan for contributing back |

## Layout

```
src/omarchy_fabric/   the fabric: model, catalog, policy, approvals, audit, registry, adapters, rpc, mcp, cli
tests/                scenario, compatibility and transport tests (pytest -k S05)
omarchy/              Omarchy glue: installer, bar plugin, menu, theme hook, skill, user services
deploy/pi5/           node config, bootstrap, compose (HA + Matter Server), systemd unit, SSH key template
examples/             configs: laptop simulator, desktop console
../                   the rest of the fork: Omarchy itself
```

## Tests

```bash
.venv/bin/python -m pytest -q
```

## License

MIT, like Omarchy.
