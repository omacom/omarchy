SNAPPER_CONFIG_PATH="${OMARCHY_SNAPPER_CONFIG_PATH:-/etc/snapper/configs/root}"
SNAPPER_HOME_CONFIG_PATH="${OMARCHY_SNAPPER_HOME_CONFIG_PATH:-/etc/snapper/configs/home}"
SNAPPER_CONF_PATH="${OMARCHY_SNAPPER_CONF_PATH:-/etc/conf.d/snapper}"
SNAPPER_HOME="${OMARCHY_SNAPPER_HOME:-/home}"
template="${OMARCHY_SNAPPER_TEMPLATE:-${OMARCHY_PATH:-/usr/share/omarchy}/default/snapper/root}"
home_template="${OMARCHY_SNAPPER_HOME_TEMPLATE:-${OMARCHY_PATH:-/usr/share/omarchy}/default/snapper/home}"

echo "Configuring Omarchy Snapper snapshot retention"

create_config() {
  local name="$1" subvolume="$2" path="$3"

  if [[ ! -f $path ]]; then
    mkdir -p "$(dirname "$path")"

    if [[ ${OMARCHY_SNAPPER_CONFIGURE_TEST:-0} == "1" ]]; then
      : >"$path"
    else
      snapper --no-dbus -c "$name" create-config "$subvolume" >/dev/null 2>&1 || snapper -c "$name" create-config "$subvolume" >/dev/null
    fi
  fi
}

create_config root / "$SNAPPER_CONFIG_PATH"
install -m 0644 "$template" "$SNAPPER_CONFIG_PATH"
configs="root"

# /home is snapshotted only where it is a subvolume of its own, as the installer
# lays it out; otherwise it is part of / and rolls back with it.
if btrfs subvolume show "$SNAPPER_HOME" >/dev/null 2>&1; then
  create_config home "$SNAPPER_HOME" "$SNAPPER_HOME_CONFIG_PATH"
  install -m 0644 "$home_template" "$SNAPPER_HOME_CONFIG_PATH"
  configs="root home"

  # Readable but never writable, so people restore their own files without root;
  # each home inside a snapshot keeps its own permissions.
  if [[ -d $SNAPPER_HOME/.snapshots ]]; then
    chmod 0755 "$SNAPPER_HOME/.snapshots"
  fi
fi

mkdir -p "$(dirname "$SNAPPER_CONF_PATH")"
printf 'SNAPPER_CONFIGS="%s"\n' "$configs" >"$SNAPPER_CONF_PATH"
chmod 0644 "$SNAPPER_CONF_PATH"

# snapperd keeps the configs it read at start, and would clean up by the old ones.
systemctl try-restart snapperd.service >/dev/null 2>&1 || true

# Only /home's config creates timeline snapshots; root's says no.
systemctl enable --now snapper-timeline.timer snapper-cleanup.timer limine-snapper-sync.service >/dev/null 2>&1 || true
