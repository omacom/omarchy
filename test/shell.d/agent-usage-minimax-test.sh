#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# A machine with no MiniMax key prints the full, zeroed record the panel
# skips, with no status to alarm anyone.
no_key=$(HOME="$TEST_HOME" XDG_DATA_HOME="$TEST_HOME/.local/share" XDG_CACHE_HOME="$TEST_HOME/.cache" MINIMAX_API_KEY="" \
  MMX_CONFIG_DIR="$TEST_HOME/missing" "$ROOT/bin/omarchy-agent-usage-minimax")

[[ $(jq -c '{id, ready, tierLabel, limits, usageStatusText, authHelpText, limitsStale, limitsFetchedAt, days: (.recentDays | length), modelUsage}' <<<"$no_key") == '{"id":"minimax","ready":false,"tierLabel":"","limits":[],"usageStatusText":"","authHelpText":"","limitsStale":false,"limitsFetchedAt":0,"days":7,"modelUsage":{}}' ]] ||
  fail "MiniMax collector prints a record the panel skips without credentials" "$no_key"
pass "MiniMax collector prints a record the panel skips without credentials"

result=$(python3 - "$ROOT/bin/omarchy-agent-usage-minimax" "$TEST_HOME" <<'PY'
import importlib.machinery
import importlib.util
import json
import os
import sys
from pathlib import Path

collector_path = sys.argv[1]
home = Path(sys.argv[2])
os.environ["HOME"] = str(home)
os.environ["MMX_CONFIG_DIR"] = str(home / ".mmx")
os.environ["XDG_DATA_HOME"] = str(home / ".local/share")
os.environ["XDG_CACHE_HOME"] = str(home / ".cache")
os.environ.pop("MINIMAX_API_KEY", None)
os.environ.pop("MINIMAX_BASE_URL", None)

loader = importlib.machinery.SourceFileLoader("minimax_collector", collector_path)
spec = importlib.util.spec_from_loader(loader.name, loader)
scanner = importlib.util.module_from_spec(spec)
loader.exec_module(scanner)

payload = {
  "model_remains": [
    {
      "model_name": "general",
      "end_time": 1782399600000,
      "current_interval_remaining_percent": 10,
      "current_interval_status": 1,
      "weekly_end_time": 1782691200000,
      "current_weekly_remaining_percent": 69,
      "current_weekly_status": 1,
    },
    {
      "model_name": "video",
      "current_interval_total_count": 0,
      "current_interval_remaining_percent": 100,
      "current_interval_status": 3,
    },
  ],
  "base_resp": {"status_code": 0, "status_msg": "success"},
}

limits = scanner.quota_limits(payload)
fetch_quota = scanner.fetch_quota

# Without a "general" row the first row that isn't a media model's is the plan.
media_first = scanner.quota_limits({"model_remains": [
  {"model_name": "video", "current_interval_remaining_percent": 100},
  {"model_name": "Image-01", "current_interval_remaining_percent": 100},
  {"model_name": "MiniMax-M2", "current_interval_remaining_percent": 25},
]})

config_dir = home / ".mmx"
config_dir.mkdir(parents=True)
(config_dir / "config.json").write_text(json.dumps({"api_key": "mmx_saved"}))
saved_key, saved_base_url = scanner.credentials()

(config_dir / "config.json").write_text(json.dumps({
  "oauth": {
    "access_token": "mmx_oauth",
    "refresh_token": "refresh",
    "expires_at": "2099-01-01T00:00:00Z",
    "region": "cn",
  }
}))
oauth_key, oauth_base_url = scanner.credentials()

(config_dir / "config.json").unlink()
opencode = home / ".local/share/opencode/auth.json"
opencode.parent.mkdir(parents=True)
opencode.write_text(json.dumps({"minimax": {"type": "api", "key": "mmx_opencode"}}))
opencode_key, opencode_base_url = scanner.credentials()

# A China-region key pi saved answers on the China host.
opencode.unlink()
pi_auth = home / ".pi/agent/auth.json"
pi_auth.parent.mkdir(parents=True)
pi_auth.write_text(json.dumps({"minimax-cn": {"type": "api_key", "key": "mmx_pi_cn"}}))
pi_key, pi_base_url = scanner.credentials()
pi_auth.unlink()

import copy, time
from datetime import datetime, timedelta, timezone

# Windows still open, so the cached copy outlives the failed check below.
current = copy.deepcopy(payload)
current["model_remains"][0]["end_time"] = round((time.time() + 3600) * 1000)
current["model_remains"][0]["weekly_end_time"] = round((time.time() + 86400) * 1000)
probes = []

def answer(api_key, base_url):
  probes.append(api_key)
  return current

def failing(**kwargs):
  def fetch(api_key, base_url):
    probes.append(api_key)
    raise scanner.MiniMaxError(kwargs.get("message", "failed"), transport=kwargs.get("transport", False), rejected=kwargs.get("rejected", False))
  return fetch

def run(fetch, key="mmx_test", force=False):
  scanner.fetch_quota = fetch
  probes.clear()
  record = scanner.collect(key, "https://example.invalid", force)
  return dict(record, probes=len(probes))

out = {"limits": limits, "mediaFirst": media_first, "savedKey": saved_key, "savedBaseUrl": saved_base_url,
       "oauthKey": oauth_key, "oauthBaseUrl": oauth_base_url, "opencodeKey": opencode_key,
       "piKey": pi_key, "piBaseUrl": pi_base_url}

out["record"] = run(answer, force=True)
# Within the probe interval a repeat run reuses the answer; --force doesn't.
out["reused"] = run(failing(transport=True))
out["forced"] = run(answer, force=True)

cache = scanner.limits_cache_paths("mmx_test", "https://example.invalid")[0]
def age_cache(fetched_ms, entries=None):
  data = json.loads(cache.read_text())
  data["fetchedAtMs"] = fetched_ms
  if entries is not None:
    data["limits"] = entries
  cache.write_text(json.dumps(data))

age_cache(1)
out["stale"] = run(failing(message="Couldn't reach the MiniMax API. Retrying shortly.", transport=True))
out["rejected"] = run(failing(message=scanner.AUTH_HELP_BAD_KEY, rejected=True))
out["server"] = run(failing(message="MiniMax's quota endpoint returned HTTP 500."))

def broken(api_key, base_url):
  probes.append(api_key)
  raise KeyError("surprise")
out["broken"] = run(broken)

# Another key never shows this one's numbers.
out["otherKey"] = run(failing(message="MiniMax's quota endpoint returned HTTP 500."), key="other")
out["offline"] = run(failing(message="Couldn't reach the MiniMax API.", transport=True), key="other")

# A cache stamped in the future (the clock went back) is no proof of a recent
# probe, but it is still the last good answer to fall back on.
age_cache(round((time.time() + 86400) * 1000))
out["skewed"] = run(failing(transport=True))

# A kept window that has since reset comes back at zero; one still open, or
# with no reset time, stays as it was.
now = datetime.now(timezone.utc)
age_cache(1, [
  {"label": "Session (5-hour)", "percent": 1.0, "resetsAt": (now - timedelta(hours=1)).isoformat()},
  {"label": "Weekly (7-day)", "percent": 0.5, "resetsAt": (now + timedelta(days=2)).isoformat()},
  {"label": "Other", "percent": 0.2, "resetsAt": ""},
])
out["reset"] = run(failing(transport=True))

# A bad key MiniMax names in base_resp rather than with a status code.
import io
class Response(io.BytesIO):
  def __enter__(self): return self
  def __exit__(self, *a): return False
scanner.urllib.request.urlopen = lambda request, timeout: Response(json.dumps({"base_resp": {"status_code": 1004, "status_msg": "login fail"}}).encode())
try:
  fetch_quota("k", "https://example.invalid")
  out["baseRespRejected"] = False
except scanner.MiniMaxError as error:
  out["baseRespRejected"] = error.rejected

print(json.dumps(out))
PY
)

