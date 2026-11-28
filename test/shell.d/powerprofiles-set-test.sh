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
elif [[ $1 == "get" ]]; then
  # Each call reports the next profile in the queue
  head -n 1 "$POWERPROFILES_QUEUE"
  sed -i 1d "$POWERPROFILES_QUEUE"
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

cat >"$tmp_dir/bin/loginctl" <<'EOF'
#!/bin/bash

echo "1000 dhh no active"
EOF
cat >"$tmp_dir/bin/pgrep" <<'EOF'
#!/bin/bash

[[ $* == "-U 1000" ]] && echo 4242
EOF
cat >"$tmp_dir/bin/uclampset" <<'EOF'
#!/bin/bash

echo "$*" >>"$UCLAMP_LOG"
EOF
# The first line, the monitor's own name, and an argument line must not
# re-apply; the profile change and the login must
cat >"$tmp_dir/bin/dbus-monitor" <<'EOF'
#!/bin/bash

echo "signal time=1 sender=org.freedesktop.DBus -> destination=:1.9 path=/org/freedesktop/DBus; interface=org.freedesktop.DBus; member=NameAcquired"
echo '   string ":1.9"'
echo "signal time=2 sender=:1.5 -> destination=(null destination) path=/org/freedesktop/UPower/PowerProfiles; interface=org.freedesktop.DBus.Properties; member=PropertiesChanged"
echo '      string "ActiveProfile"'
echo "signal time=3 sender=:1.6 -> destination=(null destination) path=/org/freedesktop/login1; interface=org.freedesktop.login1.Manager; member=SessionNew"
EOF
chmod +x "$tmp_dir/bin/loginctl" "$tmp_dir/bin/pgrep" "$tmp_dir/bin/uclampset" "$tmp_dir/bin/dbus-monitor"

export POWERPROFILES_QUEUE="$tmp_dir/profiles" UCLAMP_LOG="$tmp_dir/uclamp"
printf '%s\n' balanced performance power-saver >"$POWERPROFILES_QUEUE"
# The mock monitor's stream ends, which must fail so the service restarts it
if "$ROOT/bin/omarchy-powerprofiles-floor" monitor 2>/dev/null; then
  fail "power profile floor fails when its D-Bus monitor stops"
fi
expected=$'-m 768 -a -p 4242\n-m 1024 -a -p 4242\n-m 0 -a -p 4242'
[[ $(<"$UCLAMP_LOG") == "$expected" ]] ||
  fail "power profile floor follows the profile once listening, on profile changes and logins" "$(<"$UCLAMP_LOG")"
pass "power profile floor follows the profile once listening, on profile changes and logins"

cat >"$tmp_dir/bin/omarchy-hw-aarch64-apple" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$tmp_dir/bin/omarchy-hw-aarch64-apple"

export OMARCHY_APPLE_CPUFREQ_STATE_DIR="$tmp_dir/apple-run"

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
[[ ! -e $tmp_dir/state/apple-cpufreq-active ]] ||
  fail "apple path leaves the machine-wide applied profile to the root helper, not user state"
pass "apple path always applies cpufreq caps through the root helper"

# The applied profile is a root-written record every session reads, wherever its
# own state directory is
mkdir -p "$OMARCHY_APPLE_CPUFREQ_STATE_DIR"
printf 'power-saver\n' >"$tmp_dir/state/ac"
printf 'performance\n' >"$OMARCHY_APPLE_CPUFREQ_STATE_DIR/powerprofiles-apple-cpufreq-active"
for state in "$tmp_dir/state" "$tmp_dir/another-user-state"; do
  active=""
  while IFS=$'\t' read -r name is_active; do
    [[ $is_active == 1 ]] || continue
    active=$name
    break
  done < <(OMARCHY_POWERPROFILES_STATE_DIR="$state" "$ROOT/bin/omarchy-powerprofiles-list" --active-state)
  [[ $active == "performance" ]] ||
    fail "apple list marks the applied profile for every session, not the saved preference" "state=$state active=$active"
