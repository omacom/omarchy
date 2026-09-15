#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
REAL_GIT=$(command -v git)
export REAL_GIT
export SOURCE_FIXTURE="$scratch/upstream"
export TEST_LOG="$scratch/calls"
export TEST_HOME="$scratch/home with spaces"
export OMARCHY_PATH="$scratch/distro"
mkdir -p "$SOURCE_FIXTURE/scripts" "$scratch/bin" "$TEST_HOME" "$OMARCHY_PATH/default/netclaw" "$OMARCHY_PATH/applications"
mkdir -p "$OMARCHY_PATH/bin"
cp "$ROOT/bin/omarchy-netclaw-setup" "$OMARCHY_PATH/bin/"
cp "$ROOT/default/netclaw/runtime.sh" "$ROOT/default/netclaw/testbed.yaml" "$OMARCHY_PATH/default/netclaw/"
cp "$ROOT/default/netclaw/component-launcher.py" "$OMARCHY_PATH/default/netclaw/"
cp "$ROOT/default/netclaw/pyats-stdio.py" "$OMARCHY_PATH/default/netclaw/"
cp "$ROOT/default/netclaw/mcp-call.py" "$OMARCHY_PATH/default/netclaw/"
cp "$ROOT/default/netclaw/workspace-compat.py" "$OMARCHY_PATH/default/netclaw/"
cp "$ROOT/default/netclaw/markmap-launcher.mjs" "$ROOT/default/netclaw/markmap-document.mjs" "$OMARCHY_PATH/default/netclaw/"
mkdir -p "$OMARCHY_PATH/applications/icons"
cp "$ROOT/applications/icons/netclaw.png" "$OMARCHY_PATH/applications/icons/"
cp "$ROOT/applications/NetClaw.desktop" "$OMARCHY_PATH/applications/"
cat > "$SOURCE_FIXTURE/scripts/install.sh" <<'STUB'
NETCLAW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ ${REPO_ROOT:-} == "$NETCLAW_DIR" ]] || exit 1
printf 'installer:%s\n' "$*" >> "$TEST_LOG"
[[ ${TEST_INSTALL_SKIP:-0} != "1" ]] || exit 0
mkdir -p "$HOME/.openclaw/workspace" "$HOME/.local/bin"
printf 'NetClaw persona\n' > "$HOME/.openclaw/workspace/SOUL.md"
printf 'pyats\ngait\ndocument\n' > "$HOME/.openclaw/netclaw-components.conf"
if [[ ${TEST_NETBOX:-0} == "1" ]]; then printf 'netbox\n' >> "$HOME/.openclaw/netclaw-components.conf"; fi
if [[ ${TEST_SNOW:-0} == "1" ]]; then printf 'servicenow\n' >> "$HOME/.openclaw/netclaw-components.conf"; fi
if [[ ${TEST_MARKMAP:-0} == "1" ]]; then
  printf 'markmap\n' >> "$HOME/.openclaw/netclaw-components.conf"
  mkdir -p "$NETCLAW_DIR/mcp-servers/markmap_mcp/markmap-mcp/dist"
  touch "$NETCLAW_DIR/mcp-servers/markmap_mcp/markmap-mcp/dist/index.js"
fi
touch "$HOME/.openclaw/.env"
ln -sf "$NETCLAW_DIR/scripts/netclaw" "$HOME/.local/bin/netclaw"
PROBLEM_COMPONENTS=${TEST_COMPONENT_FAILURE:-}
STUB
printf '#!/bin/bash\nexit 0\n' > "$SOURCE_FIXTURE/scripts/netclaw"
chmod +x "$SOURCE_FIXTURE/scripts/netclaw"
printf 'Detailed tool reference\n' > "$SOURCE_FIXTURE/TOOLS-REFERENCE.md"
"$REAL_GIT" -C "$SOURCE_FIXTURE" init -q
"$REAL_GIT" -C "$SOURCE_FIXTURE" add .
"$REAL_GIT" -C "$SOURCE_FIXTURE" -c user.name=Test -c user.email=test@example.com commit -qm fixture
"$REAL_GIT" -C "$SOURCE_FIXTURE" rev-parse HEAD > "$OMARCHY_PATH/default/netclaw/revision"
cat > "$scratch/bin/git" <<'STUB'
#!/bin/bash
if [[ ${3:-} == "fetch" ]]; then
  [[ ${TEST_FETCH_FAILURE:-0} != "1" ]] || exit 1
  exec "$REAL_GIT" "$1" "$2" fetch --depth 1 "$SOURCE_FIXTURE" "${@: -1}"
