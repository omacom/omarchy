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

**Always allow this device** trusts the same device identity across USB ports and hubs, including after reboot. Changes to its identity still require approval. A hub may need its own approval before devices connected through it become available.

Older approvals can be tied to a port or hub. Run `omarchy-setup-security-usb-authorization --review-existing` to review connected devices and confirm which should be trusted on any port. Existing rules are preserved. For a disconnected device, reconnect it and choose **Always allow this device** if prompted.

On a preinstalled machine that asks you to create your account at first boot, USB protection starts at the end of that setup. It trusts the devices connected then, so your keyboard works throughout account setup even if it differs from the installer's keyboard.

You can turn the protection off from _Remove > Security > USB Device Authorization_. _Setup > Security > USB Device Authorization_ turns it back on with the existing trusted-device policy.

Only approve hardware you recognize. A malicious USB device can forge the manufacturer, model, serial number, and device class shown during review. Permanent approval is a convenience for accessories you control, not proof of the device's identity.

The policy protects devices connected after USBGuard starts during boot. It does not replace operating-system and driver security updates, and USB devices needed before the service starts, such as a keyboard used to unlock an encrypted disk, remain governed by the kernel's boot-time policy.

For machines whose disk unlock and recovery never depend on any USB devices, _Setup > Security > USB at Boot_ can extend the block to the beginning of kernel boot. Omarchy adds every currently connected device to USBGuard's trusted policy, sets `usbcore.authorized_default=0`, and updates current and Limine snapshot boot entries. The trusted policy applies only once USBGuard starts: even a trusted USB keyboard remains unavailable at an earlier encrypted-disk password prompt.

Older snapshots created before USBGuard was installed and enabled keep all USB disabled even after startup, including keyboards, network adapters, and storage. Trusting the devices connected now does not make them available in those snapshots. Enable boot-time protection only if you can unlock and recover the machine without any USB devices. _Remove > Security > USB at Boot_ restores the normal early-boot behavior while keeping USBGuard active after startup.

With Secure Boot enabled, changing USB boot protection requires access to your signing keys and enough free space on the system drive for a temporary copy of the boot files. If signing fails, Omarchy restores the previous boot files and settings. If an image uses a custom measured-boot policy or multiple boot profiles, rebuild it with its original signing setup before retrying.

## Changing your passwords

You have two passwords on an encrypted install: the one that unlocks the drive at boot, and the one you log in and `sudo` with. Setup makes them the same. Both can be changed under _Update > Password_ in the Omarchy menu — _Drive Encryption_ for the first, _User_ for the second. Changing the drive password asks for the current one first, so have it handy. If a change is interrupted, run _Drive Encryption_ again: it asks for the password that unlocks the drive now and finishes the change. A child install has a third, the parent password, under _Update > Password > Parent_; see below.

## Child installs

Pick _Child_ at the installer's first question and the machine is set up for a kid with two passwords. The **kid password** is the account password: it logs in, unlocks the screen, and unlocks the disk at boot. The **parent password** is root's password, and it is what every privileged path asks for: `sudo`, system prompts, _Update > Omarchy_, every _Install_ and _Remove_ entry, the Windows VM and the Docker TUI, _Setup > Reset Computer_, passwordless sudo, the DNS toggle, and the timezone menu. The kid's account is not an administrator: it is kept out of the `wheel` group on purpose, so nothing that trusts that group reaches it, and _Setup > Security > Passwordless Sudo_ and _Sudoless Docker_, which would hand the account root without a password, are not offered on a child install. Everything that never needed root is the kid's to use: Bluetooth, themes, screenshots, printing, the apps, and the Wi-Fi networks the machine already knows.

Both passwords unlock the disk, and both open the lock screen and the login screen, so a parent can get into the kid's session, locked or logged out, without asking for the kid's password; the login is the kid's account either way. One limit: ten wrong tries lock the kid's account for two minutes, and during those two minutes the parent password waits too. If the kid forgets theirs, boot with the parent password and reset it from a terminal with `sudo passwd <kid>`, which asks for the parent password first. The kid can change their own login password under _Update > Password > User_ at any time; that does not change the disk password, same as on any install.

