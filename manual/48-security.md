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

On a preinstalled machine that asks you to create your account at first boot, USB protection starts at the end of that setup. It trusts the devices connected then, so your keyboard works throughout account setup even if it differs from the installer's keyboard.

You can turn the protection off from _Remove > Security > USB Device Authorization_. _Setup > Security > USB Device Authorization_ turns it back on with the existing trusted-device policy.

Only approve hardware you recognize. A malicious USB device can forge the manufacturer, model, serial number, and device class shown during review. Permanent approval is a convenience for accessories you control, not proof of the device's identity.

The policy protects devices connected after USBGuard starts during boot. It does not replace operating-system and driver security updates, and USB devices needed before the service starts, such as a keyboard used to unlock an encrypted disk, remain governed by the kernel's boot-time policy.

For machines whose disk unlock and recovery never depend on any USB devices, _Setup > Security > USB at Boot_ can extend the block to the beginning of kernel boot. Omarchy adds every currently connected device to USBGuard's trusted policy, sets `usbcore.authorized_default=0`, and updates current and Limine snapshot boot entries. The trusted policy applies only once USBGuard starts: even a trusted USB keyboard remains unavailable at an earlier encrypted-disk password prompt.

Older snapshots created before USBGuard was installed and enabled keep all USB disabled even after startup, including keyboards, network adapters, and storage. Trusting the devices connected now does not make them available in those snapshots. Enable boot-time protection only if you can unlock and recover the machine without any USB devices. _Remove > Security > USB at Boot_ restores the normal early-boot behavior while keeping USBGuard active after startup.

With Secure Boot enabled, changing USB boot protection requires access to your signing keys and enough free space on the system drive for a temporary copy of the boot files. If signing fails, Omarchy restores the previous boot files and settings. If an image uses a custom measured-boot policy or multiple boot profiles, rebuild it with its original signing setup before retrying.

## Changing your passwords

You have two passwords on an encrypted install: the one that unlocks the drive at boot, and the one you log in and `sudo` with. Both can be changed under _Update > Password_ in the Omarchy menu — _Drive Encryption_ for the first, _User_ for the second. Changing the drive password asks for the current one first, so have it handy.

## Passing on a machine you've already used

If you're handing your machine over to someone else, you don't have to reinstall it. Run _Setup > Reset Computer_ in the Omarchy menu, type `reset` to confirm, and reboot. That wipes every user account and everything in `/home`, throws away all the packages and system changes you made since installation, and clears the machine's identity — network connections, host keys, and all. What comes back up is the setup wizard from the first boot, ready for its new owner to enter their own name, password, and encryption password.

It works by restoring the baseline snapshot the installer takes, so it's only available on machines installed from the Omarchy ISO. And on a drive without encryption, a reset is deletion rather than a secure erase, so if the data was sensitive, do a fresh install instead.

## Passwordless sudo

Sometimes you want `sudo` to stop asking, most often when an AI agent is doing a long stretch of system work for you. _Setup > Security > Passwordless Sudo_ turns that off for 15 wall-clock minutes and then puts it back automatically, including immediately after resuming from a suspend that crossed the deadline. A package-owned boot-time cleanup rule removes the grant before logins if the computer restarts first. Run the command again before the timer runs out to end it early, and pass your own number of minutes (from 1 to 1440) with `omarchy-sudo-passwordless 30` if 15 isn't enough.

Updating or removing Omarchy's settings package ends any temporary grant before its expiry support changes. If the command reports an authorization or cleanup error, resolve it before trying to enable another grant; an error does not mean passwordless access is inactive.

Be clear-eyed about this one: while it's on, anything running as your user can do anything as root without being asked. That's the whole point, and it's also the whole risk.

## Signing Keys

The public key for all ISO signatures and Omarchy repo package is `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verify at openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). The `omarchy/omarchy-keyring` package contains this as well and will be used to rollout any potential updates seamlessly.

You can find the signature for any ISO release by adding .sig to the URL. Like https://iso.omarchy.org/omarchy-x.x.x.iso.sig.

## Thunderbolt device authorization

Omarchy requires approval before connecting new Thunderbolt and USB4 PCIe accessories on controllers that support authorization. Devices connected during initial setup are trusted. New devices show a persistent notification with **Allow once**, **Always allow this device**, and **Keep blocked**. Trusted devices reconnect automatically, including while the screen is locked. IOMMU memory protection stays enabled; it does not count as consent to load a device's driver.

On controllers in secure mode, permanent approval also saves the accessory's authentication key. If a connected accessory has no saved key during initial setup, Omarchy defers Thunderbolt protection and keeps the previous Bolt behavior so your keyboard and storage remain usable. A **Finish Thunderbolt protection setup** notification explains how to continue: keep input available independently of Thunderbolt, safely disconnect the accessories, enable protection, then reconnect and approve each one. Losing a previously saved secure key requires a new explicit approval; Omarchy does not silently create a replacement key while restoring trusted devices.

_Setup > Security > Thunderbolt_ enables protection. _Remove > Security > Thunderbolt_ restores the previous Bolt behavior, which may automatically approve new devices when IOMMU protection is available. Re-enabling keeps your saved trust list. Omarchy never disconnects active storage when changing these settings.

Firmware can authorize PCIe accessories before Linux runs. A controller configured with security mode `none` bypasses software approval; select user authorization or secure authorization in its firmware settings. Omarchy reports these limitations instead of claiming that the controller is protected. Existing firmware boot allowlists can also authorize devices early. USB accessories attached through a dock require separate USB authorization.

Approval does not repair a vulnerable driver. Device names and identifiers can be forged; secure connection keys are used where Bolt and the hardware support them.

_Setup > Security > Thunderbolt Boot_ can clear and verify supported firmware boot allowlists. It captures connected accessories for authorization after Linux starts, prevents Bolt from repopulating those allowlists from automatic device policies, and retains the previous lists for _Remove > Security > Thunderbolt Boot_. This option requires every controller to be connected and to expose a boot allowlist in `user` or `secure` mode. Other hardware needs firmware settings instead; Omarchy cannot verify those settings automatically.

Enable this only if you can unlock and recover without any Thunderbolt accessories. Even a trusted keyboard or disk may remain unavailable until the policy service starts. Older snapshots and other operating systems can restore their own firmware permissions. A failed change restores the previous settings when possible; an incomplete restoration retains recovery data. Reconnect the original controllers and run `omarchy setup security thunderbolt-boot recover` to retry that recovery.

If enabling or removing device authorization fails and reports incomplete restoration, run `omarchy setup security thunderbolt-authorization recover` before trying again. This restores the configuration and service state saved before that change.
