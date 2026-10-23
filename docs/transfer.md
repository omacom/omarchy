# Transfer

Reference for `omarchy transfer`: the commands that pack packages, configs and personal files into one archive and restore them on a new install. The user-facing guide is [`manual/52-transfer.md`](../manual/52-transfer.md). This page covers how it is built.

Transfer is a one-shot migration tool. It is not the planned restic backup (`plans/backup.md`, which will own the `omarchy-backup-*` names), not a snapshot (`omarchy-snapshot` covers `/` only), and not a dotfile sync.

## Commands

All live in `bin/` and are routed as `omarchy transfer <command>`. The group description sits in `GROUP_DESCRIPTIONS` in `bin/omarchy`.

| Command | Purpose |
| ------- | ------- |
| `omarchy-transfer-functions` | Hidden library, sourced by the others. Config parser and writer, secrets list, size formatting, cleanup traps, Wi-Fi backend detection, default-file lookup. Exits 64 when executed. |
| `omarchy-transfer-export [--dry-run] [<target-dir>]` | Writes the archive. Without a target, gum offers `~/Downloads` (the default, via `xdg-user-dir DOWNLOAD`) first, then the mounted drives under `/run/media/$USER/*`, plus "Other path…". |
| `omarchy-transfer-import [--dry-run] [--wifi] [--mode=smart\|ask\|overwrite\|skip] [<archive>]` | Restores an archive. Without an archive, gum lists those found on removable media, in `~` and in `~/Downloads`. |
| `omarchy-transfer-select` | The menu's Export entry, a wizard of `omarchy-menu-select` calls. See "Export wizard" below. |
| `omarchy-transfer-config` | Creates the config from the default if missing, then opens it with `omarchy-launch-config-editor`. |

The menu entries are under `setup.transfer` in `default/omarchy/omarchy-menu.jsonc`: Export (the wizard) and Import.

## Export wizard

`omarchy-transfer-select` starts on a single-select page (`--width 440`, prompt `Export`) with three rows: `Export with Config` runs the export now from the config as it is, `Choose Step by Step` opens the pages, `Open Config File` runs `omarchy-transfer-config`. Launches go through `setsid -f`, so the menu closing does not kill them; the export runs as `omarchy-launch-floating-terminal-with-presentation omarchy-transfer-export`.

The step pages are multi-select checklists (prompt `Export <n>/<total> · <title>`) with `--action` rows: `Next` (`Start Export` on the last page), `Back` (not on page 1) and `Open Config File`. Escape aborts. A page with no entries is skipped and the rest renumbered. The config is re-read before every page, so manual edits show up.

| Page | Entries |
| ---- | ------- |
| Settings | `.config` and below, `.local/share/applications`, `fonts`, `icons`, `.bashrc`, `.bash_profile`, `.zshrc`, `.profile`, `.inputrc`, `.gitconfig` |
| Files | Every other include, so `Documents`, `Pictures`, `Dev`, `Projects` and any path you add yourself |
| Keys & Secrets | Anything `transfer_is_secret` matches |
| Options | `packages`, `wifi`, `encrypt` |

`transfer_category` in the script is the single place that maps a path to `settings`, `files` or `secrets`; the config format has no page markers.

Every click runs `omarchy-transfer-select --apply <page> <json>` through `--on-change`. The handler touches only the entries (or options, on the Options page) that belong to that page, so unticking on one page never changes another. It makes one `jq` call and writes only lines that changed.

Sizes: when the wizard begins it starts one background `du` pass (`timeout 2 du -sh`, parallel) writing to a `mktemp` file under `$XDG_RUNTIME_DIR` (or `/tmp`), removed on exit. Pages read whatever has arrived and show `size unknown` for the rest; the start page never waits.

## Config

`~/.config/omarchy/transfer.conf` is created from `default/omarchy/transfer.conf` the first time a command needs it (`transfer_ensure_conf`). The feature is opt-in, so there is no skel seeding and no migration. The shipped default is the documentation: a header block and a comment above every entry.

It is an INI file with three sections, matched case-insensitively:

- `[options]` has `packages`, `wifi` and `encrypt`. Values: `yes`/`no`, `true`/`false`, `1`/`0`, `on`/`off`.
- `[include]` has paths relative to `$HOME`, one per line. Absolute paths and any `..` are rejected. A trailing `/` is stripped. Missing paths are skipped silently.
- `[exclude]` has tar glob patterns. They apply to everything included, and are generated in both the `x` and `./x` forms so they hit however the include was written.

A line is a comment only when it starts with `#`, so `dir#x` is a valid path. A disabled include is the path behind a `#` with no space (`#Pictures`). A `#` followed by a space is an ordinary comment. The parser runs with globbing off, so a pattern like `*/cache2` stays literal.

