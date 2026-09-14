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

### Why are my external speakers not playing?

Probably because they're not set as the primary output. Click on the speaker icon on the right side of the bar, and it'll open the volume popup where you can pick the output device (and mix per-app volumes too).

### My laptop speakers sound off

On some laptops, Omarchy automatically applies a speaker tuning that corrects the built-in speakers' frequency response. `omarchy audio tuning status` tells you whether one is active on your machine, and `omarchy audio tuning off` turns it off if you'd rather hear the speakers raw.

### My Dell XPS 13 speakers went silent after an update

On the **XPS 13 DX13260, SKU 0E53**, enabling the CS35L56 sidecar amplifiers can leave the internal speakers silent when their firmware fails to load. Linux 7.2 enables these amplifiers for this model by default; the `dell-xps13-sidecar-amps` package enables them on earlier kernels. PipeWire can still show a selected, unmuted Speaker output with applications playing normally.

Check the model and the current boot's kernel log:

```bash
cat /sys/class/dmi/id/product_name /sys/class/dmi/id/product_sku
journalctl -k -b --no-pager | grep -E 'cs35l56.*(FIRMWARE_MISSING|Calibration disabled|Can.t read tuning IDs)'
```

If this exact model previously played sound and now has these errors, a temporary fallback is to restore the earlier codec speaker path. This bypasses the sidecar amplifiers, so bass and output quality can be reduced. It does not repair the amplifier firmware. Do not apply it to other models or to speakers that already work.

Create the override below, then rebuild the boot images. The filename intentionally matches the packaged sidecar override: a file in `/etc/modprobe.d` takes precedence over the same name in `/usr/lib/modprobe.d`. The command refuses to overwrite an existing local file; if one exists, inspect and back it up before changing it. Also check for any other local `snd_soc_sof_sdw` quirk overrides, which must not conflict with this one.

```bash
(
  set -euo pipefail
  omarchy-hw-dell-xps13-sidecar-amps
  config=/etc/modprobe.d/dell-xps13-sidecar-amps.conf
  if sudo test -e "$config"; then
    echo "Existing override: $config. Inspect it before proceeding."
    exit 1
  fi
  printf '%s\n' '# Temporary DX13260 speaker fallback; remove when amplifier support is fixed.' \
    'options snd_soc_sof_sdw quirk=1' | sudo tee "$config" >/dev/null
  sudo limine-mkinitcpio
)
```

Only reboot once the rebuild finishes successfully. Save your work, reboot, and test the speakers. The following should report `1`, and the boot log should show `Overriding quirk 0x10000 => 0x1`:

```bash
cat /sys/module/snd_soc_sof_sdw/parameters/quirk
journalctl -k -b --no-pager | grep 'Overriding quirk'
```

To undo **the file created above**, remove it and rebuild again, then reboot:

```bash
sudo rm /etc/modprobe.d/dell-xps13-sidecar-amps.conf && sudo limine-mkinitcpio
```

Removing the sidecar package alone will not restore the earlier routing on Linux 7.2, which enables it in the driver itself. Avoid substituting another speaker variant's firmware: Cirrus has [explained that the tuning is specific to the fitted speaker hardware](https://lore.kernel.org/linux-firmware/000b01dd3ac6$39c46210$ad4d2630$@opensource.cirrus.com/). See [#9687](https://github.com/omacom/omarchy/issues/9687) and [#10543](https://github.com/omacom/omarchy/issues/10543) for the amplifier firmware reports.

### Why can't I login or sudo with my password?

You probably typed it wrong too many times and got locked out. If this is happening on the lock screen, you can hit `CTRL + ALT + F2` to start a new TTY where you can login as root, then run `faillock --reset --user [your-username]`. That'll reset the lockout, and you're good to go.

### Why isn't my 1Password authorization prompts for 1Password SSH Agent / CLI appearing?

This can happen for 2 reasons:

In order for the rich approval prompt to appear, Settings > Advanced > Use Hardware Acceleration must be turned on. _Note: This requires a reboot to begin working._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Or if you haven't launched 1Password since booting up, the prompt will not appear.
