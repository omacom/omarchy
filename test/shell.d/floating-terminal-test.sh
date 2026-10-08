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

for command in omarchy-system-factory-reset omarchy-setup-direct-boot omarchy-install-ai-openclaw omarchy-install-service-tailscale; do
  "$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" --plain "$command"
  launch=$(<"$TEST_LOG")
  [[ $launch == *'-e bash -c omarchy-show-logo'* && $launch != *'dashboard.py'* && $launch == *"omarchy-presentation $command" ]] ||
    fail "plain presentation bypasses dashboard for $command" "$launch"
done
pass "plain setup and recovery routes bypass dashboard"

# Execute the actual launcher argv with desktop transport stubbed out.
cat >"$tmp_dir/setsid" <<'SCRIPT'
#!/bin/bash
while [[ $1 != -e ]]; do shift; done
shift
exec "$@"
SCRIPT
cat >"$tmp_dir/omarchy-show-logo" <<'SCRIPT'
#!/bin/bash
echo logo >>"$TEST_LOG"
SCRIPT
cat >"$tmp_dir/omarchy-show-done" <<'SCRIPT'
#!/bin/bash
echo "done:$1" >>"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir"/omarchy-show-*
for status in 0 7 130; do
  : >"$TEST_LOG"
  actual=0
  "$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" --plain "echo 'quoted argument' >>\"\$TEST_LOG\"; exit $status" || actual=$?
  [[ $actual == "$status" ]] || fail "plain exit status" "$actual"
  [[ $(grep -c '^quoted argument$' "$TEST_LOG") == 1 ]] || fail "plain command executes once"
  if (( status == 130 )); then
    ! grep -q '^done:' "$TEST_LOG" || fail "cancel skips completion prompt"
  else
    grep -q "^done:$status$" "$TEST_LOG" || fail "completion receives exit status"
  fi
done
pass "plain presentation preserves quoting, execution count and exit statuses"
