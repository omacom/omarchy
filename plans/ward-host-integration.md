# Ward: host integration and release plan

Status: remaining integration and release work, 2026-09-09. Multi-output implementation is now described in the architecture and authoring references, rather than retained as a proposal here. This document does not enable Ward, change the running desktop, or claim release readiness.

## Direction and scope

Omarchy should be a user of Ward, not a dependency of Ward. Ward owns isolation and the generic native hosting contract; Omarchy owns its Commons/Ui/plugin compatibility facade, desktop policy, installation workflow, and review UI.

The likely distribution path is a separate Ward source repository, with a source-built package maintained in `omarchy-pkgs`. Repository extraction and packaging are planning work here, not immediate publication tasks.

If Ward ships, all new remote Git plugin installations default to Ward unless the user explicitly chooses Yolo mode. This applies to direct Git URLs as well as registry installs. A plugin cannot opt itself out through its manifest.

The trusted host-selected worker runtime directory is implemented; see its [contract and staging workflow](../docs/ward-runtime.md). The broader ownership split below records the direction; it does not authorize new environment or host-execution capabilities without discussion.

Direct Git/local-folder installation provenance, explicit YOLO routing and graphical management are implemented in the preview. Registry-specific ingress/authentication, package publication and disk-budget enforcement remain follow-up work. Writing this plan does not authorize those follow-ups or another live plugin trial.

Existing first-party plugins and explicitly trusted local code keep their in-process path. Existing v1 installations are not silently reclassified or migrated by this work.

## Current baseline

The [architecture reference](../docs/ward-architecture.md) describes the implemented preview. Important gaps for this plan are:

