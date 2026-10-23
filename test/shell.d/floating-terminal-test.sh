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

# Run the generated presentation script in place of a real terminal.
cat >"$tmp_dir/setsid" <<'SCRIPT'
#!/bin/bash
while (($#)); do
  if [[ $1 == "-c" ]]; then
    exec bash -c "$2"
  fi
  shift
done
exit 1
SCRIPT
cat >"$tmp_dir/omarchy-show-logo" <<'SCRIPT'
#!/bin/bash
SCRIPT
cat >"$tmp_dir/omarchy-show-done" <<'SCRIPT'
#!/bin/bash
printf '%s\n' "$1" >"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/omarchy-show-logo" "$tmp_dir/omarchy-show-done"

: >"$TEST_LOG"
"$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" --close-on-success true
[[ ! -s $TEST_LOG ]] || fail "a flagged success closes without the Done prompt"
pass "a flagged success closes without the Done prompt"

"$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" --close-on-success false
[[ $(<"$TEST_LOG") == "1" ]] || fail "a flagged failure still shows the Failed prompt"
pass "a flagged failure still shows the Failed prompt"

: >"$TEST_LOG"
"$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" true
[[ $(<"$TEST_LOG") == "0" ]] || fail "an unflagged success still shows the Done prompt"
pass "an unflagged success still shows the Done prompt"

for flag in "" "--close-on-success"; do
  : >"$TEST_LOG"
  "$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" ${flag:+"$flag"} "bash -c 'exit 130'"
  [[ ! -s $TEST_LOG ]] || fail "Ctrl-C closes without a prompt, flagged or not"
done
pass "Ctrl-C closes without a prompt, flagged or not"
