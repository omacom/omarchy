# Sourced by model-gated A16 setup after checking the audited kernel capability.
# Configure the next boot; never touch a running remote processor here.

a16_cmdline_file=${OMARCHY_ZENBOOK_CMDLINE_FILE:-/etc/kernel/cmdline}
a16_root_cmdline=$(cat "$a16_cmdline_file" 2>/dev/null || true)
if [[ $a16_root_cmdline != *root=* ]]; then
  echo "A16 setup requires the installer's root command line in $a16_cmdline_file" >&2
  return 1
fi

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

# These retain the tested Fedora bring-up restrictions. Efficient audio PM and
# camera use remain separate acceptance work; the support package retains the
# WirePlumber keep-awake workaround and the kernel retains both SoundWire votes.
a16_common_params="clk_ignore_unused pd_ignore_unused arm64.nopauth iommu.passthrough=0 glymur_pci_skip=5 console=tty0 systemd.tpm2_wait=0 plymouth.enable=0 initramfs_async=0"
a16_rescue_cmdline="$a16_root_cmdline $a16_common_params omarchy.a16.dsp=off module_blacklist=qcom_q6v5_pas,i2c_qcom_cci,qcom_camss,ov02c10 modprobe.blacklist=qcom_q6v5_pas,i2c_qcom_cci,qcom_camss,ov02c10 systemd.unit=multi-user.target loglevel=7 systemd.show_status=true vt.global_cursor_default=1"
{
  echo '# A16 audited kernel with a DSP-disabled USB-root rescue entry.'
  printf 'BOOT_ORDER="%s, %s-fallback, *, Snapshots"\n' "$a16_kernel" "$a16_kernel"
  printf 'MKINITCPIO_FALLBACK=%s\n' "$a16_kernel"
  echo 'EXCLUDE_SNAPSHOT_ENTRIES="Windows*, windows*, *fallback"'
  echo '# The device tree supplies the board CMA reservation; do not override it.'
  # Limine's per-kernel command line replaces the default; include root and
  # family parameters explicitly rather than appending to an empty entry.
  printf 'KERNEL_CMDLINE[%s]="%s"\n' "$a16_kernel" "$a16_root_cmdline $a16_common_params module_blacklist=i2c_qcom_cci,qcom_camss,ov02c10 systemd.show_status=true vt.global_cursor_default=1"
  printf 'KERNEL_CMDLINE[fallback]="%s"\n' "$a16_rescue_cmdline"
} > "$limine_config_dir/zz-zenbook-a16-boot.conf"

if [[ -n ${OMARCHY_IMAGE_BOOT_REBUILD:-} ]]; then
  : > "$OMARCHY_IMAGE_BOOT_REBUILD"
fi
unset a16_root_cmdline a16_common_params a16_rescue_cmdline a16_modprobe_dir a16_cmdline_file a16_wireplumber_dir
