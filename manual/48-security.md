# Security

Omarchy takes security extremely seriously. This is meant to be an operating system that you can use to do _Real Work_ in the _Real World_. Where losing a laptop can't lead to a security emergency. So here's what we do:

1. *Full-disk encryption is mandatory*: This is the most important step to securing the physical protection of your data. If your computer is lost or stolen, the data is fully encrypted using standard LUKS (Linux Unified Key Setup).
2. *Firewall is enabled by default*: All incoming traffic is blocked by default except for port 53317 for [LocalSend](https://localsend.org/). Even ssh is off until you turn it on via _Setup > Security > SSHD_, which opens port 22 (rate limited against brute force) as part of the setup. We even lock down Docker access using the [ufw-docker](https://github.com/chaifeng/ufw-docker) setup to prevent your containers from accidentally being exposed to the world.
3. *Arch always has the latest updates*: Arch, the underlying distro that Omarchy is built on, is a rolling distribution. This means that any security vulnerability that's discovered and patched in any package is quickly available for install using `omarchy-update`. You're always running the latest, most secure versions of everything that way.
4. *Omarchy maintains its own packages and mirror*: Omarchy only relies on packages from Arch's own core/extra/multilib repositories and its own Omarchy Package Repository by default. You can install software directly from AUR, but the base install doesn't — only a few optional installs, like the third-party browsers, pull from the AUR.
5. *Cloudflare protects us from DDoS*: Omarchy distribution infrastructure — the ISOs, the Omarchy packages, the Arch mirror — is protected behind Cloudflare's formidable DDoS shield and hosted on their CDN. This provides superb availability.

## Changing your passwords

You have two passwords on an encrypted install: the one that unlocks the drive at boot, and the one you log in and `sudo` with. Setup makes them the same. Both can be changed under _Update > Password_ in the Omarchy menu — _Drive Encryption_ for the first, _User_ for the second. Changing the drive password asks for the current one first, so have it handy. If a change is interrupted, run _Drive Encryption_ again: it asks for the password that unlocks the drive now and finishes the change.

## Application keyring

Applications can save passwords and tokens in the GNOME keyring. On a new installation, a password-based desktop login lets GNOME create and unlock an encrypted `login` keyring. Automatic desktop login after unlocking an encrypted disk is still supported: the first desktop session asks you to choose a keyring password in GNOME's own dialog. Choose a nonempty password and keep it safe. Matching your user password lets a later password-based login unlock the `login` keyring through PAM.

Automatic login, fingerprint login, and disk unlocking do not supply a user password to the keyring. GNOME may therefore ask you to unlock it when an application first needs saved credentials. _Setup > Security > Application Keyring_ or `omarchy-setup-security-keyring` also opens the native enrollment or unlock dialog.

Older Omarchy versions created an unencrypted `Default_keyring`. The update migration asks GNOME to encrypt that same collection in place, preserving its saved items and default alias. When GNOME asks for its old password, leave that field empty; choose a nonempty new password. Setup does not reset application credentials or choose a password for you. The legacy collection retains its name, so it still needs a native unlock prompt after login; PAM automatically unlocks the `login` collection only.

Cancelling setup, leaving the new password empty, or updating outside a graphical desktop leaves the encryption migration pending. Complete setup in your desktop session, then run `omarchy-migrate` again. The password dialog times out after two minutes and can be retried. A customized SDDM authentication configuration may need manual PAM review before the migration can continue.

Encryption protects the saved keyring while it is locked. Applications running as your user can access secrets after it is unlocked. Re-encrypting the current collection does not remove plaintext from existing backups or snapshots; handle those copies according to your retention policy.

## Passing on a machine you've already used

If you're handing your machine over to someone else, you don't have to reinstall it. Run _Setup > Reset Computer_ in the Omarchy menu, type `reset` to confirm, and reboot. That wipes every user account and everything in `/home`, throws away all the packages and system changes you made since installation, and clears the machine's identity — network connections, host keys, and all. What comes back up is the setup wizard from the first boot, ready for its new owner to enter their own name, password, and encryption password.

It works by restoring the baseline snapshot the installer takes, so it's only available on machines installed from the Omarchy ISO. And on a drive without encryption, a reset is deletion rather than a secure erase, so if the data was sensitive, do a fresh install instead.

## Passwordless sudo

Sometimes you want `sudo` to stop asking, most often when an AI agent is doing a long stretch of system work for you. _Setup > Security > Passwordless Sudo_ asks how long to allow access: **15 minutes**, **1 Hour**, **1 Day**, or **Permanently**. A red warning icon appears beside the other menu bar indicators while access is active. Click it or run the command again to turn access off. You can also pass your own number of minutes (from 1 to 1440) with `omarchy-sudo-passwordless 30`, or use `omarchy-sudo-passwordless permanent`.

Timed access expires automatically, including immediately after resuming from a suspend that crossed the deadline. Restarting the computer ends it early. Permanent access survives reboots and stays enabled until you disable it.

Updating or removing Omarchy's settings package ends any temporary grant before its expiry support changes. If the command reports an authorization or cleanup error, resolve it before trying to enable another grant; an error does not mean passwordless access is inactive.

Be clear-eyed about this one: while it's on, anything running as your user can do anything as root without being asked. That's the whole point, and it's also the whole risk.

## Signing Keys

The public key for all ISO signatures and Omarchy repo package is `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verify at openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). The `omarchy/omarchy-keyring` package contains this as well and will be used to rollout any potential updates seamlessly.

You can find the signature for any ISO release by adding .sig to the URL. Like https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
