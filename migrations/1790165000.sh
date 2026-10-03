echo "Restore WPA3 support on Broadcom BCM4364 and Apple Silicon Macs"

# Broadcom BCM4364 and Apple Silicon (BCM4378/4387) carry modern firmware and
# must not have SAE disabled by Omarchy's 0x82000 transition-mode quirk. The
# T2 Macs that never carried BCM4364 -- MacBook Air 13" Late 2018 / True Tone
# 2019 (BCM4355, 14e4:43dc) and MacBook Pro 13" Touch 2019 / 2020 and MacBook
# Air 13" Scissor 2020 (BCM4377, 14e4:4488) -- are excluded as a group, since
# the quirk is a wpa_supplicant workaround rather than a firmware one. Remove
# only the exact blocks written by the old T2 installer and the Broadcom
# supplicant setup, wherever they sit in the file. Administrator-authored
# variants remain untouched.
conf="${OMARCHY_BRCMFMAC_CONF:-/etc/modprobe.d/brcmfmac.conf}"

# Only run cleanup on Macs that carried the unneeded quirk:
# 1. T2 Macs (106b:180[12])
# 2. BCM4364 Macs (14e4:4464)
# 3. Apple Silicon Macs (14e4:(4425|4433))
if ! lspci -nn | grep -E "106b:180[12]|14e4:(4464|4425|4433)" >/dev/null; then
  exit 0
fi

[[ -f $conf ]] || exit 0

# Read through sudo so a root-only file fails the migration and gets retried
# rather than reading as empty and burning the per-user migration marker.
content="$(sudo cat "$conf")"

legacy_block='# Fix for T2 MacBook WiFi connectivity issues
options brcmfmac feature_disable=0x82000'

current_block="# Broadcom's firmware supplicant and authenticator fail the WPA four-way
# handshake on Apple hardware, which surfaces as a rejected password. Disable
# both so wpa_supplicant performs the handshake instead.
options brcmfmac feature_disable=0x82000"

# Drop either owned block wherever it sits on whole-line boundaries, copying
# every other line through untouched. Matching line sequences literally (rather
# than as a shell pattern) keeps a reworded comment or an administrator-merged
# options line out of scope, and lets a block sandwiched between two user lines
# go the same way as a trailing one.
rest="$(printf '%s\n' "$content" | awk -v legacy="$legacy_block" -v current="$current_block" '
  BEGIN {
    legacy_count = split(legacy, legacy_line, "\n")
    current_count = split(current, current_line, "\n")
  }
  { line[NR] = $0 }
  END {
    i = 1
    while (i <= NR) {
      if (owned(i, legacy_count, legacy_line)) count = legacy_count
      else if (owned(i, current_count, current_line)) count = current_count
      else count = 0

      if (count > 0) {
        for (j = 0; j < count; j++) owned_line[i + j] = 1
        i += count
      } else {
        i++
      }
    }

    for (k = 1; k <= NR; k++) if (!(k in owned_line)) print line[k]
  }
  function owned(start, count, text, j) {
    if (start + count - 1 > NR) return 0
    for (j = 0; j < count; j++) if (line[start + j] != text[j + 1]) return 0
    return 1
  }
')"

# Both sides have their trailing newlines stripped by command substitution, so
# an untouched file compares equal to itself. Anything else means an owned block
# was removed.
[[ $rest != "$content" ]] || exit 0

# Request the reboot before editing because brcmfmac reads module options only
# when it loads. Do not reload it during an update carried over Wi-Fi.
omarchy-state set reboot-required

if [[ -z $rest ]]; then
  if [[ -L $conf ]]; then
    : | sudo tee "$conf" >/dev/null
  else
    sudo rm -f "$conf"
  fi
else
  printf '%s\n' "$rest" | sudo tee "$conf" >/dev/null
fi
