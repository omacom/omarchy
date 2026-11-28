# Booting with systemd-boot

New UEFI x86 installs boot systemd-boot; older x86 installs boot Limine until `omarchy-boot-switch` moves them. Secure Boot on stock hardware needs a Microsoft-signed shim, and shim review's established second stages are GRUB and systemd-boot. This page is the reference for the systemd-boot side. BIOS installs stay on Limine, and Apple Silicon on its own platform package.

## Which loader a machine boots

`omarchy-boot-backend` prints `systemd-boot`, `limine` or `none`. `--managed` prints every loader whose boot images must be kept current, which is both of them while a switch is on trial. Code that changes the initramfs or the kernel command line goes through two commands that handle both loaders:

- `omarchy-boot-cmdline set NAME PARAMS...` / `unset NAME` / `get NAME`. On Limine this writes `/etc/limine-entry-tool.d/NAME.conf` as `KERNEL_CMDLINE[default]+=" PARAMS"`. On systemd-boot it writes `/etc/cmdline.d/NAME.conf` with the plain parameters. Before any loader tooling is installed, which is early in an install, it writes the Limine format.
- `omarchy-boot-rebuild [PKGBASE...]` rebuilds the boot images and exits non-zero on any failure. That includes `limine-mkinitcpio` reporting a kernel it couldn't build while still exiting 0.

Call those, never `limine-mkinitcpio`, `limine-update` or `mkinitcpio -P` directly.

## Boot images

On systemd-boot, every kernel build is a boot image.

- **What an image is.** The kernel, the initramfs and the command line in effect, kept in the boot store `/var/lib/omarchy/boot`. Each image has a `manifest` with `PKGBASE`, `KVER`, `CMDLINE` and `CREATED`.
- **The boot store.** A top-level btrfs subvolume, `@omarchy-boot`, mounted from `/etc/fstab`. A snapshot restore never rolls it back, and it sits on the encrypted root. Every writer checks it is really mounted there first.
- **The command line.** `/etc/kernel/cmdline`, then Omarchy's defaults (`default/boot/cmdline-defaults.conf`, unless `/etc/cmdline.d/omarchy-defaults.conf` replaces them), then `/etc/cmdline.d/*.conf` in name order. `omarchy-boot-sync cmdline` prints the result.

`omarchy-boot-sync` builds one UKI per image with `ukify` and publishes it as `$ESP/EFI/Linux/omarchy-<machine-id[0:8]>-<pkgbase>-<hash>.efi`.

- **Profiles.** The live system and every snapshot pinned to that image are profiles inside it. systemd-boot lists each profile as its own entry. A snapshot profile's command line points `rootflags=subvol=` at `@/.snapshots/N/snapshot` and adds `noresume`.
- **Entry IDs.** Profile 0 is named after the file. The others are `<file>@<profile ID>`.
- **Titles and order.** Each profile's `.osrel` carries the menu title (`PRETTY_NAME="Snapshot 12"`, `TITLE=<description> · <date>`) and its order (`IMAGE_VERSION`: the live system on top, then snapshots newest first).
- **Published state.** `$STORE/entries` maps profile IDs to entry IDs. The sync sets `loader.conf`'s `default` to the preferred kernel's live entry (`omarchy-boot-sync prefer PKGBASE`, used by `omarchy-kernel set`).
- **Writing and cleanup.** Images are written beside the old file and renamed over it, after checking ESP space. The sync deletes only its own namespace's files, and never the image a pending one-shot boot points at.

A snapshot is pinned to the image that was current when it was taken (`/.snapshots/N/omarchy-boot-image`), not just to a kernel version. Rolling back from a broken kernel, initramfs or command-line change therefore boots the old ones. Images stay while a pin, the current pointer, the backup or a pending restore needs them.

The pipeline:

