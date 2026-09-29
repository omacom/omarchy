#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

# The collector reaches the openplatform host, so the reader that interprets
# its answer is exercised on its own: the collector loads as a module, and a
# recorded payload stands in for the response. The same stub records every
# request it sees so the test can assert on URL, headers, and method.
#
# Each call gets its own throwaway MCODE_HOME so a region preference and an
# auth record can be planted without leaking between cases. The wrapper
# emits one JSON envelope per run with `record` (the collector output) and
# `requests` (every URL the stub saw), so tests can assert on either side
# without parsing stdout twice.
run_with_stub() {
  TEST_HOME=$(mktemp -d)
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-mcode" \
    PAYLOAD="$1" STATUS_CODE="${2:-0}" REGION="${3:-en}" \
    PREFERENCES="${4:-}" AUTH_PRESENT="${5:-yes}" \
    TRANSPORT_MODE="${7-ok}" \
    CACHE_HOME="$TEST_CACHE_HOME" MCODE_HOME="$TEST_HOME" \
    ARGS="${6---force}" \
    python3 - <<'PY'
import importlib.machinery, importlib.util, contextlib, io, json, os, sys
from pathlib import Path

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

home = Path(os.environ["MCODE_HOME"])
preferences = os.environ.get("PREFERENCES")
if preferences:
    (home / "preferences").mkdir(parents=True, exist_ok=True)
    (home / "preferences" / "mcode-region.json").write_text(preferences, encoding="utf-8")
if os.environ.get("AUTH_PRESENT") == "yes":
    auth_dir = home / "auth" / "prod" / os.environ["REGION"] / "mcode-public"
    auth_dir.mkdir(parents=True, exist_ok=True)
    (auth_dir / "auth.json").write_text(json.dumps({
        "schemaVersion": 1,
        "records": {"dummy": {"accessToken": "fake-token", "clientId": "mcode-public"}},
    }), encoding="utf-8")

requests = []
payload = os.environ["PAYLOAD"]
status_code = int(os.environ["STATUS_CODE"])
transport_mode = os.environ["TRANSPORT_MODE"]
import urllib.error

def stub(request, timeout=None):
    requests.append({
        "url": request.full_url,
        "method": request.get_method(),
        "authorization": request.get_header("Authorization"),
        "accept": request.get_header("Accept"),
    })
    if transport_mode == "http_error":
        raise urllib.error.HTTPError(request.full_url, status_code, "stub", {}, io.BytesIO(b""))
    if transport_mode == "conn_error":
        raise OSError("simulated transport failure")
    body = json.dumps({
        "base_resp": {"status_code": status_code, "status_msg": "ok" if status_code == 0 else "fail"},
        **json.loads(payload),
    }) if payload else '{"base_resp":{"status_code":0,"status_msg":"empty"}}'
    return io.BytesIO(body.encode("utf-8"))

collector.urllib.request.urlopen = stub

sys.argv = ["omarchy-agent-usage-mcode", *os.environ["ARGS"].split()]
stdout = io.StringIO()
with contextlib.redirect_stdout(stdout):
    collector.main()
print(json.dumps({"record": json.loads(stdout.getvalue() or "{}"), "requests": requests}))
PY
  rm -rf "$TEST_HOME"
}

TEST_CACHE_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_CACHE_HOME"' EXIT

# Happy path: a `general` entry plus a side `video` entry. The collector must
# pick the general entry's 5-hour and weekly windows and ignore the video side
# quota entirely.
happy=$(run_with_stub '{
  "model_remains": [
    {
      "model_name": "general",
      "current_interval_total_count": 500,
      "current_interval_usage_count": 110,
      "current_interval_remaining_percent": 78,
      "current_interval_status": 1,
      "end_time": 1789171200000,
      "current_weekly_total_count": 10000,
      "current_weekly_usage_count": 1200,
      "current_weekly_remaining_percent": 88,
      "current_weekly_status": 1,
      "weekly_end_time": 1789344000000
    },
    {
      "model_name": "video",
      "current_interval_total_count": 50,
      "current_interval_usage_count": 0,
      "current_interval_remaining_percent": 100,
      "current_interval_status": 3,
      "end_time": 1789171200000,
      "current_weekly_total_count": 200,
      "current_weekly_usage_count": 0,
      "current_weekly_remaining_percent": 100,
      "current_weekly_status": 3,
      "weekly_end_time": 1789344000000
    }
  ]
}')

[[ $(jq -r '.record.limits | length' <<<"$happy") == "2" ]] ||
  fail "mcode collector emits one entry per window" "$happy"
pass "mcode collector emits one entry per window"

