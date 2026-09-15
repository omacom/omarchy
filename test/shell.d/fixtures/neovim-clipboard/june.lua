local M = {}
local uv = vim.uv or vim.loop

local function secure_runtime_dir()
  local uid = uv.getuid()
  local candidates = {}

  local function add(path)
    if path and path ~= "" then
      candidates[#candidates + 1] = path
    end
  end

  add(vim.env.XDG_RUNTIME_DIR)
  if uid then
    add("/run/user/" .. uid)
    add("/dev/shm/nvim-remote-clipboard-" .. uid)
  end

  for _, dir in ipairs(candidates) do
    if dir:sub(1, 9) == "/dev/shm/" then
      pcall(vim.fn.mkdir, dir, "p", 448)
      pcall(vim.fn.setfperm, dir, "rwx------")
    end

    local stat = uv.fs_stat(dir)
    if stat and stat.type == "directory" and stat.uid == uid and stat.mode % 512 == 448 then
      return dir
    end
  end
end

local function wayland_connection(runtime_dir)
  if vim.fn.executable("wl-copy") ~= 1 or vim.fn.executable("wl-paste") ~= 1 then
    return nil
  end

  local function valid_socket(path)
    local stat = uv.fs_stat(path)
    return stat and stat.type == "socket"
  end

  if vim.env.WAYLAND_DISPLAY and vim.env.WAYLAND_DISPLAY ~= "" then
    local display = vim.env.WAYLAND_DISPLAY
    local socket_path = display:sub(1, 1) == "/" and display or (runtime_dir .. "/" .. display)
    if valid_socket(socket_path) then
      return display
    end
  end

  for _, path in ipairs(vim.fn.glob(runtime_dir .. "/wayland-*", false, true)) do
    local display = vim.fn.fnamemodify(path, ":t")
    if not display:match("%.lock$") and valid_socket(path) then
      return display
    end
  end
end

local function write_private_file(path, payload)
  local tmp_path = path .. "." .. vim.fn.getpid() .. ".tmp"

  vim.fn.writefile({ payload }, tmp_path, "b")
  vim.fn.setfperm(tmp_path, "rw-------")
  vim.fn.rename(tmp_path, path)
  vim.fn.setfperm(path, "rw-------")
end

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

local function copy_to_client_clipboard(register, lines)
  if vim.g.omarchy_remote_clipboard_osc52 == false then
    return
  end

  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    pcall(osc52.copy(register), lines)
  end
end

function M.setup()
  local in_tmux = vim.env.TMUX ~= nil
  local has_display = vim.env.WAYLAND_DISPLAY or vim.env.DISPLAY
  local in_remote_session = vim.env.SSH_TTY or vim.env.SSH_CONNECTION
  local in_herdr = vim.env.HERDR_PANE_ID ~= nil or ancestor_process_named("herdr")
  local needs_remote_clipboard = not in_tmux and (in_herdr or (in_remote_session and not has_display))

  if not needs_remote_clipboard then
    return
  end

  local runtime_dir = secure_runtime_dir()
  if not runtime_dir then
    return
  end

  local wayland_display = wayland_connection(runtime_dir)
  local ttl_seconds = 10 * 60

  local function empty_clipboard()
    return { {}, "v" }
  end

  local function read_regtype(path)
    local stat = uv.fs_stat(path)
    if not stat or stat.uid ~= uv.getuid() or stat.mode % 512 ~= 384 then
      return "v"
    end

    local ok, file_lines = pcall(vim.fn.readfile, path)
    if not ok or #file_lines == 0 then
      return "v"
    end

    local ok_decode, data = pcall(vim.fn.json_decode, table.concat(file_lines, "\n"))
    if not ok_decode or type(data) ~= "table" then
      return "v"
    end

    if type(data.created_at) == "number" and os.time() - data.created_at > ttl_seconds then
      vim.fn.delete(path)
      return "v"
    end

    return type(data.regtype) == "string" and data.regtype or "v"
  end

  if wayland_display then
    local regtype_path = runtime_dir .. "/nvim-remote-clipboard-regtype.json"
    local env = {
      "env",
      "XDG_RUNTIME_DIR=" .. runtime_dir,
      "WAYLAND_DISPLAY=" .. wayland_display,
    }

    local function write_regtype(regtype)
      write_private_file(regtype_path, vim.fn.json_encode({
        regtype = regtype,
        created_at = os.time(),
      }))
    end

    local function copy(register)
      return function(lines, regtype)
        write_regtype(regtype)

        local cmd = vim.list_extend(vim.deepcopy(env), {
          "wl-copy",
          "--sensitive",
          "--type",
          "text/plain",
        })
        if register == "*" then
          cmd[#cmd + 1] = "--primary"
        end

        vim.fn.system(cmd, lines)
        copy_to_client_clipboard(register, lines)
      end
    end

    local function paste(register)
      return function()
        local cmd = vim.list_extend(vim.deepcopy(env), { "wl-paste", "--no-newline" })
        if register == "*" then
          cmd[#cmd + 1] = "--primary"
        end

        local lines = vim.fn.systemlist(cmd, "", 1)
        if vim.v.shell_error ~= 0 then
          return empty_clipboard()
        end

        return { lines, read_regtype(regtype_path) }
      end
    end

    vim.g.clipboard = {
      name = "OmarchyWaylandClipboard",
      copy = {
        ["+"] = copy("+"),
        ["*"] = copy("*"),
      },
      paste = {
        ["+"] = paste("+"),
        ["*"] = paste("*"),
      },
      cache_enabled = 0,
    }
  else
    local clipboard_path = runtime_dir .. "/nvim-remote-clipboard.json"

    local function copy(register)
      return function(lines, regtype)
        write_private_file(clipboard_path, vim.fn.json_encode({
          lines = lines,
          regtype = regtype,
          created_at = os.time(),
        }))
        copy_to_client_clipboard(register, lines)
      end
    end

    local function read_clipboard()
      local stat = uv.fs_stat(clipboard_path)
      if not stat or stat.uid ~= uv.getuid() or stat.mode % 512 ~= 384 then
        return empty_clipboard()
      end

      local ok, file_lines = pcall(vim.fn.readfile, clipboard_path)
      if not ok or #file_lines == 0 then
        return empty_clipboard()
      end

      local ok_decode, data = pcall(vim.fn.json_decode, table.concat(file_lines, "\n"))
      if not ok_decode or type(data) ~= "table" or type(data.lines) ~= "table" then
        return empty_clipboard()
      end

      if type(data.created_at) == "number" and os.time() - data.created_at > ttl_seconds then
        vim.fn.delete(clipboard_path)
        return empty_clipboard()
      end

      return { data.lines, data.regtype or "v" }
    end

    vim.g.clipboard = {
      name = "RemoteRuntimeClipboard",
      copy = {
        ["+"] = copy("+"),
        ["*"] = copy("*"),
      },
      paste = {
        ["+"] = read_clipboard,
        ["*"] = read_clipboard,
      },
      cache_enabled = 0,
    }
  end
end

return M
