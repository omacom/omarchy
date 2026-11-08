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

## Lid-open wake: unresolved after an EC wake trial

The three RTC-triggered tests above validated resume after an alarm. A later physical lid-close/open test exposed a separate problem: opening the lid left the machine suspended until a keypress. The user waited approximately 15 seconds with the lid open before pressing a key. A user-session observer received `PrepareForSleep=false` and produced post-resume samples only after that keypress. From the first sample, Hyprland reported the internal display enabled with DPMS on and the backlight reported normal power. Journal ordering alone had initially suggested that the lid caused wake; a queued lid-open event can be processed when another input wakes the machine.

The lid device's wake flag was enabled and `acpi.ec_no_wakeup` was already `N`, but the embedded controller at `/sys/bus/acpi/devices/PNP0C09:00/physical_node/power/wakeup` was `disabled`. Enabling that EC device wake flag was the only change for the next physical test. The machine stayed asleep until lid opening, then woke the screen promptly without a keypress, as confirmed by the user. USB Ethernet remained at `5000M`. No lock-screen or Hyprland changes were made for that test.

The local persistent rule was scoped to the tested model and embedded-controller driver:

```udev
ACTION=="add|bind", SUBSYSTEM=="platform", KERNEL=="PNP0C09:00", DRIVER=="acpi-ec", PROGRAM=="/usr/bin/cat /sys/class/dmi/id/product_name", RESULT=="MacBookPro14,1", ATTR{power/wakeup}="enabled"
```

It was installed as `/etc/udev/rules.d/71-macbook-lid-wakeup.rules`. `udevadm verify` passed. While awake, the flag was temporarily disabled and a targeted add event was emitted for this existing EC device; the installed rule restored `enabled` without rebinding the driver. After a subsequent reboot, the EC wake flag remained `enabled`, but the user reported the lid-open failure again. The observed sleep used s2idle, lid wake remained enabled, `acpi.ec_no_wakeup` remained `N`, and both Thunderbolt modules were loaded; Ethernet still used USB `5000M`. The rule therefore persisted, but it did not reliably solve lid-open wake. The previous rule/flag were backed up so this setting can be reverted independently of the Thunderbolt module.

The initial evidence records two instrumented physical lid cycles, one before and one after the EC change, in addition to the three RTC comparison cycles. The later failure contradicts treating the EC setting as a confirmed fix; lid-open wake remains unresolved. The single successful cycle does not establish causation. It does not establish the same requirement on other Macs or measure overnight battery behavior and other possible EC wake sources. The local EC rule is a separate configuration change; it is not part of the unchanged module/package tested above.

Subsequent physical tests also failed with the module plus the earlier Thunderbolt D3cold guard, and then with the complete pre-module hook setup restored, the shim unloaded/removed and EC wake reverted. The latter comparison was performed in the same running boot; a cold start of the restored setup remains untested. The old hook executed its controller removal and recovery successfully, and Ethernet returned at `5000M`. These results do not establish the shim as the cause of the lid-wake failure.

A targeted kernel trace during a failed module cycle recorded `_PSW(1)` and entry into the ACPI EC write handler with `0x01` at offset `0x68`, the firmware table's lid-open wake bit. The lid notification appeared only after the kernel left `machine_suspend`; GPE `0x6F`, named by the lid's `_PRW`, remained at zero. This verifies that the kernel requested arming the lid wake bit, not that firmware accepted it or produced a physical wake signal. The user also observed keyboard backlighting on lid opening, which alone does not establish that Linux resumed.

## Interpretation and limits

The initial user-reported 30–60 second wake delay was not fully explained by the 5.5-second device trace. The confirmed results are the measured device timings and subsequent quick screen wake.

The timing comparison covers one Mac and three RTC-triggered module cycles, including one first-suspend-after-cold-boot check; physical lid wake was evaluated separately as described above. No Thunderbolt peripheral was attached, so driver binding and native USB retention do not establish dock, eGPU or tunneled-PCIe functionality. The kernel logged `device links to tunneled native ports are missing!` at normal Thunderbolt-driver initialization. Extended sleep, overnight battery consumption, hibernation, other models and runtime behavior on the second kernel remain untested. S2idle may use more battery than deep sleep. The module is out-of-tree and unsigned in this test environment.

These tests do not establish that deep/S3 is safe with a device attached. They also do not validate combining the shim with another hook that removes its upstream bridge; the overlapping proposals need to be reconciled.

The earlier working local configuration was backed up before the module comparison and remained available for rollback. The independent results are also recorded on [Omarchy PR #10758](https://github.com/omacom/omarchy/pull/10758#issuecomment-6720126997) and [package PR #349](https://github.com/omacom/omarchy-pkgs/pull/349#issuecomment-6720129808). The older hook proposal [#9899](https://github.com/omacom/omarchy/pull/9899) was withdrawn in favor of contributing this evidence to the module approach.
