#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

mkdir -p "$workdir/stub"
cat >"$workdir/stub/omarchy-theme-color" <<'STUB'
#!/bin/bash
printf 'accent\t#7aa2f7\nforeground\t#a9b1d6\ndark_foreground\t#565f89\n'
printf 'muted\t#414868\nbright_foreground\t#c0caf5\nbright_magenta\t#bb9af7\n'
printf 'yellow\t#e0af68\ngreen\t#9ece6a\nbright_yellow\t#ff9e64\n'
printf 'bright_cyan\t#0db9d7\nred\t#f7768e\nselection\t#292e42\n'
printf 'darker_background\t#0e0e14\n'
STUB
cat >"$workdir/stub/omarchy-theme-current" <<'STUB'
#!/bin/bash
echo "Tokyo Night"
STUB
chmod +x "$workdir/stub"/*

# Through env, not as an assignment prefix: bash decides what is an assignment
# before expanding "$@", so a VAR=value arriving that way is taken as the
# command name instead.
menu() {
  env PATH="$workdir/stub:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    XDG_CONFIG_HOME="$workdir/config" \
    ${@+"$@"} "$ROOT/bin/omarchy-server-menu" --no-input 2>/dev/null || true
}

# Colour lands between the words: "[S] STATUS" is drawn as an escape, "[S]", a
# reset, a space, another escape, then "STATUS". Assertions about what the menu
# says have to read what it says, not how it looks.
strip_ansi() {
  sed $'s/\033\\[[0-9;]*[A-Za-z]//g'
}

wide=$(menu COLUMNS=100)
wide_plain=$(printf '%s' "$wide" | strip_ansi)

for entry in "[S] STATUS" "[D] DOCKER" "[V] SERVICES" "[U] UPDATE" "[L] LOGS" \
  "[B] BACKUP" "[N] NETWORK" "[T] THEME" "[Q] QUIT TO SHELL"; do
  [[ $wide_plain == *"$entry"* ]] || fail "every door is listed with its hotkey" "$entry is missing"
done
pass "every door is listed with its hotkey"

for pane in "MAIN MENU" "MAIN" "SYSTEM" "MOTD"; do
  [[ $wide_plain == *"$pane"* ]] || fail "the menu draws its panes" "$pane is missing"
done
[[ $wide_plain == *"select"* && $wide_plain == *"jump"* ]] || fail "the menu draws its key legend"
pass "the menu draws both panes and the key legend"

# A board with more than one line numbered them and told the caller which one
# they were on, which is the same fact as concurrent sessions.
signed=$(menu COLUMNS=100 USER=sysop | strip_ansi)
[[ $signed == *"sysop@"* ]] || fail "the footer names who is calling"
[[ $signed =~ node\ [0-9]+ ]] || fail "the footer names which node they are on"
pass "the footer names the caller and their node"

# Colour is invisible to width arithmetic, so a border that lines up on the
# author's terminal can still be a column out. Measuring is the only way this
# stays true, and it is the failure a reader cannot see in a diff.
printf '%s' "$wide" | python3 -c '
import re
import sys

strip = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")
widths = {}

for number, line in enumerate(sys.stdin.read().split("\n")):
    plain = strip.sub("", line)
    stripped = plain.strip()
    if not stripped.startswith(("│", "┌", "└")):
        continue
    # Rows carrying both panes are the ones that must agree.
    if stripped.count("│") + stripped.count("┌") + stripped.count("└") < 3:
        continue
    widths.setdefault(len(plain), []).append(number)

if not widths:
    sys.exit("no framed rows were drawn")
if len(widths) > 1:
    sys.exit("framed rows disagree on width: %r" % widths)
' || fail "every framed row is the same width"
pass "every framed row lines up"

[[ $wide_plain == *"▌"* ]] || fail "the selected row is marked"
pass "the selected row is marked"

# The backup engine is unbuilt; the door and its status line are wired to a stub
# so the menu matches its design rather than carrying a hole.
[[ $wide_plain == *"none yet"* ]] || fail "the backup entry shows its stub status"
pass "the backup entry shows its stub status"

printf '%s' "$wide" | python3 -c '
import sys

data = sys.stdin.buffer.read()
try:
    text = data.decode("utf-8")
except UnicodeDecodeError as broken:
    sys.exit("menu emitted invalid UTF-8: %s" % broken)
if "�" in text:
    sys.exit("menu emitted a replacement character")
' || fail "the menu draws box characters whole"
pass "the menu emits well-formed UTF-8"

ascii_menu=$(menu COLUMNS=100 OMARCHY_BBS_UNICODE=0)
LC_ALL=C printf '%s' "$ascii_menu" | grep -q '[^[:print:][:space:]'$'\033'']' &&
  fail "the ASCII fallback stays inside ASCII"
[[ $(printf '%s' "$ascii_menu" | strip_ansi) == *"[S] STATUS"* ]] || fail "the ASCII fallback still lists the doors"
pass "the ASCII fallback stays inside ASCII and still lists the doors"

# Two panes need the width for two panes. A narrow terminal gets the list.
narrow=$(menu COLUMNS=70)
narrow_plain=$(printf '%s' "$narrow" | strip_ansi)
[[ $narrow_plain != *"MOTD"* ]] || fail "a narrow terminal drops the second pane"
[[ $narrow_plain == *"[S] STATUS"* ]] || fail "a narrow terminal still lists the doors"
pass "the second pane is dropped rather than wrapped on a narrow terminal"

# A machine's own message of the day, when it has one.
mkdir -p "$workdir/config/omarchy"
printf 'Reboot me on Sunday.\n' >"$workdir/config/omarchy/motd"
[[ $(menu COLUMNS=100 | strip_ansi) == *"Reboot me on Sunday."* ]] ||
  fail "the menu shows the machine's motd when it has one"
pass "the menu shows the machine's motd"

[[ $(PATH="$workdir/stub:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  "$ROOT/bin/omarchy-server-menu" </dev/null 2>&1 >/dev/null || true) == *"needs a terminal"* ]] ||
  fail "the menu refuses to run without a terminal rather than drawing into a pipe"
pass "the menu refuses to run without a terminal"

# A long value used to push its border out on that row alone. Hostnames,
# interface lists and themes are all longer on somebody else's machine, so the
# frame has to hold regardless of what the readings say.
long_host=$(mktemp -d)
cat >"$long_host/uname" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "-n" ]]; then
  echo "a-very-long-hostname-that-will-not-fit.example.internal"
else
  exec /usr/bin/uname "$@"
fi
STUB
cat >"$long_host/omarchy-theme-current" <<'STUB'
#!/bin/bash
echo "A Theme Name Far Longer Than Its Column Allows"
STUB
chmod +x "$long_host"/*

stretched=$(env PATH="$long_host:$workdir/stub:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  XDG_CONFIG_HOME="$workdir/config" COLUMNS=100 \
  "$ROOT/bin/omarchy-server-menu" --no-input 2>/dev/null || true)

printf '%s' "$stretched" | python3 -c '
import re
import sys

strip = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")
widths = {}

for number, line in enumerate(sys.stdin.read().split("\n")):
    plain = strip.sub("", line)
    stripped = plain.strip()
    if not stripped.startswith(("│", "┌", "└")):
        continue
    if stripped.count("│") + stripped.count("┌") + stripped.count("└") < 3:
        continue
    widths.setdefault(len(plain), []).append(number)

if len(widths) > 1:
    sys.exit("a long reading pushed a border out: %r" % widths)
' || fail "a long reading is truncated rather than stretching its box"
pass "long readings are truncated rather than stretching their box"

rm -rf "$long_host"
