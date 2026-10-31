#!/bin/bash

# The Claude collector's local stats: Claude Code's own transcripts, read
# through a per-file index that only reads what was appended, its
# history.jsonl fallback, and its own filter over pi and opencode sessions
# (the anthropic provider). How the shared pi and opencode readers work, and
# the unused-machine record, are held centrally by the shared and partition
# tests, and the scan cache by the contract check. Claude's limits and plan
# have tests of their own.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox
require_command rg

python3 - <<'PY'
from agent_usage_fixtures import *

STAMP = today_stamp()


def projects():
  return home() / ".claude" / "projects" / "example"


def message(message_id, input=0, output=0, cache_write=0, cache_read=0, model="claude-test", timestamp=STAMP, event=None):
  line = {"timestamp": timestamp, "type": "assistant", "sessionId": "session-1",
          "message": {"id": message_id, "role": "assistant", "model": model,
                      "usage": {"input_tokens": input, "cache_creation_input_tokens": cache_write, "cache_read_input_tokens": cache_read, "output_tokens": output}}}
  if event:
    line["uuid"] = event
  return line


def transcript(*lines, name="session.jsonl", mode="w"):
  path = projects() / name
  path.parent.mkdir(parents=True, exist_ok=True)
  with path.open(mode) as handle:
    for line in lines:
      handle.write(json.dumps(line) + "\n")
  return path


def claude(*args):
  return collect("claude", *(args or ("--force",)))


def rescan():
  return collect("claude", "--cache-seconds", "0")


# ------------------------------------------------------------- transcripts

# A message repeated across events counts once, its token kinds apart, and a
# Claude Code home with usage but no sign-in asks for one.
sandbox()
session = transcript(
  message("message-1", 2, 231, cache_write=28857, event="event-1"),
  message("message-1", 2, 231, cache_write=28857, event="event-2"),
  message("message-2", 2, 390, cache_write=454, cache_read=28857, event="event-3"),
)
record = claude()
expect("Claude counts each API message once, its token kinds kept apart, and asks a signed-out home to sign in", {
  "today": record["todayTotalTokens"], "usage": record["modelUsage"]["claude-test"], "status": record["usageStatusText"],
}, {
  "today": 58793, "usage": {"cacheCreationInputTokens": 29311, "cacheReadInputTokens": 28857, "inputTokens": 4, "outputTokens": 621}, "status": "Waiting for auth",
}, record)

# Transcripts only ever grow, so a refresh reads what was appended since the
# last one and takes the rest from the index.
transcript(message("message-3", 1, 6, cache_read=200, event="event-4"), mode="a")
record = rescan()
expect("Claude picks up lines appended since the last scan", record["todayTotalTokens"], 59000, record)
index = next(iter(cache_root().glob("claude-index-*.json")), None)
check("Claude keeps one record per API message in the index",
      index and len(next(iter(json.loads(index.read_text())["files"].values()))["records"]) == 3, index and index.read_text())

# An unchanged file is not opened again: its records come from the index.
if os.geteuid() != 0:
  session.chmod(0)
  with contextlib.redirect_stderr(io.StringIO()) as err:
    record = rescan()
  session.chmod(0o644)
  # Opening the file would fail and be reported; the index answers first.
  expect("Claude serves an unchanged transcript from the index, never opening it",
         [record["todayTotalTokens"], "unreadable" in err.getvalue()], [59000, False], record)

# A file that shrank was rewritten, not appended to; it is read from the start.
session.write_text(session.read_text().splitlines(keepends=True)[0])
record = rescan()
expect("Claude rereads a transcript that shrank", record["todayTotalTokens"], 29090, record)

# --force reads every transcript again, even one rewritten to the same size
# and time, and rebuilds the index in place rather than removing it, since the
# other collectors reading Claude Code share it.
stat = session.stat()
session.write_text(session.read_text().replace('"output_tokens": 231', '"output_tokens": 232'))
os.utime(session, ns=(stat.st_atime_ns, stat.st_mtime_ns))
replayed = rescan()
index = next(iter(cache_root().glob("claude-index-*.json")))
real_unlink = Path.unlink
removed = []
Path.unlink = lambda path, *args, **kwargs: removed.append(path.name) if path.name.startswith("claude-index-") else real_unlink(path, *args, **kwargs)
try:
  forced = claude()
finally:
  Path.unlink = real_unlink
expect("Claude --force rereads a transcript the index would replay, rebuilding the index in place",
       [replayed["todayTotalTokens"], forced["todayTotalTokens"], removed, index.exists()], [29090, 29091, [], True], forced)

# Prompts are what a person typed, shaped as Claude Code 2.1 writes them: a
# tool loop is one prompt however many API requests it makes, and a tool's
# result, a background task reporting back, Claude Code's own meta lines, a
# compaction summary, a local command's output, an interruption marker and a
# subagent's prompt are none. A prompt typed while a turn runs is queued into
# it as an attachment, and counts; one another agent sent doesn't. A prompt
# copied into a forked transcript keeps its uuid and counts once.
def user(uuid, content, session="session-1", **extra):
  return {"type": "user", "uuid": uuid, "sessionId": session, "timestamp": STAMP, "isSidechain": False,
          "message": {"role": "user", "content": content}, **extra}


