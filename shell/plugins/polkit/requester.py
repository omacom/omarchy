#!/usr/bin/env python3
"""Identify the coding agent behind a waiting pkexec prompt.

Polkit knows which process asked, but Quickshell doesn't expose it. This scans
this user's pkexec processes matching the command line shown in the prompt,
walks up each one's parents to the first known agent, and prints:

  <mark>\t<display name>\t<1 if -light.svg exists else 0>

or nothing when no single agent is identified. This names a process and proves
nothing: any program can call itself claude.
"""

import os
import sys
from pathlib import Path

AGENTS = {
  "claude": ("claude", "Claude"),
  "codex": ("codex", "Codex"),
  "agy": ("agy", "Antigravity"),
  "grok": ("grok", "Grok"),
  "opencode": ("opencode", "OpenCode"),
  "cursor-agent": ("cursor", "Cursor"),
  "copilot": ("copilot", "Copilot"),
  "hermes": ("hermes", "Hermes"),
  "kimi": ("kimi", "Kimi"),
  "qwen": ("qwen", "Qwen"),
  "devin": ("devin", "Devin"),
  "muse": ("muse", "Muse"),
  "dsh": ("deepseek", "DeepSeek"),
  "mcode": ("minimax", "MiniMax"),
}

INTERPRETERS = {"node", "bun", "deno", "python", "python3"}

ENV_AGENTS = (
  ("CLAUDECODE=1", True, AGENTS["claude"]),
  ("AI_AGENT=claude-code", False, AGENTS["claude"]),
  ("ANTIGRAVITY_AGENT=1", True, AGENTS["agy"]),
  ("OPENCODE=1", True, AGENTS["opencode"]),
  ("CURSOR_AGENT=1", True, AGENTS["cursor-agent"]),
)

ASSETS_DIR = Path(__file__).resolve().parent.parent / "agents" / "assets"


def read_text(path: Path) -> str:
  try:
    return path.read_text(errors="replace")
  except OSError:
    return ""


def nul_fields(path: Path) -> list[str]:
  try:
    data = path.read_bytes()
  except OSError:
    return []
  if not data:
    return []
  return [p.decode(errors="replace") for p in data.removesuffix(b"\0").split(b"\0")]


def runs_shown(pdir: Path, shown: str) -> bool:
  argv = nul_fields(pdir / "cmdline")
  i = 1
  while i < len(argv):
    if argv[i] == "--":
      i += 1
      break
    if argv[i] in ("--user", "-u"):
      i += 2
    elif argv[i].startswith("--"):
      i += 1
    else:
      break
  if i >= len(argv):
    return False
  program, rest = argv[i], "".join(" " + arg for arg in argv[i + 1 :])
  if program.startswith("/"):
    raw = (program + rest).encode()
    line = (raw[:38] + b" ... " + raw[-37:]).decode(errors="replace") if len(raw) > 80 else program + rest
    return line == shown
  clean = program.removeprefix("./")
  bare = "/" + clean + rest
  if shown.endswith(bare) and " " not in shown[: len(shown) - len(bare)]:
    return True
  raw_shown = shown.encode()
  shown_exe = shown.split(" ", 1)[0]
  return (
    len(raw_shown) == 80
    and raw_shown[38:43] == b" ... "
    and shown_exe.endswith("/" + clean)
    and raw_shown.endswith(bare.encode()[-37:])
  )


def real_uid(pdir: Path) -> int | None:
  for line in read_text(pdir / "status").splitlines():
    if line.startswith("Uid:"):
      parts = line.split()
      return int(parts[1]) if len(parts) >= 2 and parts[1].isdigit() else None
  return None


def parent_pid(pdir: Path) -> int | None:
  stat = read_text(pdir / "stat")
  end = stat.rfind(") ")
  if end == -1:
    return None
  fields = stat[end + 2 :].split()
  return int(fields[1]) if len(fields) >= 2 and fields[1].isdigit() else None


def agent_of(proc_root: Path, pid: int) -> tuple[str, str] | None:
  first = parent_pid(proc_root / str(pid))
  if not first:
    return None
  cur = first
  for _ in range(64):
    if cur <= 1:
      break
    pdir = proc_root / str(cur)
    comm = read_text(pdir / "comm").strip()
    if not comm:
      break
    if comm in AGENTS:
      return AGENTS[comm]
    if comm in INTERPRETERS:
      argv = nul_fields(pdir / "cmdline")
      if len(argv) >= 2 and os.path.basename(argv[1]) in AGENTS:
        return AGENTS[os.path.basename(argv[1])]
    nxt = parent_pid(pdir)
    if not nxt or nxt == cur:
      break
    cur = nxt

  for entry in nul_fields(proc_root / str(first) / "environ"):
    for needle, exact, agent in ENV_AGENTS:
      if (entry == needle) if exact else entry.startswith(needle):
        return agent
  return None


def main() -> None:
  shown = sys.argv[1] if len(sys.argv) > 1 else ""
  if not shown:
    return
  proc_root = Path(os.environ.get("OMARCHY_PROC_ROOT") or "/proc")
  uid = os.getuid()
  found: set[tuple[str, str] | None] = set()
  try:
    entries = os.scandir(proc_root)
  except OSError:
    return
  with entries:
    for entry in entries:
      if not entry.name.isdigit() or not entry.is_dir():
        continue
      pdir = Path(entry.path)
      if read_text(pdir / "comm").strip() == "pkexec" and real_uid(pdir) == uid and runs_shown(pdir, shown):
        found.add(agent_of(proc_root, int(entry.name)))

  if len(found) == 1:
    agent = next(iter(found))
    if agent is not None:
      mark, name = agent
      has_light = 1 if (ASSETS_DIR / f"{mark}-light.svg").is_file() else 0
      print(f"{mark}\t{name}\t{has_light}")


if __name__ == "__main__":
  main()
