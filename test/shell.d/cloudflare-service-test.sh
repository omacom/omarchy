#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null; then
  skip "Cloudflare service runtime needs Quickshell (offscreen; no account needed)"
  exit 0
fi

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/home/.local/bin" "$scratch/runtime" "$scratch/Commons"
chmod 700 "$scratch/runtime"
cp "$ROOT/test/shell.d/fixtures/cloudflare/cf" "$scratch/home/.local/bin/cf"
chmod +x "$scratch/home/.local/bin/cf"
printf '#!/bin/bash\nexit 97\n' >"$scratch/bin/cf"
chmod +x "$scratch/bin/cf"
cp "$ROOT/test/shell.d/fixtures/cloudflare/shell.qml" "$scratch/shell.qml"
cp "$ROOT/shell/plugins/panels/cloudflare/"{Service.qml,Model.js} "$scratch/"
cp "$ROOT/shell/Commons/Util.qml" "$scratch/Commons/"
printf 'singleton Util 1.0 Util.qml\n' >"$scratch/Commons/qmldir"

for scenario in ${CF_TEST_SCENARIOS:-account detail repeat-account repeat-detail signout offline pagination pagination-failure login detail-timeout stubborn-detail errors-query}; do
  : >"$scratch/calls"
  if ! HOME="$scratch/home" XDG_CONFIG_HOME="$scratch/home/.config" XDG_RUNTIME_DIR="$scratch/runtime" \
    QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software PATH="$scratch/bin:$PATH" \
    CF_TEST_SCENARIO="$scenario" CF_TEST_CALLS="$scratch/calls" FORCE_COLOR=1 \
    timeout 15 quickshell -n -p "$scratch/shell.qml" >"$scratch/$scenario.log" 2>&1; then
    cat "$scratch/$scenario.log"
    fail "Cloudflare $scenario runtime regression"
  fi
  cat "$scratch/$scenario.log"
  if grep -qE "not ok -|Error:|Unable to assign|Cannot assign" "$scratch/$scenario.log"; then
    fail "Cloudflare $scenario assertions or QML errors"
  fi
  if [[ $scenario == "login" ]]; then
    [[ $(grep -c '\["auth", "login"\]' "$scratch/calls") == 1 ]] || fail "repeated login starts only one CLI process"
  fi
  pass "Cloudflare $scenario runtime regression"
done
