#!/bin/bash

# The Kimi collector's local stats: the wire.jsonl Kimi Code 2.x keeps for
# each agent of a session under its home (KIMI_CODE_HOME, else ~/.kimi-code),
# with a usage.record for every model request and a turn.prompt for every
# typed prompt, read once each though a fork copies its source's records.
# The records below are shaped as a real Kimi Code 2.3.0 run wrote them. The
# limits are held by agent-usage-kimi-regression-test.sh, and the scan cache
# by the contract check.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

freeze_today()
NOW_MS = int(datetime.fromisoformat(today_stamp()).timestamp() * 1000)
TWO_DAYS_AGO_MS = NOW_MS - 2 * 86400 * 1000
WORKSPACE = "wd_proj-kimi_82e7a3eee59c"


def kimi(*args):
  return collect("kimi", *(args or ("--force",)))


# A machine that never ran Kimi Code has no local stats to show, and nor does
# a Kimi home with no session in it.
sandbox()
record = kimi()
(home() / ".kimi-code").mkdir()
in_use = kimi()
expect("Kimi with no sessions says it has no local stats",
       [record["ready"], record["hasLocalStats"], in_use["ready"], in_use["hasLocalStats"]], [False, False, True, False], in_use)


def prompt(text, prompt_id, at, origin=None, kind="turn.prompt"):
  line = {"type": kind, "agentId": "main", "input": [{"type": "text", "text": text}], "origin": origin or {"kind": "user"}, "turnId": 0, "time": at}
  line["promptId" if kind == "turn.prompt" else "messageId"] = prompt_id
  return line


def usage(at, input_other, output, cache_read, cache_creation=0, model="mock/kimi-k2", scope="turn", agent="main"):
  return {"type": "usage.record", "agentId": agent, "model": model,
          "usage": {"inputOther": input_other, "output": output, "inputCacheRead": cache_read, "inputCacheCreation": cache_creation},
          "usageScope": scope, "time": at}


# One answered prompt, as Kimi Code logs it: the prompt, the request's usage,
# and the loop's step.end carrying the same usage, which isn't counted again.
def turn(text, prompt_id, at, input_other, output, cache_read, message_id):
  counts = {"inputOther": input_other, "output": output, "inputCacheRead": cache_read, "inputCacheCreation": 0}
  return [
    prompt(text, prompt_id, at),
    {"type": "context.append_message", "agentId": "main", "message": {"role": "user", "content": [{"type": "text", "text": text}], "id": prompt_id, "toolCalls": [], "origin": {"kind": "user"}}, "time": at},
    {"type": "context.append_message", "agentId": "main", "message": {"role": "user", "content": [{"type": "text", "text": "<system-reminder>date</system-reminder>"}], "toolCalls": [], "origin": {"kind": "injection", "variant": "date_change"}}, "time": at},
    {"type": "llm.request", "agentId": "main", "kind": "loop", "provider": "openai", "model": "kimi-k2", "modelAlias": "mock/kimi-k2", "time": at},
    usage(at + 35, input_other, output, cache_read),
    {"type": "context.append_loop_event", "agentId": "main", "event": {"type": "step.end", "turnId": "0", "step": 1, "finishReason": "end_turn", "usage": counts, "messageId": message_id}, "time": at + 37},
    {"type": "agent.message.appended", "message": {"meta": {"source": "llm", "usage": counts, "messageId": message_id}}, "time": at + 37, "kind": "event"},
    {"type": "turn.ended", "agentId": "main", "turnId": 0, "reason": "completed", "time": at + 38},
  ]


# Where the runs below sent mock/kimi-k2, unless a test says otherwise: a
# provider of Kimi's type with no base_url, Moonshot's own API.
MOCK_CONFIG = """[providers.mock]
type = "kimi"
api_key = "sk-test-dummy"

[models."mock/kimi-k2"]
provider = "mock"
model = "kimi-k2"
max_context_size = 131072
"""


