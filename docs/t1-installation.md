# T1 installation

T1 setup installs the driver, matched fingerprint packages, kernel headers, desktop provider, and first-boot importer. The shared fingerprint manager supports Touch ID; authentication setup verifies enrollment before enabling sign-in.

The private interface is `t1bridge0`. Its xART firewall rule permits only the T1 peer. Known competing packages, DKMS registrations, services, and udev rules stop setup before changes. Retire custom stacks manually and reboot; preserve password access.

## Package admission

Offline installation requires the four T1Bridge packages in `install/omarchy-other.packages` and the general `fingerprint-tui` package in the selected Omarchy channel. Merge package admission before building the ISO.

## Verification

Run `./test/cli` for command metadata and `./test/shell` for hardware detection, package selection, conflict refusal, import/retry behavior, and desktop controls.

Fresh VM checks cover installation, encrypted boot, DKMS overrides, multi-ESP discovery, and preservation of original Apple files using stock systemd. Synthetic readers cover fingerprint operations. Physical T1 activation, calibration import, and sensor acceptance remain to be verified.
