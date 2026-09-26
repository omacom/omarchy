-- Clipboard for sessions whose yanks may need to reach another machine, so that
-- yanking, deleting and putting behave the same whether Neovim is local, in
-- tmux, over SSH, or any combination of those. LazyVim empties 'clipboard'
-- whenever SSH_CONNECTION is set, which leaves a plain `y` in the unnamed
-- register; this restores 'unnamedplus' and backs it with a provider that has a
-- fast path in every one of those environments.
--
-- Writes go to whichever transports the session has: the local Wayland
-- clipboard when there is a display, and the terminal on the other end of the
-- connection via OSC 52 -- emitted by tmux itself where possible, since `tmux
-- load-buffer -w` keeps the payload out of tmux's own input parser and its size
-- limit. Reads prefer whichever clipboard the person is actually sitting in
-- front of, and fall back to the last value this Neovim copied rather than
-- blocking on an OSC 52 query that most terminals refuse to answer.
local M = {}

local function proc_lines(pid, file)
  local ok, lines = pcall(vim.fn.readfile, "/proc/" .. pid .. "/" .. file)
  return ok and lines or {}
end

local function proc_ppid(pid)
  for _, line in ipairs(proc_lines(pid, "status")) do
    local ppid = line:match("^PPid:%s+(%d+)")
    if ppid then
      return tonumber(ppid)
    end
  end
end

local function ancestor_process_named(name)
  local pid = vim.fn.getpid()

  for _ = 1, 16 do
    local ppid = proc_ppid(pid)
    if not ppid or ppid <= 1 then
      return false
    end

    local comm = proc_lines(ppid, "comm")[1] or ""
    if comm:find(name, 1, true) then
      return true
    end

    pid = ppid
  end

  return false
end

local function empty(lines)
  return lines == nil or #lines == 0 or (#lines == 1 and lines[1] == "")
end

function M.setup()
  local in_tmux = vim.env.TMUX ~= nil
  local in_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
  local in_herdr = vim.env.HERDR_PANE_ID ~= nil or ancestor_process_named("herdr")

  if not (in_tmux or in_ssh or in_herdr) then
    return
  end

  local osc52 = require("vim.ui.clipboard.osc52")
  local has_wayland = vim.env.WAYLAND_DISPLAY ~= nil
    and vim.fn.executable("wl-copy") == 1
    and vim.fn.executable("wl-paste") == 1
  local has_tmux = in_tmux and vim.fn.executable("tmux") == 1

  -- The last value this Neovim put on the clipboard, per register, as
  -- { lines, regtype }. A session with no readable clipboard still has to
  -- answer a put, and answering it with our own last copy keeps `"+y` `"+p`
  -- working instead of failing with E353.
  local last_copy = {}

  local function copy(register)
    local emit = osc52.copy(register)

    return function(lines, regtype)
      last_copy[register] = { lines, regtype or "" }

      if has_wayland then
        local cmd = { "wl-copy", "--sensitive", "--type", "text/plain" }
        if register == "*" then
          cmd[#cmd + 1] = "--primary"
        end
        vim.fn.system(cmd, lines)
      end

      if vim.g.omarchy_remote_clipboard_osc52 == false then
        return
      end

      -- tmux has no notion of a primary selection, so `*` keeps using the
      -- escape sequence directly.
      if has_tmux and register == "+" then
        vim.fn.system({ "tmux", "load-buffer", "-w", "-" }, lines)
      else
        emit(lines)
      end
    end
  end

  local function read_wayland(register)
    local cmd = { "wl-paste", "--no-newline" }
    if register == "*" then
      cmd[#cmd + 1] = "--primary"
    end

    local lines = vim.fn.systemlist(cmd, "", 1)
    if vim.v.shell_error == 0 then
      return lines
    end
  end

  -- `refresh-client -l` asks the attached client for its clipboard; the short
  -- sleep gives the reply time to land before the buffer is read. A terminal
  -- that refuses simply leaves tmux's newest buffer in place, so this returns
  -- something useful either way and never blocks the way an OSC 52 query does.
  local function read_tmux()
    local lines = vim.fn.systemlist(
      { "sh", "-c", "tmux refresh-client -l 2>/dev/null; sleep 0.05; tmux save-buffer -" },
      "",
      1
    )
    if vim.v.shell_error == 0 then
      return lines
    end
  end

  local function read_osc52(register)
    if not (vim.g.termfeatures or {}).osc52 then
      return
    end

    local result = osc52.paste(register)()
    if type(result) == "table" then
      return result
    end
  end

  local function paste(register)
    return function()
      local lines

      -- Over SSH the clipboard worth reading is the one on the machine the
      -- person is sitting at, which is the far end of the connection, not the
      -- display this Neovim happens to have.
      if in_ssh and has_tmux then
        lines = read_tmux()
      elseif has_wayland then
        lines = read_wayland(register)
      elseif has_tmux then
        lines = read_tmux()
      else
        lines = read_osc52(register)
      end

      if not empty(lines) then
        return lines
      end

      return last_copy[register] or { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
    end
  end

  vim.g.clipboard = {
    name = "OmarchyRemoteClipboard",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
    cache_enabled = 0,
  }

  -- LazyVim empties this whenever SSH_CONNECTION is set. Restore it so yanking,
  -- deleting and putting reach the clipboard exactly as they do locally.
  vim.opt.clipboard = "unnamedplus"
end

return M
