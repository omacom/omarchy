#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# The retries wait on the kernel; nothing to wait for here.
printf '#!/bin/bash\n' >"$stub_bin/sleep"

# Logs every call; loading iwlwifi brings the card's interface up with RELOAD_RECOVERS.
cat >"$stub_bin/modprobe" <<'SH'
#!/bin/bash
echo "$*" >>"$MODPROBE_LOG"
if [[ $* == "iwlwifi" && -n ${RELOAD_RECOVERS:-} ]]; then
  mkdir -p "$OMARCHY_PCI_PATH/devices/0000:28:00.0/net/wlan0/wireless"
fi
SH

chmod +x "$stub_bin"/*

# One network controller at 0000:28:00.0, from VENDOR, with a Wi-Fi interface when HAS_INTERFACE.
setup() {
  pci="$test_tmp/pci-$RANDOM"
  modules="$test_tmp/module-$RANDOM"
  card="$pci/devices/0000:28:00.0"
  mkdir -p "$card" "$modules"
  echo "${VENDOR:-0x8086}" >"$card/vendor"
  echo 0x028000 >"$card/class"
  : >"$card/remove"
  : >"$pci/rescan"
  [[ -z ${HAS_INTERFACE:-} ]] || mkdir -p "$card/net/wlan0/wireless"
  [[ -z ${IWLWIFI_LOADED:-} ]] || mkdir -p "$modules/iwlwifi" "$modules/iwlmvm"
  export MODPROBE_LOG="$test_tmp/modprobe-$RANDOM.log"
  : >"$MODPROBE_LOG"
}

recover() {
  OMARCHY_PCI_PATH="$pci" OMARCHY_MODULE_PATH="$modules" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-hw-recover-wifi" >/dev/null 2>&1
}

HAS_INTERFACE=1 setup
recover || fail "a card with its Wi-Fi interface needs no recovery"
[[ ! -s $card/remove && ! -s $pci/rescan && ! -s $MODPROBE_LOG ]] ||
  fail "a card with its Wi-Fi interface is left alone"
pass "a card with its Wi-Fi interface is left alone"

VENDOR=0x14e4 setup
recover || fail "a non-Intel card is not recovered"
[[ ! -s $card/remove && ! -s $pci/rescan ]] || fail "a non-Intel card is left alone"
pass "a non-Intel card without an interface is left alone"

IWLWIFI_LOADED=1 setup
RELOAD_RECOVERS=1 recover || fail "a card that failed to probe recovers once iwlwifi reloads"
[[ $(<"$card/remove") == "1" && $(<"$pci/rescan") == "1" ]] ||
  fail "a card that failed to probe is removed and rescanned first"
grep -qx -- "-r iwlmvm" "$MODPROBE_LOG" && grep -qx -- "-r iwlwifi" "$MODPROBE_LOG" && grep -qx iwlwifi "$MODPROBE_LOG" ||
  fail "iwlwifi and its op mode are unloaded before loading again" "$(<"$MODPROBE_LOG")"
pass "a card that failed to probe is rescanned, then recovered by reloading iwlwifi"

setup
status=0
recover || status=$?
((status == 1)) || fail "a card that never recovers is reported" "exit status: $status"
[[ ! -s $MODPROBE_LOG ]] || fail "an unloaded (blacklisted) iwlwifi is never loaded" "$(<"$MODPROBE_LOG")"
pass "a card that never recovers is reported, and an unloaded iwlwifi stays unloaded"
