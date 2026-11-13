-- The settings [bootstrap.settings.omarchy] accepts, by dotted key. Each one
-- reads and writes through the Omarchy command that owns it, so a value set
-- here and one set from the Omarchy menu are the same thing.
--
--   read()            the current value, or nil when there is none
--   check(key, value) raises when value is not one the setting accepts
--   write(value)      applies an accepted value
--
-- A command added here must also be listed under requires in mise.plugin.toml.

local cmd = require("cmd")

local function trim(text)
  return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function output(command)
  local text = trim(cmd.exec(command))
  if text ~= "" then
    return text
  end
end

-- Whether a command that answers with its exit status succeeded.
local function succeeds(command)
  return trim(cmd.exec("if " .. command .. "; then echo yes; else echo no; fi")) == "yes"
end

-- The value travels in the environment, never in the shell code, so nothing
-- in it is read as shell. A command's own explanation of a failure is printed
-- on stdout as often as stderr, and only stderr reaches the error mise shows.
local function run(command, value)
  cmd.exec(command .. ' "$OMARCHY_SETTING_VALUE" >&2', { env = { OMARCHY_SETTING_VALUE = value } })
end

local function check_type(key, value, kind)
  if type(value) ~= kind then
    error(key .. " must be a " .. kind .. ", not " .. type(value), 0)
  end
end

-- A setting whose command prints the current choice when run alone and takes
-- the new one as its argument.
local function choice(command, choices)
  return {
    read = function()
      return output(command)
    end,
    check = function(key, value)
      check_type(key, value, "string")
      for _, accepted in ipairs(choices) do
        if value == accepted then
          return
        end
      end
      error(key .. " must be one of " .. table.concat(choices, ", ") .. ", not " .. value, 0)
    end,
    write = function(value)
      run(command, value)
    end,
  }
end

-- A true or false setting. `enabled` is the command that answers whether it is
-- on, `set` the one that takes `on` or `off`. Omarchy keeps several of these as
-- a flag for the opposite (bar-off, no-animations): `inverted` says so for
-- each side.
local function switch(enabled, set, inverted)
  inverted = inverted or {}
  return {
    read = function()
      return succeeds(enabled) ~= (inverted.read or false)
    end,
    check = function(key, value)
      check_type(key, value, "boolean")
    end,
    write = function(value)
      run(set, (value ~= (inverted.write or false)) and "on" or "off")
    end,
  }
end

local settings = {}

-- A theme is named by its directory, such as tokyo-night, which is what
-- Omarchy records. omarchy-theme-set also takes "Tokyo Night", but mise would
-- then compare that spelling with the recorded one and report a difference
-- after every apply.
settings["theme"] = {
  read = function()
    local state = os.getenv("XDG_STATE_HOME")
    if not state or state == "" then
      state = os.getenv("HOME") .. "/.local/state"
    end
    local file = io.open(state .. "/omarchy/current/theme.name", "r")
    if not file then
      return nil
    end
    local name = trim(file:read("*a"))
    file:close()
    if name ~= "" then
      return name
    end
  end,
  check = function(key, value)
    check_type(key, value, "string")
    if value == "" or value ~= value:lower() or value:find("[%s<>/]") then
      error(key .. " must be a theme's directory name, such as tokyo-night, not " .. value, 0)
    end
  end,
  write = function(value)
    run("omarchy-theme-set", value)
  end,
}

settings["font"] = {
  read = function()
    return output("omarchy-font-current")
  end,
  check = function(key, value)
    check_type(key, value, "string")
    if value == "" then
      error(key .. " must name a font, such as JetBrainsMono Nerd Font", 0)
    end
  end,
  write = function(value)
    run("omarchy-font-set", value)
  end,
}

settings["screensaver"] = switch(
  "omarchy-toggle-enabled screensaver-off",
  "omarchy-toggle screensaver-off",
  { read = true, write = true }
)

settings["appearance.corners"] = choice("omarchy-hyprland-corners", { "theme", "sharp", "rounded" })
settings["appearance.transparency"] =
  choice("omarchy-hyprland-window-transparency", { "opaque", "transparent", "glassy" })

-- omarchy-toggle-animations takes the animations' own state, though the flag
-- behind it records them being off.
settings["appearance.animations"] =
  switch("omarchy-hyprland-animations-off", "omarchy-toggle-animations", { read = true })
settings["appearance.gaps"] = switch(
  "omarchy-hyprland-toggle-enabled window-no-gaps",
  "omarchy-hyprland-toggle window-no-gaps",
  { read = true, write = true }
)
settings["appearance.bar"] =
  switch("omarchy-toggle-enabled bar-off", "omarchy-toggle-bar", { read = true, write = true })

settings["workspaces.layout"] =
  choice("omarchy-hyprland-workspace-layout-default", { "dwindle", "scrolling", "floating" })

-- Every key, for the error that answers an unknown one.
local names = {}
for key in pairs(settings) do
  names[#names + 1] = key
end
table.sort(names)

return {
  by_key = settings,
  names = table.concat(names, ", "),
}
