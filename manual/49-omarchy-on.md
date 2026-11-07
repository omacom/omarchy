# Omarchy on...

### Apple M1/M2 chips

[Asahi Alarm](https://asahi-alarm.org/) is a version of Arch for Apple M1/M2 computers built on top of [Asahi Linux](https://asahilinux.org/). You can get Omarchy running on top of that with some effort. See [the user-driven guide](https://github.com/omarchy-mac/omarchy-mac).

### Apple Virtual Machine

You can also install Omarchy inside a Parallels VM. Quite the cumbersome process, but there's [a user-driven guide](https://github.com/omacom/omarchy/discussions/452) for that too.

### VirtualBox

VirtualBox is a popular VM runner. [You can run Omarchy inside that too](https://github.com/omacom/omarchy/discussions/176). But performance probably won't be great.

### VMware Workstation on Windows 11

Another popular VM runner for Windows. [Omarchy has been setup inside of that as well](https://github.com/omacom/omarchy/discussions/572).

### Steam Deck

The Steam Deck runs on Arch, which means you can run Omarchy on your Steam Deck. Altynbek Orumbayev has [a full setup script and explanation on how to do it](https://github.com/aorumbayev/deckarchy). How cool is that!

### ROG Ally (2023)

The original ASUS ROG Ally from 2023 (board RC71L, the model sometimes called Ally Normal, both the Ryzen Z1 and the Z1 Extreme) runs the Omarchy desktop. Handheld support is experimental: [Steam Deck, Legion Go and ROG Ally](https://omarchylinux.org/hardware/steam-deck-and-handhelds/). The ROG Ally X (RC72LA) is a different machine, and Omarchy does not apply this setup to it.

Omarchy recognizes the RC71L. The handheld has no lid, so docking and bringing the built-in screen back follow the laptop path. The 7-inch 1920x1080 panel advertises 120 Hz as its preferred mode. Scale and refresh are chosen in the display panel on the bar, the same way as on any other machine.

`asusctl` is not installed on this model. That program is for ROG laptops. On the Ally it conflicts with the programs that drive the controller, gyro, fans, TDP and stick RGB.

A gamescope Steam session is not part of Omarchy. [DeckShift](https://github.com/28allday/deckshift) is the current gaming mode for an Omarchy desktop: `Super + Shift + S` enters it, `Super + Shift + R` returns to Hyprland, and the bar panel opens with `Super + Shift + Alt + D`. Install it from that project. The older Super-Shift-S deck-mode scripts are retired.

Controller, gyro, TDP, fan and RGB setup is left to one handheld stack, installed by you. [Handheld Daemon](https://github.com/hhd-dev/hhd) still supports this Ally, and it must not be installed beside `asusctl`. Current Bazzite handheld images and CachyOS Handheld use InputPlumber and OpenGamepadUI instead, and that stack conflicts with Handheld Daemon. Use one of them.

### NixOS

Omarchy is really Arch + Hyprland, but Henry Sipp has [ported the essence of the setup to NixOS](https://github.com/henrysipp/omarchy-nix). So if you've been nix-pilled, here's a good starting point. It may or may not stay up-to-date with the latest Omarchy changes, but it's pretty cool none the less!

### Something else!

If you're trying to get Omarchy running on a configuration that isn't the default, you should join the #omarchy-on-other channel on [our community Discord](https://discord.gg/tXFUdasqhY).
