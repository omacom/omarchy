# System sleep

Omarchy enables suspend and hibernation by default, but if you're having issues with either on your machine, you can toggle them off.

### Docked laptops

With an external monitor physically connected, Omarchy keeps the normal docked lid policy in effect while the screen is blanked and while moving between the desktop and login screen. Closing the laptop lid will not suspend the machine during those transitions.

Disconnecting the external monitor restores normal lid handling within about a second. Explicit suspend commands and idle settings still apply while docked. If an administrator changes logind's `HandleLidSwitchDocked` away from `ignore`, Omarchy respects that setting.

Some docks or display drivers can report an external connector as connected after the monitor is unplugged. In that case, closing the lid will continue to do nothing until the reported connection clears. If this happens, use an explicit suspend command, or disable docked lid protection with `sudo systemctl disable --now omarchy-docked-lid-inhibit.service` to restore logind's normal lid handling. Re-enable it with `sudo systemctl enable --now omarchy-docked-lid-inhibit.service` when the connection reporting is fixed.

Disabling this protection is a machine-wide choice and later users' migrations preserve it. Administrators can also use `sudo systemctl mask --now omarchy-docked-lid-inhibit.service` to prevent it from being started manually; run `sudo systemctl unmask omarchy-docked-lid-inhibit.service` before re-enabling it.

### Power profiles

On a laptop, Omarchy remembers your power profile separately for plugged in and running on battery, and switches between the two as you plug and unplug. Out of the box that means performance on AC and balanced on battery.

You can see what your machine offers with `omarchy powerprofiles list`, and set the one you want for the state you're currently in with `omarchy powerprofiles set autodetect power-saver`. To set the other state without unplugging anything, name it directly: `omarchy powerprofiles set battery power-saver`. Whatever you pick is what you'll get back the next time you're in that state.

### Toggle suspend

You toggle suspend by running `omarchy toggle suspend` from the terminal. That just reveals/hides the option under _System_ (or `Super + Esc`), and then you can see if it works consistently on your system. If not, you can hide it again with the same command.

### Toggle hibernation

You set up hibernation by running `omarchy hibernation setup` from the terminal. Hibernation creates a /swap subvolume on your boot drive the size of your physical RAM allocation, so make sure you have plenty of room to spare. On a 32GB machine, you'll always need 32GB+ free for this volume. Hibernation also requires the default Limine bootloader.

When set up, you'll see the hibernate option under _System_ (or `Super + Esc`), and then you can see if it works consistently on your system. If not, you can remove it again by running `omarchy hibernation remove`.
