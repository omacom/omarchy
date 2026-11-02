#!/bin/bash

# The Qwen Code collector's own sources: its chat transcripts, read the way
# Qwen Code's own statistics read them, where QWEN_HOME, QWEN_RUNTIME_DIR and
# settings.json put them, the per-transcript index, and the pi, omp and
# opencode turns on Alibaba's Qwen plan provider ids. The unused-machine
# record and exactly-once counting across collectors are held by the
# partition test, and the scan cache by the contract check. Neither Qwen Code
# nor Alibaba publishes a way to read a plan's quota, so there is no limits
# contract to hold.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

# The checks below compare today's totals with rows stamped NOW.
freeze_today()
NOW = fixture_now().isoformat(timespec="milliseconds").replace("+00:00", "Z")
TWO_DAYS_AGO = (fixture_now() - timedelta(days=2)).isoformat(timespec="milliseconds").replace("+00:00", "Z")


def qwen(*args):
  return collect("qwen", *(args or ("--force",)))


def prompt(uuid, session, timestamp, subtype=None):
  line = {"uuid": uuid, "parentUuid": None, "sessionId": session, "timestamp": timestamp, "type": "user", "message": {"role": "user", "parts": [{"text": "hi"}]}}
  if subtype:
    line["subtype"] = subtype
  return line


# One billed answer, as Qwen Code logs it: a ui_telemetry api_response event.
def response(uuid, session, timestamp, model, auth, input, output, cached, thoughts, response_id="", total=0):
  event = {"event.name": "qwen-code.api_response", "event.timestamp": timestamp, "response_id": response_id, "model": model, "auth_type": auth,
           "input_token_count": input, "output_token_count": output, "cached_content_token_count": cached, "thoughts_token_count": thoughts, "total_token_count": total}
  return {"uuid": uuid, "sessionId": session, "timestamp": timestamp, "type": "system", "subtype": "ui_telemetry", "systemPayload": {"uiEvent": event}}


def transcript(path, lines, mode="w"):
  path = Path(path)
  path.parent.mkdir(parents=True, exist_ok=True)
  with path.open(mode) as handle:
    for line in lines:
      handle.write((line if isinstance(line, str) else json.dumps(line)) + "\n")
  return path


def chats(project="p"):
  return home() / ".qwen" / "projects" / project / "chats"


# Qwen Code sends an OpenAI-compatible reply to OPENAI_BASE_URL, else to
# OpenAI's API, its default. The checks that aren't about routes run Qwen Code
# pointed at Model Studio, as from the shell it was started in.
def studio():
  sandbox()
  os.environ["OPENAI_BASE_URL"] = "https://dashscope-intl.aliyuncs.com/compatible-mode/v1"


# A machine that never ran Qwen Code has no local stats to show.
sandbox()
record = qwen()
expect("Qwen with no usage says it has no local stats", [record["ready"], record["hasLocalStats"]], [False, False], record)

# ------------------------------------------------------------- transcripts

studio()
transcript(chats("-home-me-app") / "s1.jsonl", [
  prompt("u1", "s1", NOW),
  response("r1", "s1", NOW, "qwen3-coder-plus", "qwen-oauth", 1000, 200, 600, 50, "resp-1"),
  prompt("u2", "s1", NOW, "mid_turn_user_message"),
  # Goal and notification records are not typed prompts.
  prompt("u3", "s1", NOW, "goal_runtime"),
  # A provider that reports only the cached part reported a fully cached prompt.
  response("r3", "s1", NOW, "qwen3-coder-plus", "openai", 0, 5, 80, 0, "resp-3"),
  # Gemini's API is Google's, not a Qwen plan's, and so is the prompt it
  # answers.
  prompt("u5", "s1", NOW),
  response("r2", "s1", NOW, "gemini-2.5-pro", "gemini", 300, 40, 0, 10, "resp-2"),
  {"uuid": "x", "type": "system", "subtype": "ui_telemetry", "systemPayload": {"uiEvent": {"event.name": "qwen-code.tool_call", "model": "m"}}},
  {"uuid": "y", "type": "assistant", "model": "qwen3-coder-plus", "usageMetadata": {"promptTokenCount": 999}},
])
earlier = [prompt("u4", "s2", TWO_DAYS_AGO), response("r4", "s2", TWO_DAYS_AGO, "qwen3-coder-plus", "openai", 70, 7, 0, 3, "resp-4")]
transcript(chats("-home-me-app") / "s2.jsonl", earlier)
# A branched session carries the records it was branched from.
transcript(chats("-home-me-app") / "s3.jsonl", earlier)
transcript(chats("-home-me-app") / "s1.ledger.jsonl", [{"uuid": "l", "type": "user", "sessionId": "s1", "timestamp": NOW}])

