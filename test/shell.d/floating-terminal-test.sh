#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

cat >"$tmp_dir/setsid" <<'SCRIPT'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/setsid"

export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir:$ROOT/bin:$PATH"

"$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" "echo hello"

launch=$(<"$TEST_LOG")
[[ $launch == *"xdg-terminal-exec --app-id=org.omarchy.terminal"* ]] || fail "floating terminal launches Omarchy terminal" "$launch"
pass "floating terminal launches Omarchy terminal"

# Execute the generated presentation script, without starting a real terminal.
cat >"$tmp_dir/setsid" <<'SCRIPT'
#!/bin/bash
while (($#)); do
  if [[ $1 == "-c" ]]; then
    shift
    exec bash -c "$1"
  fi
  shift
done
exit 1
SCRIPT
cat >"$tmp_dir/omarchy-show-logo" <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT
cat >"$tmp_dir/omarchy-show-done" <<'SCRIPT'
#!/bin/bash
printf '%s\n' "$1" >"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/omarchy-show-logo" "$tmp_dir/omarchy-show-done"

: >"$TEST_LOG"
omarchy-launch-floating-terminal-with-presentation --close-on-success true
[[ ! -s $TEST_LOG ]] || fail "flagged success closes without prompting"
pass "flagged success closes without prompting"

omarchy-launch-floating-terminal-with-presentation --close-on-success false
[[ $(<"$TEST_LOG") == "1" ]] || fail "flagged failure retains the failure prompt"
pass "flagged failure retains the failure prompt"

omarchy-launch-floating-terminal-with-presentation true
[[ $(<"$TEST_LOG") == "0" ]] || fail "unflagged success retains the Done prompt"
pass "unflagged success retains the Done prompt"

for flag in "" "--close-on-success"; do
  : >"$TEST_LOG"
  omarchy-launch-floating-terminal-with-presentation ${flag:+"$flag"} 'bash -c "exit 130"'
  [[ ! -s $TEST_LOG ]] || fail "exit 130 skips prompting with or without the flag"
done
pass "exit 130 skips prompting with or without the flag"
