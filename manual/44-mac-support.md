# Mac support

## Omarchy for Apple Silicon

Omarchy for Apple Silicon is an official Omacom solution, first released with Omarchy 4.5. It installs next to macOS, and you choose between the two when your Mac starts.

Got a notice about Omarchy Mac? Go to [Coming from Omarchy Mac](#coming-from-omarchy-mac).

It runs on these Macs:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 and newer Macs aren't supported yet. M4 support is in testing on the edge channel and comes next. The installer checks your Mac before it changes anything.

On any Apple Silicon Mac, including M4 and newer, you can run Omarchy in a virtual machine with [Try Omarchy](https://github.com/omacom/try-omarchy).

### What you need

- macOS 15 Sequoia or later, and an administrator account
- Free disk space for Omarchy. The installer suggests a size and lets you change it.
- A backup of your Mac, power, and an internet connection. The install downloads several gigabytes.

### Installing

You install from macOS. Install the Omarchy Installer with [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Or download the newest Omarchy Installer from its [releases page](https://github.com/omacom/omarchy-mac-installer/releases) and open it.

The installer checks your Mac, shows you the plan, and makes room for Omarchy by shrinking the macOS partition. macOS stays on the disk and no USB drive is needed. When the first stage is done, it walks you through finishing setup in macOS Recovery: shut down, hold the power button until "Loading startup options" appears, choose Omarchy, and follow the steps.

On first boot, Omarchy asks for a password that encrypts its disk. There's no recovery key: if you forget the password, your Omarchy files can't be recovered.

To switch between Omarchy and macOS later, shut down, then hold the power button until the startup options appear and choose one.

### Coming from Omarchy Mac

Omarchy Mac is now part of Omarchy for Apple Silicon, and every Mac that ran it is supported. Your current install keeps running, and its system packages still update, but it gets no more Omarchy updates. There's no deadline and no in-place upgrade: you back up, remove the old install, install fresh, and restore. Steps 2 to 5 happen in macOS, so open this page on your phone before you restart.

1. **Back up from Omarchy, off the Mac.** Removing the old install erases it, and macOS can't read the Omarchy disk. Copy your home folder to an external drive or another computer, including SSH and GPG keys, browser profiles and unpushed work. Save your package list with `pacman -Qqe > ~/packages.txt`. Back up macOS too, since removing and installing both resize its disk.
2. **Start your Mac in macOS.** Shut down, hold the power button until the startup options appear, and choose macOS.
3. **Install the Omarchy Installer** as shown in [Installing](#installing).
4. **Remove the old install.** Open the Omarchy Installer and choose Installation > Remove Omarchy. It shows what it will delete and returns the space to macOS. If it doesn't recognize your install, it stops without changing the disk. Ask for help in [Discord](https://discord.gg/tXFUdasqhY) rather than deleting partitions by hand, which can erase macOS.
5. **Install Omarchy for Apple Silicon** with the installer.
6. **Restore your files.** Bring your settings back a piece at a time rather than copying all of `~/.config` over the new defaults, since old settings can override them.

### Good to know

- On M1 and M2 MacBooks, wake from sleep by opening the lid or pressing the power button.
- Questions or problems: ask in our [Discord](https://discord.gg/tXFUdasqhY).

The [installer's README](https://github.com/omacom/omarchy-mac-installer#readme) covers release channels, updating the installer and removing Omarchy.

## Intel Macs

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

The installer detects Mac hardware and applies the needed fixes automatically: Broadcom Wi-Fi drivers and firmware, the FaceTime HD camera driver on machines with a Broadcom 1570 (its firmware is downloaded from Apple once the Mac is online, since the installer works offline), the SPI keyboard driver on the MacBook models that need it, and an NVMe suspend fix for those same models.

### Known Limitations

Members of the community are constantly working on solutions to these challenges so if these are problematic for you, join #omarchy-on-other in our [Discord](https://discord.gg/tXFUdasqhY) and see if there's any up-to-date methods for resolving these.

#### FaceTime HD Camera

The camera driver hangs the machine if it is loaded when the Mac hibernates, so it is unloaded first. It cannot be unloaded while an app has the camera open, so hibernation is cancelled with a notification naming the app: close it and hibernate again. That includes hibernating automatically on a critical battery, and suspend-then-hibernate, which is refused before it suspends. Ordinary suspend is refused by the driver itself while the camera is open, without a notification.

The camera's firmware is downloaded from Apple, so the camera works only once the Mac has been online. The download starts at boot and is retried every 15 minutes while the network is the problem; if Apple's file has changed, it stops and waits for an Omarchy update. If the camera does not appear, `journalctl -u facetimehd-firmware-fetcher` says why, `sudo systemctl restart facetimehd-firmware-fetcher` tries again, and a reboot loads the driver if the download finished but the camera still is not there.

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
