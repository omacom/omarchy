#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command xkbcli

tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] ||
  fail "the test gets a temporary directory to stub Hyprland in"
trap 'rm -rf "$tmpdir"' EXIT

task_home="$tmpdir/home"
stub_bin="$tmpdir/bin"
mkdir -p "$task_home/.config" "$stub_bin"
cp -r "$ROOT/config/hypr" "$task_home/.config/hypr"

# Exercise the real menu against a live-registry protocol fixture. The menu
# must not execute the user config or a separate Lua interpreter.
lua_bind() {
  local identity="$2"
  if [[ $3 == "Close window" && ( $2 == "SUPER + W" || $2 == "SUPER + Q" ) ]]; then identity=close; fi
  if [[ $3 == "Toggle scratchpad" ]]; then identity=scratchpad; fi
  jq -nc --arg keys "$2" --arg description "$3" --arg identity "$identity" \
    '{keys:$keys,description:$description,identity:$identity,submap:""}'
}

exec_bind() {
  jq -nc --arg keys "$2" --arg description "$3" --arg identity "$4" \
    '{keys:$keys,description:$description,identity:$identity,submap:""}'
}

stub_hyprctl() {
  jq -s '{generation:"abc-def",bindings:to_entries|map(.value + {id:(.key+1)})}' >"$tmpdir/snapshot.json"
  cat >"$stub_bin/hyprctl" <<STUB
#!/bin/bash
case "\$1" in
  repl) cat "$tmpdir/snapshot.json" ;;
  dispatch) printf '%s\\n' "\$2" >"$tmpdir/dispatch" ;;
  *) exit 1 ;;
esac
STUB
  chmod +x "$stub_bin/hyprctl"
}

keybindings() {
  env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$task_home" \
    XDG_CACHE_HOME="$tmpdir/cache" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-menu-keybindings" --print
}

# Closing a window and toggling the scratchpad are two of the actions Omarchy
# binds twice on purpose. The last bind carries the longest description Omarchy
# ships, which is what puts a row closest to the width the menu allows.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + W" "Close window")
$(lua_bind 64 "SUPER + Q" "Close window")
$(lua_bind 64 "SUPER + F" "Full screen")
$(lua_bind 64 "SUPER + S" "Toggle scratchpad")
$(lua_bind 64 "SUPER + grave" "Toggle scratchpad")
$(exec_bind 73 "SUPER SHIFT ALT + 0" "Move window silently to workspace 10" "true")
BINDS

rendered=$(keybindings)
[[ -n $rendered ]] || fail "the keybindings menu renders with a stubbed Hyprland"

grep -q 'SUPER + F  *→ Full screen' <<<"$rendered" ||
  fail "a chord with no alternative renders on its own" "$rendered"
pass "the keybindings menu renders its entries"

(( $(grep -c '→ Close window$' <<<"$rendered") == 1 )) ||
  fail "an alternative chord joins the row of the first one" "$rendered"
grep -q 'SUPER + W / SUPER + Q  *→ Close window' <<<"$rendered" ||
  fail "a shared row names both chords" "$rendered"
pass "an alternative chord joins the row of the first one"

# Which chord leads is the whole point of keeping Hyprland's order: SUPER + W is
# the documented default and SUPER + Q the alternative bound after it.
grep -q '^SUPER + W / SUPER + Q' <<<"$rendered" ||
  fail "the chord declared first leads a shared row" "$rendered"
pass "the chord declared first leads a shared row"

# Hyprland calls the key left of 1 "grave". Nobody reads their keyboard that way.
grep -q 'SUPER + S / SUPER + ~  *→ Toggle scratchpad' <<<"$rendered" ||
  fail "the grave key reads as the symbol printed on it" "$rendered"
! grep -q 'grave' <<<"$rendered" ||
  fail "no entry still says grave" "$rendered"
pass "the grave key reads as the symbol printed on it"

# Monospace menu: every arrow sits in one column, and nothing is allowed past
# it. A row that overruns pushes its own arrow out of line.
[[ $(awk -F '→' '{ print length($1) }' <<<"$rendered" | sort -u) == "36" ]] ||
  fail "every entry pads its chords to the same column" "$rendered"
pass "every entry pads its chords to the same column"

# The menu elides a row that outgrows its card: 754px of label, 78 monospace
# characters at the heading size. The longest entry Omarchy ships sits at 74, so
# a row has four characters of room and no more.
(( $(awk '{ print length($0) }' <<<"$rendered" | sort -rn | head -1) <= 78 )) ||
  fail "no entry outgrows the width the menu gives it" "$rendered"
pass "no entry outgrows the width the menu gives it"

# Priority ordering reads the row, and the chord sharing it must not reclassify
# the entry: XF86Calculator alone belongs in the tail the menu keeps for media
# keys, while the calculator itself sits in the body of the list.
stub_hyprctl <<BINDS
$(exec_bind 68 "SUPER CTRL + Q" "Calculator" "omacalc")
$(exec_bind 0 "XF86Calculator" "Calculator" "omacalc")
$(exec_bind 8 "ALT + TAB" "Reveal active window on top" "true")
BINDS