[[ $(jq -c '.limits | map({label, percent})' <<<"$result") == '[{"label":"Session (5-hour)","percent":0.9},{"label":"Weekly (7-day)","percent":0.31000000000000005}]' ]] ||
  fail "MiniMax remaining percentages become Omarchy used fractions" "$result"
pass "MiniMax remaining percentages become Omarchy used fractions"

[[ $(jq -r '.limits[0].resetsAt + ":" + .limits[1].resetsAt' <<<"$result") == "2026-06-25T15:00:00+00:00:2026-06-29T00:00:00+00:00" ]] ||
  fail "MiniMax quota reset timestamps are normalized" "$result"
pass "MiniMax quota reset timestamps are normalized"

[[ $(jq -c '.mediaFirst | map(.percent)' <<<"$result") == '[0.75]' ]] ||
  fail "MiniMax collector skips media quota rows when choosing the plan's row" "$result"
pass "MiniMax collector skips media quota rows when choosing the plan's row"

[[ $(jq -r '.savedKey + ":" + .opencodeKey' <<<"$result") == "mmx_saved:mmx_opencode" ]] ||
  fail "MiniMax credentials use mmx and opencode logins" "$result"
pass "MiniMax credentials use mmx and opencode logins"

[[ $(jq -r '.piKey + ":" + .piBaseUrl' <<<"$result") == "mmx_pi_cn:https://api.minimaxi.com" ]] ||
  fail "MiniMax credentials use a China-region key pi saved, on the China host" "$result"
