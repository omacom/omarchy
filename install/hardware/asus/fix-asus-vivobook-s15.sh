# ASUS Vivobook S 15 (S5507QA / S5507QAD) Snapdragon X Elite board setup.

mkinitcpio_dir=${OMARCHY_VIVOBOOK_S15_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
limine_config_dir=${OMARCHY_VIVOBOOK_S15_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
sleep_config_dir=${OMARCHY_VIVOBOOK_S15_SLEEP_CONFIG_DIR:-/etc/systemd/sleep.conf.d}
udev_rules_dir=${OMARCHY_VIVOBOOK_S15_UDEV_RULES_DIR:-/etc/udev/rules.d}
wireplumber_dir=${OMARCHY_VIVOBOOK_S15_WIREPLUMBER_DIR:-/etc/wireplumber/wireplumber.conf.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "S5507"; then
  # S2idle modern standby: Qualcomm SoC resets on deep sleep, s2idle resumes cleanly.
  mkdir -p "$sleep_config_dir"
  cat >"$sleep_config_dir/asus-vivobook-s15.conf" <<'CONF'
[Sleep]
MemorySleepMode=s2idle
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
CONF

  # Keep SimpleDRM active for Plymouth and disk encryption passphrase prompt.
  # Early KMS msm.ko takes over fb0 before userspace, cutting OLED illumination.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/asus-vivobook-s15-initramfs.conf" <<'CONF'
_clean_hooks=()
for _h in "${HOOKS[@]}"; do
  [[ $_h == "kms" ]] || _clean_hooks+=("$_h")
done
HOOKS=("${_clean_hooks[@]}")
unset _clean_hooks _h
CONF

  mkdir -p "$limine_config_dir"
  cat >"$limine_config_dir/asus-vivobook-s15.conf" <<'CONF'
KERNEL_CMDLINE[default]+=" splash plymouth.use-simpledrm"
CONF

  # ASUS Keyboard udev rule for vendor report access and backlight control
  mkdir -p "$udev_rules_dir"
  cat >"$udev_rules_dir/70-asus-vivobook.rules" <<'RULES'
SUBSYSTEM=="hidraw", ATTRS{id/vendor}=="0b05", ATTRS{id/product}=="4543", MODE="0666", TAG+="uaccess", SYMLINK+="asus_keyboard"
RULES

  # Qualcomm LPASS macro codecs autosuspend prevention (prevents SoundWire bus errors)
  cat >"$udev_rules_dir/90-qualcomm-lpass-audio.rules" <<'RULES'
ACTION=="add", SUBSYSTEM=="platform", KERNEL=="*.lpass-*-macro", ATTR{power/control}="on"
RULES

  # WirePlumber camera priority: prioritize 1080p RGB webcam over IR and raw CAMSS nodes
  mkdir -p "$wireplumber_dir"
  cat >"$wireplumber_dir/51-default-camera-rgb.conf" <<'CONF'
monitor.v4l2.rules = [
  {
    matches = [
      {
        node.name = "~v4l2_input.*"
        device.name = "~v4l2_device.*ov02c10.*"
      }
    ]
    actions = {
      update-props = {
        priority.driver = 1500
        priority.session = 1500
      }
    }
  }
  {
    matches = [
      {
        node.name = "~v4l2_input.*"
        device.name = "~v4l2_device.*hm1092.*"
      }
    ]
    actions = {
      update-props = {
        priority.driver = 500
        priority.session = 500
      }
    }
  }
]
CONF
fi
