#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command jq
require_command lua
require_command xkbcli

tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] ||
  fail "the test gets a temporary directory to stub Hyprland in"
trap 'rm -rf "$tmpdir"' EXIT
sed '/^if \[\[ \$1 ==/,$d' "$ROOT/bin/omarchy-menu-keybindings" >"$tmpdir/scanner.sh"

home="$tmpdir/home"
stub_bin="$tmpdir/bin"
mkdir -p "$home/.config" "$stub_bin"
cp -r "$ROOT/config/hypr" "$home/.config/hypr"

# No platform package: neither its key names nor its binds.
menu="$tmpdir/omarchy-menu-keybindings"
platform_root_copy "$ROOT/bin/omarchy-menu-keybindings" "$menu" "$tmpdir/no-platform"

# The menu reads binds from Hyprland, which is not running here, so stand in for
# it. A Lua bind reports dispatcher __lua and no arg, and the menu recovers both
# from the Lua source; an exec bind carries its own command. Both shapes matter:
# what two chords dispatch is what decides whether they share a row.
lua_bind() {
  printf 'bind\n\tmodmask: %s\n\tsubmap: \n\tkey: %s\n\tkeycode: 0\n\tcatchall: false\n\tdescription: %s\n\tdispatcher: __lua\n\targ: \n' "$1" "$2" "$3"
}

exec_bind() {
  printf 'bind\n\tmodmask: %s\n\tsubmap: \n\tkey: %s\n\tkeycode: 0\n\tcatchall: false\n\tdescription: %s\n\tdispatcher: exec\n\targ: %s\n' "$1" "$2" "$3" "$4"
}

stub_hyprctl() {
  {
    echo '#!/bin/bash'
    echo 'case "$1" in'
    echo '  binds) cat <<'"'"'BINDS'"'"''
    cat
    echo 'BINDS'
    echo '  ;;'
    echo '  devices) echo "active keymap: English (US)" ;;'
    echo 'esac'
  } >"$stub_bin/hyprctl"
  chmod +x "$stub_bin/hyprctl"
}

keybindings() {
  env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
    XDG_CACHE_HOME="$tmpdir/cache" OMARCHY_PATH="$ROOT" \
    bash "$menu" --print
}

# Closing a window and toggling the scratchpad are two of the actions Omarchy
# binds twice on purpose. The last bind carries the longest description Omarchy
# ships, which is what puts a row closest to the width the menu allows.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + W" "Close window")
$(lua_bind 64 "SUPER + Q" "Close window")
$(lua_bind 64 "SUPER + F" "Full screen")
$(lua_bind 64 "SUPER + I" "Switch input language")
$(lua_bind 64 "SUPER + S" "Toggle scratchpad")
$(lua_bind 64 "SUPER + grave" "Toggle scratchpad")
$(exec_bind 73 "SUPER SHIFT ALT + 0" "Move window silently to workspace 10" "true")
BINDS

rendered=$(keybindings)
[[ -n $rendered ]] || fail "the keybindings menu renders with a stubbed Hyprland"

grep -q 'SUPER + F  *→ Full screen' <<<"$rendered" ||
  fail "a chord with no alternative renders on its own" "$rendered"
pass "the keybindings menu renders its entries"
grep -q 'SUPER + I  *→ Switch input language' <<<"$rendered" ||
  fail "the input switch shortcut appears in the cheatsheet" "$rendered"
pass "the input switch shortcut appears in the cheatsheet"

# The menu's own scan of the config runs lua -E, so no LUA_INIT or LUA_PATH from
# the environment reaches it and nothing there can move the platform root.
printf "io.open('%s', 'w'):close()\n" "$tmpdir/init-ran" >"$tmpdir/init.lua"
LUA_INIT="@$tmpdir/init.lua" lua -e '' && [[ -e $tmpdir/init-ran ]] || fail "the LUA_INIT probe runs in a plain lua"
rm -f "$tmpdir/init-ran"
env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" XDG_CACHE_HOME="$tmpdir/cache-init" OMARCHY_PATH="$ROOT" \
  LUA_INIT="@$tmpdir/init.lua" LUA_INIT_5_5="@$tmpdir/init.lua" LUA_INIT_5_4="@$tmpdir/init.lua" LUA_PATH="$tmpdir/?.lua" \
  bash "$ROOT/bin/omarchy-menu-keybindings" --print >/dev/null
[[ ! -e $tmpdir/init-ran ]] || fail "the menu's config scan ignores LUA_INIT from the environment"
pass "the menu's config scan ignores LUA_INIT and LUA_PATH from the environment"

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
stub_hyprctl <<'BINDS'
bind
	modmask: 64
	submap: 
	key: 
	keycode: 49
	catchall: false
	description: Toggle scratchpad
	dispatcher: exec
	arg: true
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

# The terminal bind is a Lua function Hyprland reports only as __lua, so picking
# it from the menu has to run the command the function stands for.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + RETURN" "Terminal")
BINDS

# The default config can encounter unsupported runtime values after its binds;
# dispatch recovery must work even when that scan encounters an error.
env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" OMARCHY_PATH="$ROOT" SCANNER="$tmpdir/scanner.sh" \
  bash -c 'source "$SCANNER"; output_binding_records_uncached' >"$tmpdir/terminal-records"
grep -qP '→ Terminal\texec\tomarchy-launch-terminal$' "$tmpdir/terminal-records" ||
  fail "picking the terminal bind from the menu launches a terminal" "$(cat "$tmpdir/terminal-records")"
pass "picking the terminal bind from the menu launches a terminal"

