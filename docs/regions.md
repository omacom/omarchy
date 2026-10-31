# Regional defaults

Regions customize bootstrap defaults independently of update channels and of the installer's language. Country identifiers are lowercase, officially assigned ISO 3166-1 alpha-2 codes. `global` is a reserved value for no country-specific additions. Only implemented profiles are accepted; currently `global` and `cn`.

## Runtime configuration

The ISO installer writes the region it derived to `/etc/omarchy/region` before target finalization. It is plain text, not executable configuration, owned by root and world-readable (`0644`), because refresh renders as the calling user. A missing file means `global`; an unsupported value is an error.

`omarchy-apply-pacman <stable|rc|edge> [target-root]` restores the selected channel's two pacman templates for this machine's platform (`install/helpers/pacman.sh`), puts the region's `omarchy-<channel>.prepend` server first in the `[omarchy]` section of `pacman.conf`, and puts the region's `mirrorlist-<channel>.prepend` ahead of the channel's mirrorlist. Profiles carry x86 mirrors only so far, so on ARM platforms a regional machine keeps its platform's channel templates unchanged until a profile adds ARM mirrors. Both files are generated before either live file is replaced. Existing files are backed up with `.bak`. Dev uses the edge pacman channel, as before.

Both installation finalization and `omarchy-refresh-pacman` use this command. Explicit refreshes and channel changes restore regional defaults; ordinary updates do not enforce them. The existing `pre-refresh-pacman` user hook runs after regeneration and before the update, so users can maintain overrides there. Switching to the dev channel refuses a checkout that lacks this machine's region profile, because that checkout's own refresh would otherwise drop the regional mirrors. Users can edit the files directly or set the region to `global` before a refresh to stop applying regional mirrors. This does not uninstall packages or rewrite anything in existing home directories.

Refresh renders both files as the calling user and gives root only the finished copies, so the sudo boundary stays command-scoped. That boundary does not defend against other code already running as the same user: such code could change the rendered files while refresh waits for the password, as it could alter that user's own environment in other ways.

The China profile changes only where packages come from, never which repositories or keys are trusted. It puts Omarchy's China replica of the channel's Arch mirror first (`stable-mirror.omarchy.cn`, `rc-mirror.omarchy.cn`, or `mirror.omarchy.cn` for edge and dev) and Omarchy's China replica of the `[omarchy]` repository first (`pkgs.omarchy.cn/<channel>`), keeping the `.org` servers as the fallback. Both replicas serve the same signed packages as `.org`, so package signatures are checked against the same keys as everywhere else. pacman tries servers in order and moves to the next one when a download fails, including a 404. After three failed downloads from one server, it skips that server for the rest of the transaction. It also takes the package databases from the first server that answers, without comparing them, so the China replicas must carry complete, current metadata; they sync from `.org` within minutes.

Installs from before regions have no marker and stay global; nothing changes their pacman files on update. An existing machine in mainland China opts in by writing the marker and refreshing: `echo cn | sudo tee /etc/omarchy/region` then `omarchy-refresh-pacman`, which backs up both files first.

## Profile layout

Each profile lives in `default/regions/<code>/`:

- `timezones`: the timezones that select this region, one per line, with blank lines and `#` comments allowed. List tzdata's backward-compatible names too, since the installer's timezone list includes them. A timezone may belong to at most one profile.
- `pacman/`: per channel (`stable`, `rc`, `edge`), `omarchy-<channel>.prepend`, placed first in the `[omarchy]` section of `pacman.conf`, and `mirrorlist-<channel>.prepend`, placed ahead of the channel's mirrorlist, so the regional mirrors are tried first.

A profile adds mirrors of repositories every install already uses, never a repository or a signing key of its own. Hong Kong, Macau and Taiwan belong to no profile under any timezone name, and a test keeps it that way.

## ISO installer contract

There is one ISO for every region. The companion `omarchy-iso` repository reads the profiles from the runtime it bundles, so a region and its repository defaults can never disagree.

- **Build:** the builder bundles the profiles with the runtime; it adds no repository, key or package for them.
- **Install:** the installer maps the timezone the user picked to a region through the `timezones` files; a timezone no profile lists means `global`. It shows the result on the summary screen. Unattended installs can set the region explicitly instead. For a regional install it writes `/etc/omarchy/region`; the runtime finalizer then applies the fragments.
- **Deferred installs** have no timezone until first boot, so they are `global` unless the unattended configuration sets a region.


## Scope of the China profile

The China profile provides repository defaults only. Language is a separate installer choice, not part of a region: a Chinese speaker outside China keeps global mirrors, and a China install in English still gets the regional ones.

## Remaining release validation

Unit tests cover region/channel independence, the timezone mapping, generated pacman contents, repeat application, and refresh ordering; refresh itself is exercised only inside the sudo-boundary sandbox. They do not establish live mirror availability, real package trust, or successful offline installation. Before distribution, build from matching local checkouts on an x86_64 builder and run the disposable-VM acceptance workflow in `agents/skills/acceptance-tests.md`.

The acceptance run must install without network access in both directions: a non-China timezone must produce pacman files byte for byte identical to the channel templates, and `Asia/Shanghai` must produce the China profile, boot to a new user, and keep the regional mirrors and marker through `stable`, `rc`, and `edge` refreshes.
