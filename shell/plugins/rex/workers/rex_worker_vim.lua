-- Rex worker for Vim's regex engine, run inside a headless Neovim:
--   nvim --clean --headless -l rex_worker_vim.lua
-- Same protocol as rex_worker.py: one JSON request per line on stdin,
-- replies one per line on stdout, match offsets in UTF-16 code units.
--
-- The text goes into a scratch buffer and is searched the way / searches it,
-- so ^ and $ mean line starts and ends and \n crosses lines. Vim reports
-- where a match starts and ends but only what its groups matched, so a
-- group is placed at the first place its text occurs in the match, after
-- the group before it.

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
  return starts, utf16
end

local buffer = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buffer)

local text_id, text, starts, utf16

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
    out[#out + 1] = utf16(end_byte)
    local matched = text:sub(start_byte + 1, end_byte)
    local from = 1
    for g = 1, groups do
      local value = submatches and submatches[g + 1]
      local at = value and value ~= "" and matched:find(value, from, true)
      if value == "" and submatches then at = from end
      if at then
        out[#out + 1] = utf16(start_byte + at - 1)
        out[#out + 1] = utf16(start_byte + at - 1 + #value)
        from = at
      else
        out[#out + 1] = -1
        out[#out + 1] = -1
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
      if request.text ~= nil then
        text_id = request.textId
        text = request.text
        starts, utf16 = layout(text)
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
