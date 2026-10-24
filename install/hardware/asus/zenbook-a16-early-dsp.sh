# Sourced by model-gated A16 setup after checking the audited kernel capability.
# Configure the next boot; never touch a running remote processor here.

# Follow package-owned configuration so support updates take effect during the
# pacman initramfs rebuild without requiring another hardware-setup pass.
# Relative links also resolve when the live installer reads the target via /mnt.
ln -srfn "$a16_support_dir/mkinitcpio.conf" "$mkinitcpio_dir/zz-zenbook-a16-dsp.conf"
a16_modprobe_dir=${OMARCHY_QUALCOMM_MODPROBE_DIR:-/etc/modprobe.d}
mkdir -p "$a16_modprobe_dir"
ln -srfn "$a16_support_dir/remoteproc-blacklist.conf" \
  "$a16_modprobe_dir/qualcomm-adsp-nofw.conf"

# Other Snapdragon boards must not inherit the A16 audio power workaround.
a16_wireplumber_dir=${OMARCHY_ZENBOOK_WIREPLUMBER_DIR:-/etc/wireplumber/wireplumber.conf.d}
mkdir -p "$a16_wireplumber_dir"
ln -srfn "$a16_support_dir/51-glymur-ucm.conf" "$a16_wireplumber_dir/51-omarchy-a16-keep-awake.conf"

# Disable the old late-start service, including on an upgrade from RC5.
# Its guard file remains present so an already queued invocation also skips.
systemctl disable zenbook-a16-remoteprocs.service 2>/dev/null || true

# Refresh before every boot-image build so reset/provisioning changes are inherited.
a16_boot_hooks_dir=${OMARCHY_ZENBOOK_BOOT_HOOKS_DIR:-/etc/boot/hooks/pre.d}
mkdir -p "$a16_boot_hooks_dir"
{
  echo '#!/bin/bash'
  printf 'limine_config_dir=%q\n' "$limine_config_dir"
  printf 'a16_kernel=%q\n' "$a16_kernel"
  cat <<'HOOK'
set -euo pipefail

a16_root_cmdline=$(limine-entry-tool --get-cmdline default) || exit 100
if [[ $a16_root_cmdline != *root=* ]]; then
  echo "A16 boot setup requires a shared root command line" >&2
  exit 100
fi

# These retain the tested Fedora bring-up restrictions. Efficient audio PM and
# camera use remain separate acceptance work; the support package retains the
# WirePlumber keep-awake workaround and the kernel retains both SoundWire votes.
# Plymouth blanked the internal panel; keep text unlock on tty0 until validated.
a16_common_params="clk_ignore_unused pd_ignore_unused arm64.nopauth iommu.passthrough=0 glymur_pci_skip=5 console=tty0 systemd.tpm2_wait=0 plymouth.enable=0 initramfs_async=0"
a16_rescue_cmdline="$a16_root_cmdline $a16_common_params omarchy.a16.dsp=off module_blacklist=qcom_q6v5_pas,i2c_qcom_cci,qcom_camss,ov02c10 modprobe.blacklist=qcom_q6v5_pas,i2c_qcom_cci,qcom_camss,ov02c10 systemd.unit=multi-user.target loglevel=7 systemd.show_status=true vt.global_cursor_default=1"
a16_boot_config=$(mktemp "$limine_config_dir/.zz-zenbook-a16-boot.XXXXXX") || exit 100
trap 'rm -f "$a16_boot_config"' EXIT
{
  echo '# A16 audited kernel with a DSP-disabled USB-root rescue entry.'
  printf 'BOOT_ORDER="%s, %s-fallback, *, Snapshots"\n' "$a16_kernel" "$a16_kernel"
  printf 'MKINITCPIO_FALLBACK=%s\n' "$a16_kernel"
  echo 'EXCLUDE_SNAPSHOT_ENTRIES="Windows*, windows*, *fallback"'
  echo '# The device tree supplies the board CMA reservation; do not override it.'
  # Per-kernel lines replace the default; refresh them from its current value.
  printf 'KERNEL_CMDLINE[%s]="%s"\n' "$a16_kernel" "$a16_root_cmdline $a16_common_params module_blacklist=i2c_qcom_cci,qcom_camss,ov02c10 systemd.show_status=true vt.global_cursor_default=1"
  printf 'KERNEL_CMDLINE[fallback]="%s"\n' "$a16_rescue_cmdline"
} > "$a16_boot_config" || exit 100
chmod 644 "$a16_boot_config" &&
  mv "$a16_boot_config" "$limine_config_dir/zz-zenbook-a16-boot.conf" || exit 100
HOOK
} > "$a16_boot_hooks_dir/20-zenbook-a16-cmdline" || return 1
chmod 755 "$a16_boot_hooks_dir/20-zenbook-a16-cmdline" || return 1
bash "$a16_boot_hooks_dir/20-zenbook-a16-cmdline" || return 1

if [[ -n ${OMARCHY_IMAGE_BOOT_REBUILD:-} ]]; then
  : > "$OMARCHY_IMAGE_BOOT_REBUILD"
fi
unset a16_root_cmdline a16_modprobe_dir a16_wireplumber_dir a16_boot_hooks_dir