pass "MiniMax credentials use a China-region key pi saved, on the China host"

[[ $(jq -r '.oauthKey + ":" + .oauthBaseUrl' <<<"$result") == "mmx_oauth:https://api.minimaxi.com" ]] ||
  fail "MiniMax credentials use the OAuth session and region saved by mmx" "$result"
pass "MiniMax credentials use the OAuth session and region saved by mmx"

[[ $(jq -c '.record | {id, ready, tierLabel, limitsStale, usageStatusText, authHelpText, probes}' <<<"$result") == '{"id":"minimax","ready":true,"tierLabel":"Token Plan","limitsStale":false,"usageStatusText":"","authHelpText":"","probes":1}' ]] ||
  fail "MiniMax collector prints the display-ready record contract" "$result"
pass "MiniMax collector prints the display-ready record contract"

[[ $(jq -c '[.reused.probes, .reused.limitsStale, .forced.probes]' <<<"$result") == '[0,false,1]' ]] ||
  fail "MiniMax collector reuses a probe younger than the interval and re-probes on --force" "$result"
pass "MiniMax collector reuses a recent probe and re-probes on --force"

[[ $(jq -c '.stale | {ready, tierLabel, limitsStale, percent: .limits[0].percent, usageStatusText, retryAdvised, limitsFetchedAt}' <<<"$result") == '{"ready":true,"tierLabel":"Token Plan","limitsStale":true,"percent":0.9,"usageStatusText":"","retryAdvised":true,"limitsFetchedAt":1}' ]] ||
  fail "MiniMax collector keeps the last limits, marked stale, after a failed check" "$result"
[[ $(jq -r '.stale.authHelpText' <<<"$result") == *"reach"* ]] ||
  fail "MiniMax collector says what failed when it keeps the last limits" "$result"
pass "MiniMax collector keeps the last limits, marked stale, after a failed check"

[[ $(jq -c '.rejected | {usageStatusText, limitsStale, n: (.limits | length), retryAdvised}' <<<"$result") == '{"usageStatusText":"Sign-in expired","limitsStale":true,"n":2,"retryAdvised":null}' ]] ||
  fail "MiniMax collector reports refused credentials as an expired sign-in" "$result"
[[ $(jq -r '.baseRespRejected' <<<"$result") == "true" ]] ||
  fail "MiniMax collector reads an authentication failure in base_resp as a refused key" "$result"
