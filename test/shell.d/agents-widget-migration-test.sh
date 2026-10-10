#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command jq

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"
printf '#!/bin/bash\n' >"$test_dir/bin/omarchy-agent-usage-update"
chmod +x "$test_dir/bin/"*

home="$test_dir/home"
config="$home/.config/omarchy/shell.json"
mkdir -p "$home/.config/omarchy"

run_migrations() {
  local migration
  for migration in 1785344985 1786099804; do
    HOME="$home" PATH="$test_dir/bin:$PATH" bash -euo pipefail "$ROOT/migrations/$migration.sh" >/dev/null
  done
}

agents_count() {
  jq '[.bar.layout[] | .[] | if type == "object" then .id else . end | select(. == "omarchy.agents")] | length' "$config"
}

cat >"$config" <<'JSON'
{ "bar": { "layout": { "right": [{ "id": "omarchy.tray" }, { "id": "omarchy.battery" }] } } }
JSON

run_migrations

[[ $(jq -c '.bar.layout.right' "$config") == '[{"id":"omarchy.tray"},{"id":"omarchy.agents"},{"id":"omarchy.battery"}]' ]] ||
  fail "migrations add the widget after the tray" "$(cat "$config")"
pass "migrations add the widget after the tray"

cat >"$config" <<'JSON'
{ "bar": { "layout": { "center": ["omarchy.model-usage"], "right": [{ "id": "omarchy.tray" }, { "id": "omarchy.battery" }] } } }
JSON

run_migrations

(($(agents_count) == 1)) || fail "migrations keep a hand-placed model usage widget as the only copy" "$(cat "$config")"
[[ $(jq -c '.bar.layout.center' "$config") == '["omarchy.agents"]' ]] ||
  fail "migrations keep a hand-placed model usage widget where it was" "$(cat "$config")"
pass "migrations keep a hand-placed model usage widget as the only copy"
