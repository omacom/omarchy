---
name: omarchy-app
description: >
  Build a new desktop app for Omarchy the way Omarchy's own apps are built (Omacut, Monologue, Hype, Signed, Folio, Plain, Omawrite, Omacalc): C++ and Qt Quick, built with CMake into a single binary, following the Omarchy theme and language live, tested offscreen on every push, and packaged in omarchy-pkgs so it shows up in the app launcher. Use when asked to make, build, or scaffold an app, tool, utility, or GUI program for the desktop. Triggers: new app, make me an app, desktop app, GUI, Qt, QML, Qt Quick, C++ app, CMake, app launcher entry, PKGBUILD for my app.
---

# Building an Omarchy App

Omarchy's own apps are dead simple on purpose: one window, one job, driven from the keyboard, following the desktop's theme and language, and installed like any other package. Build new ones the same way. `templates.md` has the starter files; the ones it marks as shared are the same byte for byte in every Omarchy app, so a fix to one reaches all of them. The published apps are the reference for anything bigger:

- Omacut, a video trimmer: https://github.com/omacom/omacut. Its `src/portalfilepicker.{h,cpp}` is the file picker to copy.
- Monologue, a webcam recorder: https://github.com/omacom/monologue. `tests/ui_tests.cpp` drives the real `Main.qml` against a fake backend and fails on any QML warning.
- Hype, Markdown presentations: https://github.com/omacom/hype. `src/cli.cpp` is the command line for agents.
- Signed, PDF signing: https://github.com/omacom/signed. `tests/test_cli.py` drives the binary with no display.
- Folio, the file manager: https://github.com/omacom/folio. The translation pipeline (`scripts/i18n-sync.py`, `docs/i18n.md`, and the catalog tests), and background work that outlives its window.
- Plain, the config file editor: https://github.com/omacom/plain. The most careful file handling, and the keyboard for an app you type into.
- Omawrite, a writing app: https://github.com/omacom/omawrite. Tests that drive the real window, and text that survives a round trip through `QTextDocument`.
- Omacalc, the calculator: https://github.com/omacom/omacalc.
- Omasnap, screenshots and annotation: https://github.com/omacom/omasnap. Built on Qt Widgets and layer-shell rather than Qt Quick, so a reference for capture, not for shape.

## Before writing code

Ask what the app should do if it isn't clear, and settle the one job it does. Pick a short lowercase name (`tally`, `pomo`); it is the binary, the package, the `.desktop` file, the icon, and the Wayland app id all at once. Create the project in `~/Work/<name>` unless the user says otherwise, and `git init` it.

Everything an app needs is part of Omarchy: `cmake`, `make`, a C++ compiler, Qt's base, declarative, multimedia, SVG, and Wayland modules, and `ffmpeg`. If `cmake` is missing, install the set with `omarchy-pkg-add base-devel cmake qt6-base qt6-declarative qt6-multimedia qt6-svg qt6-wayland ffmpeg`.

## Shape

```text
CMakeLists.txt               src/ as a library, the app, the tests, warnings, install rules
bin/build                    shared: cmake into build/
bin/test                     shared: builds, then runs ctest offscreen
.github/workflows/test.yml   shared: builds and tests on Arch on every push
src/main.cpp                 app setup; hands C++ objects to QML
src/backend.{h,cpp}          the app's state and work, as a QObject
src/theme.{h,cpp}            the Omarchy palette, light or dark, and Hyprland's rounding
src/translator.{h,cpp}       shared: follows the Omarchy language
src/Main.qml                 the window: layout, keys, nothing else
src/resources.qrc            compiles the QML, the icon, and the catalogs into the binary
src/i18n/<code>.json         en.json lists every string; one catalog per language
tests/<name>_tests.cpp
share/<name>.desktop  share/<name>.svg
README.md  LICENSE  .gitignore
```

