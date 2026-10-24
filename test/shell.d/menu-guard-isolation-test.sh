#!/bin/bash

# A user guard in ~/.config/omarchy/extensions/omarchy-menu.jsonc is arbitrary
# bash. One that calls `exit`, fails, or does not parse used to take its whole
# group down: later rows went unanswered (and showed unconditionally, or lost
# their ✓), or the batch failed and every group's answers were thrown away.
# Each guard now parses and runs in a subshell of its own, so it answers only
# its own row.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command node

gen_dir=$(mktemp -d)
trap 'rm -rf "$gen_dir"' EXIT

cat >"$gen_dir/hostile.js" <<'JS'
const path = require('path')
const menu = require(path.join(process.env.ROOT, 'shell/plugins/menu/MenuModel.js'))
process.stdout.write(menu.guardScript({
  quits: { id: 'quits', when: 'true; exit 0' },
  failing: { id: 'failing', when: 'exit 3' },
  broken: { id: 'broken', when: 'fi then' },
  nounset: { id: 'nounset', when: '[[ -n $OMARCHY_TEST_UNSET ]]' },
  quote: { id: 'quote', when: "[[ 'a b' == 'a b' ]]" },
  after: { id: 'after', when: 'true' }
}))
JS
hostile_script=$(node "$gen_dir/hostile.js")

# Runs the batch, answering rows on one line and the batch's status last.
batch() {
  local status=0 output
  output=$("$@" bash -eu -c "$hostile_script" 2>/dev/null | sort | tr '\n' ' ') || status=$?
  printf '%sstatus=%s' "$output" "$status"
}

# `exit 0` and a syntax error each used to end the group script early, leaving
# every later row in the group unanswered; `exit 3` used to fail the whole
# batch and discard all eight groups' answers.
result=$(batch env OMARCHY_TEST_UNSET=set)
[[ $result == "after:w:1 broken:w:0 failing:w:0 nounset:w:1 quits:w:1 quote:w:1 status=0" ]] ||
  fail "a guard that exits, fails or does not parse answers only its own row" "got: $result"
pass "a guard that exits, fails or does not parse answers only its own row"

# The same batch with the variable actually unset: under a login shell's
# `set -u` the guard used to kill its group mid-way.
result=$(batch env -u OMARCHY_TEST_UNSET)
[[ $result == "after:w:1 broken:w:0 failing:w:0 nounset:w:0 quits:w:1 quote:w:1 status=0" ]] ||
  fail "a guard tripping set -u answers its own row and leaves the group standing" "got: $result"
pass "a guard tripping set -u answers its own row and leaves the group standing"

# The quoting has to hold for a guard carrying single quotes of its own, and
# one written to break out must stay a string eval parses inside the guard's
# own subshell.
cat >"$gen_dir/escape.js" <<'JS'
const path = require('path')
const menu = require(path.join(process.env.ROOT, 'shell/plugins/menu/MenuModel.js'))
process.stdout.write(menu.guardScript({
  escape: { id: 'escape', when: "true; echo pwned:w:9; exit 0" }
}))
JS
escape_script=$(node "$gen_dir/escape.js")
[[ $escape_script == *"eval 'true; echo pwned:w:9; exit 0'"* ]] ||
  fail "a guard is single-quoted for eval, whatever characters it carries" "$escape_script"
escape_out=$(bash -e -c "$escape_script" 2>/dev/null)
[[ $escape_out == "escape:w:1" ]] ||
  fail "a hostile guard cannot write into the batch's answer stream" "stdout: $escape_out"
escape_err=$(bash -e -c "$escape_script" 2>&1 >/dev/null)
[[ -z $escape_err ]] || fail "a guard's own output stays silenced" "stderr: $escape_err"
pass "a guard runs inside its own subshell however many quotes it carries"

# The readers' captured answers reach a guard through its slot; eval expands
# the slot at run time, which has to compare exactly as the raw substitution
# did.
cat >"$gen_dir/reader.js" <<'JS'
const path = require('path')
const menu = require(path.join(process.env.ROOT, 'shell/plugins/menu/MenuModel.js'))
process.stdout.write(menu.guardScript({
  hit: { id: 'hit', checked: '[[ "$(omarchy-dns)" == "Cloudflare" ]]' },
  miss: { id: 'miss', checked: '[[ "$(omarchy-dns)" == "Google" ]]' }
}))
JS
reader_script=$(node "$gen_dir/reader.js")
reader_result=$(bash -c '
omarchy-dns() { printf "Cloudflare\n"; }
export -f omarchy-dns
'"$reader_script" | sort)
[[ $reader_result == $'hit:c:1\nmiss:c:0' ]] ||
  fail "a captured reader still compares exactly inside the eval'd guard" "got: $reader_result"
pass "a captured reader still compares exactly inside the eval'd guard"
