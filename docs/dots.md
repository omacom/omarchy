# Preference history and explicit sharing

This is the manual publish/pull portion of `plans/dots.md`, with local recovery snapshots. Automatic update hooks and timer snapshots are deliberately deferred; none of those integration points is modified here.

`default/dots/manifest` is the audited set of home-relative regular files. `shared` paths can travel between machines; `local` paths have history only. Input settings are shared: keyboard settings apply everywhere, while touchpad, mouse, tablet, and named-device settings simply remain inactive on machines without matching hardware. Monitor, autostart, and the main Hyprland config stay local because they describe a machine's physical layout or installed programs. Installed theme/plugin clones, generated state, browser profiles, and credentials have no manifest entry. Wildcards match path components rather than crossing directory boundaries. An unknown path or non-regular incoming object is rejected.

`~/.local/share/omarchy/dots.git` is a private bare repository. No `.git` is created in `$HOME`; no git worktree operation runs against `$HOME`. The helper constructs trees using blobs and a temporary index containing only manifest paths. Git receives isolated global configuration, no inherited Git environment, disabled hooks/signing/attributes, and a synthetic identity. A local lock serializes commands. Known dotfile managers and symlinks in manifest paths put the feature into dormant mode instead of changing those files.

## Refs and publication

- `history` is local snapshot history. It records manual snapshots and the state before and after apply/restore.
- Remote `sync` is shared state. Each publish has only the preceding remote `sync` commit as its parent, never a local history commit. Historical local secrets therefore cannot leak merely because someone once saved them locally and later removed them.
- `refs/omarchy/last-sync` records the last state this machine applied or published. A changed remote refuses push until pull. Push is a normal non-forced Git update, so a racing publisher cannot be overwritten.
- `refs/omarchy/pending` keeps synthesized merge objects reachable while a user resolves conflicts. No preferences change until conflicts are resolved and the user continues.

## Applying and recovering

Pull compares the previous shared state, current local files, and incoming state. Non-overlapping text edits merge; add/add, modify/delete, binary conflicts and conflicting edits require explicit resolution. This differs from the plan's remote-wins fallback: both versions remain available and the user chooses in the terminal menu. Local recovery snapshots are still created before applying anything.

`~/.local/state/omarchy/dots/pending.json` records the before/after trees, recovery snapshot, unresolved files, remote commit, and phase. Only `continue` applies a resolved update. If the user edits a file while reviewing, continue refuses to overwrite that new work. An interrupted application accepts only the original or proposed contents per path, allowing retry; cancel rolls back partially applied paths unless they were edited afterward. The pending record is removed only after the post-apply snapshot and sync reference update succeed.

Individual file replacement uses a sibling temporary file, fsync, and rename. Multiple files are not one atomic filesystem transaction; the recovery snapshot and persistent pending record cover interruption. Applied files receive private permissions, with the executable bit retained. Deletions are explicit tree changes, not an overlay that leaves obsolete files behind.

## User surface and verification

Setup > Preferences creates local history and optionally connects to an existing private SSH repository or creates a private GitHub repository through `gh`. GitHub privacy is checked; other SSH servers remain the user's responsibility. System > Preferences exposes snapshot, history, diff, publish, apply, restore, and pending-update recovery. Nothing publishes automatically.

`test/shell.d/dots-test.sh` uses real local bare Git repositories and isolated homes. It covers two-machine round trips, deletions, non-overlapping edits, persistent conflict resolution, recovery snapshots, edits made during review, stale push refusal, interrupted apply/cancel, symlink dormancy, unlisted remote paths, global Git isolation, and separation of local history from published history. Graphical verification belongs in a disposable Omarchy VM.
