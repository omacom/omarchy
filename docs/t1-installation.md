# T1 installation

T1 hardware setup installs the driver, fingerprint package pair, kernel headers, desktop provider, and first-boot importer. Users enable fingerprint authentication through the existing wizard. Custom fingerprint menus, lock-screen changes, and legacy PAM migration are separate work.

A drop-in names the private T1 interface `t1bridge0`; the xART firewall rule permits only its peer on that interface.

## Before merging

The ISO installs offline. Its configured repositories must supply all four T1Bridge packages in `install/omarchy-other.packages`. They currently exist in the [Standard Agents repository](https://github.com/standardagents/t1bridge#install-official-packages), but not Omarchy stable. Admit the four recipes to the selected Omarchy channel before building the ISO; the package list alone cannot make the build succeed.

Known competing packages, DKMS registrations, services, and udev rules stop setup before changes. T1 fingerprint setup also refuses competing packages. Masked services and backup files are allowed. Custom stacks need manual review and retirement, then a reboot; preserve password authentication.

## Verify

Run `./test/cli` for command metadata and `./test/shell` for hardware detection, package selection, conflict refusal, import/retry behavior, and desktop controls.

Before shipping, verify a fresh ISO install, DKMS compilation, device activation, and automatic import on preserved multi-ESP layouts. Upstream still documents an automatic-discovery failure there. Mock tests and successful explicit backup import do not establish first-boot success.
