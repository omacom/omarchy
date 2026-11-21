#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

units="$ROOT/default/systemd/user"
timer="$units/omarchy-clock-resync.timer"
service="$units/omarchy-clock-resync.service"
first_run="$ROOT/install/user/first-run/enable-user-units.sh"
migration="$ROOT/migrations/1792360285.sh"

# OnClockChange= is what makes the timer fire when CLOCK_REALTIME jumps against
# CLOCK_MONOTONIC, which a resume from suspend does as well as a clock being set.
grep -Fx 'OnClockChange=yes' "$timer" >/dev/null ||
  fail "the timer fires when the system clock jumps"
grep -Fx 'OnTimezoneChange=yes' "$timer" >/dev/null ||
  fail "the timer fires when the timezone changes"
pass "the timer fires when the system clock or the timezone changes"

# Any calendar or monotonic expression would turn it into a poll.
if grep -Eq '^(OnCalendar|OnActiveSec|OnBootSec|OnStartupSec|OnUnitActiveSec|OnUnitInactiveSec|AccuracySec|RandomizedDelaySec)=' "$timer"; then
  fail "the timer waits for the clock to jump instead of counting down to anything"
fi
grep -Fx 'WantedBy=graphical-session.target' "$timer" >/dev/null ||
  fail "the timer runs with the graphical session"
pass "the timer counts down to nothing and runs with the graphical session"

grep -Fx 'ExecStart=/usr/bin/omarchy-shell -q omarchy.clock resync' "$service" >/dev/null ||
  fail "the service tells the shell to resync the clock, quietly"
grep -Fx 'Type=oneshot' "$service" >/dev/null ||
  fail "the service runs once per jump"
grep -Fx 'ConditionEnvironment=OMARCHY_PATH' "$service" >/dev/null &&
  grep -Fx 'ConditionEnvironment=WAYLAND_DISPLAY' "$service" >/dev/null ||
  fail "the service waits for the environment omarchy-shell finds the shell through"
pass "the service tells the running shell to resync the clock"

# verify also checks that the ExecStart binary exists, so it needs the package.
if command -v systemd-analyze >/dev/null && [[ -x /usr/bin/omarchy-shell ]]; then
  verify=$(systemd-analyze --user verify "$timer" "$service" 2>&1) ||
    fail "systemd accepts the clock resync units" "$verify"
  [[ -z $verify ]] || fail "systemd accepts the clock resync units" "$verify"
  pass "systemd accepts the clock resync units"
fi

grep -F 'omarchy-clock-resync.timer' "$first_run" >/dev/null ||
  fail "new installs enable the clock resync timer"
pass "new installs enable the clock resync timer"

# The migration, run for a user whose units are not on the machine yet, with
# systemctl stubbed: it must put them where the user manager looks, then enable
# and start the timer, and a second run must change nothing.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home"
cat >"$tmp/bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
exit 0
SH
chmod +x "$tmp/bin/systemctl"

run_migration() {
  HOME="$tmp/home" OMARCHY_PATH="$ROOT" SYSTEMCTL_LOG="$tmp/systemctl.log" PATH="$tmp/bin:$PATH" \
    bash "$migration" >/dev/null
}

if [[ -e /usr/lib/systemd/user/omarchy-clock-resync.timer ]]; then
  skip "the package already ships the clock resync units; skipping the install check"
else
  run_migration
  [[ $(readlink "$tmp/home/.config/systemd/user/omarchy-clock-resync.timer") == "$timer" &&
    $(readlink "$tmp/home/.config/systemd/user/omarchy-clock-resync.service") == "$service" ]] ||
    fail "the migration links the clock resync units for an existing user"
  pass "the migration links the clock resync units for an existing user"
fi

grep -Fx -- '--user enable omarchy-clock-resync.timer' "$tmp/systemctl.log" >/dev/null ||
  fail "the migration enables the clock resync timer"
pass "the migration enables the clock resync timer"

# Over SSH there is no user manager to enable into, so the wants symlink is
# written directly.
cat >"$tmp/bin/systemctl" <<'SH'
#!/bin/bash
[[ $* == "--user enable"* ]] && exit 1
exit 0
SH
run_migration
[[ -L $tmp/home/.config/systemd/user/graphical-session.target.wants/omarchy-clock-resync.timer ]] ||
  fail "the migration links the timer in by hand when systemctl cannot enable it"
pass "the migration links the timer in by hand when systemctl cannot enable it"
