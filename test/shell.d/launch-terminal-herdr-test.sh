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

# The launcher asks the focused terminal for its cwd, which needs a compositor.
cat >"$tmp_dir/omarchy-cmd-terminal-cwd" <<'SCRIPT'
#!/bin/bash
echo /tmp/work
SCRIPT
chmod +x "$tmp_dir/omarchy-cmd-terminal-cwd"

export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir:$ROOT/bin:$PATH"

"$ROOT/bin/omarchy-launch-terminal-herdr"

launch=$(<"$TEST_LOG")
[[ $launch == *"--app-id=org.omarchy.herdr"* ]] || fail "herdr window gets its own app-id" "$launch"
pass "herdr window gets its own app-id"

[[ $launch == *"--dir=/tmp/work"* ]] || fail "herdr still opens in the active terminal's cwd" "$launch"
pass "herdr still opens in the active terminal's cwd"

[[ $launch == *" herdr" ]] || fail "herdr is the command the terminal runs" "$launch"
pass "herdr is the command the terminal runs"
