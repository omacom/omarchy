#!/bin/bash

# The MiniMax collector's limits: the Token Plan quota answer and how its
# remaining percentages become used ones, the sign-ins mmx, opencode and pi
# keep, refusals MiniMax names in its answer, and its adapter for the
# contract checks. The unused-machine record is held centrally by the
# partition test, the limits cache's mechanics by the shared test, and the
# scan cache by the scanner test.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

REMAINS = "api.minimax.io/v1/token_plan/remains"


def quota(end_time, weekly_end_time):
  return {
    "model_remains": [
      {"model_name": "general", "end_time": end_time, "current_interval_remaining_percent": 10, "current_interval_status": 1,
       "weekly_end_time": weekly_end_time, "current_weekly_remaining_percent": 69, "current_weekly_status": 1},
      {"model_name": "video", "current_interval_total_count": 0, "current_interval_remaining_percent": 100, "current_interval_status": 3},
    ],
    "base_resp": {"status_code": 0, "status_msg": "success"},
  }


# Windows still open, so a kept copy outlives a failed check.
ANSWER = quota(ms_in(3600), ms_in(86400))


def keyed(key="mmx_test"):
  os.environ["MINIMAX_API_KEY"] = key


def minimax(answer=None, mode="up"):
  with FakeHttp({REMAINS: answer}, mode=mode) as http:
    record = collect("minimax", "--force")
  return record, http


# ---------------------------------------------------------------- contract

sandbox()
fresh = check_limits_contract(Adapter("minimax", plant=keyed, answer={REMAINS: ANSWER}))
expect("MiniMax's Token Plan and windows come from its quota answer",
       [fresh["tierLabel"], [(entry["label"], round(entry["percent"], 2)) for entry in fresh["limits"]]],
       ["Token Plan", [("Session (5-hour)", 0.9), ("Weekly (7-day)", 0.31)]], fresh)

# An answer shaped like nothing expected is still a failed check: the kept
# limits stand.
record, _ = minimax(KeyError("surprise"))
check("MiniMax collector keeps the last limits past an unexpected answer",
      record["usageStatusText"] == "" and record["limitsStale"] is True and record["limits"] == fresh["limits"]
      and "KeyError" in record["authHelpText"], record)

# A bad key MiniMax names in base_resp rather than with a status code.
record, _ = minimax({"base_resp": {"status_code": 1004, "status_msg": "login fail"}})
expect("MiniMax collector reads an authentication failure in base_resp as a refused key",
       [record["usageStatusText"], record["limitsStale"], bool(record.get("retryAdvised"))], ["Sign-in expired", True, False], record)

# Another key never shows this one's numbers, and a failure with nothing kept
# says so; only one that reached no server asks for a retry.
keyed("other")
record, _ = minimax(mode=500)
expect("MiniMax collector keys its limits cache by credential and reports a failure with nothing kept",
       [record["usageStatusText"], record["limits"], record["tierLabel"], bool(record.get("retryAdvised"))],
       ["MiniMax limits unavailable", [], "", False], record)
record, _ = minimax(mode="down")
expect("MiniMax collector advises a retry only when the API can't be reached",
       [record["usageStatusText"], record.get("retryAdvised")], ["MiniMax limits unavailable", True], record)

# The same key in the other region is another account: its cache is kept per
# host, so the China host never shows the global allowance.
keyed()
os.environ["MINIMAX_REGION"] = "cn"
record, http = minimax(mode="down")
del os.environ["MINIMAX_REGION"]
expect("MiniMax collector keeps one key's limits per region",
       [http.requests[0]["url"].startswith("https://api.minimaxi.com/"), record["limits"], record["usageStatusText"]],
       [True, [], "MiniMax limits unavailable"], record)
record, _ = minimax(mode="down")
expect("MiniMax collector still keeps the global host's limits for that key", [record["limits"], record["limitsStale"]], [fresh["limits"], True], record)

# ------------------------------------------------------------- the answer

sandbox()
keyed()
record, http = minimax(quota(1782399600000, 1782691200000))
expect("MiniMax remaining percentages become used fractions, with their resets normalized",
       [(entry["label"], round(entry["percent"], 2), entry["resetsAt"]) for entry in record["limits"]],
       [("Session (5-hour)", 0.9, "2026-06-25T15:00:00+00:00"), ("Weekly (7-day)", 0.31, "2026-06-29T00:00:00+00:00")], record)
expect("MiniMax collector asks with the key as a bearer", http.requests[0]["headers"].get("authorization"), "Bearer mmx_test")

# Without a "general" row the first row that isn't a media model's is the plan.
record, _ = minimax({"model_remains": [
  {"model_name": "video", "current_interval_remaining_percent": 100},
  {"model_name": "Image-01", "current_interval_remaining_percent": 100},
  {"model_name": "MiniMax-M2", "current_interval_remaining_percent": 25},
]})
expect("MiniMax collector skips media quota rows when choosing the plan's row", [entry["percent"] for entry in record["limits"]], [0.75], record)

# Each window's status outranks its percentage, as in mmx and omp: 2 is
# exhausted however much the stale percentage says remains, 3 is unlimited,
# with nothing to fill. A row in mmx's "not in plan" shape (both windows
# unlimited, nothing allotted) is never the plan's row.
record, _ = minimax({"model_remains": [
  {"model_name": "general", "current_interval_total_count": 0, "current_interval_remaining_percent": 100, "current_interval_status": 3,
   "current_weekly_total_count": 0, "current_weekly_remaining_percent": 100, "current_weekly_status": 3},
  {"model_name": "MiniMax-M2", "current_interval_total_count": 1500, "current_interval_remaining_percent": 40, "current_interval_status": 2,
   "current_weekly_total_count": 0, "current_weekly_remaining_percent": 100, "current_weekly_status": 3},
], "base_resp": {"status_code": 0, "status_msg": "success"}})
expect("MiniMax reads an exhausted window as spent, drops an unlimited one, and skips a model outside the plan",
       [(entry["label"], entry["percent"]) for entry in record["limits"]], [("Session (5-hour)", 1.0)], record)

