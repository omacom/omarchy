#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT
mkdir -p "$test_dir/bin"

# Record and inspect the real staging location while it exists. No remote
# network or desktop IPC is involved in these lifecycle tests.
cat >"$test_dir/bin/git" <<'STUB'
#!/bin/bash
set -euo pipefail
[[ $1 == "clone" ]]
stage=${!#}
workspace=${stage%/*}
printf '%s\n' "$workspace" >"$TEST_CASE/workspace"
[[ $workspace == /tmp/omarchy-plugin-add.* ]]
[[ $(stat -c %a "$workspace") == 700 ]]
[[ ! -e $HOME/.config/omarchy/plugins ]]
mkdir "$stage"
printf 'downloaded data\n' >"$stage/partial"
[[ $TEST_MODE != "clone-error" ]] || exit 9
printf '%s\n' '{"schemaVersion":1,"id":"acme.cleanup","name":"Cleanup","version":"1","kinds":["service"],"entryPoints":{"service":"Service.qml"}}' >"$stage/manifest.json"
printf 'import QtQuick\nQtObject {}\n' >"$stage/Service.qml"
# This must never run during staging, validation, or audit.
printf '#!/bin/bash\ntouch "$TEST_CASE/plugin-executed"\n' >"$stage/install.sh"
chmod +x "$stage/install.sh"
[[ $TEST_MODE != "validation-error" ]] || printf 'invalid\n' >"$stage/manifest.json"
STUB

cat >"$test_dir/bin/omarchy-plugin-audit" <<'STUB'
#!/bin/bash
set -euo pipefail
workspace=$(<"$TEST_CASE/workspace")
[[ $1 == "$workspace/checkout" ]]
[[ -f $workspace/report ]]
[[ ! -e $HOME/.config/omarchy/plugins ]]
case "$TEST_MODE" in
  audit-error) exit 7 ;;
  signal-*) kill -s "${TEST_MODE#signal-}" "$PPID"; exit 0 ;;
esac
exec "$ROOT/bin/omarchy-plugin-audit" "$@"
STUB

cat >"$test_dir/bin/gum" <<'STUB'
#!/bin/bash
case "$1" in
  style|pager)
    [[ $TEST_MODE != "pager-error" ]] || exit 8
    cat >>"$TEST_CASE/pages"
    ;;
  choose)
    [[ " $* " == *" --selected Cancel "* ]] || exit 9
    [[ $TEST_MODE != "choice-error" ]] || exit 130
    count=0
    [[ ! -f $TEST_CASE/choices ]] || count=$(<"$TEST_CASE/choices")
    printf '%s\n' "$((count + 1))" >"$TEST_CASE/choices"
    case "$TEST_MODE:$count" in
      pager-error:*) printf 'View full report\n' ;;
      review-install:0|review-cancel:0) printf 'finding:0\n' ;;
      review-install:1) printf 'View full report\n' ;;
      review-install:2) printf 'Install plugin\n' ;;
      *) printf 'Cancel\n' ;;
    esac
    ;;
  *) exit 1 ;;
esac
STUB

cat >"$test_dir/bin/tput" <<'STUB'
#!/bin/bash
printf '10\n'
STUB

cat >"$test_dir/bin/less" <<'STUB'
#!/bin/bash
[[ $TEST_MODE != "pager-error" ]] || exit 8
cat >>"$TEST_CASE/pages"
STUB

cat >"$test_dir/bin/omarchy-shell" <<'STUB'
#!/bin/bash
touch "$TEST_CASE/rescanned"
STUB
chmod +x "$test_dir/bin/"*

run_case() {
  local mode=$1 expected=$2 interactive=${3:-false}
  local case_dir="$test_dir/$mode" output status=0 workspace
  mkdir -p "$case_dir"
  if [[ $interactive == "true" ]]; then
    output=$(TEST_MODE="$mode" TEST_CASE="$case_dir" HOME="$case_dir/home" \
      TMPDIR="$case_dir/home/.config/omarchy/plugins" OMARCHY_PATH="$ROOT" \
      PATH="$test_dir/bin:$ROOT/bin:$PATH" \
      script -qec 'omarchy-plugin-audit https://example.test/plugin.git' /dev/null 2>&1) || status=$?
  else
    output=$(TEST_MODE="$mode" TEST_CASE="$case_dir" HOME="$case_dir/home" \
      TMPDIR="$case_dir/home/.config/omarchy/plugins" OMARCHY_PATH="$ROOT" \
      PATH="$test_dir/bin:$ROOT/bin:$PATH" \
      omarchy-plugin-add https://example.test/plugin.git --yes 2>&1) || status=$?
  fi
  (( status == expected )) || fail "$mode exits with $expected (got $status)" "$output"
  [[ -s $case_dir/workspace ]] || fail "$mode reached private staging" "$output"
  workspace=$(<"$case_dir/workspace")
  [[ ! -e $workspace ]] || fail "$mode removes checkout and report" "$workspace"
  [[ ! -e $case_dir/plugin-executed ]] || fail "$mode never executes plugin code"
  if [[ $mode == "success" || $mode == "review-install" ]]; then
    [[ -f $case_dir/home/.config/omarchy/plugins/acme.cleanup/Service.qml ]] ||
      fail "accepted installation survives cleanup" "$output"
    [[ -f $case_dir/rescanned ]] || fail "accepted installation rescans"
  else
    [[ ! -e $case_dir/home/.config/omarchy/plugins ]] || fail "$mode never publishes a plugin"
    [[ ! -e $case_dir/rescanned ]] || fail "$mode never rescans the shell"
  fi
  if [[ $mode == review-* ]]; then
    grep -qF '[LOW] Executable files' "$case_dir/pages" || fail "$mode displays selected finding"
    if [[ $mode == "review-install" ]]; then
      grep -qF 'Plugin security audit' "$case_dir/pages" || fail "$mode displays full report"
      [[ $(<"$case_dir/choices") == 3 ]] || fail "$mode returns to choices after each page"
    else
      ! grep -qF 'Plugin security audit' "$case_dir/pages" || fail "$mode shows only selected finding"
    fi
  fi
  pass "$mode cleans private staging without executing plugin code"
}

run_case clone-error 1
run_case validation-error 1
run_case audit-error 7
run_case signal-HUP 129
run_case signal-INT 130
run_case signal-TERM 143
run_case success 0

if script -qec true /dev/null >/dev/null 2>&1; then
  # Enter through the public audit URL command; let it delegate to add first.
  # The wrapper only intercepts the subsequent directory scan.
  mv "$test_dir/bin/omarchy-plugin-audit" "$test_dir/bin/audit-directory"
  cat >"$test_dir/bin/omarchy-plugin-audit" <<'STUB'
#!/bin/bash
if [[ -d $1 ]]; then
  exec "$(dirname "$0")/audit-directory" "$@"
else
  exec "$ROOT/bin/omarchy-plugin-audit" "$@"
fi
STUB
  chmod +x "$test_dir/bin/omarchy-plugin-audit"
  run_case cancel 1 true
  run_case choice-error 1 true
  run_case pager-error 1 true
  run_case review-install 0 true
  run_case review-cancel 1 true
else
  skip "script -qec unavailable; skipping interactive cancellation cleanup"
fi
