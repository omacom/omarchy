# Keep the Micron 2400 NVMe SSD out of its APST power states.
#
# The controller (PCI 1344:5413, seen in the ASUS Zenbook UM5302LA) enters a
# deep autonomous power state and never comes back: writes time out, the
# kernel resets the controller, then aborts the outstanding I/O and the root
# filesystem goes read-only within minutes of boot. Setting
# nvme_core.default_ps_max_latency_us=0 keeps the drive in its active state,
# which is the documented workaround for APST-broken NVMe firmware.

if omarchy-hw-micron-2400-nvme; then
  dropin_dir="${OMARCHY_LIMINE_DROPIN_DIR:-/etc/limine-entry-tool.d}"

  sudo mkdir -p "$dropin_dir"
  sudo tee "$dropin_dir/micron-2400-apst.conf" >/dev/null <<'EOF'
# Micron 2400 NVMe APST hang workaround
KERNEL_CMDLINE[default]+=" nvme_core.default_ps_max_latency_us=0"
EOF
fi
