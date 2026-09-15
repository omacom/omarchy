# NetClaw integration

This fork provisions NetClaw as a user-space OS application. It is not a kernel component. Omarchy owns discovery, base dependencies, source provisioning, onboarding entry points, and gateway controls. NetClaw owns its integration catalog, tool installation, skills, platform credential wizard, and federation implementation.

## Installation contract

`install/omarchy-base.packages` includes OpenClaw, Node.js, npm, Python, and uv. `install/user/netclaw.sh` provisions a pinned checkout and the desktop entry without a provider prompt. The migration performs the same work for existing users. A network connection is required to fetch source; failures propagate so provisioning can be retried. The ISO builder and package recipes live outside this repository, so producing an image requires rebuilding the companion packages and ISO from this fork.

`default/netclaw/revision` pins the source commit. The initial integration targets upstream `7599220c0290184d3c9ff31662969abfecbe55f3`. This is a source pin, not a reproducible dependency lock: upstream components may fetch their own current repositories and packages. Update the pin only after checking the upstream installer contract and validating on Arch.

`omarchy-netclaw-prepare` uses a temporary checkout and an atomic rename. Failed fetches do not leave a partial installation at the managed path. It verifies an existing checkout's origin and leaves custom desktop entries alone. It does not implicitly pull upstream main.

`omarchy-netclaw-setup` runs as the user in a terminal. Packages go through `omarchy-pkg-add`. A uv-managed Python 3.12 environment avoids installing Python dependencies into Arch's system interpreter. Both installer PATH and the OpenClaw systemd user-service drop-in point at that environment. NetClaw's pyATS component receives an additional private Python 3.12 environment, selected by the skills' existing `PYATS_PYTHON` override: its current MCP 2 dependency conflicts with the MCP 1 dependency selected by NetBox's FastMCP 2 installer. Setup installs the component's requirements there and checks dependency consistency. OpenClaw remains the single packaged runtime; no parallel npm OpenClaw or second gateway is introduced.

NetBox also receives a private environment, installed from its own project metadata rather than the upstream installer's stale dependency list. Generated launchers select these component interpreters through the existing `PYATS_MCP_SCRIPT` and `NETBOX_MCP_SCRIPT` environment variables, including older skills that do not honor `PYATS_PYTHON`. This keeps execution inside NetClaw's normal skill/MCP flow. The launchers contain paths and module names, not credentials, and forward arguments and process exit status.

The pyATS launcher selects stdio transport without entering the backend's HTTP-only executable path. ServiceNow has a third private environment and receives the absolute path to its upstream tool-package YAML: the wheel omits that file, and without it the server silently exposes no tools. Explicit user environment overrides remain authoritative.

`workspace-compat.py` adds required frontmatter only to deployed skills that lack it, preserving their instruction bodies and the pinned source. It raises discovery and prompt limits to fit the catalog, with room for bundled skills, and raises bootstrap limits to fit the persona. Larger existing limits are preserved. These settings make skills discoverable; missing external dependencies still affect eligibility and operation.

The Markmap adapter retains the upstream MCP tools and parser but replaces JSDOM layout with a self-contained HTML artifact rendered by the real browser. Rendering tools return `saved_path` and `mime_type`, not an HTML blob in the model context. Outputs use new `.html` files within the workspace; existing files and paths outside the workspace are rejected. Libraries are embedded from the installed component, and network-derived labels are stripped of active HTML. The deployed skill documents this output contract. The MCP SDK's ESM module identity matters for this adapter; a regression fixture covers the separate CommonJS/ESM builds.

Setup first uses Omarchy's existing onboarding wrapper, then backs up the shared OpenClaw state and runs upstream's component installer with `--all` by default. `--profile` and `--add` are explicit alternatives. The wrapper checks `PROBLEM_COMPONENTS` because upstream can return zero after component failures. It records the configured revision only after deployment and a successful gateway health check. This confirms setup completion and gateway availability, not credential validity for every MCP server.

Upstream copies its persona over OpenClaw's default workspace, installs skills, links its testbed, and writes runtime environment settings. Existing OpenClaw users are adopting NetClaw in that shared workspace; the backup is essential. Credentials stay in per-user state with a restrictive umask. No credentials are embedded in package files, desktop actions, or this repository.

