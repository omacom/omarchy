# Some Broadcom Wi-Fi parts brcmfmac drives never recover from suspend: every
# firmware command times out after resume until the driver is unbound and
# rebound. Same population as fix-brcmfmac-supplicant.sh, since it's the
# PCIe/msgbuf chips that hit this -- confirmed on a MacBookPro11,5 with
# BCM43602, where every command after resume logs
# `brcmf_msgbuf_query_dcmd: Timeout on response for query command` in a loop
# until the machine is rebooted.
sys_vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"

if lspci -nn | grep "106b:180[12]" >/dev/null ||
  { [[ $sys_vendor == Apple* ]] &&
    lspci -nn | grep -E "14e4:(43ba|43bb|43bc|43a3|43dc|4464|4488|4425|4433)" >/dev/null; }; then
  echo "Detected a Mac with Broadcom Wi-Fi; installing the post-resume reload fix"

  sudo tee /etc/systemd/system/omarchy-brcmfmac-resume-fix.service >/dev/null <<'EOF'
[Unit]
Description=Reload brcmfmac after resume (some Broadcom Wi-Fi parts don't survive S3)
After=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
ConditionPathExists=/sys/bus/pci

[Service]
Type=oneshot
# Let the resume settle a bit before poking the PCI/driver state.
ExecStartPre=/usr/bin/sleep 3
ExecStart=/usr/bin/omarchy-brcmfmac-resume-fix

[Install]
WantedBy=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
EOF

  sudo systemctl enable omarchy-brcmfmac-resume-fix.service
fi