[[ $(jq -r '.record.limits[0].label' <<<"$happy") == "5h" ]] ||
  fail "mcode collector labels the 5-hour window" "$happy"
# The panel clamps the meter to [0,1] and prints percent × 100, so the
# collector must emit a fraction (0.22) rather than an integer percent (22).
[[ $(jq -r '.record.limits[0].percent' <<<"$happy") == "0.22" ]] ||
  fail "mcode collector reports percent as a fraction (0.22, not 22)" "$happy"
[[ $(jq -r '.record.limits[0].resetsAt' <<<"$happy") == "2026-09-12T00:00:00+00:00" ]] ||
  fail "mcode collector pins 5-hour reset to end_time as ISO" "$happy"

[[ $(jq -r '.record.limits[1].label' <<<"$happy") == "Weekly" ]] ||
  fail "mcode collector labels the weekly window" "$happy"
[[ $(jq -r '.record.limits[1].percent' <<<"$happy") == "0.12" ]] ||
  fail "mcode collector reports weekly percent as a fraction" "$happy"
[[ $(jq -r '.record.limits[1].resetsAt' <<<"$happy") == "2026-09-14T00:00:00+00:00" ]] ||
  fail "mcode collector pins weekly reset to weekly_end_time as ISO" "$happy"
pass "mcode collector reads 5-hour and weekly windows from the general entry"

# An unlimited window carries no percent and flags itself so the panel can
# draw the right glyph.
unlimited=$(run_with_stub '{
  "model_remains": [
    {
      "model_name": "general",
      "current_interval_total_count": 0,
      "current_interval_usage_count": 0,
      "current_interval_remaining_percent": 78,
      "current_interval_status": 3,
      "end_time": 1789171200000,
      "current_weekly_total_count": 0,
      "current_weekly_usage_count": 0,
      "current_weekly_remaining_percent": 100,
      "current_weekly_status": 3,
      "weekly_end_time": 1789344000000
    }
  ]
}')

# Bash `[[ == ]]` treats the right side as a glob, so the `.` in `0.0`
# matches any character. Quote the right side with `==` to do a literal
# string compare (the `==` inside `[[ ]]` already does that when both
# sides are quoted, but the explicit literal makes the intent clear).
expected='[{"label":"5h","percent":0.0,"resetsAt":"2026-09-12T00:00:00+00:00","unlimited":true},{"label":"Weekly","percent":0.0,"resetsAt":"2026-09-14T00:00:00+00:00","unlimited":true}]'
[[ $(jq -c '.record.limits' <<<"$unlimited") == "$expected" ]] ||
  fail "mcode collector flags an unlimited window without a percent" "$unlimited"
pass "mcode collector flags an unlimited window without a percent"

# The MiniMax coding-plan endpoint reports account-wide windows, so the
# record must declare `scope: "account"` so sync merge keeps a single
# machine's view rather than summing machines (which would double-count).
[[ $(jq -r '.record.scope' <<<"$happy") == "account" ]] ||
  fail "mcode collector declares limits account-scoped" "$happy"
pass "mcode collector declares limits account-scoped"

# When the platform returns 401/403 (the access token has lapsed), the
# collector must surface "Sign-in expired" so the panel can hint at
# `mcode login` rather than waiting the regular interval for a meter that
# will never refresh.
expired=$(run_with_stub '{}' 401 en "" yes "--force" http_error)

[[ $(jq -r '.record.usageStatusText' <<<"$expired") == "Sign-in expired" ]] ||
  fail "mcode collector surfaces a Sign-in expired message on 401" "$expired"
[[ $(jq -r '.record.limits | length' <<<"$expired") == "0" ]] ||
  fail "mcode collector returns empty limits on 401" "$expired"
# An expired bearer won't fix itself with another probe; only `mcode login`
# can mint a new one, so retry advice would just churn the panel.
[[ $(jq -r '.record.retryAdvised // false' <<<"$expired") == "false" ]] ||
  fail "mcode collector does not advise retry on 401 (token can't self-refresh)" "$expired"
pass "mcode collector surfaces Sign-in expired without retry advice on 401"

# A real transport failure (no HTTP response at all) is a separate path
# from a 4xx: the API is reachable but the bearer is fine, so the hint
# is "limits unavailable", not "Sign-in expired". The retry advice is
# the same shape so the panel knows to poll sooner.
conn_dead=$(run_with_stub '{}' 0 en "" yes "--force" conn_error)

[[ $(jq -r '.record.usageStatusText' <<<"$conn_dead") == "MiniMax limits unavailable" ]] ||
  fail "mcode collector surfaces MiniMax limits unavailable on a connection error" "$conn_dead"
