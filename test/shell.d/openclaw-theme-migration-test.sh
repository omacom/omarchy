#!/bin/bash

set -euo pipefail

# The migration renders the OpenClaw palette for the current theme and hands
# it to an OpenClaw already installed. It is exercised here with the package
# probe, the theme refresh and the theme hook stubbed, so a migration that
# handed the theme to a machine without OpenClaw, that left a later install
# with no palette to follow, or that let an OpenClaw refusing the write hold
# up later migrations shows up in what it ran.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1788754629.sh"
[[ -f $migration ]] || fail "OpenClaw theme migration exists"
[[ $(stat -c %a "$migration") == "644" ]] || fail "migration is a plain 0644 file"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == "openclaw" && ${OMARCHY_TEST_INSTALLED:-0} == 1 ]]
SH

cat >"$mock_bin/omarchy-theme-set-openclaw" <<'SH'
#!/bin/bash
echo "omarchy-theme-set-openclaw $*" >>"$OMARCHY_TEST_CALLS"
[[ ${OMARCHY_TEST_HOOK_FAILS:-0} == 0 ]]
SH

# A refresh re-stages the current theme, which is where the palette gets
# rendered.
cat >"$mock_bin/omarchy-theme-refresh" <<'SH'
#!/bin/bash
echo "omarchy-theme-refresh" >>"$OMARCHY_TEST_CALLS"
[[ ${OMARCHY_TEST_REFRESH_FAILS:-0} == 0 ]] || exit 1
[[ ${OMARCHY_TEST_REFRESH_RENDERS:-1} == 0 ]] || echo '{"label":"Omarchy","colors":{"accent":"#7aa2f7"}}' >"$HOME/.local/state/omarchy/current/theme/openclaw.json"
SH

chmod +x "$mock_bin"/*

test_home="$test_tmp/home"
state="$test_home/.local/state/omarchy/current"

reset_home() {
  rm -rf "$test_home"
  mkdir -p "$state/theme"
  : >"$calls"
}

# Run the way omarchy-migrate runs it, so a failure ends the migration.
run_migration() {
  OMARCHY_TEST_INSTALLED="${OMARCHY_TEST_INSTALLED:-1}" \
    OMARCHY_TEST_HOOK_FAILS="${OMARCHY_TEST_HOOK_FAILS:-0}" \
    OMARCHY_TEST_REFRESH_FAILS="${OMARCHY_TEST_REFRESH_FAILS:-0}" \
    OMARCHY_TEST_REFRESH_RENDERS="${OMARCHY_TEST_REFRESH_RENDERS:-1}" \
    OMARCHY_TEST_CALLS="$calls" \
    OMARCHY_PATH="$ROOT" \
    PATH="$mock_bin:$PATH" \
    HOME="$test_home" \
    bash -euo pipefail "$migration" >/dev/null 2>&1
}

reset_home
echo "tokyo-night" >"$state/theme.name"
OMARCHY_TEST_INSTALLED=0 run_migration || fail "a machine without OpenClaw succeeds"
[[ $(cat "$calls") == "omarchy-theme-refresh" ]] ||
  fail "a machine without OpenClaw still gets the palette rendered, and nothing handed over" "$(cat "$calls")"
pass "the migration renders the palette even where OpenClaw is not installed"

reset_home
echo '{"label":"Omarchy","colors":{"accent":"#7aa2f7"}}' >"$state/theme/openclaw.json"
OMARCHY_TEST_INSTALLED=0 run_migration || fail "a machine without OpenClaw and with a palette succeeds"
[[ ! -s $calls ]] || fail "a palette already rendered on a machine without OpenClaw needs nothing" "$(cat "$calls")"
pass "the migration leaves a machine without OpenClaw and with a palette alone"

reset_home
echo '{"label":"Omarchy","colors":{"accent":"#7aa2f7"}}' >"$state/theme/openclaw.json"
run_migration || fail "handing over the theme succeeds"
[[ $(cat "$calls") == "omarchy-theme-set-openclaw --activate" ]] ||
  fail "a palette already rendered is handed over without a refresh" "$(cat "$calls")"
pass "the migration activates the theme through the hook"

reset_home
echo "tokyo-night" >"$state/theme.name"
run_migration || fail "rendering the palette first succeeds"
[[ $(cat "$calls") == $'omarchy-theme-refresh\nomarchy-theme-set-openclaw --activate' ]] ||
  fail "a theme applied before the template existed is re-staged first" "$(cat "$calls")"
pass "the migration renders a missing palette before handing it over"

reset_home
run_migration || fail "an install without a current theme is a successful no-op"
[[ ! -s $calls ]] || fail "nothing is rendered or handed over without a current theme" "$(cat "$calls")"
pass "the migration skips an install with no current theme"

reset_home
echo '{"label":"Omarchy","colors":{"accent":"#7aa2f7"}}' >"$state/theme/openclaw.json"
OMARCHY_TEST_HOOK_FAILS=1 run_migration || fail "an OpenClaw that refuses the write does not fail the migration"
pass "a refused hand-over does not hold up later migrations"

reset_home
echo "no-such-theme" >"$state/theme.name"
run_migration || fail "a current theme that no longer exists is a successful no-op"
[[ ! -s $calls ]] || fail "nothing is rendered from a theme that no longer exists, and nothing handed over" "$(cat "$calls")"
pass "the migration skips a theme that was removed while current"

reset_home
echo "tokyo-night" >"$state/theme.name"
OMARCHY_TEST_REFRESH_FAILS=1 run_migration && fail "a refresh that failed does not count as done"
[[ $(cat "$calls") == "omarchy-theme-refresh" ]] || fail "a failed refresh hands nothing over" "$(cat "$calls")"
pass "a refresh that fails keeps the migration pending"

# The staging scripts do not run under errexit, so a refresh can return
# success without having rendered anything.
reset_home
echo "tokyo-night" >"$state/theme.name"
OMARCHY_TEST_REFRESH_RENDERS=0 run_migration && fail "a refresh that rendered no palette does not count as done"
[[ $(cat "$calls") == "omarchy-theme-refresh" ]] || fail "a refresh without a palette hands nothing over" "$(cat "$calls")"
pass "a refresh that renders no palette keeps the migration pending"
