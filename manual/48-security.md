# Security

Omarchy takes security extremely seriously. This is meant to be an operating system that you can use to do _Real Work_ in the _Real World_. Where losing a laptop can't lead to a security emergency. So here's what we do:

1. *Full-disk encryption is mandatory*: This is the most important step to securing the physical protection of your data. If your computer is lost or stolen, the data is fully encrypted using standard LUKS (Linux Unified Key Setup).
2. *Firewall is enabled by default*: All incoming traffic is blocked by default except for port 53317 for [LocalSend](https://localsend.org/). Even ssh is off until you turn it on via _Setup > Security > SSHD_, which opens port 22 (rate limited against brute force) as part of the setup. We even lock down Docker access using the [ufw-docker](https://github.com/chaifeng/ufw-docker) setup to prevent that your containers are accidentally exposed to the world.
3. *Arch always have the latest updates*: Arch, the underlying distro that Omarchy is built on, is a rolling distribution. This means that any security vulnerability that's discovered and patched in any package is quickly available for install using `omarchy-update`. You're always running the latest, most secure versions of everything that way.
4. *Omarchy maintains its own packages and mirror*: Omarchy only relies on packages from Arch's own core/extra/multilib repositories and its own Omarchy Package Repository by default. You can install software directly from AUR, but the base install doesn't — only a few optional installs, like the third-party browsers, pull from the AUR.
5. *New USB devices require approval*: Omarchy trusts the USB devices present during installation, then blocks newly connected accessories until you approve them. This keeps an unknown accessory from reaching a matching kernel driver merely because it claims a supported device identity.
6. *Cloudflare protects us from DDoS*: All the Omarchy distribution infrastructure — the ISOs, the Omarchy packages, the Arch mirror — is protected behind Cloudflare's formidable DDoS shield and hosted on their CDN. This provides superb availability.

## USB Device Authorization

USB device authorization is enabled by default. Omarchy uses USBGuard to trust the devices connected during installation and block USB devices it has not seen before. When a device is blocked, click the persistent notification and choose whether to allow it once, always allow it, or keep it blocked.

You can turn the protection off from _Remove > Security > USB Device Authorization_. _Setup > Security > USB Device Authorization_ turns it back on with the existing trusted-device policy.

Only approve hardware you recognize. A malicious USB device can forge the manufacturer, model, serial number, and device class shown during review. Permanent approval is a convenience for accessories you control, not proof of the device's identity.

The policy protects devices connected after USBGuard starts during boot. It does not replace operating-system and driver security updates, and USB devices needed before the service starts, such as a keyboard used to unlock an encrypted disk, remain governed by the kernel's boot-time policy.

For machines whose disk unlock and recovery never depend on any USB devices, _Setup > Security > USB at Boot_ can extend the block to the beginning of kernel boot. Omarchy adds every currently connected device to USBGuard's trusted policy, sets `usbcore.authorized_default=0`, and updates current and Limine snapshot boot entries. The trusted policy applies only once USBGuard starts: even a trusted USB keyboard remains unavailable at an earlier encrypted-disk password prompt.

Older snapshots created before USBGuard was installed and enabled keep all USB disabled even after startup, including keyboards, network adapters, and storage. Trusting the devices connected now does not make them available in those snapshots. Enable boot-time protection only if you can unlock and recover the machine without any USB devices. _Remove > Security > USB at Boot_ restores the normal early-boot behavior while keeping USBGuard active after startup.

## Changing your passwords

You have two passwords on an encrypted install: the one that unlocks the drive at boot, and the one you log in and `sudo` with. Both can be changed under _Update > Password_ in the Omarchy menu — _Drive Encryption_ for the first, _User_ for the second. Changing the drive password asks for the current one first, so have it handy.

## Passing on a machine you've already used

If you're handing your machine over to someone else, you don't have to reinstall it. Run _Setup > Reset Computer_ in the Omarchy menu, type `reset` to confirm, and reboot. That wipes every user account and everything in `/home`, throws away all the packages and system changes you made since installation, and clears the machine's identity — network connections, host keys, and all. What comes back up is the setup wizard from the first boot, ready for its new owner to enter their own name, password, and encryption password.

It works by restoring the baseline snapshot the installer takes, so it's only available on machines installed from the Omarchy ISO. And on a drive without encryption, a reset is deletion rather than a secure erase, so if the data was sensitive, do a fresh install instead.

## Passwordless sudo

Sometimes you want `sudo` to stop asking, most often when an AI agent is doing a long stretch of system work for you. _Setup > Security > Passwordless Sudo_ turns that off for 15 minutes and then puts it back automatically. Run it again before the timer runs out to end it early, and pass your own number of minutes with `omarchy-sudo-passwordless 30` if 15 isn't enough. A restart removes the passwordless sudo rule as well.

Be clear-eyed about this one: while it's on, anything running as your user can do anything as root without being asked. That's the whole point, and it's also the whole risk.

## Signing Keys

The public key for all ISO signatures and Omarchy repo package is `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verify at openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). The `omarchy/omarchy-keyring` package contains this as well and will be used to rollout any potential updates seamlessly.

You can find the signature for any ISO release by adding .sig to the URL. Like https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
