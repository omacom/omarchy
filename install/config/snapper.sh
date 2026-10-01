SNAPPER_CONFIG_PATH="${OMARCHY_SNAPPER_CONFIG_PATH:-/etc/snapper/configs/root}"
SNAPPER_CONF_PATH="${OMARCHY_SNAPPER_CONF_PATH:-/etc/conf.d/snapper}"
template="${OMARCHY_SNAPPER_TEMPLATE:-${OMARCHY_PATH:-/usr/share/omarchy}/default/snapper/root}"
SNAPPER_INIT_MARKER="${OMARCHY_SNAPPER_INIT_MARKER:-${SNAPPER_CONFIG_PATH}.omarchy-initializing}"

# Omarchy 3.x copied this template over the root config verbatim. A file still
# matching it is Omarchy's earlier policy, not the user's, so it gets upgraded.
omarchy_3_template='# Omarchy snapshots root only for pre-update recovery — kept to 5, no timeline
SUBVOLUME="/"
FSTYPE="btrfs"

NUMBER_LIMIT="5"
NUMBER_LIMIT_IMPORTANT="5"

TIMELINE_CREATE="no"'

echo "Configuring Omarchy Snapper snapshot retention"

if [[ ! -f $SNAPPER_CONFIG_PATH ]]; then
  mkdir -p "$(dirname "$SNAPPER_CONFIG_PATH")"

  if [[ ${OMARCHY_SNAPPER_CONFIGURE_TEST:-0} == "1" ]]; then
    : >"$SNAPPER_CONFIG_PATH"
  else
    snapper --no-dbus -c root create-config / >/dev/null 2>&1 || snapper -c root create-config / >/dev/null
  fi

  # Keep the exact config Omarchy created as the recovery marker. On a retry we
  # only replace the config if it is still byte-for-byte unchanged; intervening
  # user edits turn it into user policy and must be preserved.
  cp -- "$SNAPPER_CONFIG_PATH" "$SNAPPER_INIT_MARKER"
fi

if [[ -f $SNAPPER_INIT_MARKER ]]; then
  if cmp -s "$SNAPPER_INIT_MARKER" "$SNAPPER_CONFIG_PATH"; then
    install -m 0644 "$template" "$SNAPPER_CONFIG_PATH"
    rm -f "$SNAPPER_INIT_MARKER"
  else
    echo "Preserving Snapper root retention policy changed during interrupted initialization"
    rm -f "$SNAPPER_INIT_MARKER"
  fi
elif [[ $(<"$SNAPPER_CONFIG_PATH") == "$omarchy_3_template" ]]; then
  install -m 0644 "$template" "$SNAPPER_CONFIG_PATH"
else
  echo "Preserving existing Snapper root retention policy"
fi

mkdir -p "$(dirname "$SNAPPER_CONF_PATH")"
printf '%s\n' 'SNAPPER_CONFIGS="root"' >"$SNAPPER_CONF_PATH"
chmod 0644 "$SNAPPER_CONF_PATH"

systemctl disable --now snapper-timeline.timer >/dev/null 2>&1 || true
systemctl enable --now snapper-cleanup.timer limine-snapper-sync.service >/dev/null 2>&1 || true
