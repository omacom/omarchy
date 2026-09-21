#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
launch_log="$test_tmp/launch"
mkdir -p "$mock_bin" "$test_home/.local/state/omarchy/defaults"

cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_EDITOR_LAUNCH"
SH
for command in emacs emacsclient code; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
exit 0
SH
done
chmod +x "$mock_bin"/*

launch_editor() {
  HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_EDITOR_LAUNCH="$launch_log" \
    bash "$ROOT/bin/omarchy-launch-editor" "$@"
}

echo emacs >"$test_home/.local/state/omarchy/defaults/editor"
launch_editor
[[ $(<"$launch_log") == "uwsm-app -- emacsclient --alternate-editor=emacs --create-frame" ]] ||
  fail "emacs default opens a frame on the Emacs daemon" "actual: $(<"$launch_log")"
pass "emacs default opens a frame on the Emacs daemon"

launch_editor --inline notes.txt
[[ $(<"$launch_log") == "uwsm-app -- emacsclient --alternate-editor=emacs --create-frame notes.txt" ]] ||
  fail "emacs default opens files in a new daemon frame" "actual: $(<"$launch_log")"
pass "emacs default opens files in a new daemon frame"

echo code >"$test_home/.local/state/omarchy/defaults/editor"
launch_editor notes.txt
[[ $(<"$launch_log") == "uwsm-app -- code notes.txt" ]] ||
  fail "other graphical editors launch directly" "actual: $(<"$launch_log")"
pass "other graphical editors launch directly"
