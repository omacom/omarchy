#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_STATE_HOME="$test_tmp/state"
mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME"

notify_dir="$test_tmp/notifications"
mkdir -p "$notify_dir"
write_note() {
  local name=$1 app=$2 summary=$3 body=$4
  python3 - "$notify_dir/$name.json" "$app" "$summary" "$body" <<'PY'
import json, sys
path, app, summary, body = sys.argv[1:]
with open(path, "w", encoding="utf-8") as handle:
    json.dump({"app": app, "summary": summary, "body": body, "timestamp": 1}, handle)
PY
}
write_note d1 Discord "ping" "one"
write_note d2 Discord "ping" "two"
write_note s1 Slack "new message" "#ops"
write_note s2 Slack "new message" "#ops"
write_note m1 Mail "inbox" "a"
write_note m2 Mail "inbox" "b"

"$ROOT/bin/omarchy-ml-notify-fold" rule add discord --words discord --label "discord messages" >/dev/null
"$ROOT/bin/omarchy-ml-notify-fold" rule drop mail >/dev/null

digest=$("$ROOT/bin/omarchy-ml-notify-fold" "$notify_dir")
[[ $digest == "2 messages from #ops, 2 discord messages" ]] ||
  fail "a group you add is folded and a group you drop is not" "$digest"

history="$HOME/.local/state/omarchy/notifications/history.json"
mkdir -p "${history%/*}"
jq -s '.' "$notify_dir"/*.json >"$history"
[[ $("$ROOT/bin/omarchy-ml-notify-fold") == "$digest" ]] ||
  fail "the current store uses the same custom fold groups"

"$ROOT/bin/omarchy-ml-notify-fold" rule enable mail >/dev/null
digest=$("$ROOT/bin/omarchy-ml-notify-fold" "$notify_dir")
[[ $digest == "2 emails, 2 messages from #ops, 2 discord messages" ]] ||
  fail "enabling a built-in group folds it again" "$digest"
grep -Fq '"trigger.ml.fold-rule"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu can change fold groups"
pass "notification fold groups are yours to add and drop"
