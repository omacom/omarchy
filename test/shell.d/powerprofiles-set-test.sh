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
cat >"$tmp_dir/bin/omarchy-shell" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$tmp_dir/bin/busctl" "$tmp_dir/bin/omarchy-shell"

export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"
export POWERPROFILES_LOG="$tmp_dir/calls"
export OMARCHY_POWERPROFILES_STATE_DIR="$tmp_dir/state"
export OMARCHY_GAME_POWER_STATE="$tmp_dir/game-active"

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

# Active-game marker scoped to the live Hyprland instance boosts AC to
# performance without overwriting the saved preference, ignores stale markers
# from prior Hyprland instances, and yields to manual profile choices.
mkdir -p "$tmp_dir/runtime/hypr/sig-active" "$tmp_dir/runtime/hypr/sig-old"
: >"$tmp_dir/runtime/hypr/sig-old/omarchy-game-power-active"
unset OMARCHY_GAME_POWER_STATE

"$ROOT/bin/omarchy-powerprofiles-set" ac balanced
ON_BATTERY=0 XDG_RUNTIME_DIR="$tmp_dir/runtime" HYPRLAND_INSTANCE_SIGNATURE="sig-active" \
  "$ROOT/bin/omarchy-powerprofiles-set" autodetect
[[ $(tail -n 1 "$tmp_dir/calls") == "balanced" ]] || fail "stale marker from old Hyprland instance must be ignored"

: >"$tmp_dir/runtime/hypr/sig-active/omarchy-game-power-active"
ON_BATTERY=0 XDG_RUNTIME_DIR="$tmp_dir/runtime" HYPRLAND_INSTANCE_SIGNATURE="sig-active" \
  "$ROOT/bin/omarchy-powerprofiles-set" autodetect
[[ $(tail -n 1 "$tmp_dir/calls") == "performance" ]] || fail "active game marker boosts AC to performance"
[[ $(<"$tmp_dir/state/ac") == "balanced" ]] || fail "active game boost leaves saved AC preference intact"

"$ROOT/bin/omarchy-powerprofiles-set" battery power-saver
ON_BATTERY=1 XDG_RUNTIME_DIR="$tmp_dir/runtime" HYPRLAND_INSTANCE_SIGNATURE="sig-active" \
  "$ROOT/bin/omarchy-powerprofiles-set" autodetect
[[ $(tail -n 1 "$tmp_dir/calls") == "power-saver" ]] || fail "active game marker does not boost while on battery"
XDG_RUNTIME_DIR="$tmp_dir/runtime" HYPRLAND_INSTANCE_SIGNATURE="sig-active" \
  "$ROOT/bin/omarchy-powerprofiles-set" ac
[[ $(tail -n 1 "$tmp_dir/calls") == "performance" ]] || fail "plugging in AC mid-game boosts to performance"

XDG_RUNTIME_DIR="$tmp_dir/runtime" HYPRLAND_INSTANCE_SIGNATURE="sig-active" \
  "$ROOT/bin/omarchy-powerprofiles-set" ac power-saver
[[ $(tail -n 1 "$tmp_dir/calls") == "power-saver" ]] || fail "manual profile choice overrides active game boost"
[[ $(<"$tmp_dir/state/ac") == "power-saver" ]] || fail "manual profile choice updates saved AC preference"

rm -f "$tmp_dir/runtime/hypr/sig-active/omarchy-game-power-active"
ON_BATTERY=0 XDG_RUNTIME_DIR="$tmp_dir/runtime" HYPRLAND_INSTANCE_SIGNATURE="sig-active" \
  "$ROOT/bin/omarchy-powerprofiles-set" autodetect
[[ $(tail -n 1 "$tmp_dir/calls") == "power-saver" ]] || fail "clearing active game marker restores saved AC preference"
pass "active game marker boosts AC per Hyprland instance, survives AC plug-in, and yields to manual choices"

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
