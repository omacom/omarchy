# Moving to a new install

`omarchy transfer` carries your packages, settings and personal files from one Omarchy install to another. You pack everything into a single archive on the old machine (or before a reinstall), put it on a USB stick, and unpack it on the fresh install. It is built for the day you get a new laptop, swap the disk, or wipe and reinstall.

You find it under _Setup > Transfer_ in the Omarchy menu (`Super + Space`):

| Entry | What it does |
| ----- | ------------ |
| Export | Starts with three choices: _Export with Config_ packs everything the config currently selects, _Choose Step by Step_ walks you through what to bring, and _Open Config File_ opens the plain-text config |
| Import | Unpacks an archive on this machine and installs the packages from it |

The same things are available in the terminal as `omarchy transfer export` and `omarchy transfer import`.

## This is not a backup

Transfer is a one-time move, not a safety net. Three things on Omarchy can look similar, and they do different jobs:

| | What it covers | Where it lives | Use it for |
| - | -------------- | -------------- | ---------- |
| [System snapshots](47-system-snapshots.md) | The root filesystem (`/`), not your home | The same disk | Rolling back a broken update |
| Transfer | Packages, `~/.config`, shell files, keys and the folders you choose | An archive you carry away | Moving to a new install or disk |
| Off-site backup (planned, restic) | Your files over time, versioned | A remote storage account | Recovering from a dead disk, a lost laptop, an accidental delete |
| [Dotfiles](31-dotfiles.md) with Stow or git | Your config files only | A repository | Keeping settings in sync between machines |

A transfer archive is a single snapshot of the moment you made it. It is not versioned, it is not made on a schedule, and nothing watches it. If your disk dies tomorrow, an archive from last month is all you have. Do not treat it as your only copy of anything that matters. Snapshots never restore your `/home`, and transfer never restores the system, so they complement each other.

## Moving to a new install

### 1. On the old machine

1. Plug in a USB stick. Use one formatted as ext4 or exFAT. FAT32 cannot hold files over 4 GiB, and the export stops early with a message if your data would not fit.
2. Open _Setup > Transfer > Export_ and pick _Choose Step by Step_. Four pages follow: _Settings_, _Files_, _Keys & Secrets_ and _Options_. Tick what you want to bring on each page. The defaults cover `~/.config`, your shell files, `.gitconfig`, fonts, icons, SSH and GPG keys, and the folders `Documents`, `Pictures`, `Dev` and `Projects`.
3. Use _Next_ and _Back_ to move between pages, and _Start Export_ on the last page. (If the config is already how you want it, pick _Export with Config_ on the first screen instead.) It asks where to write: your Downloads folder comes first and is the default, your mounted USB sticks follow, or you can type another path.
4. If encryption is on you are asked for a passphrase twice. Write it down now.

Before it starts working it checks that there is enough free space on the stick and tells you what is going to be skipped. The archive is first written under a temporary name and only gets its final name once it is complete, so a half-written file never looks like a real archive. The result is a single file named `omarchy-transfer-<hostname>-<date>-<time>.tar.zst`, with `.age` added at the end when it is encrypted.

Next to the archive the export also writes two small files: `omarchy-transfer-restore.sh` and `omarchy-transfer-README.txt`. Copies of both are inside the archive too. Keep the archive and both files together, for example all three on the same stick. They are what lets you restore without Omarchy.

You can preview the export without writing anything:

```bash
omarchy transfer export --dry-run
```

### 2. Install Omarchy on the new machine

Do the normal Omarchy install. Connect to your network, log in, and update as usual.

### 3. Restore

Plug the stick in and run _Setup > Transfer > Import_. It looks for archives on mounted USB sticks, in your home folder and in `~/Downloads`, and lets you pick one. To look without changing anything first, run `omarchy transfer import --dry-run`. A restore then:

1. unpacks the archive into a private staging folder,
2. checks that it is intact and safe,
3. puts your files in place using the rules below,
4. installs your packages,
5. reloads Hyprland and shows a summary.

If anything fails, for example a package that no longer exists, the summary says so and the command exits with an error. Everything else is still restored.

## Restoring on another Linux

You do not need Omarchy to get your data back. There are three ways, from easiest to most manual:

1. **On Omarchy:** use _Setup > Transfer > Restore_ or `omarchy transfer import`, as described above.
2. **On any other Linux:** put the archive and `omarchy-transfer-restore.sh` in one folder and run `bash omarchy-transfer-restore.sh`. It finds the archive next to it, checks that `tar`, `zstd` and (for encrypted archives) `age` are installed, and shows the install command for your distribution if one is missing. It asks for the passphrase, unpacks the archive and puts your files in place. Existing files are never replaced: your version from the archive is saved as `<name>.transfer` next to them. Use `--dry-run` to look first, and `--mode=overwrite`, `--mode=skip` or `--mode=ask` to change that behavior.
3. **By hand:** for an encrypted archive run `age -d archive.tar.zst.age | tar --zstd -xf -`, for a plain one `tar --zstd -xf archive.tar.zst`. Or run `bash omarchy-transfer-restore.sh --extract-only <folder>` to unpack it safely into a folder. You get `home/` with your files, a visible `omarchy-transfer/` folder with the package lists, `README.txt` and `restore.sh`, and `wifi/` if you exported Wi-Fi networks. `omarchy-transfer-README.txt` explains each step in plain text. Archives made with older versions of Omarchy (hidden `.omarchy-transfer/` folder) are still accepted.

