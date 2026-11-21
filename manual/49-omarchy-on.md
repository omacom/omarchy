# Omarchy on...

### Apple M1/M2 chips

[Asahi Alarm](https://asahi-alarm.org/) is a version of Arch for Apple M1/M2 computers built on top of [Asahi Linux](https://asahilinux.org/). You can get Omarchy running on top of that with some effort. See [the user-driven guide](https://github.com/omarchy-mac/omarchy-mac).

### Apple M5 chips

Asahi Alarm, and so the guide above, runs only on M1/M2. The M5 needs a newer kernel and boot loader, which the [Aurora Silicon](https://github.com/aurora-silicon) project is building:

- **M5 MacBook Air (13-inch and 15-inch):** Linux boots on all ten CPU cores with Aurora's [`aura`](https://github.com/aurora-silicon/aura) loader and its [`integration/aurora`](https://github.com/aurora-silicon/linux/tree/integration/aurora) kernel. Graphics acceleration is partial.
- **M5 MacBook Pro (14-inch):** same chip as the Air. Its board tree is the next one being brought up.
- **M5 Pro and M5 Max:** not booting yet. The extra CPU cores and the GPU don't start under Linux; [the bring-up issue](https://github.com/omacom/linux-aurora/issues/293) tracks why.

None of these install Omarchy the way the M1/M2 guide does yet. Hardware reports from M5 owners go to [omarchy-m-testing.org](https://omarchy-m-testing.org).

### Apple Virtual Machine

You can also install Omarchy inside a Parallels VM. Quite the cumbersome process, but there's [a user-driven guide](https://github.com/omacom/omarchy/discussions/452) for that too.

### VirtualBox

VirtualBox is a popular VM runner. [You can run Omarchy inside that too](https://github.com/omacom/omarchy/discussions/176). But performance probably won't be great.

### VMware Workstation on Windows 11

Another popular VM runner for Windows. [Omarchy has been setup inside of that as well](https://github.com/omacom/omarchy/discussions/572).

### Steam Deck

The Steam Deck runs on Arch, which means you can run Omarchy on your Steam Deck. Altynbek Orumbayev has [a full setup script and explanation on how to do it](https://github.com/aorumbayev/deckarchy). How cool is that!

### NixOS

Omarchy is really Arch + Hyprland, but Henry Sipp has [ported the essence of the setup to NixOS](https://github.com/henrysipp/omarchy-nix). So if you've been nix-pilled, here's a good starting point. It may or may not stay up-to-date with the latest Omarchy changes, but it's pretty cool none the less!

### Something else!

If you're trying to get Omarchy running on a configuration that isn't the default, you should join the #omarchy-on-other channel on [our community Discord](https://discord.gg/tXFUdasqhY).
