#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-brcmfmac-supplicant.sh"
fix_t2="$ROOT/install/hardware/apple/fix-t2.sh"
all="$ROOT/install/hardware/all.sh"

grep -q 'apple/fix-brcmfmac-supplicant.sh' "$all" ||
  fail "the brcmfmac quirk runs during hardware setup"

# Two leaves writing one config means the later one silently wins, and which is
# later is a detail of all.sh nobody would think to check.
! grep -q 'brcmfmac' "$fix_t2" ||
  fail "only one leaf owns /etc/modprobe.d/brcmfmac.conf"
pass "the brcmfmac quirk has a single owner and runs during setup"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
conf="$test_tmp/etc/modprobe.d/brcmfmac.conf"
mkdir -p "$stub_bin" "$test_tmp/dmi"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

# Chatty like real lspci: keep writing well past the pipe buffer after the
# match, so a grep -q consumer would kill this stub with SIGPIPE and pipefail
# would read that as "no such hardware" (#6608).
if (( ${T2_HARDWARE:-0} == 1 )); then
  echo '01:00.0 Bridge [0680]: Apple Inc. T2 Security Chip [106b:1801]'
fi
if [[ -n ${WIFI_ID:-} ]]; then
  echo "03:00.0 Network controller [0280]: Broadcom Inc. Wireless [14e4:$WIFI_ID]"
fi
for _ in {1..4096}; do
  echo '02:00.0 Host bridge [0600]: Filler Device [ffff:0000]'
done
SH

cat >"$stub_bin/omarchy-hw-aarch64-apple" <<'SH'
#!/bin/bash

(( ${APPLE_SILICON:-0} == 1 ))
SH

chmod +x "$stub_bin"/*

# The leaf reads the vendor from an absolute path, so point it at a fixture by
# running with a fake root on PATH-independent state. pipefail is on, so a
# grep -q gate would go silent here the way #6608 did.
run_leaf() {
  local vendor="$1" wifi_id="${2:-}" t2="${3:-0}" apple_silicon="${4:-0}"
  rm -rf "$test_tmp/etc"
  mkdir -p "$test_tmp/etc"
  printf '%s' "$vendor" >"$test_tmp/dmi/sys_vendor"

  # Redirect both absolute paths the leaf touches into the sandbox.
  local script="$test_tmp/leaf.sh"
  sed -e "s|/sys/class/dmi/id/sys_vendor|$test_tmp/dmi/sys_vendor|g" \
      -e "s|/etc/modprobe.d|$test_tmp/etc/modprobe.d|g" \
      "$leaf" >"$script"

  WIFI_ID="$wifi_id" T2_HARDWARE="$t2" APPLE_SILICON="$apple_silicon" PATH="$stub_bin:$PATH" \
    bash -eE -o pipefail -c 'source "$1"' bash "$script" </dev/null
}

# T2 Macs (BCM4364, BCM4355, BCM4377) and the T2-less BCM4364 iMac19,x keep
# their firmware SAE offload, or WPA3-only networks never connect (#9802).
for wifi_id in 4464 43dc 4488; do
  run_leaf "Apple Inc." "$wifi_id" 1 >/dev/null
  [[ ! -f $conf ]] || fail "a T2 Mac with 14e4:$wifi_id does not get the quirk" "$(ls -R "$test_tmp/etc" 2>&1)"
done
pass "T2 Macs do not get the quirk"

run_leaf "Apple Inc." 4464 0 >/dev/null
[[ ! -f $conf ]] || fail "a BCM4364 Mac without a T2 does not get the quirk"
pass "a BCM4364 Mac without a T2 does not get the quirk"

# No Mac carries both a T2 and a legacy part, so without this case deleting the
# T2 check leaves every other case passing.
run_leaf "Apple Inc." 43ba 1 >/dev/null
[[ ! -f $conf ]] || fail "a T2 Mac reporting a legacy part does not get the quirk"
pass "the T2 check alone keeps the quirk off a T2 Mac"

# Legacy pre-T2 parts: BCM43602 and its single-band variants, BCM4350.
for wifi_id in 43ba 43bb 43bc 43a3; do
  run_leaf "Apple Inc." "$wifi_id" 0 >/dev/null
  [[ -f $conf ]] || fail "a legacy Mac without a T2 gets the quirk" "14e4:$wifi_id"
done
pass "legacy brcmfmac parts on pre-T2 Macs get the quirk"

run_leaf "Apple Inc." 4433 0 1 >/dev/null
[[ ! -f $conf ]] || fail "Apple Silicon is excluded from the Intel Mac quirk"
pass "Apple Silicon is excluded from the Intel Mac quirk"

# Older Macs report the vendor differently.
run_leaf "Apple Computer, Inc." 43ba 0 >/dev/null
[[ -f $conf ]] || fail "the older Apple vendor string is recognized"
pass "the older Apple vendor string is recognized"

# BCM4360 Macs run the out-of-tree wl driver, which never reads this option, so
# writing it would only look like the machine had been dealt with.
run_leaf "Apple Inc." 43a0 0 >/dev/null
[[ ! -f $conf ]] || fail "a Mac whose Wi-Fi brcmfmac does not drive is left alone"
pass "a Mac whose Wi-Fi brcmfmac does not drive is left alone"

# Plenty of non-Apple hardware uses brcmfmac and does not share this bug.
run_leaf "LENOVO" 43ba 0 >/dev/null
[[ ! -f $conf ]] || fail "non-Apple hardware is left alone"
pass "non-Apple hardware is left alone"

run_leaf "Apple Inc." "" 0 >/dev/null
[[ ! -f $conf ]] || fail "a Mac with no wireless device is left alone"
pass "a Mac with no wireless device is left alone"
