#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

export OMARCHY_PATH="$ROOT"

SCAN_SCRIPT="$ROOT/shell/services/scan-plugins.sh"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

FP="$TMPDIR/firstparty"
TP="$TMPDIR/thirdparty"
mkdir -p "$FP/panels/bluetooth" "$FP/panels/audio" "$FP/widgets" "$TP/local.weather"

cat > "$FP/panels/bluetooth/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "omarchy.bluetooth",
  "name": "Bluetooth",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "bar-widget": "Panel.qml" }
}
JSON

cat > "$FP/panels/audio/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "omarchy.audio",
  "name": "Audio",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "bar-widget": "Panel.qml" }
}
JSON

cat > "$FP/widgets/Clock.manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "omarchy.clock",
  "name": "Clock",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "bar-widget": "Clock.qml" }
}
JSON

cat > "$TP/local.weather/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "local.weather",
  "name": "Weather",
  "version": "0.1.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "bar-widget": "Panel.qml" }
}
JSON

OUTPUT=$("$SCAN_SCRIPT" "$FP" "$TP")

if [[ -z $OUTPUT ]]; then
  fail "plugin scan produced output"
fi

if ! grep -q "===firstparty::$FP/panels/bluetooth===" <<< "$OUTPUT"; then
  fail "scan emits firstparty bluetooth block"
fi

if ! grep -q '"id": "omarchy.bluetooth"' <<< "$OUTPUT"; then
  fail "scan includes bluetooth manifest content"
fi

if ! grep -q "===firstparty::$FP/widgets===" <<< "$OUTPUT"; then
  fail "scan emits firstparty widget manifest block (Clock.manifest.json)"
fi

if ! grep -qE "===thirdparty::$TP/local.weather/?===" <<< "$OUTPUT"; then
  fail "scan emits thirdparty block"
fi

if ! grep -q "=== EOM ===" <<< "$OUTPUT"; then
  fail "scan terminates manifest blocks with EOM"
fi

# Third-party ids that collide with the omarchy namespace must be ignored by the
# parser, but the scanner itself should still emit them; rejection is a parser concern.
if ! grep -q '"id": "local.weather"' <<< "$OUTPUT"; then
  fail "scan includes third-party manifest content"
fi

# Verify the scanner tolerates missing directories gracefully.
EMPTY_OUTPUT=$("$SCAN_SCRIPT" "$TMPDIR/nonexistent" "$TMPDIR/nonexistent")
if [[ -n $EMPTY_OUTPUT ]]; then
  fail "scan produces no output when both directories are missing"
fi

pass "plugin scan script emits well-formed firstparty and thirdparty blocks"
pass "plugin scan script handles sibling *.manifest.json files"
pass "plugin scan script includes raw manifest JSON between markers"
pass "plugin scan script tolerates missing plugin directories"

run_node_test <<'JS'
const fs = require('fs')

const scanScript = root + '/shell/services/scan-plugins.sh'
assert(fs.existsSync(scanScript), 'plugin scan script exists')
assert((fs.statSync(scanScript).mode & 0o111) !== 0, 'plugin scan script is executable')

const registrySource = fs.readFileSync(root + '/shell/services/PluginRegistry.qml', 'utf8')
assert(
  /scanProcess\.command\s*=\s*\[\s*"bash",\s*registry\.omarchyPath\s*\+\s*"\/shell\/services\/scan-plugins\.sh",\s*registry\.firstPartyDir,\s*registry\.pluginsDir\s*\]/.test(registrySource),
  'PluginRegistry rescan invokes the external scan script'
)
assert(
  /property string omarchyPath: Quickshell\.env\("OMARCHY_PATH"\)/.test(registrySource),
  'PluginRegistry reads OMARCHY_PATH for the scan script'
)

const shellSource = fs.readFileSync(root + '/shell/shell.qml', 'utf8')
assert(
  /pluginRegistry\.omarchyPath = shell\.omarchyPath/.test(shellSource),
  'shell.qml wires the plugin registry OMARCHY_PATH'
)

pass('PluginRegistry uses the external scan script and OMARCHY_PATH')
JS
