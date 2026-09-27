echo "Install WiFi resume hook on T2 MacBooks"

if lspci -nn | grep -q "106b:180[12]" && [[ ! -f /usr/lib/systemd/system-sleep/wifi-resume ]]; then
  cat <<'HOOK' | sudo tee /usr/lib/systemd/system-sleep/wifi-resume >/dev/null
#!/bin/bash
if [[ $1 == "post" ]]; then
  logger -t wifi-resume "Reloading brcmfmac after resume"
  modprobe -r brcmfmac_wcc brcmfmac 2>/dev/null
  modprobe brcmfmac || logger -t wifi-resume "Failed to reload brcmfmac"
fi
HOOK
  sudo chmod +x /usr/lib/systemd/system-sleep/wifi-resume
fi
