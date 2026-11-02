#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

write_plugin() {
  local dir="$1"
  local id="$2"
  local name="$3"

  mkdir -p "$dir"
  cat >"$dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$id",
  "name": "$name",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": {
    "displayName": "$name",
    "category": "Test",
    "allowMultiple": false
  }
}
JSON
  printf 'import QtQuick\nItem {}\n' >"$dir/Widget.qml"
}

stub_dir="$test_tmp/stubs"
mkdir -p "$stub_dir"
cat >"$stub_dir/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$stub_dir/omarchy-shell"

test_home="$test_tmp/home"
write_plugin "$test_home/.config/omarchy/plugins/different-folder" "acme.same" "Installed"

incoming="$test_tmp/incoming"
write_plugin "$incoming" "acme.same" "Incoming"
git -C "$incoming" init -q
git -C "$incoming" add .
git -C "$incoming" -c user.name=Test -c user.email=test@example.com commit -qm "Initial"

output=$(HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
  omarchy-plugin-add "$incoming" --yes 2>&1) &&
  fail "plugin add accepts an id already installed under another directory" "$output"
grep -qF "plugin id 'acme.same' is already used by" <<<"$output" ||
  fail "plugin add explains the installed id collision" "$output"
[[ ! -e $test_home/.config/omarchy/plugins/acme.same ]] ||
  fail "plugin add leaves a target behind after refusing a duplicate id"
pass "plugin add refuses an installed manifest id regardless of directory name"

# --- URL transport-helper guard -------------------------------------------
#
# The guard refuses git transport helpers (`<name>::…`) and option-shaped URLs
# before `git clone` runs, matching omarchy-theme-install. A git stub records
# whether clone was reached, so the guard is exercised with no network: reaching
# the stub proves a URL passed the guard; not reaching it proves the guard
# rejected the URL first.

guard_stubs="$test_tmp/guard-stubs"
mkdir -p "$guard_stubs"
cat >"$guard_stubs/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$guard_stubs/omarchy-shell"

clone_marker="$test_tmp/git-clone-reached"
cat >"$guard_stubs/git" <<STUB
#!/bin/bash
if [[ \$1 == "clone" ]]; then
  touch "$clone_marker"
  exit 1
fi
exit 0
STUB
chmod +x "$guard_stubs/git"

# A gum stub that answers `gum input` with a caller-chosen value, so a test can
# drive any URL through the interactive prompt path.
cat >"$guard_stubs/gum" <<'STUB'
#!/bin/bash
if [[ $1 == "input" ]]; then
  printf '%s\n' "$GUM_INPUT_VALUE"
fi
STUB
chmod +x "$guard_stubs/gum"

add_url() {
  HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$guard_stubs:$ROOT/bin:$PATH" \
    omarchy-plugin-add "$1" --yes 2>&1
}

# Transport helpers reach the guard, are named as such, and never reach clone.
for bad in "ext::sh -c touch /tmp/omarchy-guard-test" "fd::17"; do
  rm -f "$clone_marker"
  output=$(add_url "$bad") &&
    fail "plugin add rejects a transport-helper URL: $bad" "$output"
  grep -qF "names a git option or transport helper" <<<"$output" ||
    fail "plugin add names the transport-helper rejection: $bad" "$output"
  [[ ! -e $clone_marker ]] ||
    fail "plugin add reached git clone for a transport-helper URL: $bad"
done
pass "plugin add rejects transport-helper URLs before cloning"

# The `://` spelling of the same thing: git resolves git-remote-<scheme> for any
# scheme it does not implement itself, so `ext::` and `ext://` reach the same
# helper and both have to be refused.
for bad in "ext://sh -c id" "gcrypt://example.com/x"; do
  rm -f "$clone_marker"
  output=$(add_url "$bad") &&
    fail "plugin add rejects a transport-scheme URL: $bad" "$output"
  grep -qF "which Omarchy does not clone from" <<<"$output" ||
    fail "plugin add names the transport-scheme rejection: $bad" "$output"
  [[ ! -e $clone_marker ]] ||
    fail "plugin add reached git clone for a transport-scheme URL: $bad"
done
pass "plugin add rejects transport-scheme URLs before cloning"

