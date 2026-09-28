# Omarchy on...

### Apple M1/M2 chips

[Asahi Alarm](https://asahi-alarm.org/) is a version of Arch for Apple M1/M2 computers built on top of [Asahi Linux](https://asahilinux.org/). You can get Omarchy running on top of that with some effort. See [the user-driven guide](https://github.com/omarchy-mac/omarchy-mac).

### Apple Virtual Machine

You can also install Omarchy inside a Parallels VM. Quite the cumbersome process, but there's [a user-driven guide](https://github.com/omacom/omarchy/discussions/452) for that too.

### VirtualBox

VirtualBox is a popular VM runner. [You can run Omarchy inside that too](https://github.com/omacom/omarchy/discussions/176). But performance probably won't be great.

### VMware Workstation on Windows 11

Omarchy detects VMware guests. The installer adds `open-vm-tools` (display resizing, host time sync, host-driven power operations, shared folders) and starts the desktop at 1x, because the virtual display reports no physical size for Hyprland's automatic scaling to work from. Wayland apps run on software OpenGL (llvmpipe) inside VMware, because the vmwgfx driver hands Hyprland GPU buffers it cannot release, which kills every hardware-rendered app on its first frame until [hyprwm/aquamarine#360](https://github.com/hyprwm/aquamarine/issues/360) is fixed. Leave 3D acceleration enabled in the VM settings; Hyprland itself still uses it. The [original setup notes](https://github.com/omacom/omarchy/discussions/572) cover creating the VM on a Windows 11 host.

Multiple monitors work in VMware's full-screen mode: press `Ctrl + Alt + Enter`, then pick View > Cycle Multiple Monitors until every monitor is included. Omarchy follows the host's monitor arrangement, so the pointer lands where you point it, and blinks the displays once after each change so Workstation spans them. To manage the outputs yourself, set `omarchy_vmware_layout = false` in `~/.config/hypr/hyprland.lua` before the Omarchy defaults are loaded.

### Steam Deck

The Steam Deck runs on Arch, which means you can run Omarchy on your Steam Deck. Altynbek Orumbayev has [a full setup script and explanation on how to do it](https://github.com/aorumbayev/deckarchy). How cool is that!

### NixOS

Omarchy is really Arch + Hyprland, but Henry Sipp has [ported the essence of the setup to NixOS](https://github.com/henrysipp/omarchy-nix). So if you've been nix-pilled, here's a good starting point. It may or may not stay up-to-date with the latest Omarchy changes, but it's pretty cool none the less!

### Something else!

If you're trying to get Omarchy running on a configuration that isn't the default, you should join the #omarchy-on-other channel on [our community Discord](https://discord.gg/tXFUdasqhY).
