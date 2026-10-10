-- Shared helpers for Hyprland Lua configuration.

local paths = require("default.hypr.paths")

o = o or {}

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

o.shell_quote = shell_quote

local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end

  return false
end

-- Hyprland reaps its own children, so os.execute() can't retrieve an exit status
-- from inside the compositor. Read a marker off stdout instead.
function o.shell_succeeds(command)
  -- Subshell, so the redirection covers every command rather than binding to
  -- the last one and letting an earlier one write its own OK into the pipe.
  local pipe = io.popen("( " .. command .. " ) >/dev/null 2>&1 && echo OK")
  if not pipe then
    return false
  end

  local output = pipe:read("*a") or ""
  pipe:close()

  return output:find("OK", 1, true) ~= nil
end

function o.cmd_present(command)
  if command:find("/", 1, true) then
    return file_exists(command)
  end

  local path = os.getenv("PATH") or "/usr/local/bin:/usr/bin"
  for directory in (path .. ":"):gmatch("([^:]*):") do
    if file_exists((directory ~= "" and directory or ".") .. "/" .. command) then
      return true
    end
  end

  return false
end

function o.cmd_missing(command)
  return not o.cmd_present(command)
end

-- The global shortcuts the shell registers, read from the same list it reads.
local shell_shortcuts = nil

local function shell_shortcut_registered(name)
  if not shell_shortcuts then
    shell_shortcuts = {}
    local file = io.open(paths.omarchy_path .. "/default/omarchy/shortcuts", "r")
    if file then
      for line in file:lines() do
        local kind, target = line:match("^(%a+)%s+(%S+)%s*$")
        if kind then
          shell_shortcuts[kind .. "." .. target] = true
        end
      end
      file:close()
    end
  end

  return shell_shortcuts[name] == true
end

-- Reach the shell through its global shortcut when it registers one, so the
-- keypress spawns nothing. Anything else runs the command as before.
local function shell_dispatcher(kind, target, command)
  local name = kind .. "." .. target
  if shell_shortcut_registered(name) then
    return hl.dsp.global("omarchy:" .. name)
  end

  return command
end

local function command_from(value, description)
  if type(value) ~= "table" then
    return value
  end

  if value.omarchy then
    return "omarchy-launch-" .. value.omarchy
  elseif value.menu then
    return shell_dispatcher("menu", value.menu, "omarchy-menu toggle " .. shell_quote(value.menu))
  elseif value.panel then
    return shell_dispatcher("panel", value.panel, "omarchy-shell shell toggle " .. shell_quote(value.panel))
  elseif value.audio then
    return shell_dispatcher("audio", value.audio, "omarchy-audio-output-volume " .. shell_quote(value.audio))
  elseif value.brightness then
    local step = value.brightness == "raise" and "+5%" or "5%-"
    return shell_dispatcher("brightness", value.brightness, "omarchy-brightness-display " .. step)
  elseif value.ipc then
    local target, method = value.ipc:match("^([^.]+)%.(.+)$")
    return shell_dispatcher("ipc", value.ipc, "omarchy-shell " .. shell_quote(target) .. " " .. shell_quote(method))
  elseif value.focus and value.launch then
    return o.launch_sole(value.focus, value.launch)
  elseif value.launch then
    return o.launch(value.launch)
  elseif value.webapp then
    if value.focus then
      return o.launch_webapp_sole(description, value.webapp)
    else
      return o.launch_webapp(value.webapp)
    end
  elseif value.tui then
    if value.focus then
      return "omarchy-launch-or-focus-tui " .. shell_quote(value.tui)
    else
      return "omarchy-launch-tui " .. shell_quote(value.tui)
    end
  end

  return value
end

function o.preinstalled_bindings_enabled()
  if _G.omarchy_preinstalled_bindings ~= nil then
    return _G.omarchy_preinstalled_bindings == true
  end

  return not file_exists((os.getenv("HOME") or "") .. "/.local/state/omarchy/preinstalls-removed")
end

