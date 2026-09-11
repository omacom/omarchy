# Omarchy update process

This document describes the intended update behavior now that Omarchy is
package-backed. It covers the blessed update path plus what happens when a user attempts to
bypass it:

1. `omarchy update` — the blessed interactive Omarchy update flow.
2. `sudo pacman -Syu` — guarded by Omarchy and aborted with instructions unless
   the user explicitly bypasses the guard.

The design goal is:

- `omarchy update` owns the visible update pipeline: package transaction,
  migrations, post-update hooks, update-state refresh, and restart checks.
- Migrations run per-user after pacman finishes, because they may need `$HOME`,
  DBus/session state, a graphical session, sudo, or user interaction.
- Users who bypass `omarchy update` are nudged back by the pacman guard; if they
  explicitly bypass it, their session is notified when migrations are pending.

## State and coordination files

| Path | Owner | Purpose |
| --- | --- | --- |
| `${XDG_RUNTIME_DIR:-/tmp}/omarchy-update.lock` | user | Prevent overlapping update runs. Owned by `omarchy-update-lock`; compatibility wrappers inherit/respect it. |
| `/tmp/omarchy-update.log` | user | Transcript of `omarchy update`, used by `omarchy-update-analyze-logs`. |
| `~/.local/state/omarchy/current/` | user | Generated active theme, selected theme name, and current background symlink. |
| `~/.local/state/omarchy/migrations/` | user | Per-user migration markers. |
| `~/.local/state/omarchy/reboot-required` | user | Optional reboot marker checked by `omarchy-update-restart`. |
| `~/.local/state/omarchy/restart-*-required` | user | Optional service/app restart markers checked by `omarchy-update-restart`. The shell needs no marker: it is restarted unconditionally after every update. |

## Migration layout

See [`migrations.md`](../agents/skills/migrations.md) for the full migration model, authoring
guidelines, and troubleshooting notes.

Migrations live in:

```text
migrations/*.sh
```

They run as the current user through:

```bash
omarchy-migrate
```

Completion state is per-user:

```text
~/.local/state/omarchy/migrations/<migration filename>
```

Every user gets a chance to run every migration. Migrations run as the user;
privileged work should invoke the appropriate helper or privilege prompt.
Migrations must be idempotent; if one user already applied a machine-wide repair,
the migration should no-op for other users.

For watchers and diagnostics, `omarchy-migrate --pending` prints pending
migration names and exits `0` when any are pending. When no migrations are
pending, it prints nothing and exits non-zero.

## Raw pacman guard

The `omarchy` package installs an ALPM pre-transaction hook alongside its guard
binary:

```text
/usr/share/libalpm/hooks/00-omarchy-update-guard.hook
/usr/bin/omarchy-update-pacman-guard
```

It triggers on package upgrades and runs:

```bash
omarchy-update-pacman-guard
```

The guard detects direct pacman system-upgrade commands like `pacman -Syu` or
`pacman --sync --refresh --sysupgrade`. If the upgrade was not launched by an
Omarchy update command, the hook exits non-zero with `AbortOnFail`, which stops
the transaction before packages are changed.

`omarchy-update-system-pkgs`, `omarchy-refresh-pacman`, `omarchy-reinstall-pkgs`,
`omarchy-channel-set`, and the v4 upgrader run pacman through:

```bash
env OMARCHY_UPDATE_PACMAN=1 pacman ...
```

so the guard allows Omarchy-owned update flows. A user can intentionally bypass
the guard with:

```bash
sudo env OMARCHY_ALLOW_DIRECT_PACMAN=1 pacman -Syu
```

The guard does not start `omarchy update` itself because pacman is already in a
transaction setup path; it only aborts with instructions.

The `omarchy` package also installs ALPM hooks for `omarchy-settings` /
`omarchy-settings-dev` installs and upgrades. The pre-transaction hook runs
`omarchy-hyprland-reload-guard pause` to disable live Hyprland config reloads
while `/usr/share/omarchy/default/hypr/**` is replaced. The post-transaction
hook runs `omarchy-hyprland-reload-guard resume`, forces one `hyprctl reload`,
and restores the session's previous `misc.disable_autoreload` and
`debug.suppress_errors` values.

## Path 1: `omarchy update`

High-level flow:

