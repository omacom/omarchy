"""Exercise the clipboard store through its public CLI in disposable homes."""

import concurrent.futures
import hashlib
import json
import os
from pathlib import Path
import resource
import stat
import subprocess
import sys
import tempfile
import time


ROOT = Path(sys.argv[1])
STORAGE = ROOT / "shell/plugins/clipboard/storage.py"
MIB = 1024 * 1024


def check(condition, description):
  if not condition:
    raise AssertionError(description)


def compact(value):
  return json.dumps(value, ensure_ascii=False, separators=(",", ":")).encode()


def payloads(history):
  return [{key: value for key, value in entry.items() if key != "id"} for entry in history]


def memory_limit():
  # A sparse 1 GiB input must not become a 1 GiB read, even on roomy CI hosts.
  resource.setrlimit(resource.RLIMIT_AS, (96 * MIB, 96 * MIB))


class Store:
  def __init__(self, root, name, use_xdg=True):
    self.root = root / name
    self.home = self.root / "home"
    self.home.mkdir(parents=True)
    self.env = dict(os.environ, HOME=str(self.home), OMARCHY_PATH=str(ROOT))
    mock_bin = self.root / "bin"
    mock_bin.mkdir()
    notification = mock_bin / "omarchy-notification-send"
    notification.write_text("#!/bin/bash\nexit 0\n")
    notification.chmod(0o755)
    self.env["PATH"] = str(mock_bin) + os.pathsep + self.env["PATH"]
    self.env.pop("XDG_STATE_HOME", None)
    self.env.pop("PYTHONPATH", None)
    if use_xdg:
      self.env["XDG_STATE_HOME"] = str(self.root / "state")
    self.state = Path(self.env.get("XDG_STATE_HOME", self.home / ".local/state")) / "omarchy"
    self.history_path = self.state / "clipboard-history.json"
    self.images = self.state / "clipboard-images"

  def run(self, command, payload=b"", limited=False):
    return subprocess.run(
      [sys.executable, str(STORAGE), *command],
      input=payload,
      stdout=subprocess.PIPE,
      stderr=subprocess.PIPE,
      env=self.env,
      timeout=10,
      preexec_fn=memory_limit if limited else None,
    )

  def apply(self, action, entry=None, limited=False):
    command = {"action": action}
    if entry is not None:
      command["entry"] = entry
    result = self.run(["apply"], compact(command), limited)
    check(result.returncode == 0, f"apply {action} exits successfully: {result.stderr[:300]!r}")
    envelope = json.loads(result.stdout)
    check(isinstance(envelope.get("history"), list), f"apply {action} returns a history array")
    check(isinstance(envelope.get("blocked"), bool), f"apply {action} returns blocked status")
    return envelope

  def add(self, entry, accepted=True):
    result = self.run(["add"], compact(entry))
    if accepted:
      check(result.returncode == 0 and result.stdout, f"add accepts an entry: {result.stderr[:300]!r}")
      return json.loads(result.stdout)
    check(not result.stdout, "rejected add emits no partial entry")
    return None

  def image(self, data, mime="image/png", captured="Saturday 10:00", accepted=True):
    result = self.run(["image", mime, captured], data)
    if accepted:
      check(result.returncode == 0 and result.stdout, f"image accepts bytes: {result.stderr[:300]!r}")
      return json.loads(result.stdout)
    check(not result.stdout, "rejected image emits no partial entry")
    return None

  def read(self):
    return json.loads(self.history_path.read_bytes()) if self.history_path.exists() else []

  def seed(self, entries):
    self.state.mkdir(mode=0o700, parents=True, exist_ok=True)
    self.history_path.write_bytes(compact(entries))
    self.history_path.chmod(0o600)

  def consistent(self):
    history = self.read()
    check(len(history) <= 500, "history has at most 500 entries")
    check(not self.history_path.exists() or self.history_path.stat().st_size <= 8 * MIB,
          "history file remains within 8 MiB")
    references = {Path(entry["path"]) for entry in history if entry["type"] == "image"}
    files = {path for path in self.images.iterdir() if path.is_file() and not path.is_symlink()} if self.images.exists() else set()
    check(references == files, "committed image references and files agree before any cleanup read")
    check(sum(path.stat().st_size for path in references) <= 128 * MIB, "referenced images stay within 128 MiB")
    for path in references:
      check(path.parent == self.images, "image references stay inside the capture directory")
      check(stat.S_IMODE(path.stat().st_mode) == 0o600, "captured images are private")
      check(path.stem == hashlib.sha256(path.read_bytes()).hexdigest(), "image filename matches its bytes")
    return history


