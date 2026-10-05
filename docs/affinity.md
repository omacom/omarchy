# Affinity on Wine

Affinity (Studio, and the earlier Photo/Designer/Publisher apps) is a Windows
application. Omarchy runs it through the `affinity-appimage-bin` package, an
AppImage that bundles its own Wine build and a pre-built Wine prefix at
`~/.AffinityLinux-Appimage`. The mutable user data lives in `$HOME`, not under
the read-only AppImage mount.

Omarchy's own pieces are the opener (`default/applications/affinity-open`, the
`affinity-open` command), the MIME definitions, the desktop entry, the icon,
`omarchy-launch-affinity`, `omarchy-install-creative-affinity`,
`omarchy-remove-creative-affinity`, and the window rules under
`default/hypr/apps/affinity.lua`.

## The baked prefix username

The AppImage ships its prefix built under the username `matt`. On first run its
`AppRun` copies the prefix into `~/.AffinityLinux-Appimage`, renames
`drive_c/users/matt` to the current user, and tries to rewrite the registry paths
to match. That rewrite uses a `sed` that never matches the doubled backslashes
in the `.reg` files, so `HKCU\Environment\TEMP` and `TMP` keep pointing at
`C:\users\matt\...` even though that directory no longer exists.

Wine's printer backend creates its temporary PPD directory under `TEMP` before
it registers any CUPS printer (`get_ppd_dir` in `winspool.drv/info.c`). When
that path does not resolve, the registration loop bails before adding the
printer, and `EnumPrintersW` returns nothing — so Affinity, which lists printers
through `EnumPrintersW`, shows none even though CUPS itself works.

`omarchy-launch-affinity` repairs this before Wine starts. With the wineserver
down, it reads the profile names out of the registry files and, for every stale
name that has no directory, points it at the real user with a symlink. The
registry paths resolve again and the printer appears. The link is only created
for a name with no directory, so a prefix where the rename was skipped keeps its
real directory. The repair runs on every launch and is idempotent; a fresh
install's first session starts before the prefix exists and is repaired on the
next launch.
