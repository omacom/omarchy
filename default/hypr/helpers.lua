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

local function dispatcher_from(value, description)
  value = command_from(value, description)

  if type(value) == "string" then
    return hl.dsp.exec_cmd(value)
  end

  return value
end

-- Managed keyboard holds need raw release state: native modifier releases may
-- skip the main callback, and ending a hold marks the companion releasePending.
local managed_holds = {}
local active_hold
local function hold_binding_key(keys) return keys:lower():gsub("%s+", "") end

local function bind(keys, description, dispatcher, options, replace)
  local opts = {}
  for key, value in pairs(options or {}) do opts[key] = value end
  local double_press = opts.double_press
  local function hold_kind(action)
    if type(action) ~= "table" or action.hold == nil then return nil end
    assert(action.hold == "drag" or action.hold == "resize", "hold must be 'drag' or 'resize'")
    for key in pairs(action) do assert(key == "hold", "hold actions cannot contain launch-helper fields") end
    return action.hold
  end
  local single_hold, double_hold = hold_kind(dispatcher), hold_kind(double_press)
  local native_hold = single_hold ~= nil or double_hold ~= nil
  local keycode = opts.hold_keycode
  assert(opts.single_press_hold == nil and opts.double_press_hold == nil, "use typed hold actions")
  if native_hold then
    assert(double_press ~= nil, "hold actions require double_press")
    assert(not opts.release and not opts.click and not opts.drag, "hold actions require a press binding")
    assert(type(keycode) == "number" and keycode % 1 == 0 and keycode >= 8 and keycode <= 767,
      "keyboard hold actions require hold_keycode (XKB keycode, evdev + 8)")
    assert(type(hl.on) == "function" and type(hl.dsp.window.resize) == "function" and
      type(hl.dsp.window.drag) == "function", "hold actions require stock keyboard events and window dispatchers")
  else
    assert(keycode == nil, "hold_keycode requires a typed hold action")
  end
  local function convert(action, hold)
    if hold then return hl.dsp.window[hold]() end
    return dispatcher_from(action, description)
  end
  local timeout = opts.timeout
  if timeout == nil then timeout = 250 end
  if double_press ~= nil then
    assert(not opts.repeating and not opts.long_press, "double_press cannot be combined with repeating or long_press")
    assert(type(timeout) == "number" and timeout >= 1 and timeout <= 2147483647 and timeout % 1 == 0,
      "double_press timeout must be a positive integer in milliseconds (at most 2147483647)")
    double_press = convert(double_press, double_hold)
    assert(type(double_press) == "function" or type(double_press) == "table" or type(double_press) == "userdata",
      "double_press must be a command, launch helper, dispatcher, or function")
    opts.double_press, opts.timeout = nil, nil
  end
  opts.hold_keycode = nil
  if description then opts.description = description end
  dispatcher = convert(dispatcher, single_hold)
  local binding, release_binding, subscription, managed
  local pending, held, physical_state, owned_hold
  local generation = 0
  local registry_key = hold_binding_key(keys)
  local function live(handle) return handle and tostring(handle) ~= "HL.Keybind(expired)" end
  local function enabled() return live(binding) and binding:is_enabled() end
  local function run(action)
    if type(action) == "function" then action() else hl.dispatch(action) end
  end
  local end_action = native_hold and hl.dsp.window.resize() or nil
  local function cancel_pending()
    -- Stock one-shot timers release their callback only after firing. Disarming
    -- them retains it indefinitely, so invalidate the token and let them finish.
    pending = nil
  end
  local function unsubscribe()
    if subscription then subscription:remove(); subscription = nil end
  end
  local function reset_hold(stop)
    generation = generation + 1
    cancel_pending()
    held, physical_state = false, nil
    local owner = owned_hold
    owned_hold = nil
    if stop and owner then
      -- Handle methods can be called from another key's press callback. Stop
      -- outside that context; a newer managed hold invalidates this stop.
      hl.timer(function()
        if active_hold ~= owner then return end
        active_hold = nil
        run(end_action)
      end, { timeout = 1, type = "oneshot" })
    end
  end
  local function observe()
    subscription = hl.on("input.keyboard.key", function(code, _, state)
      if not live(binding) then
        unsubscribe()
        reset_hold(false)
        if managed_holds[registry_key] == managed then managed_holds[registry_key] = nil end
        return
      end
      if code ~= keycode then return end
      physical_state = state
      -- Clear even if a submap/inhibition suppresses the release companion.
      -- Native input handling also ends its drag on that physical event.
      if state == 0 then held = false end
    end)
  end
  local function start(action)
    owned_hold = {}
    active_hold = owned_hold
    run(action)
  end
  if double_press ~= nil then
    local single_press = dispatcher
    assert(type(single_press) == "function" or type(single_press) == "table" or type(single_press) == "userdata",
      "double_press needs a single-press command, launch helper, dispatcher, or function")
    dispatcher = function()
      if native_hold then
        if physical_state ~= 1 or held then return end
        held = true
      end
      if pending then
        cancel_pending()
        if double_hold then
          start(double_press)
        else
          local action_generation = generation
          hl.timer(function()
            if generation == action_generation and enabled() then run(double_press) end
          end, { timeout = 1, type = "oneshot" })
        end
      else
        local press = {}
        pending = press
        hl.timer(function()
          if pending ~= press then return end
          pending = nil
          if enabled() and not single_hold then run(single_press) end
        end, { timeout = timeout, type = "oneshot" })
        -- Native holds need this physical press context. The first action has
        -- already occurred even when a second press chooses the double action.
        if single_hold then start(single_press) end
      end
    end
    if not single_hold then o.bind_commands[dispatcher] = o.bind_commands[single_press] or single_press end
  end
  -- Validate and construct every action before replacing an existing binding.
  if replace then
    local previous = managed_holds[registry_key]
    if previous then previous:remove() end
    hl.unbind(keys)
  end
  binding = hl.bind(keys, dispatcher, opts)
  if not native_hold then return binding end
  local release_options = {}
  for key, value in pairs(opts) do release_options[key] = value end
  release_options.description = nil
  release_options.release, release_options.transparent = true, true
  release_options.ignore_mods, release_options.non_consuming = true, true
  local ok, err = pcall(function()
    release_binding = hl.bind(keys, function()
      -- Native end sets releasePending on this companion, which can make it
      -- run on the next press. Only a real release may end the current hold.
      if physical_state ~= 0 then return end
      held = false
      if owned_hold then
        if active_hold == owned_hold then active_hold = nil end
        owned_hold = nil
        run(end_action)
      end
    end, release_options)
    observe()
  end)
  if not ok then
    unsubscribe()
    if live(binding) then binding:remove() end
    error(err)
  end
  local methods = {}
  function methods:set_enabled(value)
    assert(type(value) == "boolean", "set_enabled expects a boolean")
    unsubscribe()
    reset_hold(live(binding))
    if not live(binding) then return end
    binding:set_enabled(value)
    if live(release_binding) then release_binding:set_enabled(value) end
    if value then observe() end
  end
  function methods:is_enabled()
    return enabled() and live(release_binding) and release_binding:is_enabled()
  end
  function methods:remove()
    unsubscribe()
    reset_hold(live(binding))
    if managed_holds[registry_key] == managed then managed_holds[registry_key] = nil end
    -- An expired old handle must not remove replacement bindings on its chord.
    if not live(binding) then return end
    binding:remove()
    if live(release_binding) then release_binding:remove() end
  end
  methods.unbind = methods.remove
  managed = setmetatable({}, {
    __index = function(_, key) return methods[key] or binding[key] end,
    __newindex = function() error("keybind properties are read-only", 2) end,
    __tostring = function() return tostring(binding) end,
  })
  managed_holds[registry_key] = managed
  return managed