def wire(session, lines, agent="main", root=None):
  config = (root or home() / ".kimi-code") / "config.toml"
  if not config.exists():
    config.parent.mkdir(parents=True, exist_ok=True)
    config.write_text(MOCK_CONFIG)
  path = (root or home() / ".kimi-code") / "sessions" / WORKSPACE / session / "agents" / agent / "wire.jsonl"
  path.parent.mkdir(parents=True, exist_ok=True)
  with path.open("a") as handle:
    if path.stat().st_size == 0:
      handle.write(json.dumps({"type": "metadata", "protocol_version": "1.5", "created_at": NOW_MS}) + "\n")
    for line in lines:
      handle.write((line if isinstance(line, str) else json.dumps(line)) + "\n")
  return path


# ------------------------------------------------------------ Kimi Code runs

sandbox()
wire("session_745e630c", turn("Say hi kimi one", "msg_01M5HQ7K1Y0EDFNMS0NRAH3PRD", NOW_MS, 1163, 51, 71, "chatcmpl-mock1"))
wire("session_2a051e63", turn("Say hi kimi two", "msg_01M5HQ7KMCT3DNQ9MJVCBKR52Z", NOW_MS + 600, 2162, 52, 72, "chatcmpl-mock2"))
record = kimi()
expect("Kimi counts Kimi Code's prompts, sessions and request usage from its wire logs", {
  key: record[key] for key in ("ready", "hasLocalStats", "hasPromptStats", "todayPrompts", "todaySessions", "todayTotalTokens", "totalPrompts", "totalSessions", "modelUsage")
}, {
  "ready": True, "hasLocalStats": True, "hasPromptStats": True, "todayPrompts": 2, "todaySessions": 2, "todayTotalTokens": 3571, "totalPrompts": 2, "totalSessions": 2,
  "modelUsage": {"mock/kimi-k2": {"inputTokens": 3325, "outputTokens": 103, "cacheReadInputTokens": 143, "cacheCreationInputTokens": 0}},
}, record)
check("Kimi's local stats are this machine's, not the account's", "scope" not in record, record)
expect("with no sign-in the limits still wait for one", record["usageStatusText"], "Waiting for auth", record)

# A compaction's request is billed too, and a subagent logs its own requests
# to its own wire; only what someone typed is a prompt, slash commands
# included, while injections, a subagent's task and shell commands are not.
sandbox()
wire("session_a", [
  *turn("refactor it", "msg_a1", NOW_MS, 1000, 100, 0, "m1"),
  prompt("also tests", "msg_a2", NOW_MS + 100, kind="turn.steer"),
  prompt("/review", "msg_a3", NOW_MS + 200, origin={"kind": "skill_activation", "trigger": "user-slash"}),
  prompt("ls", "msg_a4", NOW_MS + 300, origin={"kind": "shell_command", "phase": "input"}),
  prompt("compacted", "msg_a5", NOW_MS + 400, origin={"kind": "compaction_summary"}),
  usage(NOW_MS + 500, 400, 40, 0, 10, scope="session"),
  usage(TWO_DAYS_AGO_MS, 7, 3, 0, model="kimi-code/kimi-for-coding"),
])
wire("session_a", [
  {**prompt("look around", "msg_sub1", NOW_MS + 50, origin={"kind": "agent"}), "agentId": "agent-0"},
  usage(NOW_MS + 60, 300, 30, 0, agent="agent-0"),
], agent="agent-0")
record = kimi()
two_days_ago = (fixture_now().astimezone() - timedelta(days=2)).strftime("%Y-%m-%d")
expect("Kimi counts every billed request, subagents' and compactions' too, and only typed prompts", {
  "today": [record["todayPrompts"], record["todaySessions"], record["todayTotalTokens"]],
  "two days ago": next(day["messageCount"] for day in record["recentDays"] if day["date"] == two_days_ago),
  "models": sorted(record["modelUsage"]),
}, {"today": [3, 1, 1880], "two days ago": 10, "models": ["kimi-code/kimi-for-coding", "mock/kimi-k2"]}, record)

