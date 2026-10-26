#!/bin/bash

# The Codex collector's own sources: native Codex rollouts and their per-file
# cache, its filter over pi and opencode sessions, and how it finds, starts and
# reads the Codex app-server for its limits. How the shared pi and opencode
# readers work, and the unused-machine record, are held centrally by the shared
# and partition tests, and the scan cache by the contract check. The limits
# cache has a test of its own.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox
require_command rg
require_command jq

# The stand-in app-server every signed-in home below copies.
fake_codex "$HOME"

python3 - <<'PY'
import shutil
import tempfile

from agent_usage_fixtures import *

FAKE_CODEX = home() / "bin" / "codex"
FAKE_AUTH = home() / ".codex" / "auth.json"
BASE_PATH = os.environ["PATH"]
# Only the interpreter and file tools, so no codex or mise on this machine can
# answer for the stubs.
TOOLS = Path(os.environ["SANDBOX"]) / "tools"
STAMP = today_stamp()


def new_home(codex=FAKE_CODEX, auth=True, path=None):
  """A sandbox home with `codex` (a stub's path or its bash body) in its bin/,
  signed in unless `auth` is False ("empty" leaves an empty auth.json)."""
  sandbox()
  bin_dir = home() / "bin"
  bin_dir.mkdir()
  if isinstance(codex, Path):
    shutil.copy(codex, bin_dir / "codex")
  elif codex is not None:
    stub(bin_dir / "codex", codex)
  (home() / ".codex").mkdir()
  if auth == "empty":
    (home() / ".codex" / "auth.json").touch()
  elif auth:
    shutil.copy(FAKE_AUTH, home() / ".codex" / "auth.json")
  os.environ["PATH"] = f"{bin_dir}:{path or BASE_PATH}"
  return home()


def stub(path, body):
  path = Path(path)
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text(body if body.startswith("#!") else "#!/bin/bash\n" + body)
  path.chmod(0o755)
  return path


def codex(*args, env=None, quick=False):
  """The collector's record, run with `env` added. `quick` cuts the 8-second
  app-server timeout to half a second, for the cases that only need it to
  give up."""
  env = {key: str(value) for key, value in (env or {}).items()}
  saved = {key: os.environ.get(key) for key in env}
  os.environ.update(env)
  try:
    module = load_collector("codex")
    if quick:
      real = module.rpc_request
      module.rpc_request = lambda proc, request_id, method, params=None, timeout=8: real(proc, request_id, method, params, min(timeout, 0.5))
    with contextlib.redirect_stderr(io.StringIO()):
      return run_main(module, *(args or ("--force",)))
  finally:
    for key, value in saved.items():
      if value is None:
        os.environ.pop(key, None)
      else:
        os.environ[key] = value


def sessions():
  return home() / ".codex" / "sessions" / datetime.now().strftime("%Y/%m/%d")


def rollout(name, *lines, stamp=STAMP, mode="w"):
  path = sessions() / name
  path.parent.mkdir(parents=True, exist_ok=True)
  with path.open(mode) as handle:
    for line in lines:
      if isinstance(line, str):
        handle.write(line + "\n")
      else:
        handle.write(json.dumps({"timestamp": stamp, **line}) + "\n")
  return path


def context(model):
  return {"type": "turn_context", "payload": {"model": model}}


def meta(**payload):
  return {"type": "session_meta", "payload": payload}


def tokens(input, output, cached=0, total=None, kind="event_msg", **extra):
  info = {"last_token_usage": {"input_tokens": input, "cached_input_tokens": cached, "output_tokens": output, **extra}}
  if total is not None:
    info["total_token_usage"] = total
  return {"type": kind, "payload": {"type": "token_count", "info": info}}


def typed(text="hello", **extra):
  # A prompt as Codex 0.163 writes it in a paginated rollout.
  item = {"type": "UserMessage", "id": "u1", "content": [{"type": "text", "text": text, "text_elements": []}]}
  return {"type": "event_msg", **extra, "payload": {"type": "item_completed", "thread_id": "t1", "turn_id": "turn1", "item": item}}


# ---------------------------------------------------------- native rollouts

# A request counts once: a quota notification repeats the last request's usage
# under an unchanged running total. Cached input and reasoning are parts of
# input and output, not more of them, and the two requests one typed prompt
# took are still one prompt.
new_home()
first = {"input_tokens": 100, "cached_input_tokens": 60, "output_tokens": 20, "reasoning_output_tokens": 5, "total_tokens": 120}
second = {"input_tokens": 180, "cached_input_tokens": 110, "output_tokens": 30, "reasoning_output_tokens": 8, "total_tokens": 210}
rollout("rollout.jsonl", context("gpt-test"), typed(),
        tokens(100, 20, 60, first, reasoning_output_tokens=5, total_tokens=120),
        tokens(80, 10, 50, second, reasoning_output_tokens=3, total_tokens=90),
        {**tokens(80, 10, 50, second, reasoning_output_tokens=3, total_tokens=90), "rate_limits": {"primary": {"used_percent": 10}}})