end

function o.bind(keys, description, dispatcher, options)
  return bind(keys, description, dispatcher, options, false)
end

function o.rebind(keys, description, dispatcher, options)
  return bind(keys, description, dispatcher, options, true)
end

function o.launch(command)
  return "uwsm-app -- " .. command
end

-- The command or dispatcher each function bind stands for, so the keybindings
-- menu can still run a bind that Hyprland only reports as Lua.
-- Native bindings keep their callbacks alive. Removed bindings should not be
-- retained just because the menu recorded their single action.
o.bind_commands = setmetatable({}, { __mode = "k" })

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

-- What makes apps float on their own account, so a floating workspace can
-- leave their floating to them: the class and title patterns of rules that
-- float them, the tags rules float, and the patterns of rules that tag them.
o.floating_apps = { class = {}, title = {}, tags = {}, tagged = {} }

function o.window(match, rules)
  rules.match = rules.match or {}

  if type(match) == "string" then
    rules.match.class = match
  else
    for key, value in pairs(match) do
      rules.match[key] = value
    end
  end

  if rules.float == true then
    -- Only a rule floating a tag alone floats everything with that tag; one
    -- that also names a class or title floats just those, recorded below.
    if type(rules.match.tag) == "string" and rules.match.class == nil and rules.match.title == nil then
      o.floating_apps.tags[rules.match.tag] = true
    end
    for _, key in ipairs({ "class", "title" }) do
      if type(rules.match[key]) == "string" then
        table.insert(o.floating_apps[key], rules.match[key])
      end
    end
  end

  if type(rules.tag) == "string" and rules.tag:sub(1, 1) == "+" then
    local tag = rules.tag:sub(2)
    o.floating_apps.tagged[tag] = o.floating_apps.tagged[tag] or {}
    for _, key in ipairs({ "class", "title" }) do
      if type(rules.match[key]) == "string" then
        table.insert(o.floating_apps.tagged[tag], { key = key, pattern = rules.match[key] })
      end
    end
  end

  hl.window_rule(rules)
end

-- Opt a window in to Omarchy's standard active/inactive transparency. The tag
-- lets Appearance > Window Opacity turn these windows opaque or glassy.
function o.transparent_window(match, opacity)
  o.window(match, { opacity = opacity or "0.985 0.96", tag = "+transparent-window" })
end
