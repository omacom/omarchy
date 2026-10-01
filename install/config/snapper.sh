SNAPPER_CONFIG_PATH="${OMARCHY_SNAPPER_CONFIG_PATH:-/etc/snapper/configs/root}"
SNAPPER_CONF_PATH="${OMARCHY_SNAPPER_CONF_PATH:-/etc/conf.d/snapper}"
template="${OMARCHY_SNAPPER_TEMPLATE:-${OMARCHY_PATH:-/usr/share/omarchy}/default/snapper/root}"

echo "Normalizing Omarchy Snapper snapshot retention"

root_fstype=$(findmnt -no FSTYPE /)

if [[ $root_fstype == "btrfs" ]]; then
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
  systemctl enable --now snapper-cleanup.timer limine-snapper-sync.service >/dev/null 2>&1 || true
else
  config_dir=$(dirname "$SNAPPER_CONFIG_PATH")

  if [[ -f $SNAPPER_CONFIG_PATH ]] &&
    grep -qFx 'SUBVOLUME="/"' "$SNAPPER_CONFIG_PATH" &&
    grep -qFx 'FSTYPE="btrfs"' "$SNAPPER_CONFIG_PATH"; then
    rm -f "$SNAPPER_CONFIG_PATH"
  fi

  snapper_configs=""
  if [[ -f $SNAPPER_CONF_PATH ]]; then
    snapper_configs=$(awk -v single="'" '
      /^[[:space:]]*SNAPPER_CONFIGS[[:space:]]*=/ {
        value = $0
        if (value ~ /^[^=]*=[[:space:]]+#/) { value = ""; next }
        sub(/^[^=]*=[[:space:]]*/, "", value)
        quote = substr(value, 1, 1)
        if (quote == "\"" || quote == single) {
          value = substr(value, 2)
          value = substr(value, 1, index(value, quote) - 1)
        } else {
          sub(/[[:space:]]+#.*/, "", value)
          sub(/[[:space:]]*$/, "", value)
        }
      }
      END { print value }
    ' "$SNAPPER_CONF_PATH")
    if [[ ! -e $SNAPPER_CONFIG_PATH && " $snapper_configs " == *" root "* ]]; then
      remaining_configs=""
      for config in $snapper_configs; do
        [[ $config == "root" ]] || remaining_configs+="${remaining_configs:+ }$config"
      done
      tmp=$(mktemp "$SNAPPER_CONF_PATH.XXXXXX")
      awk -v configs="$remaining_configs" '
        /^[[:space:]]*SNAPPER_CONFIGS[[:space:]]*=/ { print "SNAPPER_CONFIGS=\"" configs "\""; next }
        { print }
      ' "$SNAPPER_CONF_PATH" >"$tmp"
      cat "$tmp" >"$SNAPPER_CONF_PATH"
      rm -f "$tmp"
      snapper_configs=$remaining_configs
    fi
  fi

  has_configs=false
  for config in $snapper_configs; do
    if [[ -f $config_dir/$config ]]; then
      has_configs=true
      break
    fi
  done
  if ! $has_configs; then
    systemctl disable --now snapper-cleanup.timer >/dev/null 2>&1 || true
  fi

  systemctl disable --now limine-snapper-sync.service >/dev/null 2>&1 || true
fi
