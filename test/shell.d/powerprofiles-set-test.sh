#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/state"

# omarchy-powerprofiles-floor reads the profile with powerprofilesctl get;
# each call reports the next profile in the queue
cat >"$tmp_dir/bin/powerprofilesctl" <<'EOF'
#!/bin/bash

if [[ $1 == "get" ]]; then
  head -n 1 "$POWERPROFILES_QUEUE"
  sed -i 1d "$POWERPROFILES_QUEUE"
fi
EOF
chmod +x "$tmp_dir/bin/powerprofilesctl"

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

out="$("$ROOT/bin/omarchy-powerprofiles-list" --active-state)"
[[ $out == $'power-saver\t0\nbalanced\t1\nperformance\t0' ]] || fail "power profiles list reads D-Bus Profiles and marks the active one" "$out"
pass "power profiles list reads D-Bus Profiles and marks the active one"

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