def queued(uuid, prompt, origin, **extra):
  return {"type": "attachment", "uuid": uuid, "sessionId": "session-1", "timestamp": STAMP, "isSidechain": False,
          "attachment": {"type": "queued_command", "commandMode": "prompt", "prompt": prompt, "origin": origin, **extra}}


def tool_reply(message_id, output, block):
  line = message(message_id, 1000, output)
  line["message"]["content"] = [{"type": block}]
  return line


sandbox()
loop = [
  user("typed-1", "runtool", promptSource="typed"),
  tool_reply("msg_1", 1, "thinking"), tool_reply("msg_1", 1, "text"), tool_reply("msg_1", 51, "tool_use"),
  user("result-1", [{"type": "tool_result", "tool_use_id": "toolu_1", "content": "ok"}], toolUseResult={"stdout": "ok"}),
  tool_reply("msg_2", 52, "text"),
]
transcript(
  *loop,
  user("notified-1", "<task-notification>\n<task-id>b1</task-id>\n</task-notification>", promptSource="system"),
  tool_reply("msg_3", 53, "text"),
  user("meta-1", "<system-reminder>context</system-reminder>", isMeta=True),
  user("summary-1", "This session is being continued from a previous conversation.", isCompactSummary=True, isVisibleInTranscriptOnly=True),
  user("command-1", "<command-name>/model</command-name>"),
  user("stdout-1", "<local-command-stdout>Set model</local-command-stdout>"),
  user("interrupted-1", [{"type": "text", "text": "[Request interrupted by user]"}]),
  user("image-1", [{"type": "image", "source": {}}, {"type": "text", "text": "what is this"}], promptSource="typed"),
  tool_reply("msg_4", 54, "text"),
  queued("queued-1", "also check the tests", {"kind": "human"}, humanTurn=True),
  queued("queued-2", "<teammate-message>done</teammate-message>", {"kind": "peer", "from": "a1"}, isMeta=True),
  {"type": "attachment", "uuid": "notified-2", "sessionId": "session-1", "timestamp": STAMP, "isSidechain": False,
   "attachment": {"type": "queued_command", "commandMode": "task-notification", "prompt": "<task-notification></task-notification>"}},
  name="parent.jsonl",
)
transcript({**user("side-1", "explore the repo"), "isSidechain": True}, name="parent/subagents/agent-a1.jsonl")
fork = [{**line, "sessionId": "session-2"} for line in loop]
transcript(*fork, user("typed-2", "forked", session="session-2", promptSource="typed"), tool_reply("msg_5", 55, "tool_use"), tool_reply("msg_6", 56, "text"), name="fork.jsonl")
record = claude()
expect("Claude counts the prompts a person typed, once each, not the API requests they made",
       [record["todayPrompts"], record["totalPrompts"], record["todayTotalTokens"]], [5, 5, 6321], record)

# A built-in that runs locally asks the model nothing, so it is no prompt:
# Claude Code 2.1.308 answers its `<command-name>` line with a
# `<local-command-stdout>` child, a user line (/compact, /model) or a
# `local_command` system line (/clear). A custom slash command expands into a
# prompt the model answers, and counts. An output read after its command, in
# a later scan, still takes the command back.
sandbox()


def command(uuid, name, parent=None):
  return user(uuid, f"<command-name>/{name}</command-name>\n            <command-message>{name}</command-message>\n            <command-args></command-args>", parentUuid=parent)


def stdout(uuid, parent, text=""):
  return user(uuid, f"<local-command-stdout>{text}</local-command-stdout>", parentUuid=parent)


transcript(
  user("typed-1", "hello", promptSource="typed"), tool_reply("msg_1", 51, "text"),
  command("compact-1", "compact", "typed-1"), stdout("compact-out", "compact-1", "Compacted (ctrl+o to see full summary)"),
  {**user("summary-1", "This session is being continued from a previous conversation.", isCompactSummary=True), "parentUuid": "compact-out"},
  command("clear-1", "clear"),
  {"type": "system", "subtype": "local_command", "uuid": "clear-out", "parentUuid": "clear-1", "isSidechain": False, "sessionId": "session-1",
   "timestamp": STAMP, "content": "<local-command-stdout></local-command-stdout>", "isMeta": False, "commandRun": {"command": "clear", "args": ""}},
  user("review-1", "<command-message>review is running…</command-message>\n<command-name>/review</command-name>"),
  user("review-meta", "Review the current diff.", isMeta=True, parentUuid="review-1"), tool_reply("msg_2", 52, "text"),
  command("model-1", "model"),
)
record = rescan()
transcript(stdout("model-out", "model-1", "Set model to Opus 5"), mode="a")
grown = rescan()
expect("Claude counts no built-in local command as a prompt, a custom command still",
       [record["todayPrompts"], grown["todayPrompts"], grown["todayTotalTokens"]], [3, 2, 2103], grown)

# A transcript replaced by a larger one, rewritten in place with more than it
# had, or rewritten at its end or in its middle with both ends matching, is a
# new file rather than an append, read from its start.
sandbox()


def replaced(*lines):
  transcript(*lines, name="session.jsonl.new")
  (projects() / "session.jsonl.new").replace(projects() / "session.jsonl")