# A request counts where it was billed. Each usage.record names its model
# alias, and config.toml where that alias goes: the Kimi Code plan /login
# provisions is Kimi's, as is an alias the config doesn't name (KIMI_MODEL_NAME
# makes one up for a run), a server you run is the local collector's, and an
# Anthropic-type provider or a gateway nobody's here, a Claude model on a
# local proxy included. A prompt goes with the request that answered it.
# Shaped as Kimi Code 2.3.0 wrote them, `kimi -m anth/claude-via-kimi -p`
# included.
sandbox()
(home() / ".kimi-code").mkdir()
(home() / ".kimi-code" / "config.toml").write_text("""default_model = "kimi-code/kimi-for-coding"

[providers."managed:kimi-code"]
type = "kimi"
base_url = "https://api.kimi.com/coding/v1"
api_key = ""

[models."kimi-code/kimi-for-coding"]
provider = "managed:kimi-code"
model = "kimi-for-coding"
max_context_size = 262144

[providers.mock]
type = "kimi"
base_url = "http://127.0.0.1:18472/v1"
api_key = "sk-test-dummy"

[models."mock/kimi-k2"]
provider = "mock"
model = "kimi-k2"
max_context_size = 131072

[providers.anth]
type = "anthropic"
base_url = "http://127.0.0.1:18491"
api_key = "sk-ant-dummy-kimi"

[models."anth/claude-via-kimi"]
provider = "anth"
model = "claude-via-kimi"
max_context_size = 131072

[providers.claude]
type = "anthropic"
api_key = "sk-ant-dummy"

[models."claude/opus"]
provider = "claude"
model = "claude-opus-4-1"
max_context_size = 200000

[providers.gateway]
type = "openai"
base_url = "https://llm.acme.example/v1"
api_key = "sk-acme"

[models."gateway/k2"]
provider = "gateway"
model = "kimi-k2"
max_context_size = 131072
""")
wire("session_routes", [
  prompt("plan", "msg_r1", NOW_MS),
  usage(NOW_MS + 10, 1000, 10, 0, model="kimi-code/kimi-for-coding"),
  prompt("local", "msg_r2", NOW_MS + 20),
  usage(NOW_MS + 30, 2162, 52, 72, model="mock/kimi-k2"),
  prompt("anthropic", "msg_r3", NOW_MS + 40),
  usage(NOW_MS + 50, 11234, 60, 80, 40, model="anth/claude-via-kimi"),
  usage(NOW_MS + 60, 5000, 50, 0, model="claude/opus"),
  usage(NOW_MS + 70, 4000, 40, 0, model="gateway/k2"),
  prompt("env", "msg_r4", NOW_MS + 80),
  usage(NOW_MS + 90, 100, 1, 0, model="env-model"),
  prompt("unanswered", "msg_r5", NOW_MS + 100),
])
record = kimi()
expect("Kimi counts only the requests Kimi billed, with their prompts", [record["todayTokensByModel"], record["todayPrompts"]],
       [{"kimi-code/kimi-for-coding": 1010, "env-model": 101}, 3], record)
local = collect("local", "--force")
expect("Local counts the Kimi Code requests a server you run answered, and their prompts",
       [local["todayTokensByModel"], local["todayPrompts"]], [{"mock/kimi-k2": 2286}, 1], local)

# A prompt no request answered goes where its requests were sent, answered or
# not, else where its agent was bound: a server you run that refused every
# attempt is local's, and Kimi's own plan Kimi's. Shaped as Kimi Code 2.3.0
# wrote `kimi -m dead/kimi-dead -p` against a dead port, retries and all.
sandbox()
(home() / ".kimi-code").mkdir()
(home() / ".kimi-code" / "config.toml").write_text("""[providers."managed:kimi-code"]
type = "kimi"
base_url = "https://api.kimi.com/coding/v1"

[models."kimi-code/kimi-for-coding"]
provider = "managed:kimi-code"
model = "kimi-for-coding"

[providers.dead]
type = "kimi"
base_url = "http://127.0.0.1:18499/v1"
api_key = "sk-test-dummy-dead"

[models."dead/kimi-dead"]
provider = "dead"
model = "kimi-dead"
max_context_size = 131072
""")


