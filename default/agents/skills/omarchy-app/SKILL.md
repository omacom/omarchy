---
name: omarchy-app
description: >
  Build a new desktop app for Omarchy the way Omarchy's own apps are built
  (Hype, Monologue, Omacut): C++ and Qt Quick, compiled with qmake6 and make
  into a single binary, following the Omarchy theme live, and installed as an
  Arch package so it shows up in the app launcher. Use when asked to make,
  build, or scaffold an app, tool, utility, or GUI program for the desktop.
  Triggers: new app, make me an app, desktop app, GUI, Qt, QML, Qt Quick, C++
  app, qmake, app launcher entry, PKGBUILD for my app.
---

# Building an Omarchy App

Omarchy's own apps are dead simple on purpose: one window, one job, driven
from the keyboard, following the desktop theme, and installed like any other
package. Build new ones the same way. `templates.md` has the starter files;
the published apps are the reference for anything bigger:

- Omacut, a video trimmer: https://github.com/omacom-io/omacut
- Monologue, a webcam recorder: https://github.com/omacom/monologue
- Hype, Markdown presentations: https://github.com/omacom/hype
- Signed, PDF signing: https://github.com/omacom/signed

## Before writing code

Ask what the app should do if it isn't clear, and settle the one job it does.
Pick a short lowercase name (`tally`, `pomo`); it is the binary, the package,
the `.desktop` file, the icon, and the Wayland app id all at once. Create the
project in `~/Work/<name>` unless the user says otherwise, and `git init` it.

Everything an app needs is part of Omarchy: `qmake6`, `make`, a C++
compiler, Qt's base, declarative, multimedia, SVG, and Wayland modules, and
`ffmpeg`. If `qmake6` is missing, install the set with `omarchy-pkg-add
base-devel qt6-base qt6-declarative qt6-multimedia qt6-svg qt6-wayland ffmpeg`.

## Shape

```text
<name>.pro              qmake project: Qt modules, sources, resources
bin/build               qmake6 + make into build/<name>
bin/test                builds and runs the Qt Test binary offscreen
bin/install             makepkg -fsi, so the app lands in the launcher
src/main.cpp            app setup; hands C++ objects to QML
src/backend.{h,cpp}     the app's state and work, as a QObject
src/theme.{h,cpp}       follows the Omarchy accent and Hyprland's rounding
src/Main.qml            the window: layout, keys, nothing else
src/resources.qrc       compiles the QML into the binary
tests/<name>_tests.{pro,cpp}
pkgbuild/PKGBUILD  pkgbuild/<name>.desktop  pkgbuild/<name>.svg
README.md  LICENSE  .gitignore
```

`src/` stays flat. No CMake, no build directories checked in, no generated
files committed.

## How the pieces split

- **C++ owns the logic**: state, files, processes, anything that can fail.
  Expose it as a `QObject` with `Q_PROPERTY … NOTIFY` for state and
  `Q_INVOKABLE` for actions, handed to QML with
  `engine.rootContext()->setContextProperty("backend", &backend)`.
- **QML owns layout and interaction**: an `ApplicationWindow` in `Main.qml`,
  a few components beside it, and every key binding as a `Shortcut` with
  `context: Qt.ApplicationShortcut`.
- Use `QGuiApplication`, not `QApplication`. Call
  `app.setDesktopFileName("<name>")` so the compositor and launcher match the
  window to its `.desktop` file and icon.
- Use the Material style with `Material.theme: Material.Dark` and the theme
  accent as `Material.accent`, on a dark window color.
- Heavy media work goes through the `ffmpeg`/`ffprobe` command-line tools via
  `QProcess`, not by linking libav.
- Open and save dialogs go through xdg-desktop-portal over D-Bus
  (`org.freedesktop.portal.FileChooser`), never `QFileDialog`. Omacut's
  `src/portalfilepicker.{h,cpp}` behind an abstract `src/filepicker.h` is the
  pattern to copy, with its attribution, and lets tests inject a fake picker.

## Omarchy conventions

- **Follow the theme live.** Read `accent` from
  `~/.local/state/omarchy/current/theme/colors.toml` and watch it; a theme
  switch replaces files and symlinks, so re-arm the watcher on every change.
  Fall back to `#FFD60A` when Omarchy isn't there. `templates.md` has the
  `Theme` class. Never change Omarchy's config.
- **Speak the user's language.** Omarchy runs in 50 languages, and the app
  follows the one picked under Setup > Language, live, like the theme. Write
  every visible string as `qsTr("Save")` in QML or `tr("Save")` in C++, with
  `%1` placeholders filled by `.arg()` rather than sentences glued together,
  and a counted string as `qsTr("%n clips", "", count)` so each language gets
  its own plural forms. Ship translations as `src/i18n/<code>.json` (English
  text to translation) compiled into the binary. The `Translator` in
  `templates.md` reads `~/.config/omarchy/language`, falls back from `pt-BR`
  to `pt` to English per string, and sets the default `QLocale` and layout
  direction from Omarchy's registry: write numbers and dates through
  `Qt.locale()` (`value.toLocaleString(Qt.locale(), 'f', 1)`) so they take
  the language's separators and digits, and keep the window's content under
  the template's mirrored root so Arabic, Hebrew, Persian, and Urdu read
  right to left. A binding that formats a date or number should read
  `translator.language` so it re-renders on a switch. Translate the
  `.desktop` file's `Name` and `Comment` too (`Name[da]=…`). Keep brand
  names, units, and keyboard keys as they are.
