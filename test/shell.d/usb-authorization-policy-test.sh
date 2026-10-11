#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$ROOT/install/helpers/usb-authorization-policy.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

identity='id 046d:c53a serial "" name "USB Receiver" hash "KCUFt1MumW4Pfs/8YXWzGQB6Hsnm8qkDqFVjfY0NIBY="'
interfaces='with-interface { 03:01:01 03:01:02 03:00:00 } with-connect-type "unknown"'
location='parent-hash "m7yTNWlczwBbYn+uRP6TRsY5AceKmAZ0Et6mgy58+/o=" via-port "3-1.1.2.1"'
device="allow $identity $location $interfaces"
portable=$(usb_authorization_portable_rule "$device")
[[ $portable == "allow $identity $interfaces"' label "omarchy-usb-authorization-v1"' ]] || fail "only device location is removed"
[[ $(usb_authorization_portable_rule "${device/#allow/block}") == "$portable" ]] || fail "blocked approvals use the same portable identity"
pass "portable USB rules retain every device identity attribute"

# A canonical escaped name cannot cause its contents to become attributes.
name='name "Receiver \" via-port \"fake\" parent-hash \"fake\" $(touch /tmp/usb-injection)"'
hostile="allow id 046d:c53a serial \"\\\\\" $name hash \"hash\" $location $interfaces"
expected="allow id 046d:c53a serial \"\\\\\" $name hash \"hash\" $interfaces"' label "omarchy-usb-authorization-v1"'
[[ $(usb_authorization_portable_rule "$hostile") == "$expected" ]] || fail "quoted attribute text must remain data"
if usb_authorization_portable_rule 'allow id 046d:c53a name "unterminated' >/dev/null; then fail "reject unmatched quote"; fi
if usb_authorization_portable_rule 'allow id 046d:c53a via-port' >/dev/null; then fail "reject missing location value"; fi
pass "USB portable parsing preserves escaped and hostile descriptor text"

# Exercise the actual root entrypoint startup boundary without root work.
sed -e "s|source /usr/bin/omarchy-security-functions|source $ROOT/bin/omarchy-security-functions|" \
  -e 's|source /usr/share/omarchy/install/helpers/usb-authorization-policy.sh|exit 126|' \
  "$ROOT/bin/omarchy-usb-authorization-approve" >"$scratch/entry"
chmod 755 "$scratch/entry"
printf 'set -p\n' >"$scratch/decoy"
if BASH_ENV="$scratch/decoy" /usr/bin/bash "$scratch/entry" -p; then fail "ordinary Bash with decoy -p is rejected"; fi
printf 'touch "%s"\n' "$scratch/injected" >"$scratch/startup"
if BASH_ENV="$scratch/startup" "$scratch/entry" >/dev/null 2>&1; then fail "startup fixture boundary"; fi
if /usr/bin/env 'BASH_FUNC_source%%=() { touch "$USB_TEST_INJECTED"; }' USB_TEST_INJECTED="$scratch/injected" "$scratch/entry" >/dev/null 2>&1; then fail "exported function fixture boundary"; fi
[[ ! -e $scratch/injected ]] || fail "privileged entrypoint executes caller startup code"
pass "USB privileged approval rejects unsafe Bash startup"

if ! command -v g++ >/dev/null || [[ ! -f /usr/include/usbguard/Rule.hpp ]]; then
  skip "native USBGuard matcher requires g++ and USBGuard development headers"
  exit 0
fi
printf '%s\n' "$device" >"$scratch/device"
printf '%s\n' "$portable" >"$scratch/policy"
g++ -std=c++17 "$ROOT/test/shell.d/fixtures/usb-authorization/match.cpp" -lusbguard -o "$scratch/match"
"$scratch/match" "$scratch/policy" "$scratch/device"