record = qwen()
two_days_ago = (fixture_now().astimezone() - timedelta(days=2)).strftime("%Y-%m-%d")
expect("Qwen counts typed prompts and billed responses once each, booked on the day each arrived", {
  "name": record["name"],
  "counts": {key: record[key] for key in ("ready", "hasPromptStats", "todayPrompts", "todaySessions", "todayTotalTokens", "totalPrompts", "totalSessions", "activeDays")},
  "two days ago": next(day["messageCount"] for day in record["recentDays"] if day["date"] == two_days_ago),
}, {
  "name": "Qwen Code",
  "counts": {"ready": True, "hasPromptStats": True, "todayPrompts": 2, "todaySessions": 1, "todayTotalTokens": 1285, "totalPrompts": 3, "totalSessions": 2, "activeDays": 2},
  "two days ago": 77,
}, record)
expect("Qwen reads tokens the way Qwen Code's own statistics do", record["modelUsage"], {
  "qwen3-coder-plus": {"inputTokens": 470, "outputTokens": 212, "cacheReadInputTokens": 680, "cacheCreationInputTokens": 0},
}, record)

# Qwen Code 0.26.0's records through the Responses API, whose output_tokens
# already include reasoning_tokens, with and without a total, and a record
# kept without its auth type, with a total: thinking the total already holds
# in the output counts once.
studio()
transcript(chats() / "r.jsonl", [
  prompt("u1", "r", NOW),
  response("r1", "r", NOW, "qwen-resp-model", "openai-responses", 5234, 55, 75, 5, "resp_mock5", total=5289),
  response("r2", "r", NOW, "qwen-resp-model", "openai-responses", 6234, 56, 76, 5, "resp_mock6"),
  response("r3", "r", NOW, "qwen3-coder-plus", "", 300, 40, 0, 10, "resp-g1", total=350),
  response("r4", "r", NOW, "qwen3-coder-plus", "", 300, 40, 0, 10, "resp-g2", total=340),
])
record = qwen()
expect("Qwen counts a Responses API reply's reasoning once, and other thinking only outside its total", {
  model: usage["outputTokens"] for model, usage in record["modelUsage"].items()
}, {"qwen-resp-model": 111, "qwen3-coder-plus": 90}, record)