[[ $(jq -r '.record.retryAdvised // false' <<<"$conn_dead") == "true" ]] ||
  fail "mcode collector advises retry on a connection error" "$conn_dead"
[[ $(jq -r '.record.limits | length' <<<"$conn_dead") == "0" ]] ||
  fail "mcode collector returns empty limits on a connection error" "$conn_dead"
pass "mcode collector handles a connection error without crashing"

# When the live probe succeeds after a failure, retryAdvised clears. The
# collector never replays a stale status, even if the cache file is
# still on disk from a prior auth-expired run.

# A media-only response leaves the user with no coding quota; the collector
# must surface empty limits rather than fabricate a window off the video side.
media_only=$(run_with_stub '{
  "model_remains": [
    {
      "model_name": "video",
      "current_interval_status": 1,
      "current_interval_remaining_percent": 50,
      "end_time": 1789171200000,
      "current_weekly_status": 1,
      "current_weekly_remaining_percent": 25,
      "weekly_end_time": 1789344000000
    }
  ]
}')

[[ $(jq -c '.record.limits' <<<"$media_only") == "[]" ]] ||
  fail "mcode collector drops media-only responses" "$media_only"
pass "mcode collector drops media-only responses"

# An empty `model_remains` array is the "no quota yet" response, not an error.
empty=$(run_with_stub '{"model_remains": []}')

[[ $(jq -c '.record.limits' <<<"$empty") == "[]" ]] ||
  fail "mcode collector handles an empty model_remains" "$empty"
pass "mcode collector handles an empty model_remains"

# An endpoint that says "no" with a non-zero base_resp status code is not a
# crash; the collector returns empty limits and lets the panel show whatever
# it last cached.
failed=$(run_with_stub '{"model_remains": [{"model_name":"general","current_interval_status":1,"current_interval_remaining_percent":78,"end_time":1,"current_weekly_status":1,"current_weekly_remaining_percent":88,"weekly_end_time":1}]}' "401")

[[ $(jq -c '.record.limits' <<<"$failed") == "[]" ]] ||
  fail "mcode collector drops a non-zero base_resp" "$failed"
pass "mcode collector drops a non-zero base_resp"

# Region: cn preference must steer the request at the cn host, en at the en
# one. The Authorization header is the only auth header the endpoint reads.
cn=$(run_with_stub '{
  "model_remains": [{"model_name":"general","current_interval_status":1,"current_interval_remaining_percent":90,"end_time":1,"current_weekly_status":1,"current_weekly_remaining_percent":80,"weekly_end_time":2}]
}' 0 cn '{"regions":{"prod":"cn"}}' yes "--force")

en=$(run_with_stub '{
  "model_remains": [{"model_name":"general","current_interval_status":1,"current_interval_remaining_percent":90,"end_time":1,"current_weekly_status":1,"current_weekly_remaining_percent":80,"weekly_end_time":2}]
}' 0 en '{"regions":{"prod":"en"}}' yes "--force")

cn_url=$(jq -r '.requests[0].url' <<<"$cn")
en_url=$(jq -r '.requests[0].url' <<<"$en")

[[ $cn_url == https://www.minimaxi.com/v1/api/openplatform/coding_plan/remains ]] ||
  fail "mcode collector hits the cn openplatform host when region is cn" "$cn_url"
[[ $en_url == https://platform.minimax.io/v1/api/openplatform/coding_plan/remains ]] ||
  fail "mcode collector hits the en openplatform host when region is en" "$en_url"

[[ $(jq -r '.requests[0].authorization' <<<"$cn") == "Bearer fake-token" ]] ||
  fail "mcode collector sends the bearer token in Authorization" "$cn"
[[ $(jq -r '.requests[0].method' <<<"$cn") == "GET" ]] ||
  fail "mcode collector uses GET, not POST, for the coding-plan probe" "$cn"
pass "mcode collector routes the probe by region and signs it with the bearer"

# --limits-only is the panel's refreshLimits() path: it must still emit a
# record with limits under the right key.
limits_only=$(run_with_stub '{
  "model_remains": [{"model_name":"general","current_interval_status":1,"current_interval_remaining_percent":80,"end_time":1,"current_weekly_status":1,"current_weekly_remaining_percent":70,"weekly_end_time":2}]
}' 0 en "" yes "--limits-only")

[[ $(jq -r '.record.limits[0].percent' <<<"$limits_only") == "0.2" ]] ||
  fail "mcode collector returns a fresh probe under --limits-only" "$limits_only"
pass "mcode collector returns a fresh probe under --limits-only"
