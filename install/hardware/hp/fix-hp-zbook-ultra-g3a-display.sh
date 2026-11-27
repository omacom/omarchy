# Display glitches on the HP ZBook Ultra G3a 16 (Ryzen AI Max+ PRO 495).

limine_config_dir=${OMARCHY_ZBOOK_ULTRA_G3A_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}

# The built-in panel flashes horizontal lines as soon as the GPU saturates
# memory bandwidth (local image generation), and now and then at idle. The
# display engine underflows: amdgpu_dm_dtn_log shows the OTG underflow bit set,
# with self-refresh exit programmed at about 30 us, too slow to keep the
# 2880x1800@120 panel fed under that load. Turning off memory stutter (0x2) on
# the DCN 3.5.1 display engine stops it, on 7.2 and on 7.3. Turning off Panel
# Replay (0x400) does not, nor does scanning out of VRAM only
# (amdgpu.sg_display=0), so Replay stays on. Stutter off costs some idle power;
# drop this once amdgpu programs the watermarks so the panel doesn't underflow.
# The 14 inch G3a reports another product name and has not been tested.
if omarchy-hw-x86 && omarchy-hw-match "ZBook Ultra G3a 16"; then
  OMARCHY_BOOT_LIMINE_DROPINS=$limine_config_dir omarchy-boot-cmdline set hp-zbook-ultra-g3a-display amdgpu.dcdebugmask=0x2
fi