Joining a new Wi-Fi network, or changing one, asks for the parent password as well: that is a system setting, and NetworkManager only waves it through for administrators. When the kid needs to join a network alone, at school say, run `sudo omarchy-parent wifi kid`; `sudo omarchy-parent wifi parent` puts the prompt back, and `sudo omarchy-parent wifi` shows the setting. The choice lives as `wifi=` in `/etc/omarchy/parent.conf`, which a parent can also edit by hand and apply with `sudo omarchy-parent apply --user <kid>`. Either way, connecting to a network the machine knows, scanning, and the Wi-Fi switch never ask, and the DNS toggle keeps asking.

Change the parent password under _Update > Password > Parent_, or with `sudo omarchy-parent password` in a terminal. That changes root's password, not the disk slot that goes with it: to rotate that as well, run _Update > Password > Drive Encryption_ and type the old parent password when it asks for the current one.

Two things to know. `sudo` remembers a password for a few minutes in the terminal it was typed in, and system prompts remember an authorization for a similar spell, so close the terminal when you are done administering. And the split protects the running system, not the hardware: someone with a live USB and the kid's disk password can reset root's password from outside, so on a kid's laptop set a BIOS password and lock the boot order. A child install does not filter the web on its own; that is a separate layer.

Fingerprint unlock still works for the kid at the lock screen, but `sudo` and system prompts keep asking for the parent password, and FIDO2 setup is not offered because it only ever covered those two. Child installs also close the text consoles behind Ctrl+Alt+F2 through F6, so the lock screen is the only way back into a locked session; `sudo omarchy-parent tty on` reopens them.

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

## Thunderbolt device authorization

Omarchy requires approval before connecting new Thunderbolt and USB4 PCIe accessories on controllers that support authorization. Devices connected during initial setup are trusted. New devices show a persistent notification with **Allow once**, **Always allow this device**, and **Keep blocked**. Trusted devices reconnect automatically, including while the screen is locked. IOMMU memory protection stays enabled; it does not count as consent to load a device's driver.

On controllers in secure mode, permanent approval also saves the accessory's authentication key. If a connected accessory has no saved key during initial setup, Omarchy defers Thunderbolt protection and keeps the previous Bolt behavior so your keyboard and storage remain usable. A **Finish Thunderbolt protection setup** notification explains how to continue: keep input available independently of Thunderbolt, safely disconnect the accessories, enable protection, then reconnect and approve each one. Losing a previously saved secure key requires a new explicit approval; Omarchy does not silently create a replacement key while restoring trusted devices.

_Setup > Security > Thunderbolt_ enables protection. _Remove > Security > Thunderbolt_ restores the previous Bolt behavior, which may automatically approve new devices when IOMMU protection is available. Re-enabling keeps your saved trust list. Omarchy never disconnects active storage when changing these settings.

When you remove protection, devices enrolled by Omarchy for permanent approval reconnect through Bolt's automatic policy, keeping their secure keys. Devices with a manual Bolt policy from before setup retain that policy. Bolt also resumes managing firmware boot allowlists for automatically approved devices. Keep all Thunderbolt controllers connected during removal so Omarchy can restore their settings if the change fails.

Firmware can authorize PCIe accessories before Linux runs. A controller configured with security mode `none` bypasses software approval; select user authorization or secure authorization in its firmware settings. Omarchy reports these limitations instead of claiming that the controller is protected. Existing firmware boot allowlists can also authorize devices early. USB accessories attached through a dock require separate USB authorization.

Approval does not repair a vulnerable driver. Device names and identifiers can be forged; secure connection keys are used where Bolt and the hardware support them.

_Setup > Security > Thunderbolt Boot_ can clear and verify supported firmware boot allowlists. It captures connected accessories for authorization after Linux starts, prevents Bolt from repopulating those allowlists from automatic device policies, and retains the previous lists for _Remove > Security > Thunderbolt Boot_. This option requires every controller to be connected and to expose a boot allowlist in `user` or `secure` mode. Other hardware needs firmware settings instead; Omarchy cannot verify those settings automatically.

Enable this only if you can unlock and recover without any Thunderbolt accessories. Even a trusted keyboard or disk may remain unavailable until the policy service starts. Older snapshots and other operating systems can restore their own firmware permissions. A failed change restores the previous settings when possible; an incomplete restoration retains recovery data. Reconnect the original controllers and run `omarchy setup security thunderbolt-boot recover` to retry that recovery.

If enabling or removing device authorization fails and reports incomplete restoration, run `omarchy setup security thunderbolt-authorization recover` before trying again. This restores the configuration and service state saved before that change.