The writer functions, `transfer_conf_set_include <path> on|off` and `transfer_conf_set_option <key> yes|no`, change only the one line they own: they add or remove the leading `#`, or rewrite the value. Comments and order are preserved byte for byte, and the file is replaced atomically (temp file plus `mv`). `transfer_conf_entries` lists every include with its state for the GUI.

Secrets (`.ssh`, `.gnupg`, `.password-store`, `.local/share/keyrings`, see `TRANSFER_SECRETS`) are dropped from the export unless `encrypt = yes`, even when they are listed under `[include]`. Wi-Fi needs `wifi = yes` and `encrypt = yes`.

## Archive format v2

One stream: `tar` into `zstd -T0 -3 --check`, then optionally `age -p`. File name: `omarchy-transfer-<host>-<YYYYmmdd-HHMMSS>.tar.zst`, with `.age` appended when encrypted. Import finds archives with the glob `omarchy-transfer-*.tar.zst*` and recognizes an encrypted one by the `.age` suffix or the age magic bytes.

| Member | Content |
| ------ | ------- |
| `omarchy-transfer/meta` | `key=value` lines: `format=2`, `omarchy_version`, `date`, `host`, `user`, `home` (absolute path at export), `encrypted`, `wifi` (`networkmanager`, `iwd` or `none`) |
| `omarchy-transfer/packages-official.txt` | Explicitly installed official packages, one per line, `*-debug` removed. Only with `packages = yes` |
| `omarchy-transfer/packages-aur.txt` | Same for AUR packages |
| `omarchy-transfer/pristine.list` | `$HOME`-relative regular files that were byte-identical to their shipped default at export time |
| `omarchy-transfer/transfer.conf` | The config the export used |
| `omarchy-transfer/restore.sh` | Copy of `default/transfer/restore.sh`, the standalone restore tool (mode 0755). Skipped with a warning if the source file is missing |
| `omarchy-transfer/README.txt` | Copy of `default/transfer/README.txt`, plain-text instructions for all three restore paths. Skipped with a warning if missing |
| `wifi/networkmanager/*` or `wifi/iwd/*` | Only with `wifi = yes` and encryption. Files mode 0600 |
| `home/<relpath>` | The data. A tar `--transform` is applied to home members only |

The metadata directory is deliberately visible (`omarchy-transfer/`, not a dotfile) so that someone who unpacks the archive by hand sees `README.txt` and `restore.sh` right next to `home/`. Archives made earlier used the hidden name `.omarchy-transfer/` with the same layout and `format=2`; import and `restore.sh` accept both names (the directory that exists is used).

`restore.sh` and `README.txt` are for people who open the archive by hand. `omarchy-transfer-import` accepts them like every other `omarchy-transfer/*` member, but they are never installed into `$HOME`: only `home/` and `wifi/` members are.

### Companion files

After the archive is finalized, the export writes two more files next to it, from the same sources as the embedded copies:

| File | Mode |
| ---- | ---- |
| `omarchy-transfer-restore.sh` | 0755 |
| `omarchy-transfer-README.txt` | 0644 |

Each is written as `.<name>.part` and moved into place with `mv`, so a half-written file never has the final name. Only these two names are replaced, nothing else in the target is touched. `--dry-run` lists all three output files and writes none. The companion files are excluded from the archive like earlier `omarchy-transfer-*` archives, so a target inside `$HOME` never packs them. The embedded `restore.sh` is byte-identical to the companion; the archive and both companion files belong together and should be kept in one folder.

Integrity comes from the zstd content checksum, which is verified because import reads the whole stream, and from age, which is authenticated encryption, so a tampered or wrongly keyed archive fails. There is no separate checksum file, which saves a full read pass.

## Export

One pass: `tar -cf - -C <meta> omarchy-transfer [-C <wifi> wifi] -C $HOME <includes> | zstd | [age -p] > <target>/.<name>.part`, then `sync` and an atomic `mv` to the final name. The home data is never staged, so plaintext secrets never touch the disk. The small metadata directory lives in `$XDG_RUNTIME_DIR` (tmpfs).

Checks before any work starts:

- Refuses to run as root.
- With `encrypt = yes` a terminal is required for the passphrase.
- Free space at the target must cover the estimated source size.
- A FAT32 target with an estimate over 4 GiB is refused, pointing at exFAT or ext4.
- The target is resolved with `realpath` after `mkdir -p` and excluded from the archive, also when it is inside `$HOME` or is `$HOME` itself. Earlier `omarchy-transfer-*` archives and the two companion files are always excluded.

Wi-Fi comes from `/etc/NetworkManager/system-connections` or `/var/lib/iwd`, read with `sudo tar` into a 0700 runtime directory. `--dry-run` reports what would be included, including the Wi-Fi backend that was really detected. The command ends with `omarchy-notification-send`.

