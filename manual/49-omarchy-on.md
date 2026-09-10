# Omarchy on...

### Apple M1/M2 chips

[Asahi Alarm](https://asahi-alarm.org/) is a version of Arch for Apple M1/M2 computers built on top of [Asahi Linux](https://asahilinux.org/). You can get Omarchy running on top of that with some effort. See [the user-driven guide](https://github.com/omarchy-mac/omarchy-mac).

### Apple Virtual Machine

You can also install Omarchy inside a Parallels VM. Quite the cumbersome process, but there's [a user-driven guide](https://github.com/basecamp/omarchy/discussions/452) for that too.

### VirtualBox

VirtualBox is a popular VM runner. [You can run Omarchy inside that too](https://github.com/basecamp/omarchy/discussions/176). But performance probably won't be great.

### VMware Workstation on Windows 11

Another popular VM runner for Windows. [Omarchy has been setup inside of that as well](https://github.com/basecamp/omarchy/discussions/572).

### Steam Deck

The Steam Deck runs on Arch, which means you can run Omarchy on your Steam Deck. Altynbek Orumbayev has [a full setup script and explanation on how to do it](https://github.com/aorumbayev/deckarchy). How cool is that!

### NixOS

Omarchy is really Arch + Hyprland, but the essence has been ported to NixOS:

- [omarchy-nix](https://github.com/henrysipp/omarchy-nix) — the first NixOS port.
- [omarchy-nixos](https://github.com/gaoqiaominfu/omarchy-nixos) — a pure NixOS system configuration (no flakes, no home-manager) that reproduces the Omarchy look & feel with waybar, rofi, mako, hyprlock and a ported SDDM theme, targeting NixOS 26.05.

So if you've been nix-pilled, these are good starting points. They may or may not stay up-to-date with the latest Omarchy changes, but they're pretty cool none the less!

### Something else!

If you're trying to get Omarchy running on a configuration that isn't the default, you should join the #omarchy-on-other channel on [our community Discord](https://discord.gg/tXFUdasqhY).
