# Add firmware workarounds required by current Snapdragon laptops.

if omarchy-hw-aarch64-qualcomm; then
  # Keep display and I/O resources enabled until their drivers load.
  # Disable pointer authentication and waiting for an unavailable TPM.
  # Translate device memory access (iommu.passthrough=0), as Arch Linux ARM's
  # kernel does by default. On a kernel that defaults to passthrough, the
  # Yoga Slim 7x's keyboard, touchpad and touchscreen read back empty
  # descriptors and never appear.
  omarchy-boot-cmdline set qualcomm-snapdragon \
    clk_ignore_unused pd_ignore_unused arm64.nopauth systemd.tpm2_wait=0 iommu.passthrough=0
fi
