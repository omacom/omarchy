# Omarchy on...

### Apple M1/M2 chips

[Asahi Alarm](https://asahi-alarm.org/) is a version of Arch for Apple M1/M2 computers built on top of [Asahi Linux](https://asahilinux.org/). You can get Omarchy running on top of that with some effort. See [the user-driven guide](https://github.com/omarchy-mac/omarchy-mac).

### Apple Virtual Machine

You can also install Omarchy inside a Parallels VM. Quite the cumbersome process, but there's [a user-driven guide](https://github.com/omacom/omarchy/discussions/452) for that too.

### VirtualBox

VirtualBox is a popular VM runner. [You can run Omarchy inside that too](https://github.com/omacom/omarchy/discussions/7758), though graphics performance and guest integration have limitations.

#### Display settings and guest utilities

For an x86 VirtualBox guest, use the VMSVGA graphics controller with 3D acceleration enabled. A black desktop can still occur with these settings; distinguish a shell rendering failure from a compositor that never starts before changing the VM configuration.

In the installed guest, check the package and service directly:

```bash
pacman -Q virtualbox-guest-utils
systemctl is-active vboxservice.service
```

If the package is missing or the service is inactive, install the distribution package and enable its service:

```bash
omarchy pkg add virtualbox-guest-utils
sudo systemctl enable --now vboxservice.service
```

Use the package in the guest rather than installing another copy from the Guest Additions CD. A version reported by the host does not establish that the installed guest's service is running. A running service also does not guarantee every integration feature works under Wayland.

#### Black desktop with only a pointer

Switch to a text console with `Ctrl+Alt+F3` and log in as your normal user. If VirtualBox does not pass the shortcut through, use its soft keyboard. Enter `bash` before following the shell commands below if your normal shell is Nushell.

```bash
systemctl --user status wayland-wm@Hyprland.desktop.service --no-pager
hyprctl instances
journalctl --user -b -t omarchy-shell --no-pager -n 80
```

If Hyprland is running but the shell repeatedly exits with `Could not create EGL surface`, `eglSwapBuffers failed`, or a fatal Wayland `Invalid argument`, software OpenGL rendering can work around the VMSVGA client rendering failure. This does not diagnose every black screen: if there is no Hyprland instance, inspect the compositor's startup errors first.

From the text console, select the running instance. This example assumes there is only one; inspect `hyprctl instances` before selecting one when there are several.

```bash
export HYPRLAND_INSTANCE_SIGNATURE="$(hyprctl -j instances | jq -r '.[0].instance')"
hyprctl -r repl 'hl.env("LIBGL_ALWAYS_SOFTWARE", "1")'
omarchy restart shell
hyprctl layers
hyprctl configerrors
```

The background and `omarchy-bar` layers should appear. Return to the graphical console, usually `Ctrl+Alt+F1`, and check the wallpaper and top bar.

For subsequent logins, back up `~/.config/hypr/hyprland.lua` and add this after its bootstrap `dofile(...)`, **before** the line that loads `default.hypr.omarchy`:

```lua
hl.on("hyprland.start", function()
  hl.env("LIBGL_ALWAYS_SOFTWARE", "1")
end)
```

Setting the variable from this early start handler lets clients inherit it without forcing the compositor's initial renderer onto software OpenGL. Software rendering can increase CPU use and reduce graphics performance; it is a workaround, not a replacement for an upstream graphics fix. To remove it, delete the handler and log out and back in after saving your work.

#### Windows or panels do not fit

Check the monitor's resolution and scale with `hyprctl monitors`. A 1280×800 output at scale 2 has only 640×400 logical desktop space, so a larger floating window can extend beyond the screen. Monitor scale and `GDK_SCALE`, which affects GTK/XWayland applications, are separate settings.

On current Omarchy, choose scale 1 in the top bar's monitor panel, or use the CLI with the output name shown by `hyprctl monitors`:

```bash
omarchy hyprland monitor scaling --monitor Virtual-1 1
```

The panel saves the choice and adjusts GTK scaling. If the resolution is also too small, choose a supported mode in the panel; `hyprctl monitors all` lists the guest's modes. Do not assume every guest supports the same mode or output name. Applications already running may need to be reopened to adopt GTK scaling changes, and a floating window may need to be moved back on-screen.

If your older configuration explicitly sets `omarchy_gdk_scale = 2` or `GDK_SCALE` to 2 in `~/.config/hypr/monitors.lua`, back up the file and adjust that override as well. Avoid copying old wlroots environment-variable recipes into the current Lua configuration.

### VMware Workstation on Windows 11

Another popular VM runner for Windows. [Omarchy has been setup inside of that as well](https://github.com/omacom/omarchy/discussions/572).

### Steam Deck

The Steam Deck runs on Arch, which means you can run Omarchy on your Steam Deck. Altynbek Orumbayev has [a full setup script and explanation on how to do it](https://github.com/aorumbayev/deckarchy). How cool is that!

### NixOS

Omarchy is really Arch + Hyprland, but Henry Sipp has [ported the essence of the setup to NixOS](https://github.com/henrysipp/omarchy-nix). So if you've been nix-pilled, here's a good starting point. It may or may not stay up-to-date with the latest Omarchy changes, but it's pretty cool none the less!

### Something else!

If you're trying to get Omarchy running on a configuration that isn't the default, you should join the #omarchy-on-other channel on [our community Discord](https://discord.gg/tXFUdasqhY).