done
pass "apple list reads the shared applied-profile record for --active-state"

cpufreq_fixture="$tmp_dir/cpufreq"
mkdir -p "$cpufreq_fixture/policy0"
printf '%s\n' 4056000 >"$cpufreq_fixture/policy0/cpuinfo_max_freq"
printf '%s\n' 696000 >"$cpufreq_fixture/policy0/cpuinfo_min_freq"
printf '%s\n' "696000 2424000 3420000 4056000" >"$cpufreq_fixture/policy0/scaling_available_frequencies"
printf '%s\n' 696000 >"$cpufreq_fixture/policy0/scaling_min_freq"
printf '%s\n' 4056000 >"$cpufreq_fixture/policy0/scaling_max_freq"
printf '%s\n' 'apple-cpufreq' >"$tmp_dir/scaling_driver"
if unshare --user --map-root-user true 2>/dev/null; then
  helper_state="$tmp_dir/helper-run"
  run_apple_apply() {
    unshare -Ur env \
      OMARCHY_APPLE_CPUFREQ_SYSFS_ROOT="$cpufreq_fixture" \
      OMARCHY_APPLE_CPUFREQ_DRIVER_FILE="$tmp_dir/scaling_driver" \
      OMARCHY_APPLE_CPUFREQ_STATE_DIR="$helper_state" \
      "$ROOT/bin/omarchy-powerprofiles-apple-cpufreq-apply" "$1"
  }

  run_apple_apply balanced ||
    fail "apple apply could not cap frequencies in a root namespace"
  [[ $(<"$cpufreq_fixture/policy0/scaling_max_freq") == "3420000" ]] ||
    fail "apple apply caps scaling_max_freq to the profile step"
  pass "apple apply caps scaling_max_freq per profile"

  [[ $(<"$helper_state/powerprofiles-apple-cpufreq-active") == "balanced" ]] ||
    fail "apple apply records the applied profile"
  run_apple_apply power-saver || fail "apple apply could not switch profiles again"
  [[ $(<"$helper_state/powerprofiles-apple-cpufreq-active") == "power-saver" ]] ||
    fail "apple apply replaces the applied-profile record on each change"
  [[ $(stat -c %a "$helper_state/powerprofiles-apple-cpufreq-active") == "644" ]] ||
    fail "applied-profile record is readable by every session and writable only by root"
  [[ $(find "$helper_state" -name '.apple-cpufreq-active.*' | wc -l) == 0 ]] ||
    fail "apple apply leaves no temporary record behind"
  pass "apple apply records the applied profile where every session can read it"

  # Any local account being able to hold this lock would stall every profile change
  [[ $(stat -c %a "$helper_state/powerprofiles-apple-cpufreq.lock") == "600" ]] ||
    fail "apple apply lock is not restricted to root"
  chmod 0666 "$helper_state/powerprofiles-apple-cpufreq.lock"
  run_apple_apply balanced || fail "apple apply could not reuse an existing lock"
  [[ $(stat -c %a "$helper_state/powerprofiles-apple-cpufreq.lock") == "600" ]] ||
    fail "apple apply does not re-restrict a lock that was left open"
  pass "apple apply holds a root-only lock"
else
  pass "apple apply caps scaling_max_freq per profile (skipped: user namespaces unavailable)"
fi

bash -n "$ROOT/bin/omarchy-powerprofiles-apple-cpufreq-apply" ||
  fail "apple-cpufreq apply script has a syntax error"
bash -n "$ROOT/bin/omarchy-powerprofiles-list" ||
  fail "powerprofiles-list script has a syntax error after apple fallback"
[[ -f $ROOT/etc/sudoers.d/omarchy-powerprofiles-apple-cpufreq ]] ||
  fail "apple-cpufreq sudoers drop-in is missing"
pass "apple-cpufreq helper scripts and sudoers drop-in are present"
