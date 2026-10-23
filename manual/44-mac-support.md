# Mac support

Omarchy has built-in support for **Intel Macs**. There are a couple of known limitations at the moment, but as long as you're aware and OK with those; you can breathe some new life into your old Macs by loading Omarchy.

Please note that installing on an M-series Mac is not directly supported at this time. You can find out more about the state of this in #omarchy-on-other in our [Discord](https://discord.gg/tXFUdasqhY).

In a simple test, we were able to achieve 36% performance gains on a 2019 MacBook Pro just by installing Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installing Omarchy on Mac

Omarchy only supports being the **only** OS installed at the moment. During the installation, the drive will be wiped and MacOS will no longer be bootable.

You can still restore it later via Internet Recovery if you'd like.

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

The installer detects Mac hardware and applies the needed fixes automatically: Broadcom Wi-Fi drivers and firmware, the SPI keyboard driver on the MacBook models that need it, and an NVMe suspend fix for those same models.

### Known Limitations

Members of the community are constantly working on solutions to these challenges so if these are problematic for you, join #omarchy-on-other in our [Discord](https://discord.gg/tXFUdasqhY) and see if there's any up-to-date methods for resolving these.

#### Devices with T1 Chip

The Apple T1 chip was introduced in late 2016 and used exclusively in the first-generation MacBook Pro models with Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Known Issues

- Touch Bar is dark out of the box. Omarchy's built-in Touch Bar support is T2-only. These machines have no physical Esc/F-row, so brightness, volume, and function keys only exist once the T1 bar is driven. On at least MacBookPro13,2 (2016 13-inch with Touch Bar) the bar, webcam, and (optionally) Touch ID work after restoring this Mac's Apple EFI data and installing [t1bridge](https://github.com/standardagents/t1bridge).

If sysfs shows USB `05ac:1281` (Apple Mobile Device Recovery Mode) or `/boot/EFI/APPLE/EMBEDDEDOS` is missing, the installer wiped the T1 firmware data. Restore it with [t1-revive](https://github.com/niconistal/t1-revive) before t1bridge. That tool talks to Apple's restore protocol; it is irreversible without an `EFI/APPLE` backup. Do not pass `--no-confirm`. After a successful restore the T1 should enumerate as `05ac:8600`.

Then add the signed t1bridge repo from [the t1bridge README](https://github.com/standardagents/t1bridge#install-official-packages) (fingerprint `35B166F78B063B04DE1E3D913E6C4216EB03D371`) and install. On Omarchy run `omarchy update` first so `pacman -S` is not a partial upgrade. Use `linux-omarchy-headers` for this kernel. Omit the fingerprint packages unless you want Touch ID (they replace distro libfprint/fprintd):

```bash
omarchy update
sudo pacman -S --needed linux-omarchy-headers t1bridge t1bridge-dkms t1bridge-omarchy
sudo systemd-sysusers /usr/lib/sysusers.d/t1bridge.conf
sudo systemd-tmpfiles --create /usr/lib/tmpfiles.d/t1bridge.conf
sudo usermod -aG t1bridge "$(id -un)"
sudo systemctl daemon-reload
sudo systemctl enable t1-touchbar-hw.service
sudo reboot
```

After reboot, in a graphical session:

```bash
systemctl --user daemon-reload
systemctl --user enable --now t1-touchbar.service
sudo t1bridge status
```

Success looks like USB `05ac:8600` configuration 2, `/dev/dri/touchbar` present, `t1-touchbar-hw.service` and user `t1-touchbar.service` active, and `id` listing `t1bridge`. Esc, Fn→F1–F12, brightness, volume, and media should work. A login that started before `usermod` will not have the group until you log out (or reboot). Volume and media need `t1bridge-omarchy` (or another desktop provider) via `T1BRIDGE_DESKTOP_PROVIDER`. Do not run Omarchy's generic fingerprint wizard if you later add Touch ID; it can replace the matched t1bridge fprintd pair.

- After suspend the laptop can wake with Touch Bar taps still working and the strip still dark. appletbdrm parks the panel (HID feature report 3 byte 1 = `0x01`) and t1bridge 0.1.12 does not write the awake value. systemd 262 only runs `/usr/lib/systemd/system-sleep` (not `/etc`). usbfs SET_REPORT is `EBUSY` because t1bridge-cfgselector owns `05ac:8600`. On MacBookPro13,2 (Omarchy 4.0.6, t1bridge 0.1.12), hidraw on iBridge interface 6 with `HIDIOCSFEATURE` `03 02` changed report 3 from `03010000` to `03020000` and relit the strip without a power cycle. Use s2idle, not S3/`deep`. Do not call ACPI `FRST` to "fix" sleep. Installable workaround: [Alkarth2010/t1-touchbar-s2idle](https://github.com/Alkarth2010/t1-touchbar-s2idle).
- Omarchy's `omarchy-hw-external-monitors` treats the Touch Bar DRM connector (`card*-USB-*`) as an external display, so an undocked lid close can skip the lock. The workaround repo includes a helper that ignores that connector. A real HDMI/DP monitor still counts as docked.
- Sound is not functioning

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