transcript(message("old-1", 1000))
rescan()
replaced(message("new-1", 20), message("new-2", 30))
record = rescan()
expect("Claude reads a transcript replaced by a larger one from its start", record["todayTotalTokens"], 50, record)
transcript(message("other-1", 7), message("other-2", 8), message("other-3", 9))
record = rescan()
expect("Claude reads a transcript rewritten in place from its start", record["todayTotalTokens"], 24, record)

transcript(*(message(f"long-{i}", 100) for i in range(1, 61)))
rescan()
transcript(*(message(f"long-{i}", 100) for i in range(1, 60)), message("long-60", 5000), message("long-61", 1))
record = rescan()
expect("Claude rereads a transcript whose end was rewritten in place", record["todayTotalTokens"], 10901, record)

transcript(*(message(f"mid-{i}", 100) for i in range(1, 201)))
rescan()
replaced(*(message(f"mid-{i}", 900 if i == 100 else 100) for i in range(1, 201)), message("mid-201", 1))
record = rescan()
expect("Claude rereads a larger replacement whose ends match", record["todayTotalTokens"], 20801, record)

# The index holds local days, so a new timezone reads every transcript again
# rather than keep the days another one gave them.
zone_stamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT01:00:00Z")
transcript(message("zone-1", 5, timestamp=zone_stamp))
saved_tz = os.environ.get("TZ")
try:
  os.environ["TZ"] = "UTC"
  time.tzset()
  rescan()
  os.environ["TZ"] = "America/Los_Angeles"
  time.tzset()
  record = rescan()
  expected_day = datetime.fromisoformat(zone_stamp.replace("Z", "+00:00")).astimezone().date().isoformat()
finally:
  if saved_tz is None:
    os.environ.pop("TZ", None)
  else:
    os.environ["TZ"] = saved_tz
  time.tzset()
expect("Claude recomputes indexed days after a timezone change", record["activeDates"], [expected_day], record)

# Every collector reading Claude Code runs at once, and the index is built
# once: one reads the transcripts while the others wait for it, then take
# what it wrote. A transcript grown since is the only one read again, and an
# index current for every transcript is read as it is.
sandbox()
for n in range(3):
  transcript(message(f"busy-{n}", 100 + n, 1), name=f"busy-{n}.jsonl")
import collectors
reads = home() / "reads.log"
totals = home() / "totals.log"
start = home() / "start"
real_read = collectors.read_claude_code_transcript


def logged_read(path, entry):
  result = real_read(path, entry)
  if result is not entry:
    with reads.open("a") as handle:
      handle.write(f"{path.name}\n")
    time.sleep(0.1)
  return result


def scan_at_once(count=4):
  for path in (reads, totals, start):
    path.unlink(missing_ok=True)
  children = []
  for _ in range(count):
    pid = os.fork()
    if pid == 0:
      try:
        collectors.read_claude_code_transcript = logged_read
        while not start.exists():
          time.sleep(0.005)
        rows = collectors.scan_claude_code("claude", projects().parent, base_url="")
        with totals.open("a") as handle:
          handle.write(f"{sum(row.input_tokens for row in rows)}\n")
      finally:
        os._exit(0)
    children.append(pid)
  start.touch()
  for pid in children:
    os.waitpid(pid, 0)
  lines = lambda path: sorted(path.read_text().split()) if path.exists() else []
  return lines(reads), lines(totals)


cold = scan_at_once()
transcript(message("busy-3", 1000, 1), name="busy-0.jsonl", mode="a")
grown = scan_at_once()
warm = scan_at_once()
expect("Claude Code's index is built once while every collector reads it at once",
       [cold, grown, warm],
       [(["busy-0.jsonl", "busy-1.jsonl", "busy-2.jsonl"], ["303"] * 4), (["busy-0.jsonl"], ["1303"] * 4), ([], ["1303"] * 4)])

# A streamed response is several lines under one message id: the first line's
# output is a placeholder, so a message counts from its highest output. One
# that fell back to another model mid-stream keeps its final line whole rather
# than a maximum per field.
sandbox()
transcript(
  message("message-1", 8, 1, cache_write=100, cache_read=2000, event="event-1"),
  message("message-1", 8, 1, cache_write=100, cache_read=2000, event="event-2"),
  message("message-1", 8, 260, cache_write=100, cache_read=2000, event="event-3"),
  message("message-2", 10, 1, cache_write=300, cache_read=4000, event="event-4"),
  message("message-2", 10, 40, cache_read=3500, model="claude-fallback", event="event-5"),
)
record = claude()
expect("Claude counts a streamed message from its final usage line, whole after a fallback", {
  "test": record["modelUsage"]["claude-test"], "fallback": record["modelUsage"]["claude-fallback"], "today": record["todayTotalTokens"],
}, {
  "test": {"cacheCreationInputTokens": 100, "cacheReadInputTokens": 2000, "inputTokens": 8, "outputTokens": 260},
  "fallback": {"cacheCreationInputTokens": 0, "cacheReadInputTokens": 3500, "inputTokens": 10, "outputTokens": 40},
  "today": 5918,
}, record)

