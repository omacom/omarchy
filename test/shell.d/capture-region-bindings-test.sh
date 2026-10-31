#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command lua
require_command jq

lua <<'LUA'
local bindings = {}
local handlers = {}

local function bind(keys)
  local binding = { keys = keys, unbound = false }

  function binding:unbind()
    assert(not self.unbound, "picker binding was unbound twice: " .. self.keys)
    self.unbound = true
  end

  table.insert(bindings, binding)
  return binding
end

hl = {
  bind = bind,
  config = function() end,
  dsp = {
    exec_cmd = function(command)
      return command
    end,
  },
  get_config = function()
    return nil
  end,
  on = function(event, handler)
    handlers[event] = handler
  end,
}

o = setmetatable({}, {
  __index = function()
    return function() end
  end,
})

local processes = {
  [101] = { comm = "slurp", environ = { "PATH=/usr/bin", "OMARCHY_CAPTURE_REGION_PICKER=1" } },
  [202] = { comm = "wl-kbptr", environ = { "OMARCHY_CAPTURE_REGION_PICKER=1" } },
  [303] = { comm = "slurp", environ = { "PATH=/usr/bin" } },
}
local real_open = io.open
io.open = function(path, mode)
  local pid, file = path:match("^/proc/(%d+)/([^/]+)$")
  pid = tonumber(pid)
  if not pid or (file ~= "comm" and file ~= "environ") then
    return real_open(path, mode)
  end

  local process = processes[pid]
  if not process then
    return nil
  end

  local contents
  if file == "comm" then
    contents = process.comm .. "\n"
  else
    contents = table.concat(process.environ, "\0") .. "\0"
  end

  return {
    read = function(_, format)
      if format == "*l" then
        return contents:match("([^\n]*)")
      end
      return contents
    end,
    close = function() end,
  }
end

dofile(os.getenv("ROOT") .. "/default/hypr/bindings/utilities.lua")

assert(#bindings == 0, "picker bindings must not exist before its layer opens")
assert(handlers["layer.opened"], "layer.opened handler was not registered")
assert(handlers["layer.closed"], "layer.closed handler was not registered")

handlers["layer.opened"]({ address = "other-namespace", namespace = "menu", pid = 101 })
handlers["layer.opened"]({ address = "other-client", namespace = "selection", pid = 202 })
handlers["layer.opened"]({ address = "plain-slurp", namespace = "selection", pid = 303 })
handlers["layer.opened"]({ address = "missing-client", namespace = "selection", pid = 404 })
assert(#bindings == 0, "unowned selection layers must not create picker bindings")

handlers["layer.opened"]({ address = "slurp-one", namespace = "selection", pid = 101 })
assert(#bindings == 8, "the first picker layer must create eight bindings")

handlers["layer.opened"]({ address = "slurp-one", namespace = "selection", pid = 101 })
handlers["layer.opened"]({ address = "slurp-two", namespace = "selection", pid = 101 })
handlers["layer.closed"]({ address = "unknown" })
handlers["layer.closed"]({ address = "slurp-one" })
for index = 1, 8 do
  assert(not bindings[index].unbound, "picker bindings must remain while a tracked layer is open")
end

handlers["layer.closed"]({ address = "slurp-two" })
for index = 1, 8 do
  assert(bindings[index].unbound, "the final picker layer must remove its bindings")
end

handlers["layer.opened"]({ address = "slurp-three", namespace = "selection", pid = 101 })
assert(#bindings == 16, "a later picker session must create a fresh binding set")
for index = 9, 16 do
  assert(not bindings[index].unbound, "fresh picker bindings must be active")
end
LUA

pass "capture picker bindings follow tagged capture-region layer lifecycles"

tmpdir=$(mktemp -d)
owned_pid=""
plain_pid=""
cleanup() {
  [[ -n $owned_pid ]] && kill "$owned_pid" 2>/dev/null || true
  [[ -n $plain_pid ]] && kill "$plain_pid" 2>/dev/null || true
  [[ -n $owned_pid ]] && wait "$owned_pid" 2>/dev/null || true
  [[ -n $plain_pid ]] && wait "$plain_pid" 2>/dev/null || true
  rm -rf "$tmpdir"
}
trap cleanup EXIT

process_has_env() {
  local pid=$1 expected=$2 variable

  [[ -r /proc/$pid/environ ]] || return 1
  while IFS= read -r -d '' variable; do
    [[ $variable == "$expected" ]] && return 0
  done 2>/dev/null <"/proc/$pid/environ"

  return 1
}

wait_for_process_env() {
  local pid=$1 expected=$2 attempt

  for ((attempt = 0; attempt < 100; attempt++)); do
    process_has_env "$pid" "$expected" && return 0
    sleep 0.05
  done

  return 1
}

mkdir -p "$tmpdir/pick-bin"
cat >"$tmpdir/pick-bin/hyprpicker" <<'SH'
#!/bin/bash
exec sleep 30
SH
cat >"$tmpdir/pick-bin/slurp" <<'SH'
#!/bin/bash
[[ ${OMARCHY_CAPTURE_REGION_PICKER:-} == "1" ]] || exit 42
echo "10,20 30x40"
SH
chmod +x "$tmpdir/pick-bin/hyprpicker" "$tmpdir/pick-bin/slurp"

selection=$(PATH="$tmpdir/pick-bin:$PATH" XDG_RUNTIME_DIR="$tmpdir" "$ROOT/bin/omarchy-capture-region" region)
[[ $selection == "10,20 30x40" ]] || fail "capture-region tags the slurp process it launches" "$selection"
pass "capture-region tags the slurp process it launches"

mkdir -p "$tmpdir/control-bin"
cp "$(command -v sleep)" "$tmpdir/control-bin/slurp"
cat >"$tmpdir/control-bin/pgrep" <<'SH'
#!/bin/bash
printf '%s\n' "$OWNED_PID" "$PLAIN_PID"
SH
cat >"$tmpdir/control-bin/hyprctl" <<'SH'
#!/bin/bash
case ${1:-} in
cursorpos) echo "10, 10" ;;
monitors) echo '[{"focused":true,"activeWorkspace":{"id":1}}]' ;;
clients) echo '[{"workspace":{"id":1},"hidden":false,"at":[0,0],"size":[100,100]}]' ;;
eval) printf '%s\n' "$*" >>"$HYPRCTL_LOG" ;;
*) exit 1 ;;
esac
SH
chmod +x "$tmpdir/control-bin/pgrep" "$tmpdir/control-bin/hyprctl"

