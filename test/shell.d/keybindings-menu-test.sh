#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua
require_command xkbcli

tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] ||
  fail "the test gets a temporary directory to stub Hyprland in"
trap 'rm -rf "$tmpdir"' EXIT

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

lua_function_bind() {
  printf 'bindd\n\tmodmask: %s\n\tsubmap: %s\n\tkey: %s\n\tkeycode: 0\n\tcatchall: false\n\tdescription: %s\n\tdispatcher: __lua\n\targ: %s\n' "$1" "$5" "$2" "$3" "$4"
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
$(lua_bind 64 "SUPER + S" "Toggle scratchpad")
$(lua_bind 64 "SUPER + grave" "Toggle scratchpad")
$(exec_bind 73 "SUPER SHIFT ALT + 0" "Move window silently to workspace 10" "true")
BINDS

rendered=$(keybindings)
[[ -n $rendered ]] || fail "the keybindings menu renders with a stubbed Hyprland"

grep -q 'SUPER + F  *→ Full screen' <<<"$rendered" ||
  fail "a chord with no alternative renders on its own" "$rendered"
pass "the keybindings menu renders its entries"

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

stub_hyprctl <<BINDS
$(lua_function_bind 76 "Z" "Reset zoom" 264)
$(lua_function_bind 64 "W" "Close window" 261)
$(lua_function_bind 0 "H" "Shrink in resize mode" 270 resize)
BINDS

eval "$(sed -n '/^lua_bind_identity()/,/^}/p; /^dispatch_lua_expression()/,/^}/p; /^mark_lua_state()/,/^}/p; /^unmark_lua_state()/,/^}/p; /^current_lua_function_ref()/,/^}/p; /^call_lua_function_if_marked()/,/^}/p; /^dispatch_lua_function_binding()/,/^}/p; /^dispatch_binding()/,/^}/p' "$ROOT/bin/omarchy-menu-keybindings")"

keybindings >/dev/null
records=$(cat "$tmpdir"/cache/omarchy/keybindings-*.records)
identity=$(lua_bind_identity 76 "" "Z" 0 "Reset zoom")
[[ $(awk -F '\t' '$1 ~ /→ Reset zoom$/ { print $2 "\t" $3 }' <<<"$records") == "__lua	$identity" ]] ||
  fail "a Lua function bind keeps which bind it is" "$records"
[[ $(awk -F '\t' '$1 ~ /→ Shrink in resize mode$/ { print $2 "\t" $3 }' <<<"$records") == "__lua	$(lua_bind_identity 0 resize "H" 0 "Shrink in resize mode")" ]] ||
  fail "a Lua function bind in a submap keeps its submap" "$records"
[[ $(awk -F '\t' '$1 ~ /→ Close window$/ { print $2 "\t" $3 }' <<<"$records") == "lua	hl.dsp.window.close()" ]] ||
  fail "a bind the source resolves keeps its expression over its ref" "$records"
pass "a Lua function bind keeps which bind it is"

stub_hyprctl_dispatch() {
  cat >"$stub_bin/hyprctl" <<STUB
#!/bin/bash
printf '%s\n' "\$*" >>"$tmpdir/hyprctl.log"
case "\$1" in
  binds)
    if [[ -f $tmpdir/dispatch-during-lookup ]]; then
      "\$0" dispatch "\$(cat "$tmpdir/dispatch-during-lookup")" >/dev/null
    fi
    cat "$tmpdir/binds"
    status=\$(cat "$tmpdir/binds-status")
    if [[ -f $tmpdir/binds-after-reload ]]; then
      mv "$tmpdir/binds-after-reload" "$tmpdir/binds"
      rm -f "$tmpdir/lua-state"
    fi
    exit "\$status"
    ;;
  dispatch)
    STUB_DIR="$tmpdir" STUB_EXPRESSION="\$2" lua - <<'LUA'
local dir = os.getenv("STUB_DIR")
local registry = debug.getregistry()

local state = io.open(dir .. "/lua-state")
if state then
  registry.omarchy_menu_keybindings_marks = {}
  for mark in state:lines() do
    registry.omarchy_menu_keybindings_marks[mark] = true
  end
  state:close()
end

