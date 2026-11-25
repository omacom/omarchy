# Lenovo Yoga Slim 7x (14Q8X9, DMI product name 83ED) board-specific setup.

modules_load_dir=${OMARCHY_YOGA_MODULES_LOAD_DIR:-/etc/modules-load.d}
mkinitcpio_dir=${OMARCHY_YOGA_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
limine_config_dir=${OMARCHY_YOGA_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
systemd_dir=${OMARCHY_YOGA_SYSTEMD_DIR:-/etc/systemd/system}
sleep_hook_dir=${OMARCHY_YOGA_SLEEP_HOOK_DIR:-/usr/lib/systemd/system-sleep}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "83ED"; then
  echo "Detected Lenovo Yoga Slim 7x, applying board-specific support..."

  # The Yoga exposes its CPU performance domains through SCMI.
  mkdir -p "$modules_load_dir"
  echo "scmi-cpufreq" >"$modules_load_dir/yoga-slim7x.conf"

  # Initialize the internal keyboard and display before disk unlock.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/yoga-slim7x-initramfs.conf" <<'CONF'
MODULES+=(i2c-hid-of qrtr ps883x pmic_glink_altmode)

# The board-signed zap shader is included by qcom-firmware-extract.
# Search like the kernel does: each suffix in every directory, then the next.
for firmware in \
  qcom/gen70500_sqe.fw \
  qcom/gen70500_gmu.bin; do
  for suffix in '' .zst .xz; do
    for directory in "${OMARCHY_YOGA_FIRMWARE_ROOT:-/usr/lib/firmware}/updates" \
      "${OMARCHY_YOGA_FIRMWARE_ROOT:-/usr/lib/firmware}"; do
      if [[ -f $directory/$firmware$suffix ]]; then
        FILES+=("$directory/$firmware$suffix")
        break 2
      fi
    done
  done
done
unset firmware directory suffix
CONF

  mkdir -p "$limine_config_dir"
  cat >"$limine_config_dir/yoga-slim7x.conf" <<'CONF'
KERNEL_CMDLINE[default]+=" initcall_blacklist=simpledrm_platform_driver_init"
# Keep Plymouth and the keyboard hooks on the laptop console, not the serial port.
KERNEL_CMDLINE[default]+=" console=tty0"
CONF

  # Start the board's DSP remote processors.
  mkdir -p "$systemd_dir"
  cat >"$systemd_dir/yoga-slim7x-remoteprocs.service" <<'UNIT'
[Unit]
Description=Start the Lenovo Yoga Slim 7x DSPs
ConditionPathExists=!/etc/modprobe.d/qualcomm-adsp-nofw.conf

[Service]
Type=oneshot
ExecStart=/bin/bash /usr/share/omarchy/install/hardware/lenovo/start-yoga-slim7x-remoteprocs.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
UNIT
  systemctl enable yoga-slim7x-remoteprocs.service

  # Keep deep suspend with the lid open from waking itself.
  install -Dm755 "$OMARCHY_PATH/default/systemd/system-sleep/yoga-slim7x-lid-wake" \
    "$sleep_hook_dir/yoga-slim7x-lid-wake"

  # Stop the DSPs and Wi-Fi before hibernating and boot them again after the
  # resume, also after a hibernation that failed. The unit runs before the
  # sleep service, which freezes user.slice: the sound card's removal would
  # then wait for a frozen PipeWire forever. The sleep services require it, so
  # no hibernation starts when a driver would not unload. The timeouts cover
  # the helper's longest path, all its waits running out: a unit killed while
  # the drivers come back leaves the watchdog unfed and resets the laptop.
  cat >"$systemd_dir/yoga-slim7x-hibernate.service" <<'UNIT'
[Unit]
Description=Stop the Lenovo Yoga Slim 7x DSPs and Wi-Fi around hibernation
Before=systemd-hibernate.service systemd-hybrid-sleep.service systemd-suspend-then-hibernate.service
StopWhenUnneeded=yes

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash /usr/share/omarchy/install/hardware/lenovo/yoga-slim7x-hibernate.sh pre
ExecStop=/bin/bash /usr/share/omarchy/install/hardware/lenovo/yoga-slim7x-hibernate.sh post
TimeoutStartSec=300
TimeoutStopSec=300

[Install]
WantedBy=hibernate.target hybrid-sleep.target suspend-then-hibernate.target
RequiredBy=systemd-hibernate.service systemd-hybrid-sleep.service systemd-suspend-then-hibernate.service
UNIT
  systemctl enable yoga-slim7x-hibernate.service
  install -Dm755 "$OMARCHY_PATH/default/systemd/system-sleep/yoga-slim7x-hibernate-recover" \
    "$sleep_hook_dir/yoga-slim7x-hibernate-recover"
fi