record = codex("--force", env={"CODEX_ARGS_FILE": home() / "codex-args"})
expect("Codex counts each request once, without a quota notification or cache and reasoning twice, and a prompt once", {
  "today": record["todayTotalTokens"], "prompts": record["todayPrompts"], "usage": record["modelUsage"]["gpt-test"], "help": record["authHelpText"],
}, {
  "today": 210, "prompts": 1, "usage": {"inputTokens": 70, "outputTokens": 30, "cacheReadInputTokens": 110, "cacheCreationInputTokens": 0}, "help": "",
}, record)
# Separate arguments, not "-a on-request" as one, which is no policy Codex
# accepts.
expect("Codex starts its app-server read-only with a supported approval policy",
       (home() / "codex-args").read_text().split("\0"), ["-s", "read-only", "-a", "on-request", "app-server"])

# Codex 0.163 writes a token_usage_record for every response it is billed for.
# A remote compaction is one only a record names: the token_count after it
# spends nothing and leaves the running total alone, and a resumed turn may
# write a record and no token_count at all. Each record counts once, a line
# repeated under the same id and total being the same response, while a mock
# backend reusing an id in a later turn is a new one; the token_count lines
# after the first record repeat them, and one before it, from an older Codex,
# still counts.
new_home()


def usage(input, output, cached=0, written=0):
  return {"input_tokens": input, "cached_input_tokens": cached, "cache_write_input_tokens": written, "output_tokens": output,
          "reasoning_output_tokens": 0, "total_tokens": input + output}


def usage_record(turn, response, spent, thread):
  return {"type": "token_usage_record", "payload": {"thread_id": "t1", "turn_id": turn, "session_id": "t1", "root_turn_id": turn,
                                                     "response_id": response, "usage": spent, "turn_token_usage": spent, "thread_token_usage": thread}}


def snapshot(last, total):
  return {"type": "event_msg", "payload": {"type": "token_count", "info": {"total_token_usage": total, "last_token_usage": last, "model_context_window": 258400}}}


first, compaction, reply, resumed = usage(31234, 51, 71, 31), usage(61234, 51, 71, 31), usage(62234, 52, 72, 32), usage(1000, 10)
after_reply = usage(93468, 103, 143, 63)
rollout("rollout-compacted.jsonl", meta(model_provider="openai", source="exec", thread_source="user", id="t1", session_id="t1", cli_version="0.163.0"),
        context("gpt-test"), typed("first"), usage_record("turn1", "resp_mock_0001", first, first), snapshot(first, first),
        usage_record("turn2", "resp_mock_0001", compaction, usage(92468, 102, 142, 62)),
        {"type": "compacted", "payload": {"message": "", "replacement_history": []}}, context("gpt-test"),
        snapshot(usage(0, 0), first), typed("second"),
        usage_record("turn2", "resp_mock_0002", reply, usage(154702, 154, 214, 94)), snapshot(reply, after_reply),
        usage_record("turn2", "resp_mock_0002", reply, usage(154702, 154, 214, 94)),
        typed("third"), usage_record("turn3", "resp_mock_0001", resumed, usage(155702, 164, 214, 94)))
rollout("rollout-upgraded.jsonl", meta(model_provider="openai", source="cli"), context("gpt-older"), typed(),
        snapshot(usage(100, 10), usage(100, 10)), typed(), usage_record("turn2", "resp_2", usage(200, 20), usage(300, 30)),
        snapshot(usage(200, 20), usage(300, 30)))
record = codex()
expect("Codex counts every response a token_usage_record names, a compaction's and a resumed turn's included, each once", {
  "today": record["todayTotalTokens"], "byModel": record["todayTokensByModel"], "prompts": record["todayPrompts"], "usage": record["modelUsage"]["gpt-test"],
}, {
  "today": 31285 + 61285 + 62286 + 1010 + 330, "byModel": {"gpt-test": 155866, "gpt-older": 330}, "prompts": 5,
  "usage": {"inputTokens": 155702 - 214 - 94, "outputTokens": 164, "cacheReadInputTokens": 214, "cacheCreationInputTokens": 94},
}, record)


# Codex CLI can front any OpenAI-compatible backend (`--oss`, or a custom
# model_provider), whose rollouts land beside the subscription's but spend a
# local box or a third party. A rollout from before Codex recorded the
# provider still counts, and a fork's own session_meta, first, decides.
new_home()
for name, provider, model, input, output in (("native", "openai", "gpt-native", 100, 10), ("ollama", "ollama", "qwen3-coder:30b", 9000, 900),
                                              ("openrouter", "openrouter", "claude-test", 5000, 500)):
  rollout(f"rollout-{name}.jsonl", meta(model_provider=provider), context(model), tokens(input, output, cache_write_input_tokens=0, reasoning_output_tokens=0))