# Plural queries must be empty lists while singular suffix getters allow fields.
for query in workspaces monitors clients windows devices cursor_pos status options; do
  cat >"$home/.config/hypr/hyprland.lua" <<LUA
local result = hl.get_$query()
assert(#result == 0)
for _, ws in ipairs(result) do error("unexpected list item") end
for _, ws in pairs(result) do error("unexpected field") end
if hl.get_cursor_pos().x > 0 then end
if hl.get_cursor_pos().x <= 0 then end
assert(hl.get_status().foo.bar)
assert(hl.get_options().foo.bar)
assert(hl[1].foo)
assert(hl.get_config() == nil)
hl.bind("SUPER + A", hl.dsp.exec_cmd("echo after"), {description = "After query"})
if hl.get_active_monitor() then
  hl.bind("SUPER + B", hl.dsp.exec_cmd("echo monitor"), {description = "Active monitor"})
end
LUA
  stub_hyprctl <<BINDS
$(lua_bind 64 "" "After query")
$(lua_bind 64 "" "Active monitor")
BINDS
  rm -rf "$tmpdir/cache"
  timeout 5 env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
    XDG_CACHE_HOME="$tmpdir/cache" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-menu-keybindings" --print >/dev/null || fail "$query scan terminates"
  grep -qP 'SUPER \+ A .*→ After query\texec\techo after$' "$tmpdir"/cache/omarchy/*.records || fail "$query recovers the binding after the loop"
  grep -qP 'SUPER \+ B .*→ Active monitor\texec\techo monitor$' "$tmpdir"/cache/omarchy/*.records || fail "singular query remains truthy"
  pass "$query loop terminates and following bindings are recovered"
done

# Ordinary errors are cacheable; instruction exhaustion must retry unchanged config.
for failure in error guard; do
  if [[ $failure == "error" ]]; then
    workload='error("scan failed")'
  else
    workload='while true do end'
  fi
  touch "$home/fail-scan"
  rm -f "$home/scan-count"
  cat >"$home/.config/hypr/hyprland.lua" <<LUA
local counter = assert(io.open(os.getenv("HOME") .. "/scan-count", "a"))
counter:write("scan\n")
counter:close()
hl.bind("SUPER + A", hl.dsp.exec_cmd("echo partial"), {description = "Interrupted binding"})
local marker = io.open(os.getenv("HOME") .. "/fail-scan", "r")
if marker then
  marker:close()
  $workload
end
LUA
  stub_hyprctl <<BINDS
$(lua_bind 64 "" "Interrupted binding")
$(exec_bind 64 "SUPER + B" "Native binding" "echo native")
BINDS
  rm -rf "$tmpdir/cache"
  timeout 5 env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
    XDG_CACHE_HOME="$tmpdir/cache" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-menu-keybindings" --print >"$tmpdir/interrupted" || fail "$failure scan still renders rows"
  grep -q 'SUPER + A .*→ Interrupted binding' "$tmpdir/interrupted" || fail "$failure scan preserves the recovered chord"
  grep -q '→ Native binding' "$tmpdir/interrupted" || fail "native binding remains available"
  first_scan_count=$(wc -l <"$home/scan-count")
  if [[ $failure == "error" ]]; then
    (( first_scan_count == 1 )) || fail "ordinary error scans once"
    grep -qP '→ Interrupted binding\texec\techo partial$' "$tmpdir"/cache/omarchy/*.records || fail "ordinary error publishes partial metadata cache"
    keybindings >/dev/null
    (( $(wc -l <"$home/scan-count") == 1 )) || fail "ordinary error uses cache without rescanning"
  else
    [[ -z $(find "$tmpdir/cache" -name '*.records') ]] || fail "instruction exhaustion publishes no cache"
    keybindings >/dev/null
    (( $(wc -l <"$home/scan-count") > first_scan_count )) || fail "instruction exhaustion rescans on next invocation"
  fi
  scan_status=0
  env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" OMARCHY_PATH="$ROOT" SCANNER="$tmpdir/scanner.sh" \
    bash -c 'source "$SCANNER"; output_binding_records_uncached' >"$tmpdir/partial-records" || scan_status=$?
  if [[ $failure == "error" ]]; then
    (( scan_status == 0 )) || fail "ordinary error remains cacheable"
  else
    (( scan_status == 1 )) || fail "instruction exhaustion uncached output returns failure"
  fi
  grep -qP 'SUPER \+ A .*→ Interrupted binding\texec\techo partial$' "$tmpdir/partial-records" || fail "$failure scan preserves collected metadata"
  grep -qP '→ Native binding\texec\techo native$' "$tmpdir/partial-records" || fail "$failure scan preserves native metadata"
  rm "$home/fail-scan"
  keybindings >/dev/null
  grep -qP '→ Interrupted binding\texec\techo partial$' "$tmpdir"/cache/omarchy/*.records || fail "unchanged config caches after failure marker removal"
  pass "$failure scan preserves metadata with the expected caching and retry behavior"
done

# Valid finite work must not trip the generous instruction limit.
cat >"$home/.config/hypr/hyprland.lua" <<'LUA'
local sum = 0; for i = 1, 2000000 do sum = sum + i end
hl.bind("SUPER + A", hl.dsp.exec_cmd("echo finite"), {description = "Interrupted binding"})
LUA
rm -rf "$tmpdir/cache"
keybindings >/dev/null
grep -qP '→ Interrupted binding\texec\techo finite$' "$tmpdir"/cache/omarchy/*.records || fail "finite workload succeeds"
pass "finite workload succeeds"
