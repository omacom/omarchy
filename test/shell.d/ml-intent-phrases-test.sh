#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_STATE_HOME="$test_tmp/state"
mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME"

"$ROOT/bin/omarchy-ml-intent" teach "evening mode" -- omarchy-brightness-display 10%- >/dev/null
[[ $("$ROOT/bin/omarchy-ml-intent" --print "evening mode please") == "omarchy-brightness-display 10%-" ]] ||
  fail "a taught phrase runs the command you saved"
[[ $("$ROOT/bin/omarchy-ml-intent" --print "dim the laptop screen") == "omarchy-brightness-display 20%-" ]] ||
  fail "a built-in sentence still runs when you have not taught it"

"$ROOT/bin/omarchy-ml-intent" teach "evening" -- omarchy-brightness-display 5%- >/dev/null
[[ $("$ROOT/bin/omarchy-ml-intent" --print "evening mode") == "omarchy-brightness-display 10%-" ]] ||
  fail "the longer taught phrase wins"

notes="$HOME/Journal"
mkdir -p "$notes"
note="$notes/yesterday.txt"
printf 'ship it\n' > "$note"
"$ROOT/bin/omarchy-ml-intent" notes "$notes" >/dev/null
OMARCHY_ML_TODAY="2026-10-19" python3 - "$note" <<'PY'
import datetime, os, sys
yesterday = datetime.date.fromisoformat("2026-10-19") - datetime.timedelta(days=1)
stamp = datetime.datetime.combine(yesterday, datetime.time(15, 0)).timestamp()
os.utime(sys.argv[1], (stamp, stamp))
PY
quoted=$(OMARCHY_ML_TODAY="2026-10-19" "$ROOT/bin/omarchy-ml-intent" --print "open yesterday's notes")
[[ $quoted == "xdg-open $note" ]] || fail "notes come from the folder you set" "$quoted"
grep -Fq '"trigger.ml.teach"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu can teach a phrase"
pass "intent phrases and the notes folder are yours to set"
