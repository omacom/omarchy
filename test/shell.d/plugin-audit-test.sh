#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_omarchy="$test_tmp/omarchy"
mkdir -p "$fake_omarchy/shell/plugins/clock" "$test_tmp/home/.config/omarchy/plugins/good" \
  "$test_tmp/home/.config/omarchy/plugins/bad"

cat >"$fake_omarchy/shell/plugins/clock/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "omarchy.clock",
  "name": "Clock",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": {"barWidget": "Widget.qml"}
}
JSON
touch "$fake_omarchy/shell/plugins/clock/Widget.qml"

cat >"$test_tmp/home/.config/omarchy/plugins/good/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "acme.good",
  "name": "Good Plugin",
  "version": "1.0.0",
  "kinds": ["service"],
  "entryPoints": {"service": "Service.qml"}
}
JSON
touch "$test_tmp/home/.config/omarchy/plugins/good/Service.qml"

cat >"$test_tmp/home/.config/omarchy/plugins/bad/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "acme.bad",
  "name": "Bad Plugin",
  "version": "1.0.0",
  "kinds": ["service"],
  "entryPoints": {"service": "Missing.qml"}
}
JSON

export HOME="$test_tmp/home"
export OMARCHY_PATH="$fake_omarchy"
export PATH="$ROOT/bin:$PATH"

json=$("$ROOT/bin/omarchy-plugin-audit" --json || true)
[[ $(jq 'length' <<<"$json") -eq 3 ]] || fail "audit reports every installed plugin" "$json"
jq -e 'any(.[]; .id == "omarchy.clock" and .source == "first-party" and .valid and .risk == "trusted-first-party")' <<<"$json" >/dev/null ||
  fail "audit identifies valid first-party plugins" "$json"
jq -e 'any(.[]; .id == "acme.good" and .source == "third-party" and .valid and .risk == "unsandboxed")' <<<"$json" >/dev/null ||
  fail "audit marks valid third-party plugins as unsandboxed" "$json"
jq -e 'any(.[]; .id == "acme.bad" and (.valid | not) and (.issues | length) > 0)' <<<"$json" >/dev/null ||
  fail "audit reports validation failures in JSON" "$json"
pass "plugin audit reports source, risk, and validation state"

if "$ROOT/bin/omarchy-plugin-audit" >/dev/null 2>"$test_tmp/audit.err"; then
  fail "human audit accepts an invalid plugin"
fi
output=$("$ROOT/bin/omarchy-plugin-audit" 2>&1 || true)
grep -F 'invalid' <<<"$output" >/dev/null || fail "human audit reports invalid status" "$output"
grep -F 'unsandboxed' <<<"$output" >/dev/null || fail "human audit explains third-party risk" "$output"
pass "plugin audit exits nonzero and explains findings"