# A stream still being written when the index was taken finishes in lines
# appended later, and the indexed message takes the higher count from them.
rescan()
transcript(message("message-2", 10, 90, cache_read=3500, model="claude-fallback", event="event-6"), mode="a")
record = rescan()
expect("Claude takes a streamed message's final count from appended lines",
       [record["modelUsage"]["claude-fallback"]["outputTokens"], record["todayTotalTokens"]], [90, 5968], record)

# A line of JSON that isn't an object skips that line, never the transcript.
sandbox()
transcript(message("listed-1", 10), [message("listed-x", 99)], message("listed-2", 20))
record = claude()
expect("Claude skips a transcript line that isn't an object and keeps the rest",
       record["todayTotalTokens"], 30, record)

# Only a missing time is today's: a time of 0, false or "" is untrusted and
# counts nowhere.
sandbox()
transcript(message("stamped", 10), *(message(f"falsy-{n}", 99, timestamp=stamp) for n, stamp in enumerate((0, False, ""))))
record = claude()
expect("Claude counts a transcript line with a falsy time nowhere",
       [record["todayTotalTokens"], sum(bucket["inputTokens"] for bucket in record["modelUsage"].values())], [10, 10], record)

# `--fork-session` copies the parent's replies into a new transcript under the
# fork's session id. Their tokens count once, but the parent was still a
# session in use, whichever transcript the scan visits last.
sandbox()
transcript(*({**message(f"msg_{n}", 1000, 50 + n), "sessionId": "parent"} for n in (1, 2)), name="parent.jsonl")
transcript(*({**message(f"msg_{n}", 1000, 50 + n), "sessionId": "fork"} for n in (1, 2, 3)), name="fork.jsonl")
module = load_collector("claude")
real_rglob = Path.rglob
for reverse in (False, True):
  module.Path.rglob = lambda path, pattern, reverse=reverse: iter(sorted(real_rglob(path, pattern), reverse=reverse))
  try:
    forked = module.scan_projects(projects().parent).snapshot()
  finally:
    module.Path.rglob = real_rglob
  expect(f"Claude counts a forked session's parent and its tokens once ({'parent' if reverse else 'fork'} read first)",
         [forked["todaySessions"], forked["totalSessions"], forked["todayTotalTokens"]], [2, 2, 3156], forked)

# A response is its message id and its request id. A gateway that reuses one
# message id for every response still served each of them; a copy in a fork
# keeps both ids and counts once; and a /btw side question's sidechain replays
# its parent's message under a new request id, which the parent's copy covers.
sandbox()


def served(message_id, request_id, output, session="session-1", **extra):
  return {**message(message_id, 1000, output), "requestId": request_id, "sessionId": session, **extra}


transcript(served("msg_gateway", "req_1", 10), served("msg_gateway", "req_2", 20), served("msg_parent", "req_3", 30), name="main.jsonl")
transcript(served("msg_gateway", "req_1", 10, session="fork"), served("msg_gateway", "req_4", 40, session="fork"), name="fork.jsonl")
transcript(served("msg_parent", "req_5", 30, isSidechain=True), served("msg_aside", "req_6", 50, isSidechain=True), name="main/subagents/agent-aside.jsonl")
record = claude()
expect("Claude counts a response by message and request id, once across forks and sidechain replays",
       record["todayTotalTokens"], 5000 + 10 + 20 + 30 + 40 + 50, record)

# A gateway reusing one message id gives a subagent's reply its parent's id
# too, as Claude Code 2.1.308 wrote it behind one: the subagent's request is
# its own, not a replay of the parent's, and counts.
sandbox()


def gateway(request_id, n, **extra):
  return {**message("msg_same", 5000234 + 1000 * n, 50 + n, cache_write=30 + n, cache_read=70 + n), "requestId": request_id, **extra}


transcript(gateway("req_0002", 1), gateway("req_0004", 3), gateway("req_0005", 4), name="main.jsonl")
transcript(gateway("req_0003", 2, isSidechain=True, agentId="a1"), name="main/subagents/agent-a1.jsonl")
record = claude()
expect("Claude counts a subagent's reply that shares its parent's message id", record["todayTotalTokens"], 20011566, record)

# An advisor the model consulted is billed apart under its own model, from
# the reply's `usage.iterations`; the top-level usage is the main model's
# alone, and no other iteration is added again. ccusage's own fixture line,
# with Claude models.
sandbox()
transcript({"timestamp": STAMP, "version": "1.2.3", "sessionId": "session-a", "type": "assistant", "requestId": "req-parent", "costUSD": 1.23,
            "message": {"id": "msg-parent", "model": "claude-main", "usage": {"input_tokens": 1, "output_tokens": 2, "iterations": [
              {"type": "message", "input_tokens": 1, "output_tokens": 2, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0},
              {"type": "advisor_message", "model": "claude-advisor", "input_tokens": 10, "output_tokens": 2, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0},
            ]}}})
record = claude()
expect("Claude counts an advisor iteration under the advisor's model",
       [record["todayTokensByModel"], record["modelUsage"].get("claude-advisor")],
       [{"claude-main": 3, "claude-advisor": 12}, {"inputTokens": 10, "outputTokens": 2, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0}], record)

