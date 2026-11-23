#!/bin/bash

# Every collector reads the whole pi/omp history through scan_pi_sessions,
# each for its own providers, so what one scan parses is paid once per
# collector on every refresh. A file holding none of a collector's lines
# must cost it nothing beyond rg's search: its prompts, tool results and
# compactions are never parsed, and no file is read again for the model a
# summary ran on. A refresh reads only the files that changed since the last
# one. Counts, the same on every machine, rather than times.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command rg

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

WORK="$WORK" python3 - <<'PY'
import json
import os
import shutil
import sys
import tempfile
from datetime import datetime, timedelta, timezone
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.environ["OMARCHY_PATH"], "shell", "plugins", "agents"))
import collectors  # noqa: E402

work = Path(os.environ["WORK"])
home = work / "home"
home.mkdir()
os.environ["HOME"] = str(home)
for name in ("PI_CODING_AGENT_DIR", "PI_CODING_AGENT_SESSION_DIR"):
  os.environ.pop(name, None)


def check(description, condition, detail=""):
  if condition:
    print("ok - " + description)
    return
  print("not ok - " + description, file=sys.stderr)
  if detail:
    print(detail, file=sys.stderr)
  sys.exit(1)


stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
runtime = {"version": "18.12.6"}


def usage(tokens):
  return {"input": tokens, "output": 10, "cacheRead": 0, "cacheWrite": 0, "totalTokens": tokens + 10, "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0, "total": 0}}


def pi_session(provider, model, n, tokens):
  """A tool-loop session as pi 1.4.0 writes one, with a pasted image and a
  compaction, on one provider."""
  lines = [
    {"type": "session", "version": 3, "id": f"s{n}", "timestamp": stamp, "cwd": "/proj"},
    {"type": "model_change", "id": f"mc{n}", "parentId": None, "timestamp": stamp, "provider": provider, "modelId": model},
    {"type": "message", "id": f"u{n}", "timestamp": stamp, "message": {"role": "user", "content": [{"type": "text", "text": "read it"}, {"type": "image", "mimeType": "image/png", "data": "iVBORw0KGgo" * 2000}], "timestamp": 1}},
    {"type": "message", "id": f"a{n}", "timestamp": stamp, "message": {"role": "assistant", "content": [{"type": "toolCall", "id": f"c{n}", "name": "read", "arguments": {"path": "/x"}}],
                                                                     "api": "openai-completions", "provider": provider, "model": model, "usage": usage(tokens), "stopReason": "toolUse", "timestamp": 2}},
    {"type": "message", "id": f"r{n}", "timestamp": stamp, "message": {"role": "toolResult", "toolCallId": f"c{n}", "toolName": "read", "content": [{"type": "text", "text": "x" * 4000}], "isError": False, "timestamp": 3}},
    {"type": "message", "id": f"b{n}", "timestamp": stamp, "message": {"role": "assistant", "content": [{"type": "text", "text": "done"}],
                                                                     "api": "openai-completions", "provider": provider, "model": model, "usage": usage(tokens + 1), "stopReason": "stop", "timestamp": 4}},
    {"type": "compaction", "id": f"cp{n}", "parentId": f"b{n}", "timestamp": stamp, "summary": "s", "firstKeptEntryId": f"u{n}", "tokensBefore": 40000, "usage": usage(tokens + 2)},
  ]
  return lines


def write(path, lines):
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join(json.dumps(line) + "\n" for line in lines))


sessions = home / ".pi" / "agent" / "sessions" / "--proj--"
write(sessions / "mine.jsonl", pi_session("demo", "demo-model", 0, 1000))
for n in range(1, 41):
  write(sessions / f"other-{n}.jsonl", pi_session(f"other{n % 4}", "other-model", n, 50000))
