#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-web-allowlist-apply against fakes for nft, systemctl, setfacl and
# the accounts: a person with their list on gets a resolver that answers only
# their domains, their DNS redirected to it by uid and DNS-over-TLS dropped,
# resolved's socket denied, and the browsers' secure DNS off; turned off, all
# of it goes.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export TEST_TMP=$tmp
mkdir -p "$tmp/bin" "$tmp/lists" "$tmp/run" "$tmp/chromium" "$tmp/zen"
printf '{"policies": {"DontCheckDefaultBrowser": true}}\n' >"$tmp/zen/policies.json"
fake() { cat >"$tmp/bin/$1"; chmod +x "$tmp/bin/$1"; }

fake id <<'SH'
#!/bin/bash
case ${!#} in emma) echo 1001 ;; zoe) echo 1002 ;; *) exit 1 ;; esac
SH
fake getent <<'SH'
#!/bin/bash
[[ $2 == emma || $2 == zoe ]]
SH
fake nft <<'SH'
#!/bin/bash
cat >"$TEST_TMP/ruleset"
SH
fake systemctl <<'SH'
#!/bin/bash
echo "$*" >>"$TEST_TMP/systemctl"
SH
fake setfacl <<'SH'
#!/bin/bash
echo "$*" >>"$TEST_TMP/setfacl"
SH
fake dnsmasq <<'SH'
#!/bin/bash
SH
fake busctl <<'SH'
#!/bin/bash
echo "busctl ${*: -1}" >>"$TEST_TMP/busctl"
SH
fake pacman <<'SH'
#!/bin/bash
echo "pacman $*" >>"$TEST_TMP/pacman"
SH

apply() {
  rm -f "$tmp/systemctl" "$tmp/setfacl"
  WEB_ALLOWLIST_TESTING=1 WEB_ALLOWLIST_DIR=$tmp/lists WEB_ALLOWLIST_RUN=$tmp/run WEB_ALLOWLIST_RESOLVED_SOCKET=$tmp/socket \
    WEB_ALLOWLIST_POLICY_DIRS=$tmp/chromium:$tmp/missing WEB_ALLOWLIST_FIREFOX_DIRS=$tmp/zen:$tmp/missing \
    WEB_ALLOWLIST_DBUS_POLICY=$tmp/dbus.conf PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-web-allowlist-apply" "$@"
}

printf 'on\nkhanacademy.org\nScratch.MIT.edu\nnot a domain\nevil.com/../x\n' >"$tmp/lists/emma"
printf 'off\nwikipedia.org\n' >"$tmp/lists/zoe"
apply

config=$tmp/run/emma.conf
grep -qx 'address=/#/' "$config" || fail "everything not allowed is answered as missing"
[[ $(grep '^server=' "$config") == $'server=/khanacademy.org/127.0.0.53\nserver=/scratch.mit.edu/127.0.0.53' ]] || fail "only the valid domains on the list are forwarded, lowercased" "$(grep '^server=' "$config")"
grep -qx 'port=21001' "$config" || fail "each person's resolver has their own port"
[[ ! -e $tmp/run/zoe.conf ]] || fail "a list that is off gets no resolver"
grep -qx 'restart omarchy-web-allowlist@emma.service' "$tmp/systemctl" || fail "a new list starts its resolver"
pass "a person with their list on gets a resolver answering only the valid domains on it"

grep -q 'meta skuid 1001 udp dport 53 redirect to :21001' "$tmp/ruleset" || fail "their DNS is redirected by uid" "$(cat "$tmp/ruleset")"
grep -q 'meta skuid 1001 tcp dport 853 drop' "$tmp/ruleset" || fail "their DNS-over-TLS is dropped"
grep -q 'ip daddr 127.0.0.1 udp dport 21001 meta skuid != 1001 drop' "$tmp/ruleset" || fail "their resolver answers them alone" "$(cat "$tmp/ruleset")"
! grep -q 'skuid 1002' "$tmp/ruleset" || fail "someone whose list is off is left alone"
grep -qx "\-m u:emma:--- -- $tmp/socket" "$tmp/setfacl" || fail "resolved's socket is denied to them" "$(cat "$tmp/setfacl")"
grep -qx "\-x u:zoe -- $tmp/socket" "$tmp/setfacl" || fail "and given back to someone whose list is off"
[[ $(cat "$tmp/chromium/web-allowlist.json") == '{"DnsOverHttpsMode": "off"}' ]] || fail "secure DNS in the browser is off while a list is on"
[[ ! -e $tmp/missing ]] || fail "only browsers that are installed get a policy"
grep -q '<policy user="emma">' "$tmp/dbus.conf" && grep -q 'deny send_destination="org.freedesktop.resolve1"' "$tmp/dbus.conf" && ! grep -q zoe "$tmp/dbus.conf" || fail "resolved's D-Bus API is closed to them alone" "$(cat "$tmp/dbus.conf")"
grep -qx 'busctl ReloadConfig' "$tmp/busctl" || fail "the bus reloads its policy"
[[ $(jq -c .policies.DNSOverHTTPS "$tmp/zen/policies.json") == '{"Enabled":false,"Locked":true}' && $(jq -r .policies.DontCheckDefaultBrowser "$tmp/zen/policies.json") == true ]] || fail "Firefox and Zen have secure DNS off and locked, keeping their other policies" "$(cat "$tmp/zen/policies.json")"
pass "their DNS goes to it by uid; DNS-over-TLS, resolved's socket and its D-Bus API are closed to them; secure DNS is off in every browser"

rm -f "$tmp/systemctl" "$tmp/ruleset" "$tmp/setfacl"
apply --socket-only
grep -qx "\-m u:emma:--- -- $tmp/socket" "$tmp/setfacl" && [[ ! -e $tmp/systemctl && ! -e $tmp/ruleset ]] || fail "--socket-only puts back only the socket's ACL"
pass "after a resolved restart only the socket's ACL is put back, starting nothing"

apply
grep -qx 'start omarchy-web-allowlist@emma.service' "$tmp/systemctl" || fail "an unchanged list keeps its resolver running without a restart"
pass "an unchanged list leaves its resolver running"

printf 'off\nkhanacademy.org\n' >"$tmp/lists/emma"
apply
[[ ! -e $config ]] || fail "turned off, the resolver's config goes"
grep -qx 'stop omarchy-web-allowlist@emma.service' "$tmp/systemctl" || fail "turned off, the resolver stops"
! grep -q skuid "$tmp/ruleset" || fail "turned off, the redirect goes"
[[ ! -e $tmp/chromium/web-allowlist.json ]] || fail "with no list on, browser secure DNS is theirs again"
[[ ! -e $tmp/dbus.conf && $(jq -c '.policies | has("DNSOverHTTPS")' "$tmp/zen/policies.json") == false ]] || fail "with no list on, the D-Bus policy and Firefox's setting go"
[[ ! -e $tmp/pacman ]] || fail "dnsmasq present, nothing is installed"
pass "turned off, the resolver, the redirect and the browser policy all go"
