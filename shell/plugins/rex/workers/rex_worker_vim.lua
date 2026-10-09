-- Rex worker for Vim's regex engine, run inside a headless Neovim:
--   nvim --clean --headless -l rex_worker_vim.lua
-- Same protocol as rex_worker.py: one JSON request per line on stdin,
-- replies one per line on stdout, match offsets in UTF-16 code units.
--
-- The text goes into a scratch buffer and is searched the way / searches it,
-- so ^ and $ mean line starts and ends and \n crosses lines. Vim reports
-- where a match starts and ends but only what its groups matched. Rex sends
-- where each group's body sits in the pattern (groupSpans), and the worker
-- finds the group by matching again with \zs and \ze around that body. A
-- group it cannot place that way (in a match across lines, or in a pattern
-- that sets \zs itself) is reported as -2, unknown.

local SLICE_SECONDS = 0.05

local function send(reply)
  io.stdout:write(vim.json.encode(reply), "\n")
  io.stdout:flush()
end

local function now()
  return vim.uv.hrtime() / 1e9
end

-- Byte offset of each line's start, and UTF-16 conversion of byte offsets.
local function layout(text)
  local starts = { 0 }
  for at in text:gmatch("()\n") do starts[#starts + 1] = at end
  local ascii = not text:find("[\128-\255]")
  local function units(from, to)
    local n, i = 0, from + 1
    while i <= to do
      local b = text:byte(i)
      if b < 0x80 then i = i + 1 n = n + 1
      elseif b >= 0xF0 then i = i + 4 n = n + 2
      elseif b >= 0xE0 then i = i + 3 n = n + 1
      elseif b >= 0xC0 then i = i + 2 n = n + 1
      else i = i + 1 end
    end
    return n
  end
  local at_byte, at_unit = 0, 0
  local function utf16(b)
    if b < 0 or ascii then return b end
    if b < at_byte then at_byte, at_unit = 0, 0 end
    at_unit = at_unit + units(at_byte, b)
    at_byte = b
    return at_unit
  end
  -- b from a nearby offset already converted, without moving the cursor: a
  -- match's groups sit close to its start.
  local function relative(from, from_unit, b)
    if b < 0 or ascii then return b end
    if b >= from then return from_unit + units(from, b) end
    return from_unit - units(b, from)
  end
  return starts, utf16, relative
end

local buffer = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buffer)

local text_id, text, starts, utf16, relative

-- Where group g of a match found at col (0-based, in this line) sits, as
-- 0-based byte offsets into the line: -1 when it matched nothing (Vim cannot
-- tell an empty group from one that did not take part), -2 when unknown.
local function locate(pattern, icase, span, line, col, value)
  if value == nil or not span then return -2, -2 end
  if value == "" then return -1, -1 end
  if pattern:find("\\z[se]") then return -2, -2 end
  -- groupSpans count UTF-16 units; Lua strings count bytes.
  local function byte_at(units)
    return vim.str_byteindex(pattern, "utf-16", units, false)
  end
  local open, close = byte_at(span[1]), byte_at(span[2])
  local marked = (icase and "\\c" or "") .. pattern:sub(1, open) .. "\\zs" .. pattern:sub(open + 1, close) .. "\\ze" .. pattern:sub(close + 1)
  local ok, found = pcall(vim.fn.matchstrpos, line, marked, col)
  if not ok or found[2] < 0 or found[1] ~= value then return -2, -2 end
  return found[2], found[3]
end

local function run_match(request)
  local pattern = request.pattern
  if vim.tbl_contains(request.flags or {}, "i") then pattern = "\\c" .. pattern end
  local ok, err = pcall(vim.fn.searchpos, pattern, "cnW")
  if not ok then
    send({ id = request.id, ok = false, done = true, error = (tostring(err):gsub("^Vim:", "")), matches = {}, stride = 2 })
    return
  end
  local groups = request.groups or 0
  local stride = (groups + 1) * 2
  local limit = request.limit or 100000
  local all = request.all ~= false
  local started = now()
  local slice = started
  local out = {}
  local count = 0
  vim.fn.cursor(1, 1)
  local flags = "cW"
  while true do
    local s = vim.fn.searchpos(pattern, flags)
    if s[1] == 0 then break end
    local line = vim.fn.getline(s[1])
    local start_byte = starts[s[1]] + s[2] - 1
    local found = vim.fn.matchstrpos(line, pattern, s[2] - 1)
    local end_byte, submatches
    if found[2] == s[2] - 1 and (found[3] < #line or not pattern:find("\\n") and not pattern:find("\\_")) then
      end_byte = starts[s[1]] + found[3]
      submatches = vim.fn.matchlist(line, pattern, s[2] - 1)
    else
      local e = vim.fn.searchpos(pattern, "cenW")
      if e[1] == 0 then
        end_byte = start_byte
      else
        -- The end is the last character of the match, inclusive.
        local last = vim.fn.getline(e[1])
        local width = #(vim.fn.strcharpart(last:sub(e[2]), 0, 1))
        end_byte = starts[e[1]] + e[2] - 1 + math.max(width, 1)
      end
    end
    local start_unit = utf16(start_byte)
    out[#out + 1] = start_unit
    out[#out + 1] = relative(start_byte, start_unit, end_byte)
    for g = 1, groups do
      local s0, e0 = locate(request.pattern, pattern ~= request.pattern, request.groupSpans and request.groupSpans[g], line, s[2] - 1, submatches and submatches[g + 1])
      if s0 == -1 then
        out[#out + 1] = -1
        out[#out + 1] = -1
      elseif s0 == -2 then
        out[#out + 1] = -2
        out[#out + 1] = -2
      else
        local line_start = starts[s[1]]
        out[#out + 1] = relative(start_byte, start_unit, line_start + s0)
        out[#out + 1] = relative(start_byte, start_unit, line_start + e0)
      end
    end
    count = count + 1
    if count >= limit or not all then break end
    flags = "W"
    if now() - slice > SLICE_SECONDS then
      send({ id = request.id, ok = true, done = false, matches = out, stride = stride, elapsed = (now() - started) * 1000 })
      out = {}
      slice = now()
    end
  end
  send({ id = request.id, ok = true, done = true, matches = out, stride = stride, elapsed = (now() - started) * 1000, names = vim.empty_dict() })
end

for line in io.stdin:lines() do
  local ok, request = pcall(vim.json.decode, line)
  if ok and type(request) == "table" then
    if request.op == "info" then
      local v = vim.version()
      send({ id = request.id, ok = true, done = true, versions = { vim = "Neovim " .. v.major .. "." .. v.minor .. "." .. v.patch } })
    else
      if request.textPath ~= nil then
        -- A file opened in Rex is read here rather than sent over the pipe.
        local f = io.open(request.textPath, "rb")
        if f then request.text = f:read("*a") f:close() end
      end
      if request.text ~= nil then
        text_id = request.textId
        text = request.text
        starts, utf16, relative = layout(text)
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(text, "\n", { plain = true }))
      end
      if text_id ~= request.textId then
        send({ id = request.id, ok = false, done = true, error = "missing-text", matches = {}, stride = 2 })
      else
        local fine, err = pcall(run_match, request)
        if not fine then
          send({ id = request.id, ok = false, done = true, error = (tostring(err):gsub("^.-:%d+: ", ""):gsub("^Vim:", "")), matches = {}, stride = 2 })
        end
      end
    end
  end
end