# Claude Code fronts whatever ANTHROPIC_BASE_URL names, and Z.ai and Ollama
# document pointing it at their own APIs; their transcripts look like any
# other, with the model that answered on each reply, as a real Claude Code
# 2.1 run against them wrote: glm-4.6 through Z.ai, then `--continue` back on
# Anthropic in the same session, and qwen3-coder and glm-4.6:cloud through
# Ollama. Only what Anthropic served is Claude's, prompts included. A reply
# Claude Code made up itself (`<synthetic>`, no tokens) answers nothing.
sandbox()
transcript(user("zai-1", "zaihello", session="zai", promptSource="sdk"), {**message("msg_z1", 501234, 51, model="glm-4.6"), "sessionId": "zai"},
           user("zai-2", "continued", session="zai", promptSource="sdk"), {**message("msg_z2", 1000, 52, model="claude-sonnet-4-5"), "sessionId": "zai"},
           name="zai.jsonl")
transcript(user("local-1", "ollamaclaude", session="local", promptSource="sdk"), {**message("msg_o1", 21000, 53, model="qwen3-coder"), "sessionId": "local"},
           name="local.jsonl")
transcript(user("cloud-1", "ollamacloud", session="cloud", promptSource="sdk"), {**message("msg_c1", 31000, 54, model="glm-4.6:cloud"), "sessionId": "cloud"},
           name="cloud.jsonl")
transcript(user("synthetic-1", "hello", session="synthetic", promptSource="typed"), {**message("msg_s1", model="<synthetic>"), "sessionId": "synthetic"},
           name="synthetic.jsonl")
record = claude()
expect("Claude leaves out the turns Claude Code sent to another provider's model",
       [record["todayTokensByModel"], record["todayPrompts"], record["todaySessions"]], [{"claude-sonnet-4-5": 1052}, 2, 2], record)
# What Claude leaves out, the provider's collector counts by the same rule:
# the GLM reply is Z.ai's, once.
zai_record = collect("zai", "--force")
expect("Z.ai counts the Claude Code reply Claude leaves out", zai_record["todayTokensByModel"], {"glm-4.6": 501285}, zai_record)

# A transcript doesn't say where it was sent, so while Claude Code is pointed
# at another provider (its settings' env, else the environment), a Claude
# model's replies are that provider's too. A host this can't place, such as a
# proxy that may forward to Anthropic, leaves them Claude's.
for env, settings, claude_tokens in (
  ({}, {"ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic", "ANTHROPIC_AUTH_TOKEN": "zai-key"}, 0),
  ({"ANTHROPIC_BASE_URL": "https://ollama.com"}, {}, 0),
  ({"ANTHROPIC_BASE_URL": "https://ollama.com"}, {"ANTHROPIC_BASE_URL": "http://127.0.0.1:4000"}, 1052),
  ({}, {"ANTHROPIC_BASE_URL": "https://llm-proxy.example.com/anthropic"}, 1052),
):
  write_json(home() / ".claude" / "settings.json", {"env": settings})
  os.environ.update(env)
  try:
    record = claude()
  finally:
    for name in env:
      os.environ.pop(name)
  expect(f"Claude reads Claude model replies as {'Claude' if claude_tokens else 'not'} Claude's with the endpoint at {settings or env}",
         [record["todayTotalTokens"], record["todayPrompts"]], [claude_tokens, 2 if claude_tokens else 0], record)

# Unreadable transcripts are expected when an agent ran as another user, so
# they make one bounded warning rather than a line each.
sandbox()
for n in range(1, 6):
  transcript(name=f"unreadable-{n}.jsonl")
module = load_collector("claude")
real_open = Path.open


def deny_unreadable(path, *args, **kwargs):
  if path.name.startswith("unreadable-"):
    raise PermissionError("permission denied")
  return real_open(path, *args, **kwargs)


module.Path.open = deny_unreadable
try:
  with contextlib.redirect_stderr(io.StringIO()) as warnings:
    module.scan_projects(projects().parent)
finally:
  module.Path.open = real_open
lines = [line for line in warnings.getvalue().splitlines() if line.startswith("Ignoring ")]
check("Claude bounds unreadable transcripts to one warning with their count",
      len(lines) == 1 and lines[0].startswith("Ignoring 5 unreadable Claude project files"), warnings.getvalue())

# ---------------------------------------------------------------- sources

# A machine with no transcripts and no stats-cache still gets today's counts
# from history.jsonl.
sandbox()
(home() / ".claude").mkdir()
(home() / ".claude" / "history.jsonl").write_text("".join(json.dumps(line) + "\n" for line in (
  {"timestamp": 86400000, "sessionId": "old", "display": "ancient"},
  {"timestamp": ms_in(0), "sessionId": "s1", "display": "one"},
  {"timestamp": ms_in(0), "sessionId": "s2", "display": "two"},
)))
record = claude()
expect("Claude falls back on history.jsonl without a stats-cache", [record["todayPrompts"], record["todaySessions"]], [2, 2], record)

