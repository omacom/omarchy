# Raspberry Pi 4 integration

The Pi 4 Model B is `aarch64-raspberrypi`. The proposed integration uses the existing aarch64 USB installer, `linux-omarchy`, UEFI, Limine and unified kernel images. Pi 5 is outside this change.

## Boot prerequisites

The Pi needs separately prepared UEFI firmware media, configured to pass a Pi 4 Device Tree with working VC4/V3D nodes. ACPI-only mode cannot provide the graphics path this desktop needs. The kernel package ships its mainline tree at `/boot/dtbs/linux-omarchy/broadcom/bcm2711-rpi-4-b.dtb`; how the firmware receives and fixes up that tree must be qualified on the board. The installer runs `omarchy-pi-check --live` before disk cleanup and refuses a missing UEFI interface, missing Pi 4 tree or missing V3D render device.

The official ISO is not a native Pi EEPROM-bootable SD image. Neither Omarchy nor `omarchy-pi` flashes the EEPROM or manages the separate firmware media. Keep that media separate from the target disk. A supported firmware release and its exact settings still need to be established before this path is advertised for installation.

## Package and updates

`install/omarchy-aarch64-raspberrypi.packages` adds `omarchy-pi` from the usual Omarchy aarch64 repository. Its recipe lives in `omacom/omarchy-pkgs`, alongside the `linux-omarchy-aarch64` recipe with Pi drivers and the Pi 4 device tree. The ISO carries this package in the live system and in its existing offline platform package set. The target keeps Omarchy's disk layout, encryption, provisioning and snapshot flows.

The package provides:

- `omarchy-pi-check` (also `omarchy hw pi-check`): boot prerequisites, temperature and kernel voltage-alarm diagnostics; `--json` emits the report. An absent voltage sensor is reported as unknown.
- `omarchy-pi-run -- <command>` (also `omarchy cmd pi-run`): opt-in systemd scope and compiler job limits for memory-heavy builds. `--plan` prints the command. The scope may kill a workload that exceeds its memory limit.
- An mkinitcpio drop-in for the Pi's firmware, PCIe and SD host modules.
- Required `setup-system`, `update-prepare` and `update-verify` entrypoints in `/usr/lib/omarchy/pi`, registered through [lifecycle dispatch](lifecycle-dispatch.md).

Setup verifies the installed kernel's drivers and device tree. Update preflight checks the current boot layout before packages change; final verification repeats the check after package hooks finish. Both require a mounted FAT ESP and a Limine menu UKI containing the installed Omarchy kernel. Failure stops the update, and final verification failure suppresses its reboot prompt. A missing Pi package fails rather than taking the compatibility warning used by older Mac installations. The package does not replace the existing kernel rebuild hooks or verify external UEFI firmware updates.

## Scope and validation

The [community port](https://github.com/pkyanam/omarchy-4-pi) uses a different Pi firmware/U-Boot/ext4 image. Its boot report and image tests do not validate this kernel/UEFI/Limine path, and its installations must keep their own updater. This change does not migrate them.

The upstream integration still requires a complete kernel/ISO build and physical boot, install and update/reboot testing. HDMI, audio, Wi-Fi, Bluetooth, power, media decoding, encryption and snapshot recovery must be checked on separate 4GB and 8GB Pi 4 boards. No performance-parity claim is made. User display, font and theme preferences, clocks, and desktop performance defaults are not changed.
