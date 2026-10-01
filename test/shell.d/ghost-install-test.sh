#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/home"
export TEST_LOG="$tmp_dir/log"
export HOME="$tmp_dir/home"

# Package installation and the user manager are stubbed; the script's job is
# the order between them.
cat >"$tmp_dir/bin/omarchy-pkg-add" <<'SCRIPT'
#!/bin/bash
printf 'add:%s\n' "$*" >>"$TEST_LOG"
SCRIPT
cat >"$tmp_dir/bin/systemctl" <<'SCRIPT'
#!/bin/bash
printf 'systemctl:%s\n' "$*" >>"$TEST_LOG"
SCRIPT
# The HUD is an omarchy-shell plugin, so the install also talks to the running
# shell. Both are stubbed; the script's job is the order between them.
cat >"$tmp_dir/bin/omarchy-shell" <<'SCRIPT'
#!/bin/bash
printf 'omarchy-shell:%s\n' "$*" >>"$TEST_LOG"
SCRIPT
cat >"$tmp_dir/bin/omarchy" <<'SCRIPT'
#!/bin/bash
printf 'omarchy:%s\n' "$*" >>"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/bin"/*
export PATH="$tmp_dir/bin:$PATH"

: >"$TEST_LOG"
"$ROOT/bin/omarchy-install-ai-ghost" >"$tmp_dir/output" 2>&1 || fail "Ghost install succeeds" "$(cat "$tmp_dir/output")"

grep -q '^add:ghost$' "$TEST_LOG" || fail "Ghost install adds the ghost package"
pass "Ghost install adds the ghost package"

grep -q '^systemctl:--user enable --now ghostd.service$' "$TEST_LOG" ||
  fail "Ghost install enables and starts the daemon unit"
pass "Ghost install enables and starts the daemon unit"

grep -q '^omarchy:plugin enable ferdousbhai.ghost$' "$TEST_LOG" ||
  fail "Ghost install enables the HUD plugin in the running shell"
pass "Ghost install enables the HUD plugin in the running shell"

[[ -L $HOME/.config/omarchy/plugins/ferdousbhai.ghost ]] ||
  fail "Ghost install links the packaged plugin into the user's plugins directory"
pass "Ghost install links the packaged plugin into the user's plugins directory"

[[ $(grep -n '^add:ghost$' "$TEST_LOG" | cut -d: -f1) -lt $(grep -n 'enable --now' "$TEST_LOG" | cut -d: -f1) ]] ||
  fail "Ghost install starts the daemon only after the package is present"
pass "Ghost install starts the daemon only after the package is present"

grep -q 'Super + Ctrl + G' "$tmp_dir/output" || fail "Ghost install names the summon key"
pass "Ghost install names the summon key"

# A real directory where the plugin symlink belongs — an older install, or a
# manual copy — must not be silently linked *inside*. `ln -sfn` does exactly
# that and reports success, leaving a plugin the shell cannot load.
rm -rf "$HOME/.config/omarchy/plugins/ferdousbhai.ghost"
mkdir -p "$HOME/.config/omarchy/plugins/ferdousbhai.ghost"
: >"$TEST_LOG"
rc=0
"$ROOT/bin/omarchy-install-ai-ghost" >/dev/null 2>&1 || rc=$?
[[ $rc != 0 ]] || fail "Ghost install refuses a real directory in place of the plugin link"
[[ ! -e $HOME/.config/omarchy/plugins/ferdousbhai.ghost/plugin ]] ||
  fail "Ghost install refuses a real directory in place of the plugin link" "nested the link inside it"
pass "Ghost install refuses a real directory in place of the plugin link"
rm -rf "$HOME/.config/omarchy/plugins/ferdousbhai.ghost"

# A failed package install must not try to start units that do not exist.
cat >"$tmp_dir/bin/omarchy-pkg-add" <<'SCRIPT'
#!/bin/bash
printf 'add:%s\n' "$*" >>"$TEST_LOG"
exit 1
SCRIPT
: >"$TEST_LOG"
rc=0
"$ROOT/bin/omarchy-install-ai-ghost" >/dev/null 2>&1 || rc=$?
[[ $rc != 0 ]] || fail "Ghost install aborts when the package cannot be added"
! grep -q 'enable --now' "$TEST_LOG" || fail "Ghost install aborts when the package cannot be added" "units enabled anyway"
pass "Ghost install aborts when the package cannot be added"