rendered=$(keybindings)
(( $(grep -n '→ Calculator$' <<<"$rendered" | cut -d: -f1) <
   $(grep -n '→ Reveal active window on top$' <<<"$rendered" | cut -d: -f1) )) ||
  fail "a shared chord does not change where its entry ranks" "$rendered"
pass "a shared chord does not change where its entry ranks"

# The same key written as a keycode arrives by the other road: Hyprland reports
# the code and the keymap resolves it, after the rename above has run.
stub_hyprctl <<BINDS
$(exec_bind 64 "SUPER + code:49" "Toggle scratchpad" "true")
BINDS

rendered=$(keybindings)
grep -q 'SUPER + ~  *→ Toggle scratchpad' <<<"$rendered" ||
  fail "a keycode resolves to the symbol printed on the key too" "$rendered"
pass "a keycode resolves to the symbol printed on the key too"

# A chord refused for width opens a row of its own, and the next chord tries
# that row rather than reaching back past it and printing out of order.
stub_hyprctl <<BINDS
$(exec_bind 64 "SUPER + A" "Calculator" "omacalc")
$(exec_bind 77 "SUPER SHIFT CTRL ALT + BACKSPACE" "Calculator" "omacalc")
$(exec_bind 64 "SUPER + B" "Calculator" "omacalc")
BINDS

rendered=$(keybindings)
(( $(grep -c '→ Calculator$' <<<"$rendered") == 3 )) ||
  fail "a refused chord does not let the next one jump the queue" "$rendered"
pass "a refused chord does not let the next one jump the queue"

# Sharing a row is something Omarchy names an action for, not something two
# chords earn by looking alike. Alt + Tab and Shift + Alt + Tab both read
# "Reveal active window on top" and cycle opposite ways.
stub_hyprctl <<BINDS
$(exec_bind 64 "SUPER + Y" "Zoom in" "omarchy-zoom in")
$(exec_bind 64 "SUPER + Z" "Zoom in" "omarchy-zoom in")
BINDS

rendered=$(keybindings)
(( $(grep -c '→ Zoom in$' <<<"$rendered") == 2 )) ||
  fail "an action Omarchy did not name keeps its chords on separate rows" "$rendered"
pass "an action Omarchy did not name keeps its chords on separate rows"

# Even a named action gives up the shared row rather than overrun the column:
# two rows in line beat one that juts out of it.
stub_hyprctl <<BINDS
$(exec_bind 73 "SUPER SHIFT ALT + BACKSPACE" "Calculator" "omacalc")
$(exec_bind 69 "SUPER SHIFT CTRL + BACKSPACE" "Calculator" "omacalc")
BINDS

rendered=$(keybindings)
(( $(grep -c '→ Calculator$' <<<"$rendered") == 2 )) ||
  fail "chords too wide to share a row stay on their own" "$rendered"
[[ $(awk -F '→' '{ print length($1) }' <<<"$rendered" | sort -u) == "36" ]] ||
  fail "chords too wide to share a row leave the column alone" "$rendered"
pass "chords too wide to share a row stay on their own"

# A shared label is not a shared action. Two chords that merely read alike have
# to stay apart, or the menu hides one of them behind the other.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + W" "Close window")
$(exec_bind 64 "SUPER + X" "Close window" "omarchy-hyprland-window-close-all")
BINDS

rendered=$(keybindings)
(( $(grep -c '→ Close window$' <<<"$rendered") == 2 )) ||
  fail "chords with the same label but different actions stay apart" "$rendered"
pass "chords with the same label but different actions stay apart"

# An unresolved Lua bind reports no dispatcher at all, so nothing says the two
# chords run the same thing, whatever their label promises.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + Y" "Close window")
$(lua_bind 64 "SUPER + Z" "Close window")
BINDS

rendered=$(keybindings)
(( $(grep -c '→ Close window$' <<<"$rendered") == 2 )) ||
  fail "chords whose dispatch is unknown stay apart" "$rendered"
pass "chords whose dispatch is unknown stay apart"

# What the menu is expected to pair up, written out here rather than read from
# the script, so dropping an action from the list fails instead of shrinking
# what gets checked.
expected_alternatives=(
  "Close window"
  "Calculator"
  "Toggle scratchpad"
  "Move window to scratchpad"
)

eval "$(sed -n '/^alternative_chord_actions()/,/^}/p' "$ROOT/bin/omarchy-menu-keybindings")"

[[ $(alternative_chord_actions) == "$(printf '%s\n' "${expected_alternatives[@]}")" ]] ||
  fail "the menu pairs up the actions Omarchy means it to" "$(alternative_chord_actions)"
pass "the menu pairs up the actions Omarchy means it to"