def failed_turn(alias, prompt_id, at, attempts=2):
  lines = [{"type": "profile.bind", "agentId": "main", "modelAlias": alias, "profileName": "agent", "thinkingEffort": "off", "systemPrompt": "You are Kimi Code CLI"}, prompt("hi", prompt_id, at)]
  for step in range(1, attempts + 1):
    lines += [
      {"type": "llm.request", "agentId": "main", "kind": "loop", "provider": "openai", "model": alias.split("/")[-1], "modelAlias": alias, "turnStep": f"0.{step}", "time": at + step},
      {"type": "context.append_loop_event", "agentId": "main", "event": {"type": "step.end", "turnId": "0", "step": step, "finishReason": "error"}, "time": at + step},
    ]
  return lines + [{"type": "turn.ended", "agentId": "main", "turnId": 0, "reason": "failed", "error": {"code": "provider.connection_error", "message": "Connection error.", "name": "APIConnectionError", "retryable": True}, "time": at + 9}]


wire("session_dead", failed_turn("dead/kimi-dead", "msg_01M5J2C56CQXYMM9KX3ABF4D0H", NOW_MS))
wire("session_plan", failed_turn("kimi-code/kimi-for-coding", "msg_p", NOW_MS))
# Bound to the dead server, and stopped before any request.
wire("session_bound", failed_turn("dead/kimi-dead", "msg_b", NOW_MS, attempts=0))
records = {cid: collect(cid, "--force") for cid in ("kimi", "local")}
expect("a Kimi Code prompt no request answered counts where its route goes",
       {cid: [record["todayPrompts"], record["todaySessions"], record["todayTotalTokens"]] for cid, record in records.items()},
       {"kimi": [1, 1, 0], "local": [2, 2, 0]}, records)

# Kimi Code sends nothing on an alias config.toml doesn't name, so one
# missing from it was removed since: a provider's, which nothing can place
# any more and counts nowhere, prompts included, or one of the plan's
# kimi-code/ models, which stays Kimi's. KIMI_MODEL_NAME's alias, never
# saved, is Kimi's too. Shaped as Kimi Code 2.3.0 wrote `kimi -m
# dead/kimi-dead -p` against a dead port and a tool loop on mock2/kimi-tool,
# both providers then deleted from config.toml.
sandbox()
(home() / ".kimi-code").mkdir()
(home() / ".kimi-code" / "config.toml").write_text('default_model = "kimi-code/kimi-for-coding"\n')
wire("session_dead", failed_turn("dead/kimi-dead", "msg_01M5J2C56CQXYMM9KX3ABF4D0H", NOW_MS))
wire("session_bound", failed_turn("dead/kimi-dead", "msg_b", NOW_MS, attempts=0))
wire("session_tool", [prompt("TOOLLOOP read note.txt", "msg_t1", NOW_MS), usage(NOW_MS + 10, 24702, 120, 0, model="mock2/kimi-tool")])
wire("session_plan", [prompt("plan", "msg_p1", NOW_MS), usage(NOW_MS + 10, 1000, 10, 0, model="kimi-code/kimi-k2.5")])
wire("session_env", [prompt("env", "msg_e1", NOW_MS), usage(NOW_MS + 10, 100, 1, 0, model="__kimi_env_model__")])
records = {cid: collect(cid, "--force") for cid in ("kimi", "local")}
expect("a removed Kimi Code provider counts nowhere, while the plan's dropped models and KIMI_MODEL_NAME's stay Kimi's",
       {cid: [record["todayPrompts"], record["todaySessions"], record["todayTokensByModel"]] for cid, record in records.items()},
       {"kimi": [2, 2, {"kimi-code/kimi-k2.5": 1010, "__kimi_env_model__": 101}], "local": [0, 0, {}]}, records)