# A stats-cache shaped as Claude Code writes it gives the record's own
# shapes: seven local days of tokens from dailyModelTokens (dailyActivity
# counts messages), and per model the four token kinds alone, each a trusted
# count. A model another provider served (glm-4.6 through Z.ai) is not
# Claude's here either.
sandbox()
(home() / ".claude").mkdir()
week = [(datetime.now() - timedelta(days=offset)).date().isoformat() for offset in range(6, -1, -1)]
write_json(home() / ".claude" / "stats-cache.json", {
  "totalMessages": 120, "totalSessions": 3,
  "dailyActivity": [{"date": "2026-01-02", "messageCount": 120, "sessionCount": 3, "toolCallCount": 40}],
  "dailyModelTokens": [
    {"date": "2026-01-02", "tokensByModel": {"claude-opus": 999}},
    {"date": week[4], "tokensByModel": {"claude-opus": 300, "claude-haiku": 20, "glm-4.6": 4000}},
    {"date": week[6], "tokensByModel": {"claude-opus": 50}},
  ],
  "modelUsage": {
    "claude-opus": {"inputTokens": 10, "outputTokens": -5, "cacheReadInputTokens": 7, "cacheCreationInputTokens": "x", "costUSD": 1.5, "webSearchRequests": 2},
    "claude-odd": [1, 2],
    "glm-4.6": {"inputTokens": 4000, "outputTokens": 0, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0},
  },
})
record = claude()
expect("Claude's stats-cache fallback gives seven days of tokens and trusted model buckets", [record["recentDays"], record["modelUsage"]], [
  [{"date": day, "messageCount": {4: 320, 6: 50}.get(n, 0)} for n, day in enumerate(week)],
  {"claude-opus": {"inputTokens": 10, "outputTokens": 0, "cacheReadInputTokens": 7, "cacheCreationInputTokens": 0}},
], record)

# history.jsonl as interactive Claude Code 2.1.308 wrote it: two typed
# prompts, /model and /exit (built-ins that ask the model nothing, with and
# without arguments), a custom command, and a prompt typed while a turn ran.
def history_line(display, session):
  return {"display": display, "pastedContents": {}, "timestamp": ms_in(0), "project": "/home/me/proj", "sessionId": session}


HISTORY = [history_line("tuihello", "s1"), history_line("tuisecond", "s1"), history_line("/model opus", "s1"), history_line("/exit", "s1"),
           history_line("/mycmd", "s2"), history_line("queuedtwo", "s2"), history_line("/exit", "s2")]

# Without transcripts, history.jsonl's built-in commands are no prompts.
sandbox()
(home() / ".claude").mkdir()
(home() / ".claude" / "history.jsonl").write_text("".join(json.dumps(line) + "\n" for line in HISTORY))
record = claude()
expect("Claude's history.jsonl fallback counts no built-in local command", [record["todayPrompts"], record["todaySessions"]], [4, 2], record)

# Sent to Z.ai, those prompts were Z.ai's, and neither file says otherwise.
write_json(home() / ".claude" / "settings.json", {"env": {"ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic"}})
write_json(home() / ".claude" / "stats-cache.json", {"totalMessages": 40, "totalSessions": 3, "dailyActivity": [{"date": datetime.now().date().isoformat(), "messageCount": 4}]})
record = claude()
expect("Claude sent to Z.ai takes no prompts or sessions from its fallbacks",
       [record["todayPrompts"], record["todaySessions"], record["totalPrompts"], record["totalSessions"], record["activeDays"]], [0, 0, 0, 0, 0], record)

# Transcripts whose every reply another provider served were counted by that
# provider's collector, prompts included: the fallbacks are not read again.
(home() / ".claude" / "settings.json").unlink()
transcript(
  {"type": "user", "uuid": "u1", "sessionId": "s1", "timestamp": STAMP, "promptSource": "typed", "message": {"role": "user", "content": "tuihello"}},
  message("glm-1", 10, 5, model="glm-5"),
)
for where, settings in (("named by its model", {}), ("sent to Z.ai", {"env": {"ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic"}})):
  write_json(home() / ".claude" / "settings.json", settings)
  record = claude()
  expect(f"Claude with only another provider's transcripts ({where}) reads no fallback",
         [record["ready"], record["todayPrompts"], record["todaySessions"], record["totalPrompts"], record["totalSessions"], record["activeDays"]],
         [False, 0, 0, 0, 0, 0], record)

# A stats-cache or history line of the wrong shape costs that field or line,
# never the record.
sandbox()
(home() / ".claude").mkdir()
for cache in ([1, 2], {"dailyModelTokens": 5, "dailyActivity": 7, "modelUsage": [1]},
              {"dailyModelTokens": [{"date": datetime.now().date().isoformat(), "tokensByModel": ["x"]}]}):
  write_json(home() / ".claude" / "stats-cache.json", cache)
  (home() / ".claude" / "history.jsonl").write_text(json.dumps([1]) + "\n" + json.dumps({"timestamp": ms_in(0), "sessionId": "s1"}) + "\n")
  record = claude()
  expect(f"a stats-cache shaped {json.dumps(cache)[:40]} and a list history line read as nothing",
         [record["todayPrompts"], record["todayTokensByModel"], record["modelUsage"]], [1, {}, {}], record)

