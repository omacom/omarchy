#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/config" "$stage/policies" "$stage/tree/install/helpers" "$stage/targets"
export XDG_CONFIG_HOME="$stage/config" TEST_POLICY_DIR="$stage/policies"
cat >"$stage/tree/install/helpers/browser-policy.sh" <<'SH'
BROWSER_POLICY_MANAGED_DIRS=("$TEST_POLICY_DIR")
browser_policy_dir_hardened() { return 0; }
browser_policy_parents_hardened() { return 0; }
as_root() {
  [[ $1 == "install" && ${@: -1} == "$TEST_POLICY_DIR/omarchy.json" ]] || return 1
  cp "${@: -2:1}" "${@: -1}"
}
SH
printf '%s\n' '--ozone-platform=wayland' '--no-default-browser-check' '--keep-me' >"$stage/config/chrome-flags.conf"
printf '%s\n' '--no-default-browser-check' >"$stage/targets/brave-flags.conf"
ln -s "$stage/targets/brave-flags.conf" "$stage/config/brave-flags.conf"
printf '{"DefaultBrowserSettingEnabled":false,"AnotherPolicy":42}\n' >"$stage/policies/omarchy.json"
run_migration() {
  OMARCHY_PATH="$stage/tree" bash -euo pipefail "$ROOT/migrations/1792551241.sh" >/dev/null
}
run_migration
run_migration
[[ $(cat "$stage/config/chrome-flags.conf") == $'--ozone-platform=wayland\n--keep-me' ]] || fail "migration removes only the disabled-default-check flag"
[[ -L $stage/config/brave-flags.conf && ! -s $stage/targets/brave-flags.conf ]] || fail "migration preserves the symlink and updates its target"
[[ ! -e $stage/config/chromium-flags.conf ]] || fail "migration does not invent absent flags files"
[[ $(jq -c . "$stage/policies/omarchy.json") == '{"AnotherPolicy":42}' ]] || fail "migration preserves other policy keys"
pass "migration is idempotent, preserves other flags and policies, and follows symlinks"
printf '{"DefaultBrowserSettingEnabled":true}\n' >"$stage/policies/omarchy.json"
run_migration
[[ $(jq '.DefaultBrowserSettingEnabled' "$stage/policies/omarchy.json") == "true" ]] || fail "migration preserves an explicit enabled policy"
pass "migration leaves an explicitly enabled browser policy unchanged"
