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
if [[ -n ${OMARCHY_UPDATE_LOCK_FD:-} && -e /proc/$$/fd/$OMARCHY_UPDATE_LOCK_FD ]]; then
  touch "$TEST_TMP/inherited-update-lock"
fi
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

# Dotfile managers link templates in; the renderer reads what the link points at.
mkdir -p "$test_tmp/dotfiles"
echo 'g = "{{ accent }}"' >"$test_tmp/dotfiles/linked.conf.tpl"
ln -s "$test_tmp/dotfiles/linked.conf.tpl" "$test_home/.config/omarchy/themed/linked.conf.tpl"
refresh --if-changed
[[ $(sets) == 6 ]] || fail "a linked user template does not refresh the theme"
echo 'h = "{{ background }}"' >>"$test_tmp/dotfiles/linked.conf.tpl"
refresh --if-changed
[[ $(sets) == 7 ]] || fail "editing a linked template's target does not refresh the theme"
echo 'not a template' >"$test_home/.config/omarchy/themed/notes.txt"
refresh --if-changed
[[ $(sets) == 7 ]] || fail "a file the renderer ignores refreshes the theme"
pass "a linked template counts by its target, and files the renderer ignores do not count"

# A dangling link sorting first must not hide edits to the templates after it.
ln -s "$test_tmp/dotfiles/gone.conf.tpl" "$test_home/.config/omarchy/themed/a-broken.conf.tpl"
refresh --if-changed || fail "a refresh with a broken template link fails"
[[ $(sets) == 8 ]] || fail "a broken template link does not refresh the theme"
echo 'i = "{{ accent }}"' >>"$test_tmp/dotfiles/linked.conf.tpl"
refresh --if-changed
[[ $(sets) == 9 ]] || fail "a broken link hides an edit to a later template"
pass "a broken template link neither fails the refresh nor hides later edits"

echo 'e = "{{ accent }}"' >>"$omarchy_path/default/themed/app.conf.tpl"
before=$(cat "$stamp")
if OMARCHY_TEST_SET_FAIL=1 refresh --if-changed; then
  fail "a failed theme set passes for a refresh"
fi
[[ $(cat "$stamp") == "$before" ]] || fail "a failed refresh is recorded as rendered"
refresh --if-changed
[[ $(sets) == 11 ]] || fail "the next conditional refresh does not retry a failed one"
pass "a failed refresh is not recorded, so the next one retries it"

# Migrations refresh unconditionally; that render counts too.
echo 'f = "{{ accent }}"' >>"$omarchy_path/default/themed/app.conf.tpl"
refresh
refresh --if-changed
[[ $(sets) == 12 ]] || fail "a migration's refresh is not counted, so the update renders again"
pass "an unconditional refresh is recorded, so the update after a migration does not repeat it"

refresh
[[ $(sets) == 13 ]] || fail "an unconditional refresh is skipped when nothing changed"
pass "a plain refresh always sets the theme"

# omarchy update holds its lock on an inherited descriptor. Work the theme set
# leaves running must not keep it, or the next update reports one still running.
exec {update_lock}>"$test_tmp/update.lock"
OMARCHY_UPDATE_LOCK_FD=$update_lock refresh
exec {update_lock}>&-
[[ $(sets) == 14 ]] || fail "a refresh under the update lock does not set the theme"
[[ ! -e $test_tmp/inherited-update-lock ]] || fail "the theme set inherits omarchy update's lock"
pass "the theme set runs without omarchy update's lock"

rm "$test_home/.local/state/omarchy/current/theme.name"
refresh --if-changed || fail "a refresh with no current theme fails"
[[ $(sets) == 14 ]] || fail "a refresh with no current theme sets one"
pass "with no current theme there is nothing to refresh"
