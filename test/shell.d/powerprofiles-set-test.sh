#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/state"

cat >"$tmp_dir/bin/powerprofilesctl" <<'EOF'
#!/bin/bash

if [[ $1 == "list" ]]; then
  printf '  power-saver:\n* balanced:\n  performance:\n'
elif [[ $1 == "set" ]]; then
  [[ ${POWERPROFILES_SET_FAIL:-0} == "0" ]] || exit 1
  printf '%s\n' "$2" >>"$POWERPROFILES_LOG"
fi
EOF
chmod +x "$tmp_dir/bin/powerprofilesctl"

cat >"$tmp_dir/bin/busctl" <<'EOF'
#!/bin/bash

# BUSCTL_FAIL makes every query fail (UPower unreachable). BUSCTL_FAIL_REMAINING
# points at a file holding a failure counter: while it is positive, fail (UPower
# not ready yet) and decrement it, then answer normally.
[[ ${BUSCTL_FAIL:-0} == "1" ]] && exit 1
# BUSCTL_HANG stands in for a wedged UPower. exec keeps no shell around so the
# per-attempt timeout lands directly on the sleeper.
[[ ${BUSCTL_HANG:-0} == "1" ]] && exec sleep 30
if [[ -n ${BUSCTL_FAIL_REMAINING:-} && -f $BUSCTL_FAIL_REMAINING ]]; then
  remaining=$(<"$BUSCTL_FAIL_REMAINING")
  if (( remaining > 0 )); then
    printf '%d\n' $((remaining - 1)) >"$BUSCTL_FAIL_REMAINING"
    exit 1
  fi
fi

if [[ ${ON_BATTERY:-0} == "1" ]]; then
  echo "b true"
else
  echo "b false"
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

# A failed detection is unknown, not "on AC": it must refuse to set a profile
# rather than fail-open to performance on a machine booting on battery (#12734).
last_before=$(tail -n 1 "$tmp_dir/calls")
if BUSCTL_FAIL=1 "$ROOT/bin/omarchy-powerprofiles-set" autodetect; then
  fail "power profile autodetect fails when detection fails"
fi
[[ $(tail -n 1 "$tmp_dir/calls") == "$last_before" ]] || fail "failed autodetect changes no profile"
pass "power profile autodetect refuses to guess when detection fails"

# A wedged UPower must not stall autodetect: the per-attempt deadline bounds
# the whole retry window.
last_before=$(tail -n 1 "$tmp_dir/calls")
start=$SECONDS
if BUSCTL_HANG=1 "$ROOT/bin/omarchy-powerprofiles-set" autodetect; then
  fail "power profile autodetect fails when detection hangs"
fi
elapsed=$((SECONDS - start))
(( elapsed < 25 )) || fail "hung detection refuses within the retry window (took ${elapsed}s)"
[[ $(tail -n 1 "$tmp_dir/calls") == "$last_before" ]] || fail "hung autodetect changes no profile"
pass "power profile autodetect bounds a hung detection"

# A not-yet-ready UPower recovers within the retry window.
printf '2\n' >"$tmp_dir/busctl-failures"
if ! BUSCTL_FAIL_REMAINING="$tmp_dir/busctl-failures" ON_BATTERY=1 "$ROOT/bin/omarchy-powerprofiles-set" autodetect; then
  fail "power profile autodetect rides out transient detection failures"
fi
[[ $(tail -n 1 "$tmp_dir/calls") == "performance" ]] || fail "power profile autodetect recovers battery preference after retries"
pass "power profile autodetect retries transient detection failures"

rg -F '["omarchy-powerprofiles-set", pendingPowerSource]' "$ROOT/shell/plugins/services/battery/Service.qml" >/dev/null ||
  fail "battery service applies profiles through Omarchy command"
pass "battery service applies profiles through Omarchy command"

rg -F 'omarchy-powerprofiles-set autodetect' "$ROOT/shell/plugins/menu/Menu.qml" >/dev/null ||
  fail "power profile menu persists selections through Omarchy command"
pass "power profile menu persists selections through Omarchy command"
