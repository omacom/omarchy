# Waking from sleep on the HP ZBook Ultra G3a 16 (Ryzen AI Max+ PRO 495).

limine_config_dir=${OMARCHY_ZBOOK_ULTRA_G3A_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}

# Every resume freezes the machine for about 80 seconds, and a long sleep
# often never comes back. Powering the SSD back on runs HP's Opal drive-unlock
# SMI (BIOS Y86 01.01.07, the latest as of November 2026). The SMI handler
# has the SSD DMA into a buffer in ACPI NVS that the IOMMU doesn't map, so
# the command never completes and every core waits in SMM until the handler
# times out. The kernel logs it as an nvme IO_PAGE_FAULT at 0x49319000 on
# each resume. With the IOMMU in passthrough the buffer is reachable and
# resume takes under a second. Thunderbolt and other external devices are
# still translated. Reported to AMD and HP; drop this once a BIOS fixes it.
# The 14 inch G3a reports another product name and has not been tested.
if omarchy-hw-x86 && omarchy-hw-match "ZBook Ultra G3a 16"; then
  OMARCHY_BOOT_LIMINE_DROPINS=$limine_config_dir omarchy-boot-cmdline set hp-zbook-ultra-g3a iommu.passthrough=1
fi