rollout("rollout-legacy.jsonl", meta(id="legacy"), context("gpt-legacy"), tokens(40, 0))
rollout("rollout-fork.jsonl", meta(model_provider="openai"), meta(model_provider="ollama"), context("gpt-fork"), tokens(3, 0))
record = codex()
expect("Codex counts only subscription-backed rollouts, legacy ones included",
       [record["todayTotalTokens"], sorted(record["modelUsage"]), record["todaySessions"]], [153, ["gpt-fork", "gpt-legacy", "gpt-native"], 3], record)

# Lines that aren't usage, or aren't JSON, are skipped, and turn_context
# switches the model the following turns count under.
new_home()
rollout("session.jsonl", meta(id="session-123"), "this is plain non-json text that should be skipped by the prefilter",
        context("gpt-4o"), {"type": "user_message", "payload": {"content": "Write a sorting algorithm"}},
        {"type": "agent_reasoning", "payload": {"content": "Thinking about quicksort..."}},
        tokens(50, 15, 20, kind="response_item", total_tokens=65), {"type": "agent_message", "payload": {"content": "Here is quicksort..."}},
        context("o3-mini"), tokens(30, 5, 10, total_tokens=35))
record = codex()
expect("Codex skips lines that aren't usage and tracks the model across turn_context", {
  "today": record["todayTotalTokens"], "byModel": record["todayTokensByModel"], "4o": record["modelUsage"]["gpt-4o"], "o3": record["modelUsage"]["o3-mini"],
}, {
  "today": 100, "byModel": {"gpt-4o": 65, "o3-mini": 35},
  "4o": {"inputTokens": 30, "outputTokens": 15, "cacheReadInputTokens": 20, "cacheCreationInputTokens": 0},
  "o3": {"inputTokens": 20, "outputTokens": 5, "cacheReadInputTokens": 10, "cacheCreationInputTokens": 0},
}, record)

# A line of the wrong shape, or a payload, info or usage that isn't an
# object, loses that line alone: the turns after it still count.
new_home()
rollout("shaped.jsonl", '[{"type": "session_meta"}]', {"type": "session_meta", "payload": [1]},
        {"type": "turn_context", "payload": ["gpt-x"]}, context("gpt-test"), typed(), tokens(10, 1),
        {"type": "event_msg", "payload": {"type": "token_count", "info": [1]}},
        {"type": "event_msg", "payload": {"type": "item_completed", "item": [1]}},
        {"type": "event_msg", "payload": {"type": "token_count", "info": {"last_token_usage": [1]}}}, typed(), tokens(20, 2))
record = codex()
expect("Codex skips a wrong-shaped rollout line and keeps reading the file",
       [record["todayTotalTokens"], record["todayPrompts"]], [33, 2], record)

# Only a line with no time at all takes the file's; a time of 0, false, or ""
# is one that can't be trusted, so it counts nowhere.
new_home()
rollout("falsy.jsonl", context("gpt-test"), *(json.dumps({"timestamp": falsy, **tokens(100, 0)}) for falsy in (0, False, "")),
        *(json.dumps({"timestamp": falsy, **typed()}) for falsy in (0, False, "")), typed(), tokens(10, 1))
record = codex()
expect("Codex counts a rollout line with a time of 0, false, or empty nowhere, not on the file's day",
       [record["todayTotalTokens"], record["todayPrompts"]], [11, 1], record)

# Prompts are the ones typed, as Codex 0.163 records them: one prompt whose
# tool call took two requests is one, as is a legacy rollout's user_message
# event; the context Codex adds itself, and a subagent's or guardian's
# messages, are none, though the tokens they spent count. Those threads start
# no session either, counting under the one that started them: its root in
# session_id, as Codex 0.163 writes it, or else its parent_thread_id. A thread
# of Codex's own that names no other, such as a memory consolidation, counts
# under none.
new_home()
rollout("rollout-paginated.jsonl", meta(model_provider="openai", source="exec", thread_source="user", id="t-exec", session_id="t-exec"),
        {"type": "event_msg", "payload": {"type": "task_started", "turn_id": "turn1"}}, context("gpt-test"),
        {"type": "response_item", "payload": {"type": "message", "role": "user", "content": [{"type": "input_text", "text": "<environment_context>"}]}},
        typed("run ls"), tokens(10, 1, total={"input_tokens": 10}),
        {"type": "event_msg", "payload": {"type": "item_completed", "item": {"type": "CommandExecution", "id": "c1"}}},
        tokens(20, 2, total={"input_tokens": 30}), {"type": "event_msg", "payload": {"type": "task_complete", "turn_id": "turn1"}})
rollout("rollout-legacy.jsonl", meta(model_provider="openai", source="cli", id="t-cli"), context("gpt-test"),
        {"type": "event_msg", "payload": {"type": "user_message", "message": "<user_instructions>", "kind": "user_instructions"}},
        {"type": "event_msg", "payload": {"type": "user_message", "message": "fix it", "kind": "plain"}},
        {"type": "event_msg", "payload": {"type": "user_message", "message": "and test it"}}, tokens(40, 4))