for line in io.lines(dir .. "/binds") do
  local ref = tonumber(line:match("^\targ: (%d+)$"))
  if ref then
    registry[ref] = function()
      local called = io.open(dir .. "/called", "a")
      called:write(ref, "\n")
      called:close()
    end
  end
end

hl = {
  dispatch = function(action)
    if type(action) == "function" then action() end
  end,
}

local chunk, problem = load("return hl.dispatch(" .. os.getenv("STUB_EXPRESSION") .. ")")
local ok = chunk and pcall(chunk)
if not ok then
  print("error: " .. tostring(problem or "dispatch failed"))
  os.exit(7)
end

if registry.omarchy_menu_keybindings_marks then
  state = io.open(dir .. "/lua-state", "w")
  for mark in pairs(registry.omarchy_menu_keybindings_marks) do
    state:write(mark, "\n")
  end
  state:close()
end
print("ok")
LUA
    ;;
esac
STUB
  chmod +x "$stub_bin/hyprctl"
  cat >"$tmpdir/binds"
  echo 0 >"$tmpdir/binds-status"
  rm -f "$tmpdir/hyprctl.log" "$tmpdir/called" "$tmpdir/lua-state" "$tmpdir/binds-after-reload" "$tmpdir/dispatch-during-lookup"
}

called() {
  [[ -f $tmpdir/called && $(cat "$tmpdir/called") == "$1" ]]
}

called_nothing() {
  [[ ! -s $tmpdir/called ]]
}

left_no_mark() {
  [[ ! -s $tmpdir/lua-state ]]
}

pick_from_menu() {
  printf '#!/bin/bash\ngrep -m1 -F -- %q\n' "$1" >"$stub_bin/omarchy-menu-select"
  chmod +x "$stub_bin/omarchy-menu-select"
  rm -rf "$tmpdir/cache"
  env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
    XDG_CACHE_HOME="$tmpdir/cache" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-menu-keybindings" >/dev/null
}

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 76 "Z" "Reset zoom" 264)
BINDS
PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$identity" >/dev/null ||
  fail "selecting a Lua function bind dispatches it"
called 264 ||
  fail "a Lua function bind is called through the ref Hyprland reports" "$(cat "$tmpdir/hyprctl.log")"
left_no_mark ||
  fail "a Lua function bind that was called leaves no mark" "$(cat "$tmpdir/lua-state")"
pass "selecting a Lua function bind calls it through its ref"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 64 "D" "Different action" 264)
$(lua_function_bind 76 "Z" "Reset zoom" 300)
BINDS
PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$identity" >/dev/null ||
  fail "a bind whose ref moved after a reload still dispatches"
called 300 ||
  fail "a bind whose ref moved is called through its new ref, not the old one" "$(cat "$tmpdir/hyprctl.log")"
pass "a bind whose ref moved after a reload is called through its new ref"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 76 "Z" "Reset zoom" 264)
BINDS
cat >"$tmpdir/binds-after-reload" <<BINDS
$(lua_function_bind 64 "D" "Different action" 264)
$(lua_function_bind 76 "Z" "Reset zoom" 300)
BINDS
! PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$identity" >/dev/null ||
  fail "a reload between the lookup and the call is refused"
called_nothing ||
  fail "a reload between the lookup and the call runs nothing" "$(cat "$tmpdir/called")"
pass "a reload between the lookup and the call runs nothing"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 76 "Z" "Reset zoom" 264)
BINDS
PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$identity" >/dev/null ||
  fail "a selection that leaves a mark dispatches"
other_selection_mark=$(sed -n '1s/^dispatch //p' "$tmpdir/hyprctl.log")
[[ -n $other_selection_mark ]] ||
  fail "a selection dispatches its mark first" "$(cat "$tmpdir/hyprctl.log")"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 76 "Z" "Reset zoom" 264)
BINDS
"$stub_bin/hyprctl" dispatch "$other_selection_mark" >/dev/null
marks_of_other_selection=$(cat "$tmpdir/lua-state")
[[ -n $marks_of_other_selection ]] ||
  fail "the other selection leaves its mark"
