#!/bin/bash

# Unknown menu flags (e.g. a typo'd --widht) must fail loudly instead of being
# silently ignored. A stubbed omarchy-shell records whether arg parsing ever
# reached the summon; the real summon needs a live compositor, so the happy
# path is proven by reaching the stub (the script then waits on done_file and
# the timeout kills it).

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

# Records the summon payload ($4) and that the shell was reached, then exits 0
# without creating done_file: callers spin until the timeout.
cat >"$mock_bin/omarchy-shell" <<SH
#!/bin/bash
touch "$test_tmp/shell-called"
printf '%s' "\$4" >"$test_tmp/payload"
exit 0
SH
chmod +x "$mock_bin/omarchy-shell"

run() {
  rm -f "$test_tmp/shell-called" "$test_tmp/payload"
  local err="$test_tmp/stderr"
  set +e
  PATH="$mock_bin:$PATH" timeout 3 bash "$ROOT/bin/$1" "${@:2}" 2>"$err"
  printf '%s' "$?|$err"
  set -e
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

# 4. menu-input still accepts --width and forwards it (reaches the summon)
result=$(run omarchy-menu-input "Reminder" --width 400)
code="${result%%|*}"
[[ $code == "124" ]] || fail "menu-input --width reaches the summon (exit $code)"
[[ -e $test_tmp/shell-called ]] || fail "menu-input --width reaches the summon"
grep -q '"width":400' "$test_tmp/payload" || fail "menu-input forwards --width 400" "$(cat "$test_tmp/payload")"

# 5. menu-select still accepts --width/--height/--maxheight and forwards them
result=$(run omarchy-menu-select "Pick" a b -- --width 400 --height 300)
code="${result%%|*}"
[[ $code == "124" ]] || fail "menu-select flags reach the summon (exit $code)"
grep -q '"width":400' "$test_tmp/payload" || fail "menu-select forwards --width 400"
grep -q '"maxHeight":300' "$test_tmp/payload" || fail "menu-select maps --height to maxHeight"

# 6. missing values still error as before
result=$(run omarchy-menu-input "Reminder" --width)
code="${result%%|*}"
err="${result#*|}"
[[ $code == "1" ]] || fail "menu-input --width without a value exits 1 (exit $code)"
grep -q "requires a value" "$err" || fail "menu-input --width without a value explains itself"

result=$(printf 'a\n' | run omarchy-menu-select "Pick" -- --maxheight)
code="${result%%|*}"
[[ $code == "1" ]] || fail "menu-select --maxheight without a value exits 1 (exit $code)"

pass "menu-input and menu-select reject unknown flags loudly"
