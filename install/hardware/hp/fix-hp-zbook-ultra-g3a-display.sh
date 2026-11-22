# Display glitches on the HP ZBook Ultra G3a 16 (Ryzen AI Max+ PRO 495).

limine_config_dir=${OMARCHY_ZBOOK_ULTRA_G3A_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}

# The built-in panel flashes horizontal lines, most often while the GPU is
# under heavy memory load (local image generation) but at idle too. Screenshots
# taken during a glitch are clean, so the frames are right and the fault is
# between the display engine and the panel. Turning off Panel Replay (0x400)
# on the DCN 3.5.1 display engine is meant to stop it; scanning out of VRAM
# only (amdgpu.sg_display=0) did not. Memory stutter (0x2) stays on: with it
# off too (0x402), the first resume after a long sleep found the SMU not
# answering, and the GPU, Thunderbolt and HDMI audio never came back. Drop
# this once amdgpu or the panel firmware fixes Panel Replay on this panel.
# The 14 inch G3a reports another product name and has not been tested.
if omarchy-hw-x86 && omarchy-hw-match "ZBook Ultra G3a 16"; then
  mkdir -p "$limine_config_dir"
  cat >"$limine_config_dir/hp-zbook-ultra-g3a-display.conf" <<'CONF'
KERNEL_CMDLINE[default]+=" amdgpu.dcdebugmask=0x400"
CONF
fi
