#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
store="$XDG_CONFIG_HOME/Grok Bot/sand-client-persistence"

collect() {
  "$ROOT/bin/omarchy-agent-usage-grok-bot" --force
}

# The app names each entry after the base32 of its key.
cache_entry() {
  local key="$1" body="$2" name
  name=$(python3 -c 'import base64, sys; print(base64.b32encode(sys.argv[1].encode()).decode().rstrip("="))' "$key")
  mkdir -p "$store"
  printf '%s\n' "$body" >"$store/$name.blob"
}

now_ms=$(python3 -c 'import time; print(int(time.time() * 1000))')
reset_ms=$((now_ms + 3 * 86400000))

record=$(collect)
[[ $(jq -c '{id, ready, limits}' <<<"$record") == '{"id":"grok-bot","ready":false,"limits":[]}' ]] ||
  fail "a machine without Grok Bot gives an empty record" "$record"
pass "a machine without Grok Bot gives an empty record"

cache_entry "sand.client.slice.account.grok%7Cuser_a.settings.cache" '{"value":{"reading":{"usage":{"percentUsed":99}}}}'
record=$(collect)
[[ $(jq -r '.ready' <<<"$record") == false ]] || fail "only the weekly-usage entry is read" "$record"
pass "only the weekly-usage entry is read"

cache_entry "sand.client.slice.account.grok%7Cuser_a.weekly-usage.cache" "$(jq -nc --argjson reset "$reset_ms" --argjson now "$now_ms" \
  '{schemaVersion: 1, value: {reading: {usage: {percentUsed: 42.5, nextResetMs: $reset, grokPlanLabel: "Grok Bot Plan"}, readAtMs: $now}, expiresAtMs: ($now + 600000)}}')"
record=$(collect)
[[ $(jq -c '{ready, tierLabel, stale: .limitsStale, label: .limits[0].label, percent: .limits[0].percent}' <<<"$record") == '{"ready":true,"tierLabel":"Grok Bot Plan","stale":false,"label":"Weekly","percent":0.425}' ]] ||
  fail "the cached weekly reading becomes the Weekly limit" "$record"
[[ -n $(jq -r '.limits[0].resetsAt' <<<"$record") ]] || fail "the weekly limit says when it resets" "$record"
[[ $(jq -r '.limitsFetchedAt' <<<"$record") == "$now_ms" ]] || fail "the reading's age is the app's own read time" "$record"
pass "the cached weekly reading becomes the Weekly limit"

cache_entry "sand.client.slice.account.grok%7Cuser_a.weekly-usage.cache" "$(jq -nc --argjson reset "$reset_ms" \
  '{value: {reading: {usage: {percentUsed: 10, nextResetMs: $reset}, readAtMs: 1}, expiresAtMs: 2}}')"
record=$(collect)
[[ $(jq -r '.limitsStale' <<<"$record") == true ]] || fail "a reading past the app's expiry is marked stale" "$record"
pass "a reading past the app's expiry is marked stale"

cache_entry "sand.client.slice.account.grok%7Cuser_a.weekly-usage.cache" 'not json'
record=$(collect)
jq -e . >/dev/null <<<"$record" || fail "a corrupt cache still prints a record" "$record"
pass "a corrupt cache still prints a record"

# A second account's reading, written later, sits beside the first.
weekly() {
  jq -nc --argjson percent "$1" --argjson read "$2" --argjson reset "$reset_ms" \
    '{value: {reading: {usage: {percentUsed: $percent, nextResetMs: $reset, grokPlanLabel: "Plan"}, readAtMs: $read}, expiresAtMs: 0}}'
}
rm -rf "$store"
cache_entry "sand.client.slice.account.grok%7Cuser_b.weekly-usage.cache" "$(weekly 80 "$((now_ms - 60000))")"
cache_entry "sand.client.slice.account.grok%7Cuser_a.weekly-usage.cache" "$(weekly 20 "$((now_ms - 3600000))")"
record=$(collect)
[[ $(jq -r '.limits[0].percent' <<<"$record") == 0.8 ]] ||
  fail "without an account marker the newest reading wins, not the first file" "$record"
pass "without an account marker the newest reading wins, not the first file"

cache_entry "sand.client.slice.client-meta.account-slot" '{"schemaVersion":1,"value":"grok|user_a"}'
record=$(collect)
[[ $(jq -r '.limits[0].percent' <<<"$record") == 0.2 ]] ||
  fail "the account the app marks as current is the one read" "$record"
pass "the account the app marks as current is the one read"

cache_entry "sand.client.slice.client-meta.account-slot" '{"schemaVersion":1,"value":"grok|user_c"}'
record=$(collect)
[[ $(jq -c '{ready, limits}' <<<"$record") == '{"ready":false,"limits":[]}' ]] ||
  fail "a current account with no reading yet never shows another account's" "$record"
pass "a current account with no reading yet never shows another account's"
