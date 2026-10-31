# System sleep

Omarchy enables suspend and hibernation by default, but if you're having issues with either on your machine, you can toggle them off.

On NVIDIA GB10 machines, such as the DGX Spark and the ASUS Ascent GX10, suspend and hibernation are turned off, as they are in NVIDIA's DGX OS, because sleep hasn't been shown to work on that hardware yet. The suspend toggle and hibernation setup don't apply there. To turn sleep back on, remove `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` with `sudo rm`; Suspend then returns to the menu, and hibernation can be set up as on other machines. Running `sudo omarchy apply hardware --install-user "$USER"` puts the file back.

On Razer Blade laptops, Omarchy ignores lid events, because the firmware on those machines breaks the lid-close sleep flow: after a sleep the lid state can stick at "closed", the laptop wakes on its own, and opening the lid doesn't reliably bring the display back. With lid events ignored, closing the lid switches the display off with the machine still running, and opening it brings everything back. To put a Razer Blade to true sleep, use the sleep option under _System_ (or `Super + Esc`) with the lid open; on battery, shutting down is the reliable option. To restore the default lid behavior, remove `/etc/systemd/logind.conf.d/30-razer-lid-ignore.conf` with `sudo rm`, or put it back with `sudo omarchy apply hardware --install-user "$USER"`, then reboot - logind only reads the drop-in at boot.

### Power profiles

On a laptop, Omarchy remembers your power profile separately for plugged in and running on battery, and switches between the two as you plug and unplug. Out of the box that means performance on AC and balanced on battery.

You can see what your machine offers with `omarchy powerprofiles list`, and set the one you want for the state you're currently in with `omarchy powerprofiles set autodetect power-saver`. To set the other state without unplugging anything, name it directly: `omarchy powerprofiles set battery power-saver`. Whatever you pick is what you'll get back the next time you're in that state.

### Toggle suspend

You toggle suspend by running `omarchy toggle suspend` from the terminal. That just reveals/hides the option under _System_ (or `Super + Esc`), and then you can see if it works consistently on your system. If not, you can hide it again with the same command.

### Toggle hibernation

You set up hibernation by running `omarchy hibernation setup` from the terminal. Hibernation creates a /swap subvolume on your boot drive the size of your physical RAM allocation, so make sure you have plenty of room to spare. On a 32GB machine, you'll always need 32GB+ free for this volume. Hibernation also requires the default Limine bootloader.

When set up, you'll see the hibernate option under _System_ (or `Super + Esc`), and then you can see if it works consistently on your system. If not, you can remove it again by running `omarchy hibernation remove`.
