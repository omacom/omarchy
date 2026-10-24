#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/state"

cat >"$tmp_dir/bin/busctl" <<'EOF'
#!/bin/bash

# Argument-tolerant fake of the D-Bus calls the power scripts make: reads
# Profiles / ActiveProfile / UPower OnBattery, logs set-property targets.
for arg in "$@"; do
  [[ $arg == "-p" ]] && continue
  case "$arg" in
    set-property) op=set ;;
    get-property) op=get ;;
    Profiles) prop=Profiles ;;
    ActiveProfile) prop=ActiveProfile ;;
    OnBattery) prop=OnBattery ;;
    *) last=$arg ;;
  esac
done

if [[ $op == "set" ]]; then
  [[ ${POWERPROFILES_SET_FAIL:-0} == "0" ]] || exit 1
  printf '%s\n' "$last" >>"$POWERPROFILES_LOG"
elif [[ $prop == "Profiles" ]]; then
  printf '%s\n' '{"type":"aa{sv}","data":[{"Profile":{"type":"s","data":"power-saver"}},{"Profile":{"type":"s","data":"balanced"}},{"Profile":{"type":"s","data":"performance"}}]}'
elif [[ $prop == "ActiveProfile" ]]; then
  printf '%s\n' "{\"type\":\"s\",\"data\":\"${ACTIVE_PROFILE:-balanced}\"}"
else
  if [[ ${ON_BATTERY:-0} == "1" ]]; then echo "b true"; else echo "b false"; fi
fi
EOF
chmod +x "$tmp_dir/bin/busctl"

export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"
export POWERPROFILES_LOG="$tmp_dir/calls"
export OMARCHY_POWERPROFILES_STATE_DIR="$tmp_dir/state"

"$ROOT/bin/omarchy-powerprofiles-set" ac balanced
[[ $(<"$tmp_dir/state/ac") == "balanced" ]] || fail "power profile stores AC preference"
[[ $(tail -n 1 "$tmp_dir/calls") == "balanced" ]] || fail "power profile applies selected AC preference"
pass "power profile stores and applies AC preference"

"$ROOT/bin/omarchy-powerprofiles-set" ac
[[ $(tail -n 1 "$tmp_dir/calls") == "balanced" ]] || fail "power profile restores AC preference"
pass "power profile restores AC preference"

if POWERPROFILES_SET_FAIL=1 "$ROOT/bin/omarchy-powerprofiles-set" ac performance; then
  fail "power profile reports a failed selection"
fi
[[ $(<"$tmp_dir/state/ac") == "balanced" ]] || fail "power profile preserves preference after failed selection"
pass "power profile persists only successful selections"

"$ROOT/bin/omarchy-powerprofiles-set" battery performance
[[ $(<"$tmp_dir/state/battery") == "performance" ]] || fail "power profile stores battery preference"
pass "power profile stores battery preference separately"

"$ROOT/bin/omarchy-powerprofiles-set" ac
[[ $(tail -n 1 "$tmp_dir/calls") == "balanced" ]] || fail "battery preference does not replace AC preference"
pass "power profile keeps AC and battery preferences separate"

ON_BATTERY=1 "$ROOT/bin/omarchy-powerprofiles-set"
[[ $(tail -n 1 "$tmp_dir/calls") == "performance" ]] || fail "autodetect restores battery preference"
pass "power profile autodetect restores battery preference"

rm "$tmp_dir/state/ac"
ON_BATTERY=0 "$ROOT/bin/omarchy-powerprofiles-set"
[[ $(tail -n 1 "$tmp_dir/calls") == "performance" ]] || fail "power profile uses performance as AC default"
pass "power profile retains performance as AC default"

"$ROOT/bin/omarchy-powerprofiles-set" ac power-saver
"$ROOT/bin/omarchy-powerprofiles-init"
[[ $(tail -n 1 "$tmp_dir/calls") == "power-saver" ]] || fail "init restores the autodetected preference"
pass "power profile init restores the autodetected preference"

rg -F '["omarchy-powerprofiles-set", pendingPowerSource]' "$ROOT/shell/plugins/services/battery/Service.qml" >/dev/null ||
  fail "battery service applies profiles through Omarchy command"
pass "battery service applies profiles through Omarchy command"

rg -F 'omarchy-powerprofiles-set autodetect' "$ROOT/shell/plugins/menu/Menu.qml" >/dev/null ||
  fail "power profile menu persists selections through Omarchy command"
pass "power profile menu persists selections through Omarchy command"

out="$("$ROOT/bin/omarchy-powerprofiles-list" --active-state)"
[[ $out == $'power-saver\t0\nbalanced\t1\nperformance\t0' ]] || fail "power profiles list reads D-Bus Profiles and marks the active one" "$out"
pass "power profiles list reads D-Bus Profiles and marks the active one"

rg -q 'powerprofilesctl' "$ROOT/bin/omarchy-powerprofiles-list" "$ROOT/bin/omarchy-powerprofiles-set" &&
  fail "power profile scripts no longer call powerprofilesctl"
pass "power profile scripts no longer call powerprofilesctl"