rollout("rollout-review.jsonl", meta(model_provider="openai", source={"subagent": "review"}, thread_source="subagent", id="t-review", session_id="t-exec",
                                     parent_thread_id="t-exec"), context("gpt-test"), typed(), tokens(100, 10))
rollout("rollout-memory.jsonl", meta(model_provider="openai", source={"internal": "memory_consolidation"}, thread_source="memory_consolidation", id="t-memory",
                                     session_id="t-memory"), context("gpt-test"), tokens(300, 30))
rollout("rollout-guardian.jsonl", meta(model_provider="openai", source={"subagent": {"other": "guardian"}}, thread_source="guardian_review", id="t-guardian",
                                       parent_thread_id="t-cli"),
        context("gpt-test"), typed(), tokens(200, 20))
record = codex()
expect("Codex counts the prompts typed, not the requests answering them or a subagent's, and a subagent's thread as no session",
       [record["todayTotalTokens"], record["todayPrompts"], record["todaySessions"], record["totalSessions"]], [737, 3, 2, 2], record)

# Session history only grows, so a refresh reads the files that changed and
# replays its per-file totals for the rest. pi sessions stay out of that
# cache: a fork repeats its parent's messages, so they are only deduplicated
# across the whole tree at once.
new_home()
early = today_stamp(9)
native = rollout("rollout.jsonl", context("gpt-test"), tokens(10, 5), stamp=early)
pi = write_pi_session(home() / ".pi" / "agent" / "sessions" / "session.jsonl", [pi_reply("openai-codex", 0, id="m1", model="gpt-test", timestamp=early, usage={"input": 4, "output": 1})])


def file_cache():
  return json.loads(next(cache_root().glob("codex-rollouts-*.json")).read_text())


def incremental(*args):
  # The aggregate scan cache would answer on its own; the rescan beneath it
  # is what this covers.
  for path in scan_cache_files("codex"):
    age_scan_cache(path, 7200)
  return codex(*(args or ("--limits-only",)))


record = codex("--limits-only")
cached = file_cache()["files"]
expect("Codex counts both sources and records the native file, not pi's, per file",
       [record["todayTotalTokens"], len(cached.get(str(native), {}).get("days", {})), str(pi) in cached], [20, 1, False], record)

if os.geteuid() != 0:
  # Unreadable, but unchanged in mtime and size: the same totals can only
  # have been replayed.
  native.chmod(0)
  replayed = incremental()
  forced = incremental("--force")
  native.chmod(0o644)
  expect("Codex replays an unchanged rollout, and --force rereads the history",
         [replayed["todayTotalTokens"], forced["todayTotalTokens"]], [20, 5])
  # The forced run couldn't read the rollout, so cache it again first.
  incremental()

rollout("rollout.jsonl", tokens(30, 2, 10), stamp=early, mode="a")
record = incremental()
expect("Codex rereads a rollout that grew", record["todayTotalTokens"], 52, record)

# A long session's rollout that grew is read on from where the last read
# stopped, through the reader every collector shares, not again from the
# start: a request rewritten in the middle of what was read, the same size,
# still counts as it was read.
padding = {"type": "response_item", "payload": {"type": "message", "role": "assistant", "content": [{"type": "output_text", "text": "x" * 6000}]}}
grown = rollout("rollout-grown.jsonl", meta(model_provider="openai", source="exec", id="t-grown"), context("gpt-grown"), typed(), tokens(10, 5),
                padding, padding, tokens(100, 0), padding, padding, tokens(1, 0), stamp=early)
incremental()
grown.write_text(grown.read_text().replace('"input_tokens": 100,', '"input_tokens": 900,'))
rollout("rollout-grown.jsonl", typed(), tokens(30, 2), stamp=early, mode="a")
record = incremental()
expect("Codex reads a grown rollout on from where it stopped", record["todayTokensByModel"].get("gpt-grown"), 148, record)

# Per-file totals are bucketed by local day, so a new timezone reads them again.
zone_stamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT02:00:00Z")
zone = home() / ".codex" / "sessions" / "zone.jsonl"
zone.write_text(json.dumps({"timestamp": zone_stamp, **tokens(3, 1)}) + "\n")
saved_tz = os.environ.get("TZ")
try:
  os.environ["TZ"] = "UTC"
  time.tzset()
  incremental()
  os.environ["TZ"] = "America/Los_Angeles"
  time.tzset()
  incremental()
  expected_day = datetime.fromisoformat(zone_stamp.replace("Z", "+00:00")).astimezone().date().isoformat()
finally:
  if saved_tz is None:
    os.environ.pop("TZ", None)
  else:
    os.environ["TZ"] = saved_tz
  time.tzset()
