echo "Install the brcmfmac post-resume reload fix on affected Broadcom Wi-Fi"

sys_vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"

if lspci -nn | grep "106b:180[12]" >/dev/null ||
  { [[ $sys_vendor == Apple* ]] &&
    lspci -nn | grep -E "14e4:(43ba|43bb|43bc|43a3|43dc|4464|4488|4425|4433)" >/dev/null; }; then
  source "$OMARCHY_PATH/install/hardware/apple/fix-brcmfmac-resume.sh"
fi
