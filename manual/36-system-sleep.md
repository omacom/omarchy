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

### Emergency battery protection

Omarchy watches a discharging laptop while the system is awake, including before login and after logout. At 5% hardware charge, or when the battery reports no more than 90 seconds left, it starts a 60-second shutdown countdown. One notification updates at the start, 30 seconds, 10 seconds, and shutdown. Save your work and connect a charger with enough power to stop the battery discharging; that cancels the countdown. A weak charger that cannot stop discharge does not cancel protection.

On systems with several batteries, protection uses their combined energy. If battery sizes are unavailable, every system pack must have a known charge at or below the threshold before low charge starts a countdown. Missing charge readings alone do not start protection, but a valid critical runtime estimate can. Once a countdown has started, missing or invalid readings do not pause it. Charging must be confirmed without another pack still discharging before the countdown is cancelled.

In the last 15 seconds, Omarchy asks Hyprland windows to close normally so applications can save or show save dialogs. Answer those dialogs promptly. The save period is part of the countdown, not extra time. At the deadline, normal system shutdown stops services and unmounts filesystems. If the battery reports insufficient runtime, the countdown is shortened to reserve 30 seconds for shutdown; there may be no time for window-close requests. Estimates are imperfect and cannot guarantee protection from sudden battery failure.

This protection shuts down the computer; it does not restore your running session. Unsaved work can be lost if an application does not save before shutdown, and a save dialog cannot postpone emergency shutdown indefinitely. Connecting power after windows have closed will cancel shutdown but will not reopen those windows. The guard does not monitor discharge while the machine is suspended.

The bar, power panel, and battery status command show usable charge with a small shutdown reserve: 5% hardware charge appears as 1%, 100% as 100%, and zero as zero. Charge-limit settings and protection thresholds still use hardware percentages. Other battery tools may therefore show a different percentage.
