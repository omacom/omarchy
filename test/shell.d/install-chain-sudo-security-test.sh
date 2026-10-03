#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# These tests establish orchestration and exit status only, not real sudo
# credentials, password prompts, vendor behaviour, or signal delivery.
for tool in bash cat chmod env grep id install mkdir mktemp readlink rm sed stat; do
  if [[ ! -x /usr/bin/$tool ]]; then
    skip "missing /usr/bin/$tool; installer orchestration requires GNU/Linux tools"
    exit 0
  fi
done
if [[ ! -r /proc/$$/cmdline || ! -e /proc/$$/exe ]]; then
  skip "procfs process metadata unavailable; cannot check protected Bash startup"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf -- "${test_tmp:?}"' EXIT
stub_bin="$test_tmp/bin"
script_dir="$test_tmp/scripts"
test_home="$test_tmp/home"
mkdir -p "$stub_bin" "$script_dir" "$test_home"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
case "${1:-}" in
  -k) printf 'REVOKE\n' >>"$TEST_EVENTS" ;;
  -h)
    printf 'CAPABILITY\n' >>"$TEST_EVENTS"
    printf 'usage: sudo [-ABbEHkNnPS] command\n'
    ;;
  *) printf 'UNEXPECTED:sudo\n' >>"$TEST_EVENTS"; exit 90 ;;
esac
SH
cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
[[ ${OMARCHY_SUDO_NO_UPDATE:-0} == 1 ]] || exit 91
printf 'PACKAGE:%s\n' "$*" >>"$TEST_EVENTS"
[[ ${TEST_FAIL_STEP:-} != "package:$*" ]] || exit "$TEST_FAIL_STATUS"
SH
cat >"$stub_bin/mise" <<'SH'
#!/bin/bash
printf 'MISE:%s\n' "$*" >>"$TEST_EVENTS"
[[ ${TEST_FAIL_STEP:-} != mise ]] || exit "$TEST_FAIL_STATUS"
SH
cat >"$stub_bin/curl" <<'SH'
#!/bin/bash
set -euo pipefail
output=
while (( $# )); do
  if [[ $1 == "--output" ]]; then
    output=$2
    shift 2
  else
    shift
  fi
done
[[ $output == "$TEST_TMP/"* ]] || exit 92
printf '%s\n' "$output" >"$TEST_DOWNLOAD_PATH"
case "$output" in
  *.bin)
    printf 'DOWNLOAD:geforce\n' >>"$TEST_EVENTS"
    [[ ${TEST_FAIL_STEP:-} != download ]] || exit "$TEST_FAIL_STATUS"
    # This is the only executable download fixture: stdout and status only.
    cat >"$output" <<'PAYLOAD'
#!/bin/bash
printf 'GeForce NOW inert fixture\n'
exit "${TEST_PAYLOAD_STATUS:-0}"
PAYLOAD
    ;;
  */Battle.net-Setup.exe)
    printf 'DOWNLOAD:battlenet\n' >>"$TEST_EVENTS"
    [[ ${TEST_FAIL_STEP:-} != download ]] || exit "$TEST_FAIL_STATUS"
    printf 'Inert Battle.net fixture; never executed.\n' >"$output"
    ;;
  *) exit 92 ;;