## Import

1. Stage: `[age -d] < archive | zstd -dc | tar -x` into `transfer-stage.XXXXXX` (mode 0700) under `${OMARCHY_TRANSFER_TMPDIR:-$HOME/.cache/omarchy}`. It is on the same filesystem as `$HOME`, so installing a file is a rename, not a copy, and nothing readable is written under `/var/tmp` or into a root snapshot. A tar listing is read from the same stream in parallel. Staging needs about the uncompressed size once. `--dry-run` extracts only the metadata directory.
2. Validate: only `home/`, `omarchy-transfer/` (or the older `.omarchy-transfer/`) and `wifi/` members; no absolute or `..` paths; no member below a symlink; only regular files, directories and symlinks; `format=2`. Any violation aborts before anything in `$HOME` changes. A wrong passphrase, a truncated archive and a flipped byte all fail here.
3. Classify in batches, not per file: `find -printf` on the stage and on `$HOME`, joined with awk, and `cmp` only for equal sizes, run in parallel with `xargs -P`.
4. Decide with the table below.
5. Packages, then Wi-Fi when `--wifi` was given.
6. Summary of added, overwritten, kept, conflicting, blocked and failed items. Exit status is non-zero if anything failed, including packages. A notification is sent and Hyprland is reloaded.
7. A trap removes the stage with `chmod -R u+w` first, so read-only directories do not block cleanup.

### Decision table (mode `smart`)

Applied in order to every regular file and symlink `R`:

| # | Condition | Action |
| - | --------- | ------ |
| 1 | Target missing | Add |
| 2 | Target identical (`cmp`, same link target, or a symlink resolving to identical content) | Same, skip |
| 3 | `R` is in `pristine.list` (the archive copy was an unmodified old default) | Keep the target, count as kept-default |
| 4 | Target equals `transfer_default_source R` (never touched on the new system) | Overwrite, save the old target as `<R>.bak.<epoch>` |
| 5 | Otherwise (changed on the new system) | Keep the target, write the archive version to `<R>.transfer`, list as a conflict |
| 6 | An ancestor of `R` in `$HOME` exists but is not a directory | Skip and report as blocked |

Other modes: `ask` prompts per conflict (cases 3 to 5 collapsed) with a diff and `o`/`s`/`A`/`N`, needs `/dev/tty`, and never diffs secrets. `overwrite` replaces with a `.bak.<epoch>` backup. `skip` never touches an existing path.

`transfer_default_source` maps `.config/X` to `/etc/skel/.config/X` if it exists and else to `$OMARCHY_PATH/config/X`. Other `.foo` files map to `/etc/skel/.foo`. No match means no default exists.

### Packages

Official packages go in one `omarchy-pkg-add` call, limited to names present in `pacman -Slq` and not yet installed. AUR packages go in one `omarchy-pkg-aur-add` call. When a batch fails, import bisects it to find the failing names instead of prompting per package. Unknown packages and `*-debug` names are skipped and reported. Failed packages make the exit status non-zero.

### Wi-Fi

Only with `--wifi`, and only for archives that carry `wifi/`. Files go to the backend that is running at import time, as `root:root` mode 0600 through `sudo`, followed by `nmcli connection reload` or a restart of `iwd`.

## restore.sh

`default/transfer/restore.sh` restores an archive on any Linux, with or without Omarchy. Usage:

```
bash omarchy-transfer-restore.sh [--dry-run] [--mode=keep|ask|overwrite|skip] [--no-packages] [--wifi] [--extract-only <dir>] [--native|--portable] [<archive>]
```

- Without an archive it looks for `omarchy-transfer-*.tar.zst*` next to the script and shows a numbered list (`read`, no gum) when there are several.
- On Omarchy (`omarchy-transfer-import` in `PATH` and `$OMARCHY_PATH` set) it hands over to the native import after a question, or directly with `--native`. `--portable` forces the standalone path.
- `--extract-only <dir>` validates and unpacks only. The result is `home/`, `omarchy-transfer/` and, if present, `wifi/`.
- Validation follows the same rules as `omarchy-transfer-import`: allowed prefixes `home/`, `omarchy-transfer/` (or `.omarchy-transfer/`), `wifi/`; file, directory and symlink types only; no absolute or `..` paths; nothing below a symlink; `format=2`.
- File modes: `keep` (default) adds missing files and writes differing archive versions as `<file>.transfer`; `overwrite` replaces and saves `<file>.bak.<epoch>`; `skip` adds only; `ask` shows a diff and asks per file.

### Parking