```text
omarchy-update [--yes|-y|--non-interactive] [--hooks=run|skip] [--aur=run|skip] [--mise=run|skip] [--orphans=ask|keep|remove] [--reboot=ask|never|if-needed] [--restarts=run|skip]
  ├─ parse/validate CLI flags (misuse exits 2 before transcript, lock, or side effects) and normalize/export unattended policy env
  ├─ unattended only: re-exec through omarchy-update-run to install scoped privilege adapters (before transcript, lock, and free-space checks)
  ├─ ensure transcript logging through script(1) → /tmp/omarchy-update.log
  ├─ omarchy-update-lock
  │    └─ acquire the update lock and run omarchy-update inside it
  ├─ omarchy-update-requires-free-space
  │    └─ abort below the configured free-space threshold on /
  ├─ interactive: omarchy-update-confirm; unattended: print Unattended update (full|strict) summary plus destructive-policy lines, no confirmation prompt
  ├─ omarchy-update-pkg-prune
  │    └─ trim the pacman cache to two versions per package, deliberately before the snapshot since the cache lives on the snapshotted subvolume
  ├─ create snapper snapshot (skipped silently without snapper; snapper installed but unconfigured fails the snapshot loudly, pointing at install/config/snapper.sh, and the update continues without one)
  ├─ omarchy-update-stay-awake start
  ├─ run package updates, migrations, policy-gated hooks/AUR/mise, orphan handling, and log analysis
  ├─ omarchy-update-status
  │    └─ refresh or clear the shell update indicator
  ├─ omarchy-update-stay-awake stop
  │    └─ release the sleep inhibitor and restore shell idle state, if changed (released before restart so an automatic reboot cannot strand it)
  └─ omarchy-update-restart (policy-gated reboot and service/shell restarts)
```

Important behavior:

- In dev-link mode, `omarchy update` fast-forwards the active checkout from its
  configured upstream before changing system packages or running migrations.
