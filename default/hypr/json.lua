-- Minimal strict JSON decoder for settings files Omarchy tools write as data.
-- Settings must never be loaded as Lua code, so anything the shell persists for
-- Hyprland is parsed here instead. Returns nil plus an error message on any
-- malformed input rather than raising.

local M = {}

-- Arrays decode to tables carrying this marker so callers can tell [] from {}.
M.array_mt = { __name = "json.array" }

local escapes = {
  ['"'] = '"',
  ["\\"] = "\\",
  ["/"] = "/",
  b = "\b",
  f = "\f",
  n = "\n",
  r = "\r",
  t = "\t",
}

local function utf8_char(code)
  if code < 0x80 then
    return string.char(code)
  elseif code < 0x800 then
    return string.char(0xC0 | (code >> 6), 0x80 | (code & 0x3F))
  elseif code < 0x10000 then
    return string.char(0xE0 | (code >> 12), 0x80 | ((code >> 6) & 0x3F), 0x80 | (code & 0x3F))
  end

  return string.char(
    0xF0 | (code >> 18),
    0x80 | ((code >> 12) & 0x3F),
    0x80 | ((code >> 6) & 0x3F),
    0x80 | (code & 0x3F)
  )
end

local function decoder(text)
  local pos = 1
  local depth = 0

  local function fail(message)
    error({ json = true, message = ("%s at byte %d"):format(message, pos) }, 0)
  end

  local function skip_whitespace()
    pos = text:find("[^ \t\r\n]", pos) or (#text + 1)
  end

  local value

  local function parse_string()
    pos = pos + 1
    local parts = {}

    while true do
      local chunk_end = text:find('["\\%c]', pos)
      if not chunk_end then
        fail("unterminated string")
      end

      parts[#parts + 1] = text:sub(pos, chunk_end - 1)
      local char = text:sub(chunk_end, chunk_end)
      pos = chunk_end + 1

      if char == '"' then
        return table.concat(parts)
      elseif char == "\\" then
        local escape = text:sub(pos, pos)
        if escape == "u" then
          local hex = text:sub(pos + 1, pos + 4)
          if not hex:match("^%x%x%x%x$") then
            fail("invalid unicode escape")
          end
          local code = tonumber(hex, 16)
          pos = pos + 5

          if code >= 0xD800 and code <= 0xDBFF then
            local low = text:match("^\\u(%x%x%x%x)", pos)
            local low_code = low and tonumber(low, 16)
            if not low_code or low_code < 0xDC00 or low_code > 0xDFFF then
              fail("invalid surrogate pair")
            end
            code = 0x10000 + ((code - 0xD800) << 10) + (low_code - 0xDC00)
            pos = pos + 6
          elseif code >= 0xDC00 and code <= 0xDFFF then
            fail("invalid surrogate pair")
          end

          parts[#parts + 1] = utf8_char(code)
        elseif escapes[escape] then
          parts[#parts + 1] = escapes[escape]
          pos = pos + 1
        else
          fail("invalid escape")
        end
      else
        fail("control character in string")
      end
    end
  end

  local function parse_number()
    local start = pos
    local integer = text:match("^-?0", pos) or text:match("^-?[1-9]%d*", pos)
    if not integer then
      fail("invalid number")
    end
    pos = pos + #integer

    local fraction = text:match("^%.%d+", pos)
    if fraction then
      pos = pos + #fraction
    elseif text:sub(pos, pos) == "." then
      fail("invalid number")
    end

    local exponent = text:match("^[eE][-+]?%d+", pos)
    if exponent then
      pos = pos + #exponent
    elseif text:match("^[eE]", pos) then
      fail("invalid number")
    end

    if text:match("^%d", pos) then
      fail("invalid number")
    end

    return tonumber(text:sub(start, pos - 1))
  end

  local function parse_literal(word, result)
    if text:sub(pos, pos + #word - 1) ~= word then
      fail("unexpected character")
    end
    pos = pos + #word
    return result
  end

  local function parse_container(open)
    depth = depth + 1
    if depth > 32 then
      fail("nesting too deep")
    end

    pos = pos + 1
    local result = open == "[" and setmetatable({}, M.array_mt) or {}
    local close = open == "[" and "]" or "}"

    skip_whitespace()
    if text:sub(pos, pos) == close then
      pos = pos + 1
      depth = depth - 1
      return result
    end

    while true do
      skip_whitespace()

      if open == "[" then
        result[#result + 1] = value()
      else
        if text:sub(pos, pos) ~= '"' then
          fail("expected object key")
        end
        local key = parse_string()
        skip_whitespace()
        if text:sub(pos, pos) ~= ":" then
          fail("expected ':'")
        end
        pos = pos + 1
        result[key] = value()
      end

      skip_whitespace()
      local char = text:sub(pos, pos)
      pos = pos + 1
      if char == close then
        depth = depth - 1
        return result
      elseif char ~= "," then
        pos = pos - 1
        fail("expected ',' or '" .. close .. "'")
      end
    end
  end

  -- null decodes to nil, which drops the key from its object; settings treat
  -- a null the same as an absent key.
  value = function()
    skip_whitespace()
    local char = text:sub(pos, pos)

    if char == "{" or char == "[" then
      return parse_container(char)
    elseif char == '"' then
      return parse_string()
    elseif char == "-" or char:match("%d") then
      return parse_number()
    elseif char == "t" then
      return parse_literal("true", true)
    elseif char == "f" then
      return parse_literal("false", false)
    elseif char == "n" then
      return parse_literal("null", nil)
    end

    fail("unexpected character")
  end

  return function()
    local result = value()
    skip_whitespace()
    if pos <= #text then
      fail("trailing characters")
    end
    return result
  end
end

function M.decode(text)
  if type(text) ~= "string" then
    return nil, "expected a string"
  end

  local ok, result = pcall(decoder(text))
  if ok then
    return result
  end

  if type(result) == "table" and result.json then
    return nil, result.message
  end

  return nil, tostring(result)
end

function M.is_array(value)
  return type(value) == "table" and getmetatable(value) == M.array_mt
end

function M.decode_file(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end

  local text = file:read("*a")
  file:close()
  return M.decode(text)
end

return M
