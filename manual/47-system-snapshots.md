# System snapshots

We create snapshots automatically on every Omarchy update, but should you want to create your own, you can use `omarchy-snapshot create`.

How you boot and restore a snapshot depends on the boot loader your machine starts with. Machines installed with Omarchy use Limine. On x86 you can move to systemd-boot, the boot loader Secure Boot needs, with _Setup > Switch to systemd-boot_ (see below). `omarchy-boot-backend` tells you which one you have.

## With systemd-boot

Pick _System > Snapshots_ in the Omarchy menu and choose the snapshot you'd like to boot into. The machine restarts into it once. Or hold Space while the machine starts to see the boot menu, where every snapshot is listed newest first with its Omarchy version and date.

A snapshot boots with a temporary layer on top, so you can use it as normal, but anything you change is gone at the next reboot. To keep it, make it your system: click the notification that appears when you log in, pick _System > Restore This Snapshot_, or run `omarchy-snapshot restore`. The restore happens while the machine restarts. The system as it was before stays in the boot menu as _Before restore_, and `omarchy-snapshot restore backup` puts it back.

From the terminal:

- `omarchy-snapshot list` lists the snapshots you can boot;
- `omarchy-snapshot boot 12` restarts into snapshot 12 once;
- `omarchy-snapshot restore 12` makes snapshot 12 the system at the next restart, and `omarchy-snapshot restore --cancel` changes your mind before that restart.

Snapshots taken before the switch to systemd-boot stay on disk, but can't be booted or restored: they belong to the Limine setup.

### Switching from Limine

_Setup > Switch to systemd-boot_ (or `omarchy-boot-switch`) checks the machine first and explains anything that stands in the way. The switch is careful about it:

1. systemd-boot is set up next to Limine, and the machine restarts into it once. If that start fails or hangs, resetting the machine brings back Limine.
2. Once systemd-boot has started Omarchy, it becomes the default; Limine stays as the fallback.
3. After one more restart proves the firmware starts systemd-boot on its own, Limine is removed and a fresh snapshot is taken.

Until that last step, `omarchy-boot-switch revert` puts everything back the way it was. Other operating systems on the same disk show up in systemd-boot's menu when they're Windows; anything else is reached from the firmware's boot menu. A factory reset after the switch returns the machine to Limine, which it was installed with; a machine installed with systemd-boot stays on it.

## With Limine

To boot and restore a snapshot, you select it from the Limine boot loader. The boot menu stays hidden by default, so press any key as soon as Limine starts to bring it up.

From that screen, choose the snapshot you'd like to boot into based on the date and version. The version of Omarchy at the time of the snapshot can be seen at the bottom left corner.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

When you arrive inside, a notification will popup notifying you that you're in a bootable snapshot and if you click it, will start the restoration process. Alternatively, you can utilize `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## What a restore covers

A restore brings back your root filesystem, but not your `/home`. So it works for reverting a broken system update, but not for recovering lost personal files.

This also means that your `~/.config` directory is kept as-is. So if you're rolling back to an earlier version of a library or application that stores configuration files in a new format, you'll have to sort that out manually.

The same goes for Omarchy's own record of which migrations have already run: it lives in your home directory, so it survives the restore. Migrations that ran after the snapshot was taken stay marked as done, even though the changes they made to the root filesystem have been rolled back, and the next `omarchy update` won't run them again. So if you update again after a restore and something an earlier update had set up is still missing, that's the likely reason.