expect("Codex rereads per-file totals after a timezone change", list(file_cache()["files"][str(zone)]["days"]), [expected_day])

# A line that stops the read keeps the usage read before it.
(home() / ".codex" / "sessions" / "broken.jsonl").write_text(
  json.dumps({"timestamp": early, **context("gpt-broken")}) + "\n" + json.dumps({"timestamp": early, **tokens(6, 0)}) + "\nnull\n")
record = incremental()
expect("Codex keeps the usage read before a line that stops the read", record["modelUsage"].get("gpt-broken", {}).get("inputTokens"), 6, record)

# A scan that couldn't read a rollout serves its own run, but isn't cached as
# the whole story: the next run reads it again.
if os.geteuid() != 0:
  new_home()
  unreadable = rollout("unreadable.jsonl", context("gpt-test"), tokens(7, 0))
  unreadable.chmod(0)
  partial = codex("--force")
  unreadable.chmod(0o644)
  record = codex("--limits-only")
  expect("Codex never caches a scan that couldn't read a rollout",
         [partial["todayTotalTokens"], record["todayTotalTokens"]], [0, 7], record)

# ------------------------------------------------------- pi and opencode

# pi and omp replies count on the openai-codex provider or the Responses API
# pi drives for it, written compact as pi writes them, and no other provider.
# Two messages sharing an id at different times are two messages, and a fork
# naming its parent through a symlinked spelling of pi's tree still repeats it.
new_home()
root = home() / ".pi" / "agent" / "sessions" / "project"
root.mkdir(parents=True)
(home() / "pi-alias").symlink_to(home() / ".pi" / "agent")


def compact(id, provider, input, timestamp=STAMP, api=None):
  message = {"role": "assistant", "provider": provider, "model": "gpt-pi", "usage": {"input": input, "output": 0}}
  if api:
    message["api"] = api
  return json.dumps({"type": "message", "id": id, "timestamp": timestamp, "message": message}, separators=(",", ":"))


write_pi_session(root / "pi.jsonl", [
  compact("deadbeef", "openai-codex", 10),
  compact("deadbeef", "openai-codex", 8, timestamp=STAMP.replace(":00:00", ":00:01")),
  compact("api", "openai", 20, api="openai-codex-responses"),
  compact("other", "anthropic", 999),
])
write_pi_session(root / "fork.jsonl", [compact("deadbeef", "openai-codex", 10)], parent=home() / "pi-alias" / "sessions" / "project" / "pi.jsonl")
opencode_db(message=[("c1", "ses_1", json.dumps(json.loads(oc_v1("openai", 5, model="gpt-5.2-codex")), separators=(",", ":")))])
record = codex()
expect("Codex counts compact pi replies on its provider or API, an id reused at another time, a fork once, and compact opencode rows",
       [record["todayTotalTokens"], record["todayPrompts"], record["totalSessions"]], [43, 4, 2], record)

# ------------------------------------------------------------- scan cache

new_home()
opencode_db(message=[("c1", "ses_1", oc_v1("openai", 5, model="gpt-5.2-codex"))])
codex()
# A scan cached before native notifications were deduplicated must not bring
# its inflated counts back, even for --limits-only.
edit_scan_cache("codex", lambda data: data.update(schemaVersion=1, stats={**data["stats"], "todayTotalTokens": 999}))
record = codex("--limits-only")
expect("Codex rescans a scan cached before notifications were deduplicated",
       [record["todayTotalTokens"], json.loads(scan_cache_files("codex")[0].read_text())["schemaVersion"]], [5, 2], record)
# A cache file of the wrong shape is a miss, written again.
for path in scan_cache_files("codex"):
  path.write_text("[]")
record = codex("--limits-only")
expect("Codex rescans past a scan cache of the wrong shape, and writes it again",
       [record["todayTotalTokens"], json.loads(scan_cache_files("codex")[0].read_text()).get("schemaVersion")], [5, 2], record)
# A cache that can't be written still leaves a record.
(home() / "not-a-dir").write_text("")
record = codex("--limits-only", env={"XDG_CACHE_HOME": home() / "not-a-dir"})
expect("Codex still prints its record when the cache can't be written", record["todayTotalTokens"], 5, record)

# ----------------------------------------------------------- the app-server

# Rate limits with optional free resets, and an account/read that can hang
# for good, as Codex 0.158's does.
ANSWERS = r'''
while read -r request; do
  id=$(jq -r '.id // empty' <<<"$request")
  case "$(jq -r '.method // empty' <<<"$request")" in
    initialize) jq -cn --argjson id "$id" '{id: $id, result: {}}' ;;
    account/read)
      [[ -n ${CODEX_ACCOUNT_READ_HANGS:-} ]] ||
        jq -cn --argjson id "$id" --argjson result "${CODEX_ACCOUNT_RESULT:-null}" '{id: $id, result: ($result // {account: {}})}' ;;
    account/rateLimits/read)
      jq -cn --argjson id "$id" --argjson limits "$CODEX_RATE_LIMITS" --argjson credits "${CODEX_RESET_CREDITS:-null}" \
        '{id: $id, result: {rateLimits: $limits, rateLimitResetCredits: $credits}}' ;;
  esac
done
'''

