#!/bin/bash

# The Local collector counts the turns that ran on hardware you own: its own
# reading of Codex rollouts and their config.toml, the self-hosted runtimes it
# knows by name, the providers local.json names, and the rows a provider
# collector claims, which it leaves out. How the shared pi and opencode readers
# work, and the unused-machine record, are held centrally by the shared and
# partition tests, and the scan cache by the contract check.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox
require_command rg

python3 - <<'PY'
from agent_usage_fixtures import *

STAMP = today_stamp()


def use_home():
  sandbox()
  os.environ["CODEX_HOME"] = str(home() / ".codex")


# A machine that never ran a self-hosted model has no local stats to show.
use_home()
record = collect("local", "--force")
expect("Local with no usage says it has no local stats", [record["ready"], record["hasLocalStats"]], [False, False], record)


def rollouts():
  return Path(os.environ["CODEX_HOME"]) / "sessions" / datetime.now().strftime("%Y/%m/%d")


# A token_count line for a turn spending 1000 input and 100 output tokens,
# with the session's running total so far.
def token_count(total):
  return {"timestamp": STAMP, "type": "event_msg", "payload": {"type": "token_count", "info": {
    "last_token_usage": {"input_tokens": 1000, "output_tokens": 100, "cached_input_tokens": 0},
    "total_token_usage": {"input_tokens": total},
  }}}


def meta(provider):
  return {"timestamp": STAMP, "type": "session_meta", "payload": {"model_provider": provider}}


def rollout(name, *lines):
  path = rollouts() / f"rollout-{name}.jsonl"
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join(json.dumps(line) + "\n" for line in lines))
  return path


# A prompt as Codex 0.163 writes it in a paginated rollout.
def typed(text="hello"):
  item = {"type": "UserMessage", "id": "u1", "content": [{"type": "text", "text": text, "text_elements": []}]}
  return {"timestamp": STAMP, "type": "event_msg", "payload": {"type": "item_completed", "thread_id": "t1", "turn_id": "turn1", "item": item}}


def context(model):
  return {"timestamp": STAMP, "type": "turn_context", "payload": {"model": model}}


def turn(name, provider, model):
  return rollout(name, meta(provider), context(model), typed(), token_count(1000))


def local_config(*providers):
  write_json(config_home() / "omarchy" / "agents" / "local.json", {"providers": list(providers)})


def local(*args):
  return collect("local", *(args or ("--force",)))


def models(record):
  return sorted(record["modelUsage"])


# ------------------------------------------------------------------ Codex

use_home()
(Path(os.environ["CODEX_HOME"]) / "config.toml").parent.mkdir(parents=True, exist_ok=True)
(Path(os.environ["CODEX_HOME"]) / "config.toml").write_text(
  '[model_providers.homelab]\nbase_url = "http://server.home:11434/v1"\n\n'
  '[model_providers.openrouter]\nbase_url = "https://openrouter.ai/api/v1"\n'
)
homelab = turn("homelab", "homelab", "qwen-net")             # another machine on the LAN
ollama = turn("ollama", "ollama", "qwen-here")               # this machine, a well-known runtime
turn("paid", "openrouter", "claude-paid")                    # a third-party API: neither collector
turn("sub", "openai", "gpt-sub")                             # the Codex subscription
turn("cloud", "ollama", "gpt-oss:120b-cloud")                # Ollama Cloud, through the local daemon
# A quota update repeats the last turn's usage with an unchanged cumulative
# total; a real second turn moves it.
with ollama.open("a") as handle:
  handle.write(json.dumps(token_count(1000)) + "\n" + json.dumps(token_count(2000)) + "\n")
  # A line nested too deep to parse (a RecursionError, not a ValueError)
  # costs only itself.
  handle.write('{"type": "token_count", "info": ' + "[" * 100000 + "\n")
# A fork copies its parent's session_meta after its own; the first decides.
rollout("fork", meta("openai"), meta("ollama"), {"timestamp": STAMP, "type": "turn_context", "payload": {"model": "qwen-forked"}}, token_count(1000))

local_record = collect("local")
expect("Local counts Codex turns on LAN endpoints and known runtimes, nothing else", models(local_record), ["qwen-here", "qwen-net"], local_record)
expect("Local counts a repeated Codex token_count once, and each typed prompt once",
       [local_record["todayTotalTokens"], local_record["modelUsage"]["qwen-here"]["inputTokens"], local_record["todayPrompts"], local_record["ready"]],
       [3300, 2000, 2, True], local_record)

# The Local and Codex collectors split the rollouts between them: the
# subscription's turns are Codex's alone, and no model shows in both.
codex_record = collect("codex", "--force")
expect("Codex keeps the subscription's own rollouts", models(codex_record), ["gpt-sub", "qwen-forked"], codex_record)
expect("Local and Codex never count the same rollout", set(models(local_record)) & set(models(codex_record)), set())