- CLI contract: `omarchy update [--yes|-y|--non-interactive] [--hooks=run|skip] [--aur=run|skip] [--mise=run|skip] [--orphans=ask|keep|remove] [--reboot=ask|never|if-needed] [--restarts=run|skip]`. No arguments keeps current interactive behavior. `-y` and `--yes` are identical unattended first-party full-pipeline modes. `--non-interactive` is unattended strict mode. `-y`/`--yes` plus `--non-interactive` may combine; strict wins regardless of order. Only exact `--name=value` forms are accepted. Repeating the same policy with the same value is allowed; contradictory repeats fail with exit 2. `ask` with either unattended mode fails with exit 2 regardless of flag order. Unknown args, missing/invalid values, and positional args fail with exit 2 before any transcript, lock, or side effects. If `-h`/`--help` is present anywhere, usage is printed with exit 0 without validating other args or running any steps.
- Mode defaults: interactive (no flags) uses hooks/aur/mise/restarts=run with orphans=ask and reboot=ask; `-y`/`--yes` (full) uses hooks/aur/mise/restarts=run with orphans=keep and reboot=never; `--non-interactive` (strict) uses hooks/aur/mise=skip with restarts=run, orphans=keep, and reboot=never. Explicit `--hooks`/`--aur`/`--mise`/`--orphans`/`--reboot`/`--restarts` values override the mode defaults order-independently.
- Policy env (normalized from argv before transcript/lock/privilege/space work; public flags are authoritative and stale inherited policy values never leak): `OMARCHY_UPDATE_UNATTENDED=1` for either unattended mode and unset when interactive; `OMARCHY_UPDATE_STRICT=1` only for strict mode and unset otherwise; always-exported `OMARCHY_UPDATE_HOOKS`/`OMARCHY_UPDATE_AUR`/`OMARCHY_UPDATE_MISE` (`run|skip`), `OMARCHY_UPDATE_ORPHANS` (`ask|keep|remove`), `OMARCHY_UPDATE_REBOOT` (`ask|never|if-needed`), and `OMARCHY_UPDATE_RESTARTS` (`run|skip`). Helpers called directly with only `OMARCHY_UPDATE_UNATTENDED=1` keep safe defaults (`OMARCHY_UPDATE_ORPHANS` falls back to `keep`, `OMARCHY_UPDATE_REBOOT` falls back to `never`, `OMARCHY_UPDATE_RESTARTS` falls back to `run`).
- Scoped privilege environment: unattended runs re-exec through hidden `bin/omarchy-update-run` (`omarchy-update-run <command> [args...]`) before transcript/lock work; interactive runs never touch the runner and inherited `OMARCHY_UPDATE_UNATTENDED`/`OMARCHY_UPDATE_ENV_READY` cannot turn an interactive invocation unattended. The runner captures the original real sudo absolute path from `PATH` before prepending `$OMARCHY_PATH/default/omarchy/update-bin`, exports `OMARCHY_UPDATE_REAL_SUDO` plus `OMARCHY_UPDATE_ENV_READY=1`, and execs the command argv without eval/shell interpolation. Re-entry uses `OMARCHY_UPDATE_RUN_REEXEC=1` and refuses to continue when the environment is still not ready. Missing/unusable adapter installs or sudo paths fail nonzero with an actionable message. The `sudo` adapter execs the captured real sudo as `exec "$real_sudo" -n "$@"`, preserves stdin/stdout/stderr and the child exit status, rejects prompt-enabling options (`-S`/`--stdin`, `-A`/`--askpass`, `-p`/`--prompt`, including combined short clusters), never adds password/askpass/stdin-auth fallbacks, and never consumes piped data meant for the child. The `pkexec` adapter always fails closed with exit 1 and never execs the real pkexec, so no graphical auth dialog can appear. The adapter directory is subprocess-scoped `PATH` prepend only: it is not installed as system `sudo`, it covers only normal `PATH` resolution, and it is explicitly not a security boundary. Absolute-path sudo, cleared-`PATH` callers, custom credential programs, package-maintainer hooks, and other arbitrary scripts bypass it.
- Policy-gated steps: `OMARCHY_UPDATE_HOOKS=skip` prints `Skipping post-update hooks (--hooks=skip)` instead of running `omarchy-hook post-update`; `OMARCHY_UPDATE_AUR=skip` prints `Skipping AUR package updates (--aur=skip)` instead of running `omarchy-update-aur-pkgs`; `OMARCHY_UPDATE_MISE=skip` prints `Skipping mise updates (--mise=skip)` instead of running `omarchy-update-mise`. Opting into external execution in strict mode still runs but first prints a guarantee-relaxation warning to stderr (`Warning: --hooks=run in strict mode relaxes the non-interactive guarantee; arbitrary hook code may prompt`, and the matching `--aur=run`/`--mise=run` lines). Unattended runs print `Unattended update (full): hooks=..., aur=..., mise=..., orphans=..., reboot=..., restarts=...` (or the `(strict)` form), plus `Orphan policy: remove -- orphaned packages will be removed without confirmation` when `--orphans=remove` and `Reboot policy: if-needed -- system will reboot automatically when required (may close unsaved applications)` when `--reboot=if-needed`. Migrations stay compulsory and ordered; a deferred/failed migration exits nonzero, stays pending, and stops later migrations/steps/reboot. Package-vs-package conflicts exit nonzero with `This upgrade needs an answer. Run omarchy update interactively to give it.` when unattended or headless instead of prompting.
- Keyring unattended precheck: `omarchy-update-keyring` runs `sudo -n true` first when `OMARCHY_UPDATE_UNATTENDED=1`; when that probe fails it prints `omarchy-update-keyring: unattended update cannot authenticate with sudo (sudo -n failed); run interactively or refresh sudo credentials before retrying` and exits 1 before privileged work. Required-operation failures propagate (`set -euo pipefail`); `Keys are correct` prints only on success.
- Inhibitor: `omarchy-update-stay-awake start` uses `sudo -n` (with a best-effort `sudo -n -v` probe) when `OMARCHY_UPDATE_UNATTENDED=1` and never selects `pkexec` unattended, even with a PTY. Background inhibitor startup is observed with `kill -0` plus zombie rejection; when acquisition fails it prints `Warning: sleep inhibitor failed to start; continuing without sleep inhibition.`, removes the pid file, and continues with exit 0 rather than recording a stale success. PID ownership, lock-FD closure, cancellation/cleanup, and interactive behavior are unchanged.
- Git unattended env: `omarchy-update-dev` (before `pull --ff-only`) and `omarchy-update-available` (before `fetch --quiet`) export `GIT_TERMINAL_PROMPT=0`, empty `GIT_ASKPASS=`, and `GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -oBatchMode=yes}"` when `OMARCHY_UPDATE_UNATTENDED=1`. Empty `GIT_ASKPASS` falls back to terminal prompts, which `GIT_TERMINAL_PROMPT=0` then disables, so auth failures fail closed instead of hanging; `GIT_SSH_COMMAND` in env wins over `core.sshCommand`, so a user custom `sshCommand` program is never executed unattended while an explicit `GIT_SSH_COMMAND` is preserved. No new host keys are auto-accepted (`BatchMode` fails closed on unknown hosts). User credential helpers remain an external-execution boundary.
- Exit codes: `0` means selected mandatory work completed while deliberately skipped optional work was reported (it does not mean every possible component updated). `2` means CLI misuse (unknown/missing/invalid/positional args, contradictory repeats, `ask` under unattended, invalid helper policy values). Other nonzero means a required update/migration/explicit-removal/explicit-reboot step failed; downstream destructive work is not run and existing transaction failure codes propagate where possible. Optional prune/snapshot keep warn-and-continue behavior. Interactive no-argument behavior is otherwise unchanged.
- The free-space requirement uses a 10 GiB threshold and stops the update before
  confirmation when it is not met. If free space cannot be determined, the
  check is silently skipped. Set `OMARCHY_UPDATE_FORCE=1` to bypass the check.