# The limits name the plan themselves, so an account/read that never answers
# costs nothing: it isn't asked.
new_home(ANSWERS)
started = time.monotonic()
record = codex(env={"CODEX_ACCOUNT_READ_HANGS": 1, "CODEX_RATE_LIMITS": '{"planType":"pro","primary":{"usedPercent":36,"windowDurationMins":10080}}'})
elapsed = time.monotonic() - started
expect("Codex reads limits naming their plan without waiting on account/read", {
  "tier": record["tierLabel"], "status": record["usageStatusText"], "limits": [[entry["label"], entry["percent"]] for entry in record["limits"]], "quick": elapsed < 1.8,
}, {"tier": "Pro 200", "status": "", "limits": [["Weekly (7-day)", 0.36]], "quick": True}, record)

# Free full resets ride along: only available ones count, and the soonest to
# lapse is the one worth mentioning.
record = codex(env={"CODEX_RATE_LIMITS": '{"planType":"pro","primary":{"usedPercent":42,"windowDurationMins":10080}}',
                    "CODEX_RESET_CREDITS": json.dumps({"availableCount": 2, "credits": [
                      {"status": "available", "expiresAt": 2000000000}, {"status": "available", "expiresAt": 1900000000}, {"status": "used", "expiresAt": 1800000000}]})})
expect("Codex reports its available free resets", record.get("resetCredits"), {"available": 2, "nextExpiresAt": "2030-03-17T17:46:40+00:00"}, record)

# Credits and account/read are extras: a malformed one loses itself, never
# the limits already read, which stay live.
for name, credits in (("milliseconds", {"credits": [{"status": "available", "expiresAt": 1900000000000}]}), ("a list", [1]),
                      ("a number", {"credits": 3}), ("a string", "lots")):
  record = codex(env={"CODEX_RATE_LIMITS": '{"planType":"pro","primary":{"usedPercent":42,"windowDurationMins":10080}}',
                      "CODEX_RESET_CREDITS": json.dumps(credits)})
  expect(f"Codex keeps its limits live when the reset credits are {name}", {
    "status": record["usageStatusText"], "stale": record["limitsStale"], "limits": [[entry["label"], entry["percent"]] for entry in record["limits"]],
  }, {"status": "", "stale": False, "limits": [["Weekly (7-day)", 0.42]]}, record)
for name, answer in (("a list", [1]), ("a string account", {"account": "pro"})):
  record = codex(env={"CODEX_RATE_LIMITS": '{"primary":{"usedPercent":42,"windowDurationMins":10080}}', "CODEX_ACCOUNT_RESULT": json.dumps(answer)})
  expect(f"Codex keeps its limits when account/read answers {name}", {
    "tier": record["tierLabel"], "status": record["usageStatusText"], "stale": record["limitsStale"],
    "limits": [[entry["label"], entry["percent"]] for entry in record["limits"]],
  }, {"tier": "", "status": "", "stale": False, "limits": [["Weekly (7-day)", 0.42]]}, record)

# A Business seat with a spend cap and no rate windows reports the cap alone,
# its share taken from the amounts; a zero cap takes the reported percentage.
new_home()
record = codex(env={"CODEX_RATE_LIMITS": '{"planType":"business","primary":null,"secondary":null,"individualLimit":{"limit":"6000","used":"1037.07","remainingPercent":83,"resetsAt":1793491200}}'})
check("Codex reports a Business spend cap with its own reset time",
      [entry["label"] for entry in record["limits"]] == ["Spend limit"] and abs(record["limits"][0]["percent"] - 1037.07 / 6000) < 1e-6
      and record["limits"][0]["resetsAt"] == "2026-11-01T00:00:00+00:00", record)
record = codex(env={"CODEX_RATE_LIMITS": '{"planType":"business","individualLimit":{"limit":"0","used":"0","remainingPercent":40,"resetsAt":1793491200}}'})
expect("Codex takes the reported percentage when the spend cap is zero",
       [entry["percent"] for entry in record["limits"] if entry["label"] == "Spend limit"], [0.6], record)

# A home nobody is signed in to answers with an error, which reads as a
# sign-in to restore rather than as missing numbers.
record = codex(env={"CODEX_FAKE": "auth"})
expect("Codex reports a missing sign-in as one", record["usageStatusText"], "Waiting for auth", record)