On a system without Omarchy, Omarchy-specific files are not activated. They are written to `~/omarchy-transfer-configs/<path>` instead. That covers everything under `.config/{hypr,omarchy,waybar,walker,mako,uwsm,swayosd,elephant,quickshell}` and every text file that mentions `/usr/share/omarchy`, `OMARCHY_PATH`, `.local/share/omarchy` or `omarchy-` (for example a `.bashrc` that sources Omarchy defaults). Activating them without Omarchy would break the shell or the desktop. The summary says what was parked and why.

### Packages

- With `pacman` present: official packages are filtered against `pacman -Slq` and installed in one `sudo pacman -S --needed` call, bisected on failure. AUR packages go through `yay` or `paru` when one exists, otherwise they are only listed. Names that do not exist (for example from the Omarchy repo) are reported as missing.
- Without `pacman`: nothing is installed. `~/omarchy-transfer-packages.txt` lists the official and AUR packages.
- `--no-packages` skips the step.

### Dependencies

Bash 4 or newer, GNU coreutils, `tar` and `zstd`. `age` only for encrypted archives. `diff` only for `--mode=ask`. `sudo` for package and Wi-Fi steps. Missing tools are detected with the package manager (`pacman`, `apt`, `dnf`, `zypper`) and the matching install command is shown. Running as root is refused.

### Rule: no Omarchy dependency

`restore.sh` is copied into every archive and runs on machines that have never seen Omarchy. It must not call any `omarchy-*` command (the optional hand-over to `omarchy-transfer-import` is the one guarded exception), must not read `$OMARCHY_PATH` for its own work, and must not source `omarchy-transfer-functions`. Anything it needs from the library is duplicated inside the script. It is checked with shellcheck.

## Where things live

| What | Where |
| ---- | ----- |
| Commands | `bin/omarchy-transfer-*` |
| Standalone restore tool and its README | `default/transfer/restore.sh`, `default/transfer/README.txt` |
| Default config | `default/omarchy/transfer.conf` |
| User config | `~/.config/omarchy/transfer.conf` |
| Menu entries | `setup.transfer*` in `default/omarchy/omarchy-menu.jsonc` |
| Import staging | `${OMARCHY_TRANSFER_TMPDIR:-~/.cache/omarchy}/transfer-stage.*` |
| Export metadata | `$XDG_RUNTIME_DIR` (tmpfs) |
| User guide | `manual/52-transfer.md` |

## Test hooks

Environment variables the commands read, so tests never touch the real system:

| Variable | Default | Purpose |
| -------- | ------- | ------- |
| `OMARCHY_TRANSFER_CONF` | `~/.config/omarchy/transfer.conf` | Config path |
| `OMARCHY_TRANSFER_TMPDIR` | `~/.cache/omarchy` | Base for import staging |
| `OMARCHY_TRANSFER_NM_DIR` | `/etc/NetworkManager/system-connections` | NetworkManager profiles |
| `OMARCHY_TRANSFER_IWD_DIR` | `/var/lib/iwd` | iwd profiles |
| `OMARCHY_TRANSFER_SKEL` | `/etc/skel` | Where shipped dotfile defaults are looked up |

`pacman`, `yay`, `sudo`, `hyprctl`, `nmcli` and `systemctl` are always called by bare name, so tests stub them through `PATH`.

## Tests

Five files (plus `transfer-portable-test.sh` for `restore.sh`) in `test/shell.d/`, picked up by `./test/shell`. Each builds a scratch directory with `mktemp -d`, uses fake homes, puts stubs for `pacman`, `yay`, `sudo`, `hyprctl`, `nmcli`, `systemctl`, `omarchy-notification-send`, `omarchy-launch-config-editor` and `gum` first in `PATH`, and runs the real commands from `bin/` with `OMARCHY_PATH` pointing at the checkout. The real `$HOME` is never touched. See [`testing.md`](testing.md) for the conventions.

| File | Covers |
| ---- | ------ |
| `transfer-roundtrip-test.sh` | Export and import end to end: archive members and metadata, companion files, `diff -r`, modes, symlinks, xattrs, both exclude forms, targets inside `$HOME`, export without a config, `~` in the archive path, staging cleanup |
| `transfer-restore-policy-test.sh` | Every smart rule (add, same, pristine, default, modified, blocked, stow symlink) and the `ask`, `overwrite` and `skip` modes |
| `transfer-integrity-test.sh` | Truncated, garbage, bit-flipped, traversal, absolute, below-symlink, special-file, wrong-format and metadata-less archives; encryption, wrong passphrase, Wi-Fi restore |
| `transfer-config-test.sh` | Parser, GUI toggle writer (comments and order preserved, odd characters), library helpers, cleanup trap, `omarchy-transfer-config` |
| `transfer-packages-test.sh` | Package lists, filtering, batching, bisection, AUR failures, exit codes |

The encryption checks need `age` and `script(1)` and are skipped without them.