## Ownership

| Location | Owner / contents |
|---|---|
| `~/.local/share/omarchy/netclaw` | Pinned source plus upstream component checkouts and inventory |
| `~/.local/share/omarchy/netclaw-python` | Private Python and component dependencies |
| `~/.local/state/omarchy/netclaw` | Locks, configured revision, previous revision, private backups |
| `~/.config/netclaw/testbed.yaml` | Private device inventory, retained across source updates |
| `~/.openclaw` | Shared provider config, NetClaw workspace, credentials, logs, gateway state |
| `~/.local/share/omarchy/netclaw-pyats-python` | Private dependencies for NetClaw's Cisco tools, selected by `PYATS_PYTHON` |
| `~/.local/share/omarchy/netclaw-netbox-python` | Private dependencies installed from the NetBox MCP project's metadata |
| `~/.local/share/omarchy/netclaw-servicenow-python` | Private ServiceNow MCP dependencies |
| `~/.local/share/omarchy/netclaw-launchers` | Component launchers and interpreter mappings used by NetClaw skills |
| `~/.local/bin/netclaw` | Upstream launcher symlink; foreign commands are protected before setup |
| `~/.config/systemd/user/openclaw-gateway.service.d/20-netclaw.conf` | Python environment for gateway subprocesses |

The menu reads the shipped JSONC directly. The `.desktop` entry is shipped with applications and copied for existing users during migration. A custom existing desktop entry is preserved. The menu renderer supports application image icons on static submenus, allowing Apps → NetClaw to retain the installed icon and its full action menu. Static entries survive app-provider refresh without duplication. No additional listener is introduced.

`omarchy-netclaw-update` applies the distro pin, refuses tracked modifications, preserves the previous revision, and reruns setup using the existing component selection. Matching upstream and integration revisions are a no-op. An adapter or setup change reruns setup even when the upstream source pin is unchanged, so distro fixes reach existing installations. Updates are explicit because component installation and provider actions can be interactive; unattended `omarchy update -y` does not invoke them.

## Validation

For a reproducible Arch Linux environment, use the [container testing workflow](netclaw-testing.md).

The [test suite results](netclaw-test-results.md) distinguish fixture checks, native runtime checks and actual NetClaw agent results, including external access failures.

Run `bash test/shell.d/netclaw-test.sh`, `bash test/cli`, and the existing menu model tests. The isolated NetClaw tests stub packages, upstream installation, and the gateway; they must never install network tooling or touch real credentials.

Before release, build the companion packages and a fresh ISO, then verify in a disposable Omarchy VM: fresh-user provisioning; existing-user migration; app launcher and Apps menu appearance; first-launch onboarding and cancellation; a Minimal profile installation; gateway restart and login persistence; a real authorized testbed query; credential reconfiguration; update and failure recovery. Capture the menu and app states following `agents/skills/visual-verification.md`. A macOS host cannot establish these Linux runtime results.

## Slow network collection and connector capabilities

The managed `mcp-call.py` delegates the protocol to upstream while allowing 180 seconds for initialization and 1800 seconds for a tool response by default. Single-device pyATS show calls receive a 900-second default deadline. The pyATS stdio adapter supplies 300-second connection and command defaults while preserving explicit testbed overrides. Setup raises the agent turn and exec defaults to at least 3600 and 2100 seconds, preserving larger values. These are ceilings; successful operations return immediately.

The deployed pyATS skill describes upstream `pyats_pcall_show_command` for one command across multiple devices in process-isolated batches. The deployed NetBox skill also corrects an upstream capability mismatch: its current MCP exposes read tools, although NetBox itself supports writes. Explicitly authorized inventory writes can use the supported REST API from NetClaw; evidence must identify that path and verify saved records. No new NetBox mutation MCP tool is claimed by this adapter.

## Credential wizard compatibility

The Omarchy setup and credential commands run the pinned upstream wizard through `default/netclaw/credential-setup.py`. It replaces input evaluation with literal assignment and writes credential values atomically as quoted dotenv data with mode 0600. Unknown upstream helper contracts fail closed. The original upstream checkout remains unchanged. Treat `.env` as dotenv data, not as a shell script to source. Standalone credential editing shares the setup lock and restarts the gateway after successful completion.
