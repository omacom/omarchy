"""Guard shortcut close requests for Foot, which has no native confirmation."""

import argparse
import fcntl
import json
import os
from pathlib import Path
import re
import subprocess


def server_session(pid):
  args = Path(f"/proc/{pid}/cmdline").read_bytes().split(b"\0")
  return any(arg in {b"-s", b"--server"} or arg.startswith(b"--server=") for arg in args[1:])


def process_stat(pid):
  # comm may contain spaces and parentheses. The remaining fields start at state.
  return Path(f"/proc/{pid}/stat").read_text().rsplit(")", 1)[1].split()


def children(pid):
  result = set()
  for task in Path(f"/proc/{pid}/task").iterdir():
    result.update(int(value) for value in (task / "children").read_text().split())
  return result


def idle_shell(pid):
  """Only exempt an ordinary interactive shell alone in its foreground PTY.

  Direct commands, background jobs, shell wrappers, and unreadable process state
  require confirmation. This deliberately does not guess from CPU use or titles.
  A Foot server owns several sessions, so it also requires confirmation.
  """
  try:
    if server_session(pid):
      return False
    child_pids = children(pid)
    if len(child_pids) != 1:
      return False
    shell_pid = child_pids.pop()
    executable = Path(os.readlink(f"/proc/{shell_pid}/exe")).name
    if executable not in {"bash", "dash", "fish", "ksh", "mksh", "zsh"}:
      return False
    args = Path(f"/proc/{shell_pid}/cmdline").read_bytes().split(b"\0")
    # A shell executing a script or -c command is not an idle login shell.
    for arg in filter(None, args[1:]):
      if arg not in {b"--login", b"--interactive"} and not re.fullmatch(rb"-[il]+", arg):
        return False
    state = process_stat(shell_pid)
    return (state[0] != "Z" and int(state[4]) != 0
            and state[2] == state[5] and not children(shell_pid))
  except (OSError, ValueError, IndexError):
    return False


def program_names(pid):
  # A server's children can belong to other windows. Don't attribute those
  # programs to the selected terminal, or include arguments containing secrets.
  try:
    if server_session(pid):
      return ""
    pending = list(children(pid))
    seen, names = set(), set()
    while pending:
      child = pending.pop()
      if child in seen:
        continue
      seen.add(child)
      if len(seen) > 256:
        return ""
      try:
        if process_stat(child)[0] != "Z":
          name = Path(os.readlink(f"/proc/{child}/exe")).name.removesuffix(" (deleted)")
          names.add(" ".join(name.split()))
          pending.extend(children(child))
      except (OSError, ValueError, IndexError):
        continue
    return ", ".join(sorted(names)[:6]) + (", …" if len(names) > 6 else "")
  except OSError:
    return ""


def hypr_json(*args):
  return json.loads(subprocess.check_output(["hyprctl", *args, "-j"], text=True))


def find_window(address):
  return next((window for window in hypr_json("clients")
               if window.get("address") == address), None)


def translate(command, *args):
  return subprocess.check_output([*command.split(), *args], text=True).strip()


def close_window(address):
  window = find_window(address)
  if not window:
    return
  pid = window["pid"]
  try:
    started = process_stat(pid)[19]
    executable = Path(os.readlink(f"/proc/{pid}/exe")).name.removesuffix(" (deleted)")
  except (OSError, ValueError, IndexError):
    return

  # Leave other terminals' native close policies alone. App-ids may be renamed
  # by the agent launcher, so identify Foot through its owning executable.
  if executable in {"foot", "footclient"} and not idle_shell(pid):
    cancel = translate("omarchy-i18n window.keepTerminal")
    close = translate("omarchy-i18n window.closeTerminal")
    title = " ".join(window.get("title", "").split())[:120] or address
    names = program_names(pid)
    details = (translate("omarchy-i18n window.terminalPrograms", names) if names
               else translate("omarchy-i18n window.terminalProgramsUnknown"))
    keep_option = f"\t{cancel}\t{title}"
    close_option = f"\t{close}\t{details}"
    result = subprocess.run(
      ["omarchy-menu-select", translate("omarchy-i18n window.confirmTerminalClose"),
       keep_option, close_option, "--", "--width", "600"],
      capture_output=True, text=True,
    )
    if result.returncode != 0 or result.stdout.strip() != f"{close}\t{details}":
      return

  # The menu can change focus. Never close whichever window happens to be active,
  # or a new window/process that reused the original identity while it was open.
  current = find_window(address)
  if not current or current.get("pid") != pid:
    return
  try:
    if process_stat(pid)[19] != started:
      return
  except (OSError, ValueError, IndexError):
    return
  subprocess.run(
    ["hyprctl", "dispatch", f'hl.dsp.window.close({{ window = "address:{address}" }})'],
    check=True, stdout=subprocess.DEVNULL,
  )


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("address", nargs="?", help="Hyprland window address (defaults to the active window)")
  args = parser.parse_args()
  address = args.address or hypr_json("activewindow").get("address", "")
  if not re.fullmatch(r"0x[0-9a-fA-F]+", address):
    return
  # Repeated shortcuts must not stack prompts (or authorize a different window).
  lock_path = Path(os.environ["XDG_RUNTIME_DIR"]) / "omarchy-terminal-close.lock"
  with lock_path.open("w") as lock:
    try:
      fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
      return
    close_window(address)


if __name__ == "__main__":
  main()