# A fork copies its source's wire, then marks it forked; the copies count
# once, under the source's session, while what the fork did after counts too.
# A fork with nothing of its own is no session of its own.
sandbox()
source = turn("start", "msg_s1", NOW_MS, 1000, 100, 0, "s1")
wire("session_f", source)
wire("session_0", [*source, {"type": "forked", "agentId": "main", "time": NOW_MS + 1000}, *turn("branch", "msg_f1", NOW_MS + 2000, 50, 5, 0, "f1")])
wire("session_1", [*source, {"type": "forked", "agentId": "main", "time": NOW_MS + 1000}])
record = kimi()
expect("Kimi counts a fork's copies of its source once, and what the fork added",
       [record["totalPrompts"], record["totalSessions"], record["todayTotalTokens"]], [2, 2, 1155], record)

# KIMI_CODE_HOME moves Kimi Code's home, and the default one isn't read then.
sandbox()
wire("session_default", turn("hi", "msg_d", NOW_MS, 1, 1, 0, "d"))
moved = home() / "kimi moved"
wire("session_moved", turn("hi", "msg_m", NOW_MS, 10, 1, 0, "m"), root=moved)
os.environ["KIMI_CODE_HOME"] = str(moved)
record = kimi()
del os.environ["KIMI_CODE_HOME"]
expect("Kimi reads the wire logs under KIMI_CODE_HOME", record["todayTotalTokens"], 11, record)

# --------------------------------------------------------- untrusted fields

sandbox()
wire("session_bad", [
  usage(NOW_MS, "100", True, -5),
  usage(NOW_MS + 1, 1e30, 0, 0),
  usage(NOW_MS + 2, float("nan"), 0, 0),
  usage(0, 1000, 0, 0),
  usage("yesterday", 1000, 0, 0),
  {**usage(NOW_MS + 3, 1000, 0, 0), "time": None},
  {**usage(NOW_MS + 4, 1000, 0, 0), "model": ["m"]},
  {**usage(NOW_MS + 5, 1000, 0, 0), "usage": [1000]},
  prompt("hi", "msg_bad", 0),
  prompt("hi", "msg_bad2", NOW_MS, origin="user"),
  usage(NOW_MS + 6, 10, 2, 0),
  # A line nested deeper than the parser will go.
  "[" * 100000 + '"usage.record"',
])
with wire("session_bad", []).open("a") as torn:
  torn.write('{"type":"usage.record","agentId":"main","model":"mock/kimi-k2","usage":{"inputOther":')
record = kimi()
expect("Kimi skips bad counts, bad times and models, a line nested too deep, and a torn last line",
       [record["todayPrompts"], record["todayTotalTokens"]], [0, 12], record)

# A wire that can't be read leaves the others counted, and that scan isn't
# cached.
sandbox()
wire("session_ok", turn("hi", "msg_ok", NOW_MS, 10, 2, 0, "ok"))
(home() / ".kimi-code" / "sessions" / WORKSPACE / "session_broken" / "agents" / "main" / "wire.jsonl").mkdir(parents=True)
with contextlib.redirect_stderr(io.StringIO()):
  record = kimi()
expect("an unreadable wire leaves the rest counted", record["todayTotalTokens"], 12, record)
check("a scan that couldn't read every wire isn't cached", not scan_cache_files("kimi"))

# Claude Code pointed at Kimi's or Moonshot's API is Kimi's; with no endpoint,
# only a Kimi model's reply is. That usage alone puts Kimi in use here, with
# no sign-in to ask for its limits.
sandbox()
claude_code_session("k", [("kimi-k2-0905", 300), ("moonshot-v1-8k", 20), ("claude-sonnet-4-5", 40)])
record = kimi()
expect("Kimi counts Claude Code's Kimi and Moonshot replies, and waits for a sign-in on them alone",
       [record["todayTokensByModel"], record["todayPrompts"], record["ready"], record["usageStatusText"]],
       [{"kimi-k2-0905": 300, "moonshot-v1-8k": 20}, 2, True, "Waiting for auth"], record)
