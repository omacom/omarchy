OMARCHY TRANSFER ARCHIVE
========================

This folder (or USB stick) holds a backup made with "omarchy transfer export":

  omarchy-transfer-<host>-<date>.tar.zst      your files and package lists
  omarchy-transfer-<host>-<date>.tar.zst.age  the same, encrypted with a
                                              passphrase (if you chose that)
  omarchy-transfer-restore.sh                 restore tool for any Linux
  omarchy-transfer-README.txt                 this file

Keep all of these together. The archive also contains its own copy of the
restore tool and of this file, so the archive alone is enough.

What is inside the archive:

  home/                Your files, as they were relative to your home folder.
  omarchy-transfer/    Information about the export: meta, package lists
                       (packages-official.txt, packages-aur.txt), the config
                       that was used, restore.sh and this README. When you
                       unpack the archive by hand, README.txt and restore.sh
                       are right here, next to home/.
  wifi/                Saved Wi-Fi networks. Only if you chose to include
                       them, and then the archive is always encrypted.

If the archive is encrypted you need the passphrase. There is no way to
recover it. Without it the data is gone.


WAY 1: ON OMARCHY (recommended)
-------------------------------

Install Omarchy, then either:

  - press Super + Space, choose Setup > Transfer > Restore, or
  - run in a terminal:

      omarchy transfer import /path/to/omarchy-transfer-<host>-<date>.tar.zst

Useful options:

  --dry-run        show what would happen, change nothing
  --wifi           also restore saved Wi-Fi networks
  --mode=MODE      smart (default), ask, overwrite or skip

Omarchy decides for every file: new files are added, identical files are left
alone, and if a file differs, yours is kept and the archived version is saved
next to it as <file>.transfer. Packages are installed too.


WAY 2: ON ANY OTHER LINUX
-------------------------

You need bash, tar and zstd (plus age if the archive is encrypted). The script
checks this itself. If something is missing it says what each tool is for and
offers to install it for you (pacman, apt, dnf or zypper). Just answer Y.

Open a terminal in this folder and run:

  bash omarchy-transfer-restore.sh

It finds the archive next to itself, asks for the passphrase if needed,
checks the archive and restores your files into your home folder. Never run it
as root; it uses sudo only where needed.

Options:

  --dry-run         show what would happen, change nothing
  --mode=MODE       what to do when a file already exists and differs:
                      keep       (default) keep yours, save the archived
                                 version as <file>.transfer
                      ask        show the difference and ask for each file
                      overwrite  replace it, keep the old one as
                                 <file>.bak.<time>
                      skip       never touch existing files
  --no-packages     do not install or list packages
  --wifi            restore saved Wi-Fi networks (needs sudo)
  --extract-only D  only check and unpack the archive into folder D
  --portable        never hand over to Omarchy's own restore
  --native          hand over to Omarchy's own restore (Omarchy only)

Things to know on a system that is not Omarchy:

  - Omarchy settings are NOT activated. Files that only make sense on Omarchy
    (Hyprland, Waybar, Walker, Mako and similar settings, and any file that
    refers to Omarchy, such as a .bashrc that loads Omarchy defaults) are
    copied to ~/omarchy-transfer-configs/ instead. They would break your shell
    or desktop. Look through them and copy over what you want.
  - Packages are installed only on Arch-based systems (pacman). AUR packages
    need yay or paru. Missing ones are listed.
  - On other systems no packages are installed. You get the list in
    ~/omarchy-transfer-packages.txt (Arch names; find the equivalents).
  - Wi-Fi networks go to NetworkManager or iwd. If neither runs, they are
    saved in ~/omarchy-transfer-wifi/ for you to copy by hand.
  - At the end you get a summary. The exit code is not zero if something
    failed.


WAY 3: BY HAND
--------------

You only need tar and zstd, and age if the archive is encrypted.

Encrypted archive:

  mkdir restored
  age -d omarchy-transfer-<host>-<date>.tar.zst.age \
    | tar --zstd -xf - -C restored

Plain archive:

  mkdir restored
  tar --zstd -xf omarchy-transfer-<host>-<date>.tar.zst -C restored

Or let the script do it safely, without restoring anything:

  bash omarchy-transfer-restore.sh --extract-only restored

Then look in the "restored" folder:

  restored/home/                 copy what you want into your home folder
  restored/omarchy-transfer/     README.txt, restore.sh, package lists
  restored/wifi/                 Wi-Fi profiles (if included)

Be careful with restored/home/.ssh and .gnupg: they hold your private keys.
Keep their permissions private (chmod 700 for the folders, 600 for the files).