def test_text_limits(root):
  store = Store(root, "text")
  exact = {"type": "text", "text": "a" * (MIB - 2) + "\nZ"}
  check(store.add(exact) == exact, "exactly 1 MiB text preserves its trailing bytes")
  before = store.history_path.read_bytes()
  store.add({"type": "text", "text": exact["text"] + "!"}, accepted=False)
  check(store.history_path.read_bytes() == before, "over-limit text leaves history unchanged")
  unicode_entry = {"type": "text", "text": "😀" * (MIB // 4)}
  check(store.add(unicode_entry) == unicode_entry, "exactly 1 MiB of UTF-8 emoji is accepted intact")
  store.add({"type": "text", "text": unicode_entry["text"] + "a"}, accepted=False)
  check(payloads(store.read())[0] == unicode_entry, "UTF-8 limit is bytes and does not truncate a codepoint")
  check(payloads(store.apply("load")["history"])[0] == unicode_entry, "load preserves accepted text")
  store.consistent()


def test_history_limits(root):
  store = Store(root, "serialized")
  # Control characters expand sixfold when serialized, despite counting once
  # toward the text byte limit. The retained array must fit on disk too.
  first = {"type": "text", "text": "\x01" * MIB}
  second = {"type": "text", "text": "\x02" * MIB}
  check(store.add(first) == first, "JSON escaping does not lower the 1 MiB text limit")
  check(store.add(second) == second, "another escaped entry is accepted intact")
  check(payloads(store.read()) == [second], "serialized history budget evicts the older escaped entry")
  store.consistent()
  entries = [{"type": "text", "text": f"entry-{index}"} for index in range(500)]
  store.seed(entries)
  latest = {"type": "text", "text": "latest"}
  store.apply("add", latest)
  check(payloads(store.read()) == [latest, *entries[:499]], "501st entry evicts only the oldest entry")
  store.apply("add", entries[25])
  check(payloads(store.read())[0] == entries[25] and len(store.read()) == 500,
        "duplicate add moves an entry without consuming another slot")
  store.consistent()


def test_history_read_boundary(root):
  store = Store(root, "history-boundary")
  entries = [{"type": "text", "text": "intact legacy entry"}]
  store.seed(entries)
  encoded = compact(entries)
  store.history_path.write_bytes(encoded + b" " * (8 * MIB - len(encoded)))
  envelope = store.apply("load", limited=True)
  check(envelope["blocked"] is False and payloads(envelope["history"]) == entries,
        "an exactly 8 MiB history remains readable")
  store.history_path.write_bytes(encoded + b" " * (8 * MIB + 1 - len(encoded)))
  before = store.history_path.stat()
  check(store.apply("load", limited=True)["blocked"] is True,
        "one byte beyond the history limit blocks loading")
  after = store.history_path.stat()
  check((after.st_ino, after.st_size, after.st_mtime_ns) == (before.st_ino, before.st_size, before.st_mtime_ns),
        "history one byte over the limit is preserved")
  store.apply("clear")
  store.consistent()


def test_image_limits(root):
  store = Store(root, "image-limits")
  oversized = b"x" * (16 * MIB + 1)
  store.image(oversized, accepted=False)
  check(store.read() == [], "oversize image leaves no reference")
  check(not store.images.exists() or not list(store.images.iterdir()), "oversize image leaves no capture file")
  entries = []
  for index in range(9):
    data = bytes([65 + index]) * (16 * MIB)
    entry = store.image(data)
    entries.append(entry)
    check(Path(entry["path"]).read_bytes() == data, "exactly 16 MiB image is accepted without truncation")
  history = store.consistent()
  check(len(history) == 8, "128 MiB image budget retains eight 16 MiB captures")
  check(not Path(entries[0]["path"]).exists(), "image budget eviction removes the oldest capture")
  check(payloads(history)[0] == entries[-1], "image budget preserves the newest capture")
  store.apply("clear")
  store.consistent()


def test_gc_lifecycle(root):
  store = Store(root, "gc")
  first = store.image(b"first image")
  second = store.image(b"second image", mime="image/jpeg")
  check(second["path"].endswith(".jpg"), "JPEG captures use the jpg extension")
  store.apply("remove", first)
  check(not Path(first["path"]).exists() and Path(second["path"]).exists(),
        "delete reclaims only the removed capture")
  check(payloads(store.read()) == [second], "delete identifies the requested image")
  orphan = store.images / ("a" * 64 + ".png")
  orphan.write_bytes(b"unreferenced capture from an earlier process")
  unrelated = store.images / "personal-notes.txt"
  unrelated.write_bytes(b"leave non-capture files alone")
  store.apply("load")
  check(not orphan.exists(), "startup load reclaims an unreferenced hash-named capture")
  check(unrelated.read_bytes() == b"leave non-capture files alone", "GC preserves unrelated files")
  unrelated.unlink()
  text_entries = [{"type": "text", "text": f"entry-{index}"} for index in range(499)]
  store.seed([*text_entries, second])
  store.apply("add", {"type": "text", "text": "newest"})
  check(not Path(second["path"]).exists(), "entry-count eviction reclaims the evicted image")
  store.consistent()
  store.image(b"clear me")
  check(store.apply("clear") == {"history": [], "blocked": False}, "clear returns an unblocked empty history")
  store.consistent()


def test_blocked_history(root):
  store = Store(root, "blocked")
  image = store.image(b"retained while blocked")
  with store.history_path.open("wb") as history:
    history.write(b"[")
    history.seek(1024 * MIB - 1)
    history.write(b"]")
  before = store.history_path.stat()
  for action in ("load", "add", "remove"):
    envelope = store.apply(action, {"type": "text", "text": "new"}, limited=True)
    check(envelope["blocked"] is True, f"oversized history blocks {action}")
    after = store.history_path.stat()
    check((after.st_ino, after.st_size, after.st_mtime_ns) == (before.st_ino, before.st_size, before.st_mtime_ns),
          f"blocked {action} preserves the original history file")
  store.add({"type": "text", "text": "do not record"}, accepted=False)
  store.image(b"do not record image", accepted=False)
  check(Path(image["path"]).exists(), "blocked history preserves existing captures pending explicit clear")
  after = store.history_path.stat()
  check((after.st_ino, after.st_size, after.st_mtime_ns) == (before.st_ino, before.st_size, before.st_mtime_ns),
        "capture entry points preserve blocked history")
  check(store.apply("clear", limited=True) == {"history": [], "blocked": False}, "explicit clear recovers oversized history")
  check(not Path(image["path"]).exists(), "explicit clear removes the formerly retained capture")
  store.add({"type": "text", "text": "recording resumed"})
  store.consistent()


def test_path_confinement(root):
  store = Store(root, "paths")
  good = store.image(b"owned capture")
  outside = store.root / ("b" * 64 + ".png")
  outside.write_bytes(b"external image must survive")
  symlink = store.images / ("c" * 64 + ".png")
  symlink.symlink_to(outside)
  nested = store.images / "nested"
  nested.mkdir()
  nested_file = nested / ("d" * 64 + ".png")
  nested_file.write_bytes(b"non-flat file must survive")
  malicious = [
    {"type": "image", "path": str(outside), "mime": "image/png"},
    {"type": "image", "path": str(store.images / ".." / ".." / ".." / outside.name), "mime": "image/png"},
    {"type": "image", "path": str(symlink), "mime": "image/png"},
    {"type": "image", "path": str(nested_file), "mime": "image/png"},
  ]
  store.seed([good, *malicious])
  envelope = store.apply("load")
  check(good in payloads(envelope["history"]), "load retains the valid captured image")
  check(all(entry.get("path") != str(symlink) for entry in envelope["history"]),
        "load excludes symlink image references")
  for entry in malicious:
    store.apply("remove", entry)
  store.apply("clear")
  check(outside.read_bytes() == b"external image must survive", "delete and clear never touch external image targets")
  check(nested_file.read_bytes() == b"non-flat file must survive", "GC does not recurse into unrelated directories")


def test_replaced_directory(root):
  store = Store(root, "directory-replaced")
  original = store.image(b"existing capture")
  moved = store.state / "detached-images"
  store.images.rename(moved)
  external = store.root / "external-directory"
  external.mkdir()
  victim = external / Path(original["path"]).name
  victim.write_bytes(b"external target must survive")
  store.images.symlink_to(external, target_is_directory=True)
  # A replaced capture directory may block the store or be repaired safely;
  # neither path is allowed to resolve the replacement to somebody else's data.
  for action in ("load", "clear"):
    result = store.run(["apply"], compact({"action": action}))
    check(result.stdout or result.returncode != 0, "unsafe capture directory does not silently succeed")
  store.run(["image", "image/png", "Saturday 10:01"], b"new capture during replacement")
  check(victim.read_bytes() == b"external target must survive", "capture-directory replacement never overwrites or deletes its target")
  check(list(external.iterdir()) == [victim], "capture-directory replacement never writes new files into its target")
  check((moved / victim.name).read_bytes() == b"existing capture", "detached capture directory remains untouched")


def test_concurrency(root):
  store = Store(root, "concurrency")
  store.apply("load")

  def capture(index):
    if index % 2:
      return store.image(f"concurrent-image-{index}".encode())
    return store.add({"type": "text", "text": f"concurrent-text-{index}"})

  with concurrent.futures.ThreadPoolExecutor(max_workers=8) as workers:
    recorded = list(workers.map(capture, range(32)))
  history = store.consistent()
  check(len(history) == 32 and all(entry in payloads(history) for entry in recorded),
        "concurrent captures and text adds do not lose committed entries")

  def mixed(index):
    if index % 5 == 0:
      return store.apply("clear")
    return capture(index + 100)

  with concurrent.futures.ThreadPoolExecutor(max_workers=8) as workers:
    list(workers.map(mixed, range(40)))
  store.consistent()
  store.apply("clear")
  check(store.consistent() == [], "clear after concurrent writes removes every capture")


def test_fallback_and_permissions(root):
  store = Store(root, "fallback", use_xdg=False)
  store.add({"type": "text", "text": "fallback location"})
  check(store.history_path.is_file(), "unset XDG_STATE_HOME uses the private home state directory")
  store.image(b"permission fixture")
  check(stat.S_IMODE(store.state.stat().st_mode) == 0o700, "clipboard state directory is private")
  check(stat.S_IMODE(store.images.stat().st_mode) == 0o700, "clipboard image directory is private")
  check(stat.S_IMODE(store.history_path.stat().st_mode) == 0o600, "clipboard history is private")
  store.consistent()


def test_stable_selection(root):
  store = Store(root, "selection")
  selected = {"type": "text", "text": "Complete text\nwith trailing newlines\n\n"}
  store.add(selected)
  identifier = store.read()[0]["id"]
  check(len(identifier) == 64 and all(char in "0123456789abcdef" for char in identifier),
        "persisted entry has a stable hexadecimal identity")
  store.add({"type": "text", "text": "A newer copy shifts the selected index"})
  response = store.run(["get", identifier])
  check(response.returncode == 0 and json.loads(response.stdout)["text"] == selected["text"],
        "identity selection returns the selected text after indexes shift")
  store.add(selected)
  check(store.read()[0]["id"] == identifier, "recopying an entry preserves its identity")
  check(store.apply("load")["history"][0]["id"] == identifier, "reloading preserves the selected identity")
  other = Store(root, "selection-other-owner")
  other.add(selected)
  check(other.read()[0]["id"] != identifier, "the same clipboard text has different identities in different stores")
  key = store.state / "clipboard-identity-key"
  check(key.stat().st_size == 32 and stat.S_IMODE(key.stat().st_mode) == 0o600,
        "the identity key is bounded and private")
  copy = store.root / "bin/wl-copy"
  copy.write_text('#!/bin/bash\ncat >"$COPIED_BYTES"\n')
  copy.chmod(0o755)
  copied = store.root / "copied"
  store.env["COPIED_BYTES"] = str(copied)
  response = store.run(["copy", identifier])
  check(response.returncode == 0 and copied.read_bytes() == selected["text"].encode(),
        "copy preserves every accepted byte including trailing newlines")
  store.apply("remove", selected)
  copied.unlink()
  response = store.run(["copy", identifier])
  check(response.returncode != 0 and not copied.exists(),
        "an evicted selection does not invoke wl-copy or replace the live clipboard")
  key.write_bytes(b"invalid")
  check(store.apply("load")["blocked"], "a damaged identity key blocks unsafe selection")
  check(store.apply("clear")["blocked"] is False and key.stat().st_size == 32,
        "explicit clear safely restores a damaged identity key")


def test_capture_limits_and_clear(root):
  store = Store(root, "capture")
  runtime = store.root / "runtime"
  runtime.mkdir()
  store.env["XDG_RUNTIME_DIR"] = str(runtime)
  paste = store.root / "bin/wl-paste"
  paste.write_text('#!/bin/bash\nprintf "text/plain\\n"\n')
  paste.chmod(0o755)
  command = ["bash", str(ROOT / "shell/plugins/clipboard/capture.sh"), "text"]
  accepted = "Exact text\n\n"
  response = subprocess.run(command, input=accepted.encode(), capture_output=True, env=store.env, timeout=5)
  check(response.returncode == 0 and json.loads(response.stdout)["text"] == accepted,
        "real capture preserves complete text")
  before = store.history_path.read_bytes()
  for oversized in (b"x" * (MIB + 1), b"y" * (8 * MIB)):
    response = subprocess.run(command, input=oversized, capture_output=True, env=store.env, timeout=5)
    check(not response.stdout and store.history_path.read_bytes() == before,
          "real capture rejects oversized decoded and raw inputs without a partial entry")
  check(not list(runtime.iterdir()), "capture removes private staging files after oversized inputs")

  # Pause a real capture during sensitivity enumeration, after its generation
  # has been recorded. Clear invalidates the older event before release.
  started, release = store.root / "started", store.root / "release"
  store.env.update(CAPTURE_STARTED=str(started), CAPTURE_RELEASE=str(release))
  paste.write_text('#!/bin/bash\ntouch "$CAPTURE_STARTED"\nwhile [[ ! -e $CAPTURE_RELEASE ]]; do sleep 0.01; done\nprintf "text/plain\\n"\n')
  process = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE, env=store.env)
  try:
    deadline = time.monotonic() + 1.5
    while not started.exists() and time.monotonic() < deadline:
      time.sleep(0.01)
    check(started.exists(), "capture records its generation before reading the payload")
    store.apply("clear")
    release.touch()
    output, _ = process.communicate(b"pre-clear content", timeout=5)
    check(not output and store.read() == [], "a delayed pre-clear capture cannot repopulate history")
  finally:
    if process.poll() is None:
      process.kill()
      process.communicate()
  response = subprocess.run(command, input=b"new post-clear copy", capture_output=True, env=store.env, timeout=5)
  check(response.stdout and store.read()[0]["text"] == "new post-clear copy",
        "new post-clear copies are recorded normally")


def test_cli_failure_boundaries(root):
  store = Store(root, "cli")
  store.add({"type": "text", "text": "unchanged"})
  copied, typed = store.root / "copied", store.root / "typed"
  store.env.update(COPIED_BYTES=str(copied), TYPED_KEYS=str(typed))
  copy = store.root / "bin/wl-copy"
  copy.write_text('#!/bin/bash\ncat >"$COPIED_BYTES"\n')
  copy.chmod(0o755)
  wtype = store.root / "bin/wtype"
  wtype.write_text('#!/bin/bash\ntouch "$TYPED_KEYS"\n')
  wtype.chmod(0o755)
  image = store.image(b"complete image bytes")
  identifier = store.read()[0]["id"]
  response = store.run(["copy", identifier, "image"])
  check(response.returncode == 0 and copied.read_bytes() == b"complete image bytes",
        "image identity selection copies the complete captured bytes")
  copy.write_text('#!/bin/bash\nexit 1\n')
  for arguments in (["--history-id", identifier], ["image/png", image["path"]]):
    response = subprocess.run([str(ROOT / "bin/omarchy-clipboard-paste-file"), *arguments],
                              capture_output=True, env=store.env, timeout=5)
    check(response.returncode != 0 and not typed.exists(), "failed image copying never synthesizes a paste keystroke")
  store.apply("remove", image)
  copied.unlink()
  response = store.run(["copy", identifier, "image"])
  check(response.returncode != 0 and not copied.exists(), "a collected image cannot paste the previous clipboard")
  response = subprocess.run([str(ROOT / "bin/omarchy-clipboard-paste-text"), "--shift-insert", "new text"],
                            capture_output=True, env=store.env, timeout=5)
  check(response.returncode != 0 and not typed.exists(), "failed direct text copying never synthesizes a paste keystroke")
  with store.history_path.open("wb") as stream:
    stream.truncate(1024 * MIB)
  for script in ("omarchy-clipboard-paste-text", "omarchy-clipboard-open"):
    response = subprocess.run([str(ROOT / "bin" / script), "--history-index", "0"],
                              capture_output=True, env=store.env, timeout=5, preexec_fn=memory_limit)
    check(response.returncode != 0 and not typed.exists(), "legacy index lookup respects bounded history reads")


TESTS = [
  (test_text_limits, "clipboard storage enforces UTF-8 text limits without truncating entries"),
  (test_history_limits, "clipboard storage bounds serialized bytes and entry count"),
  (test_history_read_boundary, "clipboard storage enforces the exact history read limit"),
  (test_image_limits, "clipboard storage bounds individual and aggregate image bytes"),
  (test_gc_lifecycle, "clipboard storage reclaims images on startup, delete, eviction and clear"),
  (test_blocked_history, "clipboard storage bounds oversized-history reads and requires explicit clear"),
  (test_path_confinement, "clipboard storage excludes symlink references and confines image cleanup"),
  (test_replaced_directory, "clipboard storage rejects capture-directory symlink replacement"),
  (test_concurrency, "clipboard storage serializes capture, add and clear without orphaned images"),
  (test_fallback_and_permissions, "clipboard storage uses private files and the XDG state fallback"),
  (test_stable_selection, "clipboard selection uses stable identities and preserves complete paste bytes"),
  (test_capture_limits_and_clear, "clipboard capture bounds raw input and discards pre-clear in-flight copies"),
  (test_cli_failure_boundaries, "clipboard CLI readers remain bounded and paste only after successful copying"),
]


with tempfile.TemporaryDirectory(prefix="omarchy-clipboard-storage-") as temporary:
  for test, description in TESTS:
    try:
      test(Path(temporary))
    except Exception as error:
      print(f"not ok - {description}", file=sys.stderr)
      print(f"{type(error).__name__}: {error}", file=sys.stderr)
      sys.exit(1)
    print(f"ok - {description}", flush=True)