# As omp 18.12.6 writes one: the switch names provider/model, no field
# `pattern` sees, and the only usage is a compaction on that model.
write(home / ".omp" / "agent" / "sessions" / "-" / "omp-compacted.jsonl", [
  {"type": "session", "version": 3, "id": "o1", "timestamp": stamp, "cwd": "/proj"},
  {"type": "model_change", "id": "omc", "parentId": None, "timestamp": stamp, "runtime": runtime, "model": "demo/omp-model", "resolvedModelIsFallback": False},
  {"type": "message", "id": "ou", "timestamp": stamp, "runtime": runtime, "message": {"role": "user", "content": [{"type": "text", "text": "compact"}], "attribution": "user", "timestamp": 1}},
  {"type": "compaction", "id": "ocp", "timestamp": stamp, "runtime": runtime, "summary": "s", "firstKeptEntryId": "ou", "tokensBefore": 900, "usage": usage(700)},
])

parsed = {"files": set(), "lines": 0}
pi_rows = collectors._pi_rows


def counting_rows(path, lines, accept):
  parsed["files"].add(Path(path).name)
  parsed["lines"] += len(lines)
  return pi_rows(path, lines, accept)


collectors._pi_rows = counting_rows


def scan(provider):
  for key in parsed:
    parsed[key] = set() if key != "lines" else 0
  pattern = r'"provider"\s*:\s*"' + provider + '"'
  return collectors.scan_pi_sessions(pattern, lambda name, model, entry: name == provider)


rows, complete = scan("nobody")
check("a scan for a provider with no sessions parses no line",
      complete and not rows and not parsed["files"] and parsed["lines"] == 0, json.dumps({**parsed, "files": sorted(parsed["files"])}))

rows, complete = scan("demo")
check("a scan parses only the files holding its own lines, the omp switch's included",
      complete and parsed["files"] == {"mine.jsonl", "omp-compacted.jsonl"}, json.dumps(sorted(parsed["files"])))
# The omp prompt no reply answered counts on the switch's model.
check("its own replies, prompts and compactions still count",
      sorted((row.model, row.input_tokens, row.prompts) for row in rows)
      == [("demo-model", 1000, 1), ("demo-model", 1001, 0), ("demo-model", 1002, 0), ("omp-model", 0, 1), ("omp-model", 700, 0)],
      json.dumps([row._asdict() for row in rows]))

rows, complete = scan("other1")
check("another provider's scan parses only its own ten files",
      complete and len(parsed["files"]) == 10 and all(name.startswith("other-") for name in parsed["files"]) and len(rows) == 30,
      json.dumps({"files": sorted(parsed["files"]), "rows": len(rows)}))
# A prompt goes with the reply that answered it, even one rg's pattern keeps
# out of the parse: another provider's reply after a handoff answered it, and
# the next reply here answers none.
turns = work / "turns"
write(turns / "handoff.jsonl", [
  {"type": "model_change", "id": "hm", "timestamp": stamp, "provider": "demo", "modelId": "demo-model"},
  {"type": "message", "id": "hu", "timestamp": stamp, "message": {"role": "user", "content": "ask the other one"}},
  {"type": "message", "id": "ho", "timestamp": stamp, "message": {"role": "assistant", "provider": "elsewhere", "model": "e", "usage": usage(300)}},
  {"type": "message", "id": "hd", "timestamp": stamp, "message": {"role": "assistant", "provider": "demo", "model": "demo-model", "usage": usage(30)}},
])
rows, _ = collectors.scan_pi_sessions(r'"provider"\s*:\s*"demo"', lambda name, model, entry: name == "demo", roots=[turns])
check("a prompt another provider answered is not booked on the next reply here",
      [(row.input_tokens, row.prompts) for row in rows] == [(30, 0)], json.dumps([row._asdict() for row in rows]))