`src/` stays flat, and a new file there needs no change to `CMakeLists.txt`. No build directories checked in, no generated files committed. No `PKGBUILD` and no `bin/install` in the app's repository: the package lives in `omacom/omarchy-pkgs` (see *README and release*), and `cmake --install` covers trying the app in the launcher before then.

## How the pieces split

- **C++ owns the logic**: state, files, processes, anything that can fail. Expose it as a `QObject` with `Q_PROPERTY … NOTIFY` for state and `Q_INVOKABLE` for actions, handed to QML with `engine.rootContext()->setContextProperty("backend", &backend)`. A value QML shows is a property with a `NOTIFY` signal, never a `Q_INVOKABLE` getter: nothing tells a binding that a getter's answer changed, so it shows stale state until something else in the binding happens to change.
- **QML owns layout and interaction**: an `ApplicationWindow` in `Main.qml`, a few components beside it, and every key binding as a `Shortcut`. Leave its context at the default, the window: with `Qt.ApplicationShortcut`, an app with several windows has the same key claimed by each, and it becomes ambiguous or acts on a window that isn't in front.
- Use `QGuiApplication`, not `QApplication`. Call `app.setDesktopFileName("<name>")` so the compositor and launcher match the window to its `.desktop` file and icon.
- Use the Material style, light or dark as the theme is, with the theme's colors as `Material.accent`, `Material.background`, and `Material.foreground`.
- Heavy media work goes through the `ffmpeg`/`ffprobe` command-line tools via `QProcess`, not by linking libav.
- Open and save dialogs go through xdg-desktop-portal over D-Bus (`org.freedesktop.portal.FileChooser`), never `QFileDialog`. Copy Omacut's `src/portalfilepicker.{h,cpp}` behind its abstract `src/filepicker.h`, with its attribution: it is the one that survives a portal that stops answering or is replaced mid-dialog, and the other apps' copies have drifted from it. The abstract picker lets tests inject a fake.

## Omarchy conventions