OMARCHY_CAPTURE_REGION_PICKER=1 "$tmpdir/control-bin/slurp" 30 &
owned_pid=$!
"$tmpdir/control-bin/slurp" 30 &
plain_pid=$!
export OWNED_PID=$owned_pid PLAIN_PID=$plain_pid
wait_for_process_env "$owned_pid" "OMARCHY_CAPTURE_REGION_PICKER=1" ||
  fail "tagged slurp exposes its picker marker before capture control"

PATH="$tmpdir/control-bin:$PATH" XDG_RUNTIME_DIR="$tmpdir" "$ROOT/bin/omarchy-capture-region" --take-window
owned_status=0
wait "$owned_pid" 2>/dev/null || owned_status=$?
owned_pid=""
# 143 is SIGTERM; a fake picker left to finish its sleep exits 0.
(( owned_status == 143 )) || fail "capture control terminates the tagged slurp" "wait status $owned_status"

kill -0 "$plain_pid" 2>/dev/null || fail "capture control preserves unowned slurp processes"
[[ -e $tmpdir/omarchy-capture-region-window ]] || fail "capture control records the requested picker action"
pass "capture control targets only tagged slurp processes"

export HYPRCTL_LOG="$tmpdir/hyprctl.log"
: >"$HYPRCTL_LOG"
PATH="$tmpdir/control-bin:$PATH" XDG_RUNTIME_DIR="$tmpdir" "$ROOT/bin/omarchy-capture-region" --select-window next
[[ ! -s $HYPRCTL_LOG ]] || fail "capture navigation must not dispatch without a tagged picker" "$(cat "$HYPRCTL_LOG")"
pass "capture navigation ignores untagged slurp processes"

OMARCHY_CAPTURE_REGION_PICKER=1 "$tmpdir/control-bin/slurp" 30 &
owned_pid=$!
export OWNED_PID=$owned_pid
wait_for_process_env "$owned_pid" "OMARCHY_CAPTURE_REGION_PICKER=1" ||
  fail "tagged slurp exposes its picker marker before navigation"
: >"$HYPRCTL_LOG"
PATH="$tmpdir/control-bin:$PATH" XDG_RUNTIME_DIR="$tmpdir" "$ROOT/bin/omarchy-capture-region" --select-window next
grep -q '^eval hl.dispatch(hl.dsp.cursor.move' "$HYPRCTL_LOG" ||
  fail "capture navigation dispatches with a tagged picker" "$(cat "$HYPRCTL_LOG")"
pass "capture navigation dispatches with a tagged picker"
