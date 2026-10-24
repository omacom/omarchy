# Hardware authentication

### Fingerprint authentication

A lot of laptops come with a fingerprint sensor to do authentication. You can use this with Omarchy by running _Setup > Security > Fingerprint_ in the Omarchy menu (`Super + Space`).

That'll install the fingerprint package, collect your print, verify it, and you'll be set to go using your fingerprint to unlock from the lock screen (which you can trigger with `Super + Ctrl + L`), enter sudo mode, and authorize system prompts.

Once the lock screen has turned the display off, the sensor rests to save power, so wake the screen with any key or the touchpad before touching it.

When your laptop lid is closed, the fingerprint prompt is automatically skipped, so you go straight to the password prompt instead of waiting on a sensor you can't reach. If you otherwise need to work on an external keyboard that doesn't have a sensor, just hit `CTRL + C`, when you're prompted for your fingerprint during `sudo`.

You can remove the fingerprint authentication under _Remove > Security > Fingerprint_ in the Omarchy menu.

### Sudo dialog for commands without a terminal

A coding agent, a launcher, or a background job often runs `sudo` without a terminal. There `sudo` can't ask for your password, and a fingerprint prompt has nowhere to show, so the command just waits or fails. Run _Setup > Security > Sudo Dialog_ in the Omarchy menu (`Super + Space`), and such a `sudo` asks in the same dialog system prompts use instead, with your fingerprint or password, and shows the command it's for. The dialog shows the first 60 characters, with each byte outside plain ASCII as `?`, and ends a longer one with how many characters it left out; the full command is in `journalctl -t omarchy-sudo-dialog`, so check it there before approving a long one. Cancelling the dialog stops that `sudo`. As in a terminal, once you've approved, `sudo` doesn't ask again for a few minutes for further commands started by the same parent process. A `sudo -S`, which reads the password from its input, is left alone.

A `sudo` you type in a terminal keeps asking there, as before, and the dialog only appears for your own desktop session, never over SSH.

You can remove it under _Remove > Security > Sudo Dialog_ in the Omarchy menu.

### Fido2 authentication

If you're using a Fido2 device, you can set it up for `sudo` authentication using _Setup > Security > Fido2_ in the Omarchy menu (`Super + Space`). It covers `sudo` and system authorization prompts, though, not unlocking your computer.

You can remove the fido2 authentication under _Remove > Security > Fido2_ in the Omarchy menu.
