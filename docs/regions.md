# Regional ISO defaults

Regions customize bootstrap defaults independently of update channels. Country identifiers are lowercase, officially assigned ISO 3166-1 alpha-2 codes. `global` is a reserved value for no country-specific additions. Only implemented profiles are accepted; currently `global` and `cn`.

## Runtime configuration

The ISO installer writes the selected region to `/etc/omarchy/region` before target finalization. It is plain text, not executable configuration. A missing file means `global`; an unsupported value is an error.

`omarchy-apply-pacman <stable|rc|edge> [target-root]` restores the selected channel's two pacman templates and appends `default/regions/<region>/pacman/{pacman.conf.append,mirrorlist.append}`. Both files are generated before either live file is replaced. Existing files are backed up with `.bak`. Dev uses the edge pacman channel, as before.

Both installation finalization and `omarchy-refresh-pacman` use this command. Explicit refreshes and channel changes restore regional defaults; ordinary updates do not enforce them. The existing `pre-refresh-pacman` user hook runs after regeneration and before the update, so users can maintain overrides there. Switching to the dev channel refuses a checkout that lacks this machine's region profile, because that checkout's own refresh would otherwise drop the regional repositories. Users can edit the files directly or set the region to `global` before a refresh to stop applying regional repository defaults. This does not uninstall packages or rewrite anything in existing home directories.

The China profile keeps the channel's Omarchy Arch mirror first, appends USTC's regular Arch mirror, and adds the USTC ArchLinuxCN community repository. It does not change the `[omarchy]` package repository. USTC's mirror, run by the University of Science and Technology of China, and ArchLinuxCN, a long-standing community repository, are a practical bridge until Omarchy runs its own mirror in China. USTC is not a stable/RC snapshot replica: missing old packages and newer fallback databases remain compatibility risks.

## ISO builder contract

The companion `omarchy-iso` repository accepts `--region global|cn`, passes `OMARCHY_REGION` into the build container, and records it in `/root/omarchy_region` on the ISO. Non-global artifact and offline-cache names gain a region suffix. Existing global names remain unchanged.

Regional content comes from the same runtime used by the ISO: either the `--local-source` checkout or the downloaded runtime package. A China build against a runtime without regional support fails rather than silently producing a global installation.

- `packages`: additional target packages, one name per line, with blank lines and `#` comments allowed. The builder merges these into the ISO's copy of `omarchy-base.packages`, so they are both included in the offline repository and installed on the target. The source manifest is not modified.
- `pacman/`: repository fragments used by the runtime finalizer. The builder also adds the community repository to its writable online config to obtain regional packages; it does not change its Arch channel mirrors.
- `skel/` (optional): new-user defaults. The ISO installer overlays these onto target `/etc/skel` after the base settings packages and before user creation, including installations that defer user creation until first boot. It never overlays existing home directories.

For China, the builder installs `archlinuxcn-keyring` using the existing Arch trust chain before downloading other regional packages. Signature or keyring failures abort the build; no unverified keyserver trust or online signature bypass is added. The keyring is also installed on the target from the offline package set, then initialized and populated before online repositories are enabled. The ISO's existing offline repository verification policy is unchanged.

## Scope of the China profile

The China profile currently provides repository defaults only. System language (Simplified Chinese), timezone (Asia/Shanghai), and input-method defaults are planned as separate changes on top of this mechanism: `packages` and `skel/` carry them into the ISO, and the installer stages `skel/` before any user exists.

## Remaining release validation

Unit tests cover region/channel independence, package-list augmentation, keyring failure handling, pre-user defaults, generated pacman contents, repeat application, and refresh ordering; refresh itself is exercised only inside the sudo-boundary sandbox. They do not establish live mirror availability, real package trust, or successful offline installation. Before distribution, build from matching local checkouts on an x86_64 builder and run the disposable-VM acceptance workflow in `agents/skills/acceptance-tests.md`.

The China acceptance run must install without network access, boot to a new user, including deferred first-boot user creation, and keep the regional mirrors, repository, marker, and keyring trust through `stable`, `rc`, and `edge` refreshes.
