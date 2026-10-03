# File layout

How `omarchy/` is organized and where everything ends up on an installed
system.

## Mental model

Two Arch packages are built from this one repo (PKGBUILDs live in the
separate `omarchy-pkgs` repository, under `pkgbuilds/`):

- **`omarchy`** — runtime binaries (`bin/`, including `bin/omarchy-dev-*`),
  install/finalize scripts (`install/`), migrations, themes, and the
  Quickshell desktop (`shell/`). Depends on `omarchy-settings`.
- **`omarchy-settings`** — everything that has to be on the target *before*
  the omarchy package installs (specifically before `useradd -m` and the
  limine bootloader install): all `/etc/skel/**`, `/etc/` drop-ins,
  package-owned system files under `/usr/share` and `/usr/lib`, fonts,
  plymouth theme, sddm theme, branding, plus the limine/snapper configs
  (mkinitcpio hooks, limine-entry-tool drop-ins, snapper template, the
  `default/limine/` and `default/snapper/` trees, and the boot/snapshot
  story end-to-end). Also ships the three debug binaries
  (`omarchy-debug`, `omarchy-debug-idle`, `omarchy-upload-log`) needed by
  the live ISO env.

Two other packages live in `omarchy-pkgs` but stand alone:
`omarchy-keyring` (GPG keys for pacman) and `omarchy-nvim` (the Neovim
setup; independently seeds `/etc/skel`).

Some trees ship in neither package and exist only in the repo: `manual/`
(user manual chapters), `agents/skills/` (contributor task guides), `docs/`,
`test/`, and `plans/`.

Three layers populate `$HOME`:

1. **Seed** — `omarchy-settings` ships static defaults to `/etc/skel/`.
   Arch's `useradd -m` copies that tree into a new user's `$HOME` at user
   creation. This is the only mechanism that touches a brand-new user's home
   for these files.
2. **Finalize** — `omarchy-provision-user` (routed as `omarchy finalize
   user`) runs once per user and handles the things `/etc/skel` can't do
   because they need `$HOME` expansion, the live `$OMARCHY_PATH`, or runtime
   detection of system state.
3. **Resync** — `omarchy-reinstall-configs` is the explicit, destructive
   command for an existing user to clobber their configs back to shipped
   defaults.

`/etc/skel` only fires at user creation. Existing users picking up new
defaults must use the resync command.

Deferred-provisioning installs (`omarchy-apply-system --defer-provisioning`)
create no user at all: the ISO leaves `/var/lib/omarchy/provisioning/pending`
behind, which arms `omarchy-provision-owner.service` (shipped from
`install/provisioning/`, alongside the factory-reset finish unit and
`setup-form.sh`). On first boot `bin/omarchy-provision-owner` creates the
user on tty1 and runs the finalize step itself.

On an encrypted install `omarchy-provision-owner` then re-keys LUKS from the staged install key to the owner's password through `install/provisioning/luks-rekey.sh`, which journals each step (phase and slot numbers, never keys) in `/var/lib/omarchy/provisioning/luks-rekey.state` so an interrupted first boot resumes. Setup finishes only once the staged key opens nothing, and removes the journal with `pending`, so a retry after the staged key is retired must use the password the disk holds. On a platform whose boot package owns the boot chain, the check before the owner form, the boot-time unlock and the record of the kept key slot go through `omarchy-lifecycle-dispatch`. See [lifecycle-dispatch.md](lifecycle-dispatch.md).

`omarchy-drive-password` reuses those journal helpers when the owner changes the password of the disk holding `/`: it changes the LUKS key, confirms the new key opens the disk and the old one no longer does, and only then sets the login and root passwords. `~/.local/state/omarchy/drive-password.state` records the disk's UUID, the key slots and the phase (never a password) until the accounts match, and the next run finishes an interrupted change with whichever of the old or new password the disk opens with.

