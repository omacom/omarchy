---
name: omarchy-app
description: >
  Build a new desktop app for Omarchy the way Omarchy's own apps are built
  (Hype, Monologue, Omacut): C++ and Qt Quick, compiled with qmake6 and make
  into a single binary, following the Omarchy theme live, and installed into
  ~/.local (no sudo) so it shows up in the app launcher in the same run, with
  an Arch package for system-wide installs. Use when asked to make,
  build, or scaffold an app, tool, utility, or GUI program for the desktop.
  Triggers: new app, make me an app, desktop app, GUI, Qt, QML, Qt Quick, C++
  app, qmake, app launcher entry, PKGBUILD for my app.
---

# Building an Omarchy App

Omarchy's own apps are dead simple on purpose: one window, one job, driven
from the keyboard, following the desktop theme, and in the app launcher the
moment they're built. Build new ones the same way, and finish the job: the
app is installed and listed in the launcher before you report back.
`templates.md` has the starter files; the published apps are the reference
for anything bigger:

- Omacut, a video trimmer: https://github.com/omacom-io/omacut
- Monologue, a webcam recorder: https://github.com/omacom/monologue
- Hype, Markdown presentations: https://github.com/omacom/hype
- Signed, PDF signing: https://github.com/omacom/signed

## Before writing code

Ask what the app should do if it isn't clear, and settle the one job it does.
Pick a short lowercase name (`tally`, `pomo`); it is the binary, the package,
the `.desktop` file, the icon, and the Wayland app id all at once. Make sure
it's free before using it, because `bin/install` overwrites whatever has that
name: no `command -v <name>`, no `pacman -Qq <name>` or `pacman -Si <name>`,
no `<name>.desktop` in `~/.local/share/applications` or
`/usr/share/applications`, no `~/Work/<name>`, and no line `<name>` in
`$OMARCHY_PATH/default/omarchy/launcher.hides` (those ids are hidden from the
launcher). Create the project in `~/Work/<name>` unless the user says
otherwise, and `git init` it.

Everything an app needs is part of Omarchy: `qmake6`, `make`, a C++
compiler, Qt's base, declarative, multimedia, SVG, and Wayland modules, and
`ffmpeg`. If `qmake6` is missing, the set is installed with `omarchy-pkg-add
base-devel qt6-base qt6-declarative qt6-multimedia qt6-svg qt6-wayland
ffmpeg`. That needs sudo, which an agent's shell can't answer, so it's the one
step to ask the user to run (`! omarchy-pkg-add …`). Nothing after it needs a
password.

## Shape

```text
<name>.pro              qmake project: Qt modules, sources, resources
bin/build               qmake6 + make into build/<name>
bin/test                builds and runs the Qt Test binary offscreen
bin/install             builds and installs into ~/.local, no sudo: in the launcher at once
bin/uninstall           removes what bin/install put in ~/.local
bin/package             makepkg -fsi, the system-wide Arch package (asks for sudo)
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
  `Qt.locale()` (`value.toLocaleString(Qt.locale(), 'f', 1)`) in QML or
  `QLocale().toString(value, 'f', 1)` in C++ so they take the language's
  separators and digits, and keep the window's content under the template's
  mirrored root so Arabic, Hebrew, Persian, and Urdu read right to left. A
  binding that formats a date or number should read `translator.language` so
  it re-renders on a switch. Remember that `QQmlEngine::retranslate()` only
  re-evaluates QML bindings: any C++ `Q_PROPERTY` holding a translated status
  or error string must also re-translate when `Translator::changed` fires
  (store a `std::function<QString()>` builder in C++ and connect
  `&translator, &Translator::changed, &backend, &Backend::retranslate`), and
  transient status/error banners should be cleared when switching views.
  Translate the `.desktop` file's `Name` and `Comment` too (`Name[da]=…`).
  Keep brand names, units, and keyboard keys as they are.
- **Corners match the windows.** Hyprland's `decoration:rounding` is 0 on
  Omarchy's default, so corners are sharp unless the theme or the user rounds
  windows. The template `Theme` asks `hyprctl` for the effective value and
  exposes it as `theme.radius`; use it for every panel, dialog, input box, and
  button, and cap small elements with `Math.min(4, theme.radius)`. Only true
  circles keep a fixed radius. Do not rely on Material's built-in `Button`
  background or `Material.roundedScale` for buttons: Material 3 defaults
  `Button` to a 48px-tall capsule pill (`Material.FullScale`), draws dark
  elevated buttons nearly the same color as the window (`#1c1b1f`), and draws
  `flat: true` buttons with no visible border until hovered. Use the template's
  inline `UiButton` component (custom `background: Rectangle { radius:
  theme.radius }` and `contentItem: Text`) so primary, active/selected, and
  secondary buttons all share exact `theme.radius` corners and crisp borders.
