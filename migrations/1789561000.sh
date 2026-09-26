echo "Stop broken TPM PCR units from forcibly rebooting the machine"

# Upstream systemd-pcrphase*.service / systemd-pcrfs*.service use
# FailureAction=reboot-force. On hardware where the TPM is present but dead
# (ThinkPad T470 and similar), that turns a failed measurement into a login
# loop. Omarchy ships FailureAction=none drop-ins; reload so they apply now.

systemd_dir="${OMARCHY_SYSTEMD_SYSTEM_DIR:-/etc/systemd/system}"
source_root="${OMARCHY_PATH:-/usr/share/omarchy}"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

units=(
  systemd-pcrphase-sysinit.service
  systemd-pcrphase.service
  systemd-pcrmachine.service
  systemd-pcrfs-root.service
  'systemd-pcrfs@.service'
)

for unit in "${units[@]}"; do
  drop_in="$systemd_dir/${unit}.d/10-omarchy-no-force-reboot.conf"
  source="$source_root/etc/systemd/system/${unit}.d/10-omarchy-no-force-reboot.conf"

  if [[ ! -f $drop_in && -f $source ]]; then
    as_root mkdir -p "${drop_in%/*}"
    as_root install -m644 "$source" "$drop_in"
  fi
done

as_root systemctl daemon-reload >/dev/null 2>&1 || omarchy-state set reboot-required