# A prompt counts on the day it was typed, not the day its reply came, and
# one whose time can't be trusted counts nowhere.
yesterday = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat(timespec="milliseconds").replace("+00:00", "Z")
dated = work / "dated"
write(dated / "midnight.jsonl", [
  {"type": "model_change", "id": "dm", "timestamp": stamp, "provider": "demo", "modelId": "demo-model"},
  {"type": "message", "id": "du", "timestamp": yesterday, "message": {"role": "user", "content": "late"}},
  {"type": "message", "id": "da", "timestamp": stamp, "message": {"role": "assistant", "provider": "demo", "model": "demo-model", "usage": usage(40)}},
  {"type": "message", "id": "dx", "timestamp": 0, "message": {"role": "user", "content": "untimed"}},
  {"type": "message", "id": "db", "timestamp": stamp, "message": {"role": "assistant", "provider": "demo", "model": "demo-model", "usage": usage(50)}},
])
rows, _ = collectors.scan_pi_sessions(r'"provider"\s*:\s*"demo"', lambda name, model, entry: name == "demo", roots=[dated])
today = collectors.local_day(stamp)
check("a prompt counts on its own day, and an untimed one not at all",
      sorted((row.day, row.input_tokens, row.prompts) for row in rows)
      == sorted([(collectors.local_day(yesterday), 0, 1), (today, 40, 0), (today, 50, 0)]),
      json.dumps([row._asdict() for row in rows]))


def turn(n, provider, model):
  return [{"type": "message", "id": f"fu{n}", "timestamp": stamp, "message": {"role": "user", "content": "go", "timestamp": 1}},
          {"type": "message", "id": f"fa{n}", "timestamp": stamp, "message": {"role": "assistant", "provider": provider, "model": model, "usage": usage(100), "timestamp": 2}}]


# A fork copies its parent's whole history, as pi --fork does. A collector
# that owns one fork's own reply reads the other files of the fork tree
# only when they hold a copy of a prompt it booked: here none does.
forks = work / "forks"
history = [{"type": "model_change", "id": "fm", "timestamp": stamp, "provider": "busy", "modelId": "busy-model"}]
for n in range(20):
  history += turn(n, "busy", "busy-model")
write(forks / "parent.jsonl", [{"type": "session", "version": 3, "id": "fp", "timestamp": stamp, "cwd": "/proj"}, *history])
for n in range(6):
  extra = []
  if n == 5:
    extra = [{"type": "model_change", "id": "fk", "timestamp": stamp, "provider": "late", "modelId": "late-model"}, *turn("k", "late", "late-model")]
  write(forks / f"fork-{n}.jsonl", [{"type": "session", "version": 3, "id": f"ff{n}", "timestamp": stamp, "cwd": "/proj", "parentSession": str(forks / "parent.jsonl")}, *history, *extra])
for key in parsed:
  parsed[key] = set() if key != "lines" else 0
rows, complete = collectors.scan_pi_sessions(r'"provider"\s*:\s*"late"', lambda name, model, entry: name == "late", roots=[forks])
check("a fork's own reply parses no other file of its fork tree that holds none of its prompts",
      complete and parsed["files"] == {"fork-5.jsonl"} and [(row.input_tokens, row.prompts) for row in rows] == [(100, 1)],
      json.dumps({"files": sorted(parsed["files"]), "rows": [row._asdict() for row in rows]}))

# pi deletes a session from /resume and leaves its forks naming it. The
# fork's copies then count under the fork, and the scan is complete.
orphan = work / "orphan"
write(orphan / "fork.jsonl", [{"type": "session", "version": 3, "id": "of", "timestamp": stamp, "cwd": "/proj", "parentSession": str(orphan / "deleted.jsonl")},
                              *history, {"type": "model_change", "id": "ok", "timestamp": stamp, "provider": "late", "modelId": "late-model"}, *turn("k", "late", "late-model")])
for provider, want in (("busy", (2000, 20)), ("late", (100, 1))):
  rows, complete = collectors.scan_pi_sessions(r'"provider"\s*:\s*"' + provider + '"', lambda name, model, entry: name == provider, roots=[orphan])
  check(f"a fork whose parent was deleted is read in full for {provider}",
        complete and (sum(row.input_tokens for row in rows), sum(row.prompts for row in rows)) == want,
        json.dumps({"complete": complete, "rows": [row._asdict() for row in rows]}))

