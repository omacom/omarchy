# MacBookPro14,1 suspend and USB-C validation

This report records independent hardware evidence for [the proposed MacBookPro14,1 suspend fix](https://github.com/omacom/omarchy/pull/10758) and [its DKMS package](https://github.com/omacom/omarchy-pkgs/pull/349). Both proposals were open and unmerged when checked on November 8, 2026. The tested package was built locally from the proposal, rather than installed from an official Omarchy repository release.

## Test environment

- Hardware: 2017 13-inch MacBook Pro with two Thunderbolt 3 ports, DMI `MacBookPro14,1`.
- Firmware: Apple BIOS `529.140.2.0.0`, dated June 23, 2024.
- System: Omarchy 4.5.0-3, systemd 262.1, `linux-omarchy` 7.2.15-1.
- Peripherals: USB-C hub with VIA VL817 and Realtek RTL8153 Gigabit Ethernet; the hub remained attached throughout the tests.
- Module: unchanged `tb_ar_shim` 1.0.0, packaged as `tb-ar-shim-dkms` 1.0.0-1 from package PR #349 at `f6aa10a69ab7b06ccf92b87f6b99200ebcfb68ae`.
- Source: [module repository](https://github.com/orospakr/linux-apple-alpine-ridge-suspend), tag `v1.0.0`; the archive passed the recipe's SHA-256 check (`30ceacceabe854904ef4d555e225e9901c17fd7b524f075c4a17de8e7b2a8b9c`).

DKMS built the package for both installed kernels, `7.2.15-1-omarchy` and `7.2.11-arch1-1`. Runtime testing covered the Omarchy kernel only. This validates the module and package on this machine; the companion PR's installer and migration were not exercised unchanged.

## Failure and comparison

After deep/S3 sleep, the Alpine Ridge USB controller (`8086:15d4`) disappeared and root port `0000:00:1c.4` became inaccessible in D3cold. The RTL8153 still reported a 1 Gbps Ethernet cable link but fell back to USB 2 at `480M`. A wired download measured 34.3 MB/s, approximately 275 Mbps. Complete shutdown and power-on restored the controller, USB `5000M` and a speed test over 900 Mbps.

An intermediate local workaround used s2idle, unloaded the Thunderbolt driver, removed the USB controller before suspend and rescanned after wake. Device resume took approximately 5.5 seconds, including 5.189 seconds in bridge `0000:04:00.0`. Disabling D3cold on the Thunderbolt PCI subtree reduced that measured delay.

The module comparison retained s2idle, loaded both `tb_ar_shim` and the normal `thunderbolt` driver, and replaced the earlier sleep hook with camera/display handling only. The final comparison had no Thunderbolt blacklist, controller removal, bridge rescan or D3cold override. Modules were explicitly configured to load at boot. The systemd suspend policy was `MemorySleepMode=s2idle`, rather than the companion PR's kernel command-line setup.

| Configuration | Device-resume time | Ethernet USB connection after wake |
| --- | --- | --- |
| Earlier local hook + s2idle + Thunderbolt D3cold guard | 0.5393 s | `5000M` |
| Module + normal Thunderbolt driver + s2idle, guard retained | 0.5456 s | `5000M` |
| Module + normal Thunderbolt driver + s2idle, D3cold allowed | 0.5369 s | `5000M` |
| Same module setup, first suspend after cold power-on | 0.5322 s | `5000M` |

An isolated kernel trace measured from `machine_suspend` end to `thaw_processes` end. These timings exclude time asleep, unlocking and Ethernet link/DHCP reconnection. They show comparable wake times for the successful workaround and module; they do not show a timing advantage for the module.

All three module cycles used automatic RTC wake. Each logged configuration saved for seven devices, without a spent restore budget or the earlier inaccessible-controller/resume-timeout messages. The USB controller and hub remained present. After the cold power-on, both modules autoloaded and the test started with zero completed suspends in that boot. All Thunderbolt-subtree `d3cold_allowed` attributes were `1`. The user confirmed quick screen wake.

After that first post-boot resume, a bounded `omarchy network speedtest down` run over the verified Ethernet default route reported roughly 925–934 Mbps after warm-up, peaking at 934 Mbps. The cable link was 1 Gbps full duplex.

The module's observed benefit was retaining the normal Thunderbolt driver and USB controller without the older hook, blacklist or D3cold guard. These results are separate from the module author's reported 28 successful cycles.

## Lid-open wake: EC interrupt not registered for wake

The RTC-triggered tests above did not validate the lid as a wake source. Physical tests repeatedly left the machine suspended after opening until a keypress. Session recordings began only after that keypress, with the display and backlight already enabled. Kernel traces placed the lid notification after the end of `machine_suspend`, so a queued lid-open event in the journal was not evidence that the lid woke the machine. Keyboard backlighting could react to opening while the screen remained dark.

Enabling the EC platform device's `power/wakeup` flag was followed by one successful test, but failed again after reboot while still enabled. Restoring the Thunderbolt D3cold guard also failed. Restoring the complete old hook, removing the Alpine Ridge shim, reverting the EC flag, and then cold-booting after a user-reported SMC reset did not solve it. These comparisons do not support attributing the failure specifically to the Alpine Ridge shim. The experimental EC udev rule was removed.

The firmware table gives the lid `_PRW` GPE `0x6F`, while the EC runtime interrupt uses GPE `0x07`. An earlier targeted trace showed `_PSW(1)` reaching the EC write handler with offset `0x68`, value `0x01` (the lid-open wake bit); the kernel had requested firmware wake enablement. GPE `0x6F` nevertheless remained at zero across the failed physical tests.

A subsequent timed-suspend trace isolated a separate failure: `acpi_ec_set_gpe_wake_mask(ACPI_GPE_ENABLE)` called `acpi_set_gpe_wake_mask(NULL, 7, ACPI_GPE_ENABLE)` and received `0x8`, `AE_TYPE`, while other wake GPEs returned `AE_OK`. `acpi.ec_no_wakeup` was already `N`. In [ACPICA's implementation](https://github.com/torvalds/linux/blob/master/drivers/acpi/acpica/evxfgpe.c), this error means the GPE is missing `ACPI_GPE_CAN_WAKE`. The [x86 LPS0 attachment path](https://github.com/torvalds/linux/blob/master/drivers/acpi/x86/s2idle.c) calls `acpi_ec_mark_gpe_for_wake()`; this Mac has no `PNP0D80` device. The trace establishes the missing wake capability on the running kernel; it does not establish a regression's introduction version.

A small local helper restricted to Apple Inc. `MacBookPro14,1` calls the exported `acpi_ec_mark_gpe_for_wake()` API. It uses the kernel's first EC rather than hard-coding GPE `0x07`, and changes no Thunderbolt state. With that helper loaded, a second timed suspend returned `AE_OK` for EC wake-mask enable and disable, slept until the RTC alarm, and resumed devices in approximately 0.54 seconds. The following physical lid test woke the screen without a keypress, as confirmed by the user. Ethernet remained on USB `5000M`.

The successful physical test used the restored old Thunderbolt hook, s2idle and D3cold guard, with the EC platform wake flag disabled. The EC helper has not yet been physically tested together with the Alpine Ridge shim. It is separate from the unchanged upstream module/package discussed above. The local helper was packaged as `macbook-ec-wake-dkms` 0.1-1; DKMS builds succeeded for both installed kernels. It loaded automatically after a subsequent reboot, before the first suspend. The user completed two further physical lid cycles; the journal records both returning from s2idle, the suspend counters report two successes and zero failures, and USB Ethernet remains at `5000M`. This is not an official Omarchy package. Longer-term reliability and overnight battery behavior remain untested. Unloading the helper does not undo the capability mark; removing its boot loading and rebooting does, since ACPICA exposes no public inverse for marking a GPE wake-capable.

## Interpretation and limits

The initial user-reported 30–60 second wake delay was not fully explained by the 5.5-second device trace. The confirmed results are the measured device timings and subsequent quick screen wake.

The timing comparison covers one Mac and three RTC-triggered module cycles, including one first-suspend-after-cold-boot check; physical lid wake was evaluated separately as described above. No Thunderbolt peripheral was attached, so driver binding and native USB retention do not establish dock, eGPU or tunneled-PCIe functionality. The kernel logged `device links to tunneled native ports are missing!` at normal Thunderbolt-driver initialization. Extended sleep, overnight battery consumption, hibernation, other models and runtime behavior on the second kernel remain untested. S2idle may use more battery than deep sleep. The module is out-of-tree and unsigned in this test environment.

These tests do not establish that deep/S3 is safe with a device attached. They also do not validate combining the shim with another hook that removes its upstream bridge; the overlapping proposals need to be reconciled.

The earlier working local configuration was backed up before the module comparison and remained available for rollback. The independent results are also recorded on [Omarchy PR #10758](https://github.com/omacom/omarchy/pull/10758#issuecomment-6720126997) and [package PR #349](https://github.com/omacom/omarchy-pkgs/pull/349#issuecomment-6720129808). The older hook proposal [#9899](https://github.com/omacom/omarchy/pull/9899) was withdrawn in favor of contributing this evidence to the module approach.
