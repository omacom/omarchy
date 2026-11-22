# Are we reinventing the wheel?

Checked on 2026-11-22 against live sources (GitHub, PyPI, Home Assistant core and docs, the MCP spec repo, vendor pages). Star counts and versions are as of that date.

## Verdict

**Partly, and we should only build the part nobody has.**

- The **device layer is solved**. Home Assistant (3000+ integrations, Zigbee, Z-Wave, Matter), the OHF Matter Server, Zigbee2MQTT and ESPHome already talk to the hardware. Writing our own radio stacks or device drivers would be reinventing the wheel. We don't: omarchy-fabric consumes HA's WebSocket API and the Matter Server's WebSocket API as backends.
- **Exposing devices to agents over MCP is solved** too: Home Assistant ships an official MCP server, and `homeassistant-ai/ha-mcp` is a mature community one. Our MCP surface is not new in itself.
- **What does not exist is the governance layer** that sits between agents and the physical world, across backends: risk tiers per command, out-of-band approval with *physical presence* as the strongest proof, a tamper-evident audit log for device actions, leases so agents don't fight, "don't fight the human" override detection beyond lights, dry runs against HA and Matter devices, and a desktop (Omarchy) that makes all of it visible. Pieces exist in isolation; nothing combines them, and nothing is device-aware *and* backend-neutral.

So the fabric is a thin broker: **reuse everything below it, build only the policy, approval, audit and arbitration layer, and the Omarchy experience.**

## What exists

### Home Assistant + MCP

