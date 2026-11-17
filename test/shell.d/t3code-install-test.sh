#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mock_bin="$test_tmp/bin"
mount_dir="$test_tmp/mount"
export TEST_TMP="$test_tmp"
mkdir -p "$mock_bin" "$mount_dir"

# Run the real theme refresh, renderer and publisher in a throwaway home.
# Only the app install, the AppImage mount, the channel prompt and the desktop
# launch are stubbed.
cat >"$mock_bin/omarchy-install-t3code-app" <<'SH'
#!/bin/bash
echo "$1" >"$TEST_TMP/channel"
mkdir -p "$HOME/.local/share/t3code"
cp "$TEST_TMP/fake-appimage" "$HOME/.local/share/t3code/T3-Code.AppImage"
SH

# The runtime prints its mount point and stays mounted until it is killed.
cat >"$test_tmp/fake-appimage" <<SH
#!/bin/bash
[[ \$1 == "--appimage-mount" ]] || exit 1
echo "\$\$" >"$test_tmp/mounter.pid"
echo "$mount_dir"
exec sleep 30
SH
chmod +x "$test_tmp/fake-appimage"

cat >"$mount_dir/t3code" <<'SH'
#!/bin/bash
[[ $ELECTRON_RUN_AS_NODE == "1" && $1 == "$(dirname "$0")/resources/app.asar/apps/server/dist/bin.mjs" ]] || exit 1
shift
[[ $1 == "theme" && $2 == "set" && $3 == "omarchy" && $4 == "--base-dir" && $5 == "$T3CODE_HOME" ]] || exit 1
palette="$T3CODE_HOME/userdata/themes/omarchy.json"
if [[ ! -f $palette ]] || ! jq -e '.name == "Omarchy" and (.accent | test("^#[0-9a-fA-F]{6}$"))' "$palette" >/dev/null; then
  echo "No published Omarchy theme"
  exit 1
fi
if [[ ${OMARCHY_TEST_T3_FAIL:-0} == "1" ]]; then
  echo "T3 theme selection failed"
  exit 1
fi
if [[ ${OMARCHY_TEST_T3_HANG:-0} == "1" ]]; then
  touch "$TEST_TMP/cli-started"
  exec sleep 30
fi
echo "T3 selected Omarchy"
SH

cat >"$mock_bin/gum" <<'SH'
#!/bin/bash
[[ $1 == "choose" && $2 == "--header" && $3 == "Install T3 Code from which channel?" ]] || exit 1
[[ $4 == "Stable" && $5 == "Nightly" ]] || exit 1
echo "${OMARCHY_TEST_GUM_PICK:-Stable}"
SH

cat >"$mock_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
echo "$*" >"$TEST_TMP/dropped"
SH

