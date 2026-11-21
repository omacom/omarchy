# Foreign package ABI mismatches on snapshot channels

Treat a foreign package whose ABI bounds do not fit the selected snapshot as a compatibility planning problem before committing the update. Keep dependency enforcement in pacman/libalpm, and use native package builds for explicitly tracked applications when a compatible published package is unavailable.

## Reproduced case

On 2026-11-21, the stable repository and the workstation both had Omarchy `4.5.0-3` and OpenCV `5.0.0-13`. Gaze's published `0.5.2` daemon and GUI packages required `opencv>=5.1` and `opencv<5.2`. Updating the AUR `gaze-bin` package therefore selected a binary that the configured stable snapshot could not satisfy. The three installed Gaze packages were `0.3.7-1`.

This case is distinct from a missing mirror file or a make-dependency provider conflict. The snapshot's native system transaction prepared successfully; replacing Gaze with the newer publisher binaries did not. There was no newer stable Omarchy version to select as an intermediate step. Re-running the ordinary update or rebuilding a binary-download PKGBUILD would still select the same incompatible payload.

A native build of Gaze `0.5.2` against that snapshot produced packages requiring `opencv>=5.0` and `opencv<5.1`. Preserving the installed `gaze-bin`, `gaze-gui-bin` and `gaze-omarchy-bin` identities allowed the complete candidate group to prepare with libalpm. The daemon, GUI, PAM modules and ONNX runtime passed loader checks after installation in a disposable container. Gaze's application build change is tracked separately in [GunduLabs/gaze#1027](https://github.com/GunduLabs/gaze/pull/1027).

## Recommended handling

Add an opt-in compatibility preflight after keyring preparation and before the system package transaction. It should inspect the target repository metadata and the already-installed tracked application group, then select this policy:

1. Prefer a compatible published package from the approved provider, using the native repositories first when they supply it.
2. Reuse a previous local build if its identity, provenance and hashes are valid and the complete target transaction still prepares successfully.
3. Otherwise build the approved source recipe in an isolated environment against the selected target repositories and architecture, then prepare all resulting candidates together with the OS transaction.
4. Stop with the actual dependency failure when no approved candidate fits. Report untracked applications and suggest a reviewed adapter; do not turn error text into executable build instructions.

On a later update request, return to the compatible published package even if the temporary local build has a higher packaging revision. A local source build is a temporary compatibility path, not a permanent package pin or replacement repository policy. An unrelated repository change should not trigger another build if the existing artifact still satisfies the target transaction.

Keep user configuration at the application/policy level, for example:

```toml
[applications]
gaze = "prefer-upstream"
```

The reviewed provider contains the package mapping, trusted upstream, source recipe and supported architectures. The planner must respect existing pacman pins and evaluate the installed package state, effective repository order, servers, metadata hashes and architecture. An Omarchy display version alone does not describe the dependency target.

## Native boundaries

Use libalpm for transaction preparation, makepkg for package construction, devtools clean chroots or another isolated native build environment, and repo-add for staged candidates. Keep builds outside the native package transaction lock. A pre-transaction ALPM hook cannot recover a dependency failure that happens before hooks run; a post-update hook is too late for a blocked system transaction and is best-effort in the current update pipeline.

Import approved artifacts into root-owned storage, validate the restricted manifest and package identities, and retain package verification. Revalidate the installed state and target metadata under the native transaction lock before commit. Do not run arbitrary user-supplied pacman configuration as root, loosen the regular repositories' signature policy, remove ABI bounds, or use `--nodeps` to force an incompatible binary onto the snapshot.

Pass the selected package group to the existing guarded `omarchy-update-pacman` transaction so library and application changes can commit together. Preserve its systemd scope, the update lock, snapshot, migrations, service restarts and boot verification. Exclude managed targets only from that update's later AUR pass so it cannot immediately overwrite the selected build. The next preflight should evaluate the approved upstream packages again.

## Opt-in integration contract

The updater activates the optional coordinator when `~/.config/omarchy/update-compat.toml` is nonempty. Install the separately packaged `omarchy-update-compat` component before tracking applications. Without tracking, the existing pipeline is unchanged.

- `prepare-session PATH` refreshes a private target database, builds as the desktop user when needed, and writes a ready plan or stops before the main transaction.
- `session-bundle PATH` returns the staged artifact manifest, or an empty value when the installed selection can be kept.
- The existing pacman helper passes a staged manifest only to the fixed `/usr/lib/omarchy-update-compat/privileged` entry point. It retains the existing sudo environment and PID-1 scope. The importer owns its configuration and copied artifacts; the caller cannot supply a root command or pacman configuration.
- `verify-installed PATH` checks the actual installed package metadata before reporting completion. `aur-ignore PATH` protects that selection only for the request's later AUR pass, including a kept installed build whose artifact cache has been removed.

`default/update-compatibility-api` identifies contract version 1 so the standalone entry point can avoid wrapping an updater that already implements it. The companion supplies the reviewed catalog, source backend and restricted privileged boundary; this change does not add a generic executable update hook.

## Proof and limits

The [standalone implementation](https://github.com/carlos-443-diaz/omarchy-update-compat) uses libalpm, makepkg and repo-add. Its [acceptance record](https://github.com/carlos-443-diaz/omarchy-update-compat/blob/main/validation/acceptance-progress.json) separates the historical manual host deployment, automatic VM proof, and later focused verification. The [acceptance checklist](https://github.com/carlos-443-diaz/omarchy-update-compat/blob/main/ACCEPTANCE.md) records production promotion conditions.

The automatic official-VM run starts with real Gaze 0.3.7 packages, reproduces the publisher/OpenCV mismatch, builds 0.5.2 from an empty source cache with bounded rootless jobs, deploys it through the guarded transaction, finishes the stock updater, and passes daemon, loader and package database checks. The build took about 17.5 minutes. A repeated update keeps the installed build without compilation or installation. Native ABI fixtures additionally commit an OpenCV/publisher handoff with a lower package revision, reject target drift under the transaction lock, and preserve native file-conflict checks. They do not establish physical authentication across a future ABI transition.

Focused checks cover artifact/policy/configuration changes, root-only transaction configuration, bounded execution/output, cancellation, concurrent coordinators, native package locks, cache loss, and an exact build-image/target metadata comparison. The source backend pins reviewed inputs and compiles without network access. A RustSec audit of the pinned lockfile reported no known advisories; that is not a security certification. The modified Omarchy updater completed its full official-VM regression suite: 435 test files without failures, with skipped checks in six files.

The [earlier host deployment](https://github.com/carlos-443-diaz/omarchy-update-compat/blob/main/validation/host-upgrade.json) retained enrollment and TPM encryption, passed both Gaze doctors, and verified the camera. It used explicit manual deployment and is not the automatic cold-build proof.

The initial provider wraps GunduLabs publisher archives under the installed AUR identities; those artifacts are not Arch official packages. Its source backend is x86_64 only and stops explicitly on aarch64. The compiled libalpm helper needs a maintained native package built alongside pacman's ABI changes. Native architecture/runtime coverage, coordinator self-upgrade/cohort coverage, locked-desktop authentication and boot recovery remain separate promotion gates. Keep regular repository signature policy, native dependency checks, existing pins and authentication intact.
