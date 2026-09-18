#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" "$test_home/.local/share/applications"

cat >"$mock_bin/xdg-settings" <<'MOCK'
#!/bin/bash
echo test-browser.desktop
MOCK
cat >"$mock_bin/test-browser" <<'MOCK'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_HELP_LOG"
[[ ${OMARCHY_TEST_BROWSER_FAMILY:-} == "mozilla" ]] && echo MOZ_LOG
exit 0
MOCK
cp "$mock_bin/test-browser" "$mock_bin/test-edge"
cat >"$mock_bin/systemd-run" <<'MOCK'
#!/bin/bash
while (( $# )) && [[ $1 != "uwsm-app" ]]; do shift; done
shift 3 # uwsm-app -- browser
if (( $# )); then
  printf '%s\0' "$@" >"$OMARCHY_TEST_ARGS_LOG"
else
  : >"$OMARCHY_TEST_ARGS_LOG"
fi
MOCK
cat >"$mock_bin/omarchy-hyprland-focus-app" <<'MOCK'
#!/bin/bash
exit 0
MOCK
chmod +x "$mock_bin"/*

run_launcher() {
  local browser=$1 family=$2
  shift 2
  printf '[Desktop Entry]\nExec=%s %%U\n' "$browser" >"$test_home/.local/share/applications/test-browser.desktop"
  rm -f "$test_tmp/help" "$test_tmp/args"
  HOME="$test_home" PATH="$mock_bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE="" \
    OMARCHY_TEST_BROWSER_FAMILY="$family" OMARCHY_TEST_HELP_LOG="$test_tmp/help" \
    OMARCHY_TEST_ARGS_LOG="$test_tmp/args" bash "$ROOT/bin/omarchy-launch-browser" "$@"
}

assert_args() {
  local actual=() expected=("$@")
  mapfile -d '' -t actual <"$test_tmp/args"
  (( ${#actual[@]} == ${#expected[@]} )) || fail "argument count is preserved"
  for i in "${!expected[@]}"; do
    [[ ${actual[i]} == "${expected[i]}" ]] || fail "argument $i is preserved" "actual: ${actual[i]}"
  done
}

for family in chromium mozilla; do
  run_launcher test-browser "$family"
  [[ ! -e $test_tmp/help ]] || fail "normal $family launch skips browser help"
  assert_args

  url='https://example.test/--private?q=two words&literal=$HOME'
  run_launcher test-browser "$family" "$url" --profile-directory='Work profile'
  [[ ! -e $test_tmp/help ]] || fail "URL launch skips browser help"
  assert_args "$url" --profile-directory='Work profile'
done
pass "normal windows and URLs skip browser help and preserve arguments"

for family in chromium mozilla edge; do
  browser=test-browser
  case $family in
  chromium) flag=--incognito ;;
  mozilla) flag=--private-window ;;
  edge) browser=test-edge; flag=--inprivate ;;
  esac
  run_launcher "$browser" "$family" "$url" --private --profile-directory='Work profile' --private
  assert_args "$url" "$flag" --profile-directory='Work profile' "$flag"
  [[ $(cat "$test_tmp/help") == "--help" ]] || fail "private $family launch probes help exactly once"
done
pass "private windows retain browser-specific flags without rewriting URLs"
