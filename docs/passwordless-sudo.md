# Temporary passwordless sudo

`omarchy-sudo-passwordless` publishes a bounded grant for the numeric UID authenticated by sudo. Its user interface runs without a reusable sudo timestamp; fixed installed internal actions run as root and serialize on `/run/lock/omarchy-sudo-passwordless.lock`.

## Grant lifecycle

The sudoers rule is the only grant record: it contains the resolved account name and a UTC `NOTAFTER` deadline enforced by sudo itself, including after suspend. Publication validates a dot-prefixed temporary file with `visudo`, arms a calendar cleanup timer, then atomically renames the complete rule into place. No other file authorizes anything or is consulted to decide whether a grant exists; the advisory status marker below only mirrors the deadline for display. Failure after renewal starts removes the old grant; failed revocation remains an error and leaves the cleanup timer armed.

An internal status result is `0` for an active, validated grant and `3` for confirmed inactive access. All other results are errors, including failed authentication and failed revocation. The user interface only offers a new grant after result `3`. It must not turn an inspection failure into a claim that no grant exists.

Calendar timers clean up expired files; their liveness does not define authorization. Callbacks read the current rule and remove it only when expired. Earlier callbacks cannot shorten a renewed grant, so no timer identity needs to be persisted. Old UID-only and token-bearing callbacks remain accepted. Pending callbacks after renewal or manual disable are harmless and expire within the maximum 24-hour grant window. Boot-time tmpfiles cleanup removes the reserved generated filename namespace before users log in; routine non-boot tmpfiles maintenance leaves live grants alone.

Legacy cleanup uses a root-owned machine marker under `/var/lib/omarchy/migrations/`, written only after successful cleanup under the grant lock. Later accounts can finish their migration queues without sudo and without revoking grants created after the repair. Old grant state files are no longer consulted. A legacy grant is recognized by its exact filename and rule relationship, since the old command wrote the caller's unvalidated name into both, so accounts outside the current name policy are still cleaned up. The generated filename prefix is reserved: boot cleanup and the package hook already remove everything under it, and the old writer could emit a rule whose body differs from its filename, so the migration moves any other file found there into a fresh root-only directory under `/var/lib/omarchy/sudoers-quarantine/`, as `policy` with the original name stored beside it, rather than leaving it live or deleting its content.

## Status marker

The bar indicator and `omarchy-sudo-passwordless status [--json]` run without sudo, but the sudoers rule is readable only by root. Under the grant lock, publication therefore also writes the deadline in epoch seconds to `/run/omarchy-sudo-passwordless/<uid>`, a mode-0644 file in a root-owned mode-0755 directory that only root can write. The marker is advisory: sudo never reads it, and status reports only what it says.

Ordering keeps the marker from hiding a grant. It is published before the rule is renamed into place and removed only after the rule is gone, so a live rule always has a marker, and a marker without a rule can only overstate access. A renewal that shortens a grant first publishes the old, later deadline, and writes the shorter one only after the new rule is in place, so a publisher killed in between cannot leave the old rule live behind an expired marker. Revocation, expiry callbacks, migration cleanup and package removal all remove markers whose rules are gone; a marker whose rule could not be removed stays. `/run` is a tmpfs, so markers vanish at reboot along with the boot-time removal of grants. Publication and removal refuse a status directory that is not a root-owned mode-0755 directory.

Public status exits `0` with an unexpired marker, `3` with none or an expired one, and `2` when a marker is present but untrusted or malformed, or when the status directory exists but is not a trusted directory the caller can search, since that would hide any marker in it. The indicator shows exit `2` as active with an unknown status rather than as inactive. Public `disable` calls the fixed internal revoke action directly; while a grant is live sudo needs no password for it, so the indicator can revoke without a terminal and falls back to the interactive toggle when sudo asks for one.

## Package ownership

The packaging companion must put the publication/expiry command, `omarchy-security-functions`, `omarchy-nopasswd-sudo.conf`, and the pre-transaction revocation hook in the settings package together. Removing the desktop runtime alone must leave a working expiry command behind. Stable and development package pairs must transfer ownership in one transaction without duplicate files.

Before settings removal or upgrade, the installed ALPM `PreTransaction` hook invokes the fixed `__package-removing` action, acquires the same grant lock, sets `/run/omarchy-sudo-passwordless-package-removing` and revokes existing policy. The marker prevents a waiting publisher from creating a new grant while package files change. A successful installation clears the marker only after boot cleanup exists. The hook uses `AbortOnFail` because a scriptlet failure alone does not abort pacman. The scriptlets repeat cleanup as a fallback for upgrades from older packages that have no installed hook. New grants require both the boot rule and hook before publication. Failed or interrupted transactions leave the marker set; retry the package transaction successfully before requesting another grant.

The runtime marker need not survive reboot: pre-removal revokes the old grants before package files disappear, and a new invocation independently verifies boot cleanup. Both root operations use fixed machine paths. The marker is not a user-controlled mode switch.

## Validation

The three passwordless-sudo test suites share a private filesystem and command fixture. They cover caller validation, the public prompt boundary, the status marker, atomic publication, renewal failures, expiry, old callbacks, machine migration, and the source/package lock. Supply `OMARCHY_PKGS_PATH` as either a repository root or its `pkgbuilds` directory. An optional `OMARCHY_TEST_SUDOERS` path to sudo's upstream `testsudoers` executable evaluates the generated policy before and after its deadline without root or changing host policy.

These local tests do not establish release readiness. The simplified candidate needs fresh installed-package, suspend/resume, boot-cleanup, and package-removal validation in a disposable VM. The shared security library and its interface are unchanged for downstream PRs.
