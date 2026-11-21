#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

dns="$ROOT/bin/omarchy-dns"

# Static assertions
grep -F 'RESOLVED_SINGLE_LABEL_CONF=/etc/systemd/resolved.conf.d/15-single-label.conf' "$dns" >/dev/null || \
  fail "omarchy-dns defines the 15-single-label.conf drop-in path"

grep -F 'ResolveUnicastSingleLabel=yes' "$dns" >/dev/null || \
  fail "omarchy-dns writes ResolveUnicastSingleLabel=yes in the drop-in"

grep -F 'write_single_label_dns()' "$dns" >/dev/null || \
  fail "omarchy-dns defines write_single_label_dns"

grep -F 'clear_single_label_dns()' "$dns" >/dev/null || \
  fail "omarchy-dns defines clear_single_label_dns"

grep -F 'prompt_single_label_dns()' "$dns" >/dev/null || \
  fail "omarchy-dns defines prompt_single_label_dns"

grep -F '[[ -t 0 ]] || return 0' "$dns" >/dev/null || \
  fail "omarchy-dns returns early from single-label prompt without a terminal"

pass "omarchy-dns carries single-label DNS configuration contract"

# Verify provider bindings
# Cloudflare and Google must clear single-label drop-in
awk '/^Cloudflare\)/, /^  ;;/ { if (/clear_single_label_dns/) found=1 } END { exit !found }' "$dns" || \
  fail "Cloudflare provider clears single-label DNS configuration"

awk '/^Google\)/, /^  ;;/ { if (/clear_single_label_dns/) found=1 } END { exit !found }' "$dns" || \
  fail "Google provider clears single-label DNS configuration"

awk '/^DHCP\)/, /^  ;;/ { if (/prompt_single_label_dns/) found=1 } END { exit !found }' "$dns" || \
  fail "DHCP provider prompts for single-label DNS configuration"

awk '/^Custom\)/, /^  ;;/ { if (/prompt_single_label_dns/) found=1 } END { exit !found }' "$dns" || \
  fail "Custom provider prompts for single-label DNS configuration"

pass "omarchy-dns binds single-label DNS actions to the appropriate providers"

# Functional behavioral test in a temporary sandbox
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

conf="$test_tmp/resolved.conf.d/15-single-label.conf"

subshell_test() {
  bash -c '
    set -euo pipefail
    RESOLVED_SINGLE_LABEL_CONF="'"$conf"'"
    '"$(sed -n '/^write_single_label_dns()/,/^}/p' "$dns")"'
    '"$(sed -n '/^clear_single_label_dns()/,/^}/p' "$dns")"'
    '"$(sed -n '/^prompt_single_label_dns()/,/^}/p' "$dns")"'
    '"$1"'
  '
}

# Test write_single_label_dns
subshell_test 'write_single_label_dns'
[[ -f "$conf" ]] || fail "write_single_label_dns creates the drop-in file"
grep -F 'ResolveUnicastSingleLabel=yes' "$conf" >/dev/null || fail "drop-in contains ResolveUnicastSingleLabel=yes"
pass "write_single_label_dns writes the expected systemd-resolved drop-in"

# Test clear_single_label_dns
subshell_test 'clear_single_label_dns'
[[ ! -f "$conf" ]] || fail "clear_single_label_dns removes the drop-in file"
pass "clear_single_label_dns removes the drop-in file"

# Test non-interactive prompt does not prompt or write
subshell_test 'prompt_single_label_dns </dev/null'
[[ ! -f "$conf" ]] || fail "prompt_single_label_dns does not write without a terminal"
pass "prompt_single_label_dns is a no-op without a terminal"