- **Fit tiled windows on scaled displays.** On a 1920×1080 laptop scaled at
  `1.5` or `1.667` in Hyprland, a tiled window's logical height is only
  ~610–650px. Keep vertical padding and spacing compact so the main view fits
  within 640px height without clipping (even when a top status/error banner is
  visible), and check both `960×680` and `1152×648` in the offscreen harness.
  When a view or side panel can grow taller than the window, wrap it in a
  `Flickable` (`clip: true`, `contentWidth: width`,
  `contentHeight: contentLayout.implicitHeight + 36`) and position the child
  layout with `x` and `y`—never `anchors.top: parent.top` or
  `anchors.horizontalCenter: parent.horizontalCenter` inside a `Flickable` or
  `ScrollView`, which pins the layout and cuts off bottom controls. Keep
  inspector action buttons (`Save`, `Export`, `Delete`) in a fixed footer bar
  outside the `Flickable`.
- **Place things where the pointer is.** Anything the user inserts lands
  under the mouse when it's over the content (a `HoverHandler` tracks it),
  and in the middle of what's visible otherwise. Never at a fixed corner.
- **Keyboard first.** `?` shows every shortcut in an overlay, `Q` quits (and
  asks first when there's unsaved or unexported work), Space is the main
  action, Ctrl+Z / Ctrl+Shift+Z undo and redo. Disable single-key `Shortcut`s
  (`Space`, `Q`, `?`, `1`, `2`, etc.) whenever a `TextInput` or `TextEdit` has
  `activeFocus` (`enabled: !win.editingText`) so typing never fires global
  shortcuts, and give `UiButton` `focusPolicy: Qt.TabFocus` so clicking a
  button with the mouse doesn't steal `Space` from the window's main shortcut.
  The README lists the shortcuts in a table.
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

1. `bin/build`, then run `build/<name>` in the background to try it (it
   holds the shell until the window closes). Pass a file argument if the app
   opens files, so it's quick to test.
2. `bin/test` after each change to the backend. Tests compile `../src/*.cpp`
   straight in, run offscreen, and pass temp directories to anything that
   reads the disk (the `Theme` takes the theme directory as an argument).
3. Look at it, through the offscreen harness in step 4, and check the window
   against the theme before calling it done. Look once more in another
   language by passing the harness `da`, rather than switching the user's
   desktop with `omarchy language`: longer words must not clip. `bin/test`
   already fails when a `qsTr()` string is missing from a shipped catalog.
4. Drive the real QML offscreen when a change is about interaction.
   `templates.md` has a harness to build in the scratchpad. It compiles the
   app's `src/` and `resources.qrc`, loads `qrc:/Main.qml` offscreen with a
   language of its own and the default accent, sends key and mouse events,
   and saves `window->grabWindow()`. That shows what the user would see
   without touching their desktop. Keep its `QT_QUICK_BACKEND=rhi` and
   `QSG_RHI_BACKEND=opengl`: offscreen otherwise falls back to Qt Quick's
   software renderer, which leaves out Material's button backgrounds, so a
   correct window looks broken. Send a typed character such as `?` with
   `QTest::keyClick(window, '?')`; `keyClicks` takes only a `QWidget`.
5. Run `bin/install` yourself; don't hand it to the user. It builds and
   copies the binary to `~/.local/bin`, the icon to
   `~/.local/share/icons/hicolor/scalable/apps`, and the `.desktop` file to
   `~/.local/share/applications` with `Exec=` naming the installed binary in
   full. It needs no password, so it works from an agent's shell, and it
   fails rather than install an entry that is invalid, whose `Exec=` doesn't
   name the app, or that Omarchy hides. The Omarchy launcher (Quickshell
   `DesktopEntries`) watches those directories, so once it succeeds the app
   is listed: the user presses `Super + Space` and types its name (the
   menu's search covers Apps), unless `~/.config/hypr/bindings.lua` rebinds
   that key. Then start it the way the launcher does, in the background,
   `uwsm-app -- gtk-launch <name>.desktop`, and wait for its window with
   `timeout 8 sh -c 'until hyprctl clients -j | grep -q "\"class\": \"<name>\""; do sleep 0.2; done'`.
   That proves the entry, the installed binary, and the app id agree, and
   leaves the app open for the user. Exit status 124 means no window came
   up: run `~/.local/bin/<name>` directly to see why. Run `bin/install` again
   after every change the user should see there.
6. `bin/package` (`makepkg -fsi`) builds the system-wide Arch package. Its
   pacman step asks for sudo, so use it only when the user asks for a
   system-wide install or a release, and have them run it in a terminal.
   Afterwards it runs `bin/uninstall`, because a `~/.local` entry with the
   same name would shadow the package's and keep starting the old binary.

## Qt Quick traps

- Don't name a component file after a Qt Quick type: `ItemView.qml` fails
  with "abstract base class". Prefix it with what it shows (`PlacedItem.qml`).
- A `MouseArea` inside a `ListView` or `Flickable` loses its drag after a few
  pixels unless it sets `preventStealing: true`.
- `ListView` pins delegates to `x: 0`. To center content, make the delegate a
  full-width `Item` and center the content inside it.
- Every file that sets a `Material.*` attached property must import
  `QtQuick.Controls.Material`, or the file fails to load.
- Material's `TextArea` and `TextField` have asymmetric default padding when
  their `background` is replaced or `null` (`leftPadding: 16; rightPadding: 16`
  and `topPadding: 0` on `TextArea`, causing line 1 to collide with the top
  border while indenting deeply on the left), and Material's built-in
  `placeholderText` floats upward as a label and collides with any section
  heading above the field. Always set explicit symmetric padding (`leftPadding:
  12; rightPadding: 12; topPadding: 10; bottomPadding: 10` on `TextArea`;
  `leftPadding: 10; rightPadding: 10; topPadding: 0; bottomPadding: 0;
  verticalAlignment: TextInput.AlignVCenter` on `TextField`), and draw custom
  placeholder text as a child `Label` positioned at `x: parent.leftPadding;
  y: parent.topPadding` (for `TextArea`) or `x: parent.leftPadding;
  anchors.verticalCenter: parent.verticalCenter` (for `TextField`) so the
  placeholder and cursor align to the pixel.
- `TextArea` consumes `Tab` to insert `\t` unless you handle
  `Keys.onTabPressed` and `Keys.onBacktabPressed` with
  `nextItemInFocusChain(true/false).forceActiveFocus(Qt.TabFocusReason)`. Wrap
  `TextArea` in a container with `clip: true` and `Layout.preferredHeight:
  Math.max(minHeight, editor.implicitHeight)` so multi-line text never spills
  outside its border.
- Never put `anchors.top: parent.top` or `anchors.horizontalCenter:
  parent.horizontalCenter` on a layout inside a `ScrollView` or `Flickable`:
  anchoring to `Flickable`'s `contentItem` pins the layout or omits margins
  from `contentHeight`, so overflowing content is clipped and cannot scroll.
  In horizontal chip/tag `Flickable` strips, vertically center the inner `Row`
  (`anchors.verticalCenter: parent.verticalCenter`) and add a `WheelHandler`
  that scrolls `contentX`.
- `font.pixelSize` is an int. Standard keys go in `sequences:
  [StandardKey.Undo]`, not `sequence:`.
- Text that must look the same on screen and in an exported file is measured
  and painted by one C++ function, used by a `QQuickPaintedItem` on screen and
  by the exporter, rather than laid out twice.
- Material 3's default `Button` is a 48px-tall capsule pill (`FullScale`) with
  `topInset: 6; bottomInset: 6; leftPadding: 12; rightPadding: 12`, its
  `highlighted` state draws text in `Material.primaryHighlightedTextColor`
  (white in the dark theme, unreadable on light accents like `#FFD60A`), its
  un-highlighted dark background (`#1c1b1f`) disappears into dark panels, its
  `flat: true` state has no border until hovered, and its `focusPolicy:
  Qt.StrongFocus` steals `Space` after a mouse click. Use the template's
  `UiButton` component (`focusPolicy: Qt.TabFocus`, `flat: true`, `topInset: 0;
  bottomInset: 0`, custom `background: Rectangle { radius: theme.radius }` and
  `contentItem: Text`), and set `leftPadding: 0; rightPadding: 0` on narrow
  icon buttons (`"?"`, `"×"`) so Material's 12px padding doesn't clip the
  glyph.
- `everyStringIsTranslated()` in `tests/<name>_tests.cpp` must scan both
  `*.qml` (`qsTr("…")`) and `*.cpp` (`tr("…")` and `translate("…", "…")`) so
  C++ status messages, error strings, and offline libraries are never missing
  from `src/i18n/<code>.json`.
- moc ignores a raw string literal's own delimiter and ends it at the first
  `)"`, so `R"x(say ")" twice)x"` derails it. In a file moc reads (a
  `Q_OBJECT` header, or a test `.cpp` that includes its `.moc`), it then
  finds no class, prints only "note: No relevant classes found. No output
  generated.", and the build fails later with "undefined reference to
  `vtable for …`". Write such a string as an ordinary escaped literal.

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