fi
exec "$REAL_GIT" "$@"
STUB
cat > "$scratch/bin/omarchy-openclaw-onboard" <<'STUB'
#!/bin/bash
[[ ${TEST_ONBOARD_SKIP:-0} != "1" ]] || exit 0
mkdir -p "$HOME/.openclaw"
printf '{"existing":true}\n' > "$HOME/.openclaw/openclaw.json"
STUB
cat > "$scratch/bin/uv" <<'STUB'
#!/bin/bash
printf 'uv:%s\n' "$*" >> "$TEST_LOG"
if [[ $1 == "venv" ]]; then
  mkdir -p "${@: -1}/bin"
  ln -s /usr/bin/python3 "${@: -1}/bin/python3"
fi
STUB
for command in omarchy-pkg-add systemctl openclaw omarchy-launch-openclaw omarchy-launch-terminal omarchy-launch-tui; do
  cat > "$scratch/bin/$command" <<'STUB'
#!/bin/bash
printf '%s:%s\n' "${0##*/}" "$*" >> "$TEST_LOG"
if [[ ${0##*/} == "openclaw" && ${1:-} == "config" && ${2:-} == "get" ]]; then
  exit 1
fi
STUB
done
# On macOS no flock binary ships; the integration itself targets Linux. The
# portable fixture stubs locking, while exercising real filesystem and git work.
if ! command -v flock >/dev/null; then
  printf '#!/bin/bash\nexit 0\n' > "$scratch/bin/flock"
fi
chmod +x "$scratch/bin/"*
export PATH="$scratch/bin:$TEST_HOME/.local/bin:$ROOT/bin:$PATH"
run() { env HOME="$TEST_HOME" bash "$ROOT/bin/$1" "${@:2}"; }
state="$TEST_HOME/.local/state/omarchy/netclaw"
source_dir="$TEST_HOME/.local/share/omarchy/netclaw"

if TEST_FETCH_FAILURE=1 run omarchy-netclaw-prepare >/dev/null 2>&1; then fail 'failed fetch propagates'; fi
[[ ! -e $source_dir ]] || fail 'failed fetch leaves no partial checkout'
pass 'failed provisioning is retryable'
run omarchy-netclaw-prepare >/dev/null 2>&1
[[ -f $source_dir/scripts/install.sh ]] || fail 'source is provisioned'
[[ -f $TEST_HOME/.local/share/applications/NetClaw.desktop ]] || fail 'desktop entry is installed'
[[ -f $TEST_HOME/.local/share/icons/hicolor/256x256/apps/netclaw.png ]] || fail 'App Store icon is installed'
printf 'custom desktop\n' > "$TEST_HOME/.local/share/applications/NetClaw.desktop"
run omarchy-netclaw-prepare
[[ $(cat "$TEST_HOME/.local/share/applications/NetClaw.desktop") == "custom desktop" ]] || fail 'custom desktop is preserved'
pass 'provisioning is idempotent and preserves desktop customization'
if run omarchy-netclaw-status >/dev/null 2>&1; then fail 'cold source is not configured'; fi
if TEST_ONBOARD_SKIP=1 run omarchy-netclaw-setup --profile minimal >/dev/null 2>&1; then fail 'skipped onboarding fails setup'; fi
[[ ! -f $state/configured ]] || fail 'skipped onboarding is not marked complete'
pass 'onboarding cancellation leaves setup incomplete'
mkdir -p "$TEST_HOME/.openclaw/workspace"
printf 'original persona\n' > "$TEST_HOME/.openclaw/workspace/SOUL.md"
run omarchy-netclaw-setup
[[ -f $state/configured ]] || fail 'successful setup records completion'
[[ $(cat "$state/configured") == $(cat "$OMARCHY_PATH/default/netclaw/revision") ]] || fail 'completion records revision'
backup_found=false
for backup in "$state"/backup-*/openclaw/workspace/SOUL.md; do
  if [[ $(cat "$backup") == "original persona" ]]; then backup_found=true; fi
done
[[ $backup_found == "true" ]] || fail 'existing persona is backed up'
grep -q 'netclaw-python/bin' "$TEST_HOME/.config/systemd/user/openclaw-gateway.service.d/20-netclaw.conf" || fail 'gateway shares Python environment'
grep -q 'installer:--runtime openclaw --all' "$TEST_LOG" || fail 'first setup selects every upstream component'
[[ -f $TEST_HOME/.openclaw/workspace/TOOLS-REFERENCE.md ]] || fail 'deferred persona references are deployed'
[[ $(readlink "$TEST_HOME/.openclaw/workspace/testbed/testbed.yaml") == "$TEST_HOME/.config/netclaw/testbed.yaml" ]] || fail 'workspace points to private inventory'
grep -q 'PYATS_TESTBED_PATH=' "$TEST_HOME/.openclaw/.env" || fail 'gateway uses private inventory'
grep -q 'DOCUMENT_MCP_CMD=.*netclaw-python/bin/python3.*document-mcp/server.py' "$TEST_HOME/.openclaw/.env" || fail 'document skill receives its managed server command'
grep -q 'PYATS_PYTHON=.*netclaw-pyats-python/bin/python3' "$TEST_HOME/.openclaw/.env" || fail 'Cisco skills use isolated MCP dependencies'
grep -q 'uv:pip check --python .*netclaw-pyats-python/bin/python3' "$TEST_LOG" || fail 'isolated Cisco dependencies are checked'
pass 'setup backs up state, deploys persona references, and configures the shared gateway' 
run omarchy-netclaw-chat --message 'show interface errors'
grep -q 'omarchy-launch-openclaw:--tui --session netclaw --message show interface errors' "$TEST_LOG" || fail 'chat preserves prompt'
run omarchy-netclaw-status >/dev/null
run omarchy-netclaw-update
run omarchy-install-netclaw-cli --check
run omarchy-install-netclaw-cli --now
# Verify the real agent dispatcher can seed a NetClaw conversation.
mkdir -p "$TEST_HOME/.config/omarchy/defaults"
run omarchy-default-agent netclaw
[[ $(cat "$TEST_HOME/.config/omarchy/defaults/agent") == "netclaw" ]] || fail 'default agent chooser stores NetClaw'
grep -q 'omarchy-launch-tui:--app-id=org.omarchy.agent omarchy-netclaw-chat' "$TEST_LOG" || fail 'default agent chooser launches NetClaw' 
run omarchy-agent --inline --prompt 'inspect BGP neighbors'
grep -q 'omarchy-launch-openclaw:--tui --session netclaw --message inspect BGP neighbors' "$TEST_LOG" || fail 'default agent routes prompted NetClaw sessions'
pass 'configured chat, default agent, status, and unchanged updates work'
printf '\n# Adapter-only revision\n' >> "$OMARCHY_PATH/default/netclaw/runtime.sh"
old_integration=$(cat "$state/integration-revision")
run omarchy-netclaw-update
[[ $(cat "$state/integration-revision") != "$old_integration" ]] || fail 'adapter-only update refreshes setup'
[[ $(cat "$state/configured") == $(cat "$OMARCHY_PATH/default/netclaw/revision") ]] || fail 'adapter update preserves upstream pin'
pass 'adapter changes refresh installed components with an unchanged upstream pin'
printf 'new release\n' > "$SOURCE_FIXTURE/release.txt"
"$REAL_GIT" -C "$SOURCE_FIXTURE" add .
"$REAL_GIT" -C "$SOURCE_FIXTURE" -c user.name=Test -c user.email=test@example.com commit -qm update
previous=$(cat "$state/configured")
"$REAL_GIT" -C "$SOURCE_FIXTURE" rev-parse HEAD > "$OMARCHY_PATH/default/netclaw/revision"
run omarchy-netclaw-update
[[ $(cat "$state/previous-revision") == "$previous" ]] || fail 'update records previous revision'
[[ $(cat "$state/configured") == $(cat "$OMARCHY_PATH/default/netclaw/revision") ]] || fail 'update configures the new revision'
grep -q 'installer:--runtime openclaw --add pyats gait' "$TEST_LOG" || fail 'update preserves component selection'
pass 'new distro revision refreshes existing components and records recovery revision' 
TEST_NETBOX=1 TEST_SNOW=1 TEST_MARKMAP=1 run omarchy-netclaw-setup --add 'netbox servicenow markmap' >/dev/null
grep -q 'NETBOX_MCP_SCRIPT=.*netclaw-launchers/netbox.py' "$TEST_HOME/.openclaw/.env" || fail 'NetBox skill uses private component launcher'
grep -q 'uv:pip install --python .*netclaw-netbox-python/bin/python3 .*netbox-mcp-server' "$TEST_LOG" || fail 'NetBox installs its project dependencies'
python3 - "$TEST_HOME" <<'PYTHON'
import json
from pathlib import Path
import subprocess
import sys
home = Path(sys.argv[1])
launchers = home / ".local/share/omarchy/netclaw-launchers"
markmap = json.loads((launchers / "markmap-launcher.json").read_text())
assert markmap["backend"].endswith("markmap_mcp/markmap-mcp/dist/index.js")
assert (launchers / "markmap-document.mjs").is_file()
assert 'MARKMAP_MCP_SCRIPT=' + json.dumps(str(launchers / "markmap-launcher.mjs")) in (home / ".openclaw/.env").read_text()
netbox = json.loads((launchers / "netbox.json").read_text())
assert netbox["args"] == ["-m", "netbox_mcp_server.server"]
assert netbox["python"].endswith("netclaw-netbox-python/bin/python3")
snow = json.loads((launchers / "servicenow.json").read_text())
assert snow["python"].endswith("netclaw-servicenow-python/bin/python3")
assert snow["args"] == ["-m", "servicenow_mcp.cli"]
assert snow["environment"]["TOOL_PACKAGE_CONFIG_PATH"].endswith("servicenow-mcp/config/tool_packages.yaml")
pyats = json.loads((launchers / "pyats.json").read_text())
assert pyats["python"].endswith("netclaw-pyats-python/bin/python3")
assert pyats["args"][1] == str(launchers / "pyats-stdio.py")
assert pyats["args"][2].endswith("/pyATS_MCP/pyats_mcp_server.py")
fake_backend = home / "fake-pyats.py"
# The backend must import its package, not the adjacent generated launcher.
(home / "pyats.py").write_text("PACKAGE_MARKER = 'real package'\n")
fake_backend.write_text("import pyats\nassert pyats.PACKAGE_MARKER == 'real package'\nclass Server:\n    def run(self, *, transport):\n        assert transport == 'stdio'\n        print('stdio ready')\nmcp = Server()\nif __name__ == '__main__':\n    raise RuntimeError('HTTP entry point must not run')\n")
result = subprocess.run([sys.executable, str(launchers / "pyats-stdio.py"), str(fake_backend)], capture_output=True, text=True, timeout=10)
assert result.returncode == 0 and result.stdout.strip() == "stdio ready", result.stderr
# Exercise argument forwarding and the child process's exit status without a
# network backend. Keep fixture paths with spaces to catch shell quoting bugs.
(launchers / "netbox.json").write_text(json.dumps({"python": sys.executable, "args": ["-c", "import sys; assert sys.argv[1:] == ['argument with spaces']; sys.exit(7)"]}))
result = subprocess.run([sys.executable, str(launchers / "netbox.py"), "argument with spaces"])
assert result.returncode == 7
PYTHON
pass 'component launchers isolate dependencies and preserve process semantics'
if TEST_COMPONENT_FAILURE=pyats run omarchy-netclaw-setup --add pyats >/dev/null 2>&1; then fail 'component failure propagates'; fi
[[ ! -f $state/configured ]] || fail 'failed reinstall clears completion'
pass 'upstream component failures cannot masquerade as success'
touch "$state/components-installed"
if TEST_INSTALL_SKIP=1 run omarchy-netclaw-setup --profile minimal >/dev/null 2>&1; then fail 'early upstream exit cannot complete setup'; fi
[[ ! -f $state/configured && ! -f $state/components-installed ]] || fail 'stale installation marker is removed'
pass 'early exit cannot reuse stale completion state'
printf 'local change\n' >> "$source_dir/scripts/install.sh"
if run omarchy-netclaw-update >/dev/null 2>&1; then fail 'update refuses tracked edits'; fi
grep -q 'local change' "$source_dir/scripts/install.sh" || fail 'update preserves tracked edits'
pass 'updates refuse to overwrite local changes'
rm "$TEST_HOME/.local/bin/netclaw"
printf 'foreign command\n' > "$TEST_HOME/.local/bin/netclaw"
if run omarchy-netclaw-setup >/dev/null 2>&1; then fail 'foreign launcher is protected'; fi
[[ $(cat "$TEST_HOME/.local/bin/netclaw") == "foreign command" ]] || fail 'foreign launcher remains intact'
pass 'setup protects foreign NetClaw installations'
if run omarchy-netclaw-service nonsense >/dev/null 2>&1; then fail 'invalid service action fails'; fi
run omarchy-netclaw-service stop
grep -q 'openclaw:gateway stop' "$TEST_LOG" || fail 'service control uses shared gateway'
pass 'gateway controls validate actions'

run_node_test <<'JS'
const fs = require('fs');
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js');
const parsed = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'));
assert(!parsed.some(item => item.id === 'netclaw' || item.id.startsWith('netclaw.')), 'NetClaw does not extend the root menu');
assert(parsed.some(item => item.id === 'apps' && item.provider === 'apps'), 'NetClaw uses the standard Apps provider');
assert(parsed.some(item => item.id === 'setup.default.agent.netclaw'), 'default agent menu includes NetClaw');
JS
