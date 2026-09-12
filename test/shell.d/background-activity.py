import datetime
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("activity", Path(os.environ["ROOT"]) / "shell/plugins/background/activity.py")
activity = importlib.util.module_from_spec(spec)
spec.loader.exec_module(activity)
NOW = 1800000000


def event(kind, seconds=0, **extra):
  return {"timestamp": datetime.datetime.fromtimestamp(NOW + seconds, datetime.timezone.utc).isoformat(), "type": kind, **extra}


def codex(kind, seconds=0):
  return event("event_msg", seconds, payload={"type": kind})


class ActivityTest(unittest.TestCase):
  def test_codex_lifecycle_and_late_usage(self):
    session = activity.Session("codex")
    for ending in ("task_complete", "turn_aborted"):
      session.consume(codex("task_started"), NOW)
      self.assertTrue(session.active)
      session.consume(codex(ending), NOW)
      session.consume(codex("token_count"), NOW)
      self.assertFalse(session.active)

  def test_claude_lifecycle_and_metadata(self):
    session = activity.Session("claude")
    session.consume(event("user", isMeta=True), NOW)
    self.assertFalse(session.active)
    session.consume(event("user", message={"content": "private prompt"}), NOW)
    self.assertTrue(session.active)
    session.consume(event("assistant", message={"stop_reason": "tool_use"}), NOW)
    self.assertTrue(session.active)
    session.consume(event("system", subtype="turn_duration"), NOW)
    self.assertFalse(session.active)
    session.consume(event("user", message={"content": [{"type": "tool_result"}]}), NOW)
    self.assertFalse(session.active)
    session.consume(event("user", message={"content": "next"}), NOW)
    session.consume(event("assistant", message={"stop_reason": "end_turn"}), NOW)
    self.assertFalse(session.active)

  def test_old_future_and_malformed_records(self):
    session = activity.Session("codex")
    for record in (None, [], {}, {"timestamp": 42}, codex("task_started", -121), codex("task_started", 60), event("event_msg", payload=[])):
      session.consume(record, NOW)
    self.assertFalse(session.active)

  def test_incremental_partial_truncated_and_rotated_files(self):
    with tempfile.TemporaryDirectory() as folder:
      path = Path(folder) / "session.jsonl"
      session = activity.Session("codex")
      record = json.dumps(codex("task_started"))
      path.write_text(record[:30])
      session.read(path, NOW)
      self.assertFalse(session.active)
      with path.open("a") as f:
        f.write(record[30:] + "\n{bad json}\n")
      session.read(path, NOW)
      self.assertTrue(session.active)
      offset = session.offset
      session.read(path, NOW)
      self.assertEqual(session.offset, offset)
      self.assertEqual(len(session.pulses), 1)
      path.write_text(json.dumps(codex("task_complete")) + "\n")
      session.read(path, NOW)
      self.assertFalse(session.active)
      replacement = Path(folder) / "replacement"
      replacement.write_text(record + "\n")
      replacement.replace(path)
      session.read(path, NOW)
      self.assertTrue(session.active)

  def test_concurrency_expiry_and_private_output(self):
    with tempfile.TemporaryDirectory() as folder:
      home = Path(folder)
      for provider in ("claude", "codex"):
        root = home / (".claude/projects" if provider == "claude" else ".codex/sessions")
        root.mkdir(parents=True)
        for i in range(4):
          path = root / f"secret-project-{i}.jsonl"
          record = codex("task_started") if provider == "codex" else event("user", message={"content": "PRIVATE SECRET"})
          path.write_text(json.dumps(record) + "\n")
          os.utime(path, (NOW, NOW))
      monitor = activity.Monitor(home)
      result = monitor.sample(NOW)
      self.assertEqual(result["active"], {"claude": 4, "codex": 4})
      self.assertTrue(all(0.9 < level <= 1 for level in result["levels"].values()))
      self.assertNotIn("secret", json.dumps(result).lower())
      self.assertEqual(monitor.sample(NOW + 121)["levels"], {"claude": 0, "codex": 0})

  def test_bounded_tail(self):
    with tempfile.TemporaryDirectory() as folder:
      path = Path(folder) / "session.jsonl"
      path.write_bytes(b"x" * (activity.TAIL_BYTES * 2) + b"\n" + json.dumps(codex("task_started")).encode() + b"\n")
      session = activity.Session("codex")
      session.read(path, NOW)
      self.assertTrue(session.active)
      self.assertEqual(session.offset, path.stat().st_size)


if __name__ == "__main__":
  unittest.main()