- **Corners match the windows.** Hyprland's `decoration:rounding` is 0 on
  Omarchy's default, so corners are sharp unless the theme or the user rounds
  windows. The template `Theme` asks `hyprctl` for the effective value and
  exposes it as `theme.radius`; use it for every panel, dialog, and button,
  set `Material.roundedScale: theme.radius` on the window and on Material
  controls in other files, and cap small elements with
  `Math.min(4, theme.radius)`. Only true circles keep a fixed radius.
- **Place things where the pointer is.** Anything the user inserts lands
  under the mouse when it's over the content (a `HoverHandler` tracks it),
  and in the middle of what's visible otherwise. Never at a fixed corner.
- **Keyboard first.** `?` shows every shortcut in an overlay, `Q` quits (and
  asks first when there's unsaved or unexported work), Space is the main
  action, Ctrl+Z / Ctrl+Shift+Z undo and redo. The README lists the shortcuts
  in a table.
- **Careful with data.** Never modify the user's originals. Save atomically
  (write beside the target, then rename). Ask before discarding work.
- **Say what's wrong.** A missing tool, device, or permission is reported in
  the window, never worked around by quietly doing less.
- **Agents can drive it.** If the app makes or changes files, give it
  commands that need no display, as Hype does (`hype check`, `hype render`,
  `hype export`): each takes `--json`, exits 0 or 1 with errors on stderr, and
  `<name> skill install` installs a short agent skill bundled in the binary.
  Set `QT_QPA_PLATFORM=offscreen` before `QGuiApplication` for those commands,
  and keep the GUI behind `<name> open`. Hype's `src/cli.cpp` is the pattern.
- Comments explain why, in full sentences. Commit messages are short and
  imperative ("Trim from the keyboard").

## Loop

1. `bin/build`, then run `build/<name>` to try it. Pass a file argument if
   the app opens files, so it's quick to test.
2. `bin/test` after each change to the backend. Tests compile `../src/*.cpp`
   straight in, run offscreen, and pass temp directories to anything that
   reads the disk (the `Theme` takes the theme directory as an argument).
3. Look at it. Take a screenshot with `omarchy capture screenshot fullscreen
   save` and check the window against the theme before calling it done.
   Switch the language once (`omarchy language da`) and look again: longer
   words must not clip, and nothing should still be in English.
4. Drive the real QML offscreen when a change is about interaction. A small
   harness in the scratchpad that loads `qrc:/Main.qml` with
   `QT_QPA_PLATFORM=offscreen`, sends mouse and key events, and saves
   `window->grabWindow()` shows what the user would see without touching
   their desktop. Set `QT_FORCE_STDERR_LOGGING=1`, or QML warnings go to the
   journal instead of the terminal.
5. `bin/install` builds the package with `makepkg -fsi`, which installs the
   binary, the `.desktop` entry, and the icon. The app then appears in the
   Omarchy app launcher (`Super + Space`). Run it again after every change
   the user should see there.

## Qt Quick traps

- Don't name a component file after a Qt Quick type: `ItemView.qml` fails
  with "abstract base class". Prefix it with what it shows (`PlacedItem.qml`).
- A `MouseArea` inside a `ListView` or `Flickable` loses its drag after a few
  pixels unless it sets `preventStealing: true`.
- `ListView` pins delegates to `x: 0`. To center content, make the delegate a
  full-width `Item` and center the content inside it.
- Every file that sets a `Material.*` attached property must import
  `QtQuick.Controls.Material`, or the file fails to load.
- A Material `TextField` floats its `placeholderText` as the label. Don't add
  a separate label above it, or the two overlap.
- `font.pixelSize` is an int. Standard keys go in `sequences:
  [StandardKey.Undo]`, not `sequence:`.
- Text that must look the same on screen and in an exported file is measured
  and painted by one C++ function, used by a `QQuickPaintedItem` on screen and
  by the exporter, rather than laid out twice.

## README and release

- The README opens with a screenshot of the app doing its job. Grab it from
  the offscreen harness, with the default accent so it doesn't depend on the
  current theme, and with made-up content: never the user's name, signature,
  files, or other personal data.
- To ship: tag `v<version>` and make a GitHub release, then add the package to
  `omacom/omarchy-pkgs` under `pkgbuilds/<name>/` building from the release
  tarball, with `.omarchy/package.json` set to `"source": "local"`,
  `"auto_merge": true`, and an `upstream.watch` on the GitHub repo so later
  releases sync on their own. Only once that package is published can
  Omarchy install it: `install/omarchy-base.packages`, the preinstall
  scripts, and a migration for existing machines.
