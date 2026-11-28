if omarchy-hw-intel && [[ -e /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost ]]; then
  install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-powerprofiles-intel.service" \
    /etc/systemd/system/omarchy-powerprofiles-intel.service
  systemctl enable omarchy-powerprofiles-intel.service

  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    systemctl start --no-block omarchy-powerprofiles-intel.service || true
  fi
fi
