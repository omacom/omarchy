# Hardware authentication

### Fingerprint authentication

A lot of laptops come with a fingerprint sensor to do authentication. You can use this with Omarchy by running _Setup > Security > Fingerprint_ in the Omarchy menu (`Super + Space`).

That'll install the fingerprint package, collect your print, verify it, and you'll be set to go using your fingerprint to unlock from the lock screen (which you can trigger with `Super + Ctrl + L`), enter sudo mode, and authorize system prompts.

Once the lock screen has turned the display off, the sensor rests to save power, so wake the screen with any key or the touchpad before touching it.

To keep fingerprint attempts available while the lock display is blank, set `fingerprintWhileBlank` to `true` on the `omarchy.lock` entry in the `plugins` array of `~/.config/omarchy/shell.json`. Add `{ "id": "omarchy.lock", "fingerprintWhileBlank": true }` if that entry is missing, preserving your other entries. The setting takes effect when the file changes. Set it to `false` or remove the setting to restore the default. This can use more power; it keeps normal retry and timeout limits, does not prevent suspend, and does not make a sleeping computer or a covered sensor respond to touch.

When your laptop lid is closed, the fingerprint prompt is automatically skipped, so you go straight to the password prompt instead of waiting on a sensor you can't reach. If you otherwise need to work on an external keyboard that doesn't have a sensor, just hit `CTRL + C`, when you're prompted for your fingerprint during `sudo`.

You can remove the fingerprint authentication under _Remove > Security > Fingerprint_ in the Omarchy menu.

### Fido2 authentication

If you're using a Fido2 device, you can set it up for `sudo` authentication using _Setup > Security > Fido2_ in the Omarchy menu (`Super + Space`). It covers `sudo` and system authorization prompts, though, not unlocking your computer.

You can remove the fido2 authentication under _Remove > Security > Fido2_ in the Omarchy menu.
