# Touch Bar integration

The 13-inch M1 and M2 MacBook Pros with device-tree compatibles `apple,j293` and `apple,j493` receive a single prebuilt `omarchy-touchbar` package containing the native renderer and companion shell plugin. The exact hardware predicate excludes other Apple Silicon Macs and Intel T1/T2 machines. It uses the built-in model rather than active DRM connectors, so closing the lid or dimming an idle Touch Bar does not affect detection.

## Setup and updates

Fresh hardware setup runs `install/hardware/apple/touchbar.sh`, guarded by `omarchy-hw-touchbar`. It installs the prebuilt binary package from configured signed repositories, validates native capabilities/configuration and activates tiny-dfr when systemd is running. In an ISO chroot it stages configuration without starting systemd services. The normal image pipeline defers this hardware leaf to first boot; the model check runs there rather than assuming every Apple Silicon image has a Touch Bar.

Per-user provisioning runs `install/user/hardware/touchbar.sh`. It validates the package-owned plugin, preserves and extends the user's layout and bindings, installs font hooks and enables the service plugin in `shell.json` using the existing offline configuration helper. It performs no privileged writes or shell IPC in ISO/deferred-owner provisioning. The root hardware phase registers a known installation owner; deferred-owner provisioning registers the actual new owner's UID before running the user leaf. Font channels are created by a persistent tmpfiles rule and the selected family is published by the unprivileged font/post-boot hooks.

Existing desktop users run:

```sh
omarchy install touchbar
```

This orchestrates both phases, applies the preserved layout with the usual administrator authorization, and checks the live service and native configuration before reporting success. To use an explicitly reviewed, locally supplied prebuilt archive:

```sh
omarchy install touchbar --package /absolute/path/omarchy-touchbar-0.3.8.omarchy1-3-aarch64.pkg.tar.zst
```

No setup path downloads arbitrary binaries, changes repository trust, installs compilers, clones sources or builds a package. Missing publication is an error, not a source-build fallback. Setup requires pkgrel 3 or newer, checks the repository candidate before changing packages and rechecks the installed package name/version before activating it. A preloaded valid combined package works without a sync database/network query; offline first boot may alternatively install from a publisher-provided signed repository database and cached prebuilt package. Image publishers must preload those artifacts to support offline setup. The package is deliberately absent from the family-wide package list, which would install it on unsupported Macs.

Ordinary pacman updates upgrade the daemon and plugin together. The package owns regular runtime files under `/usr/share/omarchy/shell/plugins/touchbar`, so the shell loads the new plugin directly; there is no stale user copy or git update step. The copied font hooks are stable wrappers targeting that package-owned path. Runtime setup and removal explicitly rescan the shell plugin registry after committing settings; a successful settings reload alone does not discover new plugin files. Offline provisioning performs neither IPC operation. A development checkout used through `omarchy dev link` must expose the installed plugin in its own plugin tree before using its shell; this integration targets the standard installed `/usr/share/omarchy` tree.

## Preservation and removal

An existing user plugin with the same manifest ID is moved to a hidden `.touchbar-backup-*` directory before the packaged plugin takes over. An unrelated ID, symlinked plugin path or unsafe manifest is refused. Existing layout customizations and bindings outside the plugin's managed markers remain intact. Edited regular font hooks are backed up under `~/.local/state/omarchy/touchbar/backups/<event>/`, outside active hook directories. Identical hooks are retained; symlinks and non-regular paths are refused before installation touches either event. Removal compares exact installed/known legacy wrapper bytes and preserves subsequently edited hooks. Animation setup retains the companion's layout backups. Administrative `/etc/tiny-dfr/config.toml` files without a recognized generated marker are preserved and setup reports how to opt into management rather than overwriting them.

```sh
omarchy install touchbar --uninstall
```

Removal works independently of hardware detection. It restores stock tiny-dfr, backs away the managed daemon configuration so the stock daemon does not reference a removed package-owned logo, removes this service's enabled entry, removes exactly owned font hooks and removes only the delimited Touch Bar bindings. User layouts and plugin/configuration backups remain. Startup/configuration validation failure also restores stock tiny-dfr and retains the generated configuration as a backup. The root helper migrates only the exact service override created by the earlier local animation installer; unrelated overrides are untouched.

If the package was already removed or startup rollback restored stock, removal still cleans user settings, hooks and bindings. Missing/broken installed helpers or failed package transactions remain errors; user cleanup is attempted independently and the command retains the failure status. An installed, fixed-path main helper can clean old font rules after package-owned helpers disappear.

Font owner replacement retires only root-owned regular tmpfiles rules matching the exact integration template. Successful removal retires those rules and their unchanged channel directories; failed stock replacement preserves channel state. Custom/tampered rules and unrelated runtime contents or symlink targets are preserved. An owned recreation rule is removed even when unrelated runtime data must remain. The font channel tracks one explicitly registered desktop owner at a time because tiny-dfr controls one physical Touch Bar. Running installation as another user intentionally registers that user's font selection. This does not change the selected dictation backend; tap/hold actions call Omarchy's existing dictation commands.

