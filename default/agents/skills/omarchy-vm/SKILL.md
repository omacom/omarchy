---
name: omarchy-vm
description: >
  Test things in a disposable Omarchy VM instead of on the machine you are working on.
  Use when a change is risky, when a plugin or theme needs trying on a clean desktop,
  when something must be verified on a bare Omarchy, or when the user says "try it in
  the VM". Covers omarchy vm install, launch, ssh, plugin, screenshots and snapshots.
---

# Omarchy VM

`omarchy vm` runs a throwaway Omarchy under QEMU/KVM. Everything in it may break: a snapshot puts it back, and a fresh one is a single command. Use it instead of the running machine whenever a change is risky or needs a clean desktop to prove itself on.

Run `omarchy vm` for the full command list. Use it rather than driving QEMU or ssh by hand, because it already knows the pitfalls below.

## Getting a guest

```bash
omarchy vm status                # is there one, and is it running?
omarchy vm install               # unattended, once, 15 to 30 minutes
omarchy vm snapshot save fresh   # baseline to return to (stop it first)
omarchy vm launch                # about 18 seconds to a desktop
```

`install` downloads and verifies the current ISO unless `--iso PATH` points at one. Take a snapshot straight after installing: `omarchy vm snapshot restore fresh` then undoes anything later.

## Working in the guest

```bash
omarchy vm ssh 'systemctl status sddm'   # as root
omarchy vm run 'hyprctl monitors'        # as the user, with its Wayland session
omarchy vm push ./file /tmp/
omarchy vm shot screen.png               # then look at the image
```

`ssh` is root and `run` is the desktop user; anything touching Hyprland, Quickshell or the clipboard needs `run`, because those need the session environment.

## Never put a secret in the guest

The guest has no disk encryption and passwordless sudo, both so it can start without anyone typing. Its disk is readable by anyone who reaches it, a qcow2 keeps deleted content around, and snapshots carry it along. So no keys, no tokens, no passwords, not even briefly.

When a command in there genuinely needs one of the user's keys, forward the agent instead:

```bash
omarchy vm agent git -C ~/project push
```

The guest can ask the agent to sign, never to hand a key over, and that access ends when the command returns.

## Looking at a guest that cannot answer

If SSH does not come up, do not guess and do not go hunting for the QEMU window. Ask QEMU itself:

```bash
omarchy vm screendump screen.png
omarchy vm sendkey ret
```

Both go over QEMU's QMP socket, so they work with no SSH, no session in the guest, and regardless of which workspace the window sits on. `sendkey` enters the virtual machine rather than the host desktop, so it cannot disturb what the user is doing.

`screendump` needs a software framebuffer, which GPU acceleration removes. `install` already runs without acceleration; elsewhere use `OMARCHY_VM_GL=0 omarchy vm launch`. `sendkey` always works.

## Testing a plugin

```bash
omarchy vm launch
omarchy vm plugin ~/path/to/plugin
omarchy vm shot screen.png
```

That copies the directory in, registers its bar widget from `manifest.json` and restarts the shell. Check the result with a screenshot rather than assuming. A panel can be opened without a mouse through the plugin's own IPC:

```bash
omarchy vm run 'qs -p /usr/share/omarchy/shell/shell.qml ipc call <plugin-id> open'
```

## Pitfalls

- Snapshot only a stopped VM. Copying a live disk gives an inconsistent image, so `snapshot save` refuses while it runs.
- Overwriting a snapshot needs `--force`, and so does `remove` without a terminal to confirm in.
- If `shot` hangs rather than fails, the guest screen is blanked and grim is waiting for a frame. `install` turns the screensaver off; `omarchy vm provision` restores that on an older guest.
- The guest takes its resolution from the window size once and never revisits it, so screenshots can come out the wrong shape. `omarchy vm resolution 1920x1080` sets guest and window together.
- Hyprland in the guest is Quattro, so `hyprctl dispatch` takes lua: `hl.dsp.focus({ workspace = 2 })`.
- Synthetic input inside the guest session (ydotool, wtype) is unreliable for proving a global keybinding works; drive those through `sendkey` or the plugin's IPC.
