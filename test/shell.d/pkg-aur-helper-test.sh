#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
log_file="$test_tmp/calls.log"
mkdir -p "$stub_bin" "$test_home"

write_stub() {
  local name="$1"
  local body="$2"

  cat >"$stub_bin/$name" <<<"$body"
  chmod +x "$stub_bin/$name"
}

write_stub yay '#!/bin/bash
printf "yay\t%s\n" "$*" >>"$OMARCHY_AUR_TEST_LOG"
exit 0
'

write_stub paru '#!/bin/bash
printf "paru\t%s\n" "$*" >>"$OMARCHY_AUR_TEST_LOG"
exit 0
'

write_stub pacman '#!/bin/bash
if [[ ${1:-} == "-Qem" ]]; then
  echo "foreign-pkg 1.0-1"
  exit 0
fi
if [[ ${1:-} == "-Q" ]]; then
  [[ ${2:-} == "present-pkg" ]] && exit 0
  exit 1
fi
exit 1
'

write_stub omarchy-pkg-aur-accessible '#!/bin/bash
printf "aur-accessible\n" >>"$OMARCHY_AUR_TEST_LOG"
exit 0
'

run_env() {
  : >"$log_file"
  OMARCHY_AUR_TEST_LOG="$log_file" HOME="$test_home" PATH="$stub_bin:$ROOT/bin:$PATH" "$@"
}

# No configured helper: yay first when both are installed.
[[ $(run_env "$ROOT/bin/omarchy-pkg-aur-helper") == "yay" ]] || fail "aur helper defaults to yay when both helpers are installed"
pass "aur helper defaults to yay when both helpers are installed"

# Configured helper wins.
mkdir -p "$test_home/.config/omarchy/defaults"
printf 'paru\n' >"$test_home/.config/omarchy/defaults/aur-helper"
[[ $(run_env "$ROOT/bin/omarchy-pkg-aur-helper") == "paru" ]] || fail "aur helper honors the configured helper"
pass "aur helper honors the configured helper"

# Configured but uninstalled helper falls back instead of breaking AUR ops.
mv "$stub_bin/paru" "$stub_bin/paru-hidden"
[[ $(run_env "$ROOT/bin/omarchy-pkg-aur-helper") == "yay" ]] || fail "aur helper falls back when the configured helper is missing"
pass "aur helper falls back when the configured helper is missing"
mv "$stub_bin/paru-hidden" "$stub_bin/paru"

run_env "$ROOT/bin/omarchy-default-aur-helper" paru >/dev/null
[[ $(cat "$test_home/.config/omarchy/defaults/aur-helper") == "paru" ]] || fail "default aur-helper records the chosen helper"
pass "default aur-helper records the chosen helper"

[[ $(run_env "$ROOT/bin/omarchy-default-aur-helper") == "paru" ]] || fail "default aur-helper reports the current helper"
pass "default aur-helper reports the current helper"

if run_env "$ROOT/bin/omarchy-default-aur-helper" bogus 2>"$test_tmp/usage.err"; then
  fail "default aur-helper rejects unknown helpers"
fi
grep -q "Usage" "$test_tmp/usage.err" || fail "default aur-helper explains valid helpers" "$(cat "$test_tmp/usage.err")"
pass "default aur-helper rejects unknown helpers"

# AUR installs route through the configured helper, not a hard-coded yay.
run_env "$ROOT/bin/omarchy-pkg-aur-add" foreign-pkg >/dev/null 2>&1 || true
grep -Fxq $'paru\t-S --noconfirm --needed foreign-pkg' "$log_file" || fail "aur add installs through paru when configured" "$(cat "$log_file")"
pass "aur add installs through paru when configured"

# Nothing missing means the helper is never invoked.
run_env "$ROOT/bin/omarchy-pkg-aur-add" present-pkg >/dev/null 2>&1
[[ ! -s $log_file ]] || fail "aur add skips the helper when everything is installed" "$(cat "$log_file")"
pass "aur add skips the helper when everything is installed"

# AUR updates route through the configured helper too.
run_env "$ROOT/bin/omarchy-update-aur-pkgs" >/dev/null 2>&1
grep -Fxq $'paru\t-Sua --noconfirm --cleanafter --ignore gcc14,gcc14-libs' "$log_file" || fail "aur updates run through paru when configured" "$(cat "$log_file")"
pass "aur updates run through paru when configured"
