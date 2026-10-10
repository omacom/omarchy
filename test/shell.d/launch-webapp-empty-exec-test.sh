#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
applications_dir="$test_home/.local/share/applications"
mkdir -p "$mock_bin" "$applications_dir"
uwsm_log="$test_tmp/uwsm"
handoff_log="$test_tmp/handoff"

cat >"$mock_bin/omarchy-cmd-default-browser" <<'SH'
#!/bin/bash
printf '%s\n' "$OMARCHY_TEST_BROWSER"
SH
cat >"$mock_bin/omarchy-cmd-browser-handoff" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_HANDOFF"
exit 1
SH
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
[[ $1 == "--" ]] && shift
exec "$@"
SH
cat >"$mock_bin/uwsm-app" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_UWSM"
SH
chmod +x "$mock_bin"/*

run_launch() {
  local browser_desktop status
  rm -f "$uwsm_log" "$handoff_log"
  case $1 in
  google-chrome* | brave* | microsoft-edge* | opera* | vivaldi* | helium*) browser_desktop=$1 ;;
  *) browser_desktop="chromium.desktop" ;;
  esac
  printf 'Exec=%s\n' "${2:-}" >"$applications_dir/$browser_desktop"
  set +e
  HOME="$test_home" PATH="$mock_bin:$PATH" \
    OMARCHY_TEST_BROWSER="$1" \
    OMARCHY_TEST_UWSM="$uwsm_log" \
    OMARCHY_TEST_HANDOFF="$handoff_log" \
    bash "$ROOT/bin/omarchy-launch-webapp" "https://example.test/app" >"$test_tmp/out" 2>"$test_tmp/err"
  status=$?
  set -e
  printf '%s\n' "$status"
}

status=$(run_launch zen.desktop)
[[ $status == "1" ]] || fail "empty browser exec exits 1" "status=$status $(cat "$test_tmp/err")"
[[ ! -e $uwsm_log ]] || fail "empty browser exec does not call uwsm-app" "$(cat "$uwsm_log")"
[[ ! -e $handoff_log ]] || fail "empty browser exec does not call the browser handoff" "$(cat "$handoff_log")"
grep -F 'no browser Exec found for chromium.desktop' "$test_tmp/err" >/dev/null ||
  fail "empty browser exec names the missing desktop entry" "$(cat "$test_tmp/err")"
pass "empty browser exec exits 1 and does not call uwsm-app"

status=$(run_launch zen.desktop)
[[ $status == "1" ]] || fail "a non-allowlisted browser still fails closed when chromium is missing" "status=$status"
[[ ! -e $uwsm_log ]] || fail "a non-allowlisted browser is not launched" "$(cat "$uwsm_log")"
pass "the browser allowlist is not widened"

status=$(run_launch google-chrome.desktop google-chrome-stable)
[[ $status == "0" ]] || fail "an allowlisted browser with an Exec still launches" "status=$status $(cat "$test_tmp/err")"
[[ -e $uwsm_log ]] || fail "an allowlisted browser reaches uwsm-app when handoff declines"
grep -F 'google-chrome-stable' "$uwsm_log" >/dev/null || fail "uwsm-app receives the resolved Exec" "$(cat "$uwsm_log")"
grep -F -- '--app=https://example.test/app' "$uwsm_log" >/dev/null || fail "uwsm-app receives the app url" "$(cat "$uwsm_log")"
pass "an allowlisted browser with an Exec still reaches uwsm-app"
