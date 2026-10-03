#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-toggle-battery-limit"
sudoers_file="$ROOT/etc/sudoers.d/omarchy-battery-limit"
rule='%wheel ALL=(root) NOPASSWD: /usr/bin/omarchy-toggle-battery-limit, /usr/bin/omarchy-toggle-battery-limit on, /usr/bin/omarchy-toggle-battery-limit off'
menu_file="$ROOT/default/omarchy/omarchy-menu.jsonc"

rules=$(grep -vE '^[[:space:]]*(#|$)' "$sudoers_file")
[[ $rules == "$rule" ]] ||
  fail "battery-limit sudoers file carries exactly the on/off/bare rule and nothing else" "got: $rules"

if command -v visudo >/dev/null; then
  visudo -cf "$sudoers_file" >/dev/null || fail "battery-limit sudoers rule parses"
fi

grep -Fx 'PACKAGED_PATH=/usr/bin/omarchy-toggle-battery-limit' "$helper" >/dev/null ||
  fail "omarchy-toggle-battery-limit elevates the path the sudoers rule names"

grep -E 'sudo -n -l -l' "$helper" >/dev/null ||
  fail "omarchy-toggle-battery-limit reads the grant from the long sudo listing"

grep -Eq '^\s*export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin' "$helper" ||
  fail "omarchy-toggle-battery-limit pins PATH to trusted system directories when it holds root"
gated=$(grep -A1 -E '^if \(\( EUID == 0 \)\); then$' "$helper" || true)
[[ $gated == *"export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin"* ]] ||
  fail "omarchy-toggle-battery-limit gates the trusted-PATH pin on holding root"

grep -F 'install -m 0644 -o root -g root -T' "$helper" >/dev/null ||
  fail "omarchy-toggle-battery-limit installs the udev rule with install -T"

if grep -E 'RUN\+=' "$helper" >/dev/null; then
  fail "omarchy-toggle-battery-limit udev rule does not RUN anything"
fi

pass "battery-limit sudoers rule is scoped to on, off, and the bare toggle"

grep -F '"trigger.toggle.battery-limit"' "$menu_file" >/dev/null ||
  fail "Toggle menu declares the battery cap trigger"

grep -F '"action":"omarchy-toggle-battery-limit"' "$menu_file" >/dev/null ||
  fail "battery cap trigger runs omarchy-toggle-battery-limit"

grep -F '"when":"omarchy-toggle-battery-limit --supported"' "$menu_file" >/dev/null ||
  fail "battery cap trigger is hidden when the hardware has no charge threshold"

grep -F '"checked":"omarchy-toggle-battery-limit --enabled"' "$menu_file" >/dev/null ||
  fail "battery cap trigger shows a check while the cap is on"

pass "Toggle menu exposes battery cap as an on/off trigger"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/power/BAT0" "$test_tmp/udev" "$test_tmp/bin"
printf '100\n' >"$test_tmp/power/BAT0/charge_control_end_threshold"

run_helper() {
  OMARCHY_POWER_SUPPLY_PATH="$test_tmp/power" \
    OMARCHY_UDEV_RULES_DIR="$test_tmp/udev" \
    PATH="$test_tmp/bin:$PATH" \
    bash "$helper" "$@"
}

run_helper --supported
pass "battery-limit --supported succeeds when a charge threshold exists"

if run_helper --enabled; then
  fail "battery-limit --enabled is false at 100%"
fi
[[ $(run_helper --status) == "on" ]] && fail "battery-limit --status is off at 100%"
[[ $(run_helper --status) == "off" ]] || fail "battery-limit --status is off at 100%"
pass "battery-limit reports off when the threshold is 100%"

printf '80\n' >"$test_tmp/power/BAT0/charge_control_end_threshold"
run_helper --enabled
[[ $(run_helper --status) == "on" ]] || fail "battery-limit --status is on at 80%"
pass "battery-limit reports on when the threshold is 80%"

rm -rf "$test_tmp/power"
mkdir -p "$test_tmp/power/AC0"
if run_helper --supported; then
  fail "battery-limit --supported fails without a charge threshold"
fi
pass "battery-limit --supported fails when the hardware cannot cap charge"

mkdir -p "$test_tmp/power/BAT0"
printf '100\n' >"$test_tmp/power/BAT0/charge_control_end_threshold"

cat >"$test_tmp/bin/pkexec" <<'SH'
#!/bin/bash
printf 'pkexec %s\n' "$*" >"$ELEVATION_LOG"
SH
chmod +x "$test_tmp/bin/pkexec"

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
if [[ $1 == -n && $2 == -l ]]; then
  if [[ ${STUB_GRANTED-granted} == "granted" ]]; then
    echo "    Options: !authenticate"
  else
    echo "    Matched: ${!#}"
  fi
  exit 0
fi
printf 'sudo %s\n' "$*" >"$ELEVATION_LOG"
SH
chmod +x "$test_tmp/bin/sudo"

cat >"$test_tmp/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notify %s\n' "$*" >"$NOTIFY_LOG"
SH
chmod +x "$test_tmp/bin/omarchy-notification-send"

if ((EUID == 0)); then
  pass "running as root; skipping the elevation checks, which would rewrite charge thresholds"
