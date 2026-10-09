# Dots

Dots saves the history of the user's key configs and, optionally, shares them between machines through a private Git repository. It implements [`plans/dots.md`](../plans/dots.md) on top of mise's [dotfile history](https://mise.jdx.dev/dotfiles.html#tracking-files-in-place), which Omarchy already ships.

## Pieces

- `default/mise/dots.toml` is the audited list of tracked files, as mise `[dotfiles]` track entries. Nothing outside it is saved. `~/.config/hypr/monitors.lua` is tracked with a `machine` variant: each machine keeps its own history of it, and sync never applies one machine's version on another. The file also declares mise's `history-watch` service, under mise's documented name `mise-history`, and sets `history.sync = "manual"`.
- `omarchy dots enable` links that file to `~/.config/mise/conf.d/omarchy-dots.toml`, so package updates change the list for everyone. A user turns one entry off in `~/.config/mise/config.toml` with `enabled = false`. `omarchy-dots-enabled` tests the link.
- `omarchy-dots-capture <label> -- <command>` runs a command between two labeled snapshots (`mise dot capture`). It wraps `omarchy-migrate` (label `omarchy update`, only when migrations are pending), `omarchy-refresh-config`, the batch `omarchy-refresh-*` commands that reset tracked files, and `omarchy-reinstall-configs`. The command runs exactly once: `OMARCHY_DOTS_CAPTURED` marks the nested commands of a batch, and when mise cannot start the command, the wrapper runs it directly.
- Install runs `install/user/dots.sh` after mise is set up, which saves the first snapshot in the chroot; first run starts the watcher once the user manager is up. A migration turns dots on for existing installs.

## Standing down

`omarchy dots enable --auto` (install, first run, the migration) leaves dots off, and says why, when:

- the user ran `omarchy dots disable` (`~/.local/state/omarchy/dots-disabled`)
- `~/.git`, chezmoi, or yadm is present, or a key config is a symlink, as Stow makes
- mise lacks machine variants, `bootstrap --adopt --take-remote-all`, or the check that makes `mise dot sync` refuse versions that look like secrets (mise 2026.10.5)

`omarchy dots enable` reports the same reasons, and `--force` overrides the dotfile-manager check. Configs stay as they are, and `.bak` files from `omarchy refresh` keep working either way.

## Sync

`omarchy dots push` connects a private repository the first time (creating one with `gh` when signed in, and checking that an existing one is private), then saves and runs `mise dot sync`, which refuses to publish a saved version with a line that looks like a secret (a token, a private key, or a `*_KEY=`/`*_TOKEN=` assignment) and names the file and line. Omarchy never passes `--allow-plaintext-history`. When it creates the repository with `gh`, it runs `gh auth setup-git`, which makes `gh` the global git credential helper for github.com; the push says so. `omarchy dots pull` fetches and applies; when files conflict, it offers the repository's versions with `--take-remote-all`, which saves this machine's versions first.

On a machine that is not connected, `omarchy dots pull <url>` runs `mise bootstrap --adopt <url> --replace-history --take-remote-all --only dotfiles`. Every install has local history from its first snapshot, which is unrelated to the repository's, so the machine's history is replaced by the shared one; files that differ take the repository's version after this machine's version is saved on top of the adopted history.

Unlike the plan's squash-published `sync` branch, mise publishes the saved history itself, so earlier versions of tracked files reach the repository too. The tracked list is the boundary, and mise skips credential-named files. The repository must be private.
