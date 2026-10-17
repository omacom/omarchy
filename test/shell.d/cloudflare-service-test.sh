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
# The upgrading wrapper only marks cf as set up; calling it fails the scenario.
printf '#!/bin/bash\nexit 96\n' >"$scratch/home/.local/bin/cf"
chmod +x "$scratch/home/.local/bin/cf"
cp "$ROOT/test/shell.d/fixtures/cloudflare/cf" "$scratch/cf"
chmod +x "$scratch/cf"
printf '#!/bin/bash\nexit 97\n' >"$scratch/bin/cf"
chmod +x "$scratch/bin/cf"
# The panel runs the installed cf through mise offline, so a call can never
# start a download that outlives it. Any other mise call fails the scenario.
cat >"$scratch/bin/mise" <<'EOF'
#!/bin/bash
[[ $# -ge 4 && $1 == "x" && $2 == "npm:cf" && $3 == "--" && $4 == "cf" && ${MISE_OFFLINE:-} == "1" ]] || exit 98
shift 4
exec "$CF_TEST_INSTALLED" "$@"
EOF
chmod +x "$scratch/bin/mise"
cp "$ROOT/test/shell.d/fixtures/cloudflare/shell.qml" "$scratch/shell.qml"
cp "$ROOT/shell/plugins/panels/cloudflare/"{Service.qml,Model.js} "$scratch/"
cp "$ROOT/shell/Commons/"{Util.qml,I18n.qml,Plural.js,Numbers.js} "$scratch/Commons/"
printf 'singleton Util 1.0 Util.qml\nsingleton I18n 1.0 I18n.qml\n' >"$scratch/Commons/qmldir"

for scenario in ${CF_TEST_SCENARIOS:-account detail repeat-account repeat-detail signout offline pagination pagination-failure login login-race detail-timeout stubborn-detail errors-query old-cli}; do
  : >"$scratch/calls"
  rm -f "$scratch/calls.token"
  if ! OMARCHY_PATH="$ROOT" HOME="$scratch/home" XDG_CONFIG_HOME="$scratch/home/.config" XDG_RUNTIME_DIR="$scratch/runtime" \
    QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software PATH="$scratch/bin:$PATH" \
    CF_TEST_SCENARIO="$scenario" CF_TEST_INSTALLED="$scratch/cf" CF_TEST_CALLS="$scratch/calls" FORCE_COLOR=1 \
    timeout 15 quickshell -n -p "$scratch/shell.qml" >"$scratch/$scenario.log" 2>&1; then
    cat "$scratch/$scenario.log"
    fail "Cloudflare $scenario runtime regression"
  fi
  cat "$scratch/$scenario.log"
  if grep -qE "not ok -|Error:|Unable to assign|Cannot assign" "$scratch/$scenario.log"; then
    fail "Cloudflare $scenario assertions or QML errors"
  fi
  if [[ $scenario == "old-cli" ]]; then
    [[ $(grep -c '\["o11y", "telemetry"' "$scratch/calls") == 2 ]] || fail "an older cf is asked for o11y only on the first load"
  elif grep -q '\["observability", "telemetry"' "$scratch/calls"; then
    fail "Cloudflare $scenario asks cf 1.0 for observability"
  fi
  if [[ $scenario == "login" ]]; then
    [[ $(grep -c '\["auth", "login"\]' "$scratch/calls") == 1 ]] || fail "repeated login starts only one CLI process"
  fi
  pass "Cloudflare $scenario runtime regression"
done
