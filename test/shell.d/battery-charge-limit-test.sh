#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"

# Each fake UPower battery is a directory of property files under $FAKE_UPOWER.
cat >"$tmp_dir/bin/upower" <<'EOF'
#!/bin/bash

[[ $1 == "-e" ]] || exit 1
echo /org/freedesktop/UPower/devices/line_power_AC0
for device in "$FAKE_UPOWER"/*; do
  [[ -d $device ]] && echo "/org/freedesktop/UPower/devices/${device##*/}"
done
EOF

cat >"$tmp_dir/bin/busctl" <<'EOF'
#!/bin/bash

device="$FAKE_UPOWER/${3##*/}"
[[ -d $device ]] || exit 1

case "$1" in
  get-property)
    case "$5" in
      ChargeThresholdSupported | ChargeThresholdEnabled) echo "b $(<"$device/$5")" ;;
      *) echo "u $(<"$device/$5")" ;;
    esac
    ;;
  call)
    [[ $5 == "EnableChargeThreshold" && ! -e $device/refuse ]] || exit 1
    echo "$7" >"$device/ChargeThresholdEnabled"
    ;;
esac
EOF
chmod +x "$tmp_dir/bin/upower" "$tmp_dir/bin/busctl"

export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"
export FAKE_UPOWER="$tmp_dir/upower"

# battery <name> <supported> <enabled> <settings bitmask> <end threshold>
battery() {
  local device="$FAKE_UPOWER/$1"

  mkdir -p "$device"
  echo "$2" >"$device/ChargeThresholdSupported"
  echo "$3" >"$device/ChargeThresholdEnabled"
  echo "$4" >"$device/ChargeThresholdSettingsSupported"
  echo "$5" >"$device/ChargeEndThreshold"
}

reset() {
  rm -rf "$FAKE_UPOWER"
  mkdir -p "$FAKE_UPOWER"
}

limit() {
  "$ROOT/bin/omarchy-battery-charge-limit" "$@"
}

# Laptop with start/end percentage thresholds (ThinkPad, ASUS, Framework).
reset
battery battery_BAT0 true false 3 80

[[ $(limit status) == "off 80" ]] || fail "charge limit reports off with the stopping percentage"
pass "charge limit reports off with the stopping percentage"

limit on
[[ $(<"$FAKE_UPOWER/battery_BAT0/ChargeThresholdEnabled") == "true" ]] || fail "charge limit turns on"
[[ $(limit status) == "on 80" ]] || fail "charge limit reports on"
pass "charge limit turns on through UPower"

limit on
[[ $(limit status) == "on 80" ]] || fail "charge limit on is idempotent"
pass "charge limit on is idempotent"

limit off
[[ $(limit status) == "off 80" ]] || fail "charge limit turns off"
pass "charge limit turns off through UPower"

limit toggle
[[ $(limit status) == "on 80" ]] || fail "charge limit toggles on"
limit toggle
[[ $(limit status) == "off 80" ]] || fail "charge limit toggles off"
pass "charge limit toggles"

# Laptop that only offers a Long_Life charging mode (charge_types, e.g. Dell).
reset
battery battery_BAT0 true true 4 80

[[ $(limit status) == "on" ]] || fail "charge limit omits a percentage the firmware does not keep"
pass "charge limit omits the percentage on charging-mode laptops"

# Two batteries both follow the limit.
reset
battery battery_BAT0 true false 3 80
battery battery_BAT1 true false 3 80

limit on
[[ $(<"$FAKE_UPOWER/battery_BAT0/ChargeThresholdEnabled") == "true" ]] || fail "charge limit applies to the first battery"
[[ $(<"$FAKE_UPOWER/battery_BAT1/ChargeThresholdEnabled") == "true" ]] || fail "charge limit applies to the second battery"
pass "charge limit applies to every battery"

echo false >"$FAKE_UPOWER/battery_BAT1/ChargeThresholdEnabled"
[[ $(limit status) == "off 80" ]] || fail "charge limit is on only when every battery is limited"
pass "charge limit reports off while any battery charges to full"

# A battery that cannot be limited is skipped, and none at all is an error.
reset
battery battery_BAT0 false false 0 0

if limit status 2>"$tmp_dir/err"; then
  fail "charge limit fails without a supported battery"
fi
rg -q 'no battery that supports a charge limit' "$tmp_dir/err" || fail "charge limit explains the missing support"
pass "charge limit fails cleanly without a supported battery"

reset
battery battery_BAT0 false false 0 0
battery battery_BAT1 true false 2 60

[[ $(limit status) == "off 60" ]] || fail "charge limit skips batteries without support"
pass "charge limit skips batteries without support"

# The firmware or polkit refusing the change is reported, not swallowed.
reset
battery battery_BAT0 true false 3 80
touch "$FAKE_UPOWER/battery_BAT0/refuse"

if limit on; then
  fail "charge limit reports a refused change"
fi
[[ $(limit status) == "off 80" ]] || fail "charge limit state is unchanged after a refused change"
pass "charge limit reports a refused change"

if limit sideways 2>/dev/null; then
  fail "charge limit rejects unknown actions"
fi
if limit 2>/dev/null; then
  fail "charge limit requires an action"
fi
pass "charge limit rejects unknown actions"
