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

mkdir -p "$tmp_dir/pstate"
export OMARCHY_INTEL_PSTATE_DIR="$tmp_dir/pstate"
printf 'active\n' >"$tmp_dir/pstate/status"
printf '0\n' >"$tmp_dir/pstate/hwp_dynamic_boost"
printf '0\n' >"$tmp_dir/pstate/energy_efficiency"

printf '%s\n' performance >"$POWERPROFILES_QUEUE"
ON_BATTERY=0 "$ROOT/bin/omarchy-powerprofiles-intel" apply
[[ $(<"$tmp_dir/pstate/hwp_dynamic_boost") == "1" && $(<"$tmp_dir/pstate/energy_efficiency") == "0" ]] ||
  fail "intel pstate enables dynamic boost and disables energy efficiency in performance"

printf '%s\n' balanced >"$POWERPROFILES_QUEUE"
ON_BATTERY=1 "$ROOT/bin/omarchy-powerprofiles-intel" apply
[[ $(<"$tmp_dir/pstate/hwp_dynamic_boost") == "1" && $(<"$tmp_dir/pstate/energy_efficiency") == "1" ]] ||
  fail "intel pstate keeps dynamic boost and enables energy efficiency for balanced on battery"

printf '%s\n' balanced >"$POWERPROFILES_QUEUE"
ON_BATTERY=0 "$ROOT/bin/omarchy-powerprofiles-intel" apply
[[ $(<"$tmp_dir/pstate/hwp_dynamic_boost") == "1" && $(<"$tmp_dir/pstate/energy_efficiency") == "0" ]] ||
  fail "intel pstate disables energy efficiency for balanced on AC"

printf '%s\n' power-saver >"$POWERPROFILES_QUEUE"
ON_BATTERY=0 "$ROOT/bin/omarchy-powerprofiles-intel" apply
[[ $(<"$tmp_dir/pstate/hwp_dynamic_boost") == "0" && $(<"$tmp_dir/pstate/energy_efficiency") == "1" ]] ||
  fail "intel pstate disables dynamic boost and enables energy efficiency in power-saver"
pass "intel pstate maps each power profile and AC/battery state"

"$ROOT/bin/omarchy-powerprofiles-intel" release
[[ $(<"$tmp_dir/pstate/hwp_dynamic_boost") == "0" && $(<"$tmp_dir/pstate/energy_efficiency") == "0" ]] ||
  fail "intel pstate release restores kernel defaults"

printf '%s\n' unknown >"$POWERPROFILES_QUEUE"
"$ROOT/bin/omarchy-powerprofiles-intel" apply
[[ $(<"$tmp_dir/pstate/hwp_dynamic_boost") == "0" && $(<"$tmp_dir/pstate/energy_efficiency") == "0" ]] ||
  fail "intel pstate leaves sysfs untouched for an unknown profile"

printf 'passive\n' >"$tmp_dir/pstate/status"
printf '%s\n' performance >"$POWERPROFILES_QUEUE"
"$ROOT/bin/omarchy-powerprofiles-intel" apply
[[ $(<"$tmp_dir/pstate/hwp_dynamic_boost") == "0" ]] ||
  fail "intel pstate ignores passive mode"

printf 'active\n' >"$tmp_dir/pstate/status"
rm "$tmp_dir/pstate/energy_efficiency"
printf '%s\n' performance >"$POWERPROFILES_QUEUE"
"$ROOT/bin/omarchy-powerprofiles-intel" apply
[[ $(<"$tmp_dir/pstate/hwp_dynamic_boost") == "1" && ! -e $tmp_dir/pstate/energy_efficiency ]] ||
  fail "intel pstate still updates dynamic boost when energy_efficiency is absent"
pass "intel pstate handles release, unknown profiles, passive mode, and missing knobs"

printf '0\n' >"$tmp_dir/pstate/hwp_dynamic_boost"
printf '0\n' >"$tmp_dir/pstate/energy_efficiency"
cat >"$tmp_dir/bin/powerprofilesctl" <<'EOF'
#!/bin/bash

if [[ $1 == "get" ]]; then
  profile=$(head -n 1 "$POWERPROFILES_QUEUE")
  sed -i 1d "$POWERPROFILES_QUEUE"
  printf '%s\n' "$profile" >>"$INTEL_CALL_LOG"
  printf '%s\n' "$profile"
fi
EOF
cat >"$tmp_dir/bin/busctl" <<'EOF'
#!/bin/bash

state=$(head -n 1 "$BATTERY_QUEUE")
sed -i 1d "$BATTERY_QUEUE"
printf 'b %s\n' "$state"
EOF
cat >"$tmp_dir/bin/dbus-monitor" <<'EOF'
#!/bin/bash

echo "signal time=1 sender=org.freedesktop.DBus -> destination=:1.9 path=/org/freedesktop/DBus; interface=org.freedesktop.DBus; member=NameAcquired"
echo '   string ":1.9"'
echo "signal time=2 sender=:1.5 -> destination=(null destination) path=/org/freedesktop/UPower/PowerProfiles; interface=org.freedesktop.DBus.Properties; member=PropertiesChanged"
echo '      string "ActiveProfile"'
echo "signal time=3 sender=:1.6 -> destination=(null destination) path=/org/freedesktop/UPower; interface=org.freedesktop.DBus.Properties; member=PropertiesChanged"
echo '      string "OnBattery"'
echo "signal time=4 sender=:1.7 -> destination=(null destination) path=/org/freedesktop/login1; interface=org.freedesktop.login1.Manager; member=PrepareForSleep"
echo '   boolean true'
echo "signal time=5 sender=:1.7 -> destination=(null destination) path=/org/freedesktop/login1; interface=org.freedesktop.login1.Manager; member=PrepareForSleep"
echo '   boolean false'
EOF
chmod +x "$tmp_dir/bin/powerprofilesctl" "$tmp_dir/bin/busctl" "$tmp_dir/bin/dbus-monitor"

export INTEL_CALL_LOG="$tmp_dir/intel-calls"
export BATTERY_QUEUE="$tmp_dir/battery"
printf '%s\n' balanced balanced power-saver performance >"$POWERPROFILES_QUEUE"
printf '%s\n' false true >"$BATTERY_QUEUE"

if "$ROOT/bin/omarchy-powerprofiles-intel" monitor 2>/dev/null; then
  fail "intel pstate monitor fails when dbus-monitor stops"
fi
expected_calls=$'balanced\nbalanced\npower-saver\nperformance'
[[ $(<"$INTEL_CALL_LOG") == "$expected_calls" && ! -s $POWERPROFILES_QUEUE && ! -s $BATTERY_QUEUE ]] ||
  fail "intel pstate monitor applies on start, profile/AC changes, and resume only" "$(<"$INTEL_CALL_LOG")"
[[ $(<"$tmp_dir/pstate/hwp_dynamic_boost") == "1" && $(<"$tmp_dir/pstate/energy_efficiency") == "0" ]] ||
  fail "intel pstate monitor leaves final knobs matching resumed performance profile"
pass "intel pstate monitor follows PowerProfiles, UPower, and resume signals"
