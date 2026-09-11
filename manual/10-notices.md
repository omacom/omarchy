# Notices

You can quickly access the date and time, battery status, and current weather using the hotkey notices.

### Date & Time

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Weather

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

The location is detected from your IP address, which is usually close enough, but not always. You can pin it down with `omarchy weather location --set Malibu`, or be exact about it by adding coordinates: `omarchy weather location --set Malibu 34.0259,-118.7798`. Run `omarchy weather location` on its own to see where it thinks you are, and `--clear` to go back to auto-detection.

### Battery

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)

### Boot time

Every boot, once the desktop is up, Omarchy shows a notice with the time taken from power-on to the desktop starting, broken down by phase: firmware, boot loader, kernel, system startup, and desktop. It appears once per boot, so logging out and back in does not repeat it. Run `omarchy system boot time` in a terminal to see the figure again later.

If your disk is encrypted and you type the passphrase during boot, the time you spend typing it is counted in the kernel phase; there is no way to measure boot without it. On machines whose firmware does not report its own timing, the figure is counted from kernel start and the notice says so.
