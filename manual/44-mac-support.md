# Mac support

Omarchy has built-in support for **Intel Macs**. There are a couple of known limitations at the moment, but as long as you're aware and OK with those; you can breathe some new life into your old Macs by loading Omarchy.

Please note that installing on an M-series Mac is not directly supported at this time. You can find out more about the state of this in #omarchy-on-other in our [Discord](https://discord.gg/tXFUdasqhY).

In a simple test, we were able to achieve 36% performance gains on a 2019 MacBook Pro just by installing Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installing Omarchy on Mac

Omarchy supports both a full-disk install and a free-space install. A full-disk install erases the selected drive and removes the existing macOS installation. To keep macOS, first create unallocated space and choose **Free space install** in the installer. See [Dual Boot Install](50-dual-boot-install.md) for the general procedure.

Keeping macOS is especially useful on Macs with a T1 or T2 chip. Their firmware and machine-data requirements differ; see the T1 and T2 sections below before partitioning. Internet Recovery provides a recovery path, but is not a substitute for backing up the required files.

#### Prepare macOS for a free-space install

Back up your files before changing partitions. On a T1 Mac, also preserve the Apple EFI partition and verify an external backup of its entire `EFI/APPLE/` directory, including `EFI/APPLE/EMBEDDEDOS/FDRData` and `combined.memboot`. Verify that the copied files match the originals before proceeding. `FDRData` is specific to this Mac and is required for Touch ID through T1Bridge; another Mac's copy cannot replace it. If it has been erased, restoring macOS on this Mac and completing its first boot may recover the data, but restoring macOS can erase Linux. Booting Recovery alone is not enough. See [T1Bridge's backup and recovery requirements](https://github.com/standardagents/t1bridge/blob/main/docs/setup.md).

Create the unallocated space from macOS, not from the Linux installer:

1. Open Terminal and run `diskutil list` and `diskutil apfs list` to identify the macOS APFS container. Do not select the EFI partition or an individual APFS volume.
2. Check the container's resize limits with `diskutil apfs resizeContainer diskXsY limits`, replacing `diskXsY` with the identifier of its APFS physical-store partition from the previous step.
3. Shrink the container, leaving enough space for macOS, its data, and future updates. For example, `sudo diskutil apfs resizeContainer diskXsY 100g` retains a **100 GB macOS container**; it does not allocate 100 GB to Omarchy. Replace both the identifier and size for your disk. If the resize fails, stop and resolve the reported error rather than deleting volumes or forcing a partition change.
4. Run `diskutil list` again and confirm that macOS and its EFI partition remain present and that the intended space is listed as **free space**.
5. Boot the Omarchy USB and choose **Free space install**, not a full-disk wipe. Check the proposed partition changes before confirming; do not format the existing Apple EFI partition.

The Windows disk-preparation section in [Dual Boot Install](50-dual-boot-install.md) does not apply to APFS. Follow that guide's installation section only after creating free space from macOS.

For the sake of this part, we'll assume you've already reviewed [Getting Started](02-getting-started.md) and have your USB drive ready. If you don't go ahead and do that now.

#### Disable Secure Boot

It is necessary to disable Apple's Secure Boot in order to boot the bootable USB, as well as the OS. To disable it, perform the following:

1. Turn off your Mac
2. Turn it on and _immediately_ press and hold Command-R until you see the loading screen appear
3. Select your user and enter your password if prompted
4. Once in the recovery screen, choose **Utilities > Startup Security Utility** from the menubar
5. Enter your password when prompted to authenticate
6. Choose "No Security" from the Secure Boot options
7. Choose "Allow booting from external or removable media" from the External Boot options

#### Start the Installation

1. Insert the USB drive
2. Restart your Mac and _immediately_ press and hold Option until you see a screen of boot devices
3. Select the orange EFI Boot device
4. Proceed with the [install as normal](02-getting-started.md)

The installer detects Mac hardware and applies the needed fixes automatically: Broadcom Wi-Fi drivers and firmware where available, the SPI keyboard driver on the MacBook models that need it, and an NVMe suspend fix for those same models. Hardware-specific support can still require additional firmware, packages, or upstream fixes.

### Known Limitations

Members of the community are constantly working on solutions to these challenges so if these are problematic for you, join #omarchy-on-other in our [Discord](https://discord.gg/tXFUdasqhY) and see if there's any up-to-date methods for resolving these.

#### Devices with T1 Chip

The Apple T1 chip was introduced in late 2016 and used exclusively in the first-generation MacBook Pro models with Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Known Issues

- Touch Bar and audio support require additional community-maintained software.
- [T1Bridge](https://github.com/standardagents/t1bridge) provides a complete T1 stack, including Touch Bar, Touch ID, and the private T1 link.
- [mbp-t1-touchbar](https://github.com/Seborider/mbp-t1-touchbar) provides an alternative Touch Bar stack.

Choose one complete Touch Bar stack. Do not install both projects unchanged: their kernel modules, services, and udev rules can conflict and break Touch Bar operation. Combining `mbp-t1-touchbar` with T1Bridge's Touch ID support requires a deliberately configured hybrid setup; follow the projects' integration instructions rather than installing both full stacks.

These components include kernel modules. Prefer their DKMS packages where available so modules are rebuilt automatically when the kernel is updated. Confirm that all required modules and the boot image for the target kernel build successfully before rebooting.

#### Devices with T2 Chip

The Apple T2 Security Chip was introduced in 2017. The T2 chip was discontinued with the transition to Apple silicon (M-series chips) starting in 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

On these models, the installer automatically sets up the patched `linux-t2` kernel, the T2 audio configuration, Apple's Broadcom Wi-Fi/Bluetooth firmware, and fan control via `t2fanrd`. The Touch Bar runs on the kernel's built-in Boot Camp-style support.

The T2 Wi-Fi firmware fetcher reads firmware from an on-disk macOS volume. A full-disk installation that removed macOS may therefore boot without working Wi-Fi until the firmware is supplied from a macOS installation or a supported recovery image. Preserve macOS or prepare a recovery path before installing on a T2 Mac.
