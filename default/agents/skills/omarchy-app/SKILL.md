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
src/theme.{h,cpp}       follows the Omarchy accent color
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
- **Keyboard first.** `?` shows every shortcut in an overlay, `Q` quits (and
  asks first when there's unsaved or unexported work), Space is the main
  action, Ctrl+Z / Ctrl+Shift+Z undo and redo. The README lists the shortcuts
  in a table.
- **Careful with data.** Never modify the user's originals. Save atomically
  (write beside the target, then rename). Ask before discarding work.
- **Say what's wrong.** A missing tool, device, or permission is reported in
  the window, never worked around by quietly doing less.
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
4. `bin/install` builds the package with `makepkg -fsi`, which installs the
   binary, the `.desktop` entry, and the icon. The app then appears in the
   Omarchy app launcher (`Super + Space`). Run it again after every change
   the user should see there.
