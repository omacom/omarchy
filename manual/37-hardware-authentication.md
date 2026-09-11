# Hardware authentication

### Fingerprint authentication

A lot of laptops come with a fingerprint sensor to do authentication. You can use this with Omarchy by running _Setup > Security > Fingerprint_ in the Omarchy menu (`Super + Space`).

That'll install the fingerprint package, collect your print, verify it, and you'll be set to go using your fingerprint to unlock from the lock screen (which you can trigger with `Super + Ctrl + L`), enter sudo mode, and authorize system prompts.

When your laptop lid is closed, the fingerprint prompt is automatically skipped, so you go straight to the password prompt instead of waiting on a sensor you can't reach. If you otherwise need to work on an external keyboard that doesn't have a sensor, just hit `CTRL + C`, when you're prompted for your fingerprint during `sudo`.

You can remove the fingerprint authentication under _Remove > Security > Fingerprint_ in the Omarchy menu.

### Fido2 authentication

If you're using a Fido2 device, you can set it up for `sudo` authentication using _Setup > Security > Fido2_ in the Omarchy menu (`Super + Space`). It covers `sudo` and system authorization prompts, though, not unlocking your computer.

You can remove the fido2 authentication under _Remove > Security > Fido2_ in the Omarchy menu.

### PIN authentication

If your machine has a TPM2 chip, you can set up a short PIN as a Windows Hello-style stand-in for your password by running _Setup > Security > PIN_ in the Omarchy menu (`Super + Space`). The PIN itself never leaves the TPM: it gates a secret sealed inside the chip, the chip enforces a hardware lockout after too many wrong guesses, and your password still works everywhere as a fallback.

That'll install the PIN package, ask you to enter and confirm a PIN right there in the terminal, and wire it up for logging in, `sudo`, polkit prompts, and unlocking the screen. If your machine logs you in automatically, PIN doesn't change that either way, since autologin never checks a password to begin with; it takes over the regular SDDM password prompt on any machine that still shows one.

You can remove PIN authentication under _Remove > Security > PIN_ in the Omarchy menu.
