#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

editor_log="$test_tmp/editor.log"
record_editor() { printf '<%s>\n' "$@" >>"$editor_log"; }
EDITOR=record_editor

shopt -s expand_aliases
# A terminal opened before eff became a function still has the old alias when it re-sources.
alias eff='$EDITOR "$(ff)"'
source "$ROOT/default/bash/aliases"

# fzf prints nothing and exits 130 when its picker is closed with Escape.
fzf() { return 130; }
eff || true
[[ ! -e $editor_log ]] || fail "eff opens no editor when its picker is cancelled" "$(<"$editor_log")"

fzf() { printf 'notes with spaces.txt\n'; }
eff +42
[[ $(<"$editor_log") == $'<notes with spaces.txt>\n<+42>' ]] ||
  fail "eff opens the picked file as one argument, passing its own on to the editor" "$(<"$editor_log")"
pass "eff opens the picked file, and no editor when its picker is cancelled"
