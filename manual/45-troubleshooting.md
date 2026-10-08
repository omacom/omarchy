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

### Audio stops when my phone connects over Bluetooth

If your WirePlumber log shows `org.bluez.Error.NotAuthorized` followed by a `create-node.lua` error when a paired phone connects, try disabling automatic A2DP source connection for that phone. This is a workaround for the reported WirePlumber failure, not a repair of its node-creation code.

`a2dp_sink` connects audio output devices such as speakers and headphones. `a2dp_source` lets your PC receive media audio from a phone, so removing it also stops that phone from automatically connecting for phone-to-PC music playback. Calls use separate HFP/HSP profiles. Omarchy keeps both A2DP directions enabled by default.

Find the affected phone's Bluetooth address with `bluetoothctl devices`. Create `~/.config/wireplumber/wireplumber.conf.d/zz-local-bluetooth-a2dp.conf` with the following content, replacing `AA:BB:CC:DD:EE:FF` with that address. If the directory is missing, create it with `mkdir -p ~/.config/wireplumber/wireplumber.conf.d`. If the file already exists, add this rule to its `monitor.bluez.rules` array instead of replacing existing settings.

```ini
monitor.bluez.rules = [
  {
    matches = [
      {
        device.name = "~bluez_card.*"
        api.bluez5.address = "AA:BB:CC:DD:EE:FF"
      }
    ]
    actions = {
      update-props = {
        bluez5.auto-connect = [ a2dp_sink ]
      }
    }
  }
]
```

The `zz-` prefix puts this rule after Omarchy's `bluetooth-a2dp-autoconnect.conf`. Keep any other custom fragments that change this setting in mind: the last matching rule wins. This rule changes only the named phone; other devices retain their existing policy. To opt out for every Bluetooth device instead, remove the `api.bluez5.address` line.

Restart WirePlumber to load the change; this briefly interrupts audio:

```bash
systemctl --user restart wireplumber.service
```

If the bar stops responding after audio recovery, restart the shell with `omarchy restart shell`. To undo the workaround, remove only the rule you added (or its file if it contains nothing else) and restart WirePlumber again. Your other Bluetooth customizations stay in place. If the failure persists, share the relevant `journalctl --user -u wireplumber.service` output when reporting the problem.

### My laptop speakers sound off

On some laptops, Omarchy automatically applies a speaker tuning that corrects the built-in speakers' frequency response. `omarchy audio tuning status` tells you whether one is active on your machine, and `omarchy audio tuning off` turns it off if you'd rather hear the speakers raw.

### Why can't I login or sudo with my password?

You probably typed it wrong too many times and got locked out. If this is happening on the lock screen, you can hit `CTRL + ALT + F2` to start a new TTY where you can login as root, then run `faillock --reset --user [your-username]`. That'll reset the lockout, and you're good to go.

### Why isn't my 1Password authorization prompts for 1Password SSH Agent / CLI appearing?

This can happen for 2 reasons:

In order for the rich approval prompt to appear, Settings > Advanced > Use Hardware Acceleration must be turned on. _Note: This requires a reboot to begin working._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Or if you haven't launched 1Password since booting up, the prompt will not appear.
