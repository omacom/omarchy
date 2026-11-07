-- Rex worker for Lua patterns (Lua 5.1's string library). Same protocol as
-- rex_worker.py: one JSON request per line on stdin, replies one per line on
-- stdout, match offsets in UTF-16 code units.
--
-- string.find reports what each capture matched but not where, so every
-- capture gets a position capture () in front of it; capture k becomes 2k
-- and its start is capture 2k - 1.

-- ---- JSON ------------------------------------------------------------------

local json = {}

local escapes = { ['"'] = '\\"', ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }

local function encode_string(s)
  return '"' .. s:gsub('[%c"\\]', function(c)
    return escapes[c] or string.format("\\u%04x", c:byte())
  end) .. '"'
end

function json.encode(v)
  local t = type(v)
  if t == "nil" then return "null" end
  if t == "boolean" then return tostring(v) end
  if t == "number" then
    if v == math.floor(v) and math.abs(v) < 2 ^ 53 then return string.format("%d", v) end
    return string.format("%.17g", v)
  end
  if t == "string" then return encode_string(v) end
  if v.__array then
    local parts = {}
    for i = 1, v.n or #v do parts[i] = json.encode(v[i]) end
    return "[" .. table.concat(parts, ",") .. "]"
  end
  local parts = {}
  for k, value in pairs(v) do
    if k ~= "__array" then parts[#parts + 1] = encode_string(tostring(k)) .. ":" .. json.encode(value) end
  end
  return "{" .. table.concat(parts, ",") .. "}"
end

local function array(t) t.__array = true return t end

local function utf8_char(cp)
  if cp < 0x80 then return string.char(cp) end
  if cp < 0x800 then return string.char(0xC0 + math.floor(cp / 64), 0x80 + cp % 64) end
  if cp < 0x10000 then return string.char(0xE0 + math.floor(cp / 4096), 0x80 + math.floor(cp / 64) % 64, 0x80 + cp % 64) end
  return string.char(0xF0 + math.floor(cp / 262144), 0x80 + math.floor(cp / 4096) % 64, 0x80 + math.floor(cp / 64) % 64, 0x80 + cp % 64)
end

function json.decode(s)
  local pos = 1
  local function ws() pos = s:find("[^ \t\r\n]", pos) or #s + 1 end
  local value
  local function str()
    pos = pos + 1
    local out = {}
    while true do
      local c = s:sub(pos, pos)
      if c == "" then error("unterminated string") end
      if c == '"' then pos = pos + 1 break end
      if c == "\\" then
        local e = s:sub(pos + 1, pos + 1)
        if e == "u" then
          local cp = tonumber(s:sub(pos + 2, pos + 5), 16)
          pos = pos + 6
          if cp >= 0xD800 and cp <= 0xDBFF and s:sub(pos, pos + 1) == "\\u" then
            local low = tonumber(s:sub(pos + 2, pos + 5), 16)
            if low >= 0xDC00 and low <= 0xDFFF then
              cp = 0x10000 + (cp - 0xD800) * 1024 + (low - 0xDC00)
              pos = pos + 6
            end
          end
          out[#out + 1] = utf8_char(cp)
        else
          out[#out + 1] = ({ b = "\b", f = "\f", n = "\n", r = "\r", t = "\t" })[e] or e
          pos = pos + 2
        end
      else
        local stop = s:find('["\\]', pos) or #s + 1
        out[#out + 1] = s:sub(pos, stop - 1)
        pos = stop
      end
    end
    return table.concat(out)
  end
  function value()
    ws()
    local c = s:sub(pos, pos)
    if c == "{" then
      pos = pos + 1
      local t = {}
      ws()
      if s:sub(pos, pos) == "}" then pos = pos + 1 return t end
      while true do
        ws()
        local k = str()
        ws()
        pos = pos + 1
        t[k] = value()
        ws()
        local d = s:sub(pos, pos)
        pos = pos + 1
        if d == "}" then return t end
      end
    elseif c == "[" then
      pos = pos + 1
      local t = array({})
      ws()
      if s:sub(pos, pos) == "]" then pos = pos + 1 return t end
      while true do
        t[#t + 1] = value()
        ws()
        local d = s:sub(pos, pos)
        pos = pos + 1
        if d == "]" then return t end
      end
    elseif c == '"' then
      return str()
    elseif s:sub(pos, pos + 3) == "true" then pos = pos + 4 return true
    elseif s:sub(pos, pos + 4) == "false" then pos = pos + 5 return false
    elseif s:sub(pos, pos + 3) == "null" then pos = pos + 4 return nil
    end
    local num = s:match("^-?%d+%.?%d*[eE]?[-+]?%d*", pos)
    pos = pos + #num
    return tonumber(num)
  end
  return value()
end

-- ---- offsets ------------------------------------------------------------------

-- UTF-8 byte offsets (0-based) to UTF-16. Offsets mostly move forward, so the
-- count continues from the last one.
local function converter(text)
  local ascii = not text:find("[\128-\255]")
  local at_byte, at_unit = 0, 0
  local function units(from, to)
    local n = 0
    local i = from + 1
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
  local function convert(b)
    if b < 0 or ascii then return b end
    if b < at_byte then at_byte, at_unit = 0, 0 end
    at_unit = at_unit + units(at_byte, b)
    at_byte = b
    return at_unit
  end
  -- b from a nearby offset already converted, without moving the cursor: a
  -- match's captures sit close to its start.
  local function relative(from, from_unit, b)
    if b < 0 or ascii then return b end
    if b >= from then return from_unit + units(from, b) end
    return from_unit - units(b, from)
  end
  return { convert = convert, relative = relative }
end

-- ---- patterns -------------------------------------------------------------------

-- Puts () before every capture and renumbers %1-%9 to match. Returns the new
-- pattern and the number of captures, or nil and a message.
local function instrument(pattern)
  local out = {}
  local i = 1
  local captures = 0
  local n = #pattern
  while i <= n do
    local c = pattern:sub(i, i)
    if c == "%" then
      local e = pattern:sub(i + 1, i + 1)
      if e:match("%d") and e ~= "0" then
        local mapped = tonumber(e) * 2
        if mapped > 9 then return nil, "Rex cannot locate captures in a pattern that refers back to capture " .. e end
        out[#out + 1] = "%" .. mapped
      elseif e == "b" then
        out[#out + 1] = pattern:sub(i, i + 3)
        i = i + 2
      else
        out[#out + 1] = c .. e
      end
      i = i + 2
    elseif c == "[" then
      -- A set runs to the first ] that is not its first character or escaped.
      local j = i + 1
      if pattern:sub(j, j) == "^" then j = j + 1 end
      if pattern:sub(j, j) == "]" then j = j + 1 end
      while j <= n and pattern:sub(j, j) ~= "]" do
        if pattern:sub(j, j) == "%" then j = j + 1 end
        j = j + 1
      end
      out[#out + 1] = pattern:sub(i, j)
      i = j + 1
    elseif c == "(" then
      captures = captures + 1
      out[#out + 1] = "()("
      i = i + 1
    else
      out[#out + 1] = c
      i = i + 1
    end
  end
  return table.concat(out), captures
end

local SLICE_SECONDS = 0.05

local function run_match(request, text, convert)
  local id = request.id
  local pattern, captures = instrument(request.pattern)
  if not pattern then
    return { id = id, ok = false, done = true, error = captures, matches = array({}), stride = 2 }
  end
  local limit = request.limit or 100000
  local all = request.all ~= false
  local started = os.clock()
  local out = array({})
  local count = 0
  local init = 1
  local anchored = request.pattern:sub(1, 1) == "^"
  local length = #text
  while init <= length + 1 do
    local found = { string.find(text, pattern, init) }
    if not found[1] then break end
    local s, e = found[1], found[2]
    local start_unit = convert.convert(s - 1)
    local function near(b) return convert.relative(s - 1, start_unit, b) end
    out[#out + 1] = start_unit
    out[#out + 1] = near(e)
    for k = 1, captures do
      local position, value = found[2 + 2 * k - 1], found[2 + 2 * k]
      if type(value) == "number" then
        out[#out + 1] = near(value - 1)
        out[#out + 1] = near(value - 1)
      elseif position then
        out[#out + 1] = near(position - 1)
        out[#out + 1] = near(position - 1 + #value)
      else
        out[#out + 1] = -1
        out[#out + 1] = -1
      end
    end
    count = count + 1
    if count >= limit or not all or anchored then break end
    init = e >= s and e + 1 or s + 1
  end
  out.n = #out
  return { id = id, ok = true, done = true, matches = out, stride = (captures + 1) * 2, elapsed = (os.clock() - started) * 1000, names = {} }
end

-- ---- main ------------------------------------------------------------------------

io.stdout:setvbuf("line")
local texts = {}
for line in io.stdin:lines() do
  local ok, request = pcall(json.decode, line)
  if ok and type(request) == "table" then
    local reply
    if request.op == "info" then
      reply = { id = request.id, ok = true, done = true, versions = { lua = _VERSION } }
    else
      if request.textPath then
        -- A file opened in Rex is read here rather than sent over the pipe.
        local f = io.open(request.textPath, "rb")
        if f then request.text = f:read("*a") f:close() end
      end
      if request.text then
        texts = { [request.textId] = { request.text, converter(request.text) } }
      end
      local entry = texts[request.textId]
      if not entry then
        reply = { id = request.id, ok = false, done = true, error = "missing-text", matches = array({}), stride = 2 }
      else
        local fine, result = pcall(run_match, request, entry[1], entry[2])
        -- Pattern errors surface while matching, prefixed with this file's
        -- name and line, which mean nothing to the user.
        reply = fine and result or { id = request.id, ok = false, done = true, error = (tostring(result):gsub("^.-:%d+: ", "")), matches = array({}), stride = 2 }
      end
    end
    io.stdout:write(json.encode(reply), "\n")
    io.stdout:flush()
  end
end
