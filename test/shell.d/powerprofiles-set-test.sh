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

cat >"$tmp_dir/bin/omarchy-hw-aarch64-apple" <<'EOF'
#!/bin/bash
exit 1
EOF
chmod +x "$tmp_dir/bin/omarchy-hw-aarch64-apple"

cat >"$tmp_dir/bin/omarchy-powerprofiles-apple-cpufreq-apply" <<'EOF'
#!/bin/bash
exit 1
EOF
chmod +x "$tmp_dir/bin/omarchy-powerprofiles-apple-cpufreq-apply"

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

cat >"$tmp_dir/bin/omarchy-hw-aarch64-apple" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$tmp_dir/bin/omarchy-hw-aarch64-apple"

cat >"$tmp_dir/bin/omarchy-powerprofiles-apple-cpufreq-apply" <<'EOF'
#!/bin/bash
printf '%s\n' "$1" >>"$APPLE_APPLY_LOG"
printf '%s\n' "${OMARCHY_POWERPROFILES_STATE_USER:-}" >>"$APPLE_STATE_USER_LOG"
exit 0
EOF
chmod +x "$tmp_dir/bin/omarchy-powerprofiles-apple-cpufreq-apply"

export APPLE_APPLY_LOG="$tmp_dir/apple-apply"
export APPLE_STATE_USER_LOG="$tmp_dir/apple-state-user"
: >"$APPLE_APPLY_LOG"
: >"$APPLE_STATE_USER_LOG"

POWERPROFILES_SET_FAIL=0 "$ROOT/bin/omarchy-powerprofiles-set" ac balanced
[[ $(tail -n 1 "$tmp_dir/calls") == "balanced" ]] || fail "apple path still calls powerprofilesctl"
[[ $(tail -n 1 "$APPLE_APPLY_LOG") == "balanced" ]] || fail "apple path applies caps even when PPD succeeds"
[[ $(tail -n 1 "$APPLE_STATE_USER_LOG") == "$(id -un)" ]] ||
  fail "apple apply receives session user for state"
pass "apple path always applies cpufreq caps and passes state user"