- **Follow the theme live, all of it.** The template `Theme` reads the whole palette from `~/.local/state/omarchy/current/theme/colors.toml`, not only the accent: `accent`, `background`, and `foreground` as properties, and every other key in `theme.colors` (`theme.colors.selection`, `theme.colors.red`). Themes are light as well as dark, so the window takes `theme.background` and `Material.theme: theme.light ? Material.Light : Material.Dark` rather than a hard-coded dark color, and anything drawn on the accent uses `theme.accentForeground`, since a fixed white label is unreadable on a light accent. Theme files write colors quoted, bare, or with a trailing comment, and `readThemeColors()` takes all three. A theme switch replaces files and symlinks, so the watcher re-arms on every change, and watching the nearest existing ancestor means installing Omarchy later works without a restart. Without Omarchy it falls back to a dark palette with `#FFD60A`. Never change Omarchy's config.
- **React to events, never poll.** Omarchy's `AGENTS.md` asks long-running code to react to events rather than poll with a timer. Hyprland's rounding has an event: the template `Theme` asks `hyprctl` on start and again whenever Hyprland's event socket announces `configreloaded`, which it sends once new values are in effect, the same way Omarchy's own shell follows it; if the socket drops, it reconnects and asks again. Do the same for anything else the app follows, and where a poll is truly the only way, stop it while the window is inactive.
- **Speak the user's language.** Omarchy runs in 50 languages, and the app follows the one picked under Setup > Language, live, like the theme. Write every visible string as `qsTr("Save")` in QML or `tr("Save")` in C++, with `%1` placeholders filled by `.arg()` rather than sentences glued together, and a counted string as `qsTr("%Ln clips", "", count)` so each language gets its own plural forms and digits. Ship translations as `src/i18n/<code>.json` (English text to translation) compiled into the binary, with `en.json` listing every string the app translates, so translators have one file to work from and the tests can tell when a string is missing. The template `Translator` is the one every app carries: it reads `~/.config/omarchy/language`, falls back from `pt-BR` to `pt` to English per string, and sets the default `QLocale` and layout direction from Omarchy's registry. Write numbers and dates through `Qt.locale()` (`value.toLocaleString(Qt.locale(), 'f', 1)`), and keep the window's content under the template's mirrored root so Arabic, Hebrew, Persian, and Urdu read right to left. A binding that formats a date or number reads `translator.language` so it re-renders on a switch. Translate the `.desktop` file's `Name` and `Comment` too (`Name[da]=…`). Keep brand names, units, and keyboard keys as they are. A label with an access key (`qsTr("&Save")`) keeps one in every translation, distinct from the others in its dialog. Folio's `scripts/i18n-sync.py` and its workflow keep 49 catalogs in step with `en.json`.
- **Corners match the windows.** Hyprland's `decoration:rounding` is 0 on Omarchy's default, so corners are sharp unless the theme or the user rounds windows. Use `theme.radius` for every panel, dialog, and button, and cap small elements with `Math.min(4, theme.radius)`. Only true circles keep a fixed radius. A Material control takes it as `Material.roundedScale: theme.radius`, set on each control rather than once on the window, because it isn't inherited. It is an enumeration, so it takes that binding but rejects a literal number: `Material.roundedScale: 6` stops the file from loading.
- **Text follows the desktop's size.** `omarchy display text size` sets the shell's `[font] base-size` in `~/.config/omarchy/shell.toml` (12 px by default, over the theme's own `shell.toml`) and GNOME's `text-scaling-factor` together. An app that is mostly text scales its type from one of them, live: Plain's `Theme` reads `base-size` as `textSize`, and Omacalc and Omawrite follow `text-scaling-factor` through the settings portal.
- **Place things where the pointer is.** Anything the user inserts lands under the mouse when it's over the content (a `HoverHandler` tracks it), and in the middle of what's visible otherwise. Never at a fixed corner.
- **Keyboard first.** `?` shows every shortcut in an overlay, `Q` quits (and asks first when there's unsaved or unexported work), Space is the main action, Ctrl+Z / Ctrl+Shift+Z undo and redo. The README lists the shortcuts in a table. An app you type into (an editor, or anything whose text field has focus most of the time) can't give bare keys away, so it shows the shortcuts on F1 and Ctrl+?, quits on Ctrl+Q, closes on Ctrl+W, and puts its actions on Ctrl and a letter; and any single-key shortcut elsewhere in an app is disabled while a text field has focus.
- **Careful with data.** Never modify the user's originals. Save atomically with `QSaveFile` and `setDirectWriteFallback(false)`, so a folder it can't write a temp file in fails the save rather than having the file truncated and rewritten in place. A `QTemporaryFile` renamed into place arrives as 0600 whatever the umask, so give it the replaced file's permissions, or the umask's default, before the rename. Ask before discarding work, and decide what is unsaved by comparing the content with what was last saved, not by counting edits, so undoing back to the saved text is clean again. Dismissing a question (Escape, closing it) takes the answer that loses nothing, and pauses anything automatic, such as an auto-save, until the user decides.
- **Work finishes, off the GUI thread.** Anything slow (a process, a large file, a network call) runs on a worker thread or as an asynchronous `QProcess`, never behind a `waitForFinished` on the GUI thread. Closing the last window quits the event loop under whatever is still running, so each background job holds a `QEventLoopLocker` until it is done, and the app stays running, windowless, until the work is.
- **Open instantly; load video only when it's shown.** Creating any `MediaPlayer`, `AudioOutput`, or `VideoOutput` starts Qt Multimedia's FFmpeg backend, which probes the GPU's hardware decoders (Vulkan, CUDA) on the GUI thread, adding about two seconds to every launch on an NVIDIA machine, whether or not anything plays. Keep them in a `Loader` that turns on with the first video and stays on (Hype's `videoLoader`), and don't disable hardware decoding to dodge it. Time the window opening (`hype open`, then the window appearing in `hyprctl clients`) when adding a module: a window should be up in well under half a second.
- **Say what's wrong.** A missing tool, device, or permission is reported in the window, never worked around by quietly doing less.
- **Agents can drive it.** If the app makes or changes files, give it commands that need no display, as Hype does (`hype check`, `hype render`, `hype export`): each takes `--json`, exits 0 or 1 with errors on stderr, and `<name> skill install` installs a short agent skill bundled in the binary. `QGuiApplication` aborts in its constructor when there is no display, before the app has seen its arguments, so decide whether the command needs a window first: set `QT_QPA_PLATFORM=offscreen` for those commands and for `--help` and `--version`, and keep the GUI behind `<name> open`. Hype's `src/cli.cpp` is the pattern, and Signed's `tests/test_cli.py` tests one.
- Comments explain why, in full sentences. Commit messages are short and imperative ("Trim from the keyboard").

## Tests

`bin/test` builds and runs every test `CMakeLists.txt` registers with `add_test`, offscreen, and the app's CI runs the same on every push. The template's test file is the minimum a new app keeps:

- **The backend**, one `private slots:` case per behavior, with temp directories for anything that reads the disk.
- **The theme and the translator**, each built with a temp directory, a fake `hyprctl`, a local event socket, and a temp language file, never the user's own.
- **The catalogs.** `en.json` lists exactly the strings the sources translate, and every other catalog translates only what `en.json` has, with the same placeholders and an `other` plural form. They catch the string someone added without a catalog entry.
- **The real window.** Load `qrc:/Main.qml` with the real `Theme`, `Translator`, and `Backend` (or a QML fake backend, as Monologue's `tests/ui_tests.cpp` does once the backend needs devices), drive it with `QTest` keys and clicks, and fail on any QML warning the engine reports. Give it a `Translator` reading a temp language file, or a desktop set to Danish fails the English assertions.

A test binary that isn't registered with `add_test` never runs, and `ctest` with nothing to run passes, so register each one. A test that needs a tool CI may lack fails without it rather than skipping, or a green run proves nothing. Whatever a test needs beyond the app's own dependencies (a font, a codec, a tool) is a `checkdepends` in the app's recipe in omarchy-pkgs, which is where CI reads it from: the CI container has no fonts at all until one is listed.

## Loop

1. `bin/build`, then run `build/<name>` to try it. Pass a file argument if the app opens files, so it's quick to test.
2. `bin/test` after each change. Its arguments go to `ctest`, so `bin/test -V` shows every Qt test function as it runs. Warnings are on for the whole project; keep the build free of them.
3. Look at it. Take a screenshot with `omarchy capture screenshot fullscreen save` and check the window against the theme, on a light theme as well as a dark one, before calling it done. Switch the language once (`omarchy language da`) and look again: longer words must not clip, and nothing should still be in English. Try a right-to-left language too, and open every dialog and popup, not only the window.
4. Drive the real QML offscreen when a change is about interaction. A small harness in the scratchpad that loads `qrc:/Main.qml` with `QT_QPA_PLATFORM=offscreen`, sends mouse and key events, and saves `window->grabWindow()` shows what the user would see without touching their desktop. Set `QT_FORCE_STDERR_LOGGING=1`, or QML warnings go to the journal instead of the terminal. What it proves worth keeping moves into the tests.
5. `cmake --install build --prefix ~/.local` installs the binary, the `.desktop` entry, and the icon for this user, so the app appears in the Omarchy app launcher (`Super + Space`) before it is packaged. Run it again after every change the user should see there. Once the package is installed, remove the local copy with `xargs rm < build/install_manifest.txt`, or its `.desktop` entry keeps shadowing the package's.

## Qt Quick traps

- Don't name a component file after a Qt Quick type: `ItemView.qml` fails with "abstract base class". Prefix it with what it shows (`PlacedItem.qml`).
- A `MouseArea` inside a `ListView` or `Flickable` loses its drag after a few pixels unless it sets `preventStealing: true`.
- `ListView` pins delegates to `x: 0`. To center content, make the delegate a full-width `Item` and center the content inside it.
- Every file that sets a `Material.*` attached property must import `QtQuick.Controls.Material`, or the file fails to load.
- A Material `TextField` floats its `placeholderText` as the label. Don't add a separate label above it, or the two overlap.
- `font.pixelSize` is an int. Standard keys go in `sequences: [StandardKey.Undo]`, not `sequence:`.
- A `Popup` or `Dialog` is not an `Item` and doesn't inherit the window's `LayoutMirroring`; set on the popup itself it only logs a warning. Set it on the popup's content and its button box. Mirroring flips anchors and layouts, not explicit `x` positions: anything placed by `x` (a timeline, a ruler, a strip of pages) computes its own mirrored position, or stays left to right on purpose.
- A Material `Popup` animates out: after `close()` its `opened` is false at once, and `visible` only when the transition ends, so wait on the one you mean. A popup that should close on Escape needs `focus: true`.
- A highlighted Material `Button` colors its caption by Material's own rule and ignores `Material.foreground`, so a caption that must read on the accent replaces the `contentItem`, as the template's does.
- Hyprland sizes a new window only once it is on screen, so the first frames are laid out at the size the app asked for and then again at the real one, and the content visibly jumps. Folio keeps the content hidden until the size has settled.
- `QIcon` takes a file name, so `QIcon("qrc:/<name>.svg")` is always null; the resource is `":/<name>.svg"`, and an SVG icon needs `qt6-svg`'s icon engine at run time.
- `QTextDocument::toPlainText()` and `TextEdit`'s `text` turn non-breaking spaces into spaces and line separators into newlines, so an editor that saves from them rewrites characters the user never touched. Save from `toRawText()`, with only the paragraph separators turned back into newlines.
- `TextEdit` draws only the visible lines of a long text (over 10,000 characters) when the text arrives through its `text` property. Text put in through a cursor, as an undoable reload does, redraws every line on every keystroke unless the item sets `ItemObservesViewport` itself.
- Qt lays out a text line's formats in quadratic time, so a syntax highlighter leaves very long lines (thousands of characters) uncolored. It still scans them, or a comment or string they open or close stops carrying on to the lines after.
- A string C++ translated once and kept (a status line, an error) stays in the old language after a switch. Rebuild it when `Translator::changed` fires, or keep the English and its arguments and translate it where it is shown.
- The template `Translator` sets the default `QLocale` from the Omarchy language, so with English picked, numbers and dates take English's format rather than the system's regional settings. That is right for what the app shows; a date the app writes into the user's own document should choose which it wants.
- moc reads every file that has `Q_OBJECT` and doesn't understand raw string literals: one holding a lone `"`, such as a regular expression for `qsTr("…")`, derails it, and the error arrives at link time as an undefined reference to the class's vtable. Write such a string as an ordinary escaped literal.
- Text that must look the same on screen and in an exported file is measured and painted by one C++ function, used by a `QQuickPaintedItem` on screen and by the exporter, rather than laid out twice.

## README and release

- The README opens with a screenshot of the app doing its job. Grab it from the offscreen harness, with the default accent so it doesn't depend on the current theme, and with made-up content: never the user's name, signature, files, or other personal data.
- The package lives in `omacom/omarchy-pkgs`, never in the app's repository. To ship: tag `v<version>` and make a GitHub release, then add the recipe under `pkgbuilds/<name>/` as `templates.md` shows, building from the release tarball, with `.omarchy/package.json` set to `"source": "local"`, `"auto_merge": true`, and an `upstream.watch` on the GitHub repo so later releases sync on their own. omarchy-pkgs merges a collaborator's package pull request by itself once its build is green, so open one as a draft when it isn't meant to land yet.
- That recipe is the app's one list of dependencies: the app's CI reads `depends`, `makedepends`, and `checkdepends` from it rather than keeping a copy. Until the recipe has landed, CI fails at installing them and `bin/test` is the check. A new dependency, a test-only one included, goes into the recipe along with the code that needs it.
- Only once that package is published can Omarchy install it: `install/omarchy-base.packages`, the preinstall scripts, and a migration for existing machines.
