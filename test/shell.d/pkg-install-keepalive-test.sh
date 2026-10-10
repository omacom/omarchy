#!/bin/bash
#
# omarchy-pkg-install needs sudo only for its pacman transaction. Once that is
# done, the keepalive should stop and revoke before the Done/Failed prompt,
# which waits for a keypress for as long as the window stays open.

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$mock_bin"

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo %s\n' "$*" >>"$TEST_CALLS"
case ${1:-} in
-v | -k | pacman) exit 0 ;;
-n) [[ ${2:-} == "true" ]] ;;
*) exit 90 ;;
esac
SH

cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash

printf '%s\n' test-package
SH

cat >"$mock_bin/fzf" <<'SH'
#!/bin/bash

head -n 1
SH

# Each keepalive interval takes 10 ms here instead of 60 s.
cat >"$mock_bin/sleep" <<'SH'
#!/bin/bash

exec /bin/sleep 0.01
SH

# Stands in for "Press any key to close...": the window stays open 0.5 s.
cat >"$mock_bin/omarchy-show-done" <<'SH'
#!/bin/bash

printf 'prompt opened (status %s)\n' "$1" >>"$TEST_CALLS"
/bin/sleep 0.5
printf 'prompt closed\n' >>"$TEST_CALLS"
SH

chmod +x "$mock_bin"/*

PATH="$mock_bin:$ROOT/bin:$PATH" TEST_CALLS="$calls" \
  bash "$ROOT/bin/omarchy-pkg-install" </dev/null

while_open=$(sed -n '/^prompt opened/,/^prompt closed$/p' "$calls" | grep -c '^sudo -n true$' || true)
(( while_open == 0 )) ||
  fail "no sudo refresh while the Done prompt is open" "refreshes while open: $while_open"$'\n'"$(uniq -c "$calls")"
pass "no sudo refresh while the Done prompt is open"

revoke_line=$(grep -nx 'sudo -k' "$calls" | head -n 1 | cut -d: -f1)
prompt_line=$(grep -n '^prompt opened' "$calls" | cut -d: -f1)
[[ -n $revoke_line ]] && (( revoke_line < prompt_line )) ||
  fail "sudo -k runs before the Done prompt" "$(uniq -c "$calls")"
pass "sudo -k runs before the Done prompt"