## Package provenance and publication

The canonical recipe in [package PR #2216](https://github.com/omacom/omarchy-pkgs/pull/2216) is release/CI input only. Omarchy owns and tests the activation, font-channel and release-rendering helpers in `default/touchbar/`; the package recipe retrieves those files from an immutable Omarchy revision with SHA-256 verification, rather than maintaining duplicate copies. Version `0.3.8.omarchy1-3` targets aarch64 and pins both git inputs:

- Native fork: `guirossibrum/tiny-dfr` at `6b77e96f8cef5ddf5c6c5c5b4a003b477f342ec9`.
- Companion plugin: `guirossibrum/omarchy-touchbar` at `1c1f34ac84459017b320123b57f5e14e7427ab7a`.

The package provides/conflicts with `tiny-dfr` and retains its service/udev compatibility. Its plugin payload is an explicit runtime allowlist: QML, manifest, layout/application scripts, hardware/font helpers, trace data and logo. It excludes repository metadata, tests, videos, documentation, build trees and unused legacy installers. The package rewrites the pinned companion hook to the immutable package path and generates the initial animated configuration using that revision's renderer with a portable font; no packager UID/font selection leaks into the artifact. The native renderer reuses Omarchy's ttfx Wipe effect.

[Package PR #2216](https://github.com/omacom/omarchy-pkgs/pull/2216) uses the existing native ARM CI and normal release ring. Maintainers use the existing review/build-approval process; the standard merge/publish workflow builds, signs and publishes to `edge`, with ordinary promotion to release channels. No manual recipe transfer or new signing workflow is required.

**The combined signed package must be published or preloaded by the image publisher before this integration is merged/released.** Recipe inclusion does not constitute publication. Package/repository ownership, signature policy and ongoing maintenance require maintainer agreement; no user installation path circumvents that dependency.

## Validation

`bash test/shell.d/touchbar-setup-test.sh` exercises the real setup/orchestration code against external OS/package boundaries, including unsupported no-effects behavior, preloaded offline setup, a non-default owner UID, offline user enablement, idempotence, preservation, package failure and stock rollback. Test fixtures run in temporary trees and do not alter the active desktop. `bash test/shell.d/hw-match-device-tree-test.sh` covers model discrimination; the companion repository separately tests its renderer, font channel and layout/binding safety. Release validation must stage the actual combined archive and run native `--capabilities` and `--check-config` against its files.

Physical validation is currently on an M1 MacBook Pro. M2 is a supported model match, not a claim of a second hardware test. [Companion validation notes](https://github.com/guirossibrum/omarchy-touchbar/blob/feature/animated-menu-logo/VALIDATION.md) describe the native checks and separate local lid workaround. The integration does not change suspend/clamshell policy.

### Integration qualification

The current setup passes 27 focused regressions, model detection, metadata checks for 583 commands, syntax checks, plugin validation, source/checksum verification and generated `.SRCINFO` comparison. The four original review cases fail against the prior code. Coverage includes successful settings reload followed by an explicit live discovery scan, cleanup after package disappearance, actual legacy hook bytes and edited hooks, protected font-rule retirement, no-follow/oversized inputs, and repository/installed minimum-version enforcement.

The [pkgrel 3 unsigned review bundle](https://github.com/guirossibrum/omarchy-touchbar/releases/tag/review-0.3.8.omarchy1-3) contains the prebuilt package, recipe inputs, pinned provenance and SHA256SUMS. Its 54 runtime files total 3,418,368 bytes plus the compatibility symlink. The root-owned makepkg archive is 1,088,990 bytes, with `.BUILDINFO`, `.MTREE`, `.PKGINFO` and `.INSTALL`. It was assembled with `makepkg --repackage` using the unchanged qualified native binary, without compilation or source downloads.

Actual isolated pacman upgrade from pkgrel 2 to 3 reports 75 files and zero altered files; restoring stock reports 46 files and zero altered files, with the combined payload removed. These scratch transactions skip dependency checks/install hooks; actual runtime scripts, historical hooks and loaded-helper cleanup were qualified separately. The real packaged native validator and offline owner/user setup also passed in an isolated filesystem. No live configuration changes were made. This review artifact does not replace official signed publication or final live transaction qualification.

The full aggregate previously ran once: CLI passed; 400 of 422 shell files were nonfailing, with 44 files containing skipped checks. All 22 failing files reproduced on untouched base `6194f46` with matching runtime-permission/socket or existing UI failures. The narrowly scoped review fixes were checked with the focused suite; the aggregate is not claimed green or rerun merely to confirm prior results.