# Qwen Code 0.26.0's records from two sessions against a server that recycles
# response ids: each got chatcmpl-mock1208 and chatcmpl-mock1209 for replies
# of the same size, a minute apart. Both count. --fork-session copies a
# record verbatim, its uuid included, under the new session with a
# forkedFrom, and that copy counts once, in the session that wrote it, though
# the fork's file name sorts first; the fork counts for the prompt typed into
# it.
studio()
first = [
  prompt("8b0e5c1a-6f4d-4a0e-9a51-3c0f1b6c2d10", "f73baca5-d3d4-4eb9-8008-20dc4951f613", NOW),
  response("8f4c3a4e-5876-4c73-9356-6507b21f70ea", "f73baca5-d3d4-4eb9-8008-20dc4951f613", NOW, "qwen-sp-model", "openai", 9312, 58, 78, 0, "chatcmpl-mock1208", total=9370),
  response("28ac483b-350e-45aa-9286-486a3964925a", "f73baca5-d3d4-4eb9-8008-20dc4951f613", NOW, "qwen-sp-model", "openai", 10313, 59, 79, 0, "chatcmpl-mock1209", total=10372),
]
transcript(chats("-home-me-proj-qwen10") / "f73baca5-d3d4-4eb9-8008-20dc4951f613.jsonl", first)
transcript(chats("-home-me-proj-qwen11") / "61cea1b3-8fa7-433b-b69c-cce255da2433.jsonl", [
  prompt("4e2b7d90-1c3a-4f55-8e6b-7a9d0c1e2f34", "61cea1b3-8fa7-433b-b69c-cce255da2433", NOW),
  response("0c2fb936-82a9-4a54-9d94-7c043a11b674", "61cea1b3-8fa7-433b-b69c-cce255da2433", NOW, "qwen-sp-model", "openai", 9312, 58, 78, 0, "chatcmpl-mock1208", total=9370),
  response("d7f750d2-72ec-47ef-82a1-9e1400e2c289", "61cea1b3-8fa7-433b-b69c-cce255da2433", NOW, "qwen-sp-model", "openai", 10313, 59, 79, 0, "chatcmpl-mock1209", total=10372),
])
branched = [{**line, "sessionId": "9d1e4b27-3f6a-4c08-b5e2-0a7c8d9e1f23", "forkedFrom": {"sessionId": line["sessionId"], "messageUuid": line["uuid"]}} for line in first]
transcript(chats("-home-me-proj-qwen10") / "9d1e4b27-3f6a-4c08-b5e2-0a7c8d9e1f23.jsonl", [
  *branched,
  prompt("6bcf502c-f7ae-46ec-882c-721ccc6ca9a3", "9d1e4b27-3f6a-4c08-b5e2-0a7c8d9e1f23", NOW),
  response("4b804879-1b4d-45b5-a2d6-81ef1ee79f4b", "9d1e4b27-3f6a-4c08-b5e2-0a7c8d9e1f23", NOW, "qwen-sp-model", "openai", 4314, 46, 0, 0, "chatcmpl-mock1210", total=4360),
])
record = qwen()
expect("Qwen counts different replies a server gave the same response id, and a forked copy once, in its source session", {
  key: record[key] for key in ("todayTotalTokens", "todayPrompts", "todaySessions")
}, {"todayTotalTokens": 2 * (9370 + 10372) + 4360, "todayPrompts": 3, "todaySessions": 3}, record)

# ------------------------------------------------------------------ routes

# A reply counts where it was billed. Qwen Code records only its auth type,
# and settings.json's modelProviders the base URL each model is sent to:
# Alibaba's hosts are Qwen's, OpenRouter's or a self-hosted server's are
# theirs, and Anthropic's API, which Qwen Code reaches with --auth-type
# anthropic, is no Qwen plan, nor OpenAI's, where Qwen Code sends a model no
# route or OPENAI_BASE_URL places. Each prompt goes with the reply that
# answered it. Shaped as Qwen Code 0.26.0 wrote them against a mock of each
# API.
sandbox()
write_json(home() / ".qwen" / "settings.json", {"modelProviders": {"openai": [
  {"id": "qwen3-coder-plus", "baseUrl": "https://coding-intl.dashscope.aliyuncs.com/v1", "envKey": "BAILIAN_CODING_PLAN_API_KEY"},
  {"id": "qwen/qwen3-coder", "baseUrl": "https://openrouter.ai/api/v1", "envKey": "OPENROUTER_API_KEY"},
  {"id": "local-qwen", "baseUrl": "http://127.0.0.1:18083/v1"},
]}})
transcript(chats() / "routes.jsonl", [
  prompt("u1", "routes", NOW),
  response("r1", "routes", NOW, "qwen3-coder-plus", "openai", 1234, 51, 71, 5, "chatcmpl-mock1", total=1285),
  prompt("u2", "routes", NOW),
  response("r2", "routes", NOW, "claude-mock-model", "anthropic", 7234, 57, 77, 0, "msg_mock7", total=7291),
  prompt("u3", "routes", NOW),
  response("r3", "routes", NOW, "qwen/qwen3-coder", "openai", 5000, 50, 0, 0, "chatcmpl-or"),
  prompt("u4", "routes", NOW),
  response("r4", "routes", NOW, "local-qwen", "openai", 3000, 30, 0, 0, "chatcmpl-local"),
  prompt("u5", "routes", NOW),
  response("r5", "routes", NOW, "qwen-unlisted", "openai", 100, 10, 0, 0, "chatcmpl-default"),
])
record = qwen()
expect("Qwen counts the replies Alibaba billed, with their prompts, and leaves other providers' out",
       [sorted(record["modelUsage"]), record["todayPrompts"], record["todayTotalTokens"]],
       [["qwen3-coder-plus"], 1, 1285], record)