Prebuilt images are set up away from the machine they will run on, so their hardware setup waits for that machine. The builder writes a root-owned manifest, `/var/lib/omarchy/image/target` (`format=1`, `platform=<omarchy-hw-platform value>`), before `omarchy-apply-system`. While it exists, `omarchy-apply-hardware` runs no hardware leaf: it queues each one in `/var/lib/omarchy/image/deferred-steps` and arms `omarchy-provision-hardware.service` (shipped from `install/provisioning/`). On the machine's first boot, before owner setup and the login screen, `bin/omarchy-provision-hardware` renames the manifest to `target.booted` and runs the queue in order, dropping each step that succeeds. Before the first step it makes the machine's own pacman keyring when the build asked for one (`/var/lib/omarchy/image/pacman-keyring`, which install finalization writes on Qualcomm and generic aarch64 instead of running `pacman-key --init`, so no two machines share a master key). A failed step stays queued for the next boot. It refreshes no package databases: the image carries its sync databases and every package its queued steps install, so the queue runs offline (the image build checks that it carries them; a step whose package is missing stays queued). Once the queue is empty it rebuilds the initramfs if a step changed its inputs (the mkinitcpio configuration, or the kernel command line in `/etc/default/limine` and `/etc/limine-entry-tool.d/`) or asked for the rebuild (`/var/lib/omarchy/image/boot-rebuild`), and disables the service; the unit file stays, so a start job already queued is skipped on the emptied queue rather than failed. A platform's own first boot may run `omarchy-provision-hardware` itself: runs are serialised, and it exits 75 when a step or the keyring failed and stays queued, and 1 when it refused to run (an untrusted manifest or queue) or the final rebuild failed, which the next run retries. Steps know they run on an image's first boot from `OMARCHY_IMAGE_DEFERRED_HARDWARE=1` (Bluetooth starts its service there, since boot already brought up its target). `install/helpers/image-target.sh` holds the contract. Root always uses these fixed paths; no environment variable turns a live system into an image build.

Current generated theme state lives under
`~/.local/state/omarchy/current/`. Keep `~/.config/omarchy/` for files a user
may intentionally version in a dotfile manager, such as user themes, hooks,
shell layout, plugins, and themed template overrides.

## Build-time map (repo → installed paths)

