# Editions

Omarchy ships two editions from one repo. The desktop edition is the historical one: Hyprland, the Quickshell shell, GUI applications. The server edition is headless: a getty on the console, SSH as the primary access, and no compositor.

The edition is chosen at install time and never toggled afterwards. Uninstalling a GUI stack in place is a migration minefield in both directions, so changing your mind is a reinstall.

## The marker

`/etc/omarchy-edition` holds one word, `desktop` or `server`. The installer writes it. Nothing else should.

A missing marker reads as `desktop`. Every install that predates editions is a desktop, so defaulting keeps the predicates answerable on machines the installer never stamped.

## Reading it

```bash
omarchy edition                 # prints desktop or server
```

For scripts, use the predicates. They print nothing and answer with an exit code, in the `hw-` tradition:

```bash
if omarchy-edition-server; then
  ...
fi

omarchy-edition-desktop || exit 0
```

An unrecognized marker fails loudly: `omarchy-edition` exits non-zero and both predicates stay false, rather than guessing an edition for a half-configured machine.

`omarchy-edition-set <desktop|server>` writes the marker. It escalates with `sudo` only when the target needs it, so the installer can call it as root from the ISO chroot where there is no terminal to answer a password prompt in.

## Package lists

| File | Edition |
| --- | --- |
| `install/omarchy-base.packages` | desktop |
| `install/omarchy-server.packages` | server |

The server list is derived from the base list by subtraction, plus three additions the base list cannot supply: `openssh` (the desktop gets it from the ISO's own `archinstall.packages`), `rsync`, and `lazyjournal` (the menu's log door, packaged in `omarchy-pkgs`). `test/shell.d/server-packages-test.sh` enforces that shape: anything in the server list that is neither in the base list nor a declared addition fails the suite.

Commands that install the default package set pick their list from the edition. `omarchy-reinstall-pkgs` is the example to copy.

## The front door

The server edition greets a login the way a bulletin board did. Three surfaces, one palette:

| Command | Draws |
| --- | --- |
| `omarchy-server-palette` | Translates the active theme into shell-sourceable ANSI escapes. `eval "$(omarchy-server-palette)"` puts `$OMARCHY_BBS_ACCENT` and friends in scope. |
| `omarchy-server-issue` | Renders `/etc/issue`, the pre-login banner agetty draws on the console. |
| `omarchy-server-splash` | Draws the login splash. Exits 0 when the caller chose the menu, non-zero when they chose a shell. |
| `omarchy-server-greet` | Reads or sets what a login lands on: `splash`, `menu`, or `off`. Per user. |
| `default/bash/server-greet` | The hook, sourced from `default/bash/init`. Guards, then greets. |

The palette names roles, not colors, so a theme can move a hue without every renderer following it: `ACCENT FG DIM RULE BRIGHT TITLE KEY OK WARN INFO ALERT ACCENT_BG SELECTION_BG ON_ACCENT`, plus `RESET` and `BOLD`.

Two axes degrade independently, because they fail differently. **Color depth** falls from truecolor to 16 SGR codes, and an SGR parameter a terminal cannot render is ignored or approximated rather than printed. **Glyphs** fall from box drawing to ASCII, signalled by `$OMARCHY_BBS_UNICODE`, because a console font missing box characters substitutes them and wrecks the alignment. `TERM=linux` gets both floors.

`omarchy-server-issue` is called by `omarchy-theme-set`, so switching themes restyles the banner. On the desktop edition it does nothing, which is why that call needs no guard around it - except that a machine which was a server long enough to get a banner has its stock `/etc/issue` restored from the copy kept beside it. The marker is writable, and a desktop should not keep greeting people as a server. It leaves agetty's own escapes in the file (`\n` nodename, `\4` IPv4, `\l` tty) so the hostname and address stay correct without anything regenerating them.

### The greeting guard

`default/bash/server-greet` is sourced on every bash startup, including all the ones that must stay silent. A single byte on stdout breaks `scp`, `sftp` and `rsync`, which parse the stream as protocol, and a blocking read breaks `ssh host <command>` for anything automated. So the guards are exhaustive, and they run cheapest first:

| Condition | Silences |
| --- | --- |
| `$-` has no `i` | `scp`, `sftp`, `rsync`, `ssh host <command>`, every script that starts a shell |
| `$OMARCHY_BBS_SESSION` set | A shell opened from inside the front door |
| `$SSH_ORIGINAL_COMMAND` set | A forced command, or an explicit remote command |
| `$TMUX` set | `tmux attach`, which is a reconnection rather than an arrival |
| stdin or stdout is not a tty | Anything with nothing to draw on |
| `$SSH_CONNECTION` set without `$SSH_TTY` | `ssh -T` and other sessions with no pty |
| No readable edition marker | Every desktop, at the cost of one stat and no subprocess |
| Marker is not `server` | The desktop edition |
| Greet mode is `off` | Anyone who asked for a plain shell |

The marker is read inline rather than through `omarchy-edition-server`, because the common case is a desktop where the file does not exist, and that case should not fork.

`test/shell.d/server-greet-test.sh` covers each row. It drives a real pty through Python rather than `script`, whose arguments differ between util-linux and BSD.

## Gating rules

**New migrations that touch a compositor, the shell, or GUI config must gate on the edition.** A migration that restarts Hyprland or rewrites a Quickshell config has nothing to do on a server, and running it there is at best noise.

```bash
omarchy-edition-desktop || exit 0
```

Existing migrations need no retrofit. The `omarchy` package seeds `/etc/skel/.local/state/omarchy/migrations` with a marker for every migration in the build, so a user created during a fresh install starts with all of them already marked. Historical migrations never run on a machine installed after they shipped, server or desktop.

**Refresh commands** that copy a GUI config into `~/.config` should gate the same way.

**Install steps** already gated, as the pattern to follow:

| Step | Why |
| --- | --- |
| `install/login/all.sh` | SDDM is the desktop's login manager; a server boots to a getty |
| `install/config/theme-system.sh` | Nautilus icons and Chromium policy |
| `install/config/lockscreen-pam.sh` | hyprlock |
| the tail of `install/config/enable-services.sh` | `cups`, `cups-browsed`, `avahi-daemon`, `power-profiles-daemon`, `sddm` |

That last one is the reason this matters rather than being tidiness: `systemctl enable` on a unit whose package was never installed fails, and `omarchy-apply-system` runs under `set -euo pipefail`. Use a full `if`, not `predicate && command`, for the same reason.

**Do not gate** anything the two editions share: pacman, snapper, the update pipeline, the CLI, or the terminal side of a theme. One update pipeline, two editions.

## Remote LUKS unlock

The server edition can unlock an encrypted root via SSH during boot through dropbear in the initramfs. This is opt-in: `omarchy-server-remote-unlock enable` installs the packages, configures the initramfs, and regenerates the boot image.

Requirements:
- Server edition
- Encrypted root filesystem
- At least one SSH key in `~/.ssh/authorized_keys`

The initramfs SSH server uses your authorized keys. To unlock remotely:

```bash
ssh -p 2222 root@<server-ip> cryptroot-unlock
```

The default port is 2222 (avoids conflict with the main sshd). The dropbear host key persists so its fingerprint stays stable across reboots.

### Commands

```bash
omarchy-server-remote-unlock enable                           # Enable with DHCP
omarchy-server-remote-unlock enable --static-ip=192.168.1.100/24  # Enable with static IP
omarchy-server-remote-unlock enable --port=2323                # Custom SSH port
omarchy-server-remote-unlock disable                          # Disable
omarchy-server-remote-unlock status                           # Check status
```

### Implementation

The `enable` command:

1. Installs `mkinitcpio-dropbear`, `mkinitcpio-netconf`, and `mkinitcpio-utils`
2. Copies `~/.ssh/authorized_keys` to `/etc/initcpio/dropbear/`
3. Generates or reuses a persistent dropbear host key in `/etc/dropbear/`
4. Adds a `mkinitcpio.conf.d` drop-in that inserts `netconf`, `dropbear`, and `encryptssh` hooks before the `encrypt` hook
5. Configures network via kernel command line (`ip=dhcp` or `ip=<static>`)
6. Rebuilds the initramfs and updates the bootloader

The `disable` command removes the drop-in and network config, then rebuilds the initramfs. The packages stay installed (safe to remove manually).

### Testing notes

The test suite (`test/shell.d/server-remote-unlock-test.sh`) covers:
- Edition gating (desktop rejected)
- SSH key requirement (enable without keys rejected)
- Encrypted root requirement (enable on unencrypted rejected)
- Argument parsing (--port, --static-ip)
- Status reporting

The test cannot validate the actual initramfs hooks or boot-time network configuration without real hardware. **Untested and requiring bare-metal verification:**
- Actual SSH connectivity in the initramfs
- Network configuration (DHCP and static IP)
- Passphrase unlock flow
- Host key persistence across reboots
- Interaction with Limine/UKI boot
