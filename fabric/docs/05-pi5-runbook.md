# Pi 5 runbook

Turning the Raspberry Pi 5 into the fabric node: Home Assistant and the Matter Server in containers, `ofab` as a native service with the approve button and the audit key, and the Omarchy desktop as its console.

## Which OS on the node

**Raspberry Pi OS Lite (64-bit).** The options, and why:

| Option | Verdict |
|---|---|
| Raspberry Pi OS Lite, 64-bit | **Use this.** Best Pi 5 support (RP1 GPIO, PCIe NVMe, firmware updates), and `python3-gpiozero` / `python3-lgpio` packages that match the hardware. |
| Omarchy on the Pi 5 | Not yet. Omarchy 4.5 made ARM official, but the Pi 5 is explicitly untested upstream, and the node should be headless. Trying it is scenario H20 and a contribution in itself. When the planned Omarchy Server edition lands, it is the natural home for the node. |
| Home Assistant OS | The best-supported way to run HA, Thread and Matter, but it can't run the fabric natively with GPIO. Use it on a *second* device if you prefer HAOS, and point the node's adapters at it. |

## 1. Flash and first boot

1. With Raspberry Pi Imager, write Raspberry Pi OS Lite (64-bit). In its settings set the hostname (`pi5`), your user, your SSH public key, and the timezone.
2. Fit the active cooler, use the 27 W supply, and prefer Ethernet.
3. Boot, then from the desktop: `ssh pi5.local`, and `sudo apt update && sudo apt full-upgrade -y && sudo reboot`.

## 2. Docker, for Home Assistant and the Matter Server

Install Docker Engine with the compose plugin following Docker's Debian instructions (docs.docker.com/engine/install/debian/), then add your user to the `docker` group and log in again.

## 3. The fabric node

The fabric lives in the `fabric/` folder of the Omarchy fork; a sparse clone fetches just that folder:

```bash
git clone --depth 1 --filter=blob:none --sparse --branch fabric/main https://github.com/dereksgithub/omarchy ~/omarchy
```

```bash
git -C ~/omarchy sparse-checkout set fabric
```

```bash
sudo ~/omarchy/fabric/deploy/pi5/bootstrap.sh --stack
```

`bootstrap.sh` (safe to re-run) does this:

- installs Python with the Pi OS gpiozero and lgpio packages
- creates the `fabric` user (in the `gpio` group)
- installs `ofab` into a root-owned venv in `/opt/omarchy-fabric`, which the fabric user can run but not change
- writes `/etc/omarchy-fabric/node.toml` and a fresh HMAC audit key
- enables `omarchy-fabric-node.service`
- with `--stack`, starts Home Assistant and the Matter Server from `/opt/fabric-stack/compose.yaml`

The Matter Server listens on `127.0.0.1` only: its WebSocket API has no authentication. If the Pi is on Wi-Fi, set `MATTER_INTERFACE=wlan0` in `/opt/fabric-stack/.env`.

## 4. Home Assistant

1. Open `http://pi5.local:8123` and onboard.
2. Create a user named `omarchy-fabric`. Make it an administrator if you want areas and device names in the fabric (the registry calls need admin); the token never leaves the node either way.
3. Log in as that user, open its profile, create a long-lived access token, and save it:

```bash
sudo tee /etc/omarchy-fabric/ha.token >/dev/null
```

```bash
sudo chown root:fabric /etc/omarchy-fabric/ha.token && sudo chmod 0640 /etc/omarchy-fabric/ha.token
```

4. Add the Matter integration in HA with `ws://localhost:5580/ws`.
5. Do **not** enable HA's own MCP server for your agents, or install ha-mcp for them: either would be a path around the fabric.

## 5. Wire the controls

Approve button on GPIO17 (pin 11) to GND (pin 9); kill switch on GPIO27 (pin 13) to GND (pin 14); status LED on GPIO22 (pin 15) through 330 Ω to GND (pin 20). See [03-hardware-list.md](03-hardware-list.md). While testing, uncomment the simulator adapter in `node.toml` so T3 targets are simulated.

```bash
sudo systemctl restart omarchy-fabric-node && sudo journalctl -u omarchy-fabric-node -f
```

Check it from the Pi:

```bash
sudo -u fabric ofab -c /etc/omarchy-fabric/node.toml status
```

## 6. Connect the Omarchy desktop

On the desktop, one key per identity:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/fabric_console -C fabric-console
```

```bash
ssh-keygen -t ed25519 -f ~/.ssh/fabric_claude -C fabric-claude
```

On the Pi, put each public key in `/home/fabric/.ssh/authorized_keys` behind its forced command (template: `deploy/pi5/authorized_keys.example`). On the desktop, add the `fabric-console` and `fabric-claude` host aliases to `~/.ssh/config` (template in `examples/desktop-console.toml`). Then, from a clone of the same branch on the desktop (the same two clone commands as on the Pi):

```bash
~/omarchy/fabric/omarchy/bin/omarchy-install-fabric --node ssh://fabric-console
```

```bash
claude mcp add --scope user fabric -- ofab mcp --connect ssh://fabric-claude
```

```bash
ofab status
```

## 7. Smoke test

1. In Claude Code: "list the things the fabric knows about".
2. "Unlock the simulated front door, a courier is here." Expect `pending_approval`, a desktop notification that points at the button, and the LED blinking.
3. Press the approve button. Expect `executed`, then `ofab audit tail` showing `presence:gpio:approve`.
4. Work through the hardware scenarios in [04-scenarios.md](04-scenarios.md), starting with H01–H04.

## Troubleshooting

| Symptom | Look at |
|---|---|
| `ha` adapter: "no Home Assistant token" | `/etc/omarchy-fabric/ha.token` exists, owned `root:fabric`, mode 0640; restart the service |
| `ha` adapter: rejected the token | The token belongs to a user that was deleted, or it was pasted with extra text |
| `matter` adapter disconnected | `docker compose -f /opt/fabric-stack/compose.yaml logs matter-server`; is it listening on 127.0.0.1:5580? |
| Buttons do nothing | `groups fabric` includes `gpio`; wiring to the right header pins; `journalctl -u omarchy-fabric-node` for gpiozero errors |
| Desktop: "no fabric daemon" | `ssh fabric-console` should print nothing and wait (the forced RPC bridge); check `~/.ssh/config` aliases |
| Daemon refuses to start: audit key missing | `bootstrap.sh` creates `/etc/omarchy-fabric/audit.key`; the daemon fails closed without it |
