# Hardware authentication

### Fingerprint authentication

On a computer with a supported reader, the installer offers to open _Fingerprint Setup_ at first login. You can also open it from _Setup > Security > Fingerprint_. On a Mac, open the lid to use the built-in Touch ID sensor. If the app asks you to prepare the reader, follow the platform's consent and backup instructions first.

Choose an unused finger and select _Enroll selected finger_. Follow the touch and lift prompts until the app confirms that the fingerprint was added. Select _Continue_ to see the saved fingers, add another, or verify one. To use an enrolled finger at the lock screen, choose _Enable fingerprint unlock_, verify a saved finger and confirm the administrator prompt. Lock the desktop with `Super + Ctrl + L`. Your password remains available.

For the terminal workflow that also configures `sudo` and system authorization prompts, run `omarchy setup security fingerprint`.

Once the lock screen has turned the display off, the sensor rests to save power, so wake the screen with any key or the touchpad before touching it.

When your laptop lid is closed, the fingerprint prompt is automatically skipped, so you go straight to the password prompt instead of waiting on a sensor you can't reach. If you otherwise need to work on an external keyboard that doesn't have a sensor, just hit `CTRL + C`, when you're prompted for your fingerprint during `sudo`.

You can remove the fingerprint authentication under _Remove > Security > Fingerprint_ in the Omarchy menu.

### Fido2 authentication

If you're using a Fido2 device, you can set it up for `sudo` authentication using _Setup > Security > Fido2_ in the Omarchy menu (`Super + Space`). It covers `sudo` and system authorization prompts, though, not unlocking your computer.

You can remove the fido2 authentication under _Remove > Security > Fido2_ in the Omarchy menu.
