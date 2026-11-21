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

#### MacBook Pro 13-inch (2017, two Thunderbolt 3 ports)

On `MacBookPro14,1`, deep sleep with a USB-C hub attached can leave the fast USB controller inaccessible until a complete shutdown and power-on. A Gigabit Ethernet adapter may then use the hub's USB 2 connection, even though its wired link still reports 1 Gbps.

Check `lsusb -t` before and after sleep. A Gigabit USB adapter connected at `480M` cannot deliver full Gigabit throughput; its USB 3 connection normally appears at `5000M`. A fallback after sleep can indicate a controller resume failure, so check it after a cold power-on before replacing the hub or cable. The SSD suspend fix does not cover this Thunderbolt controller issue.

See [the upstream investigation](https://github.com/omacom/omarchy/issues/10593) and [the proposed module fix](https://github.com/omacom/omarchy/pull/10758) for current status. Independent RTC-triggered testing on one MacBookPro14,1 verified quick wake and over 900 Mbps after resume with the proposed module and s2idle; the package proposal remains unmerged as of November 8, 2026. Other models, Thunderbolt peripherals and overnight battery use need separate validation.

Test lid-open wake separately from an alarm or keyboard wake. On the tested machine, opening the lid still required a keypress even after restoring the older suspend hook. Investigation found that the kernel rejected enabling the embedded controller's wake interrupt because it was not registered as wake-capable. A model-specific local helper corrected that error and passed a physical lid-open test. It then loaded automatically after reboot, followed by two more completed lid cycles. Longer-term reliability and battery effects still need validation; this is not yet a shipped Omarchy fix.

#### Devices with T1 Chip

The Apple T1 chip was introduced in late 2016 and used exclusively in the first-generation MacBook Pro models with Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Known Issues

- Touch Bar is non-functional
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

#### iMac Retina 5K (2017)

The 2017 27-inch iMac has no T2 chip, so the installer sets it up like the other Intel Macs.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Known Issues

- The display doesn't run at its native 5120×2880: the panel is two tiles, and the stock driver lights only one
- Sound is not functioning
- The brightness control has no effect
- Sleep hangs the machine; only a power cycle recovers it

A community patcher for this model fixes the display, sound and brightness: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