- `omarchy update` checks/runs migrations in the same visible terminal via
  `omarchy-migrate` after pacman finishes.
- A failure should leave enough output in `/tmp/omarchy-update.log` and the
  terminal transcript to debug.

## Path 2: direct `sudo pacman -Syu` attempt

High-level flow:

```text
sudo pacman -Syu
  ├─ pre-transaction guard aborts and tells the user to run omarchy update
  └─ if explicitly bypassed, upgrades omarchy and related packages
  └─ at that user's next login
       ├─ graphical-session.target starts
       ├─ omarchy-migrate-notify.service starts after it
       ├─ omarchy-migrate-notify checks omarchy-migrate --pending
       ├─ if this user has missing migration state, show notification
       └─ click opens terminal: omarchy-migrate
```

Login is deliberately the only trigger. A watcher on the packaged migration
directory cannot distinguish a bypassed `pacman -Syu` from the package
transaction inside a normal `omarchy update`, so it fired notifications for
migrations that `omarchy-migrate` was about to apply in the visible update
terminal. The retired unit was `omarchy-update-user-notify.path`.

Retiring that watcher through a migration cannot come in time for the update
that retires it: pacman writes the migration directory, the watcher fires, and
only then does `omarchy-migrate` reach the migration that stops it. So the
notifier also refuses to run while `omarchy update` holds its
`$XDG_RUNTIME_DIR/omarchy-update.lock`, which covers the stale watcher and any
trigger added later — during an update, every pending migration is by
definition already being applied a step away. It checks again after waiting for
the notification server, since that wait is long enough for an update to start
underneath it.

The notifier reads only its own user's runtime directory, never the `/tmp` path
`omarchy-update` falls back to when `XDG_RUNTIME_DIR` is unset. A shared lock
file belongs to whoever created it first, so honouring it would let one user
silence another user's notification. Missing an update and showing a redundant
toast is the better failure.

Suppression is why `omarchy-update-stay-awake` starts its sleep inhibitor with
the lock descriptor closed. That inhibitor outlives the step that starts it, so
an update killed before cleanup would otherwise leave it holding the flock
indefinitely — blocking later updates and, now that the notifier reads the same
lock, silencing migration notifications at every login.

Fallbacks:

- `omarchy-provision-first-run` enables `omarchy-migrate-notify.service`, which also
  covers users created after install: their per-user migration markers are
  missing, so their first login prompts them to run every shipped migration.
- The package ships `omarchy-update-user-notify.service` as a symlink onto
  `omarchy-migrate-notify.service`. Users set up before the rename hold an
  absolute `graphical-session.target.wants` symlink to the old path, and the
  migration that repoints it only runs for users who run an update — the
  opposite of who the notifier is for. The alias can be dropped once installs
  have run migration `1785095882`.
- The notifier is ordered after `graphical-session.target`, so an action that
  launches through `uwsm-app` cannot block the target that gates UWSM's app
  daemon.
- The notifier waits for a live notification server before sending, because
  `graphical-session.target` can be reached before the shell claims
  `org.freedesktop.Notifications`.
- The notifier is only a prompt. It does not run migrations in the background.
- A session that is already open when another user updates is not re-checked;
  it picks the migrations up at its next login, or whenever that user runs
  `omarchy-migrate` or `omarchy update`.
