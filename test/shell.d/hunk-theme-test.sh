#!/bin/bash

set -euo pipefail

# omarchy-theme-set-hunk publishes a palette another program parses, installs
# an extension beside it, and edits one line of the user's config. All three
# are exercised here against a throwaway HOME with the Hunk presence check
# stubbed, so a palette that stopped being validated, a config edit that lost
# the user's settings, or an activation that trampled a chosen theme shows up
# in what landed on disk.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "hunk" && ${OMARCHY_TEST_HUNK_INSTALLED:-1} == "1" ]]
SH
chmod +x "$mock_bin"/*

good_theme='{
  "base": "github-dark-default",
  "background": "#1a1b26",
  "text": "#a9b1d6",
  "accent": "#7aa2f7",
  "syntaxScopes": { "comment": "#565f89" }
}'

test_home="$test_tmp/home"
source_path="$test_home/.local/state/omarchy/current/theme/hunk.json"
hunk_dir="$test_home/.config/hunk"
config="$hunk_dir/config.toml"
theme="$hunk_dir/themes/omarchy.json"
extension="$hunk_dir/extensions/omarchy.js"

# Each case gets a fresh HOME so no file survives from the one before. --config
# writes the config Hunk would find; without it Hunk has never been configured.
reset_home() {
  local source="$good_theme"

  rm -rf "$test_home"
  mkdir -p "$(dirname "$source_path")"

  while (( $# > 0 )); do
    case "$1" in
      --config)
        mkdir -p "$hunk_dir"
        printf '%s' "$2" >"$config"
        shift
        ;;
      *) source="$1" ;;
    esac
    shift
  done

  printf '%s\n' "$source" >"$source_path"
}

run_hook() {
  OMARCHY_TEST_HUNK_INSTALLED="${OMARCHY_TEST_HUNK_INSTALLED:-1}" \
    PATH="$mock_bin:$PATH" \
    HOME="$test_home" \
    XDG_CONFIG_HOME="${OMARCHY_TEST_XDG_CONFIG_HOME:-}" \
    OMARCHY_PATH="$ROOT" \
    "$ROOT/bin/omarchy-theme-set-hunk" "$@"
}

# -- publishing ---------------------------------------------------------------

reset_home
OMARCHY_TEST_HUNK_INSTALLED=0 run_hook
[[ ! -e $hunk_dir ]] || fail "a machine without Hunk gets no Hunk config directory"
pass "a theme switch leaves a machine without Hunk alone"

reset_home
run_hook 2>"$test_tmp/stderr"
diff -q "$source_path" "$theme" >/dev/null || fail "the generated palette is published to ~/.config/hunk/themes/omarchy.json"
diff -q "$ROOT/config/hunk/extensions/omarchy.js" "$extension" >/dev/null || fail "the Omarchy extension is installed beside the palette"
[[ $(ls "$hunk_dir/themes") == "omarchy.json" && $(ls "$hunk_dir/extensions") == "omarchy.js" ]] ||
  fail "no temporary file is left beside the palette or the extension" "$(ls -R "$hunk_dir")"
[[ $(cat "$config") == 'theme = "omarchy"' ]] || fail "a Hunk that was never configured is put on the Omarchy theme" "$(cat "$config")"
[[ ! -s $test_tmp/stderr ]] || fail "a theme switch says nothing about Hunk" "$(cat "$test_tmp/stderr")"
pass "the palette, the extension and the theme selection land on a fresh Hunk"

reset_home
mkdir -p "$(dirname "$extension")"
echo '// changed by hand' >"$extension"
run_hook
[[ $(cat "$extension") == '// changed by hand' ]] || fail "an extension the user changed is kept"
pass "an existing extension is not overwritten"

reset_home
OMARCHY_TEST_XDG_CONFIG_HOME="$test_tmp/xdg" run_hook
[[ -f $test_tmp/xdg/hunk/themes/omarchy.json && -f $test_tmp/xdg/hunk/extensions/omarchy.js && -f $test_tmp/xdg/hunk/config.toml ]] ||
  fail "XDG_CONFIG_HOME is where Hunk looks, so that is where the files go" "$(ls -R "$test_tmp/xdg" 2>/dev/null)"
[[ ! -e $hunk_dir ]] || fail "nothing is written under ~/.config when XDG_CONFIG_HOME points elsewhere"
pass "the files follow XDG_CONFIG_HOME"

# Hunk rejects a theme whole on any value that is not #rrggbb, and the file is
# spread into a theme registration, so only Hunk's colour keys, a base id and
# hex syntax scopes may pass; the previous palette stays otherwise.
for bad in \
  '{"base": "github-dark-default", "background": "{{ background }}"}' \
  '{"background": "red"}' \
  '{"background": "#1a1b26", "label": "Evil"}' \
  '{"background": "#1a1b26", "id": "github-dark-default"}' \
  '{"base": "../../evil", "background": "#1a1b26"}' \
  '{"base": "github-dark-default"}' \
  '{"background": "#1a1b26", "syntaxScopes": {"comment": "red"}}' \
  '{"background": "#1a1b26", "syntaxScopes": "#1a1b26"}' \
  '["#1a1b26"]' \
  'not json'; do
  reset_home "$bad"
  mkdir -p "$(dirname "$theme")"
  echo '{"background": "#000000"}' >"$theme"
  run_hook 2>"$test_tmp/stderr"
  [[ $(cat "$theme") == '{"background": "#000000"}' ]] || fail "a palette that is not hex colours on Hunk's keys is not published" "$bad"
  grep -q 'not a plain color palette' "$test_tmp/stderr" || fail "a held-back palette is reported" "$bad"
  [[ ! -e $config ]] || fail "a held-back palette does not activate the theme" "$bad"
done
pass "a palette is held to the shape Hunk loads"

# -- the user's config --------------------------------------------------------

reset_home --config $'# my hunk\nline_numbers = false\n\n[pager]\nwrap_lines = true\n'
run_hook
[[ $(cat "$config") == $'# my hunk\nline_numbers = false\n\ntheme = "omarchy"\n\n[pager]\nwrap_lines = true' ]] ||
  fail "the theme is added as a top-level key before the first table, keeping the rest" "$(cat "$config")"
pass "a config without a theme gets one where top-level keys belong"

reset_home --config $'line_numbers = false\n'
run_hook
[[ $(cat "$config") == $'line_numbers = false\ntheme = "omarchy"' ]] || fail "a config with no tables gets the theme at the end" "$(cat "$config")"
pass "a config without tables gets the theme at the end"

reset_home --config $'[vcs]\ntheme = "github-light-default"\n'
run_hook
[[ $(cat "$config") == $'theme = "omarchy"\n\n[vcs]\ntheme = "github-light-default"' ]] ||
  fail "a theme under a command table is that command's; the top level still gets the Omarchy theme" "$(cat "$config")"
pass "a theme set for one command does not count as the top-level theme"

reset_home --config $'theme = "github-light-default"\nline_numbers = false\n'
run_hook 2>"$test_tmp/stderr"
[[ $(cat "$config") == $'theme = "github-light-default"\nline_numbers = false' ]] || fail "a theme chosen in Hunk's config is left" "$(cat "$config")"
[[ -f $theme && -f $extension ]] || fail "a chosen theme still gets the Omarchy palette published beside it"
[[ ! -s $test_tmp/stderr ]] || fail "a chosen theme is left without comment on a theme switch" "$(cat "$test_tmp/stderr")"
pass "a theme switch leaves a theme the user chose in Hunk"

for line in 'theme = "omarchy"' "theme = 'omarchy'" 'theme="omarchy"' 'theme = "omarchy" # via Omarchy'; do
  reset_home --config "$line"$'\nline_numbers = false\n'
  run_hook
  [[ $(cat "$config") == "$line"$'\nline_numbers = false' ]] || fail "a config already on the Omarchy theme is not rewritten" "$(cat "$config")"
done
pass "a config already on the Omarchy theme is left as it is"

# -- activation ---------------------------------------------------------------

reset_home --config $'theme = "github-light-default" # chosen\nline_numbers = false\n\n[pager]\ntheme = "auto"\n'
run_hook --activate 2>"$test_tmp/stderr"
[[ $(cat "$config") == $'theme = "omarchy"\nline_numbers = false\n\n[pager]\ntheme = "auto"' ]] ||
  fail "--activate replaces the top-level theme line and nothing else" "$(cat "$config")"
grep -q "'github-light-default' theme" "$test_tmp/stderr" || fail "--activate says which theme it replaced"
grep -q 'on the Omarchy theme' "$test_tmp/stderr" || fail "--activate reports success"
pass "--activate replaces a theme the user chose"

reset_home --config $'theme = "omarchy"\n'
run_hook --activate 2>"$test_tmp/stderr"
[[ $(cat "$config") == 'theme = "omarchy"' ]] || fail "--activate leaves a config already on the theme alone" "$(cat "$config")"
grep -q 'on the Omarchy theme' "$test_tmp/stderr" || fail "--activate reports a Hunk already on the theme"
pass "--activate is idempotent"

reset_home
if OMARCHY_TEST_HUNK_INSTALLED=0 run_hook --activate 2>"$test_tmp/stderr"; then
  fail "--activate fails without Hunk"
fi
grep -q 'not installed' "$test_tmp/stderr" || fail "a missing Hunk is reported"
pass "--activate fails on a machine without Hunk"

# -- a palette the current theme has not rendered yet -----------------------------

reset_home
rm "$source_path"
run_hook
[[ ! -e $hunk_dir ]] || fail "a theme switch without a rendered palette writes nothing"
pass "a theme switch has nothing to do without a rendered palette"

reset_home
rm "$source_path"
if run_hook --activate 2>"$test_tmp/stderr"; then
  fail "--activate fails when no palette has been rendered"
fi
grep -q 'omarchy-theme-refresh' "$test_tmp/stderr" || fail "a missing palette says how to render one"
pass "--activate fails without a rendered palette and says what to do"
