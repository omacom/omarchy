#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

test_home="$scratch/home"
state="$test_home/.local/state/omarchy/current"
shipped="$scratch/omarchy"
stub_bin="$scratch/bin"
mkdir -p "$stub_bin" "$scratch/runtime" "$scratch/temporary"

cat >"$stub_bin/omarchy-theme-set-templates" <<'STUB'
#!/bin/bash
[[ ${TEST_FAILURE:-} != "renderer" ]] || exit 42
if [[ ${TEST_FAILURE:-} == "cancel-render" ]]; then
  kill -TERM "$PPID"
  exit 42
fi
exec "$ROOT/bin/omarchy-theme-set-templates" "$@"
STUB

cat >"$stub_bin/omarchy-theme-color" <<'STUB'
#!/bin/bash
[[ ${TEST_FAILURE:-} != "palette" ]] || exit 42
exec "$ROOT/bin/omarchy-theme-color" "$@"
STUB

cat >"$stub_bin/omarchy-theme-colors-from-alacritty" <<'STUB'
#!/bin/bash
[[ ${TEST_FAILURE:-} != "legacy-palette" ]] || exit 42
exec "$ROOT/bin/omarchy-theme-colors-from-alacritty" "$@"
STUB

cat >"$stub_bin/cp" <<'STUB'
#!/bin/bash
for arg in "$@"; do
  case ${TEST_FAILURE:-}:$arg in
    builtin-copy:"$OMARCHY_PATH/themes/new/"* | user-copy:"$HOME/.config/omarchy/themes/new/"* | nested-copy:*/nested/keep.txt)
      exit 42
      ;;
  esac
done
exec /usr/bin/cp "$@"
STUB

cat >"$stub_bin/mv" <<'STUB'
#!/bin/bash
if [[ ${TEST_FAILURE:-} == "cancel-publish" && ${*: -1} == "$TEST_STATE/theme" ]]; then
  kill -TERM "$PPID"
fi
case ${TEST_FAILURE:-}:${*: -1} in
  replacement:"$TEST_STATE/theme" | name:"$TEST_STATE/theme.name" | override-write:"$TEST_STATE/next-theme/shell.toml")
    exit 42
    ;;
esac
exec /usr/bin/mv "$@"
STUB

cat >"$stub_bin/sed" <<'STUB'
#!/bin/bash
if [[ ${TEST_FAILURE:-} == "template" && $1 == "-f" ]]; then exit 42; fi
exec /usr/bin/sed "$@"
STUB

cat >"$stub_bin/awk" <<'STUB'
#!/bin/bash
if [[ ${TEST_FAILURE:-} == "override-read" && ${*: -1} == "$TEST_STATE/next-theme/shell.bar.toml" ]]; then exit 42; fi
exec /usr/bin/awk "$@"
STUB

cat >"$stub_bin/flock" <<'STUB'
#!/bin/bash
[[ ${TEST_FAILURE:-} != "lock" ]] || exit 42
exec /usr/bin/flock "$@"
STUB

cat >"$stub_bin/omarchy-shell" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_IPC"
STUB
chmod +x "$stub_bin/"*

reset_fixture() {
  rm -rf "$test_home" "$shipped" "$scratch/expected"
  mkdir -p "$state/theme" "$shipped/themes/new" "$shipped/default/themed" "$scratch/expected"
  printf 'previous working configuration\n' >"$state/theme/working.conf"
  printf 'previous image\n' >"$state/theme/background.png"
  printf 'old-theme\n' >"$state/theme.name"
  ln -s "$state/theme/background.png" "$state/background"
  cp -a "$state/." "$scratch/expected/"
  cp "$ROOT/themes/tokyo-night/colors.toml" "$shipped/themes/new/colors.toml"
  printf 'accent={{ accent }}\n' >"$shipped/default/themed/example.conf.tpl"
  printf '[bar]\nbackground = "{{ background }}"\n' >"$shipped/default/themed/shell.toml.tpl"
  : >"$scratch/ipc"
}

run_theme() {
  HOME="$test_home" OMARCHY_PATH="$shipped" PATH="$stub_bin:$ROOT/bin:$PATH" \
    XDG_RUNTIME_DIR="$scratch/runtime" TMPDIR="$scratch/temporary" \
    TEST_STATE="$state" TEST_IPC="$scratch/ipc" TEST_FAILURE="${1:-}" \
    OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
    bash "$ROOT/bin/omarchy-theme-set" new >"$scratch/output" 2>&1
}