Omarchy's own settings only make sense on Omarchy. On another Linux they would break your shell or desktop, so the restore does not activate them. Files under `~/.config/hypr`, `omarchy`, `waybar` and similar, and files such as a `.bashrc` that load Omarchy defaults, are placed in `~/omarchy-transfer-configs/` instead. Look through them and copy over what you want.

Packages are only installed on Arch-based systems, where `pacman` exists. Anywhere else the restore writes `~/omarchy-transfer-packages.txt` with the list of package names, so you can look up the equivalents in your own distribution. Use `--no-packages` to skip the package step on Arch as well.

Keep the archive and both companion files (`omarchy-transfer-restore.sh` and `omarchy-transfer-README.txt`) together. Without the script you can still unpack by hand, but the script does the checks and the file handling for you.

## What happens when a file already exists

A fresh Omarchy install already contains its own versions of many files, such as the files in `~/.config`. The restore never blindly overwrites them. The default mode, called _smart_, decides file by file, in plain words:

1. **The file is not on the new machine yet.** It is added.
2. **The file is already the same.** Nothing happens. A link that points to identical content counts as the same, so a Stow setup is left alone.
3. **The file in the archive was just an untouched Omarchy default.** The one on the new machine is kept. This way old, outdated default settings do not come back and undo the improvements in the new Omarchy version.
4. **The file on the new machine is still the untouched default, and you had changed it on the old machine.** Your version wins. The default is saved next to it as `<name>.bak.<number>`.
5. **You changed the file on the new machine too.** The file on the new machine is kept. Your version from the archive is put next to it as `<name>.transfer`, and the summary lists it so you can compare the two and merge by hand.
6. **A file is in the way of a folder.** If the new machine has a plain file where the archive has a folder of that name, that path is skipped and listed in the summary.

You can pick a different mode with `--mode`:

| Mode | Behavior |
| ---- | -------- |
| `smart` | The rules above. This is the default. |
| `ask` | Shows a diff for each file that differs and asks: overwrite, skip, overwrite all (`A`) or skip all (`N`). Needs a terminal. Secret files are never shown in the diff. |
| `overwrite` | Replaces everything that differs. The old file is saved as `<name>.bak.<number>`. |
| `skip` | Never touches an existing file. Only adds what is missing. |

```bash
omarchy transfer import --mode=ask /run/media/$USER/STICK/omarchy-transfer-laptop-20260101-120000.tar.zst
```

Nothing is ever deleted. Files that exist only on the new machine stay as they are.

## Secrets, encryption and the passphrase

Your SSH keys, GPG keys, password store and saved keyrings are secrets. They are only exported when the archive is encrypted. With encryption off, they are left out and the export tells you so.

Encryption uses a passphrase that you type during export, and the same passphrase is asked for again at restore.

> **There is no way to recover a forgotten passphrase.** Nobody, including you, can open an encrypted archive without it. Write it down somewhere other than the stick, for example in your password manager, before you wipe the old machine.

A wrong passphrase, a damaged file or an archive that was tampered with is rejected before anything is changed on your machine.

## Wi-Fi networks

Saved Wi-Fi networks and their passwords can come along too. This needs `sudo` (the files are readable only by root), requires encryption, and is switched on by the Wi-Fi option on the _Options_ page of the Export steps. At restore time you have to ask for it explicitly:

```bash
omarchy transfer import --wifi
```

They go back to whatever your new install uses, NetworkManager or iwd.

## Choosing what to export

_Setup > Transfer > Export_ and _Choose Step by Step_ show one checklist per page: _Settings_, _Files_ (including any path you add yourself), _Keys & Secrets_ and _Options_ (packages, Wi-Fi, encryption). Pages without entries are skipped. A click turns one on or off, and the change is saved straight away. No terminal is needed.

Behind it is the config file `~/.config/omarchy/transfer.conf`, which you can open with _Open Config File_ on the first screen or on any page. The pages always read the config file, so both show the same. It is created from a commented default the first time you need it, and it explains itself. The essentials:

- `[options]` holds `packages`, `wifi` and `encrypt`, each `yes` or `no`.
- `[include]` lists folders and files relative to your home folder. To switch one off, put a `#` directly in front of it, like `#Pictures`. To add your own, add a line such as `Music`.
- `[exclude]` lists patterns that are never packed, such as caches and `node_modules`.
- A `#` followed by a space is an ordinary comment.
- Mail and browser profiles (Thunderbird, Chromium, Chrome, Brave, Vivaldi, Zen) are excluded by default to keep the archive small. Delete their lines under `[exclude]` to include them.
- The export warns when the data is over 3 GiB before compression.

Paths that do not exist are skipped quietly. Absolute paths and paths containing `..` are rejected.

## Troubleshooting

- **"Not enough space"**: free up room on the stick, or exclude large folders in the config. Use `--dry-run` to see the size first.
- **A package could not be installed**: the summary names it. Install it by hand later, or check whether it was renamed or removed. The rest of the restore is not affected.
- **Files ending in `.transfer` or `.bak.<number>`**: these are the versions the restore did not use. Compare them with the file next to them, keep what you want, and delete the rest.
- **Restore did something you did not want**: restore runs again safely. Files that are already the same are left alone, and `--mode=skip` never changes existing files.