- Direct pacman updates do not run `omarchy-hook post-update` unless the user
  explicitly runs that hook; without a package-update marker, the only pending
  state we can derive is missing per-user migration markers.

## Shell update indicator

The bar widget `omarchy.system-update` runs:

```bash
omarchy-update-available
```

`omarchy-update-available` checks the active Omarchy sources for updates:

- new upstream commits for the active dev-linked checkout
- `omarchy-dev`, when installed
- otherwise `omarchy`, when installed

The dev check fetches the checkout's configured upstream before comparing it
with `HEAD`. A failed fetch is quiet and falls back to the existing remote-
tracking state.

Exit codes:

- `0` — Omarchy updates are available; stdout is the update list.
- non-zero — no Omarchy updates are available; stdout says Omarchy is up to date.

The widget runs this check on shell startup and every six hours. Clicking the
update icon launches `omarchy-update` in a floating terminal.

## Channels and versions

Updates install whatever the active channel points at. `omarchy-channel-set
<stable|rc|edge|dev>` switches channels: the three package channels select
which pacman repo the mirrorlist points at (and swap between the `omarchy` and
`omarchy-dev` packages through a guard-allowed pacman run), while `dev` links
the runtime to a git checkout via the dev-link mechanism, after which
`omarchy update` fast-forwards that checkout instead of upgrading a package.

There is no version file at runtime. `omarchy-version` derives the version from
`pacman -Q` on whichever package is installed, or reports `dev (<hash>)` for a
linked checkout, and `omarchy-version-channel` sniffs the mirrorlist and
pacman.conf to answer which channel is active.

## Update-related binaries

This inventory is intentionally opinionated. Some commands are useful as stable
leaf commands; others exist mostly because the old update flow accreted small
scripts.