assert_previous() {
  diff -r "$scratch/expected/theme" "$state/theme" || fail "previous theme files survive"
  cmp "$scratch/expected/theme.name" "$state/theme.name" || fail "previous theme name survives"
  [[ $(readlink "$state/background") == "$(readlink "$scratch/expected/background")" ]] || fail "previous background link survives"
  [[ ! -e $state/next-theme && ! -L $state/next-theme ]] || fail "failed staging is cleaned up"
  [[ ! -s $scratch/ipc ]] || fail "failed activation does not notify the shell"
  [[ -z $(find "$scratch/temporary" -mindepth 1 -print -quit) ]] || fail "renderer scratch files are cleaned up"
  [[ -z $(find "$state" -name '.theme.name.*' -print -quit) ]] || fail "staged name is cleaned up"
}

expect_failure() {
  local failure="$1" description="$2"
  if run_theme "$failure"; then
    fail "$description returns failure" "$(cat "$scratch/output")"
  fi
  assert_previous
  pass "$description preserves the working theme, name, and background"
}

for failure in lock renderer cancel-render builtin-copy palette template replacement name; do
  reset_fixture
  expect_failure "$failure" "$failure failure"
done

reset_fixture
mkdir -p "$test_home/.config/omarchy/themes/new"
printf 'user customization\n' >"$test_home/.config/omarchy/themes/new/custom.conf"
expect_failure user-copy "user overlay copy failure"

reset_fixture
mkdir -p "$test_home/.config/omarchy/themes/new/.git" "$test_home/.config/omarchy/themes/new/nested"
printf 'nested customization\n' >"$test_home/.config/omarchy/themes/new/nested/keep.txt"
expect_failure nested-copy "nested installed-theme copy failure"

for failure in override-read override-write; do
  reset_fixture
  printf 'background = "#123456"\n' >"$shipped/themes/new/shell.bar.toml"
  expect_failure "$failure" "$failure failure"
done

for kind in local installed; do
  reset_fixture
  rm -rf "$shipped/themes/new"
  mkdir -p "$test_home/.config/omarchy/themes/new"
  if [[ $kind == "installed" ]]; then mkdir "$test_home/.config/omarchy/themes/new/.git"; fi
  printf '[colors.normal]\nblack = "#000000"\n' >"$test_home/.config/omarchy/themes/new/alacritty.toml"
  expect_failure legacy-palette "$kind legacy palette conversion failure"
done

reset_fixture
run_theme || fail "a built-in theme works without a user overlay" "$(cat "$scratch/output")"
[[ $(cat "$state/theme.name") == "new" ]] || fail "successful activation publishes the name"
grep -Fx 'accent=#7aa2f7' "$state/theme/example.conf" >/dev/null || fail "successful activation publishes rendered templates"
[[ ! -e $state/theme/working.conf && ! -e $state/next-theme ]] || fail "successful activation replaces and cleans the previous theme"
run_theme || fail "an already applied theme can be refreshed" "$(cat "$scratch/output")"
pass "successful activation renders, replaces, and can be repeated without a user overlay"

reset_fixture
mkdir -p "$test_home/.config/omarchy/themes"
mv "$shipped/themes/new" "$test_home/.config/omarchy/themes/new"
run_theme || fail "a user-only theme works without a built-in theme" "$(cat "$scratch/output")"
grep -Fx 'accent=#7aa2f7' "$state/theme/example.conf" >/dev/null || fail "user-only theme renders"
pass "a missing built-in theme does not prevent a user-only theme from activating"

reset_fixture
rm -rf "$state/theme" "$state/theme.name" "$state/background"
if run_theme name; then fail "first activation reports failed name publication"; fi
[[ ! -e $state/theme && ! -e $state/theme.name && ! -e $state/next-theme ]] || fail "failed first activation leaves no partial current state"
run_theme || fail "first activation can retry successfully" "$(cat "$scratch/output")"
[[ -f $state/theme/example.conf && $(cat "$state/theme.name") == "new" ]] || fail "first activation publishes both files and name"
pass "first activation rolls back failed name publication and can retry"

reset_fixture
run_theme cancel-publish || fail "publication completes across a cancellation signal" "$(cat "$scratch/output")"
[[ -f $state/theme/example.conf && $(cat "$state/theme.name") == "new" ]] || fail "publication keeps the files and name consistent"
[[ ! -e $state/next-theme ]] || fail "publication cleans up the previous theme"
pass "cancellation cannot interrupt the directory and name commit"

reset_fixture
rm "$shipped/themes/new/colors.toml"
printf '[bar]\nbackground = "#111111"\n' >"$shipped/themes/new/shell.toml"
printf 'background = "#123456"\n' >"$shipped/themes/new/shell.bar.toml"
run_theme || fail "manual configs without a palette still activate" "$(cat "$scratch/output")"
grep -Fx 'background = "#123456"' "$state/theme/shell.toml" >/dev/null || fail "manual shell section override is applied"
pass "manual themes without colors.toml retain shell section overrides"
