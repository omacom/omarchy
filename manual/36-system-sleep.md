# System sleep

Omarchy enables suspend and hibernation by default, but if you're having issues with either on your machine, you can toggle them off.

### Power profiles

On a laptop, Omarchy remembers your power profile separately for plugged in and running on battery, and switches between the two as you plug and unplug. Out of the box that means performance on AC and balanced on battery.

You can see what your machine offers with `omarchy powerprofiles list`, and set the one you want for the state you're currently in with `omarchy powerprofiles set autodetect power-saver`. To set the other state without unplugging anything, name it directly: `omarchy powerprofiles set battery power-saver`. Whatever you pick is what you'll get back the next time you're in that state.

### Toggle suspend

You toggle suspend by running `omarchy toggle suspend` from the terminal. That just reveals/hides the option under _System_ (or `Super + Esc`), and then you can see if it works consistently on your system. If not, you can hide it again with the same command.

### Toggle hibernation

You set up hibernation by running `omarchy hibernation setup` from the terminal. Hibernation creates a /swap subvolume on your boot drive the size of your physical RAM allocation, so make sure you have plenty of room to spare. On a 32GB machine, you'll always need 32GB+ free for this volume. Hibernation also requires the default Limine bootloader.

When set up, you'll see the hibernate option under _System_ (or `Super + Esc`), and then you can see if it works consistently on your system. If not, you can remove it again by running `omarchy hibernation remove`.

### Lid suspend guard

Closing the lid suspends the machine, which can land mid-task — an update (see #10203) or a coding agent run. Two safeguards keep the lid from interrupting work:

- Skip once: `Super + Alt + L` (or `omarchy toggle lid-suspend skip-once`) skips suspend for the next lid close only. The lid still locks, it just does not suspend. The skip is consumed when the lid re-opens and expires after 30 minutes.
- Automatic: while herdr reports a working agent, lid close never suspends. No herdr installed, no guard — the lid behaves exactly as before.

`omarchy toggle lid-suspend status` shows whether a skip is armed and whether the guard currently holds the lid.