else
  elevation_for() {
    : >"$test_tmp/elevation"
    : >"$test_tmp/notify"
    ELEVATION_LOG="$test_tmp/elevation" NOTIFY_LOG="$test_tmp/notify" \
      run_helper "$@" </dev/null >/dev/null 2>&1 || true
    cat "$test_tmp/elevation"
  }

  elevation=$(elevation_for on)
  [[ $elevation == "sudo /usr/bin/omarchy-toggle-battery-limit on" ]] ||
    fail "omarchy-toggle-battery-limit takes the passwordless sudo grant for on without a terminal" "got: $elevation"

  elevation=$(elevation_for off)
  [[ $elevation == "sudo /usr/bin/omarchy-toggle-battery-limit off" ]] ||
    fail "omarchy-toggle-battery-limit takes the passwordless sudo grant for off without a terminal" "got: $elevation"

  printf '100\n' >"$test_tmp/power/BAT0/charge_control_end_threshold"
  elevation=$(elevation_for)
  [[ $elevation == "sudo /usr/bin/omarchy-toggle-battery-limit on" ]] ||
    fail "omarchy-toggle-battery-limit toggle from 100% elevates on" "got: $elevation"

  printf '80\n' >"$test_tmp/power/BAT0/charge_control_end_threshold"
  elevation=$(elevation_for)
  [[ $elevation == "sudo /usr/bin/omarchy-toggle-battery-limit off" ]] ||
    fail "omarchy-toggle-battery-limit toggle from 80% elevates off" "got: $elevation"

  dev_linked=$(OMARCHY_PATH="$test_tmp/checkout" elevation_for on)
  [[ $dev_linked == "sudo /usr/bin/omarchy-toggle-battery-limit on" ]] ||
    fail "omarchy-toggle-battery-limit elevates the system install wherever OMARCHY_PATH points" "got: $dev_linked"

  pass "omarchy-toggle-battery-limit elevates on/off through the sudo grant"

  ungranted=$(STUB_GRANTED="" elevation_for on)
  [[ $ungranted == "pkexec /usr/bin/omarchy-toggle-battery-limit on" ]] ||
    fail "omarchy-toggle-battery-limit falls back to polkit where the grant does not reach" "got: $ungranted"

  pass "omarchy-toggle-battery-limit falls back to polkit wherever the grant does not reach"

  for bad in "" "60" "100" "--on" "on off" '$(id)' "on;id" "../on"; do
    : >"$test_tmp/elevation"
    if ELEVATION_LOG="$test_tmp/elevation" NOTIFY_LOG="$test_tmp/notify" \
      run_helper $bad </dev/null >/dev/null 2>&1; then
      # empty string is the no-arg toggle, which is valid
      if [[ -n $bad ]]; then
        fail "omarchy-toggle-battery-limit rejects '$bad'"
      fi
    fi

    if [[ -n $bad ]]; then
      rejected=$(elevation_for $bad)
      [[ -z $rejected ]] ||
        fail "omarchy-toggle-battery-limit rejects '$bad' before elevating" "got: $rejected"
    fi
  done

  pass "omarchy-toggle-battery-limit accepts nothing but on, off, and toggle"
fi

root_runner=()
if (( EUID != 0 )); then
  root_runner=(unshare --user --map-root-user)
fi

if (( EUID == 0 )) || unshare --user --map-root-user true 2>/dev/null; then
  printf '100\n' >"$test_tmp/power/BAT0/charge_control_end_threshold"
  rm -f "$test_tmp/udev/99-omarchy-battery-limit.rules"

  OMARCHY_POWER_SUPPLY_PATH="$test_tmp/power" \
    OMARCHY_UDEV_RULES_DIR="$test_tmp/udev" \
    OMARCHY_UDEV_CONTROL="$test_tmp/no-udev" \
    "${root_runner[@]}" bash "$helper" on </dev/null >/dev/null

  [[ $(<"$test_tmp/power/BAT0/charge_control_end_threshold") == 80 ]] ||
    fail "root omarchy-toggle-battery-limit on writes an 80% charge threshold" \
      "got: $(<"$test_tmp/power/BAT0/charge_control_end_threshold")"

  [[ -f $test_tmp/udev/99-omarchy-battery-limit.rules ]] ||
    fail "root omarchy-toggle-battery-limit on writes a udev rule"

  grep -F 'ATTR{charge_control_end_threshold}="80"' "$test_tmp/udev/99-omarchy-battery-limit.rules" >/dev/null ||
    fail "udev rule sets the 80% charge threshold"

  if grep -E 'RUN\+=' "$test_tmp/udev/99-omarchy-battery-limit.rules" >/dev/null; then
    fail "udev rule does not RUN anything"
  fi

  OMARCHY_POWER_SUPPLY_PATH="$test_tmp/power" \
    OMARCHY_UDEV_RULES_DIR="$test_tmp/udev" \
    OMARCHY_UDEV_CONTROL="$test_tmp/no-udev" \
    "${root_runner[@]}" bash "$helper" off </dev/null >/dev/null

  [[ $(<"$test_tmp/power/BAT0/charge_control_end_threshold") == 100 ]] ||
    fail "root omarchy-toggle-battery-limit off restores a 100% charge threshold" \
      "got: $(<"$test_tmp/power/BAT0/charge_control_end_threshold")"

  [[ ! -f $test_tmp/udev/99-omarchy-battery-limit.rules ]] ||
    fail "root omarchy-toggle-battery-limit off removes the udev rule"

  pass "root omarchy-toggle-battery-limit applies and persists the 80% cap"
else
  pass "no user namespace; skipping root apply checks"
fi
