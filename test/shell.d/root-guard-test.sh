#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# fakeroot reports EUID 0 without granting privileges, so the guard can be
# exercised for real instead of asserting that the source contains a pattern.
require_command fakeroot

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

# Every command these scripts reach for before their first prompt. A script
# whose guard went missing would log a call here rather than install packages
# or rewrite configuration on the machine running the suite.
for stub in sudo pacman systemctl omarchy-pkg-add omarchy-cmd-missing \
  omarchy-plugin-enable omarchy-webapp-install tailscale ufw gum curl; do
  cat >"$stub_bin/$stub" <<STUB
#!/bin/bash
printf '$stub %s\n' "\$*" >>"\${CALL_LOG:?}"
STUB
done
chmod +x "$stub_bin"/*

guarded_commands() {
  printf '%s\n' \
    "$ROOT/bin/omarchy-install-service-tailscale" \
    "$ROOT/bin/omarchy-setup-security-sshd"
}

while read -r command; do
  name=$(basename "$command")
  call_log="$test_dir/$name.calls"
  : >"$call_log"

  status=0
  output=$(
    CALL_LOG="$call_log" HOME="$test_dir/home" PATH="$stub_bin:$PATH" \
      fakeroot bash "$command" 2>&1
  ) || status=$?

  (( status == 1 )) ||
    fail "$name refuses to run as root" "expected exit 1, got $status: $output"
  grep -qF "without sudo" <<<"$output" ||
    fail "$name explains that it wants the desktop user" "$output"
  [[ ! -s $call_log ]] ||
    fail "$name does nothing before refusing" "$(<"$call_log")"
done < <(guarded_commands)

pass "tailscale and sshd setup commands refuse to run as root"
