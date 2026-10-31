#!/bin/bash

# Unknown menu flags (e.g. a typo'd --widht) must fail loudly instead of being
# silently ignored. A stubbed omarchy-shell completes the file-based menu
# protocol so the real CLI scripts must return a selection and exit normally.
# This covers the CLI boundary, not a live compositor or Quickshell session.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

# Write the selection before doneFile, just like Menu.finishRequest().
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
set -euo pipefail
[[ $# == 4 && $1 == "shell" && $2 == "summon" && $3 == "omarchy.menu" ]]
touch "$TEST_TMP/shell-called"
printf '%s' "$4" >"$TEST_TMP/payload"
perl -MJSON::PP=decode_json -e '
  my $payload = decode_json($ARGV[0]);
  my $selection = $payload->{mode} eq "input" ? "15 minutes" : $payload->{options}[1];
  defined($selection) or die "no selection";
  open my $selected, ">", $payload->{selectionFile} or die $!;
  print {$selected} "$selection\n";
  close $selected or die $!;
  open my $done, ">", $payload->{doneFile} or die $!;
  close $done or die $!;
' "$4"
SH
chmod +x "$mock_bin/omarchy-shell"
mkdir -p "$test_tmp/tmp files" "$test_tmp/home"

run() {
  rm -f "$test_tmp/shell-called" "$test_tmp/payload"
  local err="$test_tmp/stderr" code
  if HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" TMPDIR="$test_tmp/tmp files" TEST_TMP="$test_tmp" \
    PATH="$mock_bin:$PATH" timeout --kill-after=1 3 bash "$ROOT/bin/$1" "${@:2}" >"$test_tmp/stdout" 2>"$err"; then
    code=0
  else
    code=$?
  fi
  printf '%s' "$code|$err"
}

# 1. menu-input rejects an unknown flag before touching the shell
result=$(run omarchy-menu-input "Reminder" --widht 400)
code="${result%%|*}"
err="${result#*|}"
[[ $code == "1" ]] || fail "menu-input rejects --widht (exit $code)" "$(cat "$err")"
grep -q "unknown option: --widht" "$err" || fail "menu-input names the bad flag" "$(cat "$err")"
[[ ! -e $test_tmp/shell-called ]] || fail "menu-input rejects --widht before the summon"

# 2. menu-select rejects an unknown flag after --
result=$(run omarchy-menu-select "Pick" -- --widht 400)
code="${result%%|*}"
err="${result#*|}"
[[ $code == "1" ]] || fail "menu-select rejects --widht (exit $code)" "$(cat "$err")"
grep -q "unknown option: --widht" "$err" || fail "menu-select names the bad flag" "$(cat "$err")"
[[ ! -e $test_tmp/shell-called ]] || fail "menu-select rejects --widht before the summon"

# 3. menu-select rejects an unknown flag mixed with valid ones
result=$(run omarchy-menu-select "Pick" a b -- --width 400 --bogus)
code="${result%%|*}"
err="${result#*|}"
[[ $code == "1" ]] || fail "menu-select rejects --bogus (exit $code)" "$(cat "$err")"
grep -q "unknown option: --bogus" "$err" || fail "menu-select names the bad flag among valid ones" "$(cat "$err")"
[[ ! -e $test_tmp/shell-called ]] || fail "menu-select rejects --bogus before the summon"

# 4. menu-input accepts --width and returns the entered text
result=$(run omarchy-menu-input "Reminder" --width 400)
code="${result%%|*}"
[[ $code == "0" ]] || fail "menu-input --width completes normally (exit $code)" "$(cat "$test_tmp/stderr")"
[[ $(cat "$test_tmp/stdout") == "15 minutes" ]] || fail "menu-input returns the entered text" "$(cat "$test_tmp/stdout")"
[[ -e $test_tmp/shell-called ]] || fail "menu-input --width reaches the summon"
grep -q '"width":400' "$test_tmp/payload" || fail "menu-input forwards --width 400" "$(cat "$test_tmp/payload")"

# 5. menu-select accepts --width/--height and returns the chosen option
result=$(run omarchy-menu-select "Pick" a b -- --width 400 --height 300)
code="${result%%|*}"
[[ $code == "0" ]] || fail "menu-select flags complete normally (exit $code)" "$(cat "$test_tmp/stderr")"
[[ $(cat "$test_tmp/stdout") == "b" ]] || fail "menu-select returns the chosen option" "$(cat "$test_tmp/stdout")"
grep -q '"width":400' "$test_tmp/payload" || fail "menu-select forwards --width 400"
grep -q '"maxHeight":300' "$test_tmp/payload" || fail "menu-select maps --height to maxHeight"

# 6. missing values still error as before
result=$(run omarchy-menu-input "Reminder" --width)
code="${result%%|*}"
err="${result#*|}"
[[ $code == "1" ]] || fail "menu-input --width without a value exits 1 (exit $code)"
grep -q "requires a value" "$err" || fail "menu-input --width without a value explains itself"
[[ ! -e $test_tmp/shell-called ]] || fail "menu-input rejects missing width before the summon"

result=$(printf 'a\n' | run omarchy-menu-select "Pick" -- --maxheight)
code="${result%%|*}"
[[ $code == "1" ]] || fail "menu-select --maxheight without a value exits 1 (exit $code)"
err="${result#*|}"
grep -q "requires a value" "$err" || fail "menu-select --maxheight without a value explains itself"
[[ ! -e $test_tmp/shell-called ]] || fail "menu-select rejects missing maxheight before the summon"

pass "menu-input and menu-select reject unknown flags loudly"