local = collect("local", "--force")
expect("Local counts the Qwen Code replies sent to a self-hosted server",
       [local["todayTokensByModel"], local["todayPrompts"]], [{"local-qwen": 3030}, 1], local)


# A request no reply answered, as Qwen Code logs it: a ui_telemetry api_error
# event naming the model and auth type it was sent with.
def failed(uuid, session, timestamp, model, auth, execution):
  event = {"event.name": "qwen-code.api_error", "event.timestamp": timestamp, "response_id": "", "execution_id": execution, "model": model, "duration_ms": 2990,
           "prompt_id": f"{session}########0", "auth_type": auth, "error_message": "Connection error. (cause: connect ECONNREFUSED 127.0.0.1:18499)", "error_type": "APIConnectionError"}
  return {"uuid": uuid, "sessionId": session, "timestamp": timestamp, "type": "system", "subtype": "ui_telemetry", "systemPayload": {"uiEvent": event}}


# A prompt no reply answered goes where its requests were sent, else where
# settings.json's selected model goes: a server you run that refused them all
# is local's, not Qwen's. Shaped as Qwen Code 0.26.0 wrote a run against a
# dead port on a modelProviders route.
sandbox()
write_json(home() / ".qwen" / "settings.json", {
  "modelProviders": {"openai": [{"id": "qwen-dead-model", "name": "dead", "baseUrl": "http://127.0.0.1:18499/v1", "envKey": "MOCK_QWEN_KEY"},
                                {"id": "qwen3-coder-plus", "baseUrl": "https://coding-intl.dashscope.aliyuncs.com/v1"}]},
  "security": {"auth": {"selectedType": "openai"}},
  "model": {"name": "qwen-dead-model"},
})
transcript(chats() / "93e3e301.jsonl", [
  prompt("f5316beb", "93e3e301", NOW),
  failed("1e40dc03", "93e3e301", NOW, "qwen-dead-model", "openai", "cb1ab8b5"),
  failed("a76f1d2f", "93e3e301", NOW, "qwen-dead-model", "openai", "0746ab80"),
])
transcript(chats() / "plan.jsonl", [prompt("p1", "plan", NOW), failed("p2", "plan", NOW, "qwen3-coder-plus", "openai", "e1")])
# Typed, and stopped before any request: the selected model's route decides.
transcript(chats() / "bare.jsonl", [prompt("b1", "bare", NOW)])
records = {cid: collect(cid, "--force") for cid in ("qwen", "local")}
expect("a Qwen Code prompt no reply answered counts where its route goes",
       {cid: [record["todayPrompts"], record["todaySessions"], record["todayTotalTokens"]] for cid, record in records.items()},
       {"qwen": [1, 1, 0], "local": [2, 2, 0]}, records)

# A scan answers only for the routes it was made under: a route moved after
# it is reflected at once, even on a --limits-only run. As Qwen Code 0.26.0
# wrote a run against a server of the user's own.
def env_run():
  sandbox()
  transcript(chats() / "env.jsonl", [
    prompt("54ccea9a", "env", NOW),
    response("e1", "env", NOW, "qwen-env-model", "openai", 6309, 55, 75, 0, "chatcmpl-mock405", total=6364),
    response("e2", "env", NOW, "qwen-env-model", "openai", 7310, 56, 76, 0, "chatcmpl-mock406", total=7366),
  ])