# Two forks of that deleted session copied its last prompt, still
# unanswered, and answered it on different providers: the gone parent still
# ties them, so the prompt counts once, under one collector.
siblings = work / "siblings"
copied = [{"type": "model_change", "id": "sm", "timestamp": stamp, "provider": "busy", "modelId": "busy-model"},
          {"type": "message", "id": "sq", "timestamp": stamp, "message": {"role": "user", "content": "go", "timestamp": 1}}]
for name, provider in (("a", "alpha"), ("b", "beta")):
  write(siblings / f"fork-{name}.jsonl", [{"type": "session", "version": 3, "id": f"s{name}", "timestamp": stamp, "cwd": "/proj", "parentSession": str(siblings / "deleted.jsonl")},
                                         *copied, {"type": "model_change", "id": f"sc{name}", "timestamp": stamp, "provider": provider, "modelId": f"{provider}-model"},
                                         {"type": "message", "id": f"sr{name}", "timestamp": stamp, "message": {"role": "assistant", "provider": provider, "model": f"{provider}-model", "usage": usage(100), "timestamp": 2}}])
prompts, completes = 0, []
for provider in ("alpha", "beta"):
  rows, complete = collectors.scan_pi_sessions(r'"provider"\s*:\s*"' + provider + '"', lambda name, model, entry, provider=provider: name == provider, roots=[siblings])
  prompts += sum(row.prompts for row in rows)
  completes.append(complete)
check("a prompt two forks of a deleted session copied and answered on different providers counts once",
      all(completes) and prompts == 1, json.dumps({"prompts": prompts, "complete": completes}))

# A refresh reads only the sessions that changed since the last one, and only
# what a grown one gained, and still answers as a scan with nothing indexed.
# An rg on PATH logs what each run was asked to read, and how many bytes a run
# reading stdin was fed; a run given the path RG_FAIL names then fails on it
# the way rg reports a file it couldn't read, having read the others.
log = work / "rg.log"
spy = work / "spy"
spy.mkdir()
(spy / "rg").write_text(f"""#!/bin/bash
printf '%s\\x1f' "$@" >> {log}
if [[ ${{@: -1}} == - ]]; then
  tmp=$(mktemp -p {work}); cat > "$tmp"
  printf 'stdin=%s' "$(wc -c < "$tmp")" >> {log}; printf '\\n' >> {log}
  {shutil.which("rg")} "$@" < "$tmp"; code=$?; rm -f "$tmp"; exit $code
fi
printf '\\n' >> {log}
if [[ -n ${{RG_FAIL:-}} && " $* " == *" $RG_FAIL "* ]]; then
  {shutil.which("rg")} "$@"
  echo "rg: $RG_FAIL: Input/output error (os error 5)" >&2
  exit 2
fi
exec {shutil.which("rg")} "$@"
""")
(spy / "rg").chmod(0o755)
os.environ["PATH"] = f"{spy}:{os.environ['PATH']}"
os.environ["XDG_CACHE_HOME"] = str(work / "cache")


def reads():
  """The session files rg read since the last call, by name, and the sizes of
  what it was fed on stdin."""
  text = log.read_text() if log.exists() else ""
  log.write_text("")
  names, fed = set(), []
  for run in ([part for part in line.split("\x1f") if part] for line in text.splitlines() if line):
    if run[-1].startswith("stdin="):
      fed.append(int(run[-1].removeprefix("stdin=")))
    elif "--files" not in run:
      names.update(Path(arg).name for arg in run[run.index("--") + 1:])
  return names, fed


def index_scan(provider, root):
  rows, complete = collectors.scan_pi_sessions(r'"provider"\s*:\s*"' + provider + '"', lambda name, model, entry: name == provider, [root])
  return sorted(rows), complete