# The bearer never follows a redirect to another host.
elsewhere, stolen = stub_server(lambda request: {"model_remains": []})
origin, _ = stub_server(lambda request: (302, b"", {"Location": elsewhere + "/steal"}))
try:
  load_collector("minimax").fetch_quota("secret", origin)
  error = ""
except Exception as failure:
  error = str(failure)
check("MiniMax collector refuses to follow a redirect with the bearer", stolen == [] and "redirected" in error, error)

# ------------------------------------------------------------ credentials

sandbox()
os.environ["MMX_CONFIG_DIR"] = str(home() / ".mmx")


def credentials():
  return list(load_collector("minimax").credentials())


write_json(home() / ".mmx" / "config.json", {"api_key": "mmx_saved"})
expect("MiniMax credentials use the key mmx saved", credentials(), ["mmx_saved", "https://api.minimax.io"])

write_json(home() / ".mmx" / "config.json", {"oauth": {"access_token": "mmx_oauth", "refresh_token": "refresh", "expires_at": "2099-01-01T00:00:00Z", "region": "cn"}})
expect("MiniMax credentials use the OAuth session and region saved by mmx", credentials(), ["mmx_oauth", "https://api.minimaxi.com"])

# mmx 1.0's own order: base_url, then the OAuth resource_url, then the region,
# with MINIMAX_REGION over the saved one.
write_json(home() / ".mmx" / "config.json", {"base_url": "https://mmx.example", "oauth": {"access_token": "mmx_oauth", "resource_url": "https://resource.example"}})
expect("MiniMax asks mmx's base_url ahead of its OAuth resource_url", credentials(), ["mmx_oauth", "https://mmx.example"])
write_json(home() / ".mmx" / "config.json", {"api_key": "mmx_saved", "region": "cn"})
os.environ["MINIMAX_REGION"] = "global"
expect("MiniMax lets MINIMAX_REGION move mmx's key off the region mmx saved", credentials(), ["mmx_saved", "https://api.minimax.io"])
del os.environ["MINIMAX_REGION"]

(home() / ".mmx" / "config.json").unlink()
opencode = opencode_auth(None, "minimax", "mmx_opencode")
expect("MiniMax credentials use opencode's login", credentials()[0], "mmx_opencode")

# A China-region key pi saved answers on the China host.
opencode.unlink()
pi_auth(None, "minimax-cn", "mmx_pi_cn")
expect("MiniMax credentials use a China-region key pi saved, on the China host", credentials(), ["mmx_pi_cn", "https://api.minimaxi.com"])

# A key answers only on its own region's host, so mmx's region applies to
# mmx's key alone: a key from the environment, opencode or pi signs in where
# its own provider id says.
write_json(home() / ".mmx" / "config.json", {"region": "cn"})
opencode_auth(None, "minimax", "mmx_opencode_global")
expect("MiniMax asks with a global key opencode saved on the global host, whatever region mmx names",
       credentials(), ["mmx_opencode_global", "https://api.minimax.io"])
write_json(home() / ".mmx" / "config.json", {"api_key": "mmx_saved", "region": "cn"})
os.environ["MINIMAX_API_KEY"] = "mmx_env"
expect("MiniMax asks with an exported key on the global host, whatever region mmx names", credentials(), ["mmx_env", "https://api.minimax.io"])
os.environ["MINIMAX_BASE_URL"] = "https://minimax.example"
expect("MiniMax asks MINIMAX_BASE_URL when it is set", credentials(), ["mmx_env", "https://minimax.example"])
del os.environ["MINIMAX_API_KEY"], os.environ["MINIMAX_BASE_URL"]
expect("MiniMax asks with mmx's own key on the host mmx names", credentials(), ["mmx_saved", "https://api.minimaxi.com"])

# Wherever the host comes from, the key never goes over plain HTTP to another
# machine, nor to a URL that isn't one.
for name, setup in (
  ("MINIMAX_BASE_URL", lambda: os.environ.update(MINIMAX_API_KEY="mmx_env", MINIMAX_BASE_URL="http://evil.example")),
  ("mmx's base_url", lambda: write_json(home() / ".mmx" / "config.json", {"api_key": "mmx_saved", "base_url": "http://evil.example"})),
  ("mmx's resource_url", lambda: write_json(home() / ".mmx" / "config.json", {"oauth": {"access_token": "mmx_oauth", "resource_url": "not a url"}})),
):
  setup()
  record, http = minimax(ANSWER)
  expect(f"MiniMax sends its key to no untrusted endpoint from {name}",
         [http.count, record["usageStatusText"], "HTTPS" in record["authHelpText"]], [0, "MiniMax limits unavailable", True], record)
  os.environ.pop("MINIMAX_API_KEY", None)
  os.environ.pop("MINIMAX_BASE_URL", None)

# A key saved under a provider id MiniMax doesn't bill belongs to a gateway
# in front of it, and is never sent to MiniMax as a bearer.
sandbox()
os.environ["MMX_CONFIG_DIR"] = str(home() / ".mmx")
opencode_auth(None, "minimax-coding", "gateway_key")
pi_auth(None, "minimax-token-plan", "gateway_key")
pi_auth(home() / ".omp" / "agent", "minimax-proxy", "gateway_key")
expect("MiniMax credentials take keys only under the provider ids MiniMax bills", credentials()[0], "")
PY