env_run()
write_json(home() / ".qwen" / "settings.json", {"modelProviders": {"openai": [{"id": "qwen-env-model", "baseUrl": "http://127.0.0.1:18491/v1"}]}})
expect("Qwen leaves out a reply its route sends to a server of the user's own", collect("qwen")["todayTotalTokens"], 0)
write_json(home() / ".qwen" / "settings.json", {"modelProviders": {"openai": [{"id": "qwen-env-model", "baseUrl": "https://coding-intl.dashscope.aliyuncs.com/v1"}]}})
expect("a Qwen scan made before a modelProviders route moved is not reused after it", collect("qwen", "--limits-only")["todayTotalTokens"], 13730)

# A model no modelProviders route names is sent where OPENAI_BASE_URL (or
# ANTHROPIC_BASE_URL) says, which Qwen Code takes from the first .env file
# setting it (its home's, then ~/.env), else from settings.json's env, else
# from the security.auth.baseUrl /auth saved.
env_run()
ENV_ROUTES = [
  ("~/.qwen/.env", lambda: (home() / ".qwen" / ".env").write_text("OPENAI_API_KEY=sk-dummy\nexport OPENAI_BASE_URL=\"http://127.0.0.1:18491/v1\"  # mock\nOPENAI_MODEL=qwen-env-model\n"), "local"),
  ("~/.env", lambda: (home() / ".env").write_text("OPENAI_BASE_URL=http://127.0.0.1:18491/v1\n"), "local"),
  ("settings.json env", lambda: write_json(home() / ".qwen" / "settings.json", {"env": {"OPENAI_BASE_URL": "http://192.168.1.20:8000/v1"}}), "local"),
  ("security.auth.baseUrl", lambda: write_json(home() / ".qwen" / "settings.json", {"security": {"auth": {"selectedType": "openai", "baseUrl": "http://127.0.0.1:18491/v1"}}}), "local"),
  ("settings.json env, OpenRouter", lambda: write_json(home() / ".qwen" / "settings.json", {"env": {"OPENAI_BASE_URL": "https://openrouter.ai/api/v1"}}), None),
  ("settings.json env, Model Studio", lambda: write_json(home() / ".qwen" / "settings.json", {"env": {"OPENAI_BASE_URL": "https://dashscope-intl.aliyuncs.com/compatible-mode/v1"}}), "qwen"),
  # The first .env file wins over settings.json's env.
  ("~/.qwen/.env over settings.json env", lambda: ((home() / ".qwen" / ".env").write_text("OPENAI_BASE_URL=http://127.0.0.1:18491/v1\n"),
   write_json(home() / ".qwen" / "settings.json", {"env": {"OPENAI_BASE_URL": "https://dashscope-intl.aliyuncs.com/compatible-mode/v1"}})), "local"),
]


def clear_routes():
  for path in (home() / ".qwen" / ".env", home() / ".env", home() / ".qwen" / "settings.json"):
    path.unlink(missing_ok=True)


for where, configure, owner in ENV_ROUTES:
  clear_routes()
  configure()
  records = {cid: collect(cid, "--force") for cid in ("qwen", "local")}
  expect(f"a Qwen Code reply sent where {where} says counts under {owner or 'nobody'}",
         {cid: [record["todayTotalTokens"], record["todayPrompts"]] for cid, record in records.items()},
         {cid: [13730, 1] if cid == owner else [0, 0] for cid in records}, records)

# A .env route set after a scan is reflected at once too.
clear_routes()
expect("Qwen leaves out an OpenAI-compatible reply with no route, which went to OpenAI's API", collect("qwen")["todayTotalTokens"], 0)
(home() / ".qwen" / ".env").write_text("OPENAI_BASE_URL=https://dashscope-intl.aliyuncs.com/compatible-mode/v1\n")
expect("a Qwen scan made before a .env route is not reused after it", collect("qwen", "--limits-only")["todayTotalTokens"], 13730)

# --------------------------------------------------------- untrusted fields

studio()
transcript(chats() / "s.jsonl", [
  prompt("bad1", "s", "yesterday-ish"),
  prompt("bad2", "s", "2999-01-01T00:00:00Z"),
  response("bad3", "s", NOW, "m", "openai", "100", True, float("nan"), -5, "a"),
  response("bad4", "s", NOW, "m", "openai", 1e30, 0, 0, 0, "b"),
  response("ok1", "s", NOW, "m", "openai", 10, 2, 0, 0, "c"),
  prompt("bad5", "s", "\u00b2"),
  # A line nested deeper than the parser will go.
  "[" * 100000 + '"user"',
])
with (chats() / "s.jsonl").open("a") as torn:
  torn.write('{"uuid":"z","type":"user","timestamp":')