def demo_index(root):
  return collectors.pi_session_index_path(r'"provider"\s*:\s*"demo"', collectors.canonical_roots([root]))


def written(path):
  # The index is replaced whole, so a write gives it another inode.
  info = path.stat()
  return info.st_ino, info.st_mtime_ns


def same(provider, root):
  """Whether a scan answers as a scan with nothing indexed does, and what it
  read."""
  reads()
  got = index_scan(provider, root)
  read = reads()
  saved = os.environ["XDG_CACHE_HOME"]
  os.environ["XDG_CACHE_HOME"] = tempfile.mkdtemp(dir=work)
  try:
    want = index_scan(provider, root)
  finally:
    os.environ["XDG_CACHE_HOME"] = saved
  reads()
  return got == want and got[1], *read


def exchange(tag, provider, tokens=100):
  return [{"type": "message", "id": f"iu{tag}", "timestamp": stamp, "message": {"role": "user", "content": "go", "timestamp": 1}},
          {"type": "message", "id": f"ia{tag}", "timestamp": stamp, "message": {"role": "assistant", "provider": provider, "model": f"{provider}-model", "responseId": f"r{tag}", "usage": usage(tokens), "timestamp": 2}}]


def session(name, provider, *lines, parent=None):
  head = {"type": "session", "version": 3, "id": f"is{name}", "timestamp": stamp, "cwd": "/proj", **({"parentSession": str(parent)} if parent else {})}
  return [head, {"type": "model_change", "id": f"im{name}", "timestamp": stamp, "provider": provider, "modelId": f"{provider}-model"}, *lines]


def append(path, text):
  with path.open("a") as handle:
    handle.write(text)


indexed = work / "indexed"
write(indexed / "a.jsonl", session("a", "demo", *exchange("a1", "demo")))
write(indexed / "b.jsonl", session("b", "demo", *exchange("b1", "demo", 200)))
write(indexed / "c.jsonl", session("c", "demo", *exchange("c1", "demo", 300)))
write(indexed / "other.jsonl", session("o", "other", *exchange("o1", "other", 400)))
ok, names, _ = same("demo", indexed)
check("a first scan reads every file holding the collector's lines", ok and {"a.jsonl", "b.jsonl", "c.jsonl"} <= names, json.dumps(sorted(names)))

ok, names, fed = same("demo", indexed)
want = index_scan("demo", indexed)
for path in indexed.iterdir():
  path.chmod(0)
try:
  unreadable = index_scan("demo", indexed)
finally:
  for path in indexed.iterdir():
    path.chmod(0o644)
check("an unchanged history opens no session file, and answers the same",
      ok and not names and not fed and unreadable == want, json.dumps({"names": sorted(names), "fed": fed, "complete": unreadable[1]}))

grown = "".join(json.dumps(line) + "\n" for line in exchange("a2", "demo", 50))
append(indexed / "a.jsonl", grown)
ok, names, fed = same("demo", indexed)
check("a file that grew is read only for what it gained", ok and not names and fed == [len(grown)], json.dumps({"names": sorted(names), "fed": fed}))

# A last line rg reads before its newline is written counts as it stands, and
# is read again with what follows it once it is whole.
first, second = (json.dumps(line) for line in exchange("b2", "demo", 70))
append(indexed / "b.jsonl", first + "\n" + second)
unfinished, _, _ = same("demo", indexed)
append(indexed / "b.jsonl", "\n" + "".join(json.dumps(line) + "\n" for line in exchange("b3", "demo", 80)))
ok, names, fed = same("demo", indexed)
check("a line still being written counts as it stands and again once whole", unfinished and ok and not names and len(fed) == 1,
      json.dumps({"names": sorted(names), "fed": fed}))

