"""Static Hyprland loader and strict, non-executable keyboard data."""
import os
from pathlib import Path

from .deferred_runtime import (DATA_HEADER, DATA_HEADER_V1, FIELDS, MAX_DATA_BYTES,
               MAX_FIELD_BYTES, MAX_ROWS, SESSION_PATTERN,
               decode as _decode, render_rows as _render_rows)


MARKER = "-- Saved keyboard layouts. Loaded by default.hypr.toggles; data is never evaluated as Lua.\n"
PROMOTER = Path(__file__).with_name("deferred_runtime.py").read_bytes()


LOADER = (MARKER + r'''local state_home = os.getenv("XDG_STATE_HOME")
if not state_home or state_home == "" then
  state_home = (os.getenv("HOME") or "") .. "/.local/state"
end

local root = state_home .. "/omarchy/keyboard-layouts"
local helper = os.getenv("OMARCHY_PATH") .. "/shell/plugins/bar/widgets/keyboard/backend/deferred_runtime.py"
local prefix = "omarchy.keyboard-layout-promote-v1\n"
local maximum = 65536
local header_v1 = "omarchy.keyboard-layout-v1\n"
local header_v2 = "omarchy.keyboard-layout-v2\n"

local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function helper_data()
  local session = os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or ""
  local command = "/usr/bin/timeout --signal=TERM --kill-after=1s 2s "
    .. "/usr/bin/python3 -I -B " .. shell_quote(helper) .. " "
    .. shell_quote(root) .. " " .. shell_quote(session) .. " 2>/dev/null"
  local opened, handle = pcall(io.popen, command)
  if not opened or not handle then return nil end
  local output = handle:read(#prefix + maximum)
  local extra = handle:read(1)
  handle:close()
  if not output or extra or output:sub(1, #prefix) ~= prefix then return nil end
  return output:sub(#prefix + 1)
end

local function decode_hex(value, maximum_bytes)
  if #value > maximum_bytes * 2 or #value % 2 ~= 0 or value:find("[^0-9a-f]") then return nil end
  return (value:gsub("..", function(pair) return string.char(tonumber(pair, 16)) end))
end

local function read_rows(data)
  if not data or #data > maximum or data:sub(-1) ~= "\n" then return nil end
  local body
  if data:sub(1, #header_v2) == header_v2 then
    local encoded, remaining = data:sub(#header_v2 + 1):match("^session\t([0-9a-f]*)\n(.*)$")
    if not encoded then return nil end
    local saved_session = decode_hex(encoded, 256)
    if not saved_session or saved_session:find("[^%w_.:%-]") then return nil end
    body = remaining
  elseif data:sub(1, #header_v1) == header_v1 then
    body = data:sub(#header_v1 + 1)
  else
    return nil
  end

  local rows, names, count = {}, {}, 0
  for line in body:gmatch("([^\n]*)\n") do
    if line ~= "" then
      count = count + 1
      if count > 64 then return nil end
      local name, layout, variant, options = line:match(
        "^([0-9a-f]*)\t([0-9a-f]*)\t([0-9a-f]*)\t([0-9a-f]*)$")
      if not name then return nil end
      name, layout, variant, options = decode_hex(name, 4096), decode_hex(layout, 4096),
        decode_hex(variant, 4096), decode_hex(options, 4096)
      if not name or not layout or not variant or not options or name == "" or names[name] then return nil end
      names[name] = true
      table.insert(rows, {name = name, layout = layout, variant = variant, options = options})
    end
  end
  return rows
end

local rows = read_rows(helper_data())
if rows then
  for _, row in ipairs(rows) do
    hl.device({
      name = row.name,
      kb_layout = row.layout,
      kb_variant = row.variant,
      kb_options = row.options,
    })
  end
end
''').encode()


def _session(value=None):
  value = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "") if value is None else value
  _render_rows([], value)
  return value


def render_rows(targets, session=None):
  return _render_rows(targets, _session(session))


def render(saved, session=None):
  """Encode saved profiles as inert, strict device records."""
  targets = []
  profiles = saved.get("profiles", {})
  if not isinstance(profiles, dict):
    raise ValueError("saved profiles must be an object")
  for identity in sorted(profiles):
    group = profiles[identity]
    if not isinstance(group, list):
      raise ValueError("saved profile targets must be a list")
    targets.extend(group)
  return render_rows(targets, session)


def decode(data):
  return _decode(data)


def parse(data):
  """Validate and decode inert data for tests, migration, and diagnostics."""
  return decode(data)[1]


def saved_session(data):
  """Return the compositor session recorded in validated keyboard data."""
  return decode(data)[0]


def valid_file(path):
  from .deferred_runtime import UnsafeState, read_path
  try:
    parse(read_path(path, MAX_DATA_BYTES))
    return True
  except (OSError, ValueError, UnsafeState):
    return False