# The cloud-tagged turn Local leaves out is Ollama Cloud's, as Codex's `--oss`
# wrote it: counted there once, with the prompt that asked for it.
with FakeHttp():
  ollama_record = collect("ollama", "--force")
expect("Ollama counts the cloud-tagged Codex rollout Local leaves out",
       [ollama_record["todayTokensByModel"], ollama_record["todayPrompts"], set(models(local_record)) & set(models(ollama_record))],
       [{"gpt-oss": 1100}, 1, set()], ollama_record)

# A rollout is replayed from the per-file cache while its size and mtime stand:
# change its contents but neither, and the old count stays.
stat = homelab.stat()
homelab.write_text(homelab.read_text().replace('"output_tokens": 100', '"output_tokens": 900'))
os.utime(homelab, ns=(stat.st_atime_ns, stat.st_mtime_ns))
replayed = collect("local", "--limits-only")
for path in scan_cache_files("local"):
  path.unlink()
expired = collect("local")
reread = local()
expect("Local replays an unchanged rollout from its file cache, after the scan cache too, and --force rereads it",
       [record["modelUsage"]["qwen-net"]["outputTokens"] for record in (replayed, expired, reread)], [100, 100, 900])

# A provider the heuristics can't see is named in local.json, and takes effect
# without --force, since the classification is part of the scan key.
local_config("mystery")
turn("mystery", "mystery", "qwen-custom")
record = collect("local")
expect("Local counts the providers local.json names", record["modelUsage"].get("qwen-custom", {}).get("inputTokens"), 1000, record)

# A Codex config that isn't UTF-8 names no endpoints, like a missing one, and
# the ones it named before stay remembered.
config = Path(os.environ["CODEX_HOME"]) / "config.toml"
saved = config.read_bytes()
config.write_bytes(b'a = "\xff\xfe"\n')
record = local()
expect("Local reads past a Codex config that isn't UTF-8", models(record), ["qwen-custom", "qwen-here", "qwen-net"], record)
config.write_bytes(saved)

# A provider collector's id is never local, whatever local.json says.
local_config("openrouter", "openai")
record = collect("local")
expect("Local never counts a provider another collector counts", models(record), ["qwen-here", "qwen-net"], record)

# A cache file of the wrong shape is a miss, and a cache that can't be written
# still leaves a record.
for path in scan_cache_files("local"):
  path.write_text("[]")
record = collect("local", "--limits-only")
expect("Local rescans past a scan cache of the wrong shape", models(record), ["qwen-here", "qwen-net"], record)
cache_home = os.environ["XDG_CACHE_HOME"]
(home() / "not-a-dir").write_text("")
os.environ["XDG_CACHE_HOME"] = str(home() / "not-a-dir")
with contextlib.redirect_stderr(io.StringIO()):
  record = collect("local")
os.environ["XDG_CACHE_HOME"] = cache_home
expect("Local still prints its record when the cache can't be written", models(record), ["qwen-here", "qwen-net"], record)

# Prompts are the ones typed, not the requests answering them, each under the
# model that answered it even when a legacy rollout writes it before the
# turn_context: a tool call's two requests are one prompt, Codex's own context
# and a subagent's messages are none, and a cloud model's prompt is no more
# local than its tokens. A subagent naming no thread that started it starts no
# session of its own either.
use_home()
rollout("paginated", meta("ollama"), context("qwen-tools"), typed("run ls"), token_count(1000),
        {"timestamp": STAMP, "type": "event_msg", "payload": {"type": "item_completed", "item": {"type": "CommandExecution", "id": "c1"}}},
        token_count(2000), context("gpt-oss:120b-cloud"), typed("now in the cloud"), token_count(3000))
rollout("legacy", meta("ollama"),
        {"timestamp": STAMP, "type": "event_msg", "payload": {"type": "user_message", "message": "<user_instructions>", "kind": "user_instructions"}},
        {"timestamp": STAMP, "type": "event_msg", "payload": {"type": "user_message", "message": "fix it"}}, context("qwen-legacy"), token_count(1000))
rollout("subagent", {"timestamp": STAMP, "type": "session_meta", "payload": {"model_provider": "ollama", "source": {"subagent": "review"}}},
        context("qwen-review"), typed(), token_count(1000))
record = local()
expect("Local counts the prompts typed, under the model that answered them", {
  "prompts": record["todayPrompts"], "sessions": record["totalSessions"], "models": models(record), "ready": record["ready"],
}, {"prompts": 2, "sessions": 2, "models": ["qwen-legacy", "qwen-review", "qwen-tools"], "ready": True}, record)