# Anything that isn't an append is read from the start: a file rewritten in
# place at the same size (only its mtime says so), one rewritten larger, which
# only the bytes already read tell from an append, and one cut short.
size = (indexed / "c.jsonl").stat().st_size
for change, lines in (("rewritten at the same size", session("c", "demo", *exchange("c1", "demo", 399))),
                      ("rewritten larger", session("c", "demo", *exchange("c8", "demo", 888), *exchange("c7", "demo", 777))),
                      ("cut short", session("c", "demo"))):
  write(indexed / "c.jsonl", lines)
  info = (indexed / "c.jsonl").stat()
  os.utime(indexed / "c.jsonl", ns=(info.st_atime_ns, info.st_mtime_ns + 1_000_000_000))
  ok, names, _ = same("demo", indexed)
  check(f"a file {change} is read again from the start", ok and "c.jsonl" in names and (change != "rewritten at the same size" or info.st_size == size),
        json.dumps({"names": sorted(names), "size": [size, info.st_size]}))

(indexed / "b.jsonl").unlink()
ok, _, _ = same("demo", indexed)
check("a deleted file's rows are gone", ok)
(indexed / "moved").mkdir()
os.rename(indexed / "c.jsonl", indexed / "moved" / "c.jsonl")
ok, names, fed = same("demo", indexed)
check("a moved file counts under its new path without being read", ok and not names and not fed, json.dumps({"names": sorted(names), "fed": fed}))

# A fork tree's rows depend on every file in it, and only some of them change.
tree = work / "indexed-forks"
history = [line for n in range(5) for line in exchange(f"h{n}", "busy")]
asked = {"type": "message", "id": "iq", "timestamp": stamp, "message": {"role": "user", "content": "left", "timestamp": 1}}
write(tree / "parent.jsonl", session("p", "busy", *history, asked))
write(tree / "fork-a.jsonl", session("fa", "busy", *history, asked, {"type": "model_change", "id": "ifa", "timestamp": stamp, "provider": "late", "modelId": "late-model"},
                                     *exchange("fa", "late")[1:], parent=tree / "parent.jsonl"))
write(tree / "fork-b.jsonl", session("fb", "busy", *history, asked, parent=tree / "parent.jsonl"))
steps = (("built", lambda: None), ("unchanged", lambda: None),
         ("with a fork answering its parent's last prompt", lambda: append(tree / "fork-b.jsonl", "".join(json.dumps(line) + "\n" for line in exchange("fb", "busy")[1:]))),
         ("with the parent growing under its forks", lambda: append(tree / "parent.jsonl", "".join(json.dumps(line) + "\n" for line in exchange("p9", "late")))),
         ("with the parent deleted under its forks", lambda: (tree / "parent.jsonl").unlink()))
for step, change in steps:
  change()
  answers = [same(provider, tree)[0] for provider in ("busy", "late")]
  check(f"a fork tree {step} gives every provider a cold scan's rows", all(answers), json.dumps(answers))

# An index that isn't JSON, or holds an entry of the wrong shape (as another
# build of the same version could write), is read again, never trusted.
index_file = demo_index(indexed)
index_file.write_text("{not json")
ok, names, _ = same("demo", indexed)
check("an index that isn't JSON is a full scan", ok and {"a.jsonl", "c.jsonl"} <= names, json.dumps(sorted(names)))
data = json.loads(index_file.read_text())
next(entry for name, entry in data["files"].items() if name.endswith("/a.jsonl"))["lines"][0][0] = "first"
index_file.write_text(json.dumps(data))
ok, names, _ = same("demo", indexed)
check("an index entry of the wrong shape has its file alone read again", ok and names == {"a.jsonl"}, json.dumps(sorted(names)))

# A file this user can't read (another's, mode 600) is tried on every scan,
# which leaves the index as it was.
locked = indexed / "locked.jsonl"
write(locked, session("l", "demo", *exchange("l1", "demo")))
locked.chmod(0)
try:
  _, first = index_scan("demo", indexed)
  before = written(index_file)
  _, again = index_scan("demo", indexed)
