# Unlock 120/144/240/360Hz on the Razer Blade 15 Advanced (Mid 2021) FHD panel.
#
# The TMX TL156VDXP02 panel's factory EDID has two defects that leave Linux at
# 60Hz only, while Windows ignores them:
#   - the DisplayID extension, the only place the 360Hz timing is listed, has a
#     bad checksum (0x97, should be 0x83), so DRM drops the whole block;
#   - the 48-360Hz range descriptor is flagged "GTF default" instead of "range
#     limits only", so DRM reports no refresh range and i915 treats the eDP
#     panel as fixed-mode, allowing just its preferred timing.
#
# The corrected EDID fixes both and adds 120/144/240Hz on the panel's own
# 2000x1111 totals (the vendor's 60 and 360Hz modes differ only in pixel
# clock). 60Hz stays preferred, so boot and the console come up as before. It
# is loaded for eDP-1 only and packed into the initramfs because the kms hook
# loads i915 there.

firmware_dir=${OMARCHY_RAZER_BLADE15_FIRMWARE_DIR:-/usr/lib/firmware}
mkinitcpio_dir=${OMARCHY_RAZER_BLADE15_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
limine_config_dir=${OMARCHY_RAZER_BLADE15_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}

if omarchy-hw-razer-blade15-360hz; then
  edid=razer-blade15-tl156vdxp02.bin
  install -Dm644 "$OMARCHY_PATH/default/firmware/edid/$edid" "$firmware_dir/edid/$edid"

  # The initramfs path is the installed one, not the override's.
  mkdir -p "$mkinitcpio_dir" "$limine_config_dir"
  cat >"$mkinitcpio_dir/razer-blade15-edid.conf" <<EOF
# Razer Blade 15 (Mid 2021) corrected panel EDID, needed before i915 probes eDP
FILES+=(/usr/lib/firmware/edid/$edid)
EOF
  cat >"$limine_config_dir/razer-blade15-edid.conf" <<EOF
# Razer Blade 15 (Mid 2021) corrected panel EDID (unlocks 120-360Hz)
KERNEL_CMDLINE[default]+=" drm.edid_firmware=eDP-1:edid/$edid"
EOF
fi
