#!/bin/bash

set -e

source "$(dirname "$0")/base-test.sh"

run_node_test "dropbox model helpers" <<'JS'
const dropbox = requireFromRoot('shell/plugins/panels/dropbox/Model.js')

assertEqual(dropbox.fileKind('photo.JPG'), 'image', 'dropbox detects image files')
assertEqual(dropbox.fileKind('clip.webm'), 'video', 'dropbox detects video files')
assertEqual(dropbox.fileKind('report.pdf'), 'document', 'dropbox detects document files')
assertEqual(dropbox.fileKind('archive.zip'), 'misc', 'dropbox falls back to misc files')
assertEqual(dropbox.formatBytes(1530), '1.53 KB', 'dropbox formats small byte counts')
assertEqual(dropbox.formatBytes(2_000_000_000), '2 GB', 'dropbox formats gigabytes')
assertEqual(dropbox.formatPercent(7.25), '7.3%', 'dropbox formats small percentages')
assertEqual(dropbox.usageText(1000, 2000, true), '1 KB of 2 KB', 'dropbox formats known quota usage')
assertEqual(dropbox.usageText(1000, 0, false), '1 KB', 'dropbox formats unknown quota usage')

const parsed = dropbox.parseStatus(JSON.stringify({
  installed: true,
  running: true,
  authenticated: true,
  files: [{ name: 'x.txt' }]
}))
assert(parsed.installed && parsed.running && parsed.authenticated, 'dropbox parses status booleans')
assertEqual(parsed.files.length, 1, 'dropbox preserves file rows')

assertEqual(
  dropbox.fileMeta({ modifiedTs: 1000, folder: 'Docs' }, 1000 * 1000 + 3600 * 1000),
  '1h ago · Docs',
  'dropbox file metadata includes relative time and folder'
)
JS

require_compositor "Dropbox link lifecycle runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
mkdir -p "$stage/dropbox" "$stage/bin" "$stage/home" "$stage/shell/plugins/panels"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
ln -s "$stage/dropbox" "$stage/shell/plugins/panels/dropbox"
cp "$SHELL_TEST_DIR/fixtures/dropbox-link/shell.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/panels/dropbox/"{Model.js,DropboxIcon.qml} "$stage/dropbox/"
node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
// Exercise the real QML and expose private IDs only in the disposable copy.
// Intercept the browser boundary so the fixture cannot open real link pages.
let service = fs.readFileSync(`${root}/shell/plugins/panels/dropbox/Service.qml`, 'utf8')
service = service.replace('  id: root', `  id: root
  property alias testLinkWait: linkWait
  property alias testRefreshTimer: refreshTimer
  property alias testStartupRamp: startupRamp
  property alias testDelayedRefresh: delayedRefresh
  property alias testLoginProcess: loginProcess
  property alias testStatusProcess: statusProcess
  property var testOpenedUrls: []
  function testOpenUrl(url) { testOpenedUrls.push(url) }`)
service = service.replace(/Qt\.openUrlExternally\(/g, 'root.testOpenUrl(')
fs.writeFileSync(`${stage}/dropbox/Service.qml`, service)
let panel = fs.readFileSync(`${root}/shell/plugins/panels/dropbox/Panel.qml`, 'utf8')
panel = panel.replace('  id: root', `  id: root
  property alias testService: dropbox
  property alias testMessage: testStatusMessage
  property alias testKeys: keyCatcher`)
panel = panel.replace('          Text {\n            textFormat: Text.PlainText',
  '          Text {\n            id: testStatusMessage\n            textFormat: Text.PlainText')
fs.writeFileSync(`${stage}/dropbox/Panel.qml`, panel)
JS
cat > "$stage/bin/dropbox-cli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$DROPBOX_TEST_COMMAND_LOG"
if (( $(wc -l < "$DROPBOX_TEST_COMMAND_LOG") == 2 )); then
  echo "https://www.dropbox.com/cli_link_nonce?nonce=fixture"
else
  echo "Dropbox is already running!"
fi
SH
chmod +x "$stage/bin/dropbox-cli"
cat > "$stage/dropbox/status.py" <<'PY'
import json
print(json.dumps({
  "ok": True, "installed": True, "running": False,
  "authenticated": False, "statusText": "Unlinked", "files": []
}))
PY

# Fake HOME, status helper, CLI and browser keep this independent of the host
# account. Preview captures use the same real panel with synthetic state.
output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
  DROPBOX_TEST_ROOT="$stage" DROPBOX_TEST_COMMAND_LOG="$stage/commands.log" \
  timeout 20 quickshell -p "$stage" --no-color 2>&1) || fail "Dropbox link fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "Dropbox link lifecycle assertions pass" "$output"
if [[ $output =~ RESULT\ fail|ReferenceError|TypeError|Error:|Unable\ to\ assign|Binding\ loop ]]; then
  fail "Dropbox link fixture has no QML errors" "$output"
fi
[[ $(<"$stage/commands.log") == $'start\nstart\nstart' ]] ||
  fail "only fresh login attempts run dropbox-cli start"
pass "Dropbox no-URL and URL waits, repeated polling, timeout, late authentication, retry, and panel errors work in QML"