# A rollout records its provider's id, never the URL it reached, so a custom
# provider's endpoint is remembered from config.toml: its history stays local
# after the provider leaves the config, as in a real Codex 0.163 run on a
# provider since removed. A profile's <name>.config.toml names providers too.
# One the config never named is still nobody's, and a config that moves an id
# to a hosted URL wins over what was remembered.
use_home()
codex_config = Path(os.environ["CODEX_HOME"]) / "config.toml"
codex_config.parent.mkdir(parents=True, exist_ok=True)
codex_config.write_text('model_provider = "mocklocal"\n\n[model_providers.mocklocal]\nname = "mock"\nbase_url = "http://127.0.0.1:18441/v1"\n'
                        '\n[model_providers.boxed]\nbase_url = "http://192.168.1.20:8000/v1"\n')
turn("mocklocal", "mocklocal", "gpt-5.1-codex")
turn("boxed", "boxed", "qwen-boxed")
turn("unseen", "unseen", "qwen-unseen")
(codex_config.parent / "work.config.toml").write_text('[model_providers.profiled]\nbase_url = "http://gpu-box:8080/v1"\n')
turn("profiled", "profiled", "qwen-profiled")
before = local()
codex_config.write_text('model = "gpt-5.1-codex"\n\n[model_providers.boxed]\nbase_url = "https://api.example.com/v1"\n')
after = local()
expect("Local keeps a custom Codex provider's history after it leaves config.toml", [models(before), models(after)],
       [["gpt-5.1-codex", "qwen-boxed", "qwen-profiled"], ["gpt-5.1-codex", "qwen-profiled"]], after)

# The base URL decides, not the id: a Codex entry under an id another
# collector claims is local's on this machine, as `kimchi codex` writes one
# for a self-hosted Kimchi gateway, and still the claiming collector's
# nowhere else (a real Codex 0.163 run served 10074 tokens there).
use_home()
codex_config = Path(os.environ["CODEX_HOME"]) / "config.toml"
codex_config.parent.mkdir(parents=True, exist_ok=True)
codex_config.write_text('model_provider = "kimchi"\nmodel = "kimi-k2-mock"\n\n[model_providers.kimchi]\nname = "Kimchi Gateway"\n'
                        'base_url = "http://127.0.0.1:18491/openai/v1"\nwire_api = "responses"\n')
turn("kimchi-here", "kimchi", "kimi-k2-mock")
turn("kimchi-cloud", "kimchi", "glm-4.6:cloud")
record = local()
expect("Local counts a Codex entry on this machine whatever collector claims its id, but not a cloud-tagged model",
       models(record), ["kimi-k2-mock"], record)
expect("and the claiming collector doesn't count it too", collect("kimchi", "--force").get("modelUsage") or {}, {})

# Only a turn with no time at all takes the file's day; a time of 0, false or
# "" can't be trusted, so that turn counts nowhere, as in the Codex collector.
use_home()
untimed = dict(token_count(9000))
del untimed["timestamp"]
rollout("falsy", meta("ollama"), {"timestamp": STAMP, "type": "turn_context", "payload": {"model": "qwen-falsy"}},
        *({**token_count(1000 * n), "timestamp": falsy} for n, falsy in enumerate((0, False, ""), 1)), untimed)
record = local()
expect("Local counts a Codex turn with an untrusted time nowhere, and one with none on the file's day",
       [record["todayTotalTokens"], record["modelUsage"].get("qwen-falsy", {}).get("inputTokens")], [1100, 1000], record)

# ------------------------------------------------------------- pi and opencode

# Runtimes known by name, whatever their case, are local; Ollama's cloud
# models and provider, another provider, and pi driving the Codex API are not.
use_home()
codex_api = pi_reply("ollama", 999, id="x", model="gpt-5", api="openai-codex-responses")
write_pi_session(home() / ".pi" / "agent" / "sessions" / "--work--" / "one.jsonl", [
  pi_reply("ollama", 100, id="a", model="qwen3:30b"),
  pi_reply("LMStudio", 200, id="b", model="qwen3:8b"),
  pi_reply("vllm", 300, id="c", model="llama-70b"),
  pi_reply("llamacpp", 40, id="d", model="gemma"),
  pi_reply("ollama", 999, id="e", model="glm-4.6:cloud"),
  pi_reply("ollama-cloud", 999, id="f", model="qwen3:30b"),
  pi_reply("anthropic", 999, id="g", model="claude"),
  codex_api,
])
# opencode: a known runtime, a provider local.json names, and a cloud model.
local_config("homelab")
opencode_db(message=[
  ("m1", "ses_1", oc_v1("ollama", {"input": 100, "output": 10, "reasoning": 5, "cache": {"read": 0, "write": 0}}, model="qwen-oc")),
  ("m2", "ses_1", oc_v1("homelab", 50, model="qwen-cfg")),
  ("m3", "ses_1", oc_v1("ollama", 999, model="kimi-k2:1t-cloud")),
])
record = local()
expect("Local counts pi and opencode replies on self-hosted runtimes and configured providers",
       [record["todayTotalTokens"], models(record)], [805, ["gemma", "llama-70b", "qwen-cfg", "qwen-oc", "qwen3:30b", "qwen3:8b"]], record)