record = qwen()
expect("Qwen skips bad times, bad token fields, a line nested too deep, and a torn last line",
       [record["todayPrompts"], record["todayTotalTokens"]], [0, 12], record)

# A record with no time is dated once, by the transcript's time as it is
# read, so it isn't today's again on every day after.
studio()
undated = transcript(chats() / "u.jsonl", [prompt("nt1", "u", None), response("nt2", "u", None, "m", "openai", 10, 2, 0, 0, "nt")])
three_days_ago = time.time() - 3 * 86400
os.utime(undated, (three_days_ago, three_days_ago))
record = qwen()
expect("an undated record is dated by its transcript, once",
       [record["todayPrompts"], record["todayTotalTokens"], record["totalPrompts"], record["activeDates"]],
       [0, 0, 1, [datetime.fromtimestamp(three_days_ago).strftime("%Y-%m-%d")]], record)

# ---------------------------------------------------------------- locations

studio()
transcript(home() / "runtime" / "projects" / "p" / "chats" / "s.jsonl", [response("a", "s", NOW, "m", "openai", 1, 0, 0, 0, "ra")])
transcript(home() / "qhome" / "projects" / "p" / "chats" / "s.jsonl", [response("b", "s", NOW, "m", "openai", 10, 0, 0, 0, "rb")])
transcript(chats() / "s.jsonl", [response("c", "s", NOW, "m", "openai", 100, 0, 0, 0, "rc")])
os.environ.update(QWEN_HOME=str(home() / "qhome"), QWEN_RUNTIME_DIR=str(home() / "runtime"))
record = qwen()
del os.environ["QWEN_HOME"], os.environ["QWEN_RUNTIME_DIR"]
expect("Qwen honors QWEN_HOME and QWEN_RUNTIME_DIR", record["todayTotalTokens"], 11, record)

write_json(home() / ".qwen" / "settings.json", {"advanced": {"runtimeOutputDir": "~/out"}})
transcript(home() / "out" / "projects" / "p" / "chats" / "s.jsonl", [response("d", "s", NOW, "m", "openai", 1000, 0, 0, 0, "rd")])
record = qwen()
expect("Qwen reads the runtimeOutputDir from settings.json", record["todayTotalTokens"], 1100, record)

# A runtimeOutputDir no path can name is no place to look.
write_json(home() / ".qwen" / "settings.json", {"advanced": {"runtimeOutputDir": "/\u0000x"}})
record = qwen()
expect("Qwen ignores a runtimeOutputDir holding a NUL", record["todayTotalTokens"], 100, record)

# ------------------------------------------------- Qwen plans in pi and opencode

# pi, omp and opencode turns on Alibaba's Qwen plans count beside Qwen Code's
# own transcripts: every plan id once, and nothing on a pay-as-you-go key, a
# custom gateway that only starts with a plan's name, or a bare `qwen`.
studio()
PLAN_IDS = ["alibaba-coding-plan", "alibaba-coding-plan-cn", "alibaba-token-plan", "alibaba-token-plan-cn",
            "qwen-token-plan", "qwen-token-plan-cn", "qwen-token-plan-individual", "qwen-portal"]
OTHER_IDS = ["alibaba", "alibaba-cn", "alibaba-coding-plan-proxy", "qwen", "dashscope"]
transcript(chats() / "s.jsonl", [prompt("u", "s", NOW), response("r", "s", NOW, "qwen3-coder-plus", "openai", 1, 0, 0, 0, "rq")])
write_pi_session(home() / ".pi" / "agent" / "sessions" / "p" / "pi.jsonl",
                 [pi_reply(provider, 10 ** index, id=f"pi-{provider}", model=f"pi/{provider}") for index, provider in enumerate(PLAN_IDS[:4])]
                 + [pi_reply(provider, 7, id=f"pi-{provider}", model="other") for provider in OTHER_IDS])
