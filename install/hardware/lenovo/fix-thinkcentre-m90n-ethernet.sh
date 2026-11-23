# Onboard Intel I219-V Ethernet on the Lenovo ThinkCentre M90n-1 (board 314D).

limine_config_dir=${OMARCHY_THINKCENTRE_M90N_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}

# PCIe ASPM / L1 substates leave the I219-V (8086:15be, subsystem 17aa:314d) PHY
# latched in Ultra Low Power mode at boot, so e1000e fails to probe with
# "Failed to disable ULP" / error -2 and "Hardware Error" / NO-CARRIER (kernel
# bug 213481). Disabling PCIe ASPM globally fixes link bring-up.
#
# Scoped to the AC-powered ThinkCentre M90n-1 with 8086:15be so laptops sharing
# the same PCI ID do not lose ASPM power savings or S0ix sleep.
if omarchy-hw-x86 && omarchy-hw-match "ThinkCentre M90n-1" && omarchy-hw-pci --class 0200 8086:15be; then
  mkdir -p "$limine_config_dir"
  cat >"$limine_config_dir/lenovo-thinkcentre-m90n-ethernet.conf" <<'CONF'
# Intel I219-V (8086:15be) ULP probe failure workaround (kernel bug 213481)
KERNEL_CMDLINE[default]+=" pcie_aspm=off"
CONF
fi
