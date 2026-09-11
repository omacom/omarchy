#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

# The splash and the menu are stubs here on purpose. What is under test is
# whether they are reached at all, and reaching them wrongly is the failure that
# breaks file transfers and automation.
mkdir -p "$workdir/stub"
cat >"$workdir/stub/omarchy-server-splash" <<'STUB'
#!/bin/bash
echo "SPLASH"
exit "${STUB_SPLASH_EXIT:-1}"
STUB
cat >"$workdir/stub/omarchy-server-menu" <<'STUB'
#!/bin/bash
echo "MENU"
STUB
chmod +x "$workdir/stub/omarchy-server-splash" "$workdir/stub/omarchy-server-menu"

export XDG_STATE_HOME="$workdir/state"
mkdir -p "$XDG_STATE_HOME/omarchy"

edition_file="$workdir/omarchy-edition"
printf 'server\n' >"$edition_file"

hook="$ROOT/default/bash/server-greet"

# A pty is what separates an arrival from a transfer, so the interactive cases
# have to be run under one to mean anything. util-linux script and BSD script
# take incompatible arguments, so this borrows Python's pty instead of picking
# a side.
require_command python3

cat >"$workdir/pty-run" <<'PTY'
import pty
import sys

sys.exit(pty.spawn(sys.argv[1:]))
PTY

greet_on_pty() {
  python3 "$workdir/pty-run" env \
    PATH="$workdir/stub:$ROOT/bin:$PATH" \
    HOME="$workdir" \
    XDG_STATE_HOME="$XDG_STATE_HOME" \
    OMARCHY_EDITION_FILE="$edition_file" \
    ${@+"$@"} \
    bash --norc --noprofile -i -c "source '$hook'" 2>/dev/null | tr -d '\r'
}

# ---- the cases that must stay silent -------------------------------------

# Non-interactive is what scp, sftp, rsync and `ssh host <command>` all are.
output=$(env -i PATH="$workdir/stub:$ROOT/bin:$PATH" HOME="$workdir" \
  XDG_STATE_HOME="$XDG_STATE_HOME" OMARCHY_EDITION_FILE="$edition_file" \
  bash --norc --noprofile -c "source '$hook'" 2>&1)
[[ -z $output ]] || fail "a non-interactive shell greets nobody" "$output"
pass "a non-interactive shell stays silent, which is what scp and rsync are"

output=$(greet_on_pty SSH_ORIGINAL_COMMAND="rsync --server -vlogDtpre.iLsfxCIvu . /tmp")
[[ $output != *SPLASH* && $output != *MENU* ]] ||
  fail "a forced or explicit remote command greets nobody" "$output"
pass "an explicit remote command stays silent"

output=$(greet_on_pty SSH_CONNECTION="10.0.0.9 51000 10.0.0.7 22")
[[ $output != *SPLASH* && $output != *MENU* ]] ||
  fail "an ssh session with no pty greets nobody" "$output"
pass "ssh without a pty stays silent"

output=$(greet_on_pty TMUX="/tmp/tmux-1000/default,1234,0")
[[ $output != *SPLASH* && $output != *MENU* ]] ||
  fail "attaching to tmux is a reconnection, not an arrival" "$output"
pass "tmux attach stays silent"

output=$(greet_on_pty OMARCHY_BBS_SESSION=1)
[[ $output != *SPLASH* && $output != *MENU* ]] ||
  fail "a shell opened from inside the front door does not greet again" "$output"
pass "a nested shell inside the front door stays silent"

# ---- the edition and the mode --------------------------------------------

printf 'desktop\n' >"$edition_file"
output=$(greet_on_pty)
[[ $output != *SPLASH* && $output != *MENU* ]] ||
  fail "the desktop edition greets nobody" "$output"
pass "the desktop edition stays silent"

rm -f "$edition_file"
output=$(greet_on_pty)
[[ $output != *SPLASH* && $output != *MENU* ]] ||
  fail "a machine with no edition marker greets nobody" "$output"
pass "an unmarked machine stays silent"

printf 'server\n' >"$edition_file"
printf 'off\n' >"$XDG_STATE_HOME/omarchy/server-greet"
output=$(greet_on_pty)
[[ $output != *SPLASH* && $output != *MENU* ]] ||
  fail "greet off greets nobody" "$output"
pass "greet off stays silent"

# ---- the cases that must greet -------------------------------------------

rm -f "$XDG_STATE_HOME/omarchy/server-greet"
output=$(greet_on_pty)
[[ $output == *SPLASH* ]] || fail "an interactive login on a server sees the splash" "$output"
[[ $output != *MENU* ]] || fail "the splash does not open the menu on its own" "$output"
pass "an interactive login defaults to the splash"

