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

## Proof of concept and promotion criteria

The [standalone POC](https://github.com/carlos-443-diaz/omarchy-update-compat) demonstrates the policy and native-tool boundaries without introducing a dependency resolver. Its [validation record](https://github.com/carlos-443-diaz/omarchy-update-compat/blob/main/validation/results.json), [tests](https://github.com/carlos-443-diaz/omarchy-update-compat/blob/main/tests/test_compat.py), [container smoke script](https://github.com/carlos-443-diaz/omarchy-update-compat/blob/main/tests/container-smoke.sh) and [integration experiment](https://github.com/carlos-443-diaz/omarchy-update-compat/blob/main/integration/omarchy-update.patch) are available for reproduction.

The initial POC built the actual release for OpenCV 5.0, retained the package install scripts and ABI bounds, reused the source cache, rejected stale or tampered bundles, and committed the package group through the guarded helper in a disposable container. Its native fixture tests cover a joint OpenCV/application upgrade and return to a publisher package with a lower packaging revision. Those fixture cases demonstrate dependency preparation, not a physical authentication test or a native ARM build.

Follow-up [deployment evidence](https://github.com/carlos-443-diaz/omarchy-update-compat/blob/main/validation/host-upgrade.json) records a successful stock update in an official Omarchy VM and on the workstation after explicitly installing the matching Gaze group. The live daemon retained TPM encryption and existing enrollment, both Gaze doctors passed, and camera face verification succeeded. A separate official VM ran the complete Omarchy test suite: 435 test files completed without failures, with skipped checks in six files. The host and target snapshot had the same ABI; a real cross-ABI upgrade and rollback remain separate acceptance cases.

The POC currently wraps Gaze publisher assets under the installed AUR identities; those assets are not Arch official packages. Its source backend is x86_64 only. Its experimental user-writable transaction configuration is restricted to containers and must not be enabled on hosts as-is. General host integration requires root-owned import/signing, complete effective pacman configuration handling, target reconciliation under the transaction lock, VM upgrade/rollback coverage and native architecture validation. Gaze also needs its own doctor and camera/lock acceptance before enabling authentication.

The recommended contribution boundary is a package-neutral preflight and staged-candidate contract in the existing updater. Keep application build fixes upstream with the application and keep the adapter catalog explicit. This documents a reproduced edge case and a demonstrated handling path; it does not activate the experimental coordinator for Omarchy users.
