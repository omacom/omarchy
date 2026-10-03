#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
mkdir -p "$tmp_dir/state"
cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  exit 0
fi
exit 1
STUB
chmod +x "$tmp_dir/bin/upower"

# Fake busctl backed by files so get/set round-trips without D-Bus.
cat >"$tmp_dir/bin/busctl" <<'STUB'
#!/bin/bash
state_dir="${BUSCTL_STATE_DIR:-/tmp/busctl-state}"
mkdir -p "$state_dir"
[[ -f $state_dir/supported ]] || printf 'true' >"$state_dir/supported"
[[ -f $state_dir/enabled ]] || printf 'true' >"$state_dir/enabled"
if [[ $1 == "get-property" ]]; then
  prop="$5"
  case "$prop" in
    ChargeThresholdSupported) printf 'b %s\n' "$(cat "$state_dir/supported")" ;;
    ChargeThresholdEnabled) printf 'b %s\n' "$(cat "$state_dir/enabled")" ;;
    ChargeStartThreshold) printf 'u 75\n' ;;
    ChargeEndThreshold) printf 'u 80\n' ;;
    *) exit 1 ;;
  esac
  exit 0
fi
if [[ $1 == "call" ]]; then
  value="${7:-}"
  [[ $value == "true" || $value == "false" ]] || exit 1
  printf '%s' "$value" >"$state_dir/enabled"
  exit 0
fi
exit 1
STUB
chmod +x "$tmp_dir/bin/busctl"

run() {
  BUSCTL_STATE_DIR="$tmp_dir/state" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-charge-limit" "$@"
}

printf 'true' >"$tmp_dir/state/enabled"
printf 'true' >"$tmp_dir/state/supported"

shell_output=$(run status --shell)
grep -Fx $'enabled\ttrue' <<<"$shell_output" >/dev/null || fail "charge limit reports enabled state" "$shell_output"
grep -Fx $'start\t75' <<<"$shell_output" >/dev/null || fail "charge limit reports start threshold" "$shell_output"
grep -Fx $'end\t80' <<<"$shell_output" >/dev/null || fail "charge limit reports end threshold" "$shell_output"
grep -Fx $'supported\ttrue' <<<"$shell_output" >/dev/null || fail "charge limit reports support" "$shell_output"
pass "charge limit status --shell reports threshold state"

run full >/dev/null
[[ $(cat "$tmp_dir/state/enabled") == "false" ]] || fail "charge limit full disables the threshold"
shell_output=$(run status --shell)
grep -Fx $'enabled\tfalse' <<<"$shell_output" >/dev/null || fail "charge limit reports disabled state" "$shell_output"
pass "charge limit full disables the threshold"

run 80 >/dev/null
[[ $(cat "$tmp_dir/state/enabled") == "true" ]] || fail "charge limit 80 enables the threshold"
pass "charge limit 80 enables the threshold"

run toggle >/dev/null
[[ $(cat "$tmp_dir/state/enabled") == "false" ]] || fail "charge limit toggle flips enabled to disabled"
run toggle >/dev/null
[[ $(cat "$tmp_dir/state/enabled") == "true" ]] || fail "charge limit toggle flips disabled to enabled"
pass "charge limit toggle flips the threshold"

printf 'false' >"$tmp_dir/state/supported"
if run status --shell >/dev/null 2>&1; then
  fail "charge limit reports unknown without a capable battery"
fi
pass "charge limit exits non-zero without a capable battery"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/power/Panel.qml', 'utf8')

assert(/property bool chargeLimitEnabled/.test(panelSource), 'power tracks the charge-limit state')
assert(/omarchy-battery-charge-limit", "status", "--shell"/.test(panelSource), 'power refreshes the charge limit from the helper')
assert(/omarchy-battery-charge-limit", enabled \? "80" : "full"/.test(panelSource), 'power sets the charge limit through the helper')
assert(/visible: root\.chargeLimitSupported/.test(panelSource), 'power hides charge-limit controls without hardware support')
assert(/label: "Limit charge to " \+ root\.chargeLimitEnd/.test(panelSource), 'power labels the charge-limit toggle with the threshold')
JS