finally:
  locked.unlink()
check("an unreadable file leaves the index unwritten on the next scan", not first and not again and written(index_file) == before)

# A file rg could not read in full still counts what was read, but the scan
# is incomplete, so it is never cached, and the next one reads that file
# again: that file alone, not the others rg read in the same run.
write(indexed / "d.jsonl", session("d", "demo", *exchange("d1", "demo", 500)))
write(indexed / "e.jsonl", session("e", "demo", *exchange("e1", "demo", 600)))
os.environ["RG_FAIL"] = os.path.realpath(indexed / "d.jsonl")
try:
  _, complete = index_scan("demo", indexed)
finally:
  del os.environ["RG_FAIL"]
ok, names, _ = same("demo", indexed)
check("a failed read makes an incomplete scan, and the next one reads that file alone", not complete and ok and names == {"d.jsonl"}, json.dumps(sorted(names)))

# A listing rg could not finish (a directory this user can't open) keeps the
# entries of the files it missed, but not of those that are gone.
partial = work / "indexed-partial"
write(partial / "kept.jsonl", session("k", "demo", *exchange("k1", "demo")))
write(partial / "gone.jsonl", session("g", "demo", *exchange("g1", "demo")))
index_scan("demo", partial)
(partial / "closed").mkdir()
(partial / "closed").chmod(0)
(partial / "gone.jsonl").unlink()
try:
  _, complete = index_scan("demo", partial)
finally:
  (partial / "closed").chmod(0o755)
entries = json.loads(demo_index(partial).read_text())["files"]
check("an unfinished listing drops the entries of files that are gone",
      not complete and not any(name.endswith("/gone.jsonl") for name in entries) and any(name.endswith("/kept.jsonl") for name in entries), json.dumps(sorted(entries)))

# The fork tree above, where `late` owns one fork's reply and no other file
# holds its prompt: those files' lines are neither parsed nor kept, and the
# next scan still reads no file to tell.
late = r'"provider"\s*:\s*"late"'
index_scan("late", forks)
entries = json.loads(collectors.pi_session_index_path(late, collectors.canonical_roots([forks])).read_text())["files"]
with_lines = sorted(Path(name).name for name, entry in entries.items() if entry["lines"] is not None)
ok, names, fed = same("late", forks)
check("a fork tree's files holding none of a collector's prompts keep no lines in its index",
      with_lines == ["fork-5.jsonl"] and ok and not names and not fed, json.dumps({"with_lines": with_lines, "names": sorted(names), "fed": fed}))

# Nowhere to keep rg's messages costs a failed run its batch, never the scan.
saved = tempfile.tempdir
tempfile.tempdir = str(work / "no-tmp")
try:
  ok, names, _ = same("demo", indexed)
except OSError as exc:
  ok, names = False, {repr(exc)}
finally:
  tempfile.tempdir = saved
check("a scan with no temp directory still answers", ok and not names, json.dumps(sorted(names)))

# A reply whose cost no float holds costs its row, read whole or appended,
# never the scan; its prompt still counts, unanswered, on its model.
def damaged(tag):
  prompt, reply = exchange(tag, "demo", 900)
  reply["message"]["usage"]["cost"]["total"] = 10 ** 400
  return [prompt, reply]


costly = work / "indexed-costly"
write(costly / "s.jsonl", session("s", "demo", *damaged("x1"), *exchange("x2", "demo", 200)))
try:
  first, _ = index_scan("demo", costly)
  append(costly / "s.jsonl", "".join(json.dumps(line) + "\n" for line in damaged("x3")))
  rows, complete = index_scan("demo", costly)
  got = sorted((row.input_tokens, row.prompts) for row in rows)
except OverflowError as exc:
  first, got, complete = [], repr(exc), False
check("a damaged cost costs only its row", complete and len(first) == 2 and got == [(0, 1), (0, 1), (200, 1)], json.dumps(got))
PY
