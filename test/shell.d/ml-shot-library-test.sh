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

rm -f "$red"
plain="$shot_dir/plain.png"
printf 'plain\n' > "$plain"
"$ROOT/bin/omarchy-ml-shot" index --path "$plain" --text "" --colors "" --mtime "$(python3 -c 'import datetime; print(datetime.datetime(2026,10,15,12,0).timestamp())')" >/dev/null
"$ROOT/bin/omarchy-ml-shot" tag "$plain" red >/dev/null
found=$("$ROOT/bin/omarchy-ml-shot" search red)
[[ $found == "$plain" ]] || fail "a color tag matches without stored colors" "$found"

rm -f "$red"
if "$ROOT/bin/omarchy-ml-shot" search login >"$test_tmp/gone.out" 2>"$test_tmp/gone.err"; then
  fail "a deleted screenshot drops out of search" "$(cat "$test_tmp/gone.out")"
fi

"$ROOT/bin/omarchy-ml-shot" index --path "$blue" --text "old words" --colors blue --mtime "$(python3 -c 'import datetime; print(datetime.datetime(2026,10,14,12,0).timestamp())')" >/dev/null
"$ROOT/bin/omarchy-ml-shot" index --path "$blue" --text "fresh words" --colors blue --mtime "$(python3 -c 'import datetime; print(datetime.datetime(2026,10,16,12,0).timestamp())')" >/dev/null
"$ROOT/bin/omarchy-ml-shot" ignore "$hidden" >/dev/null || true
# blue sits in the ignored folder, so copy the reindex check onto a visible file
again="$shot_dir/again.png"
printf 'again\n' > "$again"
"$ROOT/bin/omarchy-ml-shot" index --path "$again" --text "old words" --colors blue --mtime 100 >/dev/null
"$ROOT/bin/omarchy-ml-shot" index --path "$again" --text "fresh words" --colors blue --mtime 200 >/dev/null
found=$("$ROOT/bin/omarchy-ml-shot" search "fresh words")
[[ $found == "$again" ]] || fail "reindexing keeps the newest screenshot text" "$found"
if "$ROOT/bin/omarchy-ml-shot" search old >"$test_tmp/old.out" 2>"$test_tmp/old.err"; then
  fail "reindexing drops the old screenshot text" "$(cat "$test_tmp/old.out")"
fi
pass "screenshots can be tagged, ignored, and saved as a search"
