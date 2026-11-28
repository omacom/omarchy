-- Restore workspace layouts saved by omarchy-hyprland-workspace-layout-toggle.

local paths = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")
local selection = require("default.hypr.workspace-layout-selection")

-- The saved files call o.workspace_mode, so it has to exist before they load.
local workspace_modes = require("default.hypr.workspace-modes")

local layouts_dir = paths.state_home .. "/omarchy/workspace-layouts"

-- The directory is found through XDG_STATE_HOME but the files are loaded by
-- module name, and bootstrap only puts ~/.local/state on the search path. A
-- state home anywhere else would list the saved layouts and then fail to require
-- them, or load same-named ones from under the home directory instead.
package.path = paths.state_home .. "/?.lua;" .. package.path

local function load_legacy_layout(path, id)
  if not selection.fallback or not id:match("^[1-9]%d*$") then
    return false
  end

  local file = io.open(path, "r")
  if not file then
    return false
  end
  local contents = file:read("a")
  file:close()

  -- Older releases saved the workspace rule directly.
  local workspace, mode = contents:match('^hl%.workspace_rule%({ workspace = "(%d+)", layout = "(%a+)" }%)%s*$')
  if workspace == id then
    o.workspace_mode({ workspace = workspace, mode = mode })
    return true
  end
  return false
end

workspace_modes.prepare_default()
require_all.files(layouts_dir, "omarchy.workspace-layouts", { reload = true, load = load_legacy_layout })

-- With every saved mode known, bring the open windows in line and set up what a
-- floating workspace needs.
workspace_modes.apply()
