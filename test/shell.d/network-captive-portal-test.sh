#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const network = requireFromRoot('shell/plugins/panels/network/Model.js')
const states = { Unknown: 0, None: 1, Portal: 2, Limited: 3, Full: 4 }

for (const kind of ['wifi', 'ethernet']) {
  for (const [native, expected] of [
    ['Unknown', 'unknown'], ['None', 'none'], ['Portal', 'portal'],
    ['Limited', 'limited'], ['Full', 'full']
  ]) {
    assertEqual(network.connectivityState(kind, states[native], states, true), expected,
      `${kind} maps native ${native} connectivity without confusing an outage with a portal`)
  }
  assertEqual(network.connectivityState(kind, 99, states, true), 'unknown', `${kind} handles unknown connectivity`)
  for (const native of Object.values(states)) {
    assertEqual(network.connectivityState(kind, native, states, false), 'unknown', `${kind} ignores stale results with probing disabled (${native})`)
  }
}
for (const native of Object.values(states)) {
  assertEqual(network.connectivityState('disconnected', native, states, true), 'none', `disconnect clears stale connectivity (${native})`)
}
for (const state of ['portal', 'limited']) {
  assertEqual(network.connectionIcon('wifi', 80, state), '󰤩', `${state} uses a blocked Wi-Fi icon`)
  assertEqual(network.connectionIcon('ethernet', 80, state), '󰈂', `${state} uses a blocked Ethernet icon`)
  assertEqual(network.connectionIcon('disconnected', 80, state), '󰤮', `${state} does not override the disconnected icon`)
}
for (const state of ['full', 'unknown', 'none', undefined]) {
  for (const signal of [-1, 0, 20, 40, 60, 80, 100]) {
    assertEqual(network.connectionIcon('wifi', signal, state), network.wifiIconFor(signal), `${state} preserves Wi-Fi strength ${signal}`)
  }
  assertEqual(network.connectionIcon('ethernet', -1, state), '󰈀', `${state} preserves the Ethernet icon`)
}
const url = new URL(network.captivePortalUrl)
assertEqual(url.protocol, 'http:', 'browser entry point uses plain HTTP so a portal can intercept it')
assertEqual(url.hostname, 'ping.omacom.io', 'browser entry point is fixed rather than portal-supplied')
assertEqual(url.username + url.password, '', 'browser entry point contains no credentials')
JS

# The browser must open the URL NetworkManager probes, or a portal that only
# intercepts the probed host would never show its sign-in page.
nm_conf="$ROOT/etc/NetworkManager/conf.d/omarchy-connectivity.conf"
nm_uri=$(sed -n 's/^uri=//p' "$nm_conf")
panel_uri=$(sed -n 's/^var captivePortalUrl = "\(.*\)"$/\1/p' "$ROOT/shell/plugins/panels/network/Model.js")
[[ -n $nm_uri && $nm_uri == "$panel_uri" ]] || fail "NetworkManager probes the URL the panel opens ($nm_uri vs $panel_uri)"
pass "NetworkManager probes the URL the panel opens"
[[ $(sed -n 's/^response=\(.*\)$/[\1]/p' "$nm_conf") == "[]" ]] || fail "NetworkManager expects the endpoint's empty 204"
pass "NetworkManager expects the endpoint's empty 204"

# Chromium-family browsers upgrade a plain-HTTP navigation to HTTPS, and in
# HTTPS-First's balanced mode a portal that answers port 443 as unreachable
# gets the error page for https://<probe host> instead of its sign-in page.
# The machine policy exempts the probe host, so the window stays on plain HTTP
# long enough for the portal to redirect it.
policy="$ROOT/default/chromium/policies/omarchy.json"
nm_host=${nm_uri#http://}
nm_host=${nm_host%%/*}
jq -e --arg host "$nm_host" '.HttpAllowlist | index($host) != null' "$policy" >/dev/null ||
  fail "the browser policy exempts the probe host from HTTPS upgrades ($nm_host)" "$(<"$policy")"
pass "the browser policy exempts the probe host from HTTPS upgrades"
# Only the fixed probe host: a wildcard or a portal's host would let plain HTTP
# through for sites that never asked for it.
[[ $(jq -c '.HttpAllowlist' "$policy") == "[\"$nm_host\"]" ]] ||
  fail "the browser policy exempts only the probe host" "$(jq -c '.HttpAllowlist' "$policy")"
pass "the browser policy exempts only the probe host"

# Installs that already have the policy pick the allowlist up on update.
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/managed" "$stage/install/helpers"
printf '{"DefaultBrowserSettingEnabled": false}\n' >"$stage/managed/omarchy.json"
# The real helper, pointed at scratch directories and run without root.
cat >"$stage/install/helpers/browser-policy.sh" <<STUB
OMARCHY_PATH=$ROOT source "$ROOT/install/helpers/browser-policy.sh"
OMARCHY_PATH=$ROOT
BROWSER_POLICY_MANAGED_DIRS=("$stage/managed" "$stage/absent")
browser_policy_dir_hardened() { [[ -d \$1 ]]; }
browser_policy_parents_hardened() { :; }
as_root() { local args=(); while (( \$# )); do case \$1 in -o|-g) shift 2 ;; *) args+=("\$1"); shift ;; esac; done; "\${args[@]}"; }
STUB
OMARCHY_PATH=$stage bash -euo pipefail "$ROOT/migrations/1793329471.sh" >/dev/null
jq -e --arg host "$nm_host" '.HttpAllowlist == [$host] and .DefaultBrowserSettingEnabled == false' "$stage/managed/omarchy.json" >/dev/null ||
  fail "the migration installs the allowlist into existing policy directories" "$(cat "$stage/managed/omarchy.json")"
[[ ! -e $stage/absent ]] || fail "the migration leaves browsers that are not installed alone"
pass "the migration installs the allowlist into existing policy directories only"
