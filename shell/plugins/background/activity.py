"""Local agent-turn activity, never quota polling or transcript content output."""

import datetime
import heapq
import json
import os
from pathlib import Path
import time

LEASE_SECONDS = 120
TAIL_BYTES = 1024 * 1024
MAX_FILES = 64


class Session:
  def __init__(self, provider):
    self.provider = provider
    self.offset = 0
    self.identity = None
    self.active = False
    self.closed = False
    self.updated = 0
    self.pulses = []

  def consume(self, record, now):
    if not isinstance(record, dict):
      return
    try:
      stamp = datetime.datetime.fromisoformat(record.get("timestamp", "").replace("Z", "+00:00")).timestamp()
    except (ValueError, TypeError, AttributeError):
      return
    if not now - LEASE_SECONDS <= stamp <= now + 5 or stamp < self.updated:
      return
    kind = record.get("type")
    starts = stops = progress = False
    if self.provider == "codex":
      payload = record.get("payload")
      if not isinstance(payload, dict):
        return
      event = payload.get("type")
      starts = kind == "event_msg" and event == "task_started"
      stops = kind == "event_msg" and event in ("task_complete", "turn_aborted")
      progress = (kind == "event_msg" and event in ("token_count", "item_completed")) or (
        kind == "response_item" and event in ("reasoning", "message", "function_call", "function_call_output", "custom_tool_call", "custom_tool_call_output"))
    else:
      message = record.get("message")
      message = message if isinstance(message, dict) else {}
      tool_result = bool(record.get("toolUseResult")) or any(
        isinstance(item, dict) and item.get("type") == "tool_result"
        for item in (message.get("content") if isinstance(message.get("content"), list) else []))
      starts = kind == "user" and not record.get("isMeta") and not tool_result
      stops = (kind == "system" and record.get("subtype") in ("turn_duration", "stop_hook_summary")) or (
        kind == "assistant" and message.get("stop_reason") in ("end_turn", "stop_sequence"))
      progress = kind == "assistant" or (kind == "user" and tool_result)
    if stops:
      self.active, self.closed = False, True
      self.pulses = []
    elif starts or (progress and not self.closed):
      self.active, self.closed = True, False
      self.pulses.append(stamp)
      self.pulses = self.pulses[-32:]
    else:
      return
    self.updated = stamp

  def read(self, path, now):
    try:
      with path.open("rb") as stream:
        stat = os.fstat(stream.fileno())
        identity = (stat.st_dev, stat.st_ino)
        if identity != self.identity or stat.st_size < self.offset:
          self.__init__(self.provider)
          self.identity = identity
        start = max(self.offset, stat.st_size - TAIL_BYTES)
        stream.seek(start)
        data = stream.read(TAIL_BYTES)
        if start > self.offset:
          newline = data.find(b"\n")
          start += newline + 1
          data = data[newline + 1:]
        end = data.rfind(b"\n") + 1
        self.offset = start + end
        # A single overlong record must not keep the reader stuck forever.
        if not end and len(data) == TAIL_BYTES:
          self.offset = stat.st_size
        for line in data[:end].splitlines():
          try:
            self.consume(json.loads(line), now)
          except (ValueError, UnicodeDecodeError):
            pass
    except OSError:
      self.active = False


class Monitor:
  def __init__(self, home):
    self.roots = {"claude": home / ".claude/projects", "codex": home / ".codex/sessions"}
    self.sessions = {}
    self.discovered = float("-inf")

  def discover(self, now):
    candidates = []
    for provider, root in self.roots.items():
      for directory, dirs, files in os.walk(root, followlinks=False):
        dirs[:] = [name for name in dirs if not name.startswith(".")]
        for name in files:
          if not name.endswith(".jsonl"):
            continue
          path = Path(directory) / name
          try:
            if path.is_symlink():
              continue
            modified = path.stat().st_mtime
            if modified >= now - LEASE_SECONDS:
              candidates.append((modified, str(path), provider))
          except OSError:
            continue
    selected = heapq.nlargest(MAX_FILES, candidates)
    self.sessions = {Path(path): self.sessions.get(Path(path), Session(provider)) for _, path, provider in selected}
    self.discovered = now

  def sample(self, now):
    if now - self.discovered >= 5:
      self.discover(now)
    counts = {"claude": 0, "codex": 0}
    pulses = dict(counts)
    for path, session in self.sessions.items():
      session.read(path, now)
      if session.active and 0 <= now - session.updated < LEASE_SECONDS:
        counts[session.provider] += 1
        pulses[session.provider] += sum(now - stamp < 10 for stamp in session.pulses)
    levels = {provider: round(min(1, 0.35 + 0.2 * (count - 1) + 0.025 * pulses[provider]), 3) if count else 0
              for provider, count in counts.items()}
    return {"levels": levels, "active": counts}


def main():
  monitor = Monitor(Path.home())
  try:
    while True:
      print(json.dumps(monitor.sample(time.time()), separators=(",", ":")), flush=True)
      time.sleep(1)
  except (BrokenPipeError, KeyboardInterrupt):
    pass


if __name__ == "__main__":
  main()
