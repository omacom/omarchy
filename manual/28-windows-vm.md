# Windows VM

Omarchy offers an easy way to run Windows through a Docker VM. You can install it using _Install > Windows_ from the Omarchy menu (`Super + Space`).

Your machine needs KVM virtualization for this, which most do — but it's sometimes switched off in the BIOS, and the installer will tell you if that's the case. You'll also want the disk space: whatever you give Windows, plus about 10GB for the image itself.

The installer asks how much RAM, how many CPU cores, and how much disk to hand over (64GB or more is the sensible floor), then for a Windows username and password. Leave those blank and you get `docker` / `admin`. The download takes a while — 10-15 minutes is normal — and you can follow the progress in the browser at `http://127.0.0.1:8006`. The browser prompts for the same username and password before opening the console.

The installer also asks whether to sign in automatically when the VM starts, and whether to join a Windows domain. Answering yes to the domain question changes what the following prompts mean: the account you enter becomes a **join account** — a domain user with rights to create computer objects, such as a domain admin or a delegated account — that performs an unattended domain join while Windows installs itself. No local Windows account is created in that case, so the installer then asks for the **domain user you actually want to sign in with** over RDP, and that is the login the launcher uses from then on. Joining a domain needs the domain controller to be reachable — with correct DNS — while Windows installs, so connect to your network or VPN before starting.

The browser console at `http://127.0.0.1:8006` always prompts for the account stored in the VM's configuration: the local Windows account for normal installs, and the **join account** for domain-joined ones — use it (not the RDP login user) when the console asks during installation, and whenever you peek at the screen afterwards.

Domain-joined VMs log on **inside** the RDP session instead of through a pre-logon exchange: when the session opens you get the Windows logon screen and type your domain credentials there (the pre-logon exchange NLA uses must round-trip to the domain controller, which high-latency VPN paths cannot do inside the connection's small timeouts). Pressing enter at the logon screen is enough on a fast network, but expect a pause on a VPN.

By default the installer grants **all authenticated domain accounts** the right to sign in over RDP on the VM (the same right console logons get), so any valid domain account works — not just the login user you entered. The grant is machine-local and the VM's ports are bound to localhost; to tighten it, remove `Authenticated Users` from the local `Remote Desktop Users` group inside the guest and add specific accounts instead.

 ![windows-vm](images/windows-vm.webp)

## Using it

Once it's installed, launch _Windows_ from the app launcher. That starts the VM if it isn't already running and connects you over RDP, full screen. Give it 15-30 seconds on a cold start.

The RDP session carries sound, your microphone, and a shared clipboard, so copying text between Linux and Windows just works. The resolution follows your window, and Omarchy passes your display scaling through, so it's not a blurry mess on a HiDPI screen.

When you close the RDP window, the VM shuts down automatically. If you'd rather leave it running — say you've got something working away in there — launch it with `omarchy windows vm launch --keep-alive` instead.

The rest of the controls are on the same command:

```bash
omarchy windows vm status       # is it running?
omarchy windows vm stop         # shut it down
omarchy windows vm launch       # start and connect
omarchy windows vm credentials  # change the login used for RDP
```

After a domain join — or any time the password changes — `omarchy windows vm credentials` updates what the launcher submits over RDP. It changes only that: no Windows, local, or domain password is modified. Acceptable forms are a bare name, `DOMAIN\name`, or `name@domain`.

## Sharing files

The directory `~/Windows` in your home directory is automatically shared with the VM. Put files there if you want them accessible to Windows. The VM has no access to any other part of your file system, so you're safe from anything nasty on the Windows side. Its own virtual disk is available at `~/.windows`.

Those familiar home paths stay on their own filesystems. They can also be symlinks to directories you own, which is useful when the virtual disk lives on a larger drive. The installer measures free space on the filesystem that actually contains `~/.windows`, not necessarily the filesystem containing your home directory.

Keep the disk and shared paths as separate, non-overlapping directories. Removal deliberately empties the disk directory but preserves the shared directory. Immediately before deletion, Omarchy performs a bounded containment check and refuses to remove anything if that check times out or cannot prove the two trees are separate.

Before the VM starts, Omarchy opens and pins those two directories, then bind-mounts the exact directory inodes onto private per-user anchors below `/var/lib/omarchy/windows/mounts`. Docker only sees those root-protected anchors. This preserves custom disk locations while preventing another process running as you from swapping a checked path before the privileged container consumes it. Existing disk and shared directories are tightened to mode `0700` during migration so other local accounts cannot browse their contents.

The VM's ports are bound to localhost only, so nothing on your network can reach the Windows machine. The web console also requires the configured Windows username and password, preventing another local account from driving the VM through port 8006.

## Limits and licensing

There's no GPU passthrough with this setup, so it's not suitable for gaming or video editing. It's a great way to run Microsoft Office or whatever else you absolutely must have.

The version installed is Windows 11 Pro, unactivated. You'll need your own license key to use the gated features.

If this computer shipped with Windows, the OEM key is still in firmware even after installing Omarchy. Print it with `omarchy windows key`. That key is bound to this machine — it will activate Windows reinstalled on this hardware, but it usually will not activate the VM.

You can change the resource allocation later by re-running `omarchy-windows-vm install`, which rewrites the VM's configuration from your answers. The domain join happens while Windows installs itself, so an existing VM that was set up without a domain needs to be reinstalled (or joined from inside Windows through Settings → System → About → Domain or workgroup). The compose file itself now lives at `/var/lib/omarchy/windows/docker-compose.yml` and is owned by root — that is deliberate, so a process running as you cannot rewrite it and have the privileged bring-up mount your whole disk into the container. If you need to hand-edit it (for example to mount a USB device), edit it with `sudo` and see all the options on [the Dockur Windows project](https://github.com/dockur/windows).

To get rid of the whole thing, use _Remove > Windows_ from the Omarchy menu. That deletes the VM's disk and all its data, so make sure anything you care about is out of `~/Windows` first.
