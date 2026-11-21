# Called as root by system installation or the upgrade migration. Completion
# is machine-wide: another user's migration must not undo a later opt-out.
(
  unit=omarchy-docked-lid-inhibit.service
  vendor_unit=/usr/lib/systemd/system/omarchy-docked-lid-inhibit.service
  local_unit=/etc/systemd/system/omarchy-docked-lid-inhibit.service
  state_dir=/var/lib/omarchy
  marker="$state_dir/docked-lid-inhibit.initialized"

  [[ -f $vendor_unit ]] || {
    echo "The omarchy-settings package must provide $vendor_unit before lid protection can be enabled" >&2
    exit 1
  }

  install -d -m0755 "$state_dir"
  exec 9>"$state_dir/docked-lid-inhibit.lock"
  flock -x 9

  if [[ ! -f $marker ]]; then
    enabled_state=$(systemctl is-enabled "$unit" 2>/dev/null) || true
    previously_installed=false
    removed_copy=false

    if [[ -e $local_unit || -L $local_unit ]]; then
      previously_installed=true
      if [[ -f $local_unit && ! -L $local_unit ]]; then
        digest=$(sha256sum "$local_unit")
        # Only retire the two unchanged definitions used by earlier PR builds.
        # Preserve administrator-authored units and /dev/null masks.
        case ${digest%% *} in
          f33ce1b85e1673659decc56ad396a66389fbd09050298e4be08e8aa042ee056c | \
            551065c792a3340c7b7f614ec0b11ae0c6aaeef7b8a88115114d13b3d48feb2a)
            rm -- "$local_unit"
            removed_copy=true
            ;;
        esac
      fi
    fi

    if [[ ${1:-} == "--start" ]]; then
      systemctl daemon-reload
    fi

    case $enabled_state in
      masked | masked-runtime)
        # A mask is an explicit opt-out, including before the first migration.
        ;;
      enabled | enabled-runtime)
        if $removed_copy; then
          # Replace enablement links that still target the retired /etc copy.
          if [[ $enabled_state == "enabled-runtime" ]]; then
            systemctl --runtime reenable "$unit"
          else
            systemctl reenable "$unit"
          fi
        fi
        [[ ${1:-} != "--start" ]] || systemctl start "$unit"
        ;;
      *)
        # An existing local definition may have been intentionally disabled.
        if ! $previously_installed; then
          systemctl enable "$unit"
          [[ ${1:-} != "--start" ]] || systemctl start "$unit"
        fi
        ;;
    esac

    # Publish completion only after activation succeeds, so failures retry.
    install -m0644 /dev/null "$marker"
  fi
)