# The app-server batches notifications with replies in one write: a reply
# sharing a write must not be stranded in a read buffer, and bytes left from
# one request carry into the next.
new_home(r'''
while read -r request; do
  id=$(jq -r '.id // empty' <<<"$request")
  case "$(jq -r '.method // empty' <<<"$request")" in
    initialize)
      printf '%s\n%s\n' "$(jq -cn --argjson id "$id" '{id: $id, result: {}}')" '{"method":"remoteControl/status/changed","params":{"status":"disabled"}}' ;;
    account/rateLimits/read)
      printf '%s\n%s\n' '{"method":"account/updated","params":{"authMode":"chatgpt","planType":"plus"}}' \
        "$(jq -cn --argjson id "$id" '{id: $id, result: {rateLimits: {planType: "plus", primary: {usedPercent: 5, windowDurationMins: 300, resetsAt: 1790659194}}}}')" ;;
  esac
done
''')
record = codex()
expect("Codex reads replies batched with notifications", {
  "tier": record["tierLabel"], "status": record["usageStatusText"], "limits": [[entry["label"], entry["percent"]] for entry in record["limits"]],
}, {"tier": "Plus", "status": "", "limits": [["5h window", 0.05]]}, record)

# Without temporary space the probe still runs, only without Codex's error
# text.
new_home()
real_temporary_file = tempfile.TemporaryFile


def no_space(*args, **kwargs):
  raise OSError(28, "No space left on device")


tempfile.TemporaryFile = no_space
try:
  record = codex()
finally:
  tempfile.TemporaryFile = real_temporary_file
expect("Codex probes without temporary space", [entry["percent"] for entry in record["limits"]], [0.4, 0.7], record)

# The lazy launcher at ~/.local/bin/codex runs `mise use -g`, installing
# Codex, so a read-only probe on a machine without it must never run it, nor a
# mise shim, which is a symlink to mise itself. `mise which` only names a
# binary already installed, which is probed; a symlink at the launcher's path
# is the user's own binary, probed without asking mise.
LAUNCHER = "export MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet \"npm:@openai/codex\" || exit 1\nexec mise x \"npm:@openai/codex\" -- codex \"$@\"\n"


def mise(answer=None):
  echo = f'echo "{answer}"\n' if answer else "exit 1\n"
  return stub(home() / "bin" / "mise", f'printf \'%s\\n\' "$*" >>"{home()}/mise-calls"\n' + echo)


def mise_calls():
  path = home() / "mise-calls"
  return path.read_text().splitlines() if path.exists() else []


new_home(None, auth="empty", path=TOOLS)
stub(home() / ".local" / "bin" / "codex", LAUNCHER)
mise()
record = codex("--limits-only")
expect("Codex never runs the lazy launcher, asking only `mise which`, and says its limits are unavailable",
       [record["usageStatusText"], mise_calls() in ([], ["which codex"])], ["Codex limits unavailable", True], record)

shutil.copy(FAKE_CODEX, home() / "real-codex")
mise(home() / "real-codex")
(home() / "mise-calls").unlink(missing_ok=True)
codex("--limits-only", env={"CODEX_ARGS_FILE": home() / "codex-args"})
expect("Codex probes the binary `mise which` names", [(home() / "codex-args").exists(), mise_calls()], [True, ["which codex"]])

new_home(None, auth="empty", path=TOOLS)
(home() / ".local" / "bin").mkdir(parents=True)
(home() / ".local" / "bin" / "codex").symlink_to(FAKE_CODEX)
mise(home() / "real-codex")
codex("--limits-only", env={"CODEX_ARGS_FILE": home() / "codex-args"})
expect("Codex probes a symlink at the launcher's path without asking mise", [(home() / "codex-args").exists(), mise_calls()], [True, []])

new_home(None, auth=False, path=TOOLS)
shim = mise()
(home() / ".local" / "share" / "mise" / "shims").mkdir(parents=True)
(home() / ".local" / "share" / "mise" / "shims" / "codex").symlink_to(shim)
record = codex("--limits-only")
expect("Codex never runs a mise shim, and says its limits are unavailable",
       [record["usageStatusText"], mise_calls() in ([], ["which codex"])], ["Codex limits unavailable", True], record)

# Without credentials account/read can only fail, and starting the app-server
# isn't free (it syncs the plugin list, a git fetch each time), so it isn't
# started. An API key alone doesn't sign it in, but a CODEX_ACCESS_TOKEN does,
# and so does a store outside auth.json, read as TOML; an explicit file store
# with no auth.json is still signed out.
new_home(auth=False)


def probed(config=None, **env):
  config_file = home() / ".codex" / "config.toml"
  if config is None:
    config_file.unlink(missing_ok=True)
  else:
    config_file.write_text(config)
  (home() / "codex-args").unlink(missing_ok=True)
  record = codex("--limits-only", env={"CODEX_ARGS_FILE": home() / "codex-args", **env})
  return (home() / "codex-args").exists(), record


started_bare, record = probed()
expect("Codex waits for a sign-in without starting the app-server when there are no credentials",
       [started_bare, record["usageStatusText"]], [False, "Waiting for auth"], record)
