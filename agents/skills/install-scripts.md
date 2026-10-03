# Install Scripts

Read this before working under `install/` or on the system/user setup commands.

The ISO owns installation orchestration. This repo ships target-side setup
commands and reusable setup leaves:

- `bin/omarchy-apply-system` runs root-owned system setup during ISO finalization.
- `bin/omarchy-apply-hardware` runs idempotent hardware-specific setup and is called by `omarchy-apply-system`.
- `bin/omarchy-finalize-user` runs the per-user runtime finalization (skill symlinks, xdg-user-dirs, mime defaults, `install/user/all.sh`). Shipped user defaults are seeded by `/etc/skel` from `omarchy-settings`, not by this command. `bin/omarchy-reinstall-configs` is the explicit destructive resync of those defaults into an existing user's `$HOME`.
- leaf scripts under `install/` are sourced by `run_logged $OMARCHY_INSTALL/path/to/script.sh` and intentionally do not have shebangs.
- avoid `exit` in sourced setup scripts unless intentionally aborting setup.
- use `$OMARCHY_INSTALL` and `$OMARCHY_PATH` instead of hard-coded Omarchy paths.
- keep root-scoped hardware setup under `install/hardware/` and orchestrate it through `install/hardware/all.sh`.
- in an image build every `run_logged` leaf in `install/hardware/all.sh` is queued and runs on the machine's first boot instead (`bin/omarchy-provision-hardware`, see `docs/file-layout.md`), possibly offline, using packages already in the image, and before any user exists; keep those leaves idempotent and put nothing but `run_logged` lines in `all.sh`.
- gate platform-specific setup on `omarchy-hw-platform` or a predicate built on it, not on `uname -m`; architecture checks are only for ABI, binary availability or a repository's `$arch` (see `docs/file-layout.md`).
- keep every per-user setup leaf under `install/user/` (including `install/user/hardware/` and `install/user/first-run/`) so it is clear what must run for each user.
- The base install supplies matching kernel headers before hardware setup. DKMS installers should install their driver packages and assume the headers exist.
- prefer helper commands for package and command checks where available.

Raw `command -v`, `pacman`, and `pacman-key` are acceptable in package-helper
contexts where direct package-manager behavior is the point of the script.
