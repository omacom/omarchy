echo "Install VMware guest tools on existing VMware systems"

if [[ $(systemd-detect-virt --vm) == "vmware" ]]; then
  omarchy-pkg-add open-vm-tools
  units=()
  for unit in vmtoolsd.service vmware-vmblock-fuse.service; do
    enabled=$(systemctl is-enabled "$unit" 2>/dev/null || true)
    if [[ $enabled != "enabled" ]] || ! systemctl is-active --quiet "$unit"; then
      units+=("$unit")
    fi
  done
  if (( ${#units[@]} > 0 )); then
    sudo systemctl enable --now "${units[@]}"
  fi
fi
