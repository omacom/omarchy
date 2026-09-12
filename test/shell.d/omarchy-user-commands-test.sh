#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

cli="$ROOT/bin/omarchy"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_home="$test_tmp/home"
mkdir -p "$fake_home"
user_bin="$fake_home/.local/bin"

run_cli() {
  HOME="$fake_home" "$cli" "$@"
}

# A missing user bin dir is a no-op, not an error.
run_cli commands >/dev/null || fail "commands works without a user bin dir"
pass "commands works without a user bin dir"

mkdir -p "$user_bin"

cat >"$user_bin/omarchy-zzuser-hello" <<'SH'
#!/bin/bash
# omarchy:summary=Greet from the user bin dir
# omarchy:args=[name]
echo "user-hello-ran args=[$*]"
SH
chmod +x "$user_bin/omarchy-zzuser-hello"

output=$(run_cli zzuser hello)
[[ $output == *"user-hello-ran args=[]"* ]] || fail "user command routes and executes" "$output"
pass "user command routes and executes"

output=$(run_cli zzuser hello --help)
[[ $output == *"Greet from the user bin dir"* ]] || fail "user command metadata renders in help" "$output"
[[ $output == *"omarchy-zzuser-hello"* ]] || fail "user command help names its binary" "$output"
pass "user command metadata renders in help"

output=$(run_cli zzuser --help)
[[ $output == *"omarchy zzuser hello"* ]] || fail "group help lists the user command" "$output"
[[ $output == *"Greet from the user bin dir"* ]] || fail "group help shows the user summary" "$output"
pass "group help lists the user command"

output=$(run_cli zzuser)
[[ $output == *"omarchy zzuser hello"* ]] || fail "bare group renders help including the user command" "$output"
pass "bare group renders help including the user command"

run_cli commands --json | grep -Fq "omarchy-zzuser-hello" || fail "user command appears in commands --json"
pass "user command appears in commands --json"

run_cli commands --check >/dev/null || fail "commands --check passes with a user command"
pass "commands --check passes with a user command"

# A stale or hostile user file must never shadow a packaged binary.
cat >"$user_bin/omarchy-menu" <<'SH'
#!/bin/bash
# omarchy:summary=PWNED user menu
echo "PWNED user menu ran"
SH
chmod +x "$user_bin/omarchy-menu"

cat >"$user_bin/omarchy-theme-list" <<'SH'
#!/bin/bash
# omarchy:summary=PWNED theme list
echo "PWNED theme list ran"
SH
chmod +x "$user_bin/omarchy-theme-list"

# A user alias claiming a packaged route is a collision too.
cat >"$user_bin/omarchy-zzuser-sneaky" <<'SH'
#!/bin/bash
# omarchy:summary=Sneaky user alias
# omarchy:alias=omarchy menu
echo "sneaky ran"
SH
chmod +x "$user_bin/omarchy-zzuser-sneaky"

output=$(run_cli menu --help)
[[ $output != *"PWNED"* && $output != *"Sneaky"* ]] || fail "user files do not shadow omarchy menu help" "$output"
[[ $output == *"omarchy-menu"* ]] || fail "menu help still renders the shipped command" "$output"
pass "shipped omarchy menu wins over colliding user files"

output=$(run_cli theme list 2>/dev/null)
[[ $output != *"PWNED"* ]] || fail "user file does not shadow theme list dispatch" "$output"
pass "shipped theme list wins over a colliding user file"

if run_cli commands --json | grep -Fq "PWNED"; then
  fail "colliding user files stay out of the command listing"
fi
if run_cli commands --json | grep -Fq "Sneaky user alias"; then
  fail "user file with a colliding alias stays out of the command listing"
fi
pass "colliding user files stay out of the command listing"

# Only regular files owned by the user and executable participate.
cat >"$user_bin/omarchy-zzuser-noexec" <<'SH'
#!/bin/bash
# omarchy:summary=Not executable
echo "should never run"
SH
chmod 644 "$user_bin/omarchy-zzuser-noexec"

ln -s omarchy-zzuser-hello "$user_bin/omarchy-zzuser-link"
mkdir -p "$user_bin/omarchy-zzuser-dir"
echo "not a command" >"$user_bin/README"

output=$(run_cli zzuser --help)
[[ $output != *"Not executable"* ]] || fail "non-executable user file is skipped" "$output"
[[ $output != *"zzuser link"* ]] || fail "user symlink is skipped" "$output"
pass "non-executable files and symlinks are skipped"

if run_cli commands --json | grep -Fq "omarchy-zzuser-noexec"; then
  fail "non-executable user file stays out of commands --json"
fi
if run_cli commands --json | grep -Fq "omarchy-zzuser-link"; then
  fail "user symlink stays out of commands --json"
fi
pass "skipped user files stay out of commands --json"

if run_cli zzuser noexec >/dev/null 2>&1; then
  fail "skipped user file does not route"
fi
pass "skipped user file does not route"

run_cli commands --check >/dev/null || fail "commands --check passes with skipped user files present"
pass "commands --check passes with skipped user files present"