expect("Codex starts the app-server for a token or a store outside auth.json, and not for an API key or an empty file store", {
  "apiKey": probed(OPENAI_API_KEY="x")[0],
  "token": probed(CODEX_ACCESS_TOKEN="x")[0],
  "keyring": probed('cli_auth_credentials_store = "keyring"\n')[0],
  "singleQuoted": probed("model = \"gpt-5\"\ncli_auth_credentials_store = 'keyring'\n")[0],
  "fileStore": probed('model = "gpt-5"\ncli_auth_credentials_store = "file"\n')[0],
}, {"apiKey": False, "token": True, "keyring": True, "singleQuoted": True, "fileStore": False})

# An app-server that fails says why in the CLI's own words, never as a bare
# RPC method name: one rejecting its arguments, one closing its output during
# startup, one closing its input after initialize, one saying nothing (the
# login hint), one stalled (named as a stall, its logging no reason), and one
# logging plenty before its final error.
shebang, fake_body = FAKE_CODEX.read_text().split("\n", 1)
noisy = stub(Path(os.environ["SANDBOX"]) / "noisy-codex", f"{shebang}\nimport sys\nprint('WARN codex_core: startup notice', file=sys.stderr, flush=True)\n{fake_body}")
failures = {
  "rejected": ("echo \"error: invalid value 'untrusted' for '--ask-for-approval <APPROVAL_POLICY>'\" >&2\necho '  [possible values: on-request, never]' >&2\nexit 2\n", {}),
  "dead": ("exec 1>&-\nexec sleep 30\n", {}),
  "half": ("read -r request\nexec 0<&-\njq -cn --argjson id \"$(jq -r '.id' <<<\"$request\")\" '{id: $id, result: {}}'\nexec sleep 30\n", {}),
  "silent": (FAKE_CODEX, {"CODEX_FAKE": "silent"}),
  "stalled": (FAKE_CODEX, {"CODEX_FAKE": "stall"}),
  "noisy": (noisy, {"CODEX_FAKE": "stall"}),
  "chatty": ("for i in {1..20}; do echo \"WARN codex_core::config: ignoring unknown key number $i\" >&2; done\necho 'error: failed to start app-server' >&2\nexit 1\n", {}),
}
help_texts = {}
for name, (body, env) in failures.items():
  new_home(body)
  record = codex("--limits-only", env=env, quick=True)
  help_texts[name] = [record["usageStatusText"], record["authHelpText"]]
expect("Codex explains a failed app-server in its own words", {
  "rejected": help_texts["rejected"][0] == "Codex limits unavailable" and "invalid value 'untrusted'" in help_texts["rejected"][1],
  "dead": help_texts["dead"][1],
  "half": help_texts["half"][1],
  "silent": help_texts["silent"][1],
  "stalled": help_texts["stalled"][1],
  "noisy": help_texts["noisy"][1],
  "chatty": help_texts["chatty"][1].startswith("codex app-server exited: ") and help_texts["chatty"][1].endswith("error: failed to start app-server"),
}, {
  "rejected": True,
  "dead": "Codex app-server exited before initialize",
  "half": "Codex app-server exited before initialized",
  "silent": "Run `codex login` to authenticate.",
  "stalled": "Codex app-server did not answer account/rateLimits/read",
  "noisy": "Codex app-server did not answer account/rateLimits/read",
  "chatty": True,
}, help_texts)

# ------------------------------------------------ openai_base_url's owner

# A built-in rollout answered by a model not OpenAI's is Codex's on OpenAI's
# API and nobody's behind a gateway nothing can place, so switching
# openai_base_url between the two must not leave a reused scan counting it,
# as a real rollout with its model renamed showed.
new_home()
rollout("rollout-2026-10-22T11-00-00-01a1647f-6fb5-7081-a481-257bbb530940.jsonl",
        meta(id="01a1647f-6fb5-7081-a481-257bbb530940", originator="codex_exec", source="exec", model_provider="openai", cli_version="0.163.0"),
        context("qwen3-coder"), typed(), tokens(65105, 3250, cached=566656))
(home() / ".codex" / "config.toml").write_text('openai_base_url = "https://api.openai.com/v1"\n')
on_openai = codex("--limits-only")["todayTokensByModel"]
(home() / ".codex" / "config.toml").write_text('openai_base_url = "https://gateway.example.com/v1"\n')
on_gateway = codex("--limits-only")["todayTokensByModel"]
expect("a reused scan stops counting a non-OpenAI model once openai_base_url moves from OpenAI's API to a gateway",
       ["qwen3-coder" in on_openai, "qwen3-coder" in on_gateway], [True, False], [on_openai, on_gateway])

# ---------------------------------------------------------------- contract

new_home()


def add_rollout():
  add_rollout.count = getattr(add_rollout, "count", 0) + 1
  rollout(f"grown-{add_rollout.count}.jsonl", context("gpt-test"), tokens(10, 1))


check_scan_cache(Adapter("codex", grow=add_rollout, pi_root=lambda: home() / ".pi" / "agent" / "sessions"))
PY
