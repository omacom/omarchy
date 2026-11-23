# System snapshots

We create snapshots automatically on every Omarchy update, but should you want to create your own, you can use `omarchy-snapshot create`.

To boot and restore a snapshot, you select it from the Limine boot loader. The boot menu stays hidden by default, so press any key as soon as Limine starts to bring it up.

From that screen, choose the snapshot you'd like to boot into based on the date and version. The version of Omarchy at the time of the snapshot can be seen at the bottom left corner.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

When you arrive inside, a notification will popup notifying you that you're in a bootable snapshot and if you click it, will start the restoration process. Alternatively, you can utilize `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

This will restore your root filesystem, but not your `/home`. So it works for reverting a broken system update, but not for recovering lost personal files. Those come back from a different kind of snapshot, covered under [Bringing back deleted files](#bringing-back-deleted-files) below.

This also means that your `~/.config` directory is kept as-is. So if you're rolling back to an earlier version of a library or application that stores configuration files in a new format, you'll have to sort that out manually.

The same goes for Omarchy's own record of which migrations have already run: it lives in your home directory, so it survives the restore. Migrations that ran after the snapshot was taken stay marked as done, even though the changes they made to the root filesystem have been rolled back, and the next `omarchy update` won't run them again. So if you update again after a restore and something an earlier update had set up is still missing, that's the likely reason.

_Note: This feature is only available on installations using the Limine boot loader, which has been the default since Omarchy 2.0. It's not available if you're on GRUB or systemd-boot._

## Bringing back deleted files

Your home folder gets a snapshot of its own every hour. They never roll anything back; they're there so a file you deleted by mistake can be brought back. Omarchy keeps the last day of hourly snapshots, a week of daily ones, and four weekly ones, and thins them to the last six hours and two days when free space drops below a fifth of the disk, since a snapshot holds on to what you deleted until it goes.

In Files, the Snapshots section of the sidebar opens Deleted Files: everything a snapshot still holds that's gone from your home folder now, the most recent first. Pick one and press Enter to put it back where it was. A folder comes back whole, and if you bring back just one file out of a deleted folder, the rest of it stays in the list.

From the terminal, `omarchy snapshot files deleted` lists the same, for your whole home folder or one folder in it, and `omarchy snapshot files restore ~/Documents/taxes.pdf` puts one back. It never overwrites a file that's there, and a file you moved or renamed doesn't count as deleted. A file from a folder you've since renamed comes back under the folder's old name.

Hidden files like `.env` are listed, but hidden folders like `~/.cache` and `~/.config` are not, nor are editors' swap and lock files, and dependencies and build output (`node_modules`, and folders marked with a `CACHEDIR.TAG`), which come back on their own. All of it is still in the snapshots, under `/home/.snapshots/<number>/snapshot/`, so you can copy a lost config file, or an earlier version of a file you overwrote, out by hand.

Each snapshot keeps your files with the permissions they had when it was taken. Your home folder is yours alone, so other people on the machine can't read your snapshots, but if you shared a folder with them and later stopped, they can still read it in the snapshots from before, until those are gone. Likewise, a file you deleted, a key or a password, say, stays readable to you, and to programs running as you, until the last snapshot holding it is thinned out.

Nothing running as you can delete these snapshots, so they survive a mistake, or a program that deletes your files, though one that also fills your disk gets them thinned to the last two days. They're not a backup: they live on the same disk, so a dead or stolen machine takes them with it.
