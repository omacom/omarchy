#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command modprobe

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/dmi"

regdom="$test_tmp/etc/conf.d/wireless-regdom"
modprobe_dir="$test_tmp/etc/modprobe.d"
conf="$modprobe_dir/omarchy-brcmfmac-regdom.conf"
export TEST_MODPROBE_DIR="$modprobe_dir"
export TEST_REAL_MODPROBE
TEST_REAL_MODPROBE=$(command -v modprobe)

cat >"$test_tmp/bin/lspci" <<'SH'
#!/bin/bash
if [[ -n ${TEST_WIFI_ID:-} ]]; then
  printf '02:00.0 Network controller [0280]: Broadcom Wireless [%s]\n' "$TEST_WIFI_ID"
fi
# Keep producing output after a match to expose grep -q/SIGPIPE failures when
# hardware setup is invoked with pipefail enabled.
for _ in {1..4096}; do
  echo '00:00.0 Host bridge [0600]: Filler [ffff:0000]'
done
SH

cat >"$test_tmp/bin/modprobe" <<'SH'
#!/bin/bash
[[ $* == "--showconfig" ]] || exit 1
"$TEST_REAL_MODPROBE" -C "$TEST_MODPROBE_DIR" --showconfig
SH

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH

for command in iw systemctl limine-update limine-mkinitcpio; do
  cat >"$test_tmp/bin/$command" <<'SH'
