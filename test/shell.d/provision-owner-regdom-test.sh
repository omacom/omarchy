#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A deferred install (an Apple Silicon image, an OEM ISO install) runs its
# hardware steps on the UTC placeholder, so the wireless regulatory domain can
# only come from the timezone the owner picks in first-boot setup. The setup
# step runs against a fixture root: the real install step with its paths moved
# there, and wireless-regdb's boot helper as it ships, with iw recording calls.

tmp=$(cd -- "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$tmp"' EXIT

root=$tmp/root
omarchy=$tmp/omarchy
stub_bin=$tmp/bin
conf=$root/etc/conf.d/wireless-regdom
calls=$tmp/calls
mkdir -p "$stub_bin" "$omarchy/bin" "$omarchy/install/hardware"

ln -s "$ROOT/bin/omarchy-cmd-present" "$omarchy/bin/omarchy-cmd-present"
sed -e "s|/etc/|$root/etc/|g" -e "s|/usr/share/zoneinfo|$root/usr/share/zoneinfo|g" \
  "$ROOT/install/hardware/set-wireless-regdom.sh" >"$omarchy/install/hardware/set-wireless-regdom.sh"

cat >"$stub_bin/timedatectl" <<SH
#!/bin/bash
[[ \$1 == set-timezone && -f "$root/usr/share/zoneinfo/\$2" ]] || exit 1
ln -sfn "../usr/share/zoneinfo/\$2" "$root/etc/localtime"
SH
printf '#!/bin/bash\nexec "$@"\n' >"$stub_bin/sudo"
cat >"$stub_bin/set-wireless-regdom" <<SH
#!/bin/bash

unset WIRELESS_REGDOM
. "$conf"
[ -n "\${WIRELESS_REGDOM}" ] && iw reg set \${WIRELESS_REGDOM}
SH
cat >"$stub_bin/iw" <<SH
#!/bin/bash
echo "iw \$*" >>"$calls"
[[ ! -e "$tmp/no-wifi" ]] || { echo "nl80211 not found." >&2; exit 1; }
SH
chmod +x "$stub_bin"/*

# A fresh deferred install: wireless-regdb's commented list, the UTC placeholder.
fresh_root() {
  rm -rf "$root" "$calls" "$tmp/no-wifi"
  mkdir -p "$root/etc/conf.d" "$root/usr/share/zoneinfo/Australia" "$root/usr/share/zoneinfo/America"
  printf '#\n# Wireless regulatory domain configuration\n#\n#WIRELESS_REGDOM="AU"\n#WIRELESS_REGDOM="US"\n' >"$conf"
  : >"$root/usr/share/zoneinfo/UTC"
  : >"$root/usr/share/zoneinfo/Australia/Brisbane"
  : >"$root/usr/share/zoneinfo/America/New_York"
  printf 'AU\t-2728+15302\tAustralia/Brisbane\tQueensland (most areas)\nUS\t+404251-0740023\tAmerica/New_York\tEastern (most areas)\n' \
    >"$root/usr/share/zoneinfo/zone.tab"
  ln -s ../usr/share/zoneinfo/UTC "$root/etc/localtime"
  : >"$calls"
}

export PATH="$stub_bin:$omarchy/bin:$PATH"
export OMARCHY_PATH=$omarchy

# The two setup functions as omarchy-provision-owner defines them, with its
# fixed paths moved into the fixture root.
sed -n '/^configure_timezone() {/,/^}/p; /^configure_wireless_regdom() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner" |
  sed -e "s|/usr/share/zoneinfo|$root/usr/share/zoneinfo|g" -e "s|/etc/|$root/etc/|g" >"$tmp/setup.sh"
grep -q '^configure_wireless_regdom() {' "$tmp/setup.sh" || fail "omarchy-provision-owner sets the regulatory domain in setup"
# shellcheck disable=SC1091
source "$tmp/setup.sh"

regdom_lines() {
  grep '^WIRELESS_REGDOM=' "$conf" || true
}

# The install step itself stays as an up-front install runs it: persisted only,
# the radios untouched until the reboot that follows an install.
fresh_root
ln -sfn ../usr/share/zoneinfo/America/New_York "$root/etc/localtime"
bash "$omarchy/install/hardware/set-wireless-regdom.sh"
[[ $(regdom_lines) == 'WIRELESS_REGDOM="US"' ]] || fail "an up-front install persists its timezone's country" "$(cat "$conf")"
[[ ! -s $calls ]] || fail "an up-front install leaves the radios alone" "$(cat "$calls")"
pass "an up-front install persists its timezone's country and leaves the radios to the reboot"

fresh_root
bash "$omarchy/install/hardware/set-wireless-regdom.sh"
[[ -z $(regdom_lines) ]] || fail "the UTC placeholder names no country" "$(cat "$conf")"
pass "a deferred install's hardware step sets nothing from the UTC placeholder"

timezone=Australia/Brisbane
configure_timezone >/dev/null
[[ $(readlink "$root/etc/localtime") == ../usr/share/zoneinfo/Australia/Brisbane ]] ||
  fail "setup applies the owner's timezone"
[[ $(regdom_lines) == 'WIRELESS_REGDOM="AU"' ]] || fail "setup persists the owner's country" "$(cat "$conf")"
[[ $(cat "$calls") == "iw reg set AU" ]] || fail "setup applies the owner's country to the radios" "$(cat "$calls")"
pass "setup persists the owner's timezone's country and applies it without a reboot"

configure_timezone >/dev/null
[[ $(regdom_lines) == 'WIRELESS_REGDOM="AU"' ]] || fail "a retried setup writes the domain once" "$(cat "$conf")"
pass "a retried setup keeps one regulatory domain line"

fresh_root
printf 'WIRELESS_REGDOM="DE"\n' >>"$conf"
timezone=America/New_York
configure_timezone >/dev/null
[[ $(regdom_lines) == 'WIRELESS_REGDOM="DE"' ]] || fail "setup keeps a domain already chosen" "$(cat "$conf")"
[[ $(cat "$calls") == "iw reg set DE" ]] || fail "setup applies the domain already chosen" "$(cat "$calls")"
pass "a regulatory domain already chosen is kept"

fresh_root
timezone=UTC
configure_timezone >/dev/null
[[ -z $(regdom_lines) ]] || fail "a timezone without a country sets no domain" "$(cat "$conf")"
[[ ! -s $calls ]] || fail "a timezone without a country leaves the radios alone" "$(cat "$calls")"
pass "a timezone without a country sets no regulatory domain"

fresh_root
: >"$tmp/no-wifi"
timezone=America/New_York
configure_timezone >/dev/null || fail "setup goes on on a machine without Wi-Fi"
[[ $(regdom_lines) == 'WIRELESS_REGDOM="US"' ]] || fail "a machine without Wi-Fi still gets the domain for later" "$(cat "$conf")"
pass "a machine without Wi-Fi finishes setup with the domain persisted for its next boot"

fresh_root
timezone=Omarchy/Nowhere
configure_timezone >/dev/null || fail "setup goes on after a timezone it cannot apply"
[[ -z $(regdom_lines) && ! -s $calls ]] || fail "a timezone that did not apply sets no domain" "$(cat "$conf" "$calls")"
pass "a timezone that could not be applied sets no regulatory domain"
