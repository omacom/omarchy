#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/home"
export TEST_CALLS="$work/calls"

cat >"$work/bin/systemctl" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$TEST_CALLS"
case "$*" in
  '--user enable omarchy-audio-inhibit.service'|'--user enable --now omarchy-audio-inhibit.service')
    [[ ${TEST_TTY:-0} == 0 ]]
    ;;
  '--user is-active --quiet graphical-session.target')
    [[ ${TEST_TTY:-0} == 0 ]]
    ;;
  '--user start omarchy-audio-inhibit.service')
    exit 0
    ;;
  '--user daemon-reload')
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
SH
chmod +x "$work/bin/systemctl"

migration="$ROOT/migrations/1788700025.sh"
run_migration() {
  HOME="$work/home" PATH="$work/bin:$PATH" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration"
}

# 1. Graphical session enables and starts
run_migration
grep -F 'systemctl --user enable' "$TEST_CALLS" >/dev/null || fail "migration enables the unit"
grep -F 'systemctl --user start omarchy-audio-inhibit.service' "$TEST_CALLS" >/dev/null || fail "migration starts the service in active session"
pass "migration enables and starts service in active graphical session"

# 2. TTY update writes wants symlink and does not start service
: >"$TEST_CALLS"
TEST_TTY=1 run_migration
wants_link="$work/home/.config/systemd/user/graphical-session.target.wants/omarchy-audio-inhibit.service"
[[ -L $wants_link ]] || fail "TTY update creates graphical-session.target.wants symlink"
[[ -e $wants_link ]] || fail "wants symlink resolves to an existing unit"
if grep -F 'systemctl --user start' "$TEST_CALLS" >/dev/null; then
  fail "TTY migration must not start the service"
fi
pass "TTY migration creates wants symlink without starting service"
