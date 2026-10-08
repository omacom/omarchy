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


for installer in "$ROOT"/bin/omarchy-install-*; do
  command=${installer##*/}
  "$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" "$command"
  launch=$(<"$TEST_LOG")
  [[ $launch == *'default/install-presentation/dashboard.py --interactive'* && $launch == *"--command $command" ]] ||
    fail "$command uses the default dashboard" "$launch"
done
pass "every dedicated installer uses the default interactive dashboard"

"$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" "omarchy-install-browser firefox"
launch=$(<"$TEST_LOG")
[[ $launch == *'--interactive'* && $launch == *'--command omarchy-install-browser firefox' ]] ||
  fail "parameterized browser installs use the dashboard" "$launch"
pass "parameterized browser installs use the dashboard"

"$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" "omarchy-setup-security-fingerprint"
launch=$(<"$TEST_LOG")
[[ $launch == *'--interactive'* && $launch == *'--command omarchy-setup-security-fingerprint' ]] ||
  fail "interactive setup gets a real terminal through the dashboard" "$launch"
pass "interactive setup gets a real terminal through the dashboard"
