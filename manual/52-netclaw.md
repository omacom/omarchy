# NetClaw

NetClaw is the network engineering coworker built into this Omarchy fork. Open **NetClaw** from the application launcher or **Apps → NetClaw → Chat** from the Omarchy menu. The first Chat launch opens setup in a terminal. The NetClaw submenu also provides Dashboard, Setup integrations, Credentials, Upgrade, Status, Logs and gateway controls.

## First launch

1. Sign in to your AI provider in the OpenClaw wizard.
2. Setup selects the full upstream component catalog. Complete any component-specific setup prompts; some integrations require separate services, accounts, hardware, or licenses. For a smaller installation, start explicitly with `omarchy netclaw setup --profile recommended` or `--profile minimal`.
3. Configure credentials for the integrations you selected. You can return through `omarchy netclaw credentials`.
4. Configure your device inventory in `~/.config/netclaw/testbed.yaml`, then start a conversation.

Setup downloads additional tools and may request your sudo password for packages. Provider subscriptions, network accounts, reachable devices, and any vendor licenses are supplied by you. Features become usable as their components and credentials are configured. Selecting a profile does not mean every integration is connected or healthy.

NetClaw uses the same OpenClaw provider, workspace, and gateway as Omarchy's OpenClaw app. Setup deploys NetClaw's persona and skills there. Before each attempt it saves a private copy under `~/.local/state/omarchy/netclaw/backup-*/openclaw`. Keep that backup if you have an existing OpenClaw assistant you may want to restore.

Chat uses the persistent `netclaw` session. Existing OpenClaw `main` conversations remain available; changing the testbed does not rewrite old conversation history. Always use the aliases currently configured in your testbed.

## Work from the desktop or terminal

| Command | Purpose |
|---|---|
| `omarchy netclaw chat` | Open chat; run setup on first use |
| `omarchy netclaw chat --message "Investigate interface errors in my testbed"` | Start with a question |
| `omarchy netclaw dashboard` | Open the gateway's browser dashboard |
| `omarchy netclaw setup --profile recommended` | Install a chosen profile; provider and credential steps remain interactive |
| `omarchy netclaw setup --add "netbox gnmi"` | Add integrations while keeping the existing selection |
| `omarchy netclaw credentials` | Configure platform credentials |
| `omarchy netclaw status` | Check provisioning and gateway health |
| `omarchy netclaw service logs` | Follow gateway logs |
| `omarchy netclaw service restart` | Restart the shared gateway |
| `omarchy netclaw service stop` | Stop it; OpenClaw sessions also disconnect |
| `omarchy netclaw service start` | Start it again |
| `omarchy netclaw update` | Apply the NetClaw revision selected by this distro |

Choose **Setup → Defaults → Agent → NetClaw**, or run `omarchy default agent netclaw`, to use NetClaw from Omarchy's existing agent shortcut and prompt command. Other agent choices remain available.

After installation, upstream's `netclaw` command also exposes its peering and risk menus. Federation, lab infrastructure, local models, and vendor integrations need their own setup; consult the [NetClaw documentation](https://github.com/automateyournetwork/netclaw/tree/main/docs).

## Things to try

- “Compare my interface state against NetBox and show me the discrepancies.”
- “Explain the BGP adjacency failures in my testbed. Gather evidence before proposing a change.”
- “Analyze this packet capture and explain the retransmissions.”
- “Build a lab to test this routing change before applying it.”
- “Correlate telemetry with the incident timeline and draft a change plan.”

Use the relevant components and your own authorized network inventory. ITSM workflows, audit tools, and federation controls have their own configuration; installing the desktop integration does not establish an enforced security boundary for every tool.

## Open a generated mind map

Ask NetClaw to save a Markmap of its findings. The managed Markmap integration returns the path to an interactive `.html` file; open that file in the desktop browser. Scroll to zoom, drag to pan, click a branch circle to collapse or expand it, and use **Fit map** to restore the overview. The file embeds its rendering libraries and can be viewed offline.

The default output folder is `~/.openclaw/workspace/showcase/`. Enter that path in the file manager to find your maps. Ask for a new filename when generating another version; the tool preserves existing files.

## Updates and recovery

Omarchy packages update the desktop integration and its selected NetClaw revision. Run `omarchy netclaw update` to apply that revision and refresh your chosen components. This command leaves tracked local edits alone and reports them instead of overwriting them. Component installers can download their own newer dependencies even when NetClaw's source revision stays fixed.

An incomplete setup can be retried through **Apps → NetClaw → Setup integrations**, or with `omarchy netclaw setup --profile minimal` for Light. Read the reported component logs under `~/.openclaw/logs/install/`. `omarchy netclaw status` checks the gateway; it does not authenticate every network integration.

To restore a previous OpenClaw workspace, stop the shared gateway, move `~/.openclaw` to a recovery location, and copy the desired private `backup-*/openclaw` directory back to `~/.openclaw`. Remove `~/.local/state/omarchy/netclaw/configured` so the launcher does not mistake the restored assistant for a configured NetClaw. The Python path override lives in `~/.config/systemd/user/openclaw-gateway.service.d/20-netclaw.conf`; remove it and run `systemctl --user daemon-reload` if restoring a non-NetClaw setup, then start the gateway.