# pi and opencode replies count on the anthropic provider alone: not another
# provider driving Anthropic's API, and not a prompt.
sandbox()
write_pi_session(home() / ".pi" / "agent" / "sessions" / "project" / "pi.jsonl", [
  pi_reply("anthropic", 10, id="pi-1", model="claude-pi", api="anthropic-messages"),
  pi_reply("kimi-coding", 999, id="kimi-1", model="k3", api="anthropic-messages"),
])
opencode_db(message=[
  ("msg_1", "ses_1", oc_v1("anthropic", 100, model="claude-opus-5")),
  ("msg_2", "ses_1", oc_v1("anthropic", 999, model="claude-opus-5", role="user")),
])
record = claude()
expect("Claude counts pi and opencode replies on the anthropic provider alone",
       [record["todayTotalTokens"], sorted(record["modelUsage"])], [110, ["claude-opus-5", "claude-pi"]], record)

# A Claude Code home without a sign-in is in use, and the sign-in is missing.
sandbox()
(home() / ".claude").mkdir()
record = claude()
expect("Claude asks a signed-out Claude Code home to sign in", [record["ready"], record["usageStatusText"]], [False, "Waiting for auth"], record)

# ------------------------------------------------------------- cost-state

# Claude Code 2.1.278 and later write a cost-state line when a process saves its
# cost: the lineage's startTime, carried through a resume and a
# --fork-session, and what each model has used in it so far, the requests no
# reply line records (a /compact, the session title, a side query)
# included. Shapes as Claude Code wrote them against a mock API that served
# each request once.
sandbox()
YESTERDAY = (fixture_now().astimezone() - timedelta(days=1)).replace(hour=12, minute=0, second=0, microsecond=0).isoformat()


def reply(session, message_id, counts, timestamp, model="claude-sonnet-4-5", sidechain=False):
  return {"parentUuid": None, "isSidechain": sidechain, "type": "assistant", "sessionId": session, "timestamp": timestamp,
          "requestId": f"req_{message_id}", "uuid": f"uuid-{session}-{message_id}",
          "message": {"model": model, "id": message_id, "type": "message", "role": "assistant", "content": [{"type": "text", "text": "Hello"}],
                      "usage": dict(zip(("input_tokens", "output_tokens", "cache_read_input_tokens", "cache_creation_input_tokens"), counts))}}


def typed(session, uuid, timestamp, text="Say hello"):
  return {"parentUuid": None, "isSidechain": False, "type": "user", "promptSource": "sdk", "sessionId": session, "timestamp": timestamp,
          "uuid": uuid, "message": {"role": "user", "content": text}}


def cost_state(session, start, usage):
  return {"type": "cost-state", "sessionId": session, "totalCostUSD": 0.0046, "totalAPIDuration": 9, "startTime": start,
          "modelUsage": {model: {"inputTokens": counts[0], "outputTokens": counts[1], "thinkingTokens": 0, "cacheReadInputTokens": counts[2],
                                 "cacheCreationInputTokens": counts[3], "webSearchRequests": 0, "costUSD": 0.0046}
                         for model, counts in usage.items()},
          "hasUnknownModelCost": False}


def claude_code_days(owner="claude"):
  import collectors
  days = {}
  for row in collectors.scan_claude_code(owner, projects().parent, base_url=""):
    by_model = days.setdefault(row.day, {})
    by_model[row.model] = by_model.get(row.model, 0) + row.input_tokens + row.output_tokens + row.cache_read + row.cache_write
  return days


yesterday, today_day = YESTERDAY[:10], fixture_now().astimezone().date().isoformat()
# A one-shot run asks for a title too, and is resumed the next day for a
# /compact, whose request no reply line records.
compacted = [
  typed("compact", "u-compact-1", YESTERDAY),
  reply("compact", "msg_c1", (1234, 51, 71, 31), YESTERDAY),
  {"type": "last-prompt", "lastPrompt": "Say hello", "sessionId": "compact"},
  cost_state("compact", 1792669864166, {"claude-sonnet-4-5[1m]": (1234, 51, 71, 31), "claude-haiku-4-5-20251001": (893, 24, 0, 0)}),
  {"type": "queue-operation", "operation": "enqueue", "timestamp": STAMP, "sessionId": "compact", "content": "/compact"},
  {"type": "system", "subtype": "compact_boundary", "content": "Conversation compacted", "timestamp": STAMP, "sessionId": "compact",
   "compactMetadata": {"trigger": "manual", "preTokens": 1387}},
  {"type": "user", "isCompactSummary": True, "sessionId": "compact", "timestamp": STAMP, "uuid": "u-summary", "message": {"role": "user", "content": "Summary"}},
  cost_state("compact", 1792669864166, {"claude-sonnet-4-5[1m]": (3002468, 102, 142, 62), "claude-haiku-4-5-20251001": (893, 24, 0, 0)}),
]
transcript(*compacted[:4], name="compact.jsonl")
expect("Claude counts the title query a cost-state holds beyond the replies", claude_code_days(),
       {yesterday: {"claude-sonnet-4-5": 1387, "claude-haiku-4-5-20251001": 917}})
transcript(*compacted[4:], name="compact.jsonl", mode="a")
expect("Claude counts a /compact's request, read from the cost-state appended after it, on the day it ran", claude_code_days(),
       {yesterday: {"claude-sonnet-4-5": 1387, "claude-haiku-4-5-20251001": 917}, today_day: {"claude-sonnet-4-5": 3001387}})