rm "$tmpdir/lua-state"
printf '%s\n' "$other_selection_mark" >"$tmpdir/dispatch-during-lookup"
PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$identity" >/dev/null ||
  fail "a selection that overlaps another one still dispatches" "$(cat "$tmpdir/hyprctl.log")"
called 264 ||
  fail "a selection that overlaps another one still calls its bind" "$(cat "$tmpdir/hyprctl.log")"
[[ $(cat "$tmpdir/lua-state") == "$marks_of_other_selection" ]] ||
  fail "a selection that calls its bind leaves the mark of another selection in place" "$(cat "$tmpdir/lua-state")"
pass "a selection that overlaps another one still calls its bind"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 64 "D" "Different action" 264)
BINDS
! PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$identity" >/dev/null ||
  fail "a bind Hyprland no longer reports is refused"
called_nothing ||
  fail "a bind Hyprland no longer reports calls nothing" "$(cat "$tmpdir/called")"
left_no_mark ||
  fail "a bind Hyprland no longer reports leaves no mark" "$(cat "$tmpdir/lua-state")"
pass "a bind Hyprland no longer reports calls nothing"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 64 "D" "Different action" 264)
BINDS
"$stub_bin/hyprctl" dispatch "$other_selection_mark" >/dev/null
! PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$identity" >/dev/null ||
  fail "a refused selection that overlaps another one is still refused"
[[ $(cat "$tmpdir/lua-state") == "$marks_of_other_selection" ]] ||
  fail "a refused selection leaves the mark of another selection in place" "$(cat "$tmpdir/lua-state")"
pass "a refused selection leaves the mark of another selection in place"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 76 "Z" "Reset zoom" 264)
$(lua_function_bind 76 "Z" "Reset zoom" 300)
BINDS
! PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$identity" >/dev/null ||
  fail "two binds that match the same identity are refused"
called_nothing ||
  fail "two binds that match the same identity call nothing" "$(cat "$tmpdir/called")"
left_no_mark ||
  fail "two binds that match the same identity leave no mark" "$(cat "$tmpdir/lua-state")"
pass "two binds that match the same identity call nothing"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 76 "Z" "Reset zoom" "")
BINDS
! PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$identity" >/dev/null ||
  fail "a bind reported without a numeric ref is refused"
called_nothing ||
  fail "a bind reported without a numeric ref calls nothing" "$(cat "$tmpdir/called")"
left_no_mark ||
  fail "a bind reported without a numeric ref leaves no mark" "$(cat "$tmpdir/lua-state")"
pass "a bind reported without a numeric ref calls nothing"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 76 "Z" "Reset zoom" 264)
$(lua_function_bind 76 "Z" "Reset zoom" 300 resize)
BINDS
PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$identity" >/dev/null ||
  fail "a bind that shares its chord and description with a bind in a submap dispatches"
called 264 ||
  fail "a bind outside a submap is told apart from one inside it" "$(cat "$tmpdir/hyprctl.log")"
rm "$tmpdir/called"
PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$(lua_bind_identity 76 resize "Z" 0 "Reset zoom")" >/dev/null ||
  fail "a bind in a submap that shares its chord and description with a bind outside it dispatches"
called 300 ||
  fail "a bind in a submap is told apart from one outside it" "$(cat "$tmpdir/hyprctl.log")"
pass "binds that differ only in their submap are told apart"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 76 "Z" "Reset zoom" 264)
$(lua_function_bind 64 "Z" "Reset zoom" 300)
BINDS
PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$identity" >/dev/null ||
  fail "a bind that shares its key and description with a bind on other modifiers dispatches"
called 264 ||
  fail "a bind is told apart from one on other modifiers" "$(cat "$tmpdir/hyprctl.log")"
rm "$tmpdir/called"
PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$(lua_bind_identity 64 "" "Z" 0 "Reset zoom")" >/dev/null ||
  fail "the bind on the other modifiers dispatches too"
called 300 ||
  fail "the bind on the other modifiers is called through its own ref" "$(cat "$tmpdir/hyprctl.log")"
pass "binds that differ only in their modifiers are told apart"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 76 "Z" "Reset zoom" 264)
BINDS
echo 1 >"$tmpdir/binds-status"
! PATH="$stub_bin:$PATH" dispatch_binding "__lua" "$identity" >/dev/null ||
  fail "a failed hyprctl binds is refused even with matching output"
