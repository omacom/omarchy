SNAPPER_CONFIG_DIR="${OMARCHY_SNAPPER_CONFIG_DIR:-/etc/snapper/configs}"
SNAPPER_CONF_PATH="${OMARCHY_SNAPPER_CONF_PATH:-/etc/conf.d/snapper}"
SNAPPER_HOME="${OMARCHY_SNAPPER_HOME:-/home}"
template="${OMARCHY_SNAPPER_TEMPLATE:-${OMARCHY_PATH:-/usr/share/omarchy}/default/snapper/root}"
home_template="${OMARCHY_SNAPPER_HOME_TEMPLATE:-${OMARCHY_PATH:-/usr/share/omarchy}/default/snapper/home}"

echo "Configuring Omarchy Snapper snapshot retention"

create_config() {
  local name="$1" subvolume="$2"

  [[ -f $SNAPPER_CONFIG_DIR/$name ]] && return 0
  mkdir -p "$SNAPPER_CONFIG_DIR"
  snapper --no-dbus -c "$name" create-config "$subvolume" >/dev/null 2>&1 || snapper -c "$name" create-config "$subvolume" >/dev/null 2>&1
}

# A config of someone's own that already snapshots /home under another name.
other_home_config() {
  local config
  for config in "$SNAPPER_CONFIG_DIR"/*; do
    [[ -f $config && ${config##*/} != "home" ]] && grep -qx "SUBVOLUME=\"$SNAPPER_HOME\"" "$config" && echo "${config##*/}" && return
  done
  return 0
}

create_config root / || { echo "Could not create the Snapper config for /" >&2; exit 1; }
install -m 0644 "$template" "$SNAPPER_CONFIG_DIR/root"
configs="root"

# /home is snapshotted only where it is a subvolume of its own, as the installer
# lays it out; otherwise it is part of / and rolls back with it.
if btrfs subvolume show "$SNAPPER_HOME" >/dev/null 2>&1; then
  other=$(other_home_config)

  if [[ -n $other ]]; then
    echo "Leaving /home to the Snapper config \"$other\" that already snapshots it"
    configs="root $other"
  elif create_config home "$SNAPPER_HOME"; then
    install -m 0644 "$home_template" "$SNAPPER_CONFIG_DIR/home"
    configs="root home"

    # A factory reset or a hand-deleted folder leaves the config without it.
    if [[ ! -d $SNAPPER_HOME/.snapshots ]]; then
      btrfs subvolume create "$SNAPPER_HOME/.snapshots" >/dev/null
    fi

    # Readable but never writable, so people restore their own files without root;
    # each home inside a snapshot keeps its own permissions.
    chmod 0755 "$SNAPPER_HOME/.snapshots"
  else
    # Usually a .snapshots left from an earlier config, which create-config won't reuse.
    echo "Could not create a Snapper config for /home, so it is not snapshotted" >&2
  fi
fi

mkdir -p "$(dirname "$SNAPPER_CONF_PATH")"
printf 'SNAPPER_CONFIGS="%s"\n' "$configs" >"$SNAPPER_CONF_PATH"
chmod 0644 "$SNAPPER_CONF_PATH"

# snapperd keeps the configs it read at start, and would clean up by the old ones.
systemctl try-restart snapperd.service >/dev/null 2>&1 || true

# Only /home's config creates timeline snapshots; root's says no. Someone's own
# /home config keeps the timer as they set it.
if [[ $configs == "root home" ]]; then
  systemctl enable --now snapper-timeline.timer >/dev/null 2>&1 || true
elif [[ $configs == "root" ]]; then
  systemctl disable --now snapper-timeline.timer >/dev/null 2>&1 || true
fi
systemctl enable --now snapper-cleanup.timer limine-snapper-sync.service >/dev/null 2>&1 || true