write_pi_session(home() / ".omp" / "agent" / "sessions" / "p" / "omp.jsonl",
                 [pi_reply(provider, 10 ** index, id=f"omp-{provider}", model=f"omp/{provider}") for index, provider in enumerate(PLAN_IDS[4:], 4)])
opencode_db(message=[(f"m-{provider}", "oc1", oc_v1(provider, 3, model=f"oc-{provider}")) for provider in PLAN_IDS + OTHER_IDS],
            session_message=[("v2-coding", "oc2", "assistant", oc_v2("alibaba-coding-plan", 5, model="qwen3-coder-next"))])
record = qwen()
expect("Qwen counts every Qwen plan id from pi, omp and opencode once, beside its own transcripts", {
  "tokens": record["todayTotalTokens"],
  "models": sorted(record["modelUsage"]),
  "prompts": record["todayPrompts"],
  "sessions": record["todaySessions"],
}, {
  "tokens": 1 + sum(10 ** index for index in range(len(PLAN_IDS))) + 3 * len(PLAN_IDS) + 5,
  "models": sorted(["qwen3-coder-plus", "qwen3-coder-next"] + PLAN_IDS + [f"oc-{provider}" for provider in PLAN_IDS]),
  "prompts": 1 + len(PLAN_IDS) + len(PLAN_IDS) + 1,
  "sessions": 5,
}, record)
# Qwen plan usage alone makes the tab: there is no quota to wait on a
# sign-in for, so the status stays empty and no meters show.
sandbox()
opencode_db(session_message=[("only", "oc", "assistant", oc_v2("qwen-portal", 5))])
record = qwen()
expect("Qwen shows Qwen plan usage without Qwen Code transcripts or a sign-in",
       [record["ready"], record["usageStatusText"], record["authHelpText"], record["limits"], record["todayTotalTokens"]],
       [True, "", "", [], 5], record)

# ---------------------------------------------------------------- contract

studio()


def add_response():
  add_response.count = getattr(add_response, "count", 0) + 1
  transcript(chats() / "s.jsonl", [response(f"g{add_response.count}", "s", fixture_now().isoformat(), "m", "openai", 5, 0, 0, 0, f"rg{add_response.count}")], mode="a")


check_scan_cache(Adapter("qwen", grow=add_response))

# The transcript index reads only what was appended, and starts over when the
# file is replaced, even by a longer one.
others = qwen()["todayTotalTokens"]
transcript(chats() / "t.jsonl", [response("a", "t", NOW, "m", "openai", 10, 0, 0, 0, "ra"), response("b", "t", NOW, "m", "openai", 5, 0, 0, 0, "rb")])
expect("Qwen reads a new transcript", qwen()["todayTotalTokens"] - others, 15)
transcript(chats() / "t.jsonl", [response("c", "t", NOW, "m", "openai", 20, 0, 0, 0, "rc")], mode="a")
expect("Qwen picks up lines appended to a transcript", qwen()["todayTotalTokens"] - others, 35)
replacement = transcript(chats() / "t.new", [response(name, "t", NOW, "m", "openai", tokens, 0, 0, 0, f"r{name}") for name, tokens in zip("defg", (1, 2, 3, 4))])
replacement.rename(chats() / "t.jsonl")
expect("Qwen rereads a transcript that was replaced", qwen()["todayTotalTokens"] - others, 10)

# A scan that couldn't read every transcript isn't cached.
transcript(chats() / "s.jsonl", [response("h", "s", NOW, "m", "openai", 5, 0, 0, 0, "rh")], mode="a")
(chats() / "s.jsonl").chmod(0)
try:
  if os.access(chats() / "s.jsonl", os.R_OK):
    print("ok - Qwen does not cache a scan that could not read every transcript # SKIP running as root")
  else:
    for path in scan_cache_files("qwen"):
      path.unlink()
    with contextlib.redirect_stderr(io.StringIO()):
      qwen()
    check("Qwen does not cache a scan that could not read every transcript", not scan_cache_files("qwen"),
          ", ".join(path.name for path in scan_cache_files("qwen")))
finally:
  (chats() / "s.jsonl").chmod(0o644)
PY