```
omarchy/                            built into          installed at
─────────────────────────           ──────────────      ────────────────────────────────────

bin/omarchy-*                  ──►  omarchy             /usr/bin/omarchy-*
                                                        (and symlinks in /usr/share/omarchy/bin/)
bin/omarchy-debug,
bin/omarchy-debug-idle,
bin/omarchy-upload-log         ──►  omarchy-settings    /usr/bin/  (needed before omarchy is installed)

default/libalpm/hooks/*.hook
                                ──►  omarchy             /usr/share/libalpm/hooks/*.hook

install/**                     ──►  omarchy             /usr/share/omarchy/install/
migrations/**                  ──►  omarchy             /usr/share/omarchy/migrations/
themes/**                      ──►  omarchy             /usr/share/omarchy/themes/
shell/**                       ──►  omarchy             /usr/share/omarchy/shell/
version                        ──►  omarchy             /usr/share/omarchy/version
                                                        + /etc/skel/.local/state/omarchy/migrations/*

config/**                      ──►  omarchy-settings    /etc/skel/.config/**         (seeds new users)
                                                        /usr/share/omarchy/config/** (resync source)
etc/fastfetch/config.jsonc     ──►  omarchy-settings    /etc/fastfetch/config.jsonc
etc/xdg/kitty/kitty.conf       ──►  omarchy-settings    /etc/xdg/kitty/kitty.conf

applications/*.desktop         ──►  omarchy-settings    /etc/skel/.local/share/applications/
                                                        /usr/share/omarchy/applications/
default/applications/battlenet.desktop
                                ──►  omarchy-settings    /usr/share/omarchy/default/applications/
                                                        (installer-only launcher template)
applications/icons/*           ──►  omarchy-settings    /usr/share/icons/hicolor/{48,256,scalable}/apps/

etc/**                         ──►  omarchy-settings    /etc/**           (drop-ins we own outright)
  ├─ mkinitcpio.conf.d/{00-omarchy-hooks,omarchy_hooks,thunderbolt_module}.conf
  ├─ limine-entry-tool.d/{omarchy-defaults,omarchy-uki}.conf
  ├─ NetworkManager/, sudoers.d/, sysctl.d/, tmpfiles.d/,
  │  profile.d/omarchy.sh, …                            (a summary — `ls etc/` for the full ~17-entry tree)
  └─ security/faillock.conf, nsswitch.conf,
     cups/cups-browsed.conf, plymouth/plymouthd.conf    /usr/share/omarchy/etc-overrides/
                                                          → /etc/* (post_install cp -f, see below)

default/limine/limine.conf     ──►  omarchy-settings    /usr/share/omarchy/default/limine/limine.conf
default/limine/default.conf    ──►  omarchy-settings    /usr/share/omarchy/default/limine/default.conf
                                                        (template; ISO substitutes @@CMDLINE@@ → /etc/default/limine)
default/snapper/root           ──►  omarchy-settings    /etc/snapper/config-templates/omarchy
                                                        (+ /usr/share/omarchy/default/snapper/root)

default/**                     ──►  omarchy-settings    /usr/share/omarchy/default/
  ├─ bash/env-bootstrap                                 /usr/share/omarchy/default/bash/env-bootstrap
  │                                                       (sourced by every shell/session entry point; see "Env bootstrap")
  ├─ bashrc                                             /usr/share/omarchy/etc-overrides/dot.bashrc
  │                                                       → /etc/skel/.bashrc (post_install cp -f)
  ├─ hypr/toggles/*.lua (flags,
  │    single-window-aspect-ratio, window-no-gaps)      /etc/skel/.local/state/omarchy/toggles/hypr/
  ├─ nautilus-python/extensions/*.py                    /etc/skel/.local/share/nautilus-python/extensions/
  ├─ uwsm/env.d/10-omarchy                              /usr/share/uwsm/env.d/
  ├─ environment.d/*.conf                               /usr/lib/environment.d/
  ├─ fontconfig/conf.avail/50-omarchy.conf              /usr/share/fontconfig/conf.avail/
  │                                                       + symlink /etc/fonts/conf.d/50-omarchy.conf
  ├─ xdg-terminal-exec/*.list                           /usr/share/xdg-terminal-exec/
  ├─ applications/mimeapps.list                         /usr/share/applications/mimeapps.list
  ├─ systemd/user/*.service                             /usr/lib/systemd/user/
  ├─ systemd/user/app.slice.d/10-oomd.conf              /usr/lib/systemd/user/app.slice.d/
  ├─ systemd/system-sleep/unmount-fuse                  /usr/lib/systemd/system-sleep/
  ├─ systemd/zram-generator.conf.d/90-omarchy.conf      /usr/lib/systemd/zram-generator.conf.d/
  ├─ fonts/omarchy/omarchy.ttf                          /usr/share/fonts/omarchy/
  ├─ sddm/omarchy/                                      /usr/share/sddm/themes/omarchy/
  ├─ sddm/hyprland.lua                                  /usr/share/sddm/hyprland.lua
  ├─ wayland-sessions/omarchy.desktop                   /usr/local/share/wayland-sessions/
  └─ plymouth/                                          /usr/share/plymouth/themes/omarchy/

logo.{txt,svg}, icon.{txt,png}  ──► omarchy-settings    /usr/share/omarchy/  (resync source)
                                                        /usr/share/pixmaps/omarchy.png
                                                        /usr/share/icons/hicolor/256x256/apps/omarchy.png
                                                        /etc/skel/.config/omarchy/branding/{about,screensaver}.txt
```

The hardware-conditional `force-igpu` and `keyboard-backlight` sources also live under `default/systemd/system-sleep/`, but their setup commands publish root-owned copies only on machines that need them; they are not installed by `omarchy-settings`.

### Platform root

A platform's runtime package (omarchy-mac on Apple Silicon, say) adds its desktop files under a fixed root that only the one installed platform package owns. Omarchy ships nothing there, and a missing root or file means no platform additions. No environment variable moves it; tests reach fixtures through test-only seams, never through a desktop session's environment.

```
/usr/share/omarchy-platform/
  displays.conf                backlight and DDC hints for the display commands (below)
  key-names                    "<keysym> <name>" lines the keybindings menu shows in place of keysyms
  display-cutouts.json         camera cutouts the top bar keeps out of (see omarchy-shell.md)
  keyrings                     signing keyring packages of the repositories the platform adds, one per line
  audio.json                   audio processing nodes the audio panel and microphone widget leave out (below)
```