-- Hyprland compares modifiers without regard to order or case, so
-- "SUPER + SHIFT + F" and "SHIFT + SUPER + F" are the same chord. Canonicalize
-- before comparing, or an override written in another order never finds the
-- default it means to replace.
local function canonical_keys(keys)
  local parts = {}
  for raw in (keys .. "+"):gmatch("([^+]*)%+") do
    local part = raw:match("^%s*(.-)%s*$")
    if part ~= "" then
      parts[#parts + 1] = part
    end
  end

  local key = table.remove(parts) or ""
  for index, modifier in ipairs(parts) do
    parts[index] = modifier:upper()
  end
  table.sort(parts)
  parts[#parts + 1] = key:upper()

  return table.concat(parts, "+")
end

local function bind_dedup_key(canonical, options)
  -- Internal dedup key: the same keys with a different event type.
  if options and options.release then
    return canonical .. "|r"
  elseif options and options.long_press then
    return canonical .. "|l"
  end

  return canonical
end

-- Keep every action on a chord, including deliberate stacks. Hyprland 0.56.2
-- removes the whole chord even through Keybind:unbind(), so rebuild its other
-- events after an override. tostring is safe for expired handles on that version;
-- is_enabled and unbind are not. Never restore a binding removed by hl.unbind.
local registered = {}

function o.bind(keys, description, dispatcher, options)
  local opts = {}
  for key, value in pairs(options or {}) do
    if key ~= "append" then
      opts[key] = value
    end
  end

  if description then
    opts.description = description
  end

  dispatcher = command_from(dispatcher, description)
  local canonical = canonical_keys(keys)
  local dedup = bind_dedup_key(canonical, options)
  local entries = {}
  local replacing = false
  for _, entry in ipairs(registered[canonical] or {}) do
    if tostring(entry.handle) ~= "HL.Keybind(expired)" then
      entries[#entries + 1] = entry
      if entry.dedup == dedup then
        replacing = true
      end
    end
  end

  if replacing and not (options and options.append) then
    -- Read every handle before the first unbind expires the whole chord.
    for _, entry in ipairs(entries) do
      entry.enabled = entry.handle:is_enabled()
    end
    for _, entry in ipairs(entries) do
      hl.unbind(entry.keys)
    end

    local survivors = {}
    for _, entry in ipairs(entries) do
      if entry.dedup ~= dedup then
        entry.handle = hl.bind(entry.keys, entry.dispatcher, entry.opts)
        if entry.enabled == false then
          entry.handle:set_enabled(false)
        end
        survivors[#survivors + 1] = entry
      end
    end
    entries = survivors
  end

  if type(dispatcher) == "string" then
    dispatcher = hl.dsp.exec_cmd(dispatcher)
  end

  local handle = hl.bind(keys, dispatcher, opts)
  if handle then
    entries[#entries + 1] = {
      dedup = dedup, keys = keys, dispatcher = dispatcher, opts = opts, handle = handle,
    }
  end
  registered[canonical] = entries
end

function o.rebind(keys, description, dispatcher, options)
  local canonical = canonical_keys(keys)

  -- Also remove direct hl.bind calls, and every spelling recorded by o.bind.
  hl.unbind(keys)
  for _, entry in ipairs(registered[canonical] or {}) do
    hl.unbind(entry.keys)
  end
  registered[canonical] = nil

  o.bind(keys, description, dispatcher, options)
end

function o.launch(command)
  return "uwsm-app -- " .. command
end

-- The command each function bind stands for, so the keybindings menu can still
-- run a bind that Hyprland only reports as Lua.
o.bind_commands = {}

-- Hand the launcher the focused window's pid, which it would otherwise ask
-- Hyprland for, to open the new terminal in that terminal's directory.
function o.launch_terminal()
  local function launch()
    local window = hl.get_active_window()
    if window and window.pid then
      hl.exec_cmd("omarchy-launch-terminal --pid=" .. window.pid)
    else
      hl.exec_cmd("omarchy-launch-terminal")
    end
  end

  o.bind_commands[launch] = "omarchy-launch-terminal"
  return launch
end

function o.exec_on_start(command)
  hl.on("hyprland.start", function()
    hl.exec_cmd(command)
  end)
end

function o.launch_on_start(command)
  o.exec_on_start(o.launch(command))
end

function o.launch_webapp(url)
  return "omarchy-launch-webapp " .. shell_quote(url)
end

function o.launch_webapp_sole(name, url)
  return "omarchy-launch-or-focus-webapp " .. shell_quote(name) .. " " .. shell_quote(url)
end

function o.launch_sole(match, command)
  return "omarchy-launch-or-focus " .. shell_quote(match) .. " " .. shell_quote(o.launch(command))
end

function o.bind_toggle(keys, description, toggle, options)
  o.bind(keys, description, "omarchy-toggle-" .. toggle, options)
end

-- Bind one action to a key's press and another to its release, as for
-- push-to-talk. Hyprland skips a plain release bind once another key or mouse
-- button is released during the hold, or once the modifiers have changed, so
-- typing while holding the key would never run the release. The release half
-- here is transparent and ignores modifiers, and runs only after its own press
-- did, so letting go of the key without the rest of the chord does nothing. It
-- is also non-consuming: a release bind that ignores modifiers would otherwise
-- take the key from apps whenever it is pressed with other modifiers, such as
-- Shift+F9, or without them, such as a plain x for SUPER + X.
function o.bind_hold(keys, press_description, press, release_description, release, options)
  local held = false
  press, release = command_from(press, press_description), command_from(release, release_description)

  local function run(dispatcher)
    if type(dispatcher) == "string" then
      hl.exec_cmd(dispatcher)
    elseif type(dispatcher) == "function" then
      dispatcher()
    else
      hl.dispatch(dispatcher)
    end
  end

  local function on_press()
    held = true
    run(press)
  end

  local function on_release()
    if held then
      held = false
      run(release)
    end
  end

  if type(press) == "string" then
    o.bind_commands[on_press] = press
  end
  if type(release) == "string" then
    o.bind_commands[on_release] = release
  end

  local press_options, release_options = {}, {}
  for key, value in pairs(options or {}) do
    press_options[key], release_options[key] = value, value
  end
  -- Options that change when the press half fires would break the release half.
  for _, key in ipairs({ "repeating", "long_press", "click", "drag" }) do
    release_options[key] = nil
  end
  release_options.release, release_options.transparent = true, true
  release_options.ignore_mods, release_options.non_consuming = true, true

  o.bind(keys, press_description, on_press, press_options)
  o.bind(keys, release_description, on_release, release_options)
end

function o.notify(message)
  return "omarchy-notification-send -u low " .. shell_quote(message)
end

function o.window(match, rules)
  rules.match = rules.match or {}

  if type(match) == "string" then
    rules.match.class = match
  else
    for key, value in pairs(match) do
      rules.match[key] = value
    end
  end

  hl.window_rule(rules)
end

-- Opt a window in to Omarchy's standard active/inactive transparency.
function o.transparent_window(match, opacity)
  o.window(match, { opacity = opacity or "0.985 0.96" })
end