claude_code_session("k", [("kimi-for-coding", 300), ("claude-sonnet-4-5", 40)], base_url="https://api.kimi.com/coding/")
record = kimi()
expect("Kimi counts every Claude Code reply while Claude Code is pointed at Kimi Code",
       [record["todayTokensByModel"], record["todayPrompts"]], [{"kimi-for-coding": 300, "claude-sonnet-4-5": 40}, 2], record)

# pi, omp and opencode on the Kimi Code plan count here: pi's own
# `kimi-coding` provider and models.dev's `kimi-code-plan-global` and
# `kimi-code-plan-cn`, and so does Moonshot's pay-as-you-go API. A gateway
# named like one of them doesn't.
sandbox()
write_pi_session(home() / ".pi" / "agent" / "sessions" / "project" / "pi.jsonl", [
  {"type": "message", "id": "u1", "timestamp": today_stamp(), "message": {"role": "user", "content": "hi"}},
  pi_reply("kimi-coding", 300, id="k1", model="k3", api="openai-completions"),
  pi_reply("moonshotai", 999, id="m1", model="kimi-k2.6"),
  pi_reply("kimi-coding-proxy", 999, id="p1", model="k3"),
])
opencode_db(message=[
  ("msg_1", "ses_1", oc_v1("kimi-code-plan-global", 200, model="kimi-for-coding")),
  ("msg_2", "ses_1", oc_v1("kimi-code-plan-cn", 20, model="kimi-for-coding-highspeed")),
  ("msg_3", "ses_1", oc_v1("moonshotai-cn", 999, model="kimi-k2.6")),
])
record = kimi()
expect("Kimi counts pi and opencode on the Kimi Code plan ids and Moonshot's pay-as-you-go API",
       [record["todayTokensByModel"], record["ready"], record["usageStatusText"]],
       [{"k3": 300, "kimi-k2.6": 1998, "kimi-for-coding": 200, "kimi-for-coding-highspeed": 20}, True, "Waiting for auth"], record)

# A route change reaches the cached scan at once, even on the panel's
# --limits-only refresh that otherwise reuses a scan for minutes: the request
# on Moonshot's API was Kimi's, and once config.toml sends its alias to a
# server you run, it is not. Shaped as Kimi Code 2.3.0 wrote a tool loop on
# that alias.
sandbox()
(home() / ".kimi-code").mkdir()
(home() / ".kimi-code" / "config.toml").write_text('[providers.mock2]\ntype = "kimi"\n\n[models."mock2/kimi-tool"]\nprovider = "mock2"\nmodel = "kimi-tool"\n')
wire("session_tool", [prompt("TOOLLOOP read note.txt", "msg_t1", NOW_MS), usage(NOW_MS + 10, 24702, 120, 0, model="mock2/kimi-tool")])
before = kimi("--limits-only")
(home() / ".kimi-code" / "config.toml").write_text("""[providers.mock2]
type = "kimi"
base_url = "http://127.0.0.1:18491/v1"

[models."mock2/kimi-tool"]
provider = "mock2"
model = "kimi-tool"
""")
after = kimi("--limits-only")
expect("a Kimi Code route change reaches Kimi's cached scan at once",
       [before["todayTokensByModel"], after["todayTokensByModel"], after["todayPrompts"]], [{"mock2/kimi-tool": 24822}, {}, 0], after)

# ---------------------------------------------------------------- contract

sandbox()


def add_turn():
  add_turn.count = getattr(add_turn, "count", 0) + 1
  wire(f"session_grown_{add_turn.count}", turn("again", f"msg_g{add_turn.count}", NOW_MS + add_turn.count, 10, 1, 0, f"g{add_turn.count}"))


check_scan_cache(Adapter("kimi", grow=add_turn))
PY
