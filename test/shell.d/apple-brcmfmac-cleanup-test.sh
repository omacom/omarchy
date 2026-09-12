#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
export OMARCHY_BRCMFMAC_CONF="$tmp/brcmfmac.conf" OMARCHY_BRCMFMAC_PENDING="$tmp/state/pending" TEST_LOG="$tmp/log"
export PATH="$tmp/bin:$PATH" APPLE=1 WIFI=4433 REBUILD_FAIL=0 IO_FAIL=""
cat > "$tmp/bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >> "$TEST_LOG"
[[ $1 != "${IO_FAIL:-}" ]] || exit 1
"$@"
STUB
cat > "$tmp/bin/omarchy-hw-apple-silicon" <<'STUB'
#!/bin/bash
[[ $APPLE == 1 ]]
STUB
cat > "$tmp/bin/lspci" <<'STUB'
#!/bin/bash
echo "Network controller [14e4:$WIFI]"
for ((i=0;i<4096;i++)); do echo filler; done
STUB
cat > "$tmp/bin/omarchy-state" <<'STUB'
#!/bin/bash
echo "state $*" >> "$TEST_LOG"
STUB
cat > "$tmp/bin/mkinitcpio" <<'STUB'
#!/bin/bash
[[ $REBUILD_FAIL == 0 ]]
STUB
chmod +x "$tmp/bin/"*
block="# Broadcom's firmware supplicant and authenticator fail the WPA four-way
# handshake on Apple hardware, which surfaces as a rejected password. Disable
# both so wpa_supplicant performs the handshake instead.
options brcmfmac feature_disable=0x82000"
run() { bash -euo pipefail "$ROOT/migrations/1789172112.sh" >/dev/null; }
reset() { rm -f "$OMARCHY_BRCMFMAC_CONF" "$OMARCHY_BRCMFMAC_PENDING"; : > "$TEST_LOG"; printf '%s\n' "$block" > "$OMARCHY_BRCMFMAC_CONF"; }
reset
APPLE=0 run
[[ ! -s $TEST_LOG ]] || fail "unaffected Apple gate"
WIFI=4488 run
[[ ! -s $TEST_LOG ]] || fail "unaffected PCI gate"
run
[[ ! -e $OMARCHY_BRCMFMAC_CONF && ! -e $OMARCHY_BRCMFMAC_PENDING ]] || fail "cleanup and rebuild"
grep -qx 'mkinitcpio -P' "$TEST_LOG" || fail "initramfs rebuilt"
: > "$TEST_LOG"
run
[[ ! -s $TEST_LOG ]] || fail "second run is a no-op"
pass "hardware gates, complete cleanup and idempotence"
reset
printf 'options brcmfmac roamoff=1\n\n%s\n' "$block" > "$OMARCHY_BRCMFMAC_CONF"
run
[[ $(cat "$OMARCHY_BRCMFMAC_CONF") == 'options brcmfmac roamoff=1' ]] || fail "custom prefix preserved"
reset
mv "$OMARCHY_BRCMFMAC_CONF" "$tmp/target"
ln -s "$tmp/target" "$OMARCHY_BRCMFMAC_CONF"
run
[[ -L $OMARCHY_BRCMFMAC_CONF && ! -s $tmp/target ]] || fail "symlink preserved"
reset
printf '%s\n# custom suffix\n' "$block" >> "$OMARCHY_BRCMFMAC_CONF"
cp "$OMARCHY_BRCMFMAC_CONF" "$tmp/expected"
run
cmp "$tmp/expected" "$OMARCHY_BRCMFMAC_CONF" || fail "custom config untouched"
! grep -q mkinitcpio "$TEST_LOG" || fail "no rebuild for custom config"
pass "custom content and symlinks preserved"
reset
if REBUILD_FAIL=1 run; then fail "rebuild failure propagates"; fi
[[ -f $OMARCHY_BRCMFMAC_PENDING && ! -e $OMARCHY_BRCMFMAC_CONF ]] || fail "failed rebuild remains pending"
run
[[ ! -e $OMARCHY_BRCMFMAC_PENDING ]] || fail "retry completes after config already removed"
reset
if IO_FAIL=cat run; then fail "read failure propagates"; fi
[[ -f $OMARCHY_BRCMFMAC_CONF && ! -e $OMARCHY_BRCMFMAC_PENDING ]] || fail "read failure leaves config"
reset
if IO_FAIL=rm run; then fail "edit failure propagates"; fi
[[ -f $OMARCHY_BRCMFMAC_CONF && -f $OMARCHY_BRCMFMAC_PENDING ]] || fail "edit failure remains pending"
run
[[ ! -e $OMARCHY_BRCMFMAC_PENDING ]] || fail "edit retry completes"
pass "privileged failures propagate and retries fulfill rebuild obligation"
