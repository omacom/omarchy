#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home" "$test_tmp/data/applications" "$test_tmp/local/applications" "$test_tmp/system/applications"

export HOME="$test_tmp/home"
export XDG_DATA_HOME="$test_tmp/data"
export XDG_DATA_DIRS="$test_tmp/local:$test_tmp/system"
export OMARCHY_TEST_LOG="$test_tmp/log"

# Stand-ins for the seat and the compositor: show must never reach the live ones.
# The seat has a window once the browser has been run on it.
cat >"$mock_bin/omarchy-agent-seat-windows" <<'SH'
#!/bin/bash
# A broker that accepts and never answers, or one whose Hyprland is slow to
# list its windows, when the test asks for one.
if [[ -e $OMARCHY_TEST_LOG.hang ]]; then sleep 30; exit 0; fi
if [[ -e $OMARCHY_TEST_LOG.slow ]]; then sleep 4; echo '[{"address":"0x1"}]'; exit 0; fi
if [[ -e $OMARCHY_TEST_LOG.run ]]; then echo '[{"address":"0x1"}]'; else echo '[]'; fi
SH
# It records its whole command, one argument to a line.
cat >"$mock_bin/omarchy-agent-seat-run" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_LOG.run"
SH
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_LOG.hyprctl"
SH
cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_LOG.notice"
SH
echo $'#!/bin/bash\necho foo.desktop' >"$mock_bin/omarchy-cmd-default-browser"
chmod +x "$mock_bin"/*
export PATH="$mock_bin:$ROOT/bin:$PATH"

show_start() {
  rm -f "$OMARCHY_TEST_LOG".*
  omarchy-agent-seat-show --start
}

# A browser installed in a second system data dir, as /usr/local/share is.
echo "Exec=foo %U" >"$test_tmp/system/applications/foo.desktop"
show_start
[[ $(cat "$OMARCHY_TEST_LOG.run" 2>/dev/null) == "foo" ]] ||
  fail "show --start finds the default browser in any of XDG_DATA_DIRS" "$(cat "$OMARCHY_TEST_LOG.notice" 2>/dev/null)"
[[ $(<"$OMARCHY_TEST_LOG.hyprctl") == *address:0x1* ]] ||
  fail "show --start focuses the browser it opened"

# The user's own entry shadows the system one, as it does for the helper.
echo "Exec=home-foo %U" >"$XDG_DATA_HOME/applications/foo.desktop"
show_start
[[ $(<"$OMARCHY_TEST_LOG.run") == "home-foo" ]] ||
  fail "show --start reads the entry in XDG_DATA_HOME first"

# The whole command runs, not its first word alone: env would open nothing.
echo "Exec=env SOME_FLAG=1 foo %U" >"$XDG_DATA_HOME/applications/foo.desktop"
show_start
[[ $(<"$OMARCHY_TEST_LOG.run") == $'env\nSOME_FLAG=1\nfoo' ]] ||
  fail "show --start keeps the arguments of the browser's command" "$(cat "$OMARCHY_TEST_LOG.run")"

# Quoted arguments stay whole, with the spec's escapes undone, and a field
# code is dropped wherever it stands.
echo 'Exec=foo "a b" --name="x \\"y\\"" 100%% %u --last' >"$XDG_DATA_HOME/applications/foo.desktop"
show_start
[[ $(<"$OMARCHY_TEST_LOG.run") == $'foo\na b\n--name=x "y"\n100%\n--last' ]] ||
  fail "show --start splits the browser's command as the Desktop Entry spec does" "$(cat "$OMARCHY_TEST_LOG.run")"

# A command the run helper would read as one of its own options opens nothing.
echo "Exec=--share / foo" >"$XDG_DATA_HOME/applications/foo.desktop"
show_start
[[ ! -e $OMARCHY_TEST_LOG.run ]] ||
  fail "show --start never hands the run helper an option as the browser"

rm "$XDG_DATA_HOME/applications/foo.desktop" "$test_tmp/system/applications/foo.desktop"
show_start
[[ ! -e $OMARCHY_TEST_LOG.run ]] ||
  fail "show --start runs nothing without a browser entry"
[[ $(<"$OMARCHY_TEST_LOG.notice") == *"No default browser to open on the agent seat"* ]] ||
  fail "show --start says there is no browser to open"

pass "show --start opens the default browser found over the helper's data dirs"

# A broker that holds its socket open but never answers must not hang the
# hotkey or the menu row, and is not an empty seat to open a browser on.
echo "Exec=foo %U" >"$XDG_DATA_HOME/applications/foo.desktop"
rm -f "$OMARCHY_TEST_LOG".*
touch "$OMARCHY_TEST_LOG.hang"
started=$SECONDS
if timeout 25 omarchy-agent-seat-show --start 2>"$test_tmp/show.err"; then
  fail "show fails when the broker does not answer"
fi
((SECONDS - started < 20)) || fail "show gives up on a broker that does not answer within seconds" "took $((SECONDS - started))s"
[[ $(<"$test_tmp/show.err") == *"did not answer within 10 seconds"*"omarchy agent seat stop"* ]] ||
  fail "show says the broker did not answer and how to end it" "$(<"$test_tmp/show.err")"
[[ $(<"$OMARCHY_TEST_LOG.notice") == *"did not answer"* ]] ||
  fail "show tells the user through a notification when the broker does not answer"
[[ ! -e $OMARCHY_TEST_LOG.run && ! -e $OMARCHY_TEST_LOG.hyprctl ]] ||
  fail "show opens and focuses nothing while the broker does not answer"
rm -f "$OMARCHY_TEST_LOG.hang" "$XDG_DATA_HOME/applications/foo.desktop"
pass "show reports a broker that does not answer instead of waiting on it"

# The broker gives Hyprland five seconds to list its windows, so an answer
# that takes four is a healthy seat, not one to give up on.
rm -f "$OMARCHY_TEST_LOG".*
touch "$OMARCHY_TEST_LOG.slow"
omarchy-agent-seat-show
[[ $(cat "$OMARCHY_TEST_LOG.hyprctl" 2>/dev/null) == *address:0x1* ]] ||
  fail "show waits out a window list that takes as long as the broker allows" "$(cat "$OMARCHY_TEST_LOG.notice" 2>/dev/null)"
rm -f "$OMARCHY_TEST_LOG.slow"
pass "show outlasts the broker's own deadline for the window list"
