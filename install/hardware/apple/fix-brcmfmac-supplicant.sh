# Apple Macs ship Broadcom Wi-Fi driven by brcmfmac. On legacy pre-T2 parts
# (such as BCM43602 and BCM4350), the 2015-era firmware offload fails against
# access points in WPA2/WPA3 transition mode: the client associates, the
# four-way handshake never completes, and NetworkManager reports the password
# as wrong. wpa_supplicant 2.11 made it worse on every brcmfmac part by
# completing WPA state from the driver's authorization event, which broke
# WPA2-PSK and WPA3-SAE association outright; Arch's 2.12 carries the fix.
#
# Disabling the firmware supplicant (FWSUP, 0x2000) and SAE (0x80000) hands the
# WPA2 handshake back to wpa_supplicant in software.
#
# This workaround MUST NOT be applied to modern Broadcom chips, which
# offload both the handshake and SAE and so lose WPA3-only support when it is
# applied:
# 1. BCM4364 (14e4:4464, in the T2 Macs and iMac19,x): disabling SAE offload
#    prevents connecting to WPA3-only networks (#9802).
# 2. Apple Silicon (14e4:4425 / 4433): brcmfmac wedges completely with this
#    quirk (#7439).
#
# Therefore, only apply to legacy pre-T2 Broadcom hardware with known-affected parts:
# BCM43602 (43ba, 43bb, 43bc) and BCM4350 (43a3). BCM4355 (43dc) and BCM4377
# (4488) are deliberately absent: Linux documents both only on T2 Macs, which
# the T2 check below already excludes.
sys_vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"

if [[ $sys_vendor == Apple* ]] &&
  ! lspci -nn | grep "106b:180[12]" >/dev/null &&
  lspci -nn | grep -E "14e4:(43ba|43bb|43bc|43a3)" >/dev/null; then
  echo "Detected a legacy Mac with Broadcom Wi-Fi; running the WPA handshake in software"

  mkdir -p /etc/modprobe.d
  cat > /etc/modprobe.d/brcmfmac.conf <<'EOF'
# Broadcom firmware on pre-T2 Macs fails the WPA four-way handshake on
# transition-mode networks. Disable firmware supplication and SAE so
# transition-mode networks use the software WPA2 handshake instead.
options brcmfmac feature_disable=0x82000
EOF
fi
