# 2020 27" 5K iMac (iMac20,1 / iMac20,2) with AMD Navi 14.
#
# amdgpu takes over the EFI framebuffer, then SMU init fails
# (`hw_init of IP block <smu> failed -62`). Plymouth and the kms hook then
# hide the LUKS prompt. Keep the EFI simple-framebuffer through unlock.
# See https://github.com/omacom/omarchy/issues/12197

if omarchy-hw-imac20-navi14; then
  echo "Detected 2020 5K iMac with AMD Navi 14; keeping EFI framebuffer through LUKS"

  mkdir -p /etc/limine-entry-tool.d
  cat > /etc/limine-entry-tool.d/imac20-display.conf <<'EOF'
# 2020 27" 5K iMac (iMac20,1 / iMac20,2) with Radeon Pro 5300/5500 (Navi 14).
# amdgpu SMU init fails under KMS and blanks the panel before LUKS.
KERNEL_CMDLINE[default]+=" plymouth.enable=0 nomodeset"
EOF
fi