# A renamed description would leave an action named here matching nothing, and
# the row it was meant to share would quietly split in two. Only real binds
# count: a commented-out example is not a second chord.
for action in "${expected_alternatives[@]}"; do
  (( $(grep -rhE '^[[:space:]]*o\.bind\(' "$ROOT/default/hypr/bindings" |
       grep -cF ", \"$action\",") >= 2 )) ||
    fail "every action named as having an alternative is bound twice" "$action"
done
pass "every action named as having an alternative is bound twice"

# Record attempts even if the menu were to ignore the interpreter's failure.
# The real configuration-loop regression belongs to the VM acceptance test.
cat >"$stub_bin/lua" <<STUB
#!/bin/bash
touch "$tmpdir/lua-called"
exit 99
STUB
chmod +x "$stub_bin/lua"
keybindings >/dev/null || fail "listing needs no external Lua interpreter"
[[ ! -e $tmpdir/lua-called ]] || fail "listing must not start an external Lua interpreter"
pass "listing never starts an external Lua interpreter"

stub_hyprctl <<'BINDS'
{"keys":"MOD3 + code:20","description":"Quotes \"and\", backslashes \\ and Unicode →","identity":1,"submap":""}
{"keys":"SUPER + F12","description":"Duplicate","identity":2,"submap":""}
{"keys":"SUPER + F12","description":"Duplicate","identity":3,"submap":""}
{"keys":"SUPER + F11","description":"line\nbreak\ttab\u001fseparator","identity":4,"submap":""}
BINDS
rendered=$(keybindings)
grep -F 'Quotes "and", backslashes \ and Unicode →' <<<"$rendered" >/dev/null || fail "punctuation remains display data"
grep -q 'MOD3 + MINUS' <<<"$rendered" || fail "extra modifiers and keycodes survive"
grep -q 'Duplicate \[2\]$' <<<"$rendered" || fail "identically labeled actions are independently selectable"
grep -q 'line break tab separator$' <<<"$rendered" || fail "control characters cannot forge menu records"
pass "punctuation, modifiers, duplicate labels and control characters are handled"

cat >"$stub_bin/omarchy-menu-select" <<'STUB'
#!/bin/bash
grep 'Duplicate \[2\]$'
STUB
chmod +x "$stub_bin/omarchy-menu-select"
cat >"$stub_bin/omarchy-notification-send" <<STUB
#!/bin/bash
printf '%s\n' "\$@" >>"$tmpdir/notifications"
STUB
chmod +x "$stub_bin/omarchy-notification-send"
interactive_keybindings() {
  env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$task_home" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-menu-keybindings"
}
interactive_keybindings || fail "menu selection invokes retained binding"
grep -F 'omarchy_keybindings.invoke("abc-def", 3)' "$tmpdir/dispatch" >/dev/null || fail "selection invokes the chosen duplicate, not its neighbor"
[[ ! -e $tmpdir/notifications ]] || fail "successful selection must not notify"
pass "menu selection invokes the chosen duplicate by validated token"

# hyprctl can return a Lua error as text with a successful process status.
for result in 'Keybindings changed; reopen the menu' 'Keybinding was removed or disabled'; do
  cat >"$stub_bin/hyprctl" <<STUB
#!/bin/bash
case "\$1" in
  repl) cat "$tmpdir/snapshot.json" ;;
  dispatch) echo '$result' ;;
esac
STUB
  if interactive_keybindings >"$tmpdir/out" 2>"$tmpdir/err"; then fail "Lua invocation errors must fail the menu"; fi
  grep -q 'Reopen the menu' "$tmpdir/notifications" || fail "rejected selection must notify the desktop"
  grep -q 'Reopen the menu' "$tmpdir/err" || fail "rejected selection must also explain failure on stderr"
  rm "$tmpdir/notifications"
done
sed -i 's/dispatch).*/dispatch) exit 4 ;;/' "$stub_bin/hyprctl"
if interactive_keybindings >"$tmpdir/out" 2>"$tmpdir/err"; then fail "dispatch transport errors must fail the menu"; fi
[[ -s $tmpdir/notifications ]] || fail "dispatch transport errors must notify"
rm "$tmpdir/notifications"
pass "stale, disabled and disconnected selections report visible failures"

printf 'not JSON\n' >"$tmpdir/snapshot.json"
if keybindings >"$tmpdir/out" 2>"$tmpdir/err"; then fail "invalid registry response must fail"; fi
[[ ! -s $tmpdir/out ]] || fail "invalid registry response must not present a partial menu"
grep -q 'Reload Hyprland' "$tmpdir/err" || fail "missing registry gives a useful recovery message"
grep -Fq 'dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")' "$tmpdir/err" || fail "missing bootstrap gives the exact recovery line"
[[ ! -e $tmpdir/notifications ]] || fail "print mode must not send desktop notifications"
if interactive_keybindings >"$tmpdir/out" 2>"$tmpdir/err"; then fail "interactive missing registry must fail"; fi
grep -Fq '/default/hypr/bootstrap.lua' "$tmpdir/notifications" || fail "missing registry must show recovery instructions on the desktop"
pass "missing registry gives bootstrap guidance in stderr and interactive notifications"
