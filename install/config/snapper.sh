SNAPPER_CONFIG_PATH="${OMARCHY_SNAPPER_CONFIG_PATH:-/etc/snapper/configs/root}"
SNAPPER_CONF_PATH="${OMARCHY_SNAPPER_CONF_PATH:-/etc/conf.d/snapper}"
template="${OMARCHY_SNAPPER_TEMPLATE:-${OMARCHY_PATH:-/usr/share/omarchy}/default/snapper/root}"

# Snapshots of / only work on a btrfs root, and snapper is only a dependency on
# x86_64 (limine-snapper-sync pulls it in there). Without either, this step
# would fail and abort `omarchy apply system` before the leaves after it run.
if omarchy-cmd-missing snapper; then
  echo "snapper is not installed; skipping Omarchy Snapper configuration"
  exit 0
fi
root_fstype=$(findmnt -no FSTYPE / 2>/dev/null || true)
if [[ ${root_fstype:-} != "btrfs" ]]; then
  echo "Root filesystem is ${root_fstype:-unknown}, not btrfs; skipping Omarchy Snapper configuration"
  exit 0
fi

echo "Configuring Omarchy Snapper snapshot retention"

if [[ ! -f $SNAPPER_CONFIG_PATH ]]; then
  mkdir -p "$(dirname "$SNAPPER_CONFIG_PATH")"

  if [[ ${OMARCHY_SNAPPER_CONFIGURE_TEST:-0} == "1" ]]; then
    : >"$SNAPPER_CONFIG_PATH"
  else
    snapper --no-dbus -c root create-config / >/dev/null 2>&1 || snapper -c root create-config / >/dev/null
  fi
fi

install -m 0644 "$template" "$SNAPPER_CONFIG_PATH"

mkdir -p "$(dirname "$SNAPPER_CONF_PATH")"
printf '%s\n' 'SNAPPER_CONFIGS="root"' >"$SNAPPER_CONF_PATH"
chmod 0644 "$SNAPPER_CONF_PATH"

systemctl disable --now snapper-timeline.timer >/dev/null 2>&1 || true
# Limine lists snapshots through limine-snapper-sync. systemd-boot's snapshot
# entries come from omarchy-boot-sync instead.
units=(snapper-cleanup.timer)
if [[ $(omarchy-boot-backend) != systemd-boot ]]; then
  units+=(limine-snapper-sync.service)
fi
systemctl enable --now "${units[@]}" >/dev/null 2>&1 || true
