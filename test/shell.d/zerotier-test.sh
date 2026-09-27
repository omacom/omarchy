#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"

# ZeroTier's whole install is a package plus a boot-time unit, so the stubs only
# have to record what was asked of pacman and systemd. A real sudo here would
# prompt, and a real systemctl would enable the daemon on the developer's own
# machine.
for helper in omarchy-pkg-add omarchy-pkg-drop sudo systemctl; do
  cat >"$tmp_dir/bin/$helper" <<SCRIPT
#!/bin/bash
printf '$helper:%s\n' "\$*" >>"\$TEST_LOG"
SCRIPT
  chmod +x "$tmp_dir/bin/$helper"
done

export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir/bin:$PATH"

: >"$TEST_LOG"
"$ROOT/bin/omarchy-install-service-zerotier" >/dev/null

grep -qx 'omarchy-pkg-add:zerotier-one' "$TEST_LOG" ||
  fail "ZeroTier install adds the zerotier-one package" "$(cat "$TEST_LOG")"
pass "ZeroTier install adds the zerotier-one package"

# `enable --now` is the point of the install: starting it without enabling it
# would leave the tailnet gone after the next reboot.
grep -qx 'sudo:systemctl enable --now zerotier-one.service' "$TEST_LOG" ||
  fail "ZeroTier install enables the daemon for boot and starts it now" "$(cat "$TEST_LOG")"
pass "ZeroTier install enables the daemon for boot and starts it now"

: >"$TEST_LOG"
"$ROOT/bin/omarchy-remove-service-zerotier" >/dev/null

grep -qx 'sudo:systemctl disable --now zerotier-one.service' "$TEST_LOG" ||
  fail "ZeroTier removal disables the daemon before dropping the package" "$(cat "$TEST_LOG")"
pass "ZeroTier removal disables the daemon before dropping the package"

grep -qx 'omarchy-pkg-drop:zerotier-one' "$TEST_LOG" ||
  fail "ZeroTier removal drops the zerotier-one package" "$(cat "$TEST_LOG")"
pass "ZeroTier removal drops the zerotier-one package"

# The removal runs on a machine that may already be half torn down, so it must
# survive a unit that is gone rather than abort before omarchy-pkg-drop.
cat >"$tmp_dir/bin/sudo" <<'SCRIPT'
#!/bin/bash
printf 'sudo:%s\n' "$*" >>"$TEST_LOG"
exit 1
SCRIPT
chmod +x "$tmp_dir/bin/sudo"

: >"$TEST_LOG"
"$ROOT/bin/omarchy-remove-service-zerotier" >/dev/null

grep -qx 'omarchy-pkg-drop:zerotier-one' "$TEST_LOG" ||
  fail "ZeroTier removal still drops the package when the unit is already gone" "$(cat "$TEST_LOG")"
pass "ZeroTier removal still drops the package when the unit is already gone"

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')

const items = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const byId = Object.fromEntries(items.map(item => [item.id, item]))

const install = byId['install.service.zerotier']
const remove = byId['remove.service.zerotier']

assert(install && remove, 'menu offers ZeroTier under both Install > Service and Remove > Services')

// Install rows dim rather than vanish, so the submenu stays a catalog of what
// Omarchy can install; Remove rows hide what is not there to remove.
assertEqual(install.disabled, 'omarchy-pkg-present zerotier-one', 'ZeroTier install row dims once the package is present')
assertEqual(install.when, '', 'ZeroTier install row stays listed after it is installed')
assertEqual(remove.when, 'omarchy-pkg-present zerotier-one', 'ZeroTier remove row appears only when the package is present')
assertEqual(remove.disabled, '', 'ZeroTier remove row is never dimmed')

assert(
  install.action.endsWith('omarchy-install-service-zerotier')
    && remove.action.endsWith('omarchy-remove-service-zerotier'),
  'ZeroTier menu rows run the ZeroTier service commands'
)
assert(
  install.action.startsWith('omarchy-launch-floating-terminal-with-presentation')
    && remove.action.startsWith('omarchy-launch-floating-terminal-with-presentation'),
  'ZeroTier menu rows run in a floating terminal, since both prompt for sudo'
)
JS