| Binary | Current purpose | Keep? / Question |
| --- | --- | --- |
| `omarchy-update` | Public user command. Adds transcript logging, confirmation, snapshot, and restart checks around the locked, sleep-inhibited update pipeline. | **Keep.** This is the blessed entry point and orchestrates the update pipeline. |
| `omarchy-update-lock` | Hidden command wrapper that holds the per-user update lock while its child runs. | **Keep internal/hidden.** Isolates update concurrency and lock descriptor handling. |
| `omarchy-update-stay-awake` | Hidden helper that starts or stops update-owned sleep and idle inhibition, restoring only the state it changed. | **Keep internal/hidden.** Keeps inhibitor ownership and cleanup together. |
| `omarchy-update-status` | Hidden helper that refreshes or clears the shell update indicator after rechecking available updates. | **Keep internal/hidden.** Keeps shell status synchronization out of the main pipeline. |
| `omarchy-update-confirm` | Gum confirmation copy for `omarchy update`. | **Question.** Could be inlined into `omarchy-update`; separate file only helps keep copy isolated. |
| `omarchy-update-dev` | Fast-forwards the active dev-linked checkout from its configured upstream; no-ops for package-backed installs. | **Keep.** Runs before package updates so a checkout conflict stops the update before system mutation. |
| `omarchy-update-keyring` | Ensures Omarchy keyring and Arch keyring are current before the main transaction. | **Keep, but review.** It uses targeted `pacman -Sy` for keyring bootstrapping; acceptable for this special case but should remain tightly scoped. |
| `omarchy-update-system-pkgs` | Runs `sudo env OMARCHY_UPDATE_PACMAN=1 pacman -Syu --noconfirm` with `--overwrite '/usr/share/omarchy/*'`, capturing stderr to a report file; on failure it execs `omarchy-update-system-pkgs-when-conflicted`. | **Keep for now.** Small leaf command, clear/testable. |
| `omarchy-update-system-pkgs-when-conflicted` | Hidden conflict handler: quarantines unowned conflicting files under `/var/lib/omarchy/replaced`, retries the upgrade once, restores files the upgrade didn't claim, and hands package-vs-package conflicts to an interactive pacman run (never under `-y`). | **Keep internal/hidden.** Keeps conflict recovery out of the happy path. |
| `omarchy-update-pkg-prune` | Trims the pacman cache to two versions per package (`paccache -rk2`) before the snapshot, keeping the offline downgrade path while capping snapshot growth. | **Keep internal/hidden.** |
| `omarchy-update-requires-free-space` | Aborts the update below a 10 GiB free-space threshold on `/`; silently skipped when free space cannot be determined; `OMARCHY_UPDATE_FORCE=1` bypasses. | **Keep internal/hidden.** |
| `omarchy-migrate` | Public migration command. Waits for pacman, then runs all pending migrations for the current user. Supports `--pending`. | **Keep.** This replaces the discarded `omarchy-update-user-finalize` name and no longer needs `--force`. |
| `omarchy-update-pacman-guard` | ALPM pre-transaction guard that aborts direct `pacman -Syu` style upgrades unless Omarchy set `OMARCHY_UPDATE_PACMAN=1` or the user explicitly set `OMARCHY_ALLOW_DIRECT_PACMAN=1`. | **Keep internal/hidden.** This is what nudges users back to `omarchy update`. |
| `omarchy-migrate-notify` | Internal login-time notification helper. Uses `omarchy-migrate --pending` and shows a notification only when this user has pending migrations. | **Keep internal/hidden.** Clear name now that the public command is `omarchy-migrate`. |
| `omarchy-update-user-notify` | Hidden compatibility wrapper for `omarchy-migrate-notify`. | **Temporary.** Keep only for old callers. |
| `omarchy-update-available` | Update checker for shell widget and post-update refresh. | **Keep.** Could eventually be renamed `omarchy-update-check`, but current name matches widget semantics. |
| `omarchy-update-aur-pkgs` | Updates AUR packages with `yay -Sua` if foreign packages exist and AUR is reachable. | **Question.** Omarchy is package-backed now, but users may still install AUR packages. Keep for now. |
| `omarchy-update-mise` | Runs `MISE_MINIMUM_RELEASE_AGE=0 mise up` for mise-managed tools — the override of mise's release-age cooldown is the point. | **Keep.** Mise-managed tools are intentionally part of the blessed update path. |
| `omarchy-update-orphan-pkgs` | Lists orphans and applies the orphan policy: `ask` prompts interactively, `keep` lists and retains, `remove` removes without confirmation via `sudo pacman -Rns --noconfirm`. | **Keep for now.** Safe because unattended defaults to `keep` and removal requires explicit `--orphans=remove`. |
| `omarchy-update-analyze-logs` | Scans `/tmp/omarchy-update.log` for known failure patterns, currently initramfs generation. | **Keep/expand.** Useful safety net; should grow only for high-signal checks. |
| `omarchy-update-restart` | Prompts for reboot after kernel/Hyprland updates, restarts components with `restart-*-required` markers, and always restarts the shell. | **Keep.** Important final step; may eventually include service-restart checks. |
| `omarchy-update-firmware` | Manual firmware update command using fwupd. Not part of the normal update pipeline. | **Keep separate.** Firmware is not a routine system update step. |
| `omarchy-update-time` | Restarts `systemd-timesyncd`. | **Question.** Not really an update command. Consider renaming/moving under system/time maintenance. |

## Closed decisions

1. **Migrations run per-user from the update pipeline**
   - `omarchy update` runs `omarchy-migrate` after pacman finishes.
   - Package-time migration runners do not apply migrations inside pacman.
   - Every user has per-user migration markers, and migrations must be
     idempotent when they repair machine-wide state.

2. **Migration notification naming**
   - The real helper is `omarchy-migrate-notify`, started by
     `omarchy-migrate-notify.service`.
   - `omarchy-update-user-notify` remains only as a hidden compatibility wrapper.

3. **Update pipeline ownership**
   - `omarchy-update` owns the full update pipeline now.

4. **Mise remains in the blessed update path**
   - `omarchy-update-mise` intentionally runs as part of `omarchy update`.

5. **Orphan cleanup stays in the update path for now**
   - Interactive `ask` still prompts before removal; unattended modes default to `keep`, and only explicit `--orphans=remove` removes without confirmation.

6. **Direct pacman user follow-up is based on actual migration state**
   - Direct `sudo pacman -Syu` no longer uses a fake user-update marker.
   - User notifications are shown only when `omarchy-migrate --pending` finds
     missing per-user migration state.

## Remaining concerns

1. **Pacman guard scope**
   - The guard detects direct pacman sysupgrade invocations and allows Omarchy
     commands that set `OMARCHY_UPDATE_PACMAN=1`.
   - We may regret blocking some legitimate package-manager frontends or
     maintenance flows. Keep an eye on what should be allowed versus redirected
     to `omarchy update`.

2. **Pacnew/pacsave handling is still missing**
   - Package-backed Omarchy should warn about or help process `.pacnew` and
     `.pacsave` files after updates.