See [lifecycle-dispatch.md](lifecycle-dispatch.md#platform-files).

`omarchy-update-keyring` reinstalls each installed package `keyrings` names (`#` comments and blank lines skipped, and a line that isn't a `*-keyring` package name skipped with a warning) with Arch's, before the system upgrade, so a key rotation in the platform's own repository never fails that upgrade's signature checks. On Apple Silicon, omarchy-mac names `asahi-alarm-keyring` there.

#### Display hints (`displays.conf`)

`omarchy-hw-display` picks the built-in panel's backlight by name (`gmux_backlight`, then `amdgpu_bl*`, `intel_backlight`, `acpi_video*`, else the first one listed, never a T2 Touch Bar's `appletb_backlight`), and `omarchy-brightness-display` probes every external monitor over DDC. Where a platform's names or display driver differ, its platform package says so in `/usr/share/omarchy-platform/displays.conf`; Omarchy ships none, and without it both behave as above. One directive per line, whitespace-separated; blank lines, whole-line `#` comments, unknown directives, and lines with a wrong word count or a name that is `.`, `..` or has a `/` are ignored:

- `backlight-skip <glob>`: a `/sys/class/backlight` name (a shell glob) that never drives the built-in panel, such as a Touch Bar's. It is never picked, not even when a later directive or the built-in order names it.
- `backlight-prefer <name>`: the built-in panel's backlight, a literal name, tried after `gmux_backlight` and before the GPU and ACPI ones, in file order.
- `ddc-require-connector-ddc`: the display driver registers no DDC channel, so a probe would only walk unrelated I2C buses. An external monitor (other than an Apple Studio or XDR Display, which `omarchy-brightness-display-apple` drives with asdcontrol) is probed only when its DRM connector has a `ddc` node (`/sys/class/drm/card*-<connector>/ddc`); otherwise it gets no DDC or backlight control, and the built-in panel is never dimmed in its place.

No environment variable moves the file: these commands also run under `sudo` and from the brightness keys. Their tests (`test/shell.d/hw-display-test.sh`, `test/shell.d/brightness-display-test.sh`) run a copy rewritten to read a fixture in its place.

#### Audio hints (`audio.json`)

The audio panel lists every output, input and playback stream PipeWire has, and the microphone widget counts every recording as the microphone in use (the shell's own level meters never count). A platform whose audio runs through its own processing (DSP filter graphs in front of raw devices, say) has nodes that are neither devices nor apps, and its platform package names them in `/usr/share/omarchy-platform/audio.json`; Omarchy ships none, and without it nothing is left out.

```json
{
  "hidden": ["<pattern>", "..."],
  "replaced": [{ "node": "<pattern>", "by": "<pattern>" }]
}
```

A pattern is a JavaScript regular expression matched against a whole `node.name`. A `hidden` node is never listed as an output, an input or an app stream, unless it is the current default output or input (so the panel always shows what's in use), and never lights the microphone widget; a `replaced` node is left out only while a node matching `by` exists (a mono processed microphone behind a stereo copy of it, say). Missing or malformed JSON means no hints, and an invalid pattern or entry is skipped. The shell reads the file at that fixed path, which no environment variable moves (`shell/Commons/AudioNodes.qml`), and `test/shell.d/audio-test.sh` covers the parsing.

A virtual source (an `Audio/Source/Virtual`, such as EasyEffects' or a platform's microphone mapping) needs no hint: Quickshell leaves it untyped, so the panel and widget set its volume and mute through `wpctl` (`shell/Commons/UntypedInput.qml`, one `pactl subscribe` for the whole shell) and the panel meters it with `omarchy-audio-source-level`, and the panel lists it because PulseAudio does (`omarchy-audio-sink-availability sources`).

### Why `etc-overrides/` exists

Some files under `/etc/` (`.bashrc` in `/etc/skel`, `nsswitch.conf`,
`security/faillock.conf`, `cups/cups-browsed.conf`, `plymouth/plymouthd.conf`)
are owned by upstream Arch packages, so we can't install over them via pacman
without a file conflict. Instead their sources (under `etc/` in the repo;
`.bashrc` from `default/bashrc`) ship at
`/usr/share/omarchy/etc-overrides/` and the `omarchy-settings` `post_install`
/ `post_upgrade` scriptlet `cp -f`'s them into place.

Tradeoff: user edits to those files get clobbered on every `omarchy-settings`
upgrade. This is documented in the PKGBUILD.

## Locate indexing

`default/systemd/system/plocate-updatedb.service.d/10-omarchy.conf` ships through `omarchy-settings` to `/usr/lib/systemd/system/plocate-updatedb.service.d/10-omarchy.conf`. It replaces the existing service's `ExecStart` with `updatedb --prune-bind-mounts=no --add-prunepaths=/.snapshots`, keeping Btrfs subvolume mounts searchable and excluding Snapper snapshots. The upstream service retains its timer, resource limits, and sandbox; Omarchy's existing AC-power condition still applies.

`/etc/updatedb.conf` remains owned by plocate and is never rewritten by Omarchy. The command-line options override bind-mount pruning and add to the administrator's existing path exclusions. Installer and AUR package refreshes pass the same options directly because installation may run without systemd and an explicitly requested refresh should work on battery.

Arch's systemd package hook reloads units when the vendor drop-in is installed or upgraded. The settings package containing the drop-in must ship alongside the runtime package that removes the old configuration helper and migration. Pacman removes those retired files; no new state migration is needed. A running indexer finishes with its original options, and subsequent service starts use the drop-in. For an immediate local test after installing the packages, restart `plocate-updatedb.service` while connected to AC power.

## Env bootstrap (`default/bash/env-bootstrap`)

Single source of truth for `OMARCHY_PATH` and dev-link-aware `PATH`. It:

- Sources `/etc/omarchy.conf` (written by `omarchy-dev-link`, reset to the
  package path by `omarchy-dev-unlink`) if present; otherwise forces
  `OMARCHY_PATH=/usr/share/omarchy` so a stale inherited value can't survive
  an `omarchy-dev-unlink`.
- Prepends `$OMARCHY_PATH/bin` to `PATH` **only when** `OMARCHY_PATH` is
  not `/usr/share/omarchy`. On a production install the binaries are
  already on `PATH` as `/usr/bin/omarchy-*` via the `omarchy` package.
- Appends `~/.local/share/mise/shims` and `~/.local/bin` so login shells and
  the uwsm session find mise-managed tools — kept in sync with the PAM `PATH`
  line written by `install/config/ssh-command-path.sh`, which covers SSH
  commands that run no shell setup at all.

Sourced by every entry point that needs the env set:

```
/etc/profile.d/omarchy.sh                      (system login shells)
/etc/skel/.bashrc                              (interactive shells)
/usr/share/uwsm/env.d/10-omarchy               (Hyprland session via uwsm)
/usr/share/omarchy/default/bash/envs           (SSH / non-login bash)
```

Idempotent — safe to source more than once in the same shell.

`PATH` covers everything the user runs, but not `sudo`, which resolves command
names against `secure_path` from `/etc/sudoers`. So `omarchy-dev-link` also
writes `/etc/sudoers.d/omarchy-dev-path`:

```
Defaults secure_path="<checkout>/bin:/usr/local/sbin:/usr/local/bin:/usr/bin"
```

Without it, `sudo omarchy-*` fails for a command the package has not shipped
yet and silently runs the packaged copy of one it has. The drop-in is validated
with `visudo -c` before install and removed by `omarchy-dev-unlink`; unlike
`/etc/omarchy.conf`, it takes effect without a reboot.

## Runtime finalization (`omarchy-provision-user`)

Runs once per user. It does **not** copy `~/.config/**`, `~/.bashrc`,
`flags.lua`, or the nautilus extensions — `/etc/skel` already seeded those.
It only does the things `/etc/skel` can't:

- Skill symlinks into `~/.agents/skills/<name>`, `~/.claude/skills/<name>`, `~/.codex/skills/<name>`, `~/.pi/agent/skills/<name>`, `~/.gemini/config/skills/<name>` (Antigravity), `~/.hermes/skills/<name>`, and each existing `~/.hermes/profiles/*/skills/<name>` → `$OMARCHY_PATH/default/agents/skills/<name>`, looping over every skill directory there (currently `omarchy` and `diagnose-crash`) so new skills need no edit. Symlinks (not copies) so `omarchy dev link` against a dev checkout repoints them correctly. Hermes profile dirs are only linked when they already exist — provision does not create Hermes profiles.
- `xdg-user-dirs-update` (Templates/Public/Desktop folded back into `$HOME`)
  and `~/.config/gtk-3.0/bookmarks` (needs `$HOME` expansion).
- Hyprland's package-owned default input reads `XKBLAYOUT` / `XKBVARIANT`
  from `/etc/vconsole.conf`; no per-user Hyprland config rewrite is needed.
- `xdg-settings set default-web-browser chromium.desktop` and
  `xdg-mime default HEY.desktop x-scheme-handler/mailto` (XDG-aware paths).
- `omarchy-refresh-applications` (composes generated `.desktop` launchers).
- Sources `install/user/all.sh` — theme, chromium, git, xcompose, mise,
  keyring, per-user hardware quirks (asus mic/mixer, framework f13 audio, …).
- On `--first-install`, marks every shipped user migration as already applied
  for the freshly-created user.

Idempotency marker: `~/.local/state/omarchy/done/finalize-user`, managed
by `omarchy-done`.

The ISO calls it as `omarchy-provision-user --force --first-install` in the
target chroot as the install user, after `omarchy-apply-system` has finished
the root-side work. `omarchy-provision-owner` makes the same call (with
`OMARCHY_SETUP_CONTEXT=provision-owner`) when it creates the user during
deferred first-boot provisioning.

## Migrations (`omarchy-migrate`)

See [`migrations.md`](../agents/skills/migrations.md) for the full migration model, authoring
guidelines, and troubleshooting notes.

Omarchy migrations live in `migrations/*.sh` and run per-user through
`omarchy-migrate`. Completion state lives in
`~/.local/state/omarchy/migrations/`, so every user gets a chance to run every
migration. Migrations run as the user; privileged work should invoke the
appropriate helper or privilege prompt. Migrations must be idempotent;
machine-wide repairs should no-op when another user already applied them.

Each graphical user has `omarchy-migrate-notify.service`, started once per login
through `WantedBy=graphical-session.target` and ordered after that target so
notification actions can safely launch through UWSM. The `omarchy-pkgs`
PKGBUILD has shipped `omarchy-update-user-notify.service` as a symlink onto
it, so users enabled under the old unit name keep working before they reach
migration `1785095882`.
It runs `omarchy-migrate-notify` as
that user, which checks `omarchy-migrate --pending`. If this user has missing
migration state, it shows a notification that opens a terminal for
`omarchy-migrate`. The notifier never runs migrations in the background.

Login is the only trigger. Nothing watches the packaged migration directory: a
watcher cannot tell a bypassed `pacman -Syu` from the package transaction inside
a normal `omarchy update`, so it notified about migrations that `omarchy-migrate`
was already applying in the visible update terminal.

`omarchy-migrate` waits for any active pacman transaction to finish, then runs
pending migrations. It does not need `--force`; migrations happen when state
files are missing. `omarchy update` runs `omarchy-migrate` after the package
transaction in the already-visible update terminal, then runs
`omarchy-hook post-update`.

## First-run (`omarchy-provision-first-run`)

Runs once on first interactive login, after the user manager is live. It
first runs `omarchy-provision-user || true` so finalize catches up if it
never ran, then handles the steps that need a running graphical session
and/or a working user systemd instance:

- `omarchy-hook-install post-update` for the three shipped hooks
  (`install-voxtype.hook`, `setup-fingerprint.hook`, `setup-agent.hook`).
- `install/user/first-run/enable-user-units.sh` — daemon-reload, then
  `systemctl --user enable --now` the shipped user units (`bt-agent`,
  `omarchy-sleep-lock`, `omarchy-recover-internal-monitor`,
  `omarchy-migrate-notify.service`, `omarchy-fcitx5.service`,
  `omarchy-crash-watch.service`) so they run in the first session too.
  Done here, not at finalize, because
  the user manager isn't reachable from the ISO chroot; `ConditionPath*`
  in the unit files keeps services inert when they don't apply.
- `omarchy-lifecycle-dispatch setup-user` — the platform's own user setup,
  now with the session up (a no-op where the platform registers none; see
  [lifecycle-dispatch.md](lifecycle-dispatch.md)).
- `install/user/first-run/gnome-theme.sh`,
  `install/user/first-run/gtk-primary-paste.sh` — GNOME/GTK settings that
  need the dconf daemon.
- `install/user/first-run/audio-tuning.sh` — apply speaker tuning.
- `install/user/first-run/welcome.sh` — keybindings toast that greets the
  first login and opens the cheatsheet when clicked. The caller runs
  `omarchy-notification-wait` once before this and the Wi-Fi step, so both
  toasts land on a live notification server.
- `install/user/first-run/wifi.sh` — Wi-Fi/update toasts (waits detached on
  `nm-online` so the update prompt only lands once there is a connection).

The entire sequence has one idempotency marker:
`~/.local/state/omarchy/done/first-run-user`, managed by `omarchy-done`.
Completed users exit before any first-run step. On failure the marker is not
written and the sequence retries next login.

Completion markers live under `~/.local/state/omarchy/done/`. Use
`omarchy-done check <name>` to check one and `omarchy-done mark <name>` to record it.
Use `omarchy-done ensure <name>` as a conditional when the guarded work should
run only once; it records completion before returning success.
The Quattro upgrade completes graphical first-run for upgraded users and moves
the legacy finalization marker from `~/.local/state/omarchy/` into `done/`.

## Root-side install orchestration

`omarchy-apply-system` (root, in chroot) runs target-side setup at ISO
finalization. It sources:

- `install/config/all.sh` — theme links, lockout limits, lockscreen PAM,
  powerprofilesctl shebang fix, SSH command path and keepalive, docker setup,
  Snapper retention, locate index tuning, service enablement, firewall.
- `install/hardware/all.sh` via `omarchy-apply-hardware` — vendor- and
  device-specific kernel modules, udev rules, microcode, wireless regdom,
  ASUS / Framework / Intel / Apple / Lenovo quirks.
- `install/login/all.sh` — SDDM theme/session config.
- `install/post-install/all.sh` — final pacman/udev/localdb passes.

Logging goes to `/var/log/omarchy-install.log` via
`install/helpers/logging.sh`.

Platform-specific setup asks `omarchy-hw-platform`, which prints `apple-silicon`, `qualcomm`, `generic-aarch64` or `generic`. It reads the vendor prefix of each token in the device tree's root `compatible` (`apple,` or `qcom,`, from `/proc/device-tree` or `/sys/firmware/devicetree/base`) and the CPU architecture, and fails when they contradict each other.

An image built away from the machine it will run on names its target in a root-owned manifest, `/var/lib/omarchy/image/target` (`format=1`, `platform=<omarchy-hw-platform value>`, unknown keys ignored). While the root is being built rather than booted, the detector answers from the manifest and never reads the build host's device tree. The root counts as built when it shows it: no `/run/systemd/system`, PID 1's root is another one (a chroot), or PID 1 is not systemd (a PID namespace). A booted system always answers from its hardware, even with a manifest left behind, so no unit that asks the detector may use `PrivatePIDs=`. As root the detector restarts in an empty environment and ignores the fixture variables its tests use.

The package lists the ISO pacstraps live at `install/omarchy-base.packages`
and `install/omarchy-other.packages`; the ISO builder also reads them when
constructing its offline mirror.

A platform's default package set is the base list, then its architecture's additions, then its own: `install/omarchy-aarch64.packages` on every aarch64 platform, then `install/omarchy-<platform>.packages` when that platform has one (`install/omarchy-apple-silicon.packages` on Apple Silicon, `install/omarchy-qualcomm.packages` on Qualcomm). x86_64 installs the base list alone. `omarchy-pkg-defaults [platform]` prints the composed set, for the running machine by default (via `omarchy-hw-platform`, so an image build gets its target's set), and `omarchy-reinstall-pkgs` installs it.

## Platform display hints (`/usr/share/omarchy-platform/displays.conf`)

`omarchy-hw-display` picks the built-in panel's backlight by name (`gmux_backlight`, then `amdgpu_bl*`, `intel_backlight`, `acpi_video*`, else the first one listed, never a T2 Touch Bar's `appletb_backlight`), and `omarchy-brightness-display` probes every external monitor over DDC. Where a platform's names or display driver differ, its platform package says so in `/usr/share/omarchy-platform/displays.conf`; Omarchy ships none, and without it both behave as above. One directive per line, whitespace-separated; blank lines, whole-line `#` comments, unknown directives, and lines with a wrong word count or a name that is `.`, `..` or has a `/` are ignored:

- `backlight-skip <glob>`: a `/sys/class/backlight` name (a shell glob) that never drives the built-in panel, such as a Touch Bar's. It is never picked, not even when a later directive or the built-in order names it.
- `backlight-prefer <name>`: the built-in panel's backlight, a literal name, tried after `gmux_backlight` and before the GPU and ACPI ones, in file order.
- `ddc-require-connector-ddc`: the display driver registers no DDC channel, so a probe would only walk unrelated I2C buses. An external monitor (other than an Apple Studio or XDR Display, which `omarchy-brightness-display-apple` drives with asdcontrol) is probed only when its DRM connector has a `ddc` node (`/sys/class/drm/card*-<connector>/ddc`); otherwise it gets no DDC or backlight control, and the built-in panel is never dimmed in its place.

No environment variable moves the file: these commands also run under `sudo` and from the brightness keys. Their tests (`test/shell.d/hw-display-test.sh`, `test/shell.d/brightness-display-test.sh`) run a copy rewritten to read a fixture in its place.

## Explicit resync (`omarchy-reinstall-configs`)

When an existing user wants to reset to shipped defaults:

```
~/  ←  cp -af /etc/skel/.
```

Replaying `/etc/skel` over `$HOME` is exactly what `useradd -m` does for a
brand-new user, so this one copy resyncs `.bashrc`, `.config/**`,
`.local/share/applications/`, the nautilus-python extensions, hypr toggles,
branding files, and the shipped migration markers in a single pass.

Then it runs `omarchy-refresh-limine`, `omarchy-refresh-plymouth`, and the
nvim refresh. Destructive: existing user files copied from `/etc/skel` are
clobbered without backup. Fastfetch is package-owned at
`/etc/fastfetch/config.jsonc`; delete `~/.config/fastfetch/config.jsonc` to
return to the packaged default.

## Quick reference: where does X live?

| Goal | Touch |
| --- | --- |
| Default file at `~/.config/foo/` | `config/foo/` |
| `/etc/` drop-in we own outright | `etc/` |
| `/etc/` file owned by an upstream package | `etc/` (see `etc/security/faillock.conf`), then add to `etc-overrides` in `omarchy-settings` PKGBUILD + scriptlet |
| Package-owned system file (e.g. systemd user service in `/usr/lib`) | `default/`, then add the `install -Dm644` line in `omarchy-settings` PKGBUILD |
| Per-user file that's static but lives outside `~/.config` | `default/`, then add `install -Dm644 ... $pkgdir/etc/skel/...` in `omarchy-settings` PKGBUILD |
| Runtime tweak that needs `$HOME` or live system state | extend `omarchy-provision-user`, or add a per-user leaf under `install/user/` and wire into `install/user/all.sh` |
| One-time root-side setup step | `install/config/*.sh` or `install/hardware/*.sh`, wire into `install/config/all.sh` or `install/hardware/all.sh` |
| One-time fix for existing installs | `migrations/<unix-timestamp>.sh` |
| Package-owned path something else may already write | Prefer a path nothing else writes, such as a vendor drop-in under `/usr/lib`. Otherwise the `--overwrite` entry in `bin/omarchy-update-system-pkgs` has to ship a release before the file |
| User-facing `omarchy-*` command | `bin/omarchy-<group>-<verb>` — see `GROUP_DESCRIPTIONS` in `bin/omarchy` |
| New stock theme | `themes/<name>/` (+ matching templates under `default/themed/` if they need theme colors) |
| User-installed theme | `~/.config/omarchy/themes/<name>/` |
| Generated current theme/background state | `~/.local/state/omarchy/current/` |

## Kitty defaults and user overrides

Kitty loads `/etc/xdg/kitty/kitty.conf` before `~/.config/kitty/kitty.conf`. The `omarchy-settings` package owns the system file; the user template contains only the active theme include and commented examples for personal overrides. Keeping the theme include in the user file lets users remove it without changing the packaged defaults. Individual inherited keybindings can be unmapped with an empty `map <shortcut>` directive, or all inherited bindings can be cleared with `clear_all_shortcuts yes`.

The system default uses `allow_remote_control socket-only` so Omarchy can query the active terminal directory over its Unix socket while Kitty rejects remote-control requests arriving through terminal output. Changing this setting requires restarting Kitty. The migration refreshes the exact previous stock config with a backup; customized configs retain their settings and ordering, with only explicit unrestricted `yes`, `y`, or `true` remote-control settings commented out.