# Option-shaped URLs on argv are refused before clone — by the option parser
# (`-*` falls to "unknown add option"), not the guard. The guard's own
# leading-dash arm is only reachable through the interactive gum prompt and is
# exercised separately below.
for bad in "-oProxyCommand=x" "--upload-pack=x"; do
  rm -f "$clone_marker"
  output=$(add_url "$bad") &&
    fail "plugin add rejects an option-shaped URL: $bad" "$output"
  [[ ! -e $clone_marker ]] ||
    fail "plugin add reached git clone for an option-shaped URL: $bad"
done
pass "plugin add rejects option-shaped URLs before cloning"

# The guard's leading-dash arm is only reachable through `gum input`: argv
# dashes die in the option parser first. interactive() requires a TTY on stdin
# and stdout, so run this one case on a pty via util-linux `script -qec` (the
# suite's existing pty idiom); gum itself is stubbed, so no rendering happens.
# Probe script's util-linux syntax first and skip cleanly where it is missing.
if script -qec true /dev/null >/dev/null 2>&1; then
  rm -f "$clone_marker"
  status=0
  raw=$(GUM_INPUT_VALUE="-oProxyCommand=x" HOME="$test_home" OMARCHY_PATH="$ROOT" \
    PATH="$guard_stubs:$ROOT/bin:$PATH" \
    script -qec "omarchy-plugin-add --yes" /dev/null) || status=$?
  output=$(tr -d '\r' <<<"$raw")
  (( status != 0 )) ||
    fail "plugin add rejects an option-shaped URL from the gum prompt" "$output"
  grep -qF "names a git option or transport helper" <<<"$output" ||
    fail "plugin add names the guard rejection for the gum-prompt URL" "$output"
  [[ ! -e $clone_marker ]] ||
    fail "plugin add reached git clone for an option-shaped gum-prompt URL"
  pass "plugin add guard rejects an option-shaped URL from the interactive prompt"
else
  skip "script -qec unavailable; skipping the interactive gum-prompt guard case"
fi

# Legitimate URL forms pass the guard and reach git clone (stubbed, no network).
for good in \
  "https://github.com/acme/omarchy-weather.git" \
  "git@github.com:acme/repo.git" \
  "ssh://git@github.com/acme/repo.git" \
  "git@[2001:db8::1]:org/repo.git"; do
  rm -f "$clone_marker"
  output=$(add_url "$good") || true
  ! grep -qF "names a git option or transport helper" <<<"$output" ||
    fail "plugin add wrongly rejected a legitimate URL: $good" "$output"
  [[ -e $clone_marker ]] ||
    fail "plugin add did not reach git clone for a legitimate URL: $good" "$output"
done
pass "plugin add lets legitimate git URLs reach git clone"

# A static audit happens after cloning and validation, but before the checkout is
# moved into the live plugin directory. `--yes` remains scriptable and prints the
# report instead of needing a TTY decision.
audited="$test_tmp/audited"
write_plugin "$audited" "acme.audited" "Audited"
git -C "$audited" init -q
git -C "$audited" add .
git -C "$audited" -c user.name=Test -c user.email=test@example.com commit -qm "Initial"
output=$(HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
  omarchy-plugin-add "$audited" --yes 2>&1) ||
  fail "plugin add completes after a clean audit" "$output"
grep -qF "Plugin security audit" <<<"$output" ||
  fail "plugin add prints the pre-install audit" "$output"
grep -qF "[INFO] No heuristic findings" <<<"$output" ||
  fail "plugin add reports the clean audit result" "$output"
[[ -d $test_home/.config/omarchy/plugins/acme.audited ]] ||
  fail "plugin add installs only after the audit completes"
pass "plugin add audits the staged checkout before installing it"

# Interactive installs render the report and require an explicit choice after it.
if script -qec true /dev/null >/dev/null 2>&1; then
  cat >"$stub_dir/gum" <<'STUB'
