echo "Install VMware guest tools on existing VMware systems"

if [[ $(systemd-detect-virt --vm) == "vmware" ]]; then
  omarchy-pkg-add open-vm-tools
  units=()
  for unit in vmtoolsd.service vmware-vmblock-fuse.service; do
    if ! systemctl is-enabled --quiet "$unit" || ! systemctl is-active --quiet "$unit"; then
      units+=("$unit")
    fi
  done
  if (( ${#units[@]} > 0 )); then
    sudo systemctl enable --now "${units[@]}"
  fi
fi
