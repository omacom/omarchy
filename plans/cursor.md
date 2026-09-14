# Plan: Malus cursor — package it upstream, then a bar that keeps the arrow

Revision 4. Rev 3 settled on the botanical name; rev 4 drops the AUR step because new AUR accounts cannot be created right now and ships the package as `source: local` in omarchy-pkgs. Rev 2 renamed the theme and went upstream first; Rev 1 installed the AUR `apple_cursor` package locally first; rev 2 goes upstream first (a clean package under a new name, in the AUR and in omarchy-pkgs), and only then installs locally from that package. Drafted against `omacom/omarchy-pkgs` at d5a2f30 and `omacom/omarchy` `quattro` HEAD, 2026-09-10.

## Problem

Omarchy ships no cursor choice. `default-cursors` points `/usr/share/icons/default` at Adwaita, `XCURSOR_THEME` and `HYPRCURSOR_THEME` are unset, and the only cursor setting Omarchy owns is the size (`24`) in `default/hypr/envs.lua`. The macOS pointer is the one most people switching from a Mac want, and today it takes an AUR build plus edits across four layers: Hyprland's own pointer, Wayland-native GTK/Qt/Electron apps (gsettings), XWayland apps (the XCursor default index), and the Quickshell bar.

Separately, the bar shows a pointing hand over every clickable widget. The macOS menu bar, GNOME's top bar, KDE's panel, and Waybar all keep the arrow; the hand is a web convention for hyperlinks.

## Naming

The theme is not called macOS. "macOS" is Apple's mark, and an Omarchy package that ships a theme named after it invites a takedown letter for no gain. The upstream project is `ful1e5/apple_cursor`, GPL-3.0, so redistributing under another name is permitted and only requires keeping the license and attribution.

The name used throughout this plan is **Malus**, the apple genus (*Malus domestica* is the orchard apple): package `malus-cursors`, theme directories `Malus` and `Malus-White`. It says "apple" to anyone who looks it up, carries no trademark, and sorts beside `capitaine-cursors` and `vimix-cursors` in Arch's repos. Nothing in the AUR or the Arch repos uses the name. One caveat worth knowing before it is on the AUR forever: *malus* is also Latin for "bad", so expect the occasional joke. Alternatives in Open Questions.

## What is already in flight upstream

