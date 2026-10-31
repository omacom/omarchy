# GB10 hardware support

The `aarch64-gb10` platform covers aarch64 desktops with NVIDIA GPU PCI ID `10de:2e12`: the DGX Spark, the ASUS Ascent GX10 and the Dell Pro Max with GB10. `omarchy-hw-aarch64-gb10` detects it. It keeps the N1x laptop policy separate: no laptop memory-reclaim ranges, USB4 boot arguments, or integrated-audio assumptions are applied to GB10.

## Installation and upgrades

`install/omarchy-aarch64-gb10.packages` adds `rdma-core`, `fwupd` and `ethtool` to the default set, so the ISO caches them for offline installation. Existing installations receive them through migration `1793239437.sh`. RDMA module loading uses the upstream package's udev rules and `rdma-load-modules@rdma.service`; there is no separate Omarchy module policy or hard-coded fabric addressing.

System sleep is off, as on DGX OS (`install/hardware/gb10/sleep.sh`). The DGX Spark boots without a UKI to skip a 20-second firmware delay (`install/hardware/nvidia/dgx-spark-boot.sh`).

Firmware installation is deliberately separate from OS installation. Run `sudo fwupdmgr refresh` and `fwupdmgr get-updates`, check that the device GUID, vendor and model match the machine, then follow the vendor's update procedure with stable power and local boot recovery available. A Founders Edition release table does not describe every OEM system. [Dell's FCM1253 firmware procedure](https://www.dell.com/support/kbdoc/en-us/000379162/how-to-upgrade-the-bios-and-the-firmware-on-a-dell-pro-max-with-the-grace-blackwell-system) covers BIOS, EC, PD and TPM; do not force-install an unmatched capsule.

## Kernel coverage

GB10 runs `linux-omarchy` for aarch64 (omarchy-pkgs `pkgbuilds/linux-omarchy-aarch64`). From `7.3-6` it carries `1041`, the SMMUv3 PRI missing-interrupt backport: it disables PRI when a queue cannot be serviced and preserves the integrated GPU's DMA-domain quirk. The upstream RTL8127 PLL suspend/shutdown fix has been in the kernel since 7.2.5. Neither change establishes suspend or cold-boot qualification by itself.

Hierarchical ACPI idle remains deferred in the shared kernel; flat LPI states are available. NVIDIA's legacy suspend services are not required when the loaded open driver reports `UseKernelSuspendNotifiers: 1`. Hibernation is not enabled by this kernel. Do not enable unsupported sleep modes or mask errors solely to obtain clean logs.

## Qualification checklist

| Area | Check | Evidence required |
| --- | --- | --- |
| Firmware | `fwupdmgr get-devices`, `get-updates`, and post-reboot `get-history` | Exact OEM GUID and version, successful update result, boot and peripheral checks |
| RDMA | `ibv_devices`, `ibv_devinfo`, `rdma link` | All expected verbs devices open; separate peer-to-peer data validation using known cable/topology |
| Wi-Fi | `ethtool -i wlan0`, `iw dev wlan0 link`, interface-bound gateway ping and throughput | Firmware timestamp, same BSSID/band/channel/signal, loss and latency at strong and weak signal |
| Bluetooth | Pair/reconnect, A2DP playback, switch to HFP and record microphone | Actual audible playback and intelligible recording; controller enumeration is insufficient |
| Display | HDMI and USB-C DP Alt Mode, hotplug, short and prolonged DPMS sleep | Picture returns, compositor remains responsive, HDMI audio returns, no GPU errors |
| USB-C | Each advertised port with an appropriate device | USB data at supported device speed, DP Alt Mode and USB audio where connected |
| Power | Suspend/resume, warm reboot and cold start with recovery available | Network, graphics, input, audio and inference recover; idle power measured separately |

The Dell Pro Max with GB10 advertises USB 3.2 Gen 2x2 with DP Alt Mode, not the N1x laptop's USB4 topology. A disabled SSPM ACPI device can explain shared laptop DSP/USB4 probe failures without implying that advertised USB data or external audio is unavailable. Test those paths rather than force-binding disabled hardware.

## Issues requiring controlled follow-up

The MT7925 firmware build `20260813113118` matches [an upstream weak-signal 5 GHz regression report](https://github.com/openwrt/mt76/issues/1128), but the report uses a different PCI variant. Reproduce on the target before changing defaults. A firmware A/B must preserve the driver, BSSID, channel, power-save setting and radio position, verify each blob's hash, and retain wired recovery. Do not roll back the entire MediaTek firmware package or Bluetooth firmware to test two Wi-Fi blobs.

ConnectX idle-power management requires NVIDIA's platform hotplug driver and a coordinated userspace handler, not just `rdma-core`. omarchy-pkgs packages the driver as `gb10-cx7-hotplug-dkms`: opt-in, blacklisted, and inert unless loaded with `experimental=1`. Nothing installs it by default. Removing powered PCI functions while they are in use can disrupt inference or networking. Do not import the stock handler without checking complete device removal, IRQ context, current driver dependencies and cable-reinsert recovery. Active verbs support and physical link speed do not prove this power-management path.

The PCI slot-power warning, virtual GPU PCI link width, and CPU energy-model warnings are not sufficient evidence of inference throttling. Measure the workload and physical device counters before applying performance settings. USB installer GPT warnings must not be treated as a reason to rewrite the installed NVMe partition table.
