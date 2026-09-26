# System sleep

Omarchy enables suspend and hibernation by default, but if you're having issues with either on your machine, you can toggle them off.

### Power profiles

On a laptop, Omarchy remembers your power profile separately for plugged in and running on battery, and switches between the two as you plug and unplug. Out of the box that means performance on AC and balanced on battery.

You can see what your machine offers with `omarchy powerprofiles list`, and set the one you want for the state you're currently in with `omarchy powerprofiles set autodetect power-saver`. To set the other state without unplugging anything, name it directly: `omarchy powerprofiles set battery power-saver`. Whatever you pick is what you'll get back the next time you're in that state.

### Closing the lid

On a laptop, closing the lid suspends the machine. That's the right default for a laptop in a bag, and the wrong one for a laptop carrying a build, an agent, or an SSH session from the office to the kitchen table.

The Power panel in the top bar has a _Lid close_ picker for exactly that: _Suspend_ is the default, _Stay Awake_ keeps everything running with the lid shut. The same switch is _Trigger > Hardware > Lid Stay Awake_ in the menu, and `omarchy toggle lid` from the terminal (`omarchy toggle lid status` prints the current state as JSON). It only shows up on machines with a lid switch.

Staying awake doesn't mean staying open. Closing the lid still locks the screen, so the laptop is as safe in transit as it would be asleep. Omarchy holds a logind inhibitor for the lid switch while the mode is on, so nothing in `logind.conf` is touched, and _System > Suspend_ still works when you ask for it. The choice is remembered across restarts until you flip it back.

### Toggle suspend

You toggle suspend by running `omarchy toggle suspend` from the terminal. That just reveals/hides the option under _System_ (or `Super + Esc`), and then you can see if it works consistently on your system. If not, you can hide it again with the same command.

### Toggle hibernation

You set up hibernation by running `omarchy hibernation setup` from the terminal. Hibernation creates a /swap subvolume on your boot drive the size of your physical RAM allocation, so make sure you have plenty of room to spare. On a 32GB machine, you'll always need 32GB+ free for this volume. Hibernation also requires the default Limine bootloader.

When set up, you'll see the hibernate option under _System_ (or `Super + Esc`), and then you can see if it works consistently on your system. If not, you can remove it again by running `omarchy hibernation remove`.