[omacom/omarchy#9539](https://github.com/omacom/omarchy/pull/9539), open since 2026-09-01 with no maintainer review, adds **Style → Cursor** with `omarchy-cursor-set`. Its mechanism is right (XCursor theme through the Hyprland env, gsettings, the X default index, `hyprctl setcursor`), but it downloads Bibata and macOS tarballs from GitHub inside a `bin/` script with pinned URLs and checksums, and its menu entry is literally "macOS". Everything else Omarchy installs comes through omarchy-pkgs and `omarchy-pkg-add`. Once `malus-cursors` is a package, that PR's `ensure_macos` collapses to one line. That is a review comment on #9539 after this lands, not a competing PR.

## What the package contains

The upstream release `v2.0.1` ships `macOS.tar.xz` (5.5 MB): two prebuilt XCursor themes, `macOS/` and `macOS-White/`, each with 145 cursor files (no symlinks), an `index.theme` (`Name=macOS`, `Inherits="hicolor"`) and a `cursor.theme`, plus `LICENSE`. There is no hyprcursor variant; ful1e5 added hyprcursor output to Bibata in its v2.0.7 but never rebuilt apple_cursor.

`malus-cursors` will install, for each of the two variants:

```
/usr/share/icons/Malus/
├── index.theme        Name=Malus, Comment carries upstream version, Inherits=hicolor
├── cursor.theme
├── cursors/           the 145 XCursor files, unchanged
├── manifest.hl        hyprcursor manifest, generated at build time
└── hyprcursors/       hyprcursor shapes, generated at build time
/usr/share/licenses/malus-cursors/LICENSE
```

Shipping the hyprcursor variant in the same directory is how Bibata does it since 2.0.7, and it is what lets Hyprland keep `cursor.enable_hyprcursor` on: `hyprctl setcursor Malus 24` then works without the "disable hyprcursor and reload" dance the #9539 follow-up had to add. The variant is produced from the XCursor files with `hyprcursor-util --extract` then `--create`; that needs `hyprcursor` and `xcur2png`, both in Arch `extra`, as `makedepends`. It is a bitmap conversion, so at integer scale it is pixel-identical to the XCursor theme; at fractional scale it is no worse.

PKGBUILD shape (Arch conventions: `arch=(any)`, `license=('GPL-3.0-only')`, `pkgver=2.0.1`, `url` and `source` pointing at `ful1e5/apple_cursor`, `sha256sums` pinned; `provides`/`conflicts` left empty since nothing else installs `Malus`):

```bash
prepare() {
  mv macOS Malus
  mv macOS-White Malus-White
  for theme in Malus Malus-White; do
    sed -i "s/^Name=.*/Name=$theme/; s/^Comment=.*/Comment=$theme (apple_cursor v$pkgver) XCursors/; s/^Inherits=.*/Inherits=hicolor/" "$theme/index.theme"
    sed -i "s/^Inherits=.*/Inherits=$theme/" "$theme/cursor.theme"
  done
}

build() {
  for theme in Malus Malus-White; do
    hyprcursor-util --extract "$theme" --output "$srcdir/work"
    sed -i "s/^name = .*/name = $theme/" "work/extracted_$theme/manifest.hl"
    hyprcursor-util --create "work/extracted_$theme" --output "$srcdir/out"
  done
}

package() {
  for theme in Malus Malus-White; do
    install -d "$pkgdir/usr/share/icons/$theme"
    cp -r "$theme/." "$pkgdir/usr/share/icons/$theme/"
    cp -r "out/theme_$theme/." "$pkgdir/usr/share/icons/$theme/"
  done
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
```

The exact `hyprcursor-util` output directory names (`extracted_<name>`, `theme_<name>`) and the manifest field names are to be confirmed against the installed `hyprcursor 0.1.13` during implementation; the README documents `$ACTION_$NAME` as the subdirectory pattern.

## Deliverables, in order

### 1. omarchy-pkgs: `malus-cursors` as an Omarchy-owned package

Not via the AUR: new AUR account creation is currently disabled, and omarchy-pkgs does not need it. `source: local` is the documented path for a PKGBUILD Omarchy owns, and `asdcontrol`, `dell-xps-touchpad-haptics`, and the recent "Add …" PRs (#314 vi, #282 slap-notes-bin, #166 hermes-desktop) are all shaped this way: one directory with `PKGBUILD` and `.omarchy/package.json`, sometimes a license or a patch beside them.

```
bin/add-package malus-cursors --local --scaffold   # creates pkgbuilds/malus-cursors/
```

`.omarchy/package.json`:

```json
{
  "source": "local",
  "upstream": {
    "github": "ful1e5/apple_cursor",
    "digests": true,
    "assets": { "any": "macOS.tar.xz" }
  }
}
```

`upstream` makes `bin/sync-upstream` bump `pkgver` and the checksum when ful1e5 tags a new release; `"digests": true` uses the GitHub release API's per-asset digest because apple_cursor publishes no `SHASUMS` file. `bin/sync-upstream` documents `any` as the key that maps to the unsuffixed `sha256sums` array, so an `arch=(any)` package fits the declarative form. Dropping `upstream` entirely (manual bumps, like `libfprint-git`) is also acceptable for a theme whose last release was 2023.

- Default release ring: edge → rc → stable through `bin/repo advance`. Not `fast`.
- Verification before the PR: `makepkg -sf` in `pkgbuilds/malus-cursors/`, `namcap` on the PKGBUILD and the built package, `pacman -Qlp` on the file list, and `sudo pacman -U` here to confirm `hyprctl setcursor Malus 24` is accepted with hyprcursor enabled. `bin/repo build --package malus-cursors` is the repo's own build (makepkg in Docker); Docker is installed but this user is not in the `docker` group, so that needs `sudo usermod -aG docker` plus a re-login, or it stays a maintainer-side check.
- PR to `omacom/omarchy-pkgs` from the `fork` remote (the last one, #321, was this user's), short body: what it ships, why the name, how it was built and verified.

If the AUR opens up later, the same PKGBUILD can be published there and the metadata flipped to `source: aur`; nothing else changes.

### 2. Install locally from the package

Once the package is in `edge` (or, while the PR is open, from the locally built `.pkg.tar.zst` with `sudo pacman -U`):

```
omarchy pkg add malus-cursors
```

Then four user-config edits, all under `~/.config` or the user's gsettings, none in `/usr/share/omarchy`:

1. Append to `~/.config/hypr/looknfeel.lua` (loaded after Omarchy's defaults; `hl.env` is the same call `config/hypr/monitors.lua` already uses). Hyprcursor stays enabled because the package ships the variant:

   ```lua
   hl.env("XCURSOR_THEME", "Malus")
   hl.env("HYPRCURSOR_THEME", "Malus")
   ```

2. `gsettings set org.gnome.desktop.interface cursor-theme Malus` for GTK, Electron, and Qt via the gtk3 platform theme. `omarchy-theme-set-gnome` never touches `cursor-theme`, so this survives theme switches.
3. `~/.icons/default/index.theme` with `Inherits=Malus`, for XWayland clients that ignore the env.
4. `hyprctl setcursor Malus 24` applies Hyprland's pointer immediately after `hyprctl reload`. Everything already running keeps the theme it read at startup, so log out and in to make every layer agree.

Verify: hover a terminal, Chromium, the bar, and an XWayland window and see the same black pointer at the same size; `hyprctl getoption cursor:enable_hyprcursor` still reads `true`.

### 3. omarchy: the bar keeps the arrow (one small PR, independent of the above)

Sites that set a hand cursor on the bar itself:

| File | What it is | Change |
|---|---|---|
| `shell/Ui/WidgetButton.qml:101` | Base for workspaces, keyboard layout, clock, menu button, and any widget built on it | `Qt.ArrowCursor` |
| `shell/plugins/bar/Bar.qml:1916` | Module-slot overlay that shows a hand over any click target | `Qt.ArrowCursor` |
| `shell/plugins/bar/widgets/ActiveWindow.qml:49` | Window title | `Qt.ArrowCursor` |
| `shell/plugins/bar/widgets/Tray.qml:823` | Tray icon on the bar | `Qt.ArrowCursor` |

Left alone, deliberately: `Bar.qml:1647` (closed hand while dragging a module to reorder, which is drag feedback, not hover), `Tray.qml:598` and `:746` (inside the tray's popup menu), and every panel, notification card, launcher, and `KeyboardPanel.qml` (the on-screen keyboard). Hover feedback survives; `WidgetButton` already tints on hover and shows a tooltip.

Unconditional, not a setting. If upstream wants it configurable, the fallback is one `"bar": { "hoverCursor": "arrow" | "hand" }` key read through `BarModel.js` and threaded into the four sites.

Tests: nothing under `test/shell.d/` asserts `cursorShape` today. Add `test/shell.d/bar-cursor-test.sh`, static and compositor-free: `WidgetButton.qml` and the bar widgets' top-level `MouseArea`s must not name `PointingHandCursor`, with the two tray popup ids excluded, so a future widget cannot bring the hand back unnoticed.

Visual verification per `agents/skills/visual-verification.md`: this machine is dev-linked to `~/Work/omarchy-boot-time`, and the link is a path, not a branch. Check `feat/macos-cursor` out in that worktree, `omarchy restart shell`, screenshot the pointer over the clock before and after, switch back to `feat/boot-time`.

### 4. omarchy: follow-up on #9539

After step 1 is published to `edge`, comment on #9539: with `malus-cursors` (and `bibata-cursor-theme-bin`, already in the AUR) packaged, `ensure_bibata` / `ensure_macos` become `omarchy-pkg-add`, the pinned URLs and checksums go away, and the menu entry reads "Malus". If the author wants, offer that as a commit against their branch, the way the earlier follow-up was done. Not a competing PR.

## Rejected approaches

- **Publish to the AUR first and sync from there.** Preferred in rev 2, but AUR account creation is disabled at the moment; `source: local` is the supported alternative and costs nothing but a manual version bump. Revisit if the AUR reopens.
- **Use the existing AUR `apple_cursor` as-is.** It installs the theme as `macOS`, has no hyprcursor variant, and would put Apple's mark in Omarchy's menu and package list.
- **Rename inside omarchy-pkgs with `.omarchy/patches` over the AUR `apple_cursor`.** Patching a rename plus a build step onto someone else's PKGBUILD is more fragile than owning a small one, and the AUR package name would still be `apple_cursor`.
- **Build from `bitmaps.zip` with clickgen.** ful1e5's own pipeline, and it can emit hyprcursor directly, but it pulls a Python toolchain into `makedepends` to reproduce files the release already ships. The XCursor files are the artifact; convert those.
- **Hyprcursor-only (`apple_hyprcursor`, a third-party v0.1 conversion).** Only changes Hyprland's own pointer; GTK, Qt, Electron, and XWayland still need XCursor.
- **Disable hyprcursor instead of shipping a variant** (what #9539's follow-up does). Works, but it is a global regression for every other hyprcursor theme the user might pick later, and it makes `hyprctl setcursor` refuse the theme without a reload.
- **Putting the cursor in the color theme (`themes/*/`).** Pointer style is orthogonal to palette.
- **A `shell.json` toggle for the bar cursor as the first cut.** A setting is the fallback, not the design.

## Rollout

1. `omarchy-pkgs`: branch from `origin/master` in `~/Work/omarchy-pkgs`, scaffold `malus-cursors`, write the PKGBUILD, `makepkg` + `namcap`, install here and verify `setcursor` with hyprcursor on, PR.
2. Local config: the four edits in step 2, once the package is installed.
3. Bar arrow PR from `~/Work/omarchy-cursor` (`feat/macos-cursor`, to be renamed `feat/bar-arrow-cursor` before pushing).
4. Comment on #9539 once the package is published to `edge`.

## Open questions

- Name: `Malus` is the pick. Also considered: `Cupertino` (the usual euphemism, dropped in favor of the botanical name), `Domestica`, `Pomum`. `Apple` and `macOS` are out.
- `Malus-White` ships in the same package (decided; the pair is 5 MB).
- Keep the closed-hand cursor during module drag on the bar. Plan keeps it.
- Whether the `-White` variant should be selectable in #9539's menu; not this plan's call.