#!/bin/bash
echo "Hardware setup must not change live networking or rebuild boot images here" >&2
exit 1
SH
done
chmod +x "$test_tmp/bin"/*

# Redirect filesystem state, while exercising the real timezone lookup and
# modprobe configuration parser. No installed config or live driver is touched.
sed "s|/etc/|$test_tmp/etc/|g" \
  "$ROOT/install/hardware/set-wireless-regdom.sh" >"$test_tmp/set-regdom.sh"
sed -e "s|/etc/|$test_tmp/etc/|g" \
    -e "s|/sys/class/dmi/id/sys_vendor|$test_tmp/dmi/sys_vendor|g" \
  "$ROOT/install/hardware/apple/fix-brcmfmac-regdom.sh" >"$test_tmp/fix-regdom.sh"

reset_fixture() {
  rm -rf "$test_tmp/etc"
  mkdir -p "$test_tmp/etc/conf.d" "$modprobe_dir"
  printf '#WIRELESS_REGDOM="00"\n' >"$regdom"
  printf '%s\n' "${1-Apple Inc.}" >"$test_tmp/dmi/sys_vendor"
  ln -s "/usr/share/zoneinfo/${2-America/New_York}" "$test_tmp/etc/localtime"
}

run_setup() {
  PATH="$test_tmp/bin:$PATH" TEST_WIFI_ID="${1-14e4:43a3}" \
    bash -euo pipefail -c '
      source "$1/install/helpers/logging.sh"
      run_logged "$2/set-regdom.sh"
      run_logged "$2/fix-regdom.sh"
    ' bash "$ROOT" "$test_tmp" >/dev/null
}

assert_country() {
  local expected="$1"
  [[ $(bash -c 'source "$1"; printf "%s" "${WIRELESS_REGDOM:-}"' bash "$regdom") == "$expected" ]] ||
    fail "wireless-regdb uses country $expected"
  grep -qx "options cfg80211 ieee80211_regdom=$expected" "$conf" ||
    fail "cfg80211 uses the same country $expected"
}

all="$ROOT/install/hardware/all.sh"
country_line=$(grep -n 'run_logged .*hardware/set-wireless-regdom.sh' "$all" | cut -d: -f1)
quirk_line=$(grep -n 'run_logged .*hardware/apple/fix-brcmfmac-regdom.sh' "$all" | cut -d: -f1)
(( country_line < quirk_line )) || fail "country selection precedes the Apple boot quirk"
pass "country selection precedes the Apple boot quirk"

# The affected MacBookPro14,1 uses BCM4350, while #9019 uses BCM43602.
for wifi_id in 43a3 43ba 43bb 43bc; do
  reset_fixture
  run_setup "14e4:$wifi_id"
  assert_country US
done
pass "BCM4350 and all BCM43602 variants receive the boot country hint"

cp "$conf" "$test_tmp/expected.conf"
cp "$regdom" "$test_tmp/expected-regdom"
run_setup
cmp -s "$conf" "$test_tmp/expected.conf" || fail "reruns preserve the module configuration"
cmp -s "$regdom" "$test_tmp/expected-regdom" || fail "reruns do not duplicate the country setting"
pass "rerunning hardware setup is idempotent"

for zone_country in Europe/London:GB Asia/Tokyo:JP; do
  reset_fixture "Apple Inc." "${zone_country%:*}"
  run_setup
  assert_country "${zone_country##*:}"
done
pass "fresh installs derive their country from the target timezone"

reset_fixture "Apple Computer, Inc."
run_setup
assert_country US
pass "older Apple vendor strings are recognized"

reset_fixture
printf 'WIRELESS_REGDOM="GB"\n' >>"$regdom"
run_setup
assert_country GB
pass "an explicitly configured country takes precedence over the timezone"

reset_fixture
printf 'options cfg80211 cfg80211_disable_40mhz_24ghz=1 ieee80211_regdom=JP\n' >"$modprobe_dir/local.conf"
cp "$modprobe_dir/local.conf" "$test_tmp/expected.conf"
run_setup
[[ ! -e $conf ]] || fail "an administrator country override is not shadowed"
cmp -s "$modprobe_dir/local.conf" "$test_tmp/expected.conf" || fail "administrator options are preserved"
pass "an existing country override in another modprobe file is preserved"

reset_fixture
printf '# options cfg80211 ieee80211_regdom=JP\noptions cfg80211 cfg80211_disable_40mhz_24ghz=1\n' >"$modprobe_dir/local.conf"
run_setup
assert_country US
grep -qx 'options cfg80211 cfg80211_disable_40mhz_24ghz=1' "$modprobe_dir/local.conf" ||
  fail "unrelated module options are preserved"
pass "commented country overrides and unrelated options do not suppress the fix"

reset_fixture LENOVO
run_setup
[[ ! -e $conf ]] || fail "non-Apple hardware is unchanged"
pass "non-Apple hardware is unchanged"

for wifi_id in 14e4:43a0 8086:43a3 14e4:4488 ''; do
  reset_fixture
  run_setup "$wifi_id"
  [[ ! -e $conf ]] || fail "unaffected wireless hardware is unchanged" "$wifi_id"
done
pass "wl-driven Macs, other adapters, and absent Wi-Fi do not receive the quirk"

reset_fixture
rm "$test_tmp/dmi/sys_vendor"
run_setup
[[ ! -e $conf ]] || fail "a missing DMI vendor does not match Apple"
pass "a missing DMI vendor does not match Apple"

for timezone in UTC Etc/GMT+5 Unknown/Timezone; do
  reset_fixture "Apple Inc." "$timezone"
  run_setup
  [[ ! -e $conf ]] || fail "an unknown country is not guessed" "$timezone"
done
pass "UTC, fixed offsets, and unknown timezones do not select an arbitrary country"

for country in '' 00 US,CA invalid; do
  reset_fixture
  printf 'WIRELESS_REGDOM="%s"\n' "$country" >>"$regdom"
  run_setup
  [[ ! -e $conf ]] || fail "an unset or invalid country is not passed to cfg80211" "$country"
done
pass "unset, world, and malformed country settings are not passed to cfg80211"

reset_fixture
rm "$regdom"
run_setup
[[ ! -e $conf ]] || fail "a missing regulatory configuration is left alone"
pass "a missing regulatory configuration is left alone"

# A setup leaf is sourced; skipping it must not exit the caller.
PATH="$test_tmp/bin:$PATH" TEST_WIFI_ID=14e4:43a3 \
  bash -euo pipefail -c 'source "$1"; touch "$2"' bash "$test_tmp/fix-regdom.sh" "$test_tmp/continued"
[[ -e $test_tmp/continued ]] || fail "skipping the sourced quirk returns to its caller"
pass "skipping the sourced quirk returns to its caller"