#!/bin/bash
case "$1" in
style) cat ;;
pager) cat ;;
choose)
  while (( $# )); do
    if [[ $1 == "--header" ]]; then printf '%s\n' "$2" >&2; fi
    shift
  done
  printf 'Install plugin\n'
  ;;
*) exit 1 ;;
esac
STUB
  chmod +x "$stub_dir/gum"
  interactive="$test_tmp/interactive"
  write_plugin "$interactive" "acme.interactive" "Interactive"
  git -C "$interactive" init -q
  git -C "$interactive" add .
  git -C "$interactive" -c user.name=Test -c user.email=test@example.com commit -qm "Initial"
  status=0
  raw=$(HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
    script -qec "omarchy-plugin-add $interactive" /dev/null) || status=$?
  output=$(tr -d '\r' <<<"$raw")
  (( status == 0 )) || fail "interactive plugin add installs after accepting its audit" "$output"
  grep -qF "4/4 Review plugin" <<<"$output" || fail "interactive plugin add renders the audit" "$output"
  [[ -d $test_home/.config/omarchy/plugins/acme.interactive ]] ||
    fail "interactive plugin add installs after the audit choice"
  pass "interactive plugin add asks for a decision after rendering the audit"
else
  skip "script -qec unavailable; skipping the interactive audit flow"
fi

# Installation lifecycle: isolate fault injection from the real-clone cases above.
lifecycle_stubs="$test_tmp/lifecycle-stubs"
mkdir -p "$lifecycle_stubs"

# Record and inspect the real staging location while it exists. No remote
# network or desktop IPC is involved in these lifecycle tests.
cat >"$lifecycle_stubs/git" <<'STUB'
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
if [[ $TEST_MODE == early-* ]]; then
  # Exceed pipe capacity in a single finding, even with the evidence line cap.
  awk 'BEGIN { printf "// sudo "; for (i = 0; i < 200000; i++) printf "x"; print "" }' >>"$stage/Service.qml"
fi
# This must never run during staging, validation, or audit.
printf '#!/bin/bash\ntouch "$TEST_CASE/plugin-executed"\n' >"$stage/install.sh"
chmod +x "$stage/install.sh"
[[ $TEST_MODE != "validation-error" ]] || printf 'invalid\n' >"$stage/manifest.json"
STUB

cat >"$lifecycle_stubs/omarchy-plugin-audit" <<'STUB'
#!/bin/bash
set -euo pipefail
workspace=$(<"$TEST_CASE/workspace")
[[ $1 == "$workspace/checkout" ]]
[[ -f $workspace/report ]]
[[ ! -e $HOME/.config/omarchy/plugins ]]
case "$TEST_MODE" in
  audit-error) exit 7 ;;
  search-error) chmod 000 "$1/Service.qml" ;;
  signal-*) kill -s "${TEST_MODE#signal-}" "$PPID"; exit 0 ;;
esac
exec "$ROOT/bin/omarchy-plugin-audit" "$@"
STUB

cat >"$lifecycle_stubs/gum" <<'STUB'
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
      early-full:0) printf 'View full report\n' ;;
      early-finding:0|pager-finding-error:*) printf 'finding:0\n' ;;
      early-*:1) printf 'Install plugin\n' ;;
      *) printf 'Cancel\n' ;;
    esac
    ;;
  *) exit 1 ;;
esac
STUB

cat >"$lifecycle_stubs/tput" <<'STUB'
#!/bin/bash
printf '10\n'
STUB

cat >"$lifecycle_stubs/less" <<'STUB'
#!/bin/bash
[[ $TEST_MODE != "pager-error" && $TEST_MODE != "pager-finding-error" ]] || exit 8
# Like quitting less with q before it has consumed a long report.
[[ $TEST_MODE != early-* ]] || exit 0
cat >>"$TEST_CASE/pages"
STUB

cat >"$lifecycle_stubs/cp" <<'STUB'
#!/bin/bash
set -euo pipefail
destination=${!#}
[[ $destination == "$HOME/.config/omarchy/plugins/.add."*/checkout ]]
[[ $(stat -c %a "${destination%/*}") == 700 ]]
printf '%s\n' "${destination%/*}" >"$TEST_CASE/install-workspace"
[[ ! -e $HOME/.config/omarchy/plugins/acme.cleanup ]]
case "$TEST_MODE" in
  copy-error|copy-signal-*)
    mkdir "$destination"
    cp_source=${@: -2:1}
    /usr/bin/cp "$cp_source/manifest.json" "$destination/manifest.json"
    omarchy-plugin-catalog | jq -e 'all(.[]; .id != "acme.cleanup")' >/dev/null
    if [[ $TEST_MODE == "copy-error" ]]; then
      exit 9
    else
      kill -s "${TEST_MODE#copy-signal-}" "$PPID"
      exit 0
    fi
    ;;
  *) exec /usr/bin/cp "$@" ;;
