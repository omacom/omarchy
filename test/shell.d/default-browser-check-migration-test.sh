#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791935188.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
config_dir="$home/.config"
mkdir -p "$config_dir" "$test_tmp/targets" "$test_tmp/bin"

# Installing Firefox's policies needs root; record the request instead.
cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SUDO_LOG"
SH
chmod +x "$test_tmp/bin/sudo"

printf '%s\n' '--ozone-platform=wayland' >"$config_dir/chromium-flags.conf"
printf '%s' '--ozone-platform=wayland' >"$config_dir/chrome-flags.conf"
printf '%s\n' '--enable-features=BraveFeature' >"$test_tmp/targets/brave-flags.conf"
ln -s "$test_tmp/targets/brave-flags.conf" "$config_dir/brave-flags.conf"

run_migration() {
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$test_tmp/bin:$PATH" SUDO_LOG="$test_tmp/sudo" \
    bash -euo pipefail "$migration" >/dev/null
}

run_migration
run_migration

[[ $(cat "$config_dir/chromium-flags.conf") == $'--ozone-platform=wayland\n--no-default-browser-check' ]] ||
  fail "the migration adds the flag once" "$(cat "$config_dir/chromium-flags.conf")"
[[ $(cat "$config_dir/chrome-flags.conf") == $'--ozone-platform=wayland\n--no-default-browser-check' ]] ||
  fail "the migration adds the flag after a missing trailing newline"
pass "the migration adds the flag once, on a line of its own"

[[ -L $config_dir/brave-flags.conf ]] || fail "the migration preserves symlinked browser flags"
grep -qxF -- '--no-default-browser-check' "$test_tmp/targets/brave-flags.conf" ||
  fail "the migration updates the target of symlinked browser flags"
pass "the migration follows symlinked browser flags"

[[ ! -e $config_dir/brave-origin-flags.conf ]] || fail "the migration leaves missing browser flags absent"
pass "the migration skips missing browser flags"

grep -qxF -- '--no-default-browser-check' "$ROOT/config/chromium-flags.conf" ||
  fail "new Chromium-family flags skip the default browser check"
[[ $(jq '.policies.DontCheckDefaultBrowser' "$ROOT/default/firefox/policies.json") == "true" ]] ||
  fail "Firefox's policies skip the default browser check"
[[ $(jq '.DefaultBrowserSettingEnabled' "$ROOT/default/chromium/policies/omarchy.json") == "false" ]] ||
  fail "Chromium-family policy hides the default browser setting"
pass "new installs skip the default browser check"

# Only Omarchy's own policy files go into root-owned directories.
if [[ -f $test_tmp/sudo ]]; then
  while read -r line; do
    [[ $line == "install -m 644 -o root -g root -T $ROOT/default/"*" "*/omarchy.json ||
      $line == "install -m 644 -o root -g root -T "*" "*/distribution/policies.json ]] ||
      fail "the migration writes only Omarchy's policy files as root" "$line"
  done <"$test_tmp/sudo"
fi
pass "the migration writes only Omarchy's policy files as root"
