#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command lua

lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
local startup, recovery
local invisible = false
local writes = 0
hl = {
  on = function(event, callback)
    assert(event == "hyprland.start")
    startup = callback
  end,
  config = function(config)
    invisible = config.cursor.invisible
    writes = writes + 1
  end,
  timer = function(callback, options)
    assert(options.timeout == 15000 and options.type == "oneshot")
    recovery = callback
  end,
  exec_cmd = function(command)
    if command == "omarchy-launch-shell" then
      assert(invisible, "cursor must be hidden before the shell starts")
    end
  end,
}
o = { launch = function(command) return command end }

require("default.hypr.autostart")
assert(writes == 0, "loading configuration must not hide the cursor again")
startup()
assert(invisible and omarchy_startup_cursor_pending)
recovery()
assert(not invisible and not omarchy_startup_cursor_pending, "a failed shell must not strand a hidden cursor")

startup()
-- The shell clears ownership when its startup fade begins.
omarchy_startup_cursor_pending = false
local previous_writes = writes
recovery()
assert(writes == previous_writes, "recovery must not change the cursor after the shell has revealed it")
LUA
pass "startup hides the cursor before launching the shell and recovers a failed reveal"