output=$(greet_on_pty SSH_CONNECTION="10.0.0.9 51000 10.0.0.7 22" SSH_TTY=/dev/pts/3)
[[ $output == *SPLASH* ]] || fail "an ssh session with a pty sees the splash" "$output"
pass "ssh with a pty sees the splash"

# The splash reports the choice through its exit status, so a splash that dies
# lands the caller in a shell rather than a menu they did not ask for.
output=$(greet_on_pty STUB_SPLASH_EXIT=0)
[[ $output == *SPLASH* && $output == *MENU* ]] ||
  fail "choosing the menu from the splash opens it" "$output"
pass "choosing the menu from the splash opens it"

printf 'menu\n' >"$XDG_STATE_HOME/omarchy/server-greet"
output=$(greet_on_pty)
[[ $output == *MENU* ]] || fail "greet menu opens the menu directly" "$output"
[[ $output != *SPLASH* ]] || fail "greet menu skips the splash" "$output"
pass "greet menu skips the splash and opens the menu"

# ---- the splash itself ---------------------------------------------------

# Rendering is the easy half. The half worth testing is that nothing reaches
# stderr, because a login shell shows it, and that no reading can wedge the
# draw: every value here is unavailable on a machine that has no /proc, which
# is the same path a hung daemon takes.
cat >"$workdir/stub/omarchy-theme-color" <<'STUB'
#!/bin/bash
printf 'accent\t#7aa2f7\nforeground\t#a9b1d6\ndark_foreground\t#565f89\n'
printf 'muted\t#414868\nbright_foreground\t#c0caf5\nbright_magenta\t#bb9af7\n'
printf 'yellow\t#e0af68\ngreen\t#9ece6a\nbright_yellow\t#ff9e64\n'
printf 'bright_cyan\t#0db9d7\nred\t#f7768e\nselection\t#292e42\n'
printf 'darker_background\t#0e0e14\n'
STUB
chmod +x "$workdir/stub/omarchy-theme-color"

splash_stderr="$workdir/splash.err"
# By path, not by name: the guard stubs above are still first on PATH, and they
# are what those cases needed.
splash_out=$(PATH="$workdir/stub:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  "$ROOT/bin/omarchy-server-splash" --no-input 2>"$splash_stderr") && splash_status=0 || splash_status=$?

(( splash_status == 1 )) ||
  fail "the splash reports a shell when it cannot ask" "exit $splash_status"
pass "a splash that cannot ask for input lands the caller in a shell"

[[ ! -s $splash_stderr ]] ||
  fail "the splash writes nothing to stderr, which a login shell would show" \
    "$(cat "$splash_stderr")"
pass "the splash writes nothing to stderr"

for expected in "OMARCHY SERVER" "UPTIME" "LOAD" "MEM" "DISK" "KERNEL" \
  "services up" "containers up" "callers today"; do
  [[ $splash_out == *"$expected"* ]] ||
    fail "the splash draws the whole status block" "$expected is missing"
done
pass "the splash draws the whole status block"

# The wordmark is 81 columns. Wrapping it reads as damage, so a narrow terminal
# gets the header alone.
narrow=$(PATH="$workdir/stub:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  COLUMNS=60 "$ROOT/bin/omarchy-server-splash" --no-input 2>/dev/null || true)
[[ $narrow != *"▀█████▀"* ]] || fail "a narrow terminal gets no wordmark to wrap"
[[ $narrow == *"OMARCHY SERVER"* ]] || fail "a narrow terminal still gets the header"
pass "the wordmark is dropped rather than wrapped on a narrow terminal"

# Byte-oriented tools mangle the box-drawing characters: the rule character is
# three bytes in UTF-8, and a substitution that replaces only the first emits
# sequences a terminal draws as missing glyphs. Cheap to reintroduce, invisible
# in review, obvious on a screen.
printf '%s' "$splash_out" | python3 -c '
import sys

data = sys.stdin.buffer.read()
try:
    text = data.decode("utf-8")
except UnicodeDecodeError as broken:
    sys.exit("splash emitted invalid UTF-8: %s" % broken)

if "\u2550" not in text:
    sys.exit("splash drew no rule")
if "\ufffd" in text:
    sys.exit("splash emitted a replacement character")
' || fail "the splash draws box characters whole"
pass "the splash emits well-formed UTF-8 for its box characters"

ascii_out=$(PATH="$workdir/stub:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_BBS_UNICODE=0 "$ROOT/bin/omarchy-server-splash" --no-input 2>/dev/null || true)
LC_ALL=C printf '%s' "$ascii_out" | grep -q '[^[:print:][:space:]'$'\033'']' &&
  fail "the ASCII fallback stays inside ASCII"
[[ $ascii_out == *"===="* ]] || fail "the ASCII fallback still draws a rule"
pass "the ASCII fallback stays inside ASCII and still draws its rule"
