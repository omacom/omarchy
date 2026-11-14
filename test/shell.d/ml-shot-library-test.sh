#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_STATE_HOME="$test_tmp/state"
export OMARCHY_ML_SHOT_INDEX="$test_tmp/shots.jsonl"
mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME"

shot_dir="$test_tmp/shots"
hidden="$test_tmp/hidden"
mkdir -p "$shot_dir" "$hidden"
red="$shot_dir/red.png"
blue="$hidden/blue.png"
printf 'red\n' > "$red"
printf 'blue\n' > "$blue"

"$ROOT/bin/omarchy-ml-shot" index --path "$red" --text "segfault dialog" --colors red --mtime "$(python3 -c 'import datetime; print(datetime.datetime(2026,10,13,12,0).timestamp())')" >/dev/null
"$ROOT/bin/omarchy-ml-shot" index --path "$blue" --text "calendar" --colors blue --mtime "$(python3 -c 'import datetime; print(datetime.datetime(2026,10,14,12,0).timestamp())')" >/dev/null
"$ROOT/bin/omarchy-ml-shot" tag "$red" login bug >/dev/null
found=$("$ROOT/bin/omarchy-ml-shot" search login)
[[ $found == "$red" ]] || fail "a tag finds the screenshot" "$found"

"$ROOT/bin/omarchy-ml-shot" ignore "$hidden" >/dev/null
if "$ROOT/bin/omarchy-ml-shot" search blue >"$test_tmp/hidden.out" 2>"$test_tmp/hidden.err"; then
  fail "an ignored folder is left out of search" "$(cat "$test_tmp/hidden.out")"
fi

"$ROOT/bin/omarchy-ml-shot" save login-bug login bug >/dev/null
found=$("$ROOT/bin/omarchy-ml-shot" search --saved login-bug)
[[ $found == "$red" ]] || fail "a saved search runs its query" "$found"
listed=$("$ROOT/bin/omarchy-ml-shot" saved)
[[ $listed == $'login-bug\tlogin bug' ]] || fail "saved searches are listed" "$listed"
grep -Fq '"trigger.ml.shot-tag"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu can tag a screenshot"
pass "screenshots can be tagged, ignored, and saved as a search"