esac
STUB

cat >"$lifecycle_stubs/omarchy-shell" <<'STUB'
#!/bin/bash
touch "$TEST_CASE/rescanned"
STUB
chmod +x "$lifecycle_stubs/"*

run_case() {
  local mode=$1 expected=$2 interactive=${3:-false}
  local case_dir="$test_tmp/lifecycle/$mode" output status=0 workspace
  mkdir -p "$case_dir"
  if [[ $interactive == "true" ]]; then
    output=$(TEST_MODE="$mode" TEST_CASE="$case_dir" HOME="$case_dir/home" \
      TMPDIR="$case_dir/home/.config/omarchy/plugins" OMARCHY_PATH="$ROOT" \
      PATH="$lifecycle_stubs:$ROOT/bin:$PATH" \
      script -qec 'omarchy-plugin-audit https://example.test/plugin.git' /dev/null 2>&1) || status=$?
  else
    output=$(TEST_MODE="$mode" TEST_CASE="$case_dir" HOME="$case_dir/home" \
      TMPDIR="$case_dir/home/.config/omarchy/plugins" OMARCHY_PATH="$ROOT" \
      PATH="$lifecycle_stubs:$ROOT/bin:$PATH" \
      omarchy-plugin-add https://example.test/plugin.git --yes 2>&1) || status=$?
  fi
  (( status == expected )) || fail "$mode exits with $expected (got $status)" "$output"
  [[ -s $case_dir/workspace ]] || fail "$mode reached private staging" "$output"
  workspace=$(<"$case_dir/workspace")
  [[ ! -e $workspace ]] || fail "$mode removes checkout and report" "$workspace"
  [[ ! -e $case_dir/plugin-executed ]] || fail "$mode never executes plugin code"
  if [[ -f $case_dir/install-workspace ]]; then
    [[ ! -e $(<"$case_dir/install-workspace") ]] || fail "$mode removes destination staging"
  fi
  if [[ $mode == "success" || $mode == "review-install" || $mode == early-* ]]; then
    [[ -f $case_dir/home/.config/omarchy/plugins/acme.cleanup/Service.qml ]] ||
      fail "accepted installation survives cleanup" "$output"
    [[ -f $case_dir/rescanned ]] || fail "accepted installation rescans"
  else
    [[ ! -e $case_dir/home/.config/omarchy/plugins/acme.cleanup ]] || fail "$mode never publishes a plugin"
    [[ ! -e $case_dir/rescanned ]] || fail "$mode never rescans the shell"
  fi
  if [[ $mode == early-* ]]; then
    [[ $(<"$case_dir/choices") == 2 ]] || fail "$mode returns to the menu after quitting the pager"
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
run_case copy-error 9
run_case copy-signal-HUP 129
run_case copy-signal-INT 130
run_case copy-signal-TERM 143
if (( EUID != 0 )); then
  run_case search-error 1
fi

if script -qec true /dev/null >/dev/null 2>&1; then
  # Enter through the public audit URL command; let it delegate to add first.
  # The wrapper only intercepts the subsequent directory scan.
  mv "$lifecycle_stubs/omarchy-plugin-audit" "$lifecycle_stubs/audit-directory"
  cat >"$lifecycle_stubs/omarchy-plugin-audit" <<'STUB'
#!/bin/bash
if [[ -d $1 ]]; then
  exec "$(dirname "$0")/audit-directory" "$@"
else
  exec "$ROOT/bin/omarchy-plugin-audit" "$@"
fi
STUB
  chmod +x "$lifecycle_stubs/omarchy-plugin-audit"
  run_case cancel 1 true
  run_case choice-error 1 true
  run_case pager-error 1 true
  run_case pager-finding-error 1 true
  run_case early-full 0 true
  run_case early-finding 0 true
  run_case review-install 0 true
  run_case review-cancel 1 true
else
  skip "script -qec unavailable; skipping interactive cancellation cleanup"
fi
