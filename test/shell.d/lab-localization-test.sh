#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
run_node_test <<'JS'
const fs = require('fs')
const native = fs.existsSync(path.join(root, 'shell/plugins/panels/lab/Model.js'))
const prefix = native ? 'shell/plugins/panels/lab/' : ''
const Model = requireFromRoot(prefix + 'Model.js')
const english = requireFromRoot('default/lab-vm/en.json')
const translated = {...english, 'lab.guestRunningDisplay': 'Pantalla %1', 'lab.healthSummary': '%4 fallos / %3 / %2 / %1'}
let catalog = english
const tr = (key, fallback) => catalog[key] || fallback
const status = Model.parseStatus('{"installed":true,"domainRunning":true,"viewerActive":true,"display":"1920x1080"}')
assertEqual(Model.statusText(status, tr), 'Guest running · 1920x1080', 'model uses the English catalog')
catalog = translated
assertEqual(Model.statusText(status, tr), 'Pantalla 1920x1080', 'the same model state uses a changed translation without reparsing protocol values')
const raw = '{"severity":"ok","domain":{"ip":"192.0.2.1"},"guest":{"failedUnits":["example"],"memory":{"totalBytes":100,"availableBytes":75}}}'
assertEqual(Model.healthText(raw, tr, n => '[' + n + ']'), '[1] fallos / [25]% memory / 192.0.2.1 / OK', 'whole summary templates permit reordered placeholders and localized numbers')
if (native) {
  const shell = requireFromRoot('default/i18n/en/shell.json')
  const cli = requireFromRoot('default/i18n/en/cli.json')
  for (const [key, value] of Object.entries(english)) assertEqual((key.startsWith('labCli.') ? cli : shell)[key], value, 'native and bundled English agree: ' + key)
}
JS
# Exercise the packaged CLI lookup with no global installation or real HOME.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/default/lab-vm" "$test_tmp/home"
cp "$ROOT/bin/omarchy-lab-i18n" "$test_tmp/bin/"
if [[ -f $ROOT/bin/omarchy-lab-runtime ]]; then cp "$ROOT/bin/omarchy-lab-runtime" "$test_tmp/bin/"; fi
cp "$ROOT/default/lab-vm/en.json" "$test_tmp/default/lab-vm/"
printf '{"labCli.sendToLab":"Enviar al laboratorio"}\n' >"$test_tmp/default/lab-vm/es.json"
printf 'es-MX\n' >"$test_tmp/language"
lookup() { HOME="$test_tmp/home" OMARCHY_PATH="$test_tmp" OMARCHY_LANGUAGE_FILE="$test_tmp/language" bash "$test_tmp/bin/omarchy-lab-i18n" "$1"; }
[[ $(lookup labCli.sendToLab) == "Enviar al laboratorio" ]] || fail "regional CLI lookup falls back to its base language"
[[ $(lookup labCli.aspectRatio) == "Lab Aspect Ratio" ]] || fail "missing CLI translations fall back to English"
printf '../../escape\n' >"$test_tmp/language"
[[ $(lookup labCli.sendToLab) == "Send to Omarchy Lab" ]] || fail "malformed language codes use English"
pass "bundled CLI catalogs support regional, English and invalid-code fallbacks"
