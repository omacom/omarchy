#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_home="$test_tmp/home"
fake_state="$test_tmp/state"
mkdir -p "$fake_home/.config/omarchy/plugins/acme.bad" "$fake_state"

cat >"$fake_home/.config/omarchy/plugins/acme.bad/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "acme.bad",
  "name": "Bad plugin",
  "version": "1.0.0",
  "kinds": ["service"],
  "entryPoints": {"service": "Service.qml"}
}
JSON

mkdir -p "$fake_home/.config/omarchy"
cat >"$fake_home/.config/omarchy/shell.json" <<'JSON'
{
  "version": 1,
  "bar": {
    "id": "acme.bad",
    "centerAnchor": "acme.bad",
    "layout": {
      "left": [{"id": "omarchy.menu"}, {"id": "acme.bad"}, {"id": "stale.plugin"}],
      "center": [{"id": "omarchy.clock"}],
      "right": []
    }
  },
  "plugins": [{"id": "acme.bad"}, {"id": "stale.plugin"}, {"id": "omarchy.weather"}]
}
JSON

run_recovery() {
  HOME="$fake_home" XDG_STATE_HOME="$fake_state" OMARCHY_PATH="$ROOT" \
    "$ROOT/bin/omarchy-debug-recovery" "$@"
}

run_recovery backup >/dev/null
backup_count=$(find "$fake_state/omarchy/recovery" -maxdepth 1 -type f -name 'shell-*.json' | wc -l)
[[ $backup_count == 1 ]] || fail "backup creates exactly one recovery file"
pass "backup creates exactly one recovery file"

run_recovery disable-third-party >/dev/null
jq -e '
  ([.plugins[].id] | index("acme.bad")) == null and
  ([.plugins[].id] | index("stale.plugin")) == null and
  ([.plugins[].id] | index("omarchy.weather")) != null and
  ([.bar.layout.left[].id] | index("acme.bad")) == null and
  ([.bar.layout.left[].id] | index("stale.plugin")) == null and
  (.bar.id == null) and
  (.bar.centerAnchor == "omarchy.clock")
' "$fake_home/.config/omarchy/shell.json" >/dev/null \
  || fail "disable-third-party removes third-party shell entries without removing first-party ones"
pass "disable-third-party removes third-party shell entries without removing first-party ones"

run_recovery restore-last >/dev/null
jq -e '.bar.id == "acme.bad" and (.plugins | length) == 3 and ([.bar.layout.left[].id] | index("stale.plugin")) != null' "$fake_home/.config/omarchy/shell.json" >/dev/null \
  || fail "restore-last restores the backed-up shell configuration"
pass "restore-last restores the backed-up shell configuration"
