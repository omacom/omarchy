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
- MacBook Pro 16-inch (2019) – Model: A2141 (`MacBookPro16,1`)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

On these models, the installer automatically sets up the patched `linux-t2` kernel, the T2 audio configuration, Apple's Broadcom Wi-Fi/Bluetooth firmware, and fan control via `t2fanrd`. The Touch Bar runs on the kernel's built-in Boot Camp-style support.

### Power and graphics on dual-GPU T2 MacBooks

Some T2 MacBook Pros have both Intel integrated graphics and an AMD discrete GPU, including the 2019 16-inch `MacBookPro16,1`. Their graphics configuration can affect battery life, gaming performance, external displays, and suspend. These notes do not apply to integrated-only MacBooks or Apple silicon, and are not a claim that every feature has been validated on every T2 model.

Start by identifying your hardware and kernel:

```bash
cat /sys/class/dmi/id/product_name
uname -r
lspci -nnk | rg -A3 'VGA compatible controller|Display controller|3D controller'
```

#### Keep a balanced baseline

Select **Balanced** in Omarchy's power panel while on battery. Omarchy remembers separate AC and battery preferences; `powerprofilesctl get` shows the currently applied profile. Run profile commands as your desktop user, not with `sudo`, so they use your saved preferences.

Current Omarchy handles power-source changes in the desktop shell. Review older custom power-profile udev rules before carrying them forward; a second policy owner can conflict with the desktop's saved settings. Keep the installed T2 fan control in place while evaluating power changes.

#### Choose the display GPU deliberately

The [T2 Linux hybrid-graphics guide](https://wiki.t2linux.org/guides/hybrid-graphics/) describes selecting Intel through `apple-gmux` with `force_igd=y`. This changes the internal panel's routing at boot; it is separate from choosing a GPU for an application. Back up the previous configuration and rebuild the initramfs/UKI with the tool used by your installation before rebooting. On Omarchy installations using Limine, use `sudo limine-mkinitcpio`. Do not copy another distribution's bootloader commands blindly.

For Hyprland, follow the [multi-GPU configuration guide](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Multi-GPU/). With UWSM, export `AQ_DRM_DEVICES` in `~/.config/uwsm/env-hyprland`, then log out and back in. Use stable device aliases rather than assuming `card0` or `card1` always identifies the same GPU; the Touch Bar can also appear as a DRM device.

- Intel first, AMD second allows Intel-primary rendering while retaining access to AMD-connected display outputs. This alone does not guarantee that AMD will suspend.
- Listing only Intel excludes AMD-connected outputs from the compositor. It does not disable the AMD driver or automatically power off that GPU.
- Check `hyprctl monitors all` before disabling a duplicate internal-panel output. Connector names vary; do not disable `eDP-2` on every MacBook without identifying it.

Save your previous UWSM and monitor configuration so you can restore it if a display stops working. Reverting a gmux change also requires rebuilding the boot image and rebooting.

#### Low clocks, runtime suspend, and game selection are different

AMD's `power_dpm_force_performance_level=low` restricts clocks to the lowest power state. It is a performance limitation, not an automatic gaming profile and not evidence that the GPU is powered off. `auto` enables dynamic profile selection, but T2 systems can need a low/high workaround for graphics instability. See the [kernel's AMD power-control documentation](https://docs.kernel.org/gpu/amdgpu/thermal.html#power-dpm-force-performance-level) and the T2 guide before changing a working configuration. Do not re-enable a mode that previously caused GPU resets just to pursue a lower idle-power figure.

Read runtime state separately. For the Radeon at `0000:03:00.0` on a `MacBookPro16,1` (verify the address on your machine):

```bash
cat /sys/bus/pci/devices/0000:03:00.0/power/control
cat /sys/bus/pci/devices/0000:03:00.0/power/runtime_status
cat /sys/bus/pci/devices/0000:03:00.0/power/runtime_suspended_time
cat /sys/bus/pci/devices/0000:03:00.0/power_dpm_force_performance_level
```

`power/control=on` prevents runtime suspension. `auto` permits it but does not prove it occurred; look for `runtime_status=suspended` and increasing suspended time after closing GPU clients. This runtime-PM `auto` is a different control from DPM `auto`. [Linux documents their distinction](https://docs.kernel.org/power/runtime_pm.html).

For games, an application's GPU selector or a per-application launcher can choose AMD. [Mesa's `DRI_PRIME`](https://docs.mesa3d.org/envvars.html#envvar-DRI_PRIME) supports selection by PCI address, such as `DRI_PRIME=pci-0000_03_00_0`. For Vulkan, appending `!` exposes only that GPU. Selection does not remove a forced `low` clock limit, and applications do not necessarily migrate to AMD when Intel becomes busy. Verify the renderer inside the application rather than assuming that launch succeeded on the intended GPU.

#### Verify the tradeoffs before making them permanent

Compare battery discharge over several minutes with the same brightness, applications, peripherals, and workload. Record battery full-charge capacity too; an aged battery cannot regain its original capacity through software tuning. A GPU sensor reading is not whole-machine power consumption, and one discharge-rate sample is not a battery-life benchmark.

After each change, check a cold boot, AC/battery transitions, your actual games, video playback, repeated suspend/resume, and any external displays you use. Recheck GPU runtime state after closing applications. Treat failed or untested cases as limitations, not as a fully optimized configuration. Share the model identifier, kernel version, configuration, and repeatable measurements when reporting results.

#### MacBookPro16,1 reference findings

A [model-specific configuration and validation report](../docs/hardware/macbookpro16-1.md) records the settings tested on a 2019 16-inch MacBook Pro with Intel UHD 630 and Radeon Pro 5500M. It includes the Intel-primary display configuration, balanced CPU policy, video-driver cleanup, an experimental load-based Radeon low/high controller, its tests, and rollback instructions. These are reviewable reference artifacts, not changes to Omarchy's installation defaults.

Five short rendering/idle cycles across AC, battery, and wake verified automatic Radeon clock transitions; one physical suspend/resume also passed. The Radeon returned to approximately 4 W on its own power sensor, compared with approximately 15 W during a brief forced-high idle check. The prior fixed-low configuration already idled around 4 W: the new controller restores access to high clocks under load, not an additional reduction below that baseline. There is no measured game-FPS increase, whole-laptop battery-life percentage, or claim that every MacBook feature is now optimized. Cold boot, longer real-game sessions, repeated suspend, and external displays still need validation.