index = json.loads(next(cache_root().glob("claude-index-*.json")).read_text())
(projects() / "compact.jsonl").touch()
expect("Claude reads a cost-state appended to a transcript as it reads the whole transcript again",
       [claude_code_days(), [entry["costs"] for entry in json.loads(next(cache_root().glob("claude-index-*.json")).read_text())["files"].values()]],
       [{yesterday: {"claude-sonnet-4-5": 1387, "claude-haiku-4-5-20251001": 917}, today_day: {"claude-sonnet-4-5": 3001387}},
        [entry["costs"] for entry in index["files"].values()]])

# A --fork-session carries the lineage on: its cost-state includes the
# parent's, compaction and all, and its transcript copies the parent's
# replies under its own session. A subagent runs under its parent's session
# in a file of its own, and its replies are in the cost-state too. A
# process still running has replies past its last cost-state.
sandbox()
parent = [typed("parent", "u-p1", STAMP), reply("parent", "msg_p1", (101234, 51, 71, 31), STAMP)]
transcript(*parent, cost_state("parent", 1792669919352, {"claude-sonnet-4-5": (203468, 103, 143, 63)}), name="parent.jsonl")
transcript(*[{**line, "sessionId": "fork"} for line in parent], typed("fork", "u-f1", STAMP), reply("fork", "msg_f1", (701234, 51, 71, 31), STAMP),
           cost_state("fork", 1792669919352, {"claude-sonnet-4-5": (904702, 154, 214, 94)}), name="fork.jsonl")
transcript(typed("main", "u-m1", STAMP), reply("main", "msg_m1", (100, 1, 0, 0), STAMP),
           cost_state("main", 1792681739702, {"claude-sonnet-4-5": (5600, 6, 0, 0), "claude-haiku-4-5-20251001": (300, 3, 0, 0)}),
           reply("main", "msg_m2", (90000, 9, 0, 0), today_stamp(13)), name="main.jsonl")
transcript(reply("main", "msg_s1", (5000, 5, 0, 0), STAMP, sidechain=True), name="main/subagents/agent-a1.jsonl")
expect("Claude counts a fork's lineage once, a subagent's replies once, and keeps what a running process's cost-state held beyond its replies",
       claude_code_days(),
       {today_day: {"claude-sonnet-4-5": 905164 + 101 + 5005 + 500 + 90009, "claude-haiku-4-5-20251001": 303}})

# A gateway can name a model one way in the request and another in the
# reply: no more counts than the cost-state says beyond every reply.
sandbox()
transcript(typed("gw", "u-g1", STAMP), reply("gw", "msg_g1", (500, 5, 0, 0), STAMP, model="claude-sonnet-4-5-20250929"),
           cost_state("gw", 1792681376828, {"anthropic/claude-sonnet-4.5": (500, 5, 0, 0)}), name="gw.jsonl")
expect("Claude counts nothing more for a cost-state that names the replies' model another way", claude_code_days(),
       {today_day: {"claude-sonnet-4-5-20250929": 505}})

# Claude Code 2.1.282 can write a subagent's reply with only its
# message_start usage (stop_reason null, a few output tokens) and never its
# real output. The cost-state's totals make up the difference, on the day of
# the cost-state, not the day the subagent ran.
sandbox()
snapshot = {**reply("snap", "msg_s1", (3, 10, 40000, 2000), YESTERDAY, model="claude-opus-4-5", sidechain=True)}
snapshot["message"] = {**snapshot["message"], "stop_reason": None, "content": [{"type": "tool_use", "id": "toolu_1", "name": "Read", "input": {}}]}
transcript(snapshot, name="snap/subagents/agent-a1.jsonl")
transcript(typed("snap", "u-n1", YESTERDAY), reply("snap", "msg_n1", (100, 50, 0, 0), YESTERDAY, model="claude-opus-4-5"),
           typed("snap", "u-n2", STAMP), reply("snap", "msg_n2", (10, 1, 0, 0), STAMP, model="claude-opus-4-5"),
           cost_state("snap", 1790338485827, {"claude-opus-4-5": (113, 2461, 40000, 2000)}), name="snap.jsonl")
expect("Claude counts the output a cost-state holds beyond a subagent's message_start snapshot, on the cost-state's day", claude_code_days(),
       {yesterday: {"claude-opus-4-5": 42163}, today_day: {"claude-opus-4-5": 2411}})

# ---------------------------------------------------------------- contract

sandbox()


def add_message():
  add_message.count = getattr(add_message, "count", 0) + 1
  transcript(message(f"grown-{add_message.count}", 10), mode="a")


check_scan_cache(Adapter("claude", grow=add_message, pi_root=lambda: home() / ".pi" / "agent" / "sessions"))

# A scan that couldn't read one of the transcripts isn't kept for the next
# run, so the missing tokens show as soon as the file can be read.
if os.geteuid() != 0:
  sandbox()
  claude_code_session("seen", [("claude-sonnet-4-5", 300)])
  locked = claude_code_session("late", [("claude-sonnet-4-5", 40)])
  locked.chmod(0)
  try:
    claude()
  finally:
    locked.chmod(0o644)
  record = claude("--limits-only")
  expect("Claude does not cache a scan that missed a transcript", record["todayTokensByModel"], {"claude-sonnet-4-5": 340}, record)
else:
  print("ok - Claude does not cache a scan that missed a transcript # SKIP root reads anything")
PY
