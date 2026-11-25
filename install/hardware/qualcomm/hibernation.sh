# Hibernation on the Snapdragon X1 laptops: Hamoa (X Elite and the larger X Plus)
# and Purwa (the 8-core X Plus and X). Every one of their device trees ends in
# one of the two SoC names.

systemd_dir=${OMARCHY_QUALCOMM_SYSTEMD_DIR:-/etc/systemd/system}
sleep_hook_dir=${OMARCHY_QUALCOMM_SLEEP_HOOK_DIR:-/usr/lib/systemd/system-sleep}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree qcom,x1e80100 qcom,x1p42100; then
  # Stop the DSPs and Wi-Fi before hibernating and boot them again after the
  # resume, also after a hibernation that failed. The unit runs before the
  # sleep service, which freezes user.slice: the sound card's removal would
  # then wait for a frozen PipeWire forever. The sleep services require it, so
  # no hibernation starts when a driver would not unload. The timeouts cover
  # the helper's longest path, all its waits running out: a unit killed while
  # the drivers come back leaves the watchdog unfed and resets the laptop.
  # The hook that stops the unit after a failed hibernation goes in first, so
  # a failed copy stops this step (it runs under errexit) before the unit
  # exists.
  install -Dm755 "$OMARCHY_PATH/default/systemd/system-sleep/omarchy-qualcomm-hibernate-recover" \
    "$sleep_hook_dir/omarchy-qualcomm-hibernate-recover"
  mkdir -p "$systemd_dir"
  cat >"$systemd_dir/omarchy-qualcomm-hibernate.service" <<'UNIT'
[Unit]
Description=Stop the Snapdragon X1 DSPs and Wi-Fi around hibernation
Before=systemd-hibernate.service systemd-hybrid-sleep.service systemd-suspend-then-hibernate.service
StopWhenUnneeded=yes

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash /usr/share/omarchy/install/hardware/qualcomm/hibernation-drivers.sh pre
ExecStop=/bin/bash /usr/share/omarchy/install/hardware/qualcomm/hibernation-drivers.sh post
TimeoutStartSec=300
TimeoutStopSec=300

[Install]
WantedBy=hibernate.target hybrid-sleep.target suspend-then-hibernate.target
RequiredBy=systemd-hibernate.service systemd-hybrid-sleep.service systemd-suspend-then-hibernate.service
UNIT
  systemctl enable omarchy-qualcomm-hibernate.service
fi