called_nothing ||
  fail "a failed hyprctl binds calls nothing" "$(cat "$tmpdir/called")"
left_no_mark ||
  fail "a failed hyprctl binds leaves no mark" "$(cat "$tmpdir/lua-state")"
! PATH="$stub_bin:$PATH" dispatch_binding "__lua" "" >/dev/null ||
  fail "a Lua bind with nothing to look up is refused"
pass "a failed hyprctl binds calls nothing"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 64 "D" "Different action" 300)
$(lua_function_bind 76 "Z" "Reset zoom" 264)
BINDS
pick_from_menu "→ Reset zoom" ||
  fail "picking a Lua function bind from the menu succeeds" "$(cat "$tmpdir/hyprctl.log")"
called 264 ||
  fail "picking a Lua function bind from the menu calls it" "$(cat "$tmpdir/hyprctl.log")"
pass "picking a Lua function bind from the menu calls it"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 76 "backslash" 'Toggle \n mode' 264)
BINDS
pick_from_menu '→ Toggle \n mode' ||
  fail "picking a bind with a backslash in its description succeeds" "$(cat "$tmpdir/hyprctl.log")"
called 264 ||
  fail "picking a bind with a backslash in its description calls it" "$(cat "$tmpdir/hyprctl.log")"
pass "picking a bind with a backslash in its description calls it"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 76 "Z" "Run ~/.local/share/omarchy/bin/omarchy-zoom" 264)
$(lua_function_bind 0 "H" "Shrink in keycode mode" 300 "code:20")
BINDS
pick_from_menu "→ Run ~/.local/share/omarchy/bin/omarchy-zoom" ||
  fail "picking a bind with an Omarchy path in its description succeeds" "$(cat "$tmpdir/hyprctl.log")"
called 264 ||
  fail "picking a bind with an Omarchy path in its description calls it" "$(cat "$tmpdir/hyprctl.log")"
rm "$tmpdir/called"
pick_from_menu "→ Shrink in keycode mode" ||
  fail "picking a bind in a submap named like a keycode succeeds" "$(cat "$tmpdir/hyprctl.log")"
called 300 ||
  fail "picking a bind in a submap named like a keycode calls it" "$(cat "$tmpdir/hyprctl.log")"
pass "text the menu rewrites for display does not change which bind is called"

stub_hyprctl_dispatch <<BINDS
$(lua_function_bind 76 "Z" "Reset zoom" 264)
$(lua_function_bind 76 "Z" "Reset zoom" 300 resize)
BINDS
! pick_from_menu "→ Reset zoom" ||
  fail "picking one of two function binds whose rows read the same is refused"
called_nothing ||
  fail "picking one of two function binds whose rows read the same calls nothing" "$(cat "$tmpdir/called")"
left_no_mark ||
  fail "picking one of two function binds whose rows read the same leaves no mark" "$(cat "$tmpdir/lua-state")"
pass "picking one of two function binds whose rows read the same calls nothing"

stub_hyprctl_dispatch <<BINDS
$(exec_bind 76 "Z" "Reset zoom" "true")
$(lua_function_bind 76 "Z" "Reset zoom" 264)
BINDS
! pick_from_menu "→ Reset zoom" ||
  fail "picking a row that a function bind and another bind share is refused"
called_nothing ||
  fail "picking a row that a function bind and another bind share calls no function" "$(cat "$tmpdir/called")"
! grep -q '^dispatch' "$tmpdir/hyprctl.log" ||
  fail "picking a row that a function bind and another bind share dispatches nothing" "$(cat "$tmpdir/hyprctl.log")"
pass "picking a row that a function bind and another bind share dispatches nothing"

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

rm -rf "$tmpdir/cache"
keybindings >/dev/null
grep -qP '→ Terminal\texec\tomarchy-launch-terminal$' "$tmpdir"/cache/omarchy/keybindings-*.records ||
  fail "picking the terminal bind from the menu launches a terminal" "$(cat "$tmpdir"/cache/omarchy/keybindings-*.records)"
pass "picking the terminal bind from the menu launches a terminal"