pass "MiniMax collector reports refused credentials as Sign-in expired"

[[ $(jq -c '[.server.usageStatusText, .server.limitsStale, .server.retryAdvised, .broken.usageStatusText, .broken.limitsStale]' <<<"$result") == '["",true,null,"",true]' ]] ||
  fail "MiniMax collector keeps the last limits past a server error or an unexpected answer" "$result"
pass "MiniMax collector keeps the last limits past a server error or an unexpected answer"

[[ $(jq -c '.otherKey | {usageStatusText, n: (.limits | length), tierLabel, retryAdvised}' <<<"$result") == '{"usageStatusText":"MiniMax limits unavailable","n":0,"tierLabel":"","retryAdvised":null}' ]] ||
  fail "MiniMax collector keys its limits cache by credential and reports a failure with nothing kept" "$result"
[[ $(jq -c '.offline | {usageStatusText, retryAdvised}' <<<"$result") == '{"usageStatusText":"MiniMax limits unavailable","retryAdvised":true}' ]] ||
  fail "MiniMax collector advises a retry only when the API can't be reached" "$result"
pass "MiniMax collector keeps each key's limits apart and advises a retry only for transport failures"

[[ $(jq -c '.skewed | {probes, limitsStale, n: (.limits | length)}' <<<"$result") == '{"probes":1,"limitsStale":true,"n":2}' ]] ||
  fail "MiniMax collector re-probes past a future-stamped cache and still falls back on it" "$result"
pass "MiniMax collector neither trusts nor loses a future-stamped cache"

[[ $(jq -c '.reset.limits | map({label, percent, resetsAt: (.resetsAt != "")})' <<<"$result") == '[{"label":"Session (5-hour)","percent":0.0,"resetsAt":false},{"label":"Weekly (7-day)","percent":0.5,"resetsAt":true},{"label":"Other","percent":0.2,"resetsAt":false}]' ]] ||
  fail "MiniMax collector zeroes kept windows that have reset rather than dropping them" "$result"
pass "MiniMax collector zeroes kept windows that have reset"

# The bearer never follows a redirect to another host.
redirect=$(python3 - "$ROOT/bin/omarchy-agent-usage-minimax" <<'PY'
import importlib.machinery, importlib.util, json, sys, threading
from http.server import BaseHTTPRequestHandler, HTTPServer

loader = importlib.machinery.SourceFileLoader("minimax_collector", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
scanner = importlib.util.module_from_spec(spec)
loader.exec_module(scanner)

seen = []

class Elsewhere(BaseHTTPRequestHandler):
  def do_GET(self):
    seen.append(self.headers.get("Authorization"))
    self.send_response(200)
    self.end_headers()
    self.wfile.write(b'{"model_remains":[]}')
  def log_message(self, *args):
    pass

elsewhere = HTTPServer(("127.0.0.1", 0), Elsewhere)

class Redirecting(BaseHTTPRequestHandler):
  def do_GET(self):
    self.send_response(302)
    self.send_header("Location", f"http://127.0.0.1:{elsewhere.server_port}/steal")
    self.end_headers()
  def log_message(self, *args):
    pass

origin = HTTPServer(("127.0.0.1", 0), Redirecting)
for server in (origin, elsewhere):
  threading.Thread(target=server.serve_forever, daemon=True).start()

try:
  scanner.fetch_quota("secret", f"http://127.0.0.1:{origin.server_port}")
  error = ""
except scanner.MiniMaxError as failure:
  error = str(failure)
print(json.dumps({"forwarded": seen, "error": error}))
PY
)
[[ $(jq -c '.forwarded' <<<"$redirect") == '[]' && $(jq -r '.error' <<<"$redirect") == *"redirected"* ]] ||
  fail "MiniMax collector refuses to follow a redirect with the bearer" "$redirect"
pass "MiniMax collector refuses to follow a redirect with the bearer"
