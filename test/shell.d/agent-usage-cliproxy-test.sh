#!/bin/bash

# The CLIProxyAPI collector's own sources: the management key and URL it is
# configured with, and the auth-files answer, whose quota signals are the
# rate-limit headers the proxy kept per account. The unused-machine record is
# held centrally by the partition test, and the limits cache by the contract
# checks.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

SESSION_RESET = int(time.time()) + 3600
WEEKLY_RESET = int(time.time()) + 3 * 86400


def claude_file(name="claude-a.json", email="a@example.com", session="0.42", weekly="0.17", **extra):
  signals = {
    "Anthropic-Ratelimit-Unified-5h-Utilization": session,
    "Anthropic-Ratelimit-Unified-5h-Reset": str(SESSION_RESET),
    "Anthropic-Ratelimit-Unified-7d-Utilization": weekly,
    "Anthropic-Ratelimit-Unified-7d-Reset": str(WEEKLY_RESET),
  }
  return {"id": name, "provider": "claude", "email": email, "label": email, "disabled": False, "quota": {"signals": signals}, **extra}


def codex_file(name="codex-b.json", email="b@example.com", plan="pro"):
  signals = {
    "X-Codex-Plan-Type": plan,
    "X-Codex-Primary-Used-Percent": "100",
    "X-Codex-Primary-Window-Minutes": "300",
    "X-Codex-Primary-Reset-At": str(SESSION_RESET),
    "X-Codex-Secondary-Used-Percent": "62",
    "X-Codex-Secondary-Window-Minutes": "10080",
    "X-Codex-Secondary-Reset-At": str(WEEKLY_RESET),
  }
  return {"id": name, "provider": "codex", "email": email, "label": email, "disabled": False, "quota": {"signals": signals}}


service = {"files": [claude_file()]}
ROUTES = {"/v0/management/auth-files": lambda request: {"files": service["files"]}}


def configured(url=None, key="mgmt-key"):
  write_json(config_home() / "omarchy" / "agents" / "cliproxy.json", {"managementKey": key, **({"url": url} if url else {})})


def cliproxy(mode="up"):
  with FakeHttp(ROUTES, mode=mode) as http:
    record = collect("cliproxy", "--force")
  cliproxy.requests = http.requests
  return record


def windows(limits):
  return [[entry["label"], entry["percent"]] for entry in limits]


# ---------------------------------------------------------------- contract

sandbox()
fresh = check_limits_contract(Adapter("cliproxy", plant=configured, answer=ROUTES))
expect("one Claude account reads as the section's own session and weekly windows",
       [fresh["tierLabel"], windows(fresh["limits"]), fresh["hasPromptStats"], fresh["hasLocalStats"], "accounts" in fresh],
       ["Claude", [["Session", 0.42], ["Weekly", 0.17]], False, False, False], fresh)
expect("the windows reset when Anthropic said they would",
       [entry["resetsAt"] for entry in fresh["limits"]],
       [datetime.fromtimestamp(SESSION_RESET, timezone.utc).isoformat(), datetime.fromtimestamp(WEEKLY_RESET, timezone.utc).isoformat()], fresh)

# --------------------------------------------------------------- the answer

# Several accounts are listed by name, none active, each with its own
# windows: Codex's percentages over windows it names the length of, and its
# plan as Codex names it. Disabled accounts and providers that keep no quota
# signals are left out, and an account no request has used shows no windows.
service["files"] = [
  claude_file(),
  codex_file(),
  claude_file("claude-off.json", "off@example.com", disabled=True),
  {"id": "gemini-c.json", "provider": "gemini", "email": "c@example.com"},
  {"id": "claude-new.json", "provider": "claude", "email": "new@example.com", "quota": {"signals": {}}},
]
record = cliproxy()
expect("each enabled Claude and Codex account is listed with its own windows, none active",
       [[account["label"], account["plan"], account["active"], windows(account["limits"])] for account in record["accounts"]],
       [["a@example.com", "Claude", False, [["Session", 0.42], ["Weekly", 0.17]]],
        ["b@example.com", "Codex Pro 200", False, [["Session", 1.0], ["Weekly", 0.62]]],
        ["new@example.com", "Claude", False, []]], record)
expect("several accounts leave the section's own limits empty", [record["ready"], record["limits"], "accountSwitch" in record], [True, [], False], record)

# Untrusted values from the proxy never cost the record.
service["files"] = [claude_file(session="NaN", weekly="7"), "junk", {"provider": "claude"}]
record = cliproxy()
expect("an unreadable utilization reads 0 and one past full reads full", windows(record["limits"]), [["Session", 0.0], ["Weekly", 1.0]], record)

# A proxy with no Claude or Codex account has nothing to show.
service["files"] = [{"id": "gemini-c.json", "provider": "gemini"}]
expect("a proxy without Claude or Codex accounts gives an unused record", cliproxy()["ready"], False)
service["files"] = [claude_file()]

# ---------------------------------------------------------------- the key

# The key goes to the configured proxy, as a bearer token.
sandbox()
configured("https://proxy.example.ts.net:8317/")
cliproxy()
expect("the management key is asked of the configured URL as a bearer token",
       [(request["url"], request["headers"]["authorization"]) for request in cliproxy.requests],
       [("https://proxy.example.ts.net:8317/v0/management/auth-files", "Bearer mgmt-key")])

# Plain HTTP to another machine would carry the key in the clear: nothing is
# sent, and the section says why.
configured("http://192.168.1.20:8317")
record = cliproxy()
expect("a key is never sent over plain HTTP to another machine",
       [len(cliproxy.requests), record["ready"], record["usageStatusText"]], [0, True, "CLIProxyAPI limits unavailable"], record)

# Without a key nothing says the machine uses a proxy.
sandbox()
record = cliproxy()
expect("without a management key the record is unused and nothing is asked", [record["ready"], len(cliproxy.requests)], [False, 0], record)
PY