- [Official MCP server](https://www.home-assistant.io/integrations/mcp_server/) (since 2025.2). Streamable HTTP at `/api/mcp`, OAuth 2.0 with PKCE (Client ID Metadata Documents), MCP tool annotations. Two tool sets: *Device control* (the former Assist API, only entities exposed to Assist) and, since 2026.11, an admin-only *Home Assistant* set with `call_action` on anything. 2026.11 also added a read-only mode and an Action history tab ([release notes](https://www.home-assistant.io/blog/2026/11/04/release-202611/)). Core pins `mcp==2.3.0`.
- **No confirmation, PIN or blocking for sensitive domains** over Assist, LLM or MCP control. Locks, alarm panels and scripts are not auto-exposed; covers (garage doors, gates) are. Unlocking is `intent__HassTurnOff` calling `lock.unlock` directly ([intent code](https://github.com/home-assistant/core/blob/dev/homeassistant/components/intent/__init__.py)); any confirmation is left to the MCP client. The only PIN gate in HA is in the Google Assistant integration's "secure devices".
- [MCP client integration](https://www.home-assistant.io/integrations/mcp/): HA as the client of other MCP servers. Not overlapping.
- [homeassistant-ai/ha-mcp](https://github.com/homeassistant-ai/ha-mcp), about 8.1k stars, v9.2.0 (2026-11-11). 87 tools for managing and controlling HA. Since v7.6.0 it has **Tool Security Policies**: argument-matching rules that can `require_approval`, an approval queue bound to a hash of the arguments with expiry, approval from its settings UI or over the HA event bus with a PBKDF2-hashed PIN, and elicitation. **This is the closest prior art.** It is HA-only, and has no leases, no human-override detection, no tamper-evident audit and no notion of physical presence.
- Smaller servers: [voska/hass-mcp](https://github.com/voska/hass-mcp) (353 stars, active, no approval layer), [tevonsb/homeassistant-mcp](https://github.com/tevonsb/homeassistant-mcp) (stale), allenporter's (archived; became the core integration).

### Matter

- `python-matter-server` is [archived](https://github.com/matter-js/python-matter-server) (final release 8.1.2, 2025-12-15). Its successor is the **OHF Matter Server on matter.js**, [matter-js/matterjs-server](https://github.com/matter-js/matterjs-server) v1.6.0 (2026-11-14), shipped to HA as "Matter Server app 9.x" and described as a drop-in replacement ([HA blog](https://www.home-assistant.io/blog/2026/06/23/the-matter-upgrade-youve-been-waiting-for/)).
- **Its WebSocket API (`ws://host:5580/ws`: `start_listening`, `device_command`, `read_attribute`, `write_attribute`, `commission_with_code`) is still the supported interface for third-party clients** and is versioned (`schema_version` 15, oldest supported 11), see [websockets_api.md](https://github.com/matter-js/matterjs-server/blob/main/docs/websockets_api.md). That is exactly what our Matter adapter speaks. The API is unauthenticated and binds all interfaces by default, so the node pins it to localhost.
- [matter.js](https://github.com/matter-js/matter.js) (TypeScript stack, v0.18.0), [Matterbridge](https://github.com/Luligu/matterbridge) (exposes non-Matter devices *to* Matter controllers, 3.11.4), [rs-matter](https://github.com/project-chip/rs-matter). Useful later for the reverse direction (publishing fabric things as Matter devices), not needed now.
- MCP servers that talk to Matter directly are small experiments ([0x1abin/matter-controller-mcp](https://github.com/0x1abin/matter-controller-mcp), [MatterCoder/matter-mcp-server](https://github.com/MatterCoder/matter-mcp-server), under 10 stars, idle).
- Spec: **Matter 1.6** (June 2026; NFC commissioning, Joint Fabric, Thermostat Suggestions) with 1.6.1 as a maintenance release. **Matter 1.5** (2025-11) added cameras and a unified **closures** model, including garage doors and gates. Our adapter maps Window Covering today; closures are on the roadmap.

### Governance for agents acting on the physical world

| Project | What it has | What it lacks for us |
|---|---|---|
| [Google Home MCP](https://developers.home.google.com/mcp/home) (early access, 2026-09) | Cloud MCP, blocks sensitive actions such as unlocking, rate limits | Cloud-only, Google devices, unpublished rules |
| [Microsoft Agent Governance Toolkit](https://github.com/microsoft/agent-governance-toolkit) (6.6k stars, v4.1.0) | YAML/OPA/Cedar policies, approvals, Merkle audit log, MCP gateway, kill switch | Knows nothing about devices, tiers, state or people |
| [Device Context Protocol](https://arxiv.org/abs/2605.26159) ([repo](https://github.com/device-context-protocol/dcp)) | Capability scoping, range and unit checks, dry-run mode, optional HMAC | Microcontroller level; no approvals, no HA/Matter |
| [HearthNet](https://arxiv.org/abs/2604.09618) (CAIS '26 demo) | Multiple agents on a home hub coordinated by **actuation leases** | Paper only, no code |
| [Adaptive Lighting](https://github.com/basnijholt/adaptive-lighting) (3.6k stars) | `take_over_control`: stops adjusting a light a person changed | Lights only; built on HA context ids |
| [IoT-MCP](https://arxiv.org/abs/2510.01260), [ROS-MCP](https://github.com/robotmcp/ros-mcp-server) | MCP to microcontrollers and robots | No permission layer (ROS-MCP lists it as wanted) |
| [thingctx](https://github.com/thingctx/thingctx), [wot-mcp](https://github.com/macc-n/wot-mcp) | W3C WoT Thing Descriptions as agent tools, an approval gate | Tiny, no HA/Matter backends |
| [EdgeAgent-Gateway](https://github.com/vovanphuc/EdgeAgent-Gateway), [DoSync](https://github.com/giulianireg-spec/dosync-protocol), [ThingWire](https://github.com/thingwire-dev/thingwire) | The same idea as ours (allowlists, chained audit, arbitration) | 0 to 1 stars, no adoption |

The W3C Web of Things Working Group [rechartered](https://w3.org/blog/2026/web-of-things-working-group-recharter-new-momentum-for-iot-interoperability/) on 2026-09-14 with guidance on how agents "safely sense, and act on the physical world" as a stated aim. That is a standards venue for the ideas in this project.

### Omarchy

- [omacom/omarchy](https://github.com/omacom/omarchy) (github.com/basecamp/omarchy redirects there), 47.4k stars, default branch `quattro`, latest release v4.5.0 (2026-11-05).
- **Ships no smart-home, IoT or MCP features.** Its AI work is launchers for 20+ coding agents, shared skills in `~/.agents/skills`, an agents panel, local models and crash diagnosis. Community add-ons exist for showing HA in the bar ([konradk/hass](https://github.com/konradk/hass)), chatting with HA Assist ([nives-omarchy](https://github.com/hoornet/nives-omarchy)), and MCP for dev boards ([omarchy-hardware](https://github.com/sergiudanstan/omarchy-hardware)), none with governance.
- **ARM is official as of [4.5](https://omarchy.org/news/2026/11/omarchy-4-5/)** (first ARM ISO, Apple Silicon M1–M3). The repo's platform rules name Raspberry Pis under the generic `aarch64` platform, but Pi 4 support landed on 2026-11-17 after the release, and a test file says *"The Pi 5 has another SoC and is untested."* Hence the node runs Raspberry Pi OS for now. Testing Omarchy on a Pi 5 is itself a contribution we can make.

## Gap table

| Capability | Already provided by | Our position |
|---|---|---|
| Device drivers, radios, 3000+ integrations | Home Assistant, Matter Server, Zigbee2MQTT | **Reuse** (HA + Matter adapters) |
| Normalizing HA + Matter into one model | HA's entity model; Matterbridge in the other direction | Thin capability catalog aligned to Matter clusters |
| Exposing devices over MCP | HA `mcp_server`, ha-mcp, Google Home MCP | Ours exists only because policy must sit in front of it |
| Risk-tiered policy per command, with kinds (heater, garage door) | Partial: ha-mcp rules, Google's blocklist, MS AGT (not device-aware) | **Build**: tiers, profiles, bounds, rules |
| Out-of-band human approval | Partial, HA-only: ha-mcp queue with PIN | **Build**: assurance levels up to physical presence |
| Tamper-evident audit of device actions | MS AGT (not device-aware), DoSync (1 star) | **Build**: hash chain + HMAC key on the node |
| Multi-agent leases | HearthNet (paper) | **Build** |
| Human-override detection ("don't fight the human") | Adaptive Lighting (lights only), HA context ids | **Build**, generalized across backends |
| Dry runs against HA and Matter | DCP (microcontrollers), SimuHome (benchmark) | **Build**: `simulate` + a simulated home |
| Omarchy desktop integration | Community bar plugins (display only) | **Build**: bar widget, notifications with actions, menu, hooks, skills |

## What this means for the build

1. **Never give agents HA's MCP server or ha-mcp next to the fabric.** Either one is a direct path to `lock.unlock` that bypasses every policy here. The fabric's HA user should be dedicated, its token should stay on the node, and agents should only ever see the fabric.
2. **Talk to ha-mcp.** Its approval queue and our assurance levels, leases and audit are complementary. A shared approval-request format, or ha-mcp approvals flowing to an Omarchy desktop, is a natural collaboration.
3. **Borrow from MS AGT rather than compete.** Cedar or OPA as an optional policy language and its Merkle audit design are worth adopting where they fit.
4. **Align with standards.** Keep the capability catalog tied to Matter clusters (done) and export W3C WoT Thing Descriptions (roadmap) so tools like thingctx can consume fabric things.
5. **Track MCP 2026-07-28.** The protocol went stateless and replaced server-initiated elicitation with Multi Round-Trip Requests. Our tools are already plain request/response; MRTR is a candidate in-band approval channel for the *lowest* assurance level only, because an agent's own client is not out of band.

## Not verified

- Google Home MCP's full blocked-action list and rate-limit values (only secondary coverage).
- Matter 1.7 contents (still a draft).
- Whether HA's new Action history resists tampering (no claim either way).
- Whether Omarchy runs on a Pi 5 today, and whether the community Pi 5 ports work.
- Whether SimuHome or HearthNet code exists.
