# ASUS Zenbook A16 (UX3607OA / glymur) board-specific setup.

modules_load_dir=${OMARCHY_ZENBOOK_MODULES_LOAD_DIR:-/etc/modules-load.d}
mkinitcpio_dir=${OMARCHY_ZENBOOK_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
limine_config_dir=${OMARCHY_ZENBOOK_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
sleep_config_dir=${OMARCHY_ZENBOOK_SLEEP_CONFIG_DIR:-/etc/systemd/sleep.conf.d}

if omarchy-hw-aarch64-qualcomm &&
  { omarchy-hw-match-device-tree asus,zenbook-a16-ux3607oa asus,ux3607oa ||
    omarchy-hw-match 'UX3607OA'; }; then
  echo "Detected ASUS Zenbook A16 UX3607OA, applying board-specific support..."

  # The audited kernel capability allows early DSP setup before USB root.
  # Future shared-kernel releases can retain it without a fixed version pin.
  a16_support_dir=${OMARCHY_ZENBOOK_SUPPORT_DIR:-/usr/share/omarchy-a16}
  a16_kernel=""
  if [[ -r $a16_support_dir/mkinitcpio.conf ]]; then
    a16_doc_root=${OMARCHY_ZENBOOK_KERNEL_DOC_ROOT:-/usr/share/doc}
    a16_modules_root=${OMARCHY_ZENBOOK_KERNEL_MODULES_ROOT:-/usr/lib/modules}
    if omarchy-pkg-present linux-omarchy omarchy-a16-support &&
      [[ -r $a16_doc_root/linux-omarchy/kernel-release ]]; then
      read -r a16_release < "$a16_doc_root/linux-omarchy/kernel-release"
      if [[ -r $a16_modules_root/$a16_release/omarchy-a16-dsp-abi ]]; then
        read -r a16_abi < "$a16_modules_root/$a16_release/omarchy-a16-dsp-abi"
        [[ $a16_abi != 1 ]] || a16_kernel=linux-omarchy
      fi
    fi
  fi
  if [[ -z $a16_kernel ]]; then
    echo "A16 setup requires linux-omarchy with DSP ABI 1 and omarchy-a16-support; refusing unsafe late DSP startup." >&2
    return 1
  fi

  # Keep sleep disabled until this kernel and USB-root setup pass resume tests.
  mkdir -p "$sleep_config_dir"
  cat >"$sleep_config_dir/omarchy-sleep-disabled.conf" <<'CONF'
[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
CONF
  rm -f "$sleep_config_dir/zenbook-a16.conf"

  # The Zenbook A16 exposes its CPU performance domains through SCMI.
  mkdir -p "$modules_load_dir"
  echo "scmi-cpufreq" >"$modules_load_dir/zenbook-a16.conf"

  # Initialize the keyboard, embedded controller, and display before disk unlock.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/zenbook-a16-initramfs.conf" <<'CONF'
# The EC driver is still landing upstream; '?' keeps stock kernels buildable.
MODULES+=(hid-asus asus_glymur_ec? i2c-hid-of qrtr ps883x pmic_glink_altmode)

# The board-signed zap shader is included by qcom-firmware-extract.
for firmware in \
  qcom/gen70500_sqe.fw \
  qcom/gen70500_gmu.bin \
  qcom/gen80100_sqe.fw \
  qcom/gen80100_gmu.bin; do
  for suffix in '' .zst .xz; do
    for directory in "${OMARCHY_ZENBOOK_FIRMWARE_ROOT:-/usr/lib/firmware}/updates" \
      "${OMARCHY_ZENBOOK_FIRMWARE_ROOT:-/usr/lib/firmware}"; do
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
  cat >"$limine_config_dir/zenbook-a16.conf" <<'CONF'
# qualcomm/kernel-params.sh already disables the wait for an absent TPM.
# Plymouth blanked the internal panel during bring-up. Keep the text LUKS prompt
# on tty0 until the target kernel can unlock with the normal graphical splash.
KERNEL_CMDLINE[default]+=" console=tty0 plymouth.enable=0 systemd.show_status=true vt.global_cursor_default=1"
CONF

  source "$OMARCHY_INSTALL/hardware/asus/zenbook-a16-early-dsp.sh" || return 1
  unset a16_kernel a16_release a16_abi a16_doc_root a16_modules_root
fi
