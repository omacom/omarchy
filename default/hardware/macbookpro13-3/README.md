# MacBookPro13,3 recovery payload

This directory adapts the model-specific work from [aldervale/omarchy-macbookpro13-3 at ff11b52](https://github.com/aldervale/omarchy-macbookpro13-3/tree/ff11b52). Files in this directory are **GPL-2.0-only**, including the kernel module; see [LICENSE](LICENSE). They are separately licensed from Omarchy's MIT code. Upstream review must account for this boundary.

The EC module, DKMS configuration, sleep policy and Python HID implementation are copied unchanged. The Makefile only drops a trailing blank line. Shell shebangs use Omarchy's `/bin/bash` convention. The resume wrapper points at the new root-owned runtime directory. `install.sh` replaces the two separate source installers with one fresh-install transaction and a combined ordered `suspend.conf`; it also owns the sleep policy for removal. It never starts suspend or loads the EC module during installation.

The SPI keyboard quirk lives in `default/libinput/` and is installed through normal hardware setup and a migration. This experimental payload is only installed through `omarchy setup macbookpro13-3 install`. Wi-Fi, audio, NVMe and attended T1 recovery are covered in the [user guide](../../../manual/44a-macbookpro13-3.md); the NVMe helper is included here for explicit application after inspection.

The successful lid tests establish the underlying sequence on one machine, not the new combined installer or every possible device configuration. See [the recorded validation](https://github.com/aldervale/omarchy-macbookpro13-3/blob/ff11b52/docs/validation.md). Hardware behavior after long sleep, battery retention, connected peripherals and different software versions remains unvalidated. No private logs, ACPI tables, firmware, calibration data or host MAC addresses are included.
