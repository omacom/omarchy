# Regional defaults

Regions customize bootstrap defaults independently of update channels and of the installer's language. Country identifiers are lowercase, officially assigned ISO 3166-1 alpha-2 codes. `global` is a reserved value for no country-specific additions. Only implemented profiles are accepted; currently `global` and `cn`.

## Runtime configuration

The ISO installer writes the region it derived to `/etc/omarchy/region` before target finalization. It is plain text, not executable configuration, owned by root and world-readable (`0644`), because refresh renders as the calling user. A missing file means `global`; an unsupported value is an error.

`omarchy-apply-pacman <stable|rc|edge> [target-root]` restores the selected channel's two pacman templates, appends the region's `pacman.conf.append` to `pacman.conf`, and puts the region's `mirrorlist-<channel>.prepend` ahead of the channel's mirrorlist. Both files are generated before either live file is replaced. Existing files are backed up with `.bak`. Dev uses the edge pacman channel, as before.

Both installation finalization and `omarchy-refresh-pacman` use this command. Explicit refreshes and channel changes restore regional defaults; ordinary updates do not enforce them. The existing `pre-refresh-pacman` user hook runs after regeneration and before the update, so users can maintain overrides there. Switching to the dev channel refuses a checkout that lacks this machine's region profile, because that checkout's own refresh would otherwise drop the regional repositories. Users can edit the files directly or set the region to `global` before a refresh to stop applying regional repository defaults. This does not uninstall packages or rewrite anything in existing home directories.

Refresh renders both files as the calling user and gives root only the finished copies, so the sudo boundary stays command-scoped. That boundary does not defend against other code already running as the same user: such code could change the rendered files while refresh waits for the password, as it could alter that user's own environment in other ways.

The China profile puts Omarchy's China replica of the channel's Arch mirror first (`stable-mirror.omarchy.cn`, `rc-mirror.omarchy.cn`, or `mirror.omarchy.cn` for edge and dev) and keeps the channel's `.org` mirror as the fallback. pacman tries servers in order and moves to the next one when a download fails, including a 404. After three failed downloads from one server, it skips that server for the rest of the transaction. It also takes the package databases from the first server that answers, without comparing them, so the China replicas must carry complete, current metadata. The profile also adds the ArchLinuxCN community repository from USTC's mirror, run by the University of Science and Technology of China. It does not change the `[omarchy]` package repository. ArchLinuxCN is rolling and built against current Arch, while stable and RC are snapshots, so its packages can need newer libraries than a stable machine has.

## Profile layout

Each profile lives in `default/regions/<code>/`:

- `timezones`: the timezones that select this region, one per line, with blank lines and `#` comments allowed. List tzdata's backward-compatible names too, since the installer's timezone list includes them. A timezone may belong to at most one profile.
- `packages`: additional target packages, in the same format. Every ISO carries every profile's packages in its offline repository; the installer installs them only on targets in that region. A package named `<name>-keyring` is the profile's trust anchor: the builder installs it through Arch's existing trust chain, and a regional target populates the `<name>` keyring.
- `pacman/`: `pacman.conf.append`, added after the channel's `pacman.conf`, and one `mirrorlist-<channel>.prepend` per channel (`stable`, `rc`, `edge`), placed ahead of the channel's mirrorlist so the regional mirror is tried first.

## ISO installer contract

There is one ISO for every region. The companion `omarchy-iso` repository reads the profiles from the runtime it bundles, so a region and its repository defaults can never disagree.

- **Build:** every profile's `packages` go into the offline repository, but not into the base package list. The builder adds each profile's community repository to its writable online config to download them; it does not change its Arch channel mirrors.
- **Install:** the installer maps the timezone the user picked to a region through the `timezones` files; a timezone no profile lists means `global`. It shows the result on the summary screen. Unattended installs can set the region explicitly instead. For a regional install it installs the profile's packages from the offline repository and writes `/etc/omarchy/region`; the runtime finalizer then applies the fragments.
- **Deferred installs** have no timezone until first boot, so they are `global` unless the unattended configuration sets a region.

For China, the builder installs `archlinuxcn-keyring` using the existing Arch trust chain before downloading ArchLinuxCN packages. Signature or keyring failures abort the build; no unverified keyserver trust or online signature bypass is added. On a China target the installer installs the keyring from the offline repository, then initializes and populates it before the online repositories are enabled. Global targets never populate ArchLinuxCN's keys. The ISO's existing offline repository verification policy is unchanged.

## Scope of the China profile

The China profile provides repository defaults only. Language is a separate installer choice, not part of a region: a Chinese speaker outside China keeps global mirrors, and a China install in English still gets the regional ones.

## Remaining release validation

Unit tests cover region/channel independence, the timezone mapping, generated pacman contents, repeat application, and refresh ordering; refresh itself is exercised only inside the sudo-boundary sandbox. They do not establish live mirror availability, real package trust, or successful offline installation. Before distribution, build from matching local checkouts on an x86_64 builder and run the disposable-VM acceptance workflow in `agents/skills/acceptance-tests.md`.

The acceptance run must install without network access in both directions: a non-China timezone must produce pacman files byte for byte identical to the channel templates, and `Asia/Shanghai` must produce the China profile, boot to a new user, and keep the regional mirrors, repository, marker, and keyring trust through `stable`, `rc`, and `edge` refreshes.
