# Temporary passwordless sudo

`omarchy-sudo-passwordless` publishes a bounded grant for the numeric UID authenticated by sudo. Its user interface runs without a reusable sudo timestamp; fixed installed internal actions run as root and serialize on `/run/lock/omarchy-sudo-passwordless.lock`.

## Grant lifecycle

Root state records the resolved account name, absolute expiry epoch and unique timer name. A calendar timer is armed and verified before the generated policy becomes active. The sudoers rule also embeds the same UTC deadline with `NOTAFTER`, so sudo independently rejects it after expiry even if timer cleanup is delayed. Publication rechecks the package-owned boot cleanup before and after installing policy. Policy revocation must succeed before expiry jobs are stopped; a deletion error leaves those jobs armed and reports that administrator cleanup is required.

An internal status result is `0` for an active, validated grant and `3` for confirmed inactive access. All other results are errors, including failed authentication and failed revocation. The user interface only offers a new grant after result `3`. It must not turn an inspection failure into a claim that no grant exists.

Each new expiry callback carries its timer identity. A delayed predecessor cannot revoke a newer grant. Already scheduled UID-only callbacks remain compatible by checking the current grant's expiry. Boot-time tmpfiles cleanup removes the reserved generated filename namespace before users log in; it does not run during routine non-boot tmpfiles maintenance.

## Package ownership

The packaging companion must put the publication/expiry command, `omarchy-security-functions` `omarchy-nopasswd-sudo.conf` and the pre-transaction revocation hook in the settings package together. Removing the desktop runtime alone must leave a working expiry command behind. Stable and development package pairs must transfer ownership in one transaction without duplicate files.

Before settings removal or upgrade, the installed ALPM `PreTransaction` hook invokes the fixed `__package-removing` action, acquires the same grant lock, sets `/run/omarchy-sudo-passwordless-package-removing` and revokes existing policy. The marker prevents a waiting publisher from creating a new grant while package files change. A successful installation clears the marker only after boot cleanup exists. The hook uses `AbortOnFail` because a scriptlet failure alone does not abort pacman. The scriptlets repeat cleanup as a fallback for upgrades from older packages that have no installed hook. New grants require both the boot rule and hook before publication. Failed or interrupted transactions leave the marker set; retry the package transaction successfully before requesting another grant.

The runtime marker need not survive reboot: pre-removal revokes the old grants before package files disappear, and a new invocation independently verifies boot cleanup. Both root operations use fixed machine paths. The marker is not a user-controlled mode switch.

## Validation

`test/shell.d/nopasswd-sudo-expiry-test.sh` covers the public interface, cold authentication, timer setup, boot cleanup, package transitions and lock contention. `test/shell.d/passwordless-grant-lifecycle-test.sh` covers publication/cleanup failures, error status, supported account syntax, predecessor callbacks and the shared package-removal lock. Supply `OMARCHY_PKGS_PATH` as either a repository root or its `pkgbuilds` directory.

These tests use private filesystem fixtures and mapped privileged commands. Package archive ownership, actual install/upgrade/removal, real calendar expiry, suspend/resume and boot cleanup must also be validated in a disposable VM before claiming release readiness. Changes to the common library require integration checks on the downstream update, migration, installer, package-picker and diagnostic PRs.
