"""Guard shortcut close requests for Foot, which has no native confirmation."""

import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess


def server_arguments(args):
  """Parse Foot options before its command, including compact short options.

  Unknown options mean opaque/shared state. Optional -s/-l values must be
  attached, just as in Foot's getopt grammar.
  """
  required_long = {
    "--config", "--override", "--font", "--term", "--title", "--app-id",
    "--toplevel-tag", "--pty", "--working-directory", "--window-size-pixels",
    "--window-size-chars", "--print-pid", "--log-level",
  }
  other_long = {"--check-config", "--maximized", "--fullscreen", "--login-shell",
                "--hold", "--log-colorize", "--log-no-syslog", "--version", "--help"}
  index = 1
  while index < len(args):
    arg = args[index]
    if arg == "--" or not arg.startswith("-") or arg == "-":
      break
    if arg.startswith("--"):
      option, separator, _ = arg.partition("=")
      if option == "--server":
        return True
      if option in required_long:
        if not separator:
          index += 1
      elif option not in other_long:
        return True
    else:
      for offset, option in enumerate(arg[1:], 1):
        if option == "s":
          return True
        if option in "coftTaDwWpd":
          if offset == len(arg) - 1:
            index += 1
          break
        if option == "l":
          break
        if option not in "CmFLHSveh":
          return True
    index += 1
  return False


def server_session(pid):
  args = [os.fsdecode(arg) for arg in Path(f"/proc/{pid}/cmdline").read_bytes().split(b"\0") if arg]
  return server_arguments(args)


def process_stat(pid):
  # comm may contain spaces and parentheses. The remaining fields start at state.
  return Path(f"/proc/{pid}/stat").read_text().rsplit(")", 1)[1].split()


def children(pid):
  result = set()
  for task in Path(f"/proc/{pid}/task").iterdir():
    result.update(int(value) for value in (task / "children").read_text().split())
  return result


def idle_shell(pid):
  """Best-effort exemption for a foreground shell with no child jobs.

  Direct commands, background jobs, shell wrappers, and unreadable process state
  require confirmation. This deliberately does not guess from CPU use or titles.
  Interactive shell builtins cannot be distinguished from a prompt; callers
  requiring stronger protection must use the always policy.
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


def process_identity(pid):
  started = executable = None
  try:
    started = process_stat(pid)[19]
  except (OSError, ValueError, IndexError):
    pass
  try:
    executable = Path(os.readlink(f"/proc/{pid}/exe")).name.removesuffix(" (deleted)")
  except OSError:
    pass
  return started, executable


def same_window(address, pid, started):
  current = find_window(address)
  if not current or current.get("pid") != pid:
    return False
  return started is None or process_identity(pid)[0] == started


def dispatch_close(address):
  subprocess.run(
    ["hyprctl", "dispatch", f'hl.dsp.window.close({{ window = "address:{address}" }})'],
    check=True, stdout=subprocess.DEVNULL,
  )


def close_window(address, policy="conditional"):
  window = find_window(address)
  if not window:
    return
  pid = window["pid"]
  started, executable = process_identity(pid)

  # Leave other terminals' native close policies alone. App-ids may be renamed
  # by the agent launcher, so identify Foot through its owning executable.
  foot = executable in {"foot", "footclient"} or (
    executable is None and window.get("class") in {"foot", "org.codeberg.dnkl.foot"})
  confirm = foot and policy != "never" and (policy == "always" or not idle_shell(pid))
  if not confirm:
    # An unreadable /proc entry must not disable closing ordinary GUI apps.
    # No confirmation is pending, so preserve the direct-close behavior.
    if same_window(address, pid, started):
      dispatch_close(address)
    return
  if started is None:
    return  # A pending terminal confirmation needs a verifiable process owner.

  identity = f"{os.environ.get('HYPRLAND_INSTANCE_SIGNATURE', '')}:{address}:{pid}:{started}"
  digest = hashlib.sha256(identity.encode()).hexdigest()[:24]
  lock_path = Path(os.environ["XDG_RUNTIME_DIR"]) / f"omarchy-terminal-close-{digest}.lock"
  with lock_path.open("w") as lock:
    try:
      fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
      return
    if not same_window(address, pid, started):
      return
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
       keep_option, close_option, "--", "--width", "600", "--timeout", "60"],
      capture_output=True, text=True,
    )
    if result.returncode != 0 or result.stdout.strip() != f"{close}\t{details}":
      return

    # The menu can change focus. Validate the captured target again; a server
    # owning several windows still cannot supply a compositor generation token.
    if same_window(address, pid, started):
      dispatch_close(address)


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("address", nargs="?", help="Hyprland window address (defaults to the active window)")
  parser.add_argument("--policy", choices=("always", "conditional", "never"), default="conditional")
  args = parser.parse_args()
  address = args.address or hypr_json("activewindow").get("address", "")
  if not re.fullmatch(r"0x[0-9a-fA-F]+", address):
    return
  close_window(address, args.policy)


if __name__ == "__main__":
  main()