esac
SH
cat >"$stub_bin/setsid" <<'SH'
#!/bin/bash
# Record the handoff without creating a session or evaluating a command string.
if [[ $# == 1 && $1 == "omarchy-launch-browser" ]]; then
  printf 'BROWSER\n' >>"$TEST_EVENTS"
elif [[ $# == 4 && $1 == "-f" && $2 == "sh" && $3 == "-c" && $4 == "umu-run "* ]]; then
  printf 'BATTLE_HANDOFF\n' >>"$TEST_EVENTS"
else
  exit 93
fi
SH
cat >"$stub_bin/update-desktop-database" <<'SH'
#!/bin/bash
printf 'DESKTOP_REFRESH\n' >>"$TEST_EVENTS"
SH
cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
printf '00:02.0 VGA compatible controller: Intel Corporation Fixture GPU\n'
SH
for name in omarchy-hw-nvidia-gsp omarchy-hw-nvidia-without-gsp omarchy-pkg-missing; do
  cat >"$stub_bin/$name" <<'SH'
#!/bin/bash
exit 1
SH
done
cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash
# The package-helper startup positive control uses an already-present package.
[[ $# == 3 && $1 == "-Q" && $2 == "--" ]] || exit 94
printf 'PACKAGE_QUERY:%s\n' "$3" >>"$TEST_EVENTS"
SH
cat >"$stub_bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf 'FONT_PRESENTATION\n' >>"$TEST_EVENTS"
SH
# A regressed startup guard must still never launch applications, signal host
# processes, or perform an operation through a system privilege tool.
for name in pkexec systemctl pkill gum umu-run omarchy-launch-browser omarchy-font-set; do
  cat >"$stub_bin/$name" <<'SH'
#!/bin/bash
printf 'UNEXPECTED:%s\n' "${0##*/}" >>"$TEST_EVENTS"
exit 95
SH
done

entrypoints=(omarchy-pkg-add omarchy-install-dev-env omarchy-install-font
  omarchy-install-gaming-geforce-now omarchy-install-gaming-battlenet omarchy-install-gaming-gpu-lib32)
for name in omarchy-security-functions omarchy-install-security-functions "${entrypoints[@]}"; do
  sed -e "s#/usr/bin/omarchy-install-gaming-gpu-lib32#$script_dir/omarchy-install-gaming-gpu-lib32#g" \
    -e "s#/usr/bin/\(sudo\|pacman\|curl\|lspci\|omarchy-pkg-add\|omarchy-pkg-missing\|omarchy-hw-nvidia-gsp\|omarchy-hw-nvidia-without-gsp\|omarchy-launch-floating-terminal-with-presentation\|omarchy-font-set\)\b#$stub_bin/\1#g" \
    -e "s#^PATH=/usr/bin:#PATH=$stub_bin:/usr/bin:#" \
    -e "s#/tmp/omarchy-geforce-now\.#$test_tmp/omarchy-geforce-now.#g" \
    -e "s#/tmp/omarchy-battlenet-installer.log#$test_tmp/battlenet-installer.log#g" \
    "$ROOT/bin/$name" >"$script_dir/$name"
done
chmod 0755 "$stub_bin/"* "$script_dir/"*
# Check the entrypoints AND their sourced helpers before executing any copy.
if grep -Eq '(^|[^[:alnum:]_./-])/(usr/)?s?bin/(sudo|pacman|curl|pkexec|systemctl|omarchy-pkg-add|omarchy-launch-floating-terminal-with-presentation|omarchy-font-set)([^[:alnum:]_-]|$)' "$script_dir/"*; then
  fail "installer fixture retains a host privilege, package, or download path"
fi

reset_case() {
  rm -rf -- "${test_tmp:?}/home"
  mkdir -p "$test_home"
  : >"$test_tmp/events"
  rm -f -- "$test_tmp/download-path"
}

run_fixture() {
  local expected=$1 status
  shift
  if /usr/bin/env -i HOME="$test_home" PATH="$stub_bin:/usr/bin:/bin" OMARCHY_PATH="$ROOT" LC_ALL=C \
    TEST_TMP="$test_tmp" TEST_EVENTS="$test_tmp/events" TEST_DOWNLOAD_PATH="$test_tmp/download-path" \
    TEST_FAIL_STEP="${TEST_FAIL_STEP:-}" TEST_FAIL_STATUS="${TEST_FAIL_STATUS:-42}" \
    TEST_PAYLOAD_STATUS="${TEST_PAYLOAD_STATUS:-0}" "$@" >"$test_tmp/output" 2>&1; then
    status=0
  else
    status=$?
  fi
  (( status == expected )) || fail "fixture returned $status instead of $expected: $*" "$(<"$test_tmp/output")"
  if [[ -f $test_tmp/download-path ]]; then
    local download_path
    read -r download_path <"$test_tmp/download-path"
    if [[ $download_path == *.bin ]]; then
      [[ ! -e $download_path ]] || fail "GeForce NOW left its inert download fixture behind"
    fi
  fi
}

assert_events() {
  [[ $(<"$test_tmp/events") == "$1" ]] || fail "$2" "$(<"$test_tmp/events")"
}

# Valid protected startup controls precede the six ordinary-Bash rejections.
reset_case
run_fixture 0 /usr/bin/bash -p -- "$script_dir/omarchy-install-gaming-geforce-now"
assert_events $'REVOKE\nCAPABILITY\nPACKAGE:flatpak\nREVOKE\nDOWNLOAD:geforce\nBROWSER\nREVOKE' \
  "GeForce NOW must revoke between its prerequisite and download, then clean up"
grep -Fxq 'GeForce NOW inert fixture' "$test_tmp/output" || fail "GeForce NOW did not run the inert stdout/status fixture"
pass "GeForce NOW orders prerequisite, revocation, inert fixture and browser handoff"

for step in package:flatpak download; do
  for status in 42 130; do
    reset_case
    TEST_FAIL_STEP=$step TEST_FAIL_STATUS=$status run_fixture "$status" /usr/bin/bash -p -- "$script_dir/omarchy-install-gaming-geforce-now"
    expected=$'REVOKE\nCAPABILITY\nPACKAGE:flatpak'
    [[ $step != "download" ]] || expected+=$'\nREVOKE\nDOWNLOAD:geforce'
    assert_events "$expected"$'\nREVOKE' "GeForce NOW failure must stop before later callbacks and revoke"
    run_fixture 0 /usr/bin/bash -p -- "$script_dir/omarchy-install-gaming-geforce-now"
    grep -Fxq BROWSER "$test_tmp/events" || fail "GeForce NOW retry did not reach the browser handoff"
  done
done
for status in 44 130; do
  reset_case
  TEST_PAYLOAD_STATUS=$status run_fixture "$status" /usr/bin/bash -p -- "$script_dir/omarchy-install-gaming-geforce-now"
  assert_events $'REVOKE\nCAPABILITY\nPACKAGE:flatpak\nREVOKE\nDOWNLOAD:geforce\nREVOKE' \
    "GeForce NOW fixture failure must skip the browser and revoke"
  run_fixture 0 /usr/bin/bash -p -- "$script_dir/omarchy-install-gaming-geforce-now"
  grep -Fxq BROWSER "$test_tmp/events" || fail "GeForce NOW retry did not reach the browser handoff"
done
pass "GeForce NOW failure and synthetic status-130 cancellation clean up and allow retry"

reset_case
run_fixture 0 /usr/bin/bash -p -- "$script_dir/omarchy-install-gaming-battlenet"
assert_events $'REVOKE\nCAPABILITY\nPACKAGE:umu-launcher\nPACKAGE:lib32-vulkan-intel\nREVOKE\nDOWNLOAD:battlenet\nBATTLE_HANDOFF\nDESKTOP_REFRESH\nREVOKE' \
  "Battle.net must complete both prerequisites and revoke before the inert download and launch handoff"
[[ -f $test_home/.local/share/applications/battlenet.desktop ]] || fail "Battle.net did not install its desktop file in the fixture home"
pass "Battle.net orders both package calls before revocation and user callbacks"
for package in umu-launcher lib32-vulkan-intel; do
  reset_case
  TEST_FAIL_STEP="package:$package" run_fixture 42 /usr/bin/bash -p -- "$script_dir/omarchy-install-gaming-battlenet"
  expected=$'REVOKE\nCAPABILITY\nPACKAGE:umu-launcher'
  [[ $package != "lib32-vulkan-intel" ]] || expected+=$'\nPACKAGE:lib32-vulkan-intel'
  assert_events "$expected"$'\nREVOKE' "Battle.net prerequisite failure must stop before user callbacks and revoke"
done
pass "Battle.net stops and revokes on either prerequisite failure"

for environment in ruby clojure; do
  if [[ $environment == "ruby" ]]; then
    package=libyaml
    user_events=$'MISE:settings add ruby.compile false\nMISE:settings add idiomatic_version_file_enable_tools ruby\nMISE:use --global ruby@latest\nMISE:x ruby -- gem install rails --no-document'
  else
    package=rlwrap
    user_events='MISE:use --global clojure@latest'
  fi
  reset_case
  run_fixture 0 /usr/bin/bash -p -- "$script_dir/omarchy-install-dev-env" "$environment"
  assert_events $'REVOKE\nCAPABILITY\n'"PACKAGE:$package"$'\nREVOKE\n'"$user_events"$'\nREVOKE' \
    "$environment must finish its prerequisite and revoke before mise"
  reset_case
  TEST_FAIL_STEP="package:$package" run_fixture 42 /usr/bin/bash -p -- "$script_dir/omarchy-install-dev-env" "$environment"
  assert_events $'REVOKE\nCAPABILITY\n'"PACKAGE:$package"$'\nREVOKE' "$environment prerequisite failure must stop before mise and revoke"
  reset_case
  TEST_FAIL_STEP=mise TEST_FAIL_STATUS=43 run_fixture 43 /usr/bin/bash -p -- "$script_dir/omarchy-install-dev-env" "$environment"
  assert_events $'REVOKE\nCAPABILITY\n'"PACKAGE:$package"$'\nREVOKE\n'"${user_events%%$'\n'*}"$'\nREVOKE' \
    "$environment mise failure must stop later work and revoke on exit"
  pass "$environment orders prerequisite and revocation before mise and preserves failure cleanup"
done

reset_case
run_fixture 0 /usr/bin/bash -p -- "$script_dir/omarchy-pkg-add" fixture-package
assert_events 'PACKAGE_QUERY:fixture-package' "protected package-helper startup must reach the benign package query"
reset_case
run_fixture 0 /usr/bin/bash -p -- "$script_dir/omarchy-install-font" 'Fixture Font' fixture-font 'Fixture Family'
assert_events $'REVOKE\nCAPABILITY\nFONT_PRESENTATION' "protected font startup must reach the stubbed terminal handoff"
pass "package helper and font installer accept protected startup in benign controls"

for name in "${entrypoints[@]}"; do
  reset_case
  run_fixture 126 /usr/bin/bash "$script_dir/$name" -p
  [[ ! -s $test_tmp/events ]] || fail "$name reached operational work during an ordinary Bash startup"
  grep -Fq 'Refusing an unsafe Bash startup' "$test_tmp/output" || fail "$name did not explain its startup refusal"
  pass "$name rejects ordinary Bash with a decoy post-script -p"
done
