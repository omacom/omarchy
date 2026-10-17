#!/bin/bash

# omarchy-menu-keybindings re-executes the user's hyprland.lua under a stub
# `hl` to recover descriptions for Lua binds. That stub answers every unknown
# member with a `noop` object so a config can call arbitrary hyprlua getters
# without erroring. A config that then iterates one with ipairs -- valid and
# common inside the real compositor, e.g. `ipairs(hl.get_windows() or {})` --
# must not hang the sandbox forever.

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] ||
  fail "the test gets a temporary directory to stub a config in"
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
stub_bin="$tmpdir/bin"
mkdir -p "$home/.config/hypr" "$stub_bin"

# hyprctl itself is irrelevant to the sandbox; only the Lua re-execution is
# under test, so a no-op stub is enough to keep the rest of the script quiet.
cat >"$stub_bin/hyprctl" <<'HYPRCTL'
#!/bin/bash
case "$1" in
  devices) echo "active keymap: English (US)" ;;
esac
HYPRCTL
chmod +x "$stub_bin/hyprctl"

run_with_config() {
  cat >"$home/.config/hypr/hyprland.lua"
  timeout 10 env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
    bash "$ROOT/bin/omarchy-menu-keybindings" --print >/dev/null 2>&1
}

run_with_config <<'LUA'
for _, w in ipairs(hl.get_windows() or {}) do
  print(w.title)
end
LUA
(( $? != 124 )) || fail "a config that iterates hl.get_windows() with ipairs hangs the keybindings menu"
pass "a config that iterates hl.get_windows() with ipairs does not hang the keybindings menu"

# The stub answers every unstubbed member the same way, so the same shape of
# loop over any other getter must terminate too.
run_with_config <<'LUA'
for _, ws in ipairs(hl.get_workspaces() or {}) do print(ws.id) end
for _, w in ipairs(hl.get_workspace_windows(1) or {}) do print(w.title) end
for _, m in ipairs(hl.get_monitors() or {}) do print(m.name) end
LUA
(( $? != 124 )) || fail "a config that iterates other hyprlua getters with ipairs hangs the keybindings menu"
pass "a config that iterates other hyprlua getters with ipairs does not hang the keybindings menu"

# A chained call on an unstubbed getter (valid usage the stub exists to
# support) must still resolve rather than error, now that numeric indexing
# answers nil.
run_with_config <<'LUA'
local w = hl.get_windows()
print(w.active, w[1])
LUA
(( $? != 124 )) || fail "a chained call on an unstubbed getter hangs the keybindings menu"
pass "a chained call on an unstubbed getter still resolves without hanging"