- The [native build](../native/ward/qt/CMakeLists.txt) installs its `Omarchy.Ward` Qt module and executable only. Omarchy independently stages Commons, Ui, PluginShellApi and its worker adapter through `omarchy-ward-stage-runtime`; the native build does not require an enclosing Omarchy checkout.
- The [controller](../native/ward/src/controller.rs) receives an explicitly host-selected runtime directory descriptor before graphics starts. The generic bootstrap executes its version-validated entry point inside the sandbox. Omarchy owns the [shared worker](../shell/ward-runtime/worker.qml) and its sandbox-local environment/aliases; there is no adjacent-directory fallback or `--omarchy-worker` mode.
- The [request broker](../native/ward/src/requests.rs) selects Omarchy host helpers through `OMARCHY_PATH`. Moving only QML files would therefore leave the dependency inverted.
- [SandboxedPlugins](../shell/services/SandboxedPlugins.qml) now owns one shared session per plugin with per-output native importers and independent bar placements. Mixed-DPI streams, stable identities, owner-only/default roaming, panel transfer, hotplug and shared service state have synthetic coverage. See the [architecture reference](../docs/ward-architecture.md#pixels-input-and-context) for the implemented contract.
- Direct installs now default to Ward with host-owned source/mode records and explicit YOLO/trusted-local exceptions. Registry-specific ingress/authentication is still absent.
- Individual revisions and temporary filesystems have limits, but aggregate revision storage and persistent plugin data have no enforced disk budget.

## A. Make Omarchy an adapter on top of Ward

### Ownership

| Ward | Omarchy | omarchy-pkgs |
| --- | --- | --- |
| Isolation, admission, immutable revisions, grant enforcement, worker/job supervision, generic resource brokers | Plugin manifest/product mapping, install records, permission-review UI and commands | Source package recipe, dependency declarations, build/sign/promotion workflow |
| Private compositor, bounded versioned presentation/input protocol, native Qt hosting module | Real desktop windows, bar placement, panel ownership, dismissal and multi-monitor policy | Compatible executable and Qt module built from one pinned Ward release |
| Generic worker bootstrap and minimum trusted runtime needed for isolation | Worker loader, Commons/Ui, PluginShellApi, Omarchy helper aliases and desktop compatibility projection | Installed-layout checks, architecture support and release-channel promotion |
| Synthetic containment, protocol and generic host-conformance fixtures | Synthetic Omarchy adapter and shell integration fixtures | Package installation and upgrade checks |

Ward remains focused on isolated Quickshell hosting. Independence from Omarchy does not require a general application framework, provider catalog, new service hierarchy, or several crates. Keep source co-located initially; prove the dependency direction before moving repositories.

### Minimal host contract

Define the smallest explicit, versioned host configuration needed to replace the existing hard-coded Omarchy assumptions:

- The trusted host selects the adapter runtime, entry point, identity/state namespace, and supported host-effect handlers. A downloaded manifest cannot select host code, arbitrary runtime paths, handler executables, or another host's policy store.
- Install and admit adapter assets as trusted, read-only runtime inputs, separately from the untrusted reviewed plugin bundle. Validate the selected layout and version before launch. The runtime update lifecycle must not mix incompatible controller, bridge, and adapter versions within one session.
- Keep generic resource enforcement in Ward. Move Omarchy-specific command names, settings persistence semantics, notification/browser integration, and facade translation into Omarchy-owned adapter code. A narrow trusted handler contract must preserve grant checks, typed bounded requests, argument validation, timeouts, revocation, and process ownership; it is not arbitrary plugin-selected dispatch.
- Omarchy sends detached context and desired presentation allocations. Ward validates bounds and enforces admitted capabilities. Neither direction transfers host QObjects or executable plugin QML into the shell.
- Distinguish allocation geometry required to draw a plugin from optional desktop observation. Adapting Omarchy geometry must not implicitly grant access to unrelated windows or workspace state.
- Resolve Ward's executable, native module, and generic assets from an explicit installed contract. Only the Omarchy adapter relies on `OMARCHY_PATH`; Ward must build and run its conformance fixture without that variable or an Omarchy checkout.
- Missing assets, unsupported protocol/adapter versions, or failed isolation produce an actionable unavailable state. They never trigger an in-process fallback.

Names and layout are implementation choices. A host-neutral Qt import and executable name should be selected before extraction; do not retain misleading Omarchy ownership merely because the preview uses those names. This greenfield interface does not need compatibility aliases for unpublished preview names.

### Implementation slices and exit gates

1. Inventory every Omarchy dependency in Rust, Qt, runtime assets, tests, and build/install scripts. Classify each as generic enforcement, host adaptation, or product policy; document the resulting contract before moving it.
2. Move the worker loader and Omarchy facade assets into an Omarchy-owned integration directory. Split generic runtime helpers from Omarchy compatibility aliases. Keep the existing plugin-facing contract working through that adapter.
3. Replace hard-coded bootstrap/runtime/helper selection with the small trusted host contract. Preserve admission, resource bounds, and fail-closed behavior rather than duplicating those mechanisms in the adapter.
4. Make the standalone Ward build/install independent of the enclosing repository. Add a synthetic non-Omarchy host fixture and keep the Omarchy adapter fixture outside the future Ward package's source requirements.
5. Verify both fixtures against an installed-style staging tree, with the source checkout unavailable to runtime lookup. Verify deliberate version mismatch, missing assets, malformed host configuration, and plugin attempts to influence runtime selection.

Done means a Ward-only source tree builds and passes generic tests, and Omarchy uses that same build through its own adapter. No Ward-owned source/build rule imports Commons, Ui, PluginShellApi, or Omarchy host commands. Existing focused isolation, grant, graphics, lifecycle, and shell integration tests still pass.


## B. Remote-install provenance and routing — direct Git implemented

New Git installs use Ward, with an explicit YOLO exception. The CLI and graphical manager implement host-owned records, inspect-before-add with commit pinning, visible mode labels, changed-source rejection and fail-closed damaged-record handling. Registry-specific routing/authentication remains an acceptance gap. The policy checklist is:

- Add a host-owned installation record outside the downloaded bundle, binding plugin identity, source kind/URL, installed commit/content revision, and execution mode. Keep installation provenance distinct from exact-revision capability approval.
- Apply the same routing to registry and direct-URL ingress. First-party status comes from an actual trusted installation source/path, never an ID prefix or a manifest claim.
- A plugin update cannot downgrade Ward by removing `sandbox`, changing its ID, or rewriting metadata. Source changes and identity collisions require explicit handling; unknown or inconsistent routing state must not enter the trusted loader.
- A remote plugin that is not Ward-compatible should stop with an actionable explanation. Do not silently infer Yolo mode to preserve compatibility.
- Yolo means trusted in-process execution and no Ward containment. Make that decision explicit and visible during installation and in subsequent management UI. Ordinary noninteractive confirmation must not silently choose it.
- Preserve existing first-party, trusted-local, and legacy-v1 installations without silently converting their trust model. Document any later migration as a separate decision.
- Record URLs and commits for traceability, but do not present them as publisher authentication. Registry identity, signing, and source-change verification need their own policy.

Implemented policy: explicit YOLO trust persists across ordinary same-source updates. Source/identity changes require removal and explicit reinstallation. Switching a YOLO install to Ward requires compatible content, reinstallation and ordinary revision/grant review before activation. A retained Ward identity cannot convert to YOLO. Legacy trusted installations are not migrated.

Acceptance must cover a new direct URL, registry install, explicit Yolo install, local trusted install, manifest removal on update, changed source, conflicting identity, missing record, and missing/incompatible Ward. All isolated failure cases stay out of the in-process loader.

## C. Extraction and source packaging — plan only

1. Finish the ownership split and standalone conformance gate in A. Move generic Ward source, lockfile, license/build documentation, and synthetic tests into its own repository; retain Omarchy integration and product tests here. Repository creation and history extraction are separate authorized operations.
2. Establish a pinned release/version contract for the executable, native Qt module, worker protocol, and host adapter. Build the executable and Qt bridge from the same source revision and lockfile. Define the supported Qt/Quickshell build/runtime pairing and check it in packaging.
3. Add a source PKGBUILD in `omarchy-pkgs`, using that repository's existing custom-package and edge promotion workflow. Declare build/runtime dependencies from the actual linked and launched components; verify supported architectures rather than assuming portability.
4. Stage a clean package install and run generic Ward conformance plus the separately supplied Omarchy adapter test without development overrides, relative source paths, or locally built artifacts. Cover upgrades, incompatible combinations, and absent adapter assets.
5. Publish through the existing build/sign/review/promotion pipeline, edge first. Promote to stable only after the release/security and host integration gates pass. Package publication is not part of the current branch's completion criteria.
6. Update Omarchy's package/setup integration to depend on a compatible Ward build and install its own adapter assets. Keep missing-native errors actionable and fail closed. The base shell must remain usable if a plugin is unavailable.

The package owns generic Ward files; Omarchy owns its facade. Avoid making the Ward package depend on or embed an Omarchy source checkout. Prefer one package for the tightly coupled executable/module initially; split packages only for a demonstrated distribution need.

## D. Disk budgets — follow-up

Treat these as different storage resources, not one periodic size check:

| Resource | Planned control |
| --- | --- |
| Immutable revisions and staged host-command assets | Aggregate store budget, reservation before publication/staging, reference-aware garbage collection, and bounded concurrent staging |
| Per-plugin persistent data | Enforced, user-visible and adjustable quota on the actual backing storage, with clear full-disk behavior |
| User-selected host directories | Explicit real-data access; not counted as sandbox-private storage or claimed to be confined by its quota |
| Approved host commands | Writes to plugin DATA use the same quota-backed resource; other granted host-command authority remains outside that private-data guarantee |

Start with revision-store accounting/garbage collection, retaining referenced running and approved revisions and avoiding deletion races. Decide persistent storage's enforcement backend separately. Periodic `du` and warnings are observation, not a hard quota, and worker limits alone cannot stop an approved host command from filling its DATA directory.

Preserve the real POSIX storage contract and existing identity-based data across updates. Define default limits, user adjustment, retention, quota exhaustion, recovery, and migration before enabling enforcement. Do not introduce arbitrary small limits merely to report that a quota exists.

Investigate filesystem-native quotas or another bounded backing store against Omarchy's actual filesystem/support requirements. Do not automatically enable filesystem-wide Btrfs qgroups: their operational cost and shared-extent accounting require an explicit design decision; consult the [Btrfs quota documentation](https://btrfs.readthedocs.io/en/latest/btrfs-quota.html). Removal and data-retention policy also need an explicit user-facing choice.

## Order, decisions, and completion

Completed immediate slice: trusted runtime selection, descriptor transport, bounded version/layout validation, sandbox-local generic bootstrap, separate Omarchy staging, and separate generic/adapter fixtures. This does not finish A: host-effect helpers, product schema/context names, native naming, and the release/update compatibility contract still need work. Broader host-effect generalization requires its own discussion. B, C, and D remain independent release work with their own review gates. Keep changes atomic rather than combining namespace moves, geometry changes, install routing, and quota enforcement in one commit.

Pending discussion:

1. Discuss any new trusted execution-environment profile and desktop handoff before implementing it; plugin-specific logic does not belong in Ward.
2. Before the later routing work, settle Yolo update/source-change confirmation.
3. Before publication, settle repository/package naming, version compatibility, supported architectures, and persistent-storage backend/defaults.

Remaining multi-monitor release validation: run installed graphical acceptance in a disposable VM and verify the actual host desktop on physical mixed-scale monitors, including focused-monitor summon, held-input unplug and workspace/focus transitions. Private-display tests cover two host outputs with four widget placements, three differently scaled native streams, negative origins/gaps/portrait geometry, same-output and cross-output owner transfer, fallback summon, zero outputs, crash/restart, stale/replayed records and grant independence. They do not replace those installed/hardware gates. The local ISO checkout currently has neither a release ISO nor a reusable installed base, so no VM acceptance result is claimed.

Completion of the immediate directory split does not establish all of A's broader extraction gates, a completed security audit, original-plugin feature parity, production installation policy, enforced persistent quota, or a published Ward package. Keep these remaining release gaps explicit.
