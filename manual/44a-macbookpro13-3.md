# MacBookPro13,3 community setup

`MacBookPro13,3` is the **2016 15-inch MacBook Pro with T1 and Touch Bar**. This setup combines Wi-Fi board configuration, the CS8409 audio driver, T1Bridge, keyboard classification and an optional suspend/Touch Bar workaround. It was developed on one machine running Omarchy `4.0.4-1`, kernel `7.2.5-3-omarchy`, T1Bridge `0.1.12-1` and `t1bridge-omarchy 0.2.2-1`. Other models and later versions need their own validation.

**Wake still takes about 13 seconds. Battery retention is unresolved. The experimental sleep helper refuses suspend with external USB, Thunderbolt devices or displays attached; this can leave a closed laptop awake.** Use shutdown for transport and long unplugged periods until power use is measured.

## Establish working startup hardware

Check the model with `cat /sys/class/dmi/id/product_name` and the running kernel with `uname -r`. Install build tools, DKMS and headers matching that kernel through Omarchy's normal package/update flow. Preserve and back up this Mac's Apple EFI data before installation or recovery.

| Component | Setup and observed result |
| --- | --- |
| Keyboard and touchpad | Use the kernel's `applespi`. The model-specific quirk supplied by Omarchy classifies the vendor-zero SPI keyboard as internal so libinput can pair it with the internal touchpad for typing suppression. Log out and back in after installing the quirk. |
| Wi-Fi | Use the BCM43602 board template from [dzanaga/macbookpro-2016-2017-linux](https://github.com/dzanaga/macbookpro-2016-2017-linux/tree/a5147f9c00738addbbbde85302a211954709e52b/assets/wifi). Render it with this machine's address and your actual regulatory country, install only `brcmfmac43602-pcie.Apple Inc.-MacBookPro13,3.txt` under `/usr/lib/firmware/brcm/`, then rebuild with `sudo limine-mkinitcpio` and reboot. See the [tested rendering and rollback steps](https://github.com/aldervale/omarchy-macbookpro13-3/blob/ff11b52/docs/setup.md#2-repair-wi-fi-board-configuration). 5 GHz association was confirmed; internet routing was not isolated from Ethernet. |
| Audio | Follow [davidjo/snd_hda_macbookpro](https://github.com/davidjo/snd_hda_macbookpro/tree/89b22ff90b86468b186706861dd18663562defa7) for the CS8409 driver. Keep durable DKMS source root-owned and not writable by ordinary users; copying a checkout with plain `cp -a` preserves user ownership and permits modification of later root build scripts. Use `sudo cp -a --no-preserve=ownership` into a new dedicated root-owned source directory. See the [tested installation and ownership repair](https://github.com/aldervale/omarchy-macbookpro13-3/blob/ff11b52/docs/setup.md#3-install-the-audio-driver). Speakers were confirmed; microphone and headphone switching were not separately tested. |
| T1 firmware | If T1 enumerates as recovery device `05ac:1281`, follow [t1-revive](https://github.com/niconistal/t1-revive/tree/c2062f3a09b2d278649d3ec48bbb7d15c8b55bcf) for an attended recovery with mains power and backups. Recovery writes device-specific data and boot files. It is not needed merely because an otherwise working Touch Bar goes dark after sleep. No firmware is distributed with this setup. |
| Touch Bar at startup | Follow the [official T1Bridge signed-package instructions](https://github.com/standardagents/t1bridge#install-official-packages) for `t1bridge`, `t1bridge-dkms` and `t1bridge-omarchy`, including matching kernel headers and service activation. Verify the signing key using upstream instructions. Avoid competing legacy `appleibridge` modules or configuration selectors. Confirm illumination and Fn switching by eye before attempting sleep recovery. |

The source projects remain responsible for their packages, firmware recovery and device calibration. This optional setup command does not download or run their installers, redistribute firmware, modify PAM, or configure fingerprint authentication.

## Check the NVMe service target

The earlier Omarchy NVMe workaround assumed PCI `01:00.0`. On this machine that address belongs to the GPU; the SSD is at `02:00.0`. Check `systemctl cat omarchy-nvme-suspend-fix.service` and `/sys/class/nvme/nvme*/device/d3cold_allowed` before making changes. The correct target may already be configured by a later Omarchy release.

For an existing incorrectly targeted service, this contribution includes the sysfs-based helper used on the test machine. Back up any files already at the destination paths, review custom service drop-ins and install only on `MacBookPro13,3`:

```bash
sudo install -Dm755 "$OMARCHY_PATH/default/hardware/macbookpro13-3/platform/macbook-nvme-suspend-fix" /usr/local/sbin/macbook-nvme-suspend-fix
sudo install -Dm644 "$OMARCHY_PATH/default/hardware/macbookpro13-3/platform/nvme-override.conf" /etc/systemd/system/omarchy-nvme-suspend-fix.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl enable --now omarchy-nvme-suspend-fix.service
sudo systemctl restart omarchy-nvme-suspend-fix.service
```

Verify that the actual NVMe setting is `0` after reboot. Restore previous files, or remove only these additions, to revert; reload systemd and reboot. This preserves the setting used during our successful sleep tests, but **its necessity on this Samsung-equipped model remains unproven**. It is kept separate from automatic hardware setup and the sleep installer. Upstream [#11624](https://github.com/omacom/omarchy/pull/11624) and [#12687](https://github.com/omacom/omarchy/pull/12687) address the broader service applicability problem.

## Opt into undocked sleep and Touch Bar recovery

First read the limits above and verify startup hardware. The setup command defaults to a read-only hardware preflight:

```bash
omarchy setup macbookpro13-3 check
systemctl cat systemd-suspend.service
systemd-analyze cat-config systemd/sleep.conf
```

Disconnect external peripherals. A direct charger is allowed. Preflight expects two bound Alpine Ridge NHI/xHCI pairs and a production T1 device (`05ac:8600`, USB configuration 2) with the observed HID descriptor. It does not open hidraw or put the laptop to sleep. A preflight pass is not a hardware resume test.

```bash
omarchy setup macbookpro13-3 install
```

The command explains the limits and requests confirmation and administrator authentication. It holds a sleep inhibitor while installing, builds the model-restricted EC wake module through DKMS, copies root-owned runtime helpers, and installs the s2idle policy and one ordered systemd suspend drop-in. It refuses existing community installations, prior runtime trials, other suspend hooks and conflicting effective sleep policy. Do not remove a working installation just to try this draft's packaging; compare it first. No automatic migration enables this experiment.

Before suspend, the hook checks peripheral and controller state, EC wake policy and lid wake permission. It loads the EC helper with `apply=1`, selects s2idle, saves `pm_async`, sets synchronous device callbacks and unloads Thunderbolt. On completion or preparation failure, it restores `pm_async` and reloads Thunderbolt with `host_reset=0`. Failed cleanup leaves a state record for recovery.

Only after successful suspend and controller cleanup does the Touch Bar hook inspect feature report 3. If parked, it sends one unpark report, waits 0.6 seconds and checks the readback. Model, USB configuration, interface, descriptor, opened-device identity and report values are checked. Recovery is time-bounded; no ACPI reset, firmware regeneration, device rebind or retry loop is used. A readback success still does not prove visible illumination.

The new combined installer has fixture coverage; the underlying recovery sequence was validated separately on the owner's machine. The combined installation itself still needs an attended hardware test before this draft can be considered ready.

## Verify and remove

Save work and start with one attended two-minute lid cycle. Measure lid-open to usable screen, confirm the Touch Bar lights and Fn changes icons, and check keyboard, touchpad, Wi-Fi, audio and external-port function. Repeat after a full reboot. Review `journalctl -b -u systemd-suspend.service` and the kernel journal for failures. Longer sleep and battery-loss measurements are separate tests.

Four automatic recoveries, including one after a full reboot, restored visible Touch Bar output and Fn switching on the test machine. Two owner measurements were approximately 13 seconds to wake. Kernel traces placed roughly 12.7 seconds in device noirq resume, dominated by two Alpine Ridge bridge callbacks. The display hook itself took about 0.74 seconds. Faster-wake experiments remain unvalidated and are not enabled here.

```bash
omarchy setup macbookpro13-3 remove
```

Removal checks the exact installed-file hashes, removes the sleep and Touch Bar hooks, DKMS registration and the policy installed by this command, and retains Wi-Fi, audio, NVMe, T1Bridge and keyboard settings. Administrator edits cause removal to stop for review. **Reboot afterwards:** unloading the EC module cannot clear its current-boot wake-capability mark. The original deep-sleep failure may return with the previous policy.

For keyboard focus, keep `disable_while_typing` enabled. Setting `input.follow_mouse = 0` in your Hyprland user configuration can prevent focus changes from pointer motion; that is a personal preference, so this contribution does not change it. Physical clicks and modifier-only key presses have different libinput behavior and still need a typing test.

The [community repair repository](https://github.com/aldervale/omarchy-macbookpro13-3) records the complete evidence, limitations and original source provenance. Its files and the adapted recovery payload retain GPL-2.0-only; the other named projects retain their own licenses.
