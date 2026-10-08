# System sleep

Omarchy enables suspend and hibernation by default, but if you're having issues with either on your machine, you can toggle them off.

### Power profiles

On a laptop, Omarchy remembers your power profile separately for plugged in and running on battery, and switches between the two as you plug and unplug. Out of the box that means performance on AC and balanced on battery.

You can see what your machine offers with `omarchy powerprofiles list`, and set the one you want for the state you're currently in with `omarchy powerprofiles set autodetect power-saver`. To set the other state without unplugging anything, name it directly: `omarchy powerprofiles set battery power-saver`. Whatever you pick is what you'll get back the next time you're in that state.

### Toggle suspend

You toggle suspend by running `omarchy toggle suspend` from the terminal. That just reveals/hides the option under _System_ (or `Super + Esc`), and then you can see if it works consistently on your system. If not, you can hide it again with the same command.

### Keep running with the lid closed

Closing a laptop's lid suspends it, unless an external monitor is connected. To keep the laptop running with the lid shut, so downloads, builds, SSH and remote sessions carry on, turn on lid awake with `omarchy toggle lid awake`, from _Trigger > Toggle_, or by clicking the laptop icon among the bar's indicators. Closing the lid still locks the session and turns the screen off; only the suspend is skipped.

Lid awake turns itself off when you reboot, so a laptop can't be left stuck awake in a bag. It also turns itself off at 10% battery while discharging, plays an alert, and restores normal lid-close suspend. It will not turn itself back on until you choose to do so. Set `lidAwake.batteryFloor` in `~/.config/omarchy/shell.json` to a whole percentage from 1–100 to choose another floor, or to `0` to disable this protection. It covers a different case from stay awake, which keeps the screen on and unlocked while the lid is open. `omarchy toggle lid awake status` prints the current state as JSON.

### Toggle hibernation

You set up hibernation by running `omarchy hibernation setup` from the terminal. Hibernation creates a /swap subvolume on your boot drive the size of your physical RAM allocation, so make sure you have plenty of room to spare. On a 32GB machine, you'll always need 32GB+ free for this volume. Hibernation also requires the default Limine bootloader.

When set up, you'll see the hibernate option under _System_ (or `Super + Esc`), and then you can see if it works consistently on your system. If not, you can remove it again by running `omarchy hibernation remove`.
