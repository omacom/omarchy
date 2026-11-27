echo "Enable boot-time app.slice MemoryMax containment on >=64 GiB machines"

# Wait until omarchy-settings delivers the helper and unit.
if [[ ! -f /usr/lib/systemd/system/omarchy-high-memory.service || ! -x /usr/bin/omarchy-hw-app-slice-cap ]]; then
  echo "Waiting for the omarchy-settings package that ships omarchy-high-memory.service" >&2
  exit 75
fi

if ! systemctl is-enabled --quiet omarchy-high-memory.service 2>/dev/null ||
  ! systemctl is-active --quiet omarchy-high-memory.service 2>/dev/null; then
  sudo systemctl enable --now omarchy-high-memory.service
fi

dropin=/run/systemd/user/app.slice.d/20-omarchy-high-memory.conf
if [[ -f $dropin ]] && systemctl --user show-environment >/dev/null 2>&1; then
  cur_max=$(systemctl --user show -p MemoryMax --value app.slice 2>/dev/null || true)
  if [[ $cur_max == "infinity" ]]; then
    cap_mib=$(awk -F'[=M]' '/^MemoryMax=[0-9]+M$/ { print $2; exit }' "$dropin" 2>/dev/null || true)
    cur_bytes=$(systemctl --user show -p MemoryCurrent --value app.slice 2>/dev/null || true)
    if [[ $cap_mib =~ ^[0-9]+$ && $cur_bytes =~ ^[0-9]+$ ]] && (( cur_bytes >= cap_mib * 1048576 )); then
      # Applying a lower MemoryMax live would synchronously OOM-kill active work.
      omarchy-state set reboot-required
    else
      systemctl --user daemon-reload
    fi
  fi
fi
