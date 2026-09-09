# Plan: Ekapkgs — rebase Omarchy onto a sovereign ekapkgs foundation

Revision 1. This plan replaces the nixpkgs-fork strategy in `plans/nix.md` with a downstream integration of [ekapkgs](https://github.com/ekala-project/ekapkgs), an ecosystem-scale poly-repo fork of nixpkgs. The structural argument for leaving Arch is unchanged — atomicity, reproducibility, signature-chain sovereignty — but ekapkgs changes the shape of how Omarchy relates to its upstream. Instead of forking nixpkgs and carrying an `omarchy` branch of patches against a 400k-commit monolith, Omarchy maintains a small `pkgsModule` repository — a single `pkgs-module.nix` plus its overlay tree — that composes cleanly into the ekapkgs poly-repo hierarchy. The monorepo maintenance burden shifts to an upstream we participate in rather than one we fork and drift from.

## Problem

Unchanged from `plans/nix.md`. The short version: Omarchy spends hundreds of lines protecting users from pacman's structural deficiencies — file conflicts, non-atomic updates, unsigned AUR scripts, per-machine mutable drift — and sovereignty is only half-won because Arch decides what a system upgrade contains. Nix (on a NixOS base) fixes the category. The question is which Nix ecosystem to build on.

## Definitions

- overlay - Abstraction which allows you to add or change packages globally. This allows Omarchy to curate packages outside of the upstream Ekapkgs community when needed.
- pkgsModule - Ekapkgs-specific term used for aggregating overlays across many package scope, and potentially other pkgs.config related items and normalizing their shape so that they are easily composed.
- NixOS module - Abstraction which was developed for NixOS, but not specific to it. Home-manager, nix-darwin, and many other ecosystems use this module paradigm to do holistic configuration of complex systems.

### Why ekapkgs over a nixpkgs fork

`plans/nix.md` proposes forking nixpkgs — mirroring the full tree on our git hosting, carrying an `omarchy` branch with patches, pinning a revision per release. That works, but it means Omarchy owns the full width of nixpkgs: every soname bump, every Python update, every staging cycle. The fork drifts, rebasing costs compound, and "our patches" live in a branch of a repository we don't govern.

Ekapkgs solves this differently:

- **Poly-repo architecture**: nixpkgs' monolith is split — `nix-lib` for pure Nix utilities, `corepkgs` for stdenv and the most-used few thousand packages, and language/ecosystem repos (`python-pkgs`, `haskell-pkgs`, `cuda-pkgs`, `vim-plugins`, `r-pkgs`) that branch off core. The top-level `ekapkgs` repo recombines them through overlays into a single package set. This means Omarchy can contribute desktop packages upstream where they belong and carry only its own additions locally.
- **pkgsModule composition**: each repo in the ecosystem exposes a `pkgs-module.nix` — a declarative bundle of overlays keyed by package scope (`overlays.pkgs`, `overlays.python`, etc.). Downstream consumers `import` these modules and the overlay machinery composes them. Omarchy's entire packaging surface becomes a small `pkgs-module.nix` that declares its overlays on top of the ekapkgs set — the same pattern `python-pkgs` uses to extend `corepkgs`, or `ekapkgs` uses to aggregate all language repos.
- **No staging workflow**: changes land on master; all builds must succeed. This aligns with Omarchy's freshness posture (stable trails by a month, but the upstream itself doesn't batch changes behind a multi-week staging gate).
- **Purpose-built tooling**: `ekapkgs-cli` wraps the Nix CLI with a gRPC-based cache negotiation protocol (O(1) round trips for closure substitution instead of O(N)), imperative system/home package management, SBOM generation, and closure analysis. `EkaCI` provides Nix-native CI with dependency-graph tracking, merge queues, and binary cache integration. `ekapkgs-update` automates version bumps with CVE checking. These are maintained upstream rather than built by Omarchy.
- **Governance Omarchy can participate in**: ekapkgs uses [EEPs](https://github.com/ekala-project/eeps) (Ekala Enhancement Proposals) instead of the NixOS RFC process. Proposals iterate faster and the contributor base is small enough that Omarchy's voice carries — we are a stakeholder, not a downstream consumer of a project with 6,000 contributors whose priorities we cannot influence.

The trade-off is maturity: ekapkgs is younger than nixpkgs, its package count is smaller, and some tooling (`ekapkgs system`, `ekapkgs home`) is still in design. This plan accounts for those gaps.

## Shape

- Omarchy becomes an ekapkgs-based EkaOS system. The supply chain runs on omarchy.org infrastructure: an ekapkgs pin on our git hosting, closures built on our build farm (using EkaCI), binaries served from our signed cache (`cache.omarchy.org`). A user's machine never contacts cache.nixos.org, GitHub, or any ekapkgs host for OS concerns — the same posture as today's `pkgs.omarchy.org` and mirrors, extended to cover everything.
- **Omarchy maintains a `pkgsModule` repo** — a small repository in the ekapkgs poly-repo pattern containing:
  - `pkgs-module.nix`: declares Omarchy-specific overlays (`overlays.pkgs`, plus any scope-specific overlays) on top of the ekapkgs set
  - An overlay tree (`pkgs/`): Omarchy-branded packages, patched packages, hardware-specific kernels (T2, `linux-ptl`), and anything nixpkgs/ekapkgs lack — the successor to today's `omarchy-pkgs` PKGBUILD repo
  - NixOS modules: the system configuration that today lives as shell scripts under `install/config/`, `install/hardware/`, and `etc/`
  - A pin to a specific ekapkgs revision per release
  - This repo is tiny by design — a few hundred files, not tens of thousands. Upstream improvements go upstream; only Omarchy-specific concerns live here.
- Users don't learn Nix or ekapkgs. The `omarchy` CLI keeps its verbs (`omarchy-pkg-add`, `omarchy update`, `omarchy-channel-set`), `~/.config` stays mutable user files, themes and the refresh pattern are untouched. Ekapkgs is plumbing, exactly as pacman was plumbing.
- The `ekapkgs` CLI is available for power users who want direct access to closure analysis, cache management, and the Nix CLI wrapper. It is not required for normal Omarchy use.

## Sovereignty, precisely

The same two-tier sovereignty model as `plans/nix.md`, restated for the ekapkgs context:

- **Runtime sovereignty (absolute, for OS delivery)**: an installed machine resolves every OS need — binaries, expressions, signatures, update metadata — against omarchy.org hosts only. No fallback substituters, no GitHub fetches, no upstream flake registry. If ekapkgs.org or nixos.org vanished, no user would notice.
- **Build-time sovereignty (continuity)**: our infrastructure ingests from upstream ekapkgs repos at development time, archives everything — the poly-repo trees in our git mirrors, every source tarball (EkaCI's FOD handling ensures source derivations are cached alongside build products), every build closure — in our cache. If upstream vanished, we could keep building.

The boundary is OS delivery. `mise`-managed tools, fwupd firmware, Steam, browser self-updates — application-content channels outside the promise. Cloudflare stays as CDN in front of sovereign infrastructure.

The release gate remains testable in two parts. Delivery: a clean machine, outbound network restricted to omarchy.org, can install the ISO, update, and install every curated extra. Continuity: from an empty store, with binary substitution disabled and only our source archive reachable, the release closure must rebuild.

## Rejected approaches

All rejections from `plans/nix.md` carry forward (Nix on Arch, Guix, cache.nixos.org as fallback, Hydra, live binary-cache daemon, home-manager for user configs, image-based atomicity, staying on Arch). Additional:

- **Forking nixpkgs directly** (`plans/nix.md`'s approach): the monorepo fork means owning the full width of nixpkgs — every staging cycle, every language ecosystem update, every bootstrap chain. Ekapkgs' poly-repo split lets Omarchy compose at the overlay level rather than fork at the repo level. The cost is depending on a younger upstream; the benefit is a dramatically smaller maintenance surface.
- **Using ekapkgs' `omarchy-pkgs`** for Omarchy's additions: omarchy-pkgs is the official Omarchy extension (the NUR/AUR equivalent). Omarchy's packages are part of the OS, not community contributions — they belong in a first-class `pkgsModule` repo with the same build, cache, and signature guarantees as the rest of the system.
- **Lix as the Nix evaluator**: governance and community concerns make Lix unsuitable. The evaluator choice is between upstream `nixos/nix` and DetSys's `determinate-nix`. Since ekapkgs targets Nix 2.3 compatibility with optional flake entry points, either works. Decision deferred to Phase 0 evaluation but Lix is excluded.
- **Stable/LTS overlay model (EEP-0040)** as Omarchy's channel mechanism: ekapkgs proposes stable releases through overlays for LTS scenarios. Omarchy's stable channel prioritizes freshness (trailing upstream by a month, not pinning to an LTS cut). Channels are better modeled as flake pins at different revisions of the ekapkgs ecosystem, matching the current `stable`/`rc`/`edge` pacman.conf template pattern.
- **`ekapkgs home` for user dotfile management**: the `ekapkgs home` design serializes config to TOML files and manages PATH/icon-caches/environment transparently. This is narrower than home-manager (no symlink farms into the store), but Omarchy's "your files" philosophy means even transparent environment mutation should stop at the system/user boundary. `ekapkgs home packages` (imperative per-user package management) is useful plumbing for `omarchy-pkg-add` when a user wants a package in their profile rather than the system closure; the broader `ekapkgs home switch` for declarative user environment is not wired into Omarchy's blessed UI.

## Design

### Supply chain — the poly-repo pin

Omarchy pins ekapkgs at the ecosystem level, not the monorepo level:

- **Omarchy pkgsModule repo** (`omarchy-pkgs`, successor to today's PKGBUILD repo): contains `pkgs-module.nix`, the Omarchy overlay tree, NixOS modules, and a `pins.nix` referencing exact revisions of `corepkgs`, `ekapkgs`, and any language repos Omarchy needs (e.g., `python-pkgs` for Python applications in the curated set). The pin mechanism mirrors ekapkgs' own `pins.nix` pattern.
- **Source archive**: EkaCI handles FODs (fixed-output derivations — sources, patches) as first-class build artifacts. Our farm caches every FOD output alongside regular build products. Builder and client network policy allows omarchy.org only; a cache miss fails loudly.
- **Upstream contribution path**: packages that belong in `corepkgs` or `ekapkgs` go upstream via PRs against those repos. Omarchy-specific packages (branded configs, hardware kernels, the `omarchy` meta-package) stay in our pkgsModule. This is the key difference from `plans/nix.md` — instead of carrying patches in a fork branch, improvements flow upstream where they benefit the ecosystem and reduce our carry.

### The pkgsModule pattern — how Omarchy composes

The pkgsModule pattern is ekapkgs' answer to downstream extensibility. Each repo in the ecosystem declares a `pkgs-module.nix`:

```nix
# omarchy-pkgs/pkgs-module.nix
{ lib, ... }:
let
  pins = import ./pins.nix;
  ekapkgsModule = import (pins.ekapkgs + "/pkgs-module.nix") { inherit lib; };

  omarchyOverlay = lib.packageSets.mkAutoCalledPackageDir ./pkgs;
  omarchyOverrides = import ./top-level.nix;
in
{
  imports = [ ekapkgsModule ];

  overlays.pkgs = [
    omarchyOverlay
    omarchyOverrides
  ];
}
```

This is the entire integration surface. Omarchy's overlay adds packages ekapkgs lacks, patches packages that need Omarchy-specific behavior, and the `imports` line pulls in the full ekapkgs package set (which itself aggregates corepkgs, python-pkgs, haskell-pkgs, etc.). A NixOS system configuration then consumes this pkgsModule to get the complete package set.

The pattern means:
- **Updating ekapkgs** is updating pins, rebuilding, testing — not rebasing a fork branch
- **Adding a package** is dropping a file into `pkgs/` and it auto-discovers via `mkAutoCalledPackageDir`
- **Overriding an upstream package** is an overlay entry in `top-level.nix`
- **The repo stays small** — hundreds of files, not the 60k+ of nixpkgs

### Binary cache and trust

- `cache.omarchy.org`: narinfo + nar objects on object storage behind Cloudflare, populated by EkaCI's binary cache integration (S3 backend with per-repo access controls), signed with an Omarchy ed25519 cache key. The `ekapkgs-cli` gRPC negotiation protocol means closure substitution is a single round trip instead of 3N HTTP requests — a measurable improvement for updates.
- **Certificate-based signing**: `ekapkgs-serve` supports certificate-based signing with key rotation without client config changes. This is better than the static key model in `plans/nix.md` — key rotation becomes operational rather than requiring a client update. The cache server also speaks the standard Nix binary cache protocol for backward compatibility. (Still pending implementation validation)
- **Release manifest**: same as `plans/nix.md` — a signed document per channel naming the release version, exact closure hashes per hardware variant, with expiry and monotonic versioning. Anti-rollback, anti-replay. The `ekapkgs` CLI's `system` subcommand (once implemented) or Omarchy's own update tooling consumes this manifest.
- Client `nix.conf`: `substituters = https://cache.omarchy.org` — nothing else. `trusted-public-keys` lists only our key (or CA certificate). The flake registry points to our own registry file.

### Build farm

EkaCI runs as the build farm, purpose-built for Nix projects:

- **Dependency graph tracking**: EkaCI understands the Nix dependency graph, so rebuilds triggered by a corepkgs update only rebuild affected packages — not the world. (Done)
- **Rebuild only what changed**: EkaCI is able to determine which packages actually were affected by a change and allow you to rebuild all of them to verify regressions were not introduced. (Done)
- **Merge queue support**: PRs to the omarchy-pkgs repo go through CI before merging, ensuring the cache is populated before any release. (Needs testing)
- **Binary cache integration**: built-in `nix copy` to the S3-backed cache with per-repo/branch access controls. FODs (sources, patches) are cached alongside build products, satisfying the continuity gate.(Needs testing)
- **Build metrics**: NAR size, closure size, baseline comparisons — the per-machine composition budget (evaluation time and memory on the weakest supported hardware) is a CI metric, not an assumption. (Needs polish)

Release matrix: the base system closure per hardware variant (NVIDIA open/legacy, T2, `linux-ptl`, plain), every optional package in the curated extras set, and the ISO.

### Legal-redistribution gate

One gate is legal: serving packages from `cache.omarchy.org` is redistribution. EEP issue #15 proposes defaulting to allow `unfreeRedistributable`, which covers many cases (CUDA stubs, firmware). For packages with stricter EULAs (NVIDIA userspace, certain vendor firmware), the mechanism is a `config.<eula>` abstraction where users communicate agreement to per-vendor terms, gating download from the cache. When facilitated through the `ekapkgs-cli`, these agreements will be respected. Each package in the curated set lands in one of three buckets:

1. **Free or unfreeRedistributable**: built and cached, served to all
2. **EULA-gated**: built and cached, evaluated only when the client's config declares acceptance of the vendor's terms
3. **Vendor-fetch exception**: not cached; the package expression fetches directly from the vendor, documented as a named hole in the runtime-sovereignty claim

No package enters the curated set without landing in a bucket. This is a Phase 0 deliverable.

### The system layer

- Everything under `install/config/`, `install/hardware/`, and the `etc/` tree becomes NixOS module code in the omarchy-pkgs repo. `services.displayManager.sddm`, `boot.plymouth`, snapper, docker, cups hardening, the sysctl/sudoers/tmpfiles drop-ins, the NVIDIA modprobe and initrd logic. The entire `etc-overrides/` mechanism is deleted — composing `/etc` from multiple sources is what the module system is.
- **NixOS modules from corepkgs**: boot, kernel, networking, filesystem modules come from ekapkgs' CoreModules (the "minimal NixOS system" layer). Desktop/program modules that ekapkgs' PkgsModules would eventually provide are initially carried in omarchy-pkgs' module tree. As ekapkgs' PkgsModules matures, Omarchy contributes its modules upstream and reduces its carry — the same contribute-upstream-carry-local dynamic as the package overlay.
- **Bootloader**: limine stays. Boot entries are system generations, not snapper snapshots, so `limine-snapper-sync` and `limine-mkinitcpio` retire. Secure Boot stays explicitly unsupported unless a dedicated workstream designs it properly. [Lanzaboote](https://github.com/nix-community/lanzaboote) could be migrated to Ekapkgs and then secure boot would be supported but opt-in at users request; BIOS manipulation may be required to bootstrap boot entry signing.
- **Per-machine composition, budgeted**: the poly-repo split helps here — evaluating the Omarchy pkgsModule + ekapkgs overlays is cheaper than evaluating all of nixpkgs because language-ecosystem repos not needed by the system closure are not imported. The composition budget (time and memory on weakest supported hardware) is measured in the acceptance suite via EkaCI build metrics.
- **A supported customization layer**: the machine gets a blessed local-override file the modules import — real Nix options, documented, surviving updates. Every managed `/etc` file has a named owner. Coordination that today hides behind the pacman guard moves into activation-time logic keyed by release version.
- **Store hygiene**: automatic GC with a generation-retention window, a cap on boot-menu generations, and a free-space floor. `ekapkgs store gc` provides the user-facing interface; Omarchy's GC policy configures its defaults through NixOS module options.
- **Filesystem**: btrfs stays for `/home` (snapper for user-file snapshots until `plans/backup.md` and `plans/dots.md` cover that ground). `omarchy-system-factory-reset`'s subvolume mechanics must be ported. Booting an old generation restores the OS, not mutable `/var` state.

### The user layer stays mutable

Non-negotiable: `~/.config` remains plain files the user owns and edits. `/etc/skel` seeding, `omarchy-refresh-config`, themes, and the entire `default/` → `~/.config` pipeline work unchanged. The declarative world ends at the system/user boundary.

`ekapkgs home packages` (imperative per-user package installation via `~/.config/ekapkgs/home-packages.toml`) is available as plumbing for `omarchy-pkg-add` when a package should live in the user's profile rather than the system closure. The broader declarative home-environment management is not exposed through Omarchy's UI (subject to change).

### Package UX

- The machine manifest — a plain text list of what this user added — works the same as `plans/nix.md`. `omarchy-pkg-add <name>` resolves through an alias table (Arch names → ekapkgs attributes), appends to the manifest, and rebuilds against the cache — prebuilt, so "rebuild" means download + re-evaluation + switch.
- **Under the hood**, `omarchy-pkg-add` can delegate to `ekapkgs home packages add` for user-scoped packages or to a system-scoped manifest that triggers `ekapkgs system switch`. The user doesn't see this distinction; the command decides based on whether the package needs system privileges (e.g., a service, a kernel module) or is a user application.
- **Package search**: `ekapkgs search packages` provides local indexed search (ZSTD-compressed JSON, auto-generated). The Quickshell menu's guard prelude gets simpler: one listing of the current closure's package set, computed at activation time and cached, replaces the pacman queries.
- **The AUR is gone, replaced by the curated extras set**: everything the Install menu offers comes from ekapkgs or our overlay, built and signed on our farm. Arbitrary AUR browsing has no equivalent. The escape hatch for power users — adding their own flakes or overlays — is real Nix, documented as leaving the supported envelope, and never wired into blessed UI.
- **Closure analysis**: `ekapkgs closure size`, `ekapkgs closure why-depends`, `ekapkgs closure diff`, and `ekapkgs closure sbom` are available for power users and for Omarchy's own CI — SBOM generation (CycloneDX 1.5/1.7) satisfies regulatory requirements (EU CRA, US EO 14028) and provides CVE visibility that the Arch stack never had.

### Updates, channels, migrations

- `omarchy-update` keeps its skeleton and swaps its heart: the pacman transaction becomes "download the release closure from the cache (via the gRPC negotiation protocol — one round trip), compose the new generation, switch." The `ekapkgs-cli`'s efficient substitution protocol means update downloads are faster than the Nix default.
- Deleted outright: `omarchy-update-keyring`, `omarchy-update-pkg-prune`, `omarchy-update-system-pkgs-when-conflicted`, `omarchy-update-pacman-guard` and the ALPM hooks, `omarchy-update-orphan-pkgs`, `omarchy-update-aur-pkgs`, and the pacnew concern.
- **Channels**: `stable`/`rc`/`edge` become pins at different ekapkgs revisions in the omarchy-pkgs flake, mirroring today's three pacman.conf templates. `stable` trails by a month — the pin is simply a month-old ekapkgs revision, not an LTS overlay. `omarchy-channel-set` flips the flake reference and switches. `dev` keeps its meaning: a local checkout via `omarchy-dev-link`.
- **Version**: `omarchy-version` reports the release tag of the running closure. `omarchy-update-available` compares against the release-manifest JSON.
- **Migrations**: shrink to their legitimate residue: user-space state under `$HOME`. System-state transitions become module code in the next closure. The marker mechanism and `omarchy-migrate-notify` survive for what remains.
- **Auto-updates from upstream**: `ekapkgs-update` (the upstream auto-updater) handles version bumps with CVE checking via OSV.dev, cross-distro validation via Repology, and per-package configuration through passthru attributes (EEP-0039). Omarchy's release pipeline can use this to automate the pin-bump → build → test → release cycle.

### ISO and installer

`omarchy-iso` rebuilds around a NixOS ISO carrying the full release closure. `ekaos-install` (the upstream TUI/CLI installer with UEFI and BIOS support) provides a foundation, but Omarchy's installer UX is its own — the ISO uses our modules, our branding, our hardware detection wiring into module selection. Offline installation is `nix copy` from the ISO's store to the target plus writing the hardware module selection and the machine manifest.

### SBOM and security posture

A distinguishing benefit of the ekapkgs stack: EEP-0044 standardizes SBOM generation and CVE metadata at the package level. Every package in the Omarchy closure carries CPE, PURL, license, and source-provenance metadata. `ekapkgs closure sbom` generates CycloneDX documents for the entire system closure. `ekapkgs closure sbom-diff` between releases shows version changes, new/resolved CVEs, license changes, and provenance shifts. This is infrastructure Omarchy gets for free by building on ekapkgs — the Arch stack has no equivalent.

### Distinguishing properties of the ekapkgs rebase

Compared to the nixpkgs-fork approach in `plans/nix.md`:

1. **Omarchy carries a pkgsModule, not a fork branch**: the maintenance surface is a few hundred files declaring overlays and modules, not a branch of a 60k-file monorepo. Pin bumps replace rebases.
2. **Upstream contributions flow naturally**: a desktop package that belongs in `ekapkgs`, a library fix that belongs in `corepkgs`, a Python package update that belongs in `python-pkgs` — each goes to the right repo via PR. Omarchy is a participant in the ecosystem, not a downstream consumer of a fork.
3. **Cheaper evaluation**: the poly-repo split means per-machine composition evaluates only the package scopes Omarchy imports, not all of nixpkgs. This directly benefits the composition budget on low-end hardware.
4. **Better cache protocol**: the gRPC negotiation in `ekapkgs-cli` reduces closure substitution from O(N) HTTP round trips to O(1). Updates are measurably faster.
5. **Certificate-based signing with key rotation**: `ekapkgs-serve` handles key rotation without client config changes, a significant operational improvement over static cache keys.
6. **Built-in SBOM and CVE tracking**: regulatory compliance and security visibility out of the box.
7. **Purpose-built CI**: EkaCI understands Nix dependency graphs, tracks build metrics, and integrates with the binary cache natively — no bolting Nix onto generic CI.
8. **`ekapkgs-update` for automated freshness**: version bumps with CVE checking, Repology validation, and per-package configuration flow into the release pipeline.

## Migrating from Quattro to Cinque

The migration strategy is structurally identical to `plans/nix.md` — the parallel-root migration using btrfs subvolumes. The difference is what lands on `@cinque`: an ekapkgs-based closure composed from Omarchy's pkgsModule rather than a nixpkgs-fork closure.

### The parallel-root migration

`omarchy-upgrade-to-cinque` ships as a Quattro package update. It never runs unprompted.

1. **Preflight**: same layout gating (btrfs `@`/`@home`, one LUKS container, limine), hardware-variant gate (the machine's variant must have a built Cinque closure in the cache), space gate (computed from actual NAR sizes), hibernation detection, and the won't-survive report.
2. **Fetch**: the release closure downloads from `cache.omarchy.org` into `@cinque`'s `/nix` store — using the gRPC protocol for efficient transfer.
3. **Carry state**: partition table, LUKS, `@home` untouched. Hardware config generated from live system. Accounts carry as full database files with `users.mutableUsers` on. `machine-id`, SSH host keys, NetworkManager connections. `/var/lib` payloads copied with services stopped.
4. **First boot**: Cinque boot entry added inside a deliberate boot transaction. The user boots Cinque by choosing it. First-boot verification presents results and asks before Cinque becomes default.
5. **Rollback window, then reclaim**: `@home` snapshot at cutover. `--rollback` is two-stage. `--reclaim` deletes the Quattro root.

### The won't-survive report

Same as `plans/nix.md`: delta of `pacman -Qqe` against the Quattro baseline run through the alias table, custom pacman repos listed as unsupported, system-level drift scanned and listed.

## Rollout

- **Phase 0 — infrastructure, zero user impact**: `cache.omarchy.org` with `ekapkgs-serve`, the key hierarchy (build/cache/release keys, certificate-based signing, compromise runbook), the signed release-manifest format, the legal-redistribution inventory, EkaCI configured as build farm, ekapkgs pin selection, and a CI job proving both sovereignty gates. Simultaneously: establish the omarchy-pkgs repo in the pkgsModule pattern, with initial `pkgs-module.nix`, `pins.nix`, and the overlay tree seeded from current `omarchy-pkgs` PKGBUILD translations.
- **Phase 1 — system parity** (omarchy-pkgs): NixOS modules covering every `install/config/`, `install/hardware/`, and `etc/` entry; the pkgsModule with per-channel pins; boots and passes the graphical acceptance suite in the VM. Contribute desktop-relevant modules upstream to ekapkgs where appropriate.
- **Phase 2 — CLI port** (this repo): `pkg-*`, `update-*`, `channel-*`, `version-*`, snapshot/restore semantics, menu guards; wire `omarchy-pkg-add` to `ekapkgs home packages add` / system manifest as appropriate; delete the pacman-only organs; port tests.
- **Phase 3 — ISO and installer** (`omarchy-iso`): the offline NixOS ISO using our modules, installer flow building on `ekaos-install` or our own, hardware detection wiring.
- **Phase 4 — release and overlap**: ship as the next major; maintain Quattro channels in parallel; deliver `omarchy-upgrade-to-cinque`; reinstall-with-restore as fallback.
- **Docs and tests**: `docs/update-process.md` rewritten; sovereignty gate and cache/mirror topology reference; manual chapters; shell tests for manifest editing, alias resolution, channel flips; composition budgets measured on weakest hardware; the release-gate CI assertion.

## Improvements from original nix plan

Concerns from `plans/nix.md` that the ekapkgs rebase fully addresses:

- **Fork maintenance burden**: eliminated. Omarchy carries a pkgsModule (hundreds of files, overlay + modules), not a branch of a 400k-commit monorepo. Pin bumps replace rebases; upstream contributions go upstream.
- **Staging workflow latency**: gone. Ekapkgs lands changes on master with all-builds-must-pass; no multi-week staging cycle between a fix and users receiving it.
- **Build farm complexity (Hydra rejection)**: resolved by EkaCI, purpose-built for Nix with dependency-graph tracking, merge queues, and native binary cache integration — the "plain `nix build` in CI" approach from `nix.md` gains graph-aware rebuilds and build metrics without Hydra's operational weight.
- **Cache substitution performance**: O(1) gRPC round trip via `ekapkgs-cli` replaces O(3N) HTTP requests per closure. Updates are measurably faster.
- **Cache key rotation**: certificate-based signing in `ekapkgs-serve` enables key rotation without client config changes, replacing the static ed25519 key model.
- **Evaluation cost on low-end hardware**: the poly-repo split means per-machine composition evaluates only imported package scopes, not all of nixpkgs. Directly reduces the composition budget concern.
- **Upstream influence**: ekapkgs uses EEPs with a small contributor base where Omarchy is a stakeholder. Replaces the nixpkgs situation (6,000 contributors, priorities we cannot influence).
- **SBOM and CVE visibility**: built into the ecosystem (EEP-0044, `ekapkgs closure sbom`). The Arch stack and the nixpkgs-fork plan had no equivalent.
- **Automated package freshness**: `ekapkgs-update` with CVE checking, Repology validation, and per-package passthru config (EEP-0039) feeds directly into the release pipeline.

## Open questions

1. **Which Nix evaluator**: upstream `nixos/nix` is the safe default. DetSys's `determinate-nix` is a serious alternative with commercial backing and operational polish. Ekapkgs targets Nix 2.3 compatibility, so either works. Decision in Phase 0; Lix is excluded.
2. **Flakes or stable evaluation**: same as `plans/nix.md`. Ekapkgs repos provide optional `flake.nix` entry points alongside Nix 2.3-compatible evaluation. Leaning flakes for the tooling ecosystem benefits; deserves a deliberate decision.
3. **How far the curated extras set reaches**: ekapkgs holds fewer packages than nixpkgs (the poly-repo split means the "all" set is distributed). What is the story when a user wants a package outside Omarchy's curated set — a request pipeline into the omarchy-pkgs overlay, the escape hatch of adding a flake, or both? (Ekapkgs hopes to statisfy most reasonable workflows)
4. **ekapkgs-cli `system` and `home` subcommand maturity**: these are still in design upstream. Omarchy can either (a) use them as plumbing once available, (b) co-develop them with ekapkgs upstream, or (c) build its own thin wrappers around `nixos-rebuild` and `nix profile` in the interim. The plan assumes (b) — Omarchy is an early consumer and contributor — but the interim story (c) must be ready for Phase 1.
5. **EkaCI frontend and continuous-build maturity**: EkaCI works e2e as a CI enforcement tool today. The continuous-build daemon and review portal frontend are not yet realized. Omarchy's Phase 0 needs the enforcement path (build the release matrix, populate the cache, gate the release); the portal is nice-to-have.
6. **Reclaim policy**: same as `plans/nix.md` — explicit `--reclaim` vs. automatic after N clean boots.
7. **Btrfs by default, still**: same as `plans/nix.md` — with system rollback as generations, btrfs earns its place only through `/home` snapshots and factory reset. EkaOS can manage system state independently from the mutable directories.
8. **EULA/unfree redistribution mechanism**: the `config.<eula>` abstraction for per-vendor agreement gating needs design. EEP #15's `unfreeRedistributable` default covers most cases; the EULA-gated tier is the open design question.
9. **Naming and posture**: "powered by ekapkgs" vs. "an EkaOS derivative" — same trademark and community expectations question as `plans/nix.md`, but with a smaller upstream where the relationship is collaborative rather than unilateral.
10. **PkgsModules (desktop NixOS modules) upstream**: ekapkgs' PkgsModules layer (the "complete" module set for desktop/personal use) is not yet realized. Omarchy will build its own desktop modules in Phase 1 regardless. The question is the upstream contribution path — does Omarchy's module work seed ekapkgs' PkgsModules, or do the two develop independently and converge later?
