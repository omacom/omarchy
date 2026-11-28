#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Stub omarchy-hw-x86, omarchy-hw-match, and sudo for isolated leaf testing.
mkdir -p "$test_tmp/bin" "$test_tmp/fw/ti/audio/tas2783"
: >"$test_tmp/fw/ti/audio/tas2783/8EA2-0-0-0x9.bin.zst"
: >"$test_tmp/fw/ti/audio/tas2783/8EA2-0-0-0xC.bin.zst"

cat >"$test_tmp/bin/omarchy-hw-x86" <<'EOF'
#!/bin/bash
exit 0
EOF
cat >"$test_tmp/bin/omarchy-hw-match" <<'EOF'
#!/bin/bash
[[ ${MOCK_MATCH:-0} == "1" ]]
EOF
cat >"$test_tmp/bin/sudo" <<'EOF'
#!/bin/bash
"$@"
EOF
chmod +x "$test_tmp/bin/omarchy-hw-x86" "$test_tmp/bin/omarchy-hw-match" "$test_tmp/bin/sudo"

# Non-matching machine is a no-op.
PATH="$test_tmp/bin:$PATH" MOCK_MATCH=0 OMARCHY_HP_OMNIBOOK_FW_DIR="$test_tmp/fw" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/hardware/hp/fix-hp-omnibook-x-flip-audio.sh"
[[ ! -e $test_tmp/fw/8EA2-0-0x9.bin.zst && ! -e $test_tmp/fw/8EA2-0-0xC.bin.zst ]] ||
  fail "non-matching machine writes no firmware symlinks"
pass "non-matching machine writes no firmware symlinks"

# Matching HP OmniBook X Flip 16 creates 3-field relative symlinks.
PATH="$test_tmp/bin:$PATH" MOCK_MATCH=1 OMARCHY_HP_OMNIBOOK_FW_DIR="$test_tmp/fw" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/hardware/hp/fix-hp-omnibook-x-flip-audio.sh"
[[ $(readlink "$test_tmp/fw/8EA2-0-0x9.bin.zst") == "ti/audio/tas2783/8EA2-0-0-0x9.bin.zst" &&
   $(readlink "$test_tmp/fw/8EA2-0-0xC.bin.zst") == "ti/audio/tas2783/8EA2-0-0-0xC.bin.zst" ]] ||
  fail "matching HP OmniBook X Flip creates 3-field TAS2783 firmware symlinks"
pass "matching HP OmniBook X Flip creates 3-field TAS2783 firmware symlinks"

# Re-running does not overwrite an existing 3-field firmware file.
rm "$test_tmp/fw/8EA2-0-0x9.bin.zst"
: >"$test_tmp/fw/8EA2-0-0x9.bin"
PATH="$test_tmp/bin:$PATH" MOCK_MATCH=1 OMARCHY_HP_OMNIBOOK_FW_DIR="$test_tmp/fw" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/hardware/hp/fix-hp-omnibook-x-flip-audio.sh"
[[ -f $test_tmp/fw/8EA2-0-0x9.bin && ! -e $test_tmp/fw/8EA2-0-0x9.bin.zst ]] ||
  fail "re-run preserves existing 3-field firmware files"
pass "re-run preserves existing 3-field firmware files"

# In-repo UCM2 profile layout packaged by omarchy-settings.
[[ -f $ROOT/default/alsa/ucm2/AMD/amd-soundwire/HP-OmniBook-X-Flip.conf &&
   -f $ROOT/default/alsa/ucm2/AMD/amd-soundwire/HP-OmniBook-X-Flip-HiFi.conf &&
   -f $ROOT/default/alsa/ucm2/AMD/amd-soundwire/LICENSE.HP-OmniBook &&
   $(readlink "$ROOT/default/alsa/ucm2/conf.d/amd-soundwire/HP-HPOmniBookXFlipLaptop16_cc0xxx-Type1ProductConfigId-8EA2.conf") == "../../AMD/amd-soundwire/HP-OmniBook-X-Flip.conf" ]] ||
  fail "default/alsa/ucm2 ships HP OmniBook X Flip profile, license, and conf.d symlink"
pass "default/alsa/ucm2 ships HP OmniBook X Flip profile, license, and conf.d symlink"

# Live non-destructive ALSA UCM2 parse check when amd-soundwire is present.
amdsdw_card=""
for card_id in /proc/asound/card*/id; do
  if [[ -r $card_id && $(<"$card_id") == "amdsoundwire" ]]; then
    amdsdw_card=${card_id#/proc/asound/card}
    amdsdw_card=${amdsdw_card%/id}
    break
  fi
done

if [[ -n $amdsdw_card && -d /usr/share/alsa/ucm2 ]] && command -v alsaucm >/dev/null 2>&1; then
  ucm_overlay="$test_tmp/ucm2-overlay"
  cp -a /usr/share/alsa/ucm2 "$ucm_overlay"
  cp -a "$ROOT/default/alsa/ucm2/." "$ucm_overlay/"

  verbs=$(ALSA_CONFIG_UCM2="$ucm_overlay" alsaucm -c "hw:$amdsdw_card" list _verbs)
  grep -q 'HiFi' <<<"$verbs" || fail "UCM2 profile exposes HiFi verb on amd-soundwire" "$verbs"
  pass "UCM2 profile exposes HiFi verb on amd-soundwire"

  dump=$(ALSA_CONFIG_UCM2="$ucm_overlay" alsaucm -c "hw:$amdsdw_card" dump text)
  if grep -q 'Device\.Speaker' <<<"$dump" &&
     grep -q 'Device\.Headphones' <<<"$dump" &&
     grep -q 'Device\.Mic' <<<"$dump" &&
     grep -q 'Device\.Headset' <<<"$dump" &&
     grep -q 'JackControl "Headphone Jack"' <<<"$dump" &&
     grep -q 'JackControl "Headset Mic Jack"' <<<"$dump" &&
     grep -q 'PlaybackPCM ".*hw:amdsoundwire,2"' <<<"$dump" &&
     grep -q 'PlaybackPCM ".*hw:amdsoundwire"' <<<"$dump" &&
     grep -q 'CapturePCM ".*hw:amdsoundwire,4"' <<<"$dump" &&
     grep -q 'CapturePCM ".*hw:amdsoundwire,1"' <<<"$dump" &&
     ! grep -q ',3"' <<<"$dump"; then
    pass "UCM2 profile maps Speaker/Headphones/Mic/Headset on PCM 2/0/4/1 and omits PCM 3"
  else
    fail "UCM2 profile maps Speaker/Headphones/Mic/Headset on PCM 2/0/4/1 and omits PCM 3" "$dump"
  fi
else
  skip "no live amd-soundwire card or alsaucm; skipping live UCM2 parse check"
fi
