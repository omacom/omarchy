#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_compositor "Tailscale peer settings runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
mkdir -p "$stage/tailscale" "$stage/bin" "$stage/home"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp "$SHELL_TEST_DIR/fixtures/tailscale-peers/shell.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/panels/tailscale/"{Model.js,TailscaleIcon.qml} "$stage/tailscale/"
node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
const source = root + '/shell/plugins/panels/tailscale/'
let panel = fs.readFileSync(source + 'Panel.qml', 'utf8')
panel = panel.replace('  id: root', '  id: root\n  property alias testService: tailscale')
fs.writeFileSync(stage + '/tailscale/Panel.qml', panel)
// Disable automatic polling in the disposable fixture. Tests feed status into
// the real parser; no daemon, account, routing or file-transfer command runs.
let service = fs.readFileSync(source + 'Service.qml', 'utf8')
service = service.replaceAll('running: true', 'running: false')
fs.writeFileSync(stage + '/tailscale/Service.qml', service)
JS
cat > "$stage/bin/wl-copy" <<'COPY'
#!/bin/bash
value=$(cat)
printf '%s\n' "$value" >> "$TAILSCALE_TEST_COPY_LOG"
COPY
cat > "$stage/bin/omarchy-tailscale-send" <<'SEND'
#!/bin/bash
printf '%s\n' "$@" >> "$TAILSCALE_TEST_SEND_LOG"
SEND
chmod +x "$stage/bin/"*
output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
  TAILSCALE_TEST_COPY_LOG="$stage/copy.log" TAILSCALE_TEST_SEND_LOG="$stage/send.log" \
  timeout 20 quickshell -p "$stage" --no-color 2>&1) || fail "Tailscale peer fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "Tailscale peer runtime assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<< "$output"; then
  fail "Tailscale peer fixture has no QML errors" "$output"
fi
[[ ! -e $stage/send.log ]] || fail "offline send never launches a transfer"
for expected in laptop laptop.tailnet.ts.net 100.64.0.3; do
  rg -qxF "$expected" "$stage/copy.log" || fail "offline copy includes $expected"
done
pass "Tailscale settings, keyboard focus, offline copy, transfer guards and stale-state clearing work in QML"
