# System sleep

Omarchy enables suspend by default, but if you're having issues with it on your machine, you can toggle it off.

On NVIDIA GB10 machines, such as the DGX Spark and the ASUS Ascent GX10, suspend is turned off, as it is in NVIDIA's DGX OS, because sleep hasn't been shown to work on that hardware yet. The same goes for the ASUS Zenbook A16 (UX3607OA), where suspend doesn't yet put the chip fully to sleep and can hang overnight. The suspend toggle doesn't apply there. To turn sleep back on, remove `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` with `sudo rm`; Suspend then returns to the menu. Running `sudo omarchy apply hardware --install-user "$USER"` puts the file back.

### Power profiles

On a laptop, Omarchy remembers your power profile separately for plugged in and running on battery, and switches between the two as you plug and unplug. Out of the box that means performance on AC and balanced on battery.

You can see what your machine offers with `omarchy powerprofiles list`, and set the one you want for the state you're currently in with `omarchy powerprofiles set autodetect power-saver`. To set the other state without unplugging anything, name it directly: `omarchy powerprofiles set battery power-saver`. Whatever you pick is what you'll get back the next time you're in that state.

### Toggle suspend

You toggle suspend by running `omarchy toggle suspend` from the terminal. That just reveals/hides the option under _System_ (or `Super + Esc`), and then you can see if it works consistently on your system. If not, you can hide it again with the same command.