- **Pacman.** `omarchy-boot-systemd` owns `/etc/pacman.d/hooks/90-mkinitcpio-install.hook` and `60-mkinitcpio-remove.hook`. They override mkinitcpio's with the same triggers and run `omarchy-boot-rebuild --pacman-install`/`--pacman-remove`. Both run after the transaction: a kernel upgrade removes the old version's `vmlinuz` too, and its image stays published until the new one is built. The sync drops the current image of a kernel that is no longer installed.
- **Omarchy initcpio hooks.** `omarchy-settings` installs `omarchy-snapshot-overlay` and `omarchy-restore` under `/etc/initcpio/{hooks,install}/` (which `mkinitcpio` searches ahead of `/usr/lib/initcpio/`) so routine settings upgrades do not fire `90-mkinitcpio-install.hook` when those hooks have not changed. Instead, `91-omarchy-initcpio-rebuild.hook` runs `omarchy-boot-sync-initcpio --pacman-hook`, which hashes `/etc/initcpio/{hooks,install}/omarchy-*` and `/etc/mkinitcpio.conf.d/*.conf` against `/var/lib/omarchy/initcpio.sha256` and runs `omarchy-boot-rebuild` only when the content actually changed.
- **Snapper.** The plugin `/usr/lib/snapper/plugins/20-omarchy-boot` pins each new root snapshot and starts `omarchy-boot-sync.service`. Snapper plugins must stay fast and not call snapper.
- **`omarchy snapshot create`.** Waits for the sync, so an update only goes ahead once its rollback point has a boot entry.
- **kernel-install.** Its `50-mkinitcpio` and `90-uki-copy` plugins are masked in `/etc/kernel/install.d/`, so nothing else publishes UKIs.

## The switch

`omarchy-boot-switch` records its phase in `$STORE/state`.

- **`staged`.**
  - The store is created.
  - The command line moves out of Limine's config: `/etc/default/limine` becomes `/etc/kernel/cmdline`, and each drop-in becomes `/etc/cmdline.d/<same name>.conf`.
  - The result is checked against `limine-entry-tool --get-cmdline`: the same parameters, with repeated ones in the same order.
  - systemd-boot is copied to `EFI/systemd/` next to Limine, and the images are built.
- **`trial`.** An NVRAM entry, "Omarchy Boot", is created and set as `BootNext`. Limine stays first in `BootOrder`, so a trial that fails falls back to Limine. `95-omarchy-boot-trial.hook` keeps the systemd-boot images current next to Limine's own hook.
- **`promoted`.** `omarchy-boot-confirm.service` saw systemd-boot start the live root, so the entry moves to the front of `BootOrder`.
- **`active`.** The next boot came through `BootOrder` itself. Then:
  - `omarchy-boot-systemd` replaces `omarchy-boot` and the Limine packages;
  - a recovery snapshot is taken and its entry verified;
  - the snapshots taken on Limine are deleted: they have no boot image, so systemd-boot can't start them and they can't be restored;
  - Limine's files, its per-snapshot copies and its NVRAM entry go;
  - `EFI/BOOT/BOOTX64.EFI` becomes systemd-boot if it was Limine's.

  Each step records itself in `final_step`, so an interrupted finish resumes.
- **`trial-failed`.** The trial or promotion didn't hold. Limine keeps booting, and running the switch again retries.

`omarchy-boot-switch revert` undoes everything before `active`. Snapshots taken before the switch have no systemd-boot entry and can't be restored, since their roots expect Limine, so the finish deletes them. Factory reset is unaffected: it clones `@factory`, a top-level subvolume that is not a snapper snapshot.

## Installed with systemd-boot

`omarchy-boot-switch install [--no-efi-register] [--no-fallback] [--prefer PKGBASE] [--initramfs PKGBASE=FILE]` sets up a machine that never had Limine, straight to `active`. The ISO runs it in the new root once every boot drop-in is written, after swapping the image's `omarchy-boot` for `omarchy-boot-systemd` and registering the "Omarchy Boot" entry itself. It:

- creates the store and its fstab line;
- takes `/etc/kernel/cmdline` (or `/etc/default/limine`'s command line, if that's all there is) and moves any drop-ins written in Limine's format to `/etc/cmdline.d/`;
- copies systemd-boot and `loader.conf` to the ESP, builds and verifies the images, and takes the fallback path unless told not to or another system's loader is there;
- with `--initramfs PKGBASE=FILE`, stores FILE as that kernel's initramfs instead of running mkinitcpio for it (`omarchy-boot-rebuild --initramfs`). The ISO passes the generic initramfs its root image carries, built without autodetect, when nothing on the machine changed what the initramfs is built from. A missing file or a kernel that isn't installed builds as usual, and the first kernel update builds the machine's own with autodetect;
- registers and puts first the NVRAM entry, unless the caller does.

