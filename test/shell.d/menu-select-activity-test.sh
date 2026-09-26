#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

# Fake `omarchy-shell shell summon`: parses the payload for the selection and
# done files, answers with $OMARCHY_TEST_SELECTION, and unblocks the waiter.
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
payload="${@: -1}"
selection_file=$(jq -r .selectionFile <<<"$payload")
done_file=$(jq -r .doneFile <<<"$payload")
printf '%s' "$OMARCHY_TEST_SELECTION" >"$selection_file"
: >"$done_file"
SH

# Fake presence gate and activity backend that logs its arguments.
cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_ACTIVITY_AVAILABLE:-true} == "true" ]]
SH

cat >"$mock_bin/omarchy-activity" <<'SH'
#!/bin/bash
printf 'activity:%s\n' "$*" >>"$OMARCHY_TEST_ACTIVITY_LOG"
SH

chmod +x "$mock_bin"/*

export PATH="$mock_bin:$PATH"
export OMARCHY_TEST_ACTIVITY_LOG="$test_tmp/activity-log"

activity_log="$test_tmp/activity-log"
select_cmd="$ROOT/bin/omarchy-menu-select"

# A consumed pick is recorded under the default dmenu namespace.
export OMARCHY_TEST_SELECTION="1080p"
out=$("$select_cmd" "Select resolution" 4k 1080p 720p)
[[ $out == "1080p" ]] || fail "menu select prints the picked option" "$out"
pass "menu select prints the picked option"
grep -Fxq 'activity:record dmenu 1080p Select resolution' "$activity_log" ||
  fail "menu select records the pick" "$(cat "$activity_log" 2>/dev/null)"
pass "menu select records the pick"

# An explicit namespace routes the record to the consuming platform.
: >"$activity_log"
export OMARCHY_TEST_SELECTION="/home/user/photo.jpg"
"$select_cmd" "Select image" /home/user/photo.jpg --activity-kind file -- --width 800 >/dev/null
grep -Fxq 'activity:record file /home/user/photo.jpg Select image' "$activity_log" ||
  fail "menu select honors --activity-kind" "$(cat "$activity_log" 2>/dev/null)"
pass "menu select honors --activity-kind"

# Display-only lists opt out instead of logging noise.
: >"$activity_log"
export OMARCHY_TEST_SELECTION="whatever"
"$select_cmd" "Keybindings" 'Super+Space' --no-activity -- --width 800 >/dev/null
[[ -s $activity_log ]] && fail "menu select honors --no-activity" "$(cat "$activity_log")"
pass "menu select honors --no-activity"

# A dismissed menu records nothing and keeps its exit code.
: >"$activity_log"
export OMARCHY_TEST_SELECTION=""
"$select_cmd" "Select resolution" 4k 1080p >/dev/null 2>&1 &&
  fail "menu select exits non-zero on dismissal"
[[ -s $activity_log ]] && fail "menu select records nothing on dismissal" "$(cat "$activity_log")"
pass "menu select records nothing on dismissal"

# Missing backend never breaks the pick.
export OMARCHY_TEST_SELECTION="720p"
export OMARCHY_TEST_ACTIVITY_AVAILABLE=false
out=$("$select_cmd" "Select resolution" 4k 720p)
[[ $out == "720p" ]] || fail "menu select works without the activity backend" "$out"
pass "menu select works without the activity backend"

# The file picker names its picks so they land in the file namespace.
grep -Fq -- '--activity-kind file' "$ROOT/bin/omarchy-menu-file" ||
  fail "menu file records picks as files"
pass "menu file records picks as files"

# End to end: a twice-picked older file floats above a newer untouched one.
fake_home="$test_tmp/home"
mkdir -p "$fake_home" "$test_tmp/pics"
touch -d '2026-01-01' "$test_tmp/pics/old.jpg"
touch -d '2026-09-01' "$test_tmp/pics/new.jpg"
cat >"$mock_bin/omarchy-activity" <<'SH'
#!/bin/bash
HOME="$OMARCHY_TEST_HOME" exec "$OMARCHY_TEST_REAL_ACTIVITY" "$@"
SH
cat >"$mock_bin/omarchy-menu-select" <<'SH'
#!/bin/bash
cat >"$OMARCHY_TEST_OPTIONS"
SH
chmod +x "$mock_bin/omarchy-activity" "$mock_bin/omarchy-menu-select"
export OMARCHY_TEST_HOME="$fake_home"
export OMARCHY_TEST_REAL_ACTIVITY="$ROOT/bin/omarchy-activity"
export OMARCHY_TEST_OPTIONS="$test_tmp/options"
export OMARCHY_TEST_ACTIVITY_AVAILABLE=true
HOME="$fake_home" "$ROOT/bin/omarchy-activity" record file "$test_tmp/pics/old.jpg" >/dev/null
HOME="$fake_home" "$ROOT/bin/omarchy-activity" record file "$test_tmp/pics/old.jpg" >/dev/null
"$ROOT/bin/omarchy-menu-file" "Select image" "$test_tmp/pics" "jpg" --width 100 >/dev/null
[[ $(head -n 1 "$OMARCHY_TEST_OPTIONS") == "$test_tmp/pics/old.jpg" ]] ||
  fail "menu file floats frecency-ranked files first" "$(cat "$OMARCHY_TEST_OPTIONS")"
pass "menu file floats frecency-ranked files first"