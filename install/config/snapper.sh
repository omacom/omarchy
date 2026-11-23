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

# The configs snapper runs now, other than root, that still exist.
listed=()
if [[ -f $SNAPPER_CONF_PATH ]]; then
  for name in $(. "$SNAPPER_CONF_PATH" >/dev/null 2>&1; echo "${SNAPPER_CONFIGS:-}"); do
    [[ $name != "root" && -f $SNAPPER_CONFIG_DIR/$name ]] && listed+=("$name")
  done
fi

# Someone's own config for /home: one under another name, or one called home
# that isn't Omarchy's.
theirs=""
for name in "${listed[@]}"; do
  if grep -qx "SUBVOLUME=\"$SNAPPER_HOME\"" "$SNAPPER_CONFIG_DIR/$name" &&
    { [[ $name != "home" ]] || ! grep -qxF "$(head -n 1 "$home_template")" "$SNAPPER_CONFIG_DIR/$name"; }; then
    theirs="$name"
  fi
done

create_config root / || { echo "Could not create the Snapper config for /" >&2; exit 1; }
install -m 0644 "$template" "$SNAPPER_CONFIG_DIR/root"
configs=(root)
omarchy_home=$(head -n 1 "$home_template")
for name in "${listed[@]}"; do
  # Omarchy's own home config is added back below, where /home still has one.
  [[ $name == "home" ]] && grep -qxF "$omarchy_home" "$SNAPPER_CONFIG_DIR/home" && continue
  configs+=("$name")
done

ours=0
# /home is snapshotted only where it is a subvolume of its own, as the installer
# lays it out; otherwise it is part of / and rolls back with it.
if [[ -n $theirs ]]; then
  echo "Leaving /home to the Snapper config \"$theirs\" that already snapshots it"
elif btrfs subvolume show "$SNAPPER_HOME" >/dev/null 2>&1; then
  if create_config home "$SNAPPER_HOME" &&
    install -m 0644 "$home_template" "$SNAPPER_CONFIG_DIR/home" &&
    # A factory reset or a hand-deleted folder leaves the config without it.
    { [[ -d $SNAPPER_HOME/.snapshots ]] || btrfs subvolume create "$SNAPPER_HOME/.snapshots" >/dev/null; } &&
    # Readable but never writable, so people restore their own files without
    # root; each home inside a snapshot keeps its own permissions.
    chmod 0755 "$SNAPPER_HOME/.snapshots"; then
    configs+=(home)
    ours=1
  else
    # Usually a .snapshots left from an earlier config, which create-config won't reuse.
    echo "Could not set up Snapper for /home, so it is not snapshotted" >&2
  fi
fi

mkdir -p "$(dirname "$SNAPPER_CONF_PATH")"
printf 'SNAPPER_CONFIGS="%s"\n' "${configs[*]}" >"$SNAPPER_CONF_PATH"
chmod 0644 "$SNAPPER_CONF_PATH"

# snapperd keeps the configs it read at start, and would clean up by the old ones.
systemctl try-restart snapperd.service >/dev/null 2>&1 || true

# Root's config creates no timeline snapshots, so the timer is /home's, or left
# as someone set it for a config of their own.
if (( ours )); then
  systemctl enable --now snapper-timeline.timer >/dev/null 2>&1 || true
fi
systemctl enable --now snapper-cleanup.timer limine-snapper-sync.service >/dev/null 2>&1 || true
