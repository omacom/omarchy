# Troubleshooting

### I broke my system with an update!

First try to [rollback your system](47-system-snapshots.md) the version before your recent update. If that doesn't work, use `omarchy-debug` to share with your problem on #omarchy-help in the Discord. And if all that fails, you can reinstall the defaults configs and packages using `omarchy-reinstall`.

### Why are some apps so large on my display?

Omarchy assumes a 2x high-resolution display, which requires setting `GDK_SCALE` to 2 in `~/.config/hypr/monitors.lua`. But if you're on a 1x display, you can change `local omarchy_gdk_scale = 2` to 1 (and then restart any app that's oversized). See [the manual on monitors](33-monitors.md).

For Spotify, you can use `Ctrl + Minus` to shrink the UI (and `Ctrl + Plus` to make it bigger).

### Why isn't Caps Lock working?

In Omarchy, Caps Lock has been designated to be the xcompose key. That's how you get [quick emojis](07-hotkeys.md#quick-emojis) and [other autocompletions](07-hotkeys.md#quick-completions) done. If you really miss using Caps Lock, you can remap the xcompose key to something else by editing `~/.config/hypr/input.lua`, like setting it to the right alt key:

```
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### My Wi-Fi, Bluetooth, audio, or trackpad just stopped working

Before you reboot, try restarting the offending subsystem on its own. _Update > Hardware_ in the Omarchy menu has Wi-Fi, Bluetooth, Audio, and Trackpad, and reloading one of those clears up the majority of "it worked five minutes ago" situations — a Bluetooth headset that won't reconnect, a trackpad that went dead after a suspend, sound that vanished when you unplugged a monitor.

### My mouse or other USB peripherals are frozen after waking from sleep

On some AMD systems, USB controllers fail to come back cleanly after waking from sleep (deep sleep on some AMD systems): the mouse, keyboard, or a USB receiver still shows up as connected, but stops responding until the controller is reset — replugging it into the same port doesn't help, but reloading the driver (below) or a reboot does. The kernel log shows the controller failing to resume:

```text
xHC error in resume, USBSTS 0x401, Reinit
xHCI host controller not responding, assume dead
HC died; cleaning up
```

This is a known upstream AMD xHCI resume bug ([Bugzilla 221073](https://bugzilla.kernel.org/show_bug.cgi?id=221073)), not something caused by Omarchy. Two workarounds are known:

1. **Force legacy interrupts on the xHCI driver (the reported fix).** Adding `xhci_hcd.quirks=0x40` (the XHCI_BROKEN_MSI quirk) to the kernel command line makes the controller use a regular interrupt instead of MSI, which has sidestepped the resume failure for those who reported it.
2. **Try a different sleep state (helps in some cases, not a complete fix).** If `cat /sys/power/mem_sleep` shows `[deep]` selected, switching to s2idle may avoid the failure: add `mem_sleep_default=s2idle` to the kernel command line, or for the current session only, run `echo s2idle > /sys/power/mem_sleep` (as root). It uses more battery while suspended, and the bug itself has been reported resuming from s2idle too, so it may only make the failure rarer. If `[s2idle]` is already selected, this changes nothing.

To add a kernel parameter with the default Limine boot loader, put it in a drop-in file, regenerate the boot entries, and reboot:

```bash
echo 'KERNEL_CMDLINE[default]+=" xhci_hcd.quirks=0x40"' | sudo tee /etc/limine-entry-tool.d/usb-xhci-quirks.conf
sudo limine-mkinitcpio
```

If a peripheral is already frozen right now, you can usually bring it back without a reboot by reloading the xHCI driver for your controller. Find its address with `lspci -Dk -d ::0c03` (the USB controllers whose driver in use is `xhci_hcd`), then (as root):

```bash
echo -n 0000:30:00.3 > /sys/bus/pci/drivers/xhci_hcd/unbind
sleep 2
echo -n 0000:30:00.3 > /sys/bus/pci/drivers/xhci_hcd/bind
```

(substitute the address of your own controller; the devices on that bus will re-enumerate. Only unbind the controller whose peripherals are frozen — if the controller also hosts your storage or the keyboard you're typing on, those will drop too). Note that disabling USB autosuspend alone (`usbcore.autosuspend=-1`) does not help with this particular bug, and Omarchy's shipped autosuspend config in `/etc/modprobe.d/omarchy-usb-autosuspend.conf` is ignored when `usbcore` is built into the kernel.

### Why are my external speakers not playing?

Probably because they're not set as the primary output. Click on the speaker icon on the right side of the bar, and it'll open the volume popup where you can pick the output device (and mix per-app volumes too).

### My laptop speakers sound off

On some laptops, Omarchy automatically applies a speaker tuning that corrects the built-in speakers' frequency response. `omarchy audio tuning status` tells you whether one is active on your machine, and `omarchy audio tuning off` turns it off if you'd rather hear the speakers raw.

### Why can't I login or sudo with my password?

You probably typed it wrong too many times and got locked out. If this is happening on the lock screen, you can hit `CTRL + ALT + F2` to start a new TTY where you can login as root, then run `faillock --reset --user [your-username]`. That'll reset the lockout, and you're good to go.

### Why isn't my 1Password authorization prompts for 1Password SSH Agent / CLI appearing?

This can happen for 2 reasons:

In order for the rich approval prompt to appear, Settings > Advanced > Use Hardware Acceleration must be turned on. _Note: This requires a reboot to begin working._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Or if you haven't launched 1Password since booting up, the prompt will not appear.
