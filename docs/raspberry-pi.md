# Raspberry Pi 4 integration

The Pi 4 Model B is `aarch64-raspberrypi`. This draft integration uses the existing aarch64 USB installer, `linux-omarchy`, UEFI, Limine and unified kernel images. Pi 5 is outside this change. Platform detection matches the board family rather than its RAM size; physical validation so far covers a 4GB board only.

## Boot prerequisites

The Pi needs separately prepared UEFI firmware media configured to pass a Pi 4 Device Tree with working VC4/V3D nodes. ACPI-only mode cannot provide the graphics path this desktop needs. The kernel package ships its mainline tree at `/boot/dtbs/linux-omarchy/broadcom/bcm2711-rpi-4-b.dtb`; the firmware must receive and fix up a compatible tree. The installer companion runs `omarchy-pi-check --live` before disk cleanup and refuses a missing UEFI interface, missing Pi 4 tree or missing V3D render device.

The privately tested firmware path is PFTF 1.53 in Device Tree mode with its 3GB RAM limit disabled and the required mainline-DMA overlay. Bluetooth additionally needs the AUX automatic RTS/CTS driver change paired with `uart-has-rtscts` on the AUX UART node. The tested private kernel/firmware combination establishes this pairing; it does not establish normal-channel delivery or a public firmware-management policy.

The official ISO is not a native Pi EEPROM-bootable SD image. Neither Omarchy nor `raspberrypi-4-support` flashes the EEPROM or manages the separate firmware media. Keep that media separate from the target disk. Back up the matching firmware media, ESP, UKI, kernel modules and package set before boot changes. A root snapshot alone cannot restore all those components.

## Packages and updates

`install/omarchy-aarch64-raspberrypi.packages` selects `raspberrypi-4-desktop`. The companion recipe produces this desktop package and `raspberrypi-4-support`: desktop requires matching support plus the compatible Omarchy runtime capability, while support requires the Pi-capable kernel capability. The installer live environment uses support without the desktop runtime dependency. These companion changes belong in `omacom/omarchy-pkgs` and the installer integration belongs in `omacom/omarchy-iso`; their normal-channel publication is pending. This source PR alone does not make a stock ISO Pi-ready.

The support package provides:

- `omarchy-pi-check` (also `omarchy hw pi-check`): boot prerequisites, temperature and kernel voltage-alarm diagnostics; `--json` emits the report. An absent voltage sensor is reported as unknown.
- `omarchy-pi-run -- <command>` (also `omarchy cmd pi-run`): opt-in systemd scope and compiler job limits for memory-heavy builds. `--plan` prints the command. The scope may kill a workload that exceeds its memory limit.
- An mkinitcpio drop-in for the Pi's firmware, PCIe and SD host modules.
- Required `setup-system`, `update-prepare` and `update-verify` entrypoints in `/usr/lib/omarchy/pi`, registered through [lifecycle dispatch](lifecycle-dispatch.md).

Setup verifies the installed kernel's drivers and device tree. Update preflight checks the current boot layout before packages change; final verification repeats the check after package hooks finish. Both require a mounted FAT ESP and a Limine menu UKI containing the installed Omarchy kernel. Failure stops the update, and final verification failure suppresses its reboot prompt. A missing Pi package fails rather than taking the compatibility warning used by older Mac installations. The package does not replace the existing kernel rebuild hooks or verify external UEFI firmware updates.

## Validation and remaining work

Private 4GB Pi 4 testing has demonstrated encrypted USB-root boot, VC4/V3D rendering, Bluetooth initialization, a working Jabra headset and one disconnect/reconnect, plus a same-version root snapshot restoration. The tested private kernel/header package is `7.3-32.11`, retaining kernel release `7.3.0-32.1-omarchy`, with a private paired firmware companion. This is not a complete normal-recipe kernel build or normal-channel installation.

The ASUS VG248 displays a sharp 1920×1080 at 60 Hz and 1× when supplied its genuine EDID temporarily. Normal DDC discovery still returns no EDID on both ports with the tested adapter/cable. The override was removed after the diagnostic; no per-monitor timing or EDID database is part of this integration. Automatic discovery, 4K and broader monitor qualification remain open. Intermittent resets, Wi-Fi warnings, a VC4 warning and final UI/capture acceptance also require qualification.

Before stable support, complete the matching normal kernel/package/installer builds, a fresh encrypted installation, ordinary update and warm/cold boot checks, and coherent cross-version recovery of the root, modules, UKI, ESP and external firmware. Test an 8GB Pi 4 separately before claiming that hardware qualified. Preserve full desktop functionality; experimental H264 ports, compiler tuning and GPU compute workloads are separate work and are not shipped by this PR. No performance parity with Raspberry Pi OS is claimed. Display, font and theme preferences, clocks, and desktop performance defaults are unchanged by this source integration.

The [community port](https://github.com/pkyanam/omarchy-4-pi) uses a different Pi firmware/U-Boot/ext4 image. Its results do not validate this kernel/UEFI/Limine path, and its installations must keep their own updater. This change does not migrate them.
