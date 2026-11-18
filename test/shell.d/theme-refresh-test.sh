#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
omarchy_path="$test_tmp/omarchy"
mock_bin="$test_tmp/bin"
mkdir -p "$test_home/.local/state/omarchy/current" "$omarchy_path/default/themed" "$mock_bin"
echo 'tokyo-night' >"$test_home/.local/state/omarchy/current/theme.name"
echo 'a = "{{ accent }}"' >"$omarchy_path/default/themed/app.conf.tpl"
stamp="$test_home/.local/state/omarchy/theme-templates.sha256"

# Records each theme set, and fails when asked to.
cat >"$mock_bin/omarchy-theme-set" <<'STUB'
#!/bin/bash
[[ $OMARCHY_THEME_WAIT == "1" && $OMARCHY_THEME_SKIP_BACKGROUND == "1" ]] || exit 2
echo "$1" >>"$TEST_TMP/sets"
[[ ${OMARCHY_TEST_SET_FAIL:-0} != "1" ]]
STUB
chmod +x "$mock_bin/omarchy-theme-set"

refresh() {
  HOME="$test_home" OMARCHY_PATH="$omarchy_path" TEST_TMP="$test_tmp" PATH="$mock_bin:$PATH" \
    "$ROOT/bin/omarchy-theme-refresh" "$@"
}

sets() {
  [[ -f $test_tmp/sets ]] && wc -l <"$test_tmp/sets" || echo 0
}

refresh --if-changed || fail "a first conditional refresh succeeds"
[[ $(sets) == 1 && $(cat "$test_tmp/sets") == "tokyo-night" ]] || fail "a first conditional refresh sets the current theme"
[[ -s $stamp ]] || fail "a refresh records the templates it rendered"
pass "with no record of a render, the current theme is refreshed and recorded"

refresh --if-changed || fail "an unchanged conditional refresh succeeds"
[[ $(sets) == 1 ]] || fail "unchanged templates refresh the theme again"
pass "unchanged templates leave the theme alone"

echo 'b = "{{ background }}"' >>"$omarchy_path/default/themed/app.conf.tpl"
refresh --if-changed
[[ $(sets) == 2 ]] || fail "an edited template does not refresh the theme"
echo 'c = "{{ accent }}"' >"$omarchy_path/default/themed/new.conf.tpl"
refresh --if-changed
[[ $(sets) == 3 ]] || fail "an added template does not refresh the theme"
rm "$omarchy_path/default/themed/new.conf.tpl"
refresh --if-changed
[[ $(sets) == 4 ]] || fail "a removed template does not refresh the theme"
mkdir -p "$test_home/.config/omarchy/themed"
echo 'd = "{{ accent }}"' >"$test_home/.config/omarchy/themed/mine.conf.tpl"
refresh --if-changed
[[ $(sets) == 5 ]] || fail "a user template does not refresh the theme"
pass "an edited, added or removed template, Omarchy's or the user's, refreshes the theme"

echo 'e = "{{ accent }}"' >>"$omarchy_path/default/themed/app.conf.tpl"
before=$(cat "$stamp")
if OMARCHY_TEST_SET_FAIL=1 refresh --if-changed; then
  fail "a failed theme set passes for a refresh"
fi
[[ $(cat "$stamp") == "$before" ]] || fail "a failed refresh is recorded as rendered"
refresh --if-changed
[[ $(sets) == 7 ]] || fail "the next conditional refresh does not retry a failed one"
pass "a failed refresh is not recorded, so the next one retries it"

# Migrations refresh unconditionally; that render counts too.
echo 'f = "{{ accent }}"' >>"$omarchy_path/default/themed/app.conf.tpl"
refresh
refresh --if-changed
[[ $(sets) == 8 ]] || fail "a migration's refresh is not counted, so the update renders again"
pass "an unconditional refresh is recorded, so the update after a migration does not repeat it"

refresh
[[ $(sets) == 9 ]] || fail "an unconditional refresh is skipped when nothing changed"
pass "a plain refresh always sets the theme"

rm "$test_home/.local/state/omarchy/current/theme.name"
refresh --if-changed || fail "a refresh with no current theme fails"
[[ $(sets) == 9 ]] || fail "a refresh with no current theme sets one"
pass "with no current theme there is nothing to refresh"
