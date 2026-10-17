#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/cache"
export MET_CALLS="$work/calls" MET_HEADERS="$work/request-headers"
marker="$work/executed"
printf -v attack '$(touch %s)' "$marker"
export TEST_LAST_MODIFIED="$attack"
cat >"$work/bin/curl" <<'SH'
#!/bin/bash
set -euo pipefail
printf 'request\n' >>"$MET_CALLS"
while (( $# )); do
  case "$1" in
    -D) headers=$2; shift 2 ;;
    -o) body=$2; shift 2 ;;
    -H) printf '%s\n' "$2" >>"$MET_HEADERS"; shift 2 ;;
    *) shift ;;
  esac
done
printf 'HTTP/1.1 %s\r\nLast-Modified: %s\r\n\r\n' "${TEST_HTTP_CODE:-200}" "$TEST_LAST_MODIFIED" >"$headers"
printf '{"type":"Feature","properties":{"timeseries":[]}}\n' >"$body"
printf '%s' "${TEST_HTTP_CODE:-200}"
SH
chmod +x "$work/bin/curl"

fetch() {
  PATH="$work/bin:$PATH" "$ROOT/shell/plugins/panels/weather/met-fetch.sh" 46.05 14.51 "$work/cache"
}
requests() {
  wc -l <"$MET_CALLS"
}

fetch >"$work/output"
fetch >"$work/output"
[[ ! -e $marker ]] || fail "remote Last-Modified must never execute when metadata is read"
[[ $(requests) == 1 ]] || fail "a fresh cache must avoid another request"
[[ $(jq -r .last_modified "$work/cache/meta") == "$attack" ]] || fail "remote header must round-trip as JSON data"
[[ $(jq -r .status "$work/output") == "throttled" ]] || fail "fresh metadata retains throttling"
pass "remote command substitutions stay inert across cache reads"

# Revalidation must send the stored header literally, not evaluate it.
jq '.last_fetch = "0"' "$work/cache/meta" >"$work/meta"
mv "$work/meta" "$work/cache/meta"
cp "$work/cache/body.json" "$work/original-body"
TEST_HTTP_CODE=304 fetch >"$work/output"
[[ $(requests) == 2 ]] || fail "stale cache makes one revalidation request"
grep -Fx "If-Modified-Since: $attack" "$MET_HEADERS" >/dev/null || fail "revalidation sends the literal cached header"
cmp -s "$work/original-body" "$work/cache/body.json" || fail "304 preserves the cached body"
[[ ! -e $marker ]] || fail "revalidation must not execute the header"
[[ $(jq -r .status "$work/output") == "not-modified" ]] || fail "304 reports not-modified"
fetch >"$work/output"
[[ $(requests) == 2 ]] || fail "304 metadata retains throttling"
pass "304 revalidation preserves data and backs off without executing headers"

expires=$(( $(date +%s) + 3600 ))
jq --arg expires "$expires" '.last_fetch = "0" | .expires = $expires' "$work/cache/meta" >"$work/meta"
mv "$work/meta" "$work/cache/meta"
fetch >"$work/output"
[[ $(requests) == 2 && $(jq -r .status "$work/output") == "fresh" ]] || fail "JSON metadata preserves Expires handling"
pass "unexpired JSON metadata serves the cache without a request"

# Treat timestamps as validated data before they reach Bash arithmetic.
for field in last_fetch expires; do
  for invalid in "$attack" '1+2' '-1' '08' '0xFF' '9999999999999999999999999999'; do
    before=$(requests)
    jq --arg field "$field" --arg invalid "$invalid" '.[$field] = $invalid' "$work/cache/meta" >"$work/meta"
    mv "$work/meta" "$work/cache/meta"
    fetch >"$work/output"
    [[ ! -e $marker ]] || fail "invalid $field must not execute as arithmetic"
    [[ $(requests) == $((before + 1)) ]] || fail "invalid $field metadata is ignored and refreshed"
  done
done
pass "malformed timestamps are ignored before arithmetic or throttling"

# An old executable metadata file is never sourced, including on upgrades.
printf 'touch %q\n' "$marker" >"$work/cache/meta"
before=$(requests)
fetch >"$work/output"
[[ ! -e $marker && $(requests) == $((before + 1)) ]] || fail "legacy shell metadata must be ignored"
jq -e '.meta_lat == "46.0500" and .meta_lon == "14.5100"' "$work/cache/meta" >/dev/null || fail "legacy metadata is replaced by JSON"
pass "legacy shell metadata is refreshed without execution"