# A local.json naming ids the provider collectors claim leaves only their rows
# out: opencode's google provider and Vertex only on antigravity- models, which
# the agy collector counts, and pi's google rows, which agy never reads, stay
# local's, as does an id no collector matches, like minimax-coding.
use_home()
local_config("google", "google-antigravity", "google-vertex", "minimax-coding")
opencode_db(message=[
  ("m1", "ses_1", oc_v1("google", 10, model="gemini-oc")),
  ("m2", "ses_1", oc_v1("google-vertex", 999, model="antigravity-gemini")),
  ("m3", "ses_1", oc_v1("minimax-coding", 20, model="minimax-gateway")),
], session_message=[
  ("s1", "ses_2", "assistant", oc_v2("google-vertex", 30, model="gemini-vertex")),
])
write_pi_session(home() / ".pi" / "agent" / "sessions" / "--claimed--" / "one.jsonl", [pi_reply("google", 40, id="p", model="antigravity-pi-gemini")])
record = local()
expect("Local leaves out exactly the rows another collector claims",
       [record["todayTotalTokens"], models(record)], [100, ["antigravity-pi-gemini", "gemini-oc", "gemini-vertex", "minimax-gateway"]], record)

# Claude Code pointed at a self-hosted endpoint (Ollama's guide sets
# localhost:11434) ran its models here, but a cloud-tagged one is Ollama's
# and a Claude one went on to Anthropic; with no endpoint, nothing is local.
sandbox()
claude_code_session("box", [("qwen3-coder", 30), ("glm-4.6:cloud", 300), ("claude-sonnet-4-5", 40)])
record = local()
expect("Local counts no Claude Code reply while Claude Code is sent to Anthropic", [record["todayTokensByModel"], record["ready"]], [{}, False], record)
claude_code_session("box", [("qwen3-coder", 30), ("glm-4.6:cloud", 300), ("claude-sonnet-4-5", 40)], base_url="http://localhost:11434")
record = local()
expect("Local counts the Claude Code replies a self-hosted endpoint ran itself",
       [record["todayTokensByModel"], record["todayPrompts"], record["todaySessions"]], [{"qwen3-coder": 30}, 1, 1], record)

# A MiniMax Code custom provider on this machine or the LAN ran its models
# here; one at a gateway nothing can place is nobody's.
sandbox()
mcode_routed_session("box", "custom_provider:box", "qwen-box", 1387, base_url="http://127.0.0.1:18082/anthropic")
mcode_routed_session("lan", "custom_provider:lan", "qwen-lan", 30, base_url="http://gpu-box.lan:8080/v1")
mcode_routed_session("far", "custom_provider:far", "qwen-far", 5, base_url="https://gateway.example.com/v1")
record = local()
expect("Local counts MiniMax Code replies on a self-hosted custom provider, and none elsewhere",
       [record["todayTokensByModel"], record["todayPrompts"], record["todaySessions"]], [{"qwen-box": 1387, "qwen-lan": 30}, 2, 2], record)

# ---------------------------------------------------------------- contract

use_home()


def add_session():
  add_session.count = getattr(add_session, "count", 0) + 1
  write_pi_session(home() / ".pi" / "agent" / "sessions" / f"grown-{add_session.count}.jsonl",
                   [pi_reply("ollama", 10, id=f"grown-{add_session.count}", model="qwen3:8b")])


check_scan_cache(Adapter("local", grow=add_session, pi_root=lambda: home() / ".pi" / "agent" / "sessions"))

# A harness's route config can move its rows onto this machine without its
# store changing, so the cached scan is kept only while every harness still
# classifies the same way, and the match has to survive the cache's JSON.
import collectors as shared  # noqa: E402

sandbox()
local = load_collector("local")
before = local.harness_match()
(home() / ".qwen").mkdir(parents=True, exist_ok=True)
(home() / ".qwen" / ".env").write_text("OPENAI_BASE_URL=http://127.0.0.1:8080/v1\n")
after = local.harness_match()
expect("a harness route change changes local's scan match, which survives JSON",
       [before != after, json.loads(json.dumps(after)) == after], [True, True], after)
real_routes = shared.mcode_routes
shared.mcode_routes = lambda data_dir=None: {"mine": "local", "gateway": "openrouter"}
try:
  routes = shared.mcode_scan_match()
finally:
  shared.mcode_routes = real_routes
expect("MiniMax Code's route match survives the cache's JSON round trip", json.loads(json.dumps(routes)), routes, routes)
PY
