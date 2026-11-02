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
exit 0
EOF
chmod +x "$tmp_dir/bin/omarchy-powerprofiles-apple-cpufreq-apply"

export APPLE_APPLY_LOG="$tmp_dir/apple-apply"
: >"$APPLE_APPLY_LOG"

POWERPROFILES_SET_FAIL=0 "$ROOT/bin/omarchy-powerprofiles-set" ac balanced
[[ $(tail -n 1 "$tmp_dir/calls") == "balanced" ]] || fail "apple path still calls powerprofilesctl"
[[ $(tail -n 1 "$APPLE_APPLY_LOG") == "balanced" ]] || fail "apple path applies caps even when PPD succeeds"
[[ $(<"$tmp_dir/state/apple-cpufreq-active") == "balanced" ]] ||
  fail "apple path records the applied profile in user state"
pass "apple path always applies cpufreq caps and records applied profile"

printf 'power-saver\n' >"$tmp_dir/state/ac"
printf 'performance\n' >"$tmp_dir/state/apple-cpufreq-active"
active=$("$ROOT/bin/omarchy-powerprofiles-list" --active-state | awk -F'\t' '$2 == 1 { print $1; exit }')
[[ $active == "performance" ]] ||
  fail "apple list marks the applied profile, not the saved preference" "active=$active"
pass "apple list reads apple-cpufreq-active for --active-state"

cpufreq_fixture="$tmp_dir/cpufreq"
mkdir -p "$cpufreq_fixture/policy0"
printf '%s\n' 4056000 >"$cpufreq_fixture/policy0/cpuinfo_max_freq"
printf '%s\n' 696000 >"$cpufreq_fixture/policy0/cpuinfo_min_freq"
printf '%s\n' "696000 2424000 3420000 4056000" >"$cpufreq_fixture/policy0/scaling_available_frequencies"
printf '%s\n' 696000 >"$cpufreq_fixture/policy0/scaling_min_freq"
printf '%s\n' 4056000 >"$cpufreq_fixture/policy0/scaling_max_freq"
printf '%s\n' 'apple-cpufreq' >"$tmp_dir/scaling_driver"
apple_lock="$tmp_dir/run-apple-cpufreq.lock"
mkdir -p "${apple_lock%/*}"
touch "$apple_lock"
unshare -Ur env \
  OMARCHY_APPLE_CPUFREQ_SYSFS_ROOT="$cpufreq_fixture" \
  OMARCHY_APPLE_CPUFREQ_DRIVER_FILE="$tmp_dir/scaling_driver" \
  OMARCHY_APPLE_CPUFREQ_LOCK="$apple_lock" \
  "$ROOT/bin/omarchy-powerprofiles-apple-cpufreq-apply" balanced ||
  fail "apple apply could not cap frequencies in a root namespace"
[[ $(<"$cpufreq_fixture/policy0/scaling_max_freq") == "3420000" ]] ||
  fail "apple apply caps scaling_max_freq to the profile step"
pass "apple apply caps scaling_max_freq per profile"

bash -n "$ROOT/bin/omarchy-powerprofiles-apple-cpufreq-apply" ||
  fail "apple-cpufreq apply script has a syntax error"
bash -n "$ROOT/bin/omarchy-powerprofiles-list" ||
  fail "powerprofiles-list script has a syntax error after apple fallback"
[[ -f $ROOT/etc/sudoers.d/omarchy-powerprofiles-apple-cpufreq ]] ||
  fail "apple-cpufreq sudoers drop-in is missing"
pass "apple-cpufreq helper scripts and sudoers drop-in are present"