`omarchy-boot-backend` recognises such a machine by `omarchy-boot-systemd`'s snapper plugin, even where the store isn't mounted (a factory clone). A factory reset of it runs the same install in the clone, into a fresh `@omarchy-boot-next` store that replaces the old owner's `@omarchy-boot` once the clone is at `@`; the old owner's images leave the ESP then too. BIOS installs keep Limine: systemd-boot can't start on BIOS firmware. `OMARCHY_ISO_BOOT_LOADER=limine` keeps a UEFI install on Limine.

Nothing offers the switch yet: no update prompt and no menu entry. `omarchy-boot-switch` runs it for anyone who asks. Once the Microsoft-signed shim ships, an update will offer it as "Upgrade to Secure Boot", together with the shim and Omarchy-signed kernels. `omarchy-boot-notify`, a user service at login, shows what the root side recorded (`notice_*` in the state).

## Restore

`omarchy snapshot restore N` (or `backup`) works from the live system or from a booted snapshot.

**Staging:** `omarchy-boot-sync restore-stage` writes a journal (`$STORE/restore/journal`), then:

1. snapshots the source to a writable `@restore-<tx>` at the btrfs top level;
2. records both roots by subvolume UUID, and the nested subvolumes directly under `@`;
3. publishes a maintenance profile carrying `omarchy.restore=<tx>`;
4. arms it as the one-shot entry.

It refuses while the swapfile holds a hibernation image, and blocks hibernation until the restore is done. When the swapfile's offset moved since the snapshot's image was built, it derives an image with the current `resume_offset` and fixes the staged root's own command line too.

**In the maintenance boot**, the `omarchy-restore` initramfs hook (a late hook, so after `resume`) unmounts the root it was about to boot and applies the journal with nothing running:

1. `@` becomes `@backup-<tx>`;
2. `@restore-<tx>` becomes `@`;
3. each nested subvolume moves onto its empty placeholder.

Every step checks what's already done, so power loss resumes, and a failure rolls back. With the same image as the running system (`SAME_IMAGE=1`) the hook mounts the new root and the boot continues. Otherwise it arms a one-shot of the restored root's own entry and reboots.

**On the first boot of the restored root,** `omarchy-boot-switch confirm` commits it:

- the restored image becomes current;
- the replaced root is recorded as the backup ("Before restore" in the menu);
- the backup before it is deleted.

`omarchy snapshot restore --cancel` drops a restore that's still pending.

The `omarchy-snapshot-overlay` hook boots read-only snapshots with a tmpfs overlay on top. It replaces `btrfs-overlayfs` on every install, Limine included.

## Not yet

- **Turning on Secure Boot.** Needs the Microsoft-signed Omarchy shim, `CONFIG_LOCK_DOWN_IN_EFI_SECURE_BOOT`, module signing (DKMS/NVIDIA) and MOK enrollment. `signing=required` in the state is where a signing key gets enforced: a missing key or a failed signature keeps the published images.
- **ARM hardware tests.** aarch64 machines (generic UEFI, Snapdragon, N1x, GB10) take the same path with the aa64 loader, Snapdragon's device trees from `/etc/kernel/uki.conf` in every image, and N1x's console parameters in `/etc/cmdline.d`. None has been booted on real hardware yet. The DGX Spark's Limine workaround (no UKI) isn't applied on systemd-boot, which doesn't claim the memory Limine frees.
- **Factory reset** on a machine that switched returns it to Limine, which the factory root was installed with. The reset runs `limine-install --no-efi-register` in the factory root and gives Limine a boot entry behind systemd-boot. Once the factory root is at `@`, it puts Limine first, makes Limine the fallback loader again if systemd-boot had taken it, and removes systemd-boot's entry and files, the old system's boot images, the boot store and any `@backup-*`/`@restore-*` roots. A reset that fails earlier leaves systemd-boot booting. The reset refuses while a switch is staged or on trial, and while a snapshot restore waits for its reboot.