# The launch is backgrounded, so each run names its own record.
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
touch "$TEST_TMP/launched-${OMARCHY_TEST_RUN:-default}"
SH
chmod +x "$mock_bin"/* "$mount_dir/t3code"

mkdir -p "$test_tmp/tmp"
run_installer() {
  TMPDIR="$test_tmp/tmp" HOME="$test_home" T3CODE_HOME="$test_tmp/custom t3 home" \
    OMARCHY_PATH="$ROOT" PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_THEME_HEADLESS=1 XDG_RUNTIME_DIR="$test_tmp" \
    "$ROOT/bin/omarchy-install-ai-t3-code" "$@" >"$test_tmp/output" 2>&1
}

state="$test_home/.local/state/omarchy/current"
palette="$test_tmp/custom t3 home/userdata/themes/omarchy.json"
settings="$test_tmp/custom t3 home/userdata/settings.json"
mkdir -p "$state/theme"
echo 'tokyo-night' >"$state/theme.name"
cp "$ROOT/themes/tokyo-night/colors.toml" "$state/theme/colors.toml"

OMARCHY_TEST_GUM_PICK=Nightly run_installer || fail "installing after an update succeeds" "$(cat "$test_tmp/output")"
[[ $(cat "$test_tmp/channel") == "nightly" ]] || fail "the channel picked at the prompt is installed"
[[ -f $state/theme/t3code.json && -f $palette ]] || fail "the missing palette is rendered and published"
cmp -s "$state/theme/t3code.json" "$palette" || fail "T3 receives the current theme's palette"
grep -q 'T3 selected Omarchy' "$test_tmp/output" || fail "the published palette is selected"
grep -q 'Opening T3 Code' "$test_tmp/output" || fail "the themed app opens"
[[ $(cat "$test_tmp/dropped") == "t3code-bin t3code-nightly-bin" ]] || fail "the T3 Code packages go once the app is themed"
[[ ! -e $test_home/.t3 ]] || fail "the custom T3 home is respected"
pass "an update with no staged T3 palette renders, publishes and selects it before launch"

if kill -0 "$(cat "$test_tmp/mounter.pid")" 2>/dev/null; then
  fail "the AppImage is unmounted once its CLI has run"
fi
pass "the AppImage is unmounted once its CLI has run"

OMARCHY_TEST_GUM_PICK=Stable run_installer || fail "installing stable succeeds" "$(cat "$test_tmp/output")"
[[ $(cat "$test_tmp/channel") == "stable" ]] || fail "Stable at the prompt installs the stable channel"
pass "the prompt chooses between the stable and nightly channels"

# Preserve an already rendered palette, including a user-supplied color.
jq '.accent = "#abcdef"' "$state/theme/t3code.json" >"$test_tmp/palette.json"
cp "$test_tmp/palette.json" "$state/theme/t3code.json"
run_installer stable || fail "installing with an existing palette succeeds" "$(cat "$test_tmp/output")"
cmp -s "$test_tmp/palette.json" "$palette" || fail "an existing palette is published without re-staging"
pass "an existing palette is used without refreshing the current theme"

rm -f "$test_tmp/channel"
OMARCHY_TEST_RUN=no-launch run_installer nightly --no-launch || fail "installing without a launch succeeds" "$(cat "$test_tmp/output")"
[[ $(cat "$test_tmp/channel") == "nightly" ]] || fail "the named channel is installed without a prompt"
grep -q 'T3 selected Omarchy' "$test_tmp/output" || fail "the palette is selected without a launch"
if [[ -f $test_tmp/launched-no-launch ]] || grep -q 'Opening T3 Code' "$test_tmp/output"; then
  fail "--no-launch leaves T3 Code closed" "$(cat "$test_tmp/output")"
fi
pass "--no-launch installs and themes the named channel without opening T3 Code"

rm -f "$test_tmp/dropped"
printf '{"defaultTheme":"dark","keep":"existing settings"}\n' >"$settings"
cp "$settings" "$test_tmp/settings-before.json"
if OMARCHY_TEST_T3_FAIL=1 run_installer stable; then
  fail "a failed T3 theme selection fails the installer"
fi
grep -q 'T3 theme selection failed' "$test_tmp/output" || fail "the CLI failure is visible"
if grep -Eq 'Opening T3 Code|T3 Code has been installed' "$test_tmp/output"; then
  fail "a failed selection does not report successful setup"
fi
cmp -s "$test_tmp/settings-before.json" "$settings" || fail "a failed selection does not rewrite settings"
[[ ! -e $test_tmp/dropped ]] || fail "a failed selection keeps the package, so the migration retries"
pass "a CLI failure remains visible and leaves the existing settings and package intact"

# Ctrl-C reaches the installer's whole process group, but the background
# mounter ignores it, so the installer has to unmount on its way out.
rm -f "$test_tmp/cli-started" "$test_tmp/mounter.pid"
set -m
OMARCHY_TEST_T3_HANG=1 run_installer stable &
installer=$!
set +m
for _ in {1..100}; do
  [[ -f $test_tmp/cli-started ]] && break
  sleep 0.1
done
[[ -f $test_tmp/cli-started ]] || fail "an interrupted install reaches the CLI" "$(cat "$test_tmp/output")"
kill -INT -- "-$installer"
status=0
wait "$installer" || status=$?
((status != 0)) || fail "an interrupted install does not report success"
[[ ! -e $test_tmp/dropped ]] || fail "an interrupted install keeps the package"
mounter=$(cat "$test_tmp/mounter.pid")
for _ in {1..50}; do
  kill -0 "$mounter" 2>/dev/null || break
  sleep 0.1
done
if kill -0 "$mounter" 2>/dev/null; then
  fail "an interrupted install unmounts the AppImage"
fi
[[ -z $(find "$test_tmp/tmp" -name mount) ]] || fail "an interrupted install removes its mount record"
pass "an interrupted install unmounts the AppImage and cleans up"
