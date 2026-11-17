# Omarchy App Templates

Read this when starting an app from the omarchy-app skill. Replace `<name>` with the app's name and `<Name>` with its display name. These come from Omacut, Monologue, and the other Omarchy apps (MIT, David Heinemeier Hansson); keep that attribution in the LICENSE of any app that copies them.

The files marked **shared** are identical in every Omarchy app, byte for byte: copy them as they are, with nothing to replace, and put what is particular to the app in `CMakeLists.txt` and its recipe in omarchy-pkgs instead. A fix to one goes here first, then to every app.

## `CMakeLists.txt`

Add `Multimedia`, `Concurrent`, `Svg`, or other modules only when the app uses them, in both `find_package` and `target_link_libraries`. An app with several test binaries adds an `add_executable`, `add_test`, and `set_tests_properties` for each; the offscreen property is what lets a bare `ctest` (the package's `check()`, an IDE) run them without `bin/test`. The install rules are what `cmake --install` and the package both use.

```cmake
cmake_minimum_required(VERSION 3.21)
project(<name> LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Gui Network Qml Quick QuickControls2 DBus Test)

# Everything but main.cpp, shared by the app and the tests, so each source
# compiles once and a new file in src/ needs no line here.
file(GLOB <name>_sources CONFIGURE_DEPENDS src/*.cpp src/*.h)
list(REMOVE_ITEM <name>_sources ${CMAKE_SOURCE_DIR}/src/main.cpp)
add_library(<name>_core STATIC ${<name>_sources})
target_include_directories(<name>_core PUBLIC src)
target_link_libraries(<name>_core PUBLIC
  Qt6::Core Qt6::Gui Qt6::Network Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::DBus)
target_compile_options(<name>_core PUBLIC -Wall -Wextra)

add_executable(<name> src/main.cpp src/resources.qrc)
target_link_libraries(<name> PRIVATE <name>_core)

# The tests load the real Main.qml, so they carry the resources too.
enable_testing()
add_executable(<name>_tests tests/<name>_tests.cpp src/resources.qrc)
target_link_libraries(<name>_tests PRIVATE <name>_core Qt6::Test)
add_test(NAME <name>_tests COMMAND <name>_tests)
set_tests_properties(<name>_tests PROPERTIES ENVIRONMENT QT_QPA_PLATFORM=offscreen)

# `cmake --install build --prefix ~/.local` puts the app in the launcher
# before it is packaged; a package installs the same files under /usr.
include(GNUInstallDirs)
install(TARGETS <name> RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES share/<name>.desktop DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
install(FILES share/<name>.svg DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps)
install(FILES LICENSE DESTINATION ${CMAKE_INSTALL_DATADIR}/licenses/<name>)
```

## `bin/build`

Shared.

```bash
#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cmake -S "$root" -B "$root/build" -DCMAKE_BUILD_TYPE=Release >/dev/null
cmake --build "$root/build" -j"$(nproc)"
```

## `bin/test`

Shared.

```bash
#!/bin/bash
set -euo pipefail

# Arguments go to ctest, so `bin/test -V` shows every Qt test function as it runs.
root="$(cd "$(dirname "$0")/.." && pwd)"
"$root/bin/build"
QT_QPA_PLATFORM=offscreen ctest --test-dir "$root/build" --output-on-failure --no-tests=error "$@"
```

## `.github/workflows/test.yml`

Shared. It builds and tests on Arch, as an ordinary user with a desktop's locale, installing what the app's recipe in omarchy-pkgs lists, so it goes green once that recipe has landed.

```yaml
name: Test

on:
  pull_request:
  push:
    branches: [main, master]

permissions:
  contents: read

jobs:
  test:
    name: Build and test
    runs-on: ubuntu-latest
    # The app ships as an Arch package built against Arch's Qt, so it's tested there.
    container: archlinux:latest
    defaults:
      run:
        shell: bash
    steps:
      - name: Install git for the checkout
        run: pacman -Syu --noconfirm --needed git

      - uses: actions/checkout@v4

      - name: Install the package's dependencies
        # The package lives in omarchy-pkgs, so its PKGBUILD is the one list of what the app needs and CI reads it rather than keeping a copy.
        run: |
          curl -fsSL "https://raw.githubusercontent.com/omacom/omarchy-pkgs/master/pkgbuilds/${{ github.event.repository.name }}/PKGBUILD" -o "$RUNNER_TEMP/PKGBUILD"
          source "$RUNNER_TEMP/PKGBUILD"
          deps=("${depends[@]}" "${makedepends[@]}" "${checkdepends[@]}")
          pacman -S --noconfirm --needed base-devel cmake dbus "${deps[@]%%[<>=]*}"

      - name: Set up a user and a locale like a desktop's
        # Root can read any file, so tests about unreadable ones need an ordinary user, with a second group for tests that change a file's group; and the container generates no locale.
        run: |
          useradd -m tester
          groupadd other
          usermod -aG other tester
          chown -R tester .
          sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
          locale-gen

      - name: Build
        run: su tester -c bin/build

      - name: Test
        run: su tester -c 'LANG=en_US.UTF-8 dbus-run-session -- bin/test'
```

## `src/main.cpp`

```cpp
// <name> — one line on what it does.

#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QUrl>

#include "backend.h"
#include "theme.h"
#include "translator.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("<name>");
    app.setApplicationVersion("0.1.0");

    // Matches the window to <name>.desktop, so the compositor (Wayland app_id)
    // and the launcher pick up the installed icon. The compiled-in copy covers
    // a run from build/, and needs qt6-svg's icon engine.
    app.setDesktopFileName("<name>");
    app.setWindowIcon(QIcon::fromTheme("<name>", QIcon(":/<name>.svg")));

    QQuickStyle::setStyle("Material");

    // Installed before anything is translated, and every qsTr() binding is
    // re-evaluated when the Omarchy language changes.
    Translator translator;
    app.installTranslator(&translator);

    Theme theme;
    Backend backend;

    QQmlApplicationEngine engine;
    QObject::connect(&translator, &Translator::changed, &engine, &QQmlEngine::retranslate);
    engine.rootContext()->setContextProperty("translator", &translator);
    engine.rootContext()->setContextProperty("theme", &theme);
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.load(QUrl("qrc:/Main.qml"));
    if (engine.rootObjects().isEmpty())
        return 1;

    return app.exec();
}
```

## `src/theme.h` and `src/theme.cpp`

Follows the Omarchy theme live: the whole palette, light or dark, a readable color to put on the accent, and Hyprland's window rounding as `radius`, asked for on start and again only when Hyprland's event socket says its config reloaded, with no timer polling it. Tests construct it with a temp directory, a fake `hyprctl`, and their own event socket.

```cpp
#pragma once

#include <QColor>
#include <QFileSystemWatcher>
#include <QHash>
#include <QLocalSocket>
#include <QObject>
#include <QProcess>
#include <QTimer>
#include <QVariantMap>

// Follows the Omarchy theme live: its whole palette, whether it is light or
// dark, and Hyprland's window rounding as radius.
class Theme : public QObject {
    Q_OBJECT
    Q_PROPERTY(QColor accent READ accent NOTIFY changed)
    Q_PROPERTY(QColor accentForeground READ accentForeground NOTIFY changed)
    Q_PROPERTY(QColor background READ background NOTIFY changed)
    Q_PROPERTY(QColor foreground READ foreground NOTIFY changed)
    Q_PROPERTY(QVariantMap colors READ colors NOTIFY changed)
    Q_PROPERTY(bool light READ light NOTIFY changed)
    Q_PROPERTY(int radius READ radius NOTIFY changed)

public:
    // Tests pass a temp directory, a fake hyprctl, and their own event socket.
    explicit Theme(const QString &currentDirectory = {}, QObject *parent = nullptr, const QString &hyprctl = {},
                   const QString &hyprlandEvents = {});
    ~Theme() override;

    QColor accent() const { return color("accent"); }
    QColor accentForeground() const;
    QColor background() const { return color("background"); }
    QColor foreground() const { return color("foreground"); }
    QVariantMap colors() const;
    bool light() const { return m_light; }
    int radius() const { return m_radius; }

    struct Palette {
        QHash<QString, QColor> colors;
        bool light = false;
    };
    static Palette readThemeColors(const QString &path);

signals:
    void changed();

private:
    QColor color(const QString &key) const;
    void reload();
    void refreshRounding();

    QString m_directory;
    QHash<QString, QColor> m_colors;
    bool m_light = false;
    QFileSystemWatcher m_watcher;
    QTimer m_debounce;
    QString m_hyprctl;
    int m_radius = 0;
    bool m_roundingAgain = false;
    QProcess m_roundingProcess;
    QTimer m_roundingTimeout;
    QLocalSocket m_events;
    QTimer m_reconnect;
};
```

```cpp
// Theme watching follows Omacut (MIT, David Heinemeier Hansson).
#include "theme.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QStandardPaths>
#include <cmath>

namespace {

// Without Omarchy: a dark surface and Omarchy's fallback yellow.
const QHash<QString, QColor> &fallbackColors() {
    static const QHash<QString, QColor> colors{
        {"accent", QColor("#FFD60A")},  {"background", QColor("#0e0e10")}, {"foreground", QColor("#e6e6e9")},
        {"selection", QColor("#3a3a40")}, {"muted", QColor("#5c5c66")},    {"red", QColor("#f7768e")},
        {"green", QColor("#9ece6a")},   {"yellow", QColor("#e0af68")},     {"orange", QColor("#ff9e64")},
        {"blue", QColor("#7aa2f7")},    {"magenta", QColor("#bb9af7")},    {"cyan", QColor("#7dcfff")},
    };
    return colors;
}

// Older and hand-made themes name some colors differently. Each key takes the
// first of its other names the theme has, in the order omarchy-theme-color
// (Omarchy's full resolver) tries them.
const QList<QStringList> &aliases() {
    static const QList<QStringList> aliases{
        {"background", "bg", "color0"}, {"foreground", "fg", "color7"}, {"red", "color1"},
        {"green", "color2"}, {"yellow", "color3"}, {"blue", "color4"}, {"magenta", "color5", "purple"},
        {"cyan", "color6"}, {"muted", "color8", "dark_foreground"},
        {"selection", "selection_background", "color8", "background"}, {"orange", "yellow"},
    };
    return aliases;
}

double luminance(const QColor &c) {
    auto linear = [](double v) { return v <= .04045 ? v / 12.92 : std::pow((v + .055) / 1.055, 2.4); };
    return .2126 * linear(c.redF()) + .7152 * linear(c.greenF()) + .0722 * linear(c.blueF());
}

} // namespace

Theme::Theme(const QString &directory, QObject *parent, const QString &hyprctl, const QString &hyprlandEvents)
    : QObject(parent),
      m_directory(directory.isEmpty() ? QDir::homePath() + "/.local/state/omarchy/current" : directory) {
    m_debounce.setSingleShot(true);
    m_debounce.setInterval(80);
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged, this, [this] { m_debounce.start(); });
    connect(&m_watcher, &QFileSystemWatcher::fileChanged, this, [this] { m_debounce.start(); });
    connect(&m_debounce, &QTimer::timeout, this, &Theme::reload);

    // Corners follow Hyprland's effective rounding, which themes and personal
    // overrides can both set, so ask hyprctl rather than reading its config.
    // Without Hyprland the corners stay sharp, like Omarchy's default.
    const bool hyprland = directory.isEmpty() && !qEnvironmentVariableIsEmpty("HYPRLAND_INSTANCE_SIGNATURE");
    m_hyprctl = !hyprctl.isEmpty() ? hyprctl : hyprland ? QStandardPaths::findExecutable("hyprctl") : QString();
    m_roundingTimeout.setSingleShot(true);
    m_roundingTimeout.setInterval(500);
    connect(&m_roundingTimeout, &QTimer::timeout, &m_roundingProcess, &QProcess::kill);
    connect(&m_roundingProcess, &QProcess::errorOccurred, this, [this] { m_roundingTimeout.stop(); });
    connect(&m_roundingProcess, &QProcess::finished, this, [this](int code, QProcess::ExitStatus status) {
        m_roundingTimeout.stop();
        const auto value = QJsonDocument::fromJson(m_roundingProcess.readAllStandardOutput()).object().value("int");
        if (code == 0 && status == QProcess::NormalExit && value.isDouble() && value.toInt(-1) >= 0
            && value.toInt() != m_radius) {
            m_radius = value.toInt();
            emit changed();
        }
        if (m_roundingAgain) {
            m_roundingAgain = false;
            refreshRounding();
        }
    });

    // Hyprland announces a reload on its event socket once the new values are
    // in effect (a theme switch, the user's own config), so ask again then
    // rather than polling.
    const QString events = !hyprlandEvents.isEmpty() ? hyprlandEvents
                         : hyprland ? qEnvironmentVariable("XDG_RUNTIME_DIR") + "/hypr/"
                                          + qEnvironmentVariable("HYPRLAND_INSTANCE_SIGNATURE") + "/.socket2.sock"
                                    : QString();
    connect(&m_events, &QLocalSocket::readyRead, this, [this] {
        while (m_events.canReadLine())
            if (m_events.readLine().startsWith("configreloaded>>"))
                refreshRounding();
    });
    // Asked again on every connection, since a reload may have come between.
    connect(&m_events, &QLocalSocket::connected, this, [this] {
        m_reconnect.setInterval(1000);
        refreshRounding();
    });
    // A socket that can't be reached or drops is tried again, less often each time.
    m_reconnect.setSingleShot(true);
    m_reconnect.setInterval(1000);
    connect(&m_events, &QLocalSocket::disconnected, &m_reconnect, qOverload<>(&QTimer::start));
    connect(&m_events, &QLocalSocket::errorOccurred, &m_reconnect, qOverload<>(&QTimer::start));
    connect(&m_reconnect, &QTimer::timeout, this, [this, events] {
        m_reconnect.setInterval(std::min(m_reconnect.interval() * 2, 60000));
        m_events.abort();
        m_events.connectToServer(events, QIODevice::ReadOnly);
    });
    if (!events.isEmpty())
        m_events.connectToServer(events, QIODevice::ReadOnly);
    refreshRounding();
    reload();
}

Theme::~Theme() {
    // Nothing reconnects or asks again while the members go.
    m_events.disconnect();
    m_roundingProcess.disconnect();
    if (m_roundingProcess.state() != QProcess::NotRunning) {
        m_roundingProcess.kill();
        m_roundingProcess.waitForFinished(1000);
    }
}

void Theme::refreshRounding() {
    if (m_hyprctl.isEmpty())
        return;
    // A query still running may have read the value from before the reload.
    if (m_roundingProcess.state() != QProcess::NotRunning) {
        m_roundingAgain = true;
        return;
    }
    m_roundingProcess.start(m_hyprctl, {"-j", "getoption", "decoration:rounding"});
    m_roundingTimeout.start();
}

// Every `key = "#rrggbb"` in a colors.toml, quoted or bare, with or without a
// trailing comment, and whether the theme is light: its `mode`, a light.mode
// file beside it, or failing both a light background, as Omarchy decides it.
Theme::Palette Theme::readThemeColors(const QString &path) {
    Palette palette;
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return palette;
    static const QRegularExpression entry(R"re(^\s*([a-z0-9_]+)\s*=\s*(["']?)(#[0-9a-fA-F]{6}|light|dark)\2\s*(#.*)?$)re");
    QHash<QString, QString> modes;
    while (!file.atEnd()) {
        const auto match = entry.match(QString::fromUtf8(file.readLine()).trimmed());
        if (!match.hasMatch())
            continue;
        const QString key = match.captured(1), value = match.captured(3);
        if (value.startsWith('#'))
            palette.colors.insert(key, QColor(value));
        else
            modes.insert(key, value);
    }
    for (const QStringList &names : aliases())
        for (const QString &name : names.mid(1))
            if (!palette.colors.contains(names.first()) && palette.colors.contains(name))
                palette.colors.insert(names.first(), palette.colors.value(name));

    QString mode = modes.value("mode", modes.value("theme_type"));
    if (mode.isEmpty() && QFileInfo::exists(QFileInfo(path).absolutePath() + "/light.mode"))
        mode = "light";
    if (mode.isEmpty() && palette.colors.contains("background")) {
        const QColor background = palette.colors.value("background");
        mode = background.red() + background.green() + background.blue() > 382 ? "light" : "dark";
    }
    palette.light = mode == "light";
    return palette;
}

QColor Theme::color(const QString &key) const {
    if (const auto it = m_colors.constFind(key); it != m_colors.constEnd())
        return *it;
    return fallbackColors().value(key, fallbackColors().value("foreground"));
}

QVariantMap Theme::colors() const {
    QVariantMap colors;
    for (auto it = fallbackColors().begin(); it != fallbackColors().end(); ++it)
        colors.insert(it.key(), it.value());
    for (auto it = m_colors.begin(); it != m_colors.end(); ++it)
        colors.insert(it.key(), it.value());
    return colors;
}

// Black or white, whichever reads on the accent (WCAG relative luminance).
QColor Theme::accentForeground() const {
    return luminance(accent()) > .179 ? QColor("black") : QColor("white");
}

void Theme::reload() {
    const auto paths = m_watcher.files() + m_watcher.directories();
    if (!paths.isEmpty())
        m_watcher.removePaths(paths);

    // A theme switch replaces symlinks and files, so watch the parents too and
    // re-arm after every change. Watching the nearest existing ancestor means
    // installing Omarchy later works without restarting the app.
    QString ancestor = m_directory;
    while (!QFileInfo::exists(ancestor) && ancestor != "/")
        ancestor = QFileInfo(ancestor).absolutePath();
    QStringList candidates{ancestor, QFileInfo(ancestor).absolutePath(), m_directory,
                           m_directory + "/theme", m_directory + "/theme/colors.toml"};
    candidates.removeDuplicates();
    for (const auto &path : candidates)
        if (QFileInfo::exists(path))
            m_watcher.addPath(path);

    const Palette palette = readThemeColors(m_directory + "/theme/colors.toml");
    const bool light = palette.colors.isEmpty() ? false : palette.light;
    if (palette.colors != m_colors || light != m_light) {
        m_colors = palette.colors;
        m_light = light;
        emit changed();
    }
}
```

## `src/translator.h` and `src/translator.cpp`

Shared. Follows the language picked under Omarchy's Setup > Language, live. QML writes `qsTr("Save")` and C++ writes `tr("Save")`; the English text is the key, so an untranslated string simply shows in English. A counted string is `qsTr("%Ln clips", "", count)`, its forms picked by the plural rules of the catalog that supplied it, so an English fallback in Russian takes English's forms. It also sets the default locale and layout direction, so numbers, dates, and right-to-left mirroring follow the language. Apps translate on worker threads too, so a lock guards the catalog; it unregisters itself before it goes, since a worker can still be translating while the app shuts down; and it watches the nearest directory that exists, so a first pick that creates `~/.config/omarchy` is still seen. Tests construct it with a temp language file and catalog directory.

```cpp
#pragma once

#include <QFileSystemWatcher>
#include <QHash>
#include <QJsonValue>
#include <QLocale>
#include <QReadWriteLock>
#include <QTimer>
#include <QTranslator>

// Follows the language picked under Omarchy's Setup > Language. Catalogs are
// flat JSON objects from English source text to translation, one per Omarchy
// language code (i18n/da.json, i18n/pt-BR.json), so QML keeps plain
// qsTr("Save") and C++ keeps tr("Save"). A counted string,
// qsTr("%n clips", "", count), maps to an object of plural forms keyed by
// CLDR category ({"one": "%n klip", "other": "%n klip"}).
class Translator : public QTranslator {
    Q_OBJECT
    Q_PROPERTY(QString language READ language NOTIFY changed)

public:
    explicit Translator(const QString &languageFile = {}, const QString &catalogDirectory = ":/i18n",
                        QObject *parent = nullptr);
    ~Translator() override;

    QString language() const;
    bool isEmpty() const override;
    QString translate(const char *context, const char *sourceText, const char *disambiguation = nullptr,
                      int n = -1) const override;

    static QString readLanguage(const QString &path);
    static QString pluralCategory(const QString &language, long long count);
    static QLocale formatLocale(const QString &language);

signals:
    void changed();

private:
    void reload();

    QString m_languageFile;
    QString m_catalogDirectory;
    // A translation, and the language whose catalog it came from, so a
    // counted string falling back to English takes English plural rules.
    struct Entry {
        QJsonValue value;
        QString language;
    };

    // translate() also runs on worker threads (an app's background errors),
    // while a language switch replaces the catalog on the GUI thread.
    mutable QReadWriteLock m_lock;
    QString m_language;
    QHash<QString, Entry> m_strings;
    QFileSystemWatcher m_watcher;
    QTimer m_debounce;
};
```

```cpp
#include "translator.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocale>
#include <QRegularExpression>

Translator::Translator(const QString &languageFile, const QString &catalogDirectory, QObject *parent)
    : QTranslator(parent),
      m_languageFile(languageFile.isEmpty() ? QDir::homePath() + "/.config/omarchy/language" : languageFile),
      m_catalogDirectory(catalogDirectory) {
    m_debounce.setSingleShot(true);
    m_debounce.setInterval(80);
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged, this, [this] { m_debounce.start(); });
    connect(&m_watcher, &QFileSystemWatcher::fileChanged, this, [this] { m_debounce.start(); });
    connect(&m_debounce, &QTimer::timeout, this, &Translator::reload);
    reload();
}

QString Translator::language() const {
    QReadLocker locker(&m_lock);
    return m_language;
}

bool Translator::isEmpty() const {
    QReadLocker locker(&m_lock);
    return m_strings.isEmpty();
}

// Unregistered before the catalog and its lock go, since a worker thread can
// still be translating through QCoreApplication while the app shuts down;
// one outliving the application (a test's) has nothing to unregister from.
Translator::~Translator() {
    if (QCoreApplication::instance())
        QCoreApplication::removeTranslator(this);
}

// One registry code on the first line; anything else, or no file, is English.
QString Translator::readLanguage(const QString &path) {
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return "en";
    const QString code = QString::fromUtf8(file.readLine()).trimmed();
    static const QRegularExpression valid("^[a-z]{2,3}(-[A-Za-z]{2})?$");
    return valid.match(code).hasMatch() ? code : "en";
}

// CLDR cardinal plural categories for whole counts, for Omarchy's languages
// (the same rules as Omarchy's shell/Commons/Plural.js).
QString Translator::pluralCategory(const QString &language, long long count) {
    const long long n = count < 0 ? -count : count, n10 = n % 10, n100 = n % 100;
    const bool millions = n != 0 && n % 1000000 == 0;
    const bool teens = n100 >= 12 && n100 <= 14;
    const QString code = language;
    auto in = [&](std::initializer_list<const char *> codes) {
        for (const char *c : codes) if (code == QLatin1String(c)) return true;
        return false;
    };
    if (in({"ja", "ko", "zh-CN", "zh-TW", "th", "vi", "id", "ms"})) return "other";
    if (in({"hi", "bn", "fa", "si"})) return n <= 1 ? "one" : "other";
    if (in({"fr", "pt-BR"})) return n <= 1 ? "one" : millions ? "many" : "other";
    if (in({"ca", "es-MX", "it", "pt"})) return n == 1 ? "one" : millions ? "many" : "other";
    if (code == "fil") return (n10 == 4 || n10 == 6 || n10 == 9) ? "other" : "one";
    if (code == "is") return n10 == 1 && n100 != 11 ? "one" : "other";
    if (in({"cs", "sk"})) return n == 1 ? "one" : n >= 2 && n <= 4 ? "few" : "other";
    if (code == "pl") return n == 1 ? "one" : n10 >= 2 && n10 <= 4 && !teens ? "few" : "many";
    if (in({"ru", "uk"})) return n10 == 1 && n100 != 11 ? "one" : n10 >= 2 && n10 <= 4 && !teens ? "few" : "many";
    if (in({"hr", "sr"})) return n10 == 1 && n100 != 11 ? "one" : n10 >= 2 && n10 <= 4 && !teens ? "few" : "other";
    if (code == "sl") return n100 == 1 ? "one" : n100 == 2 ? "two" : n100 >= 3 && n100 <= 4 ? "few" : "other";
    if (code == "lt") return n100 >= 11 && n100 <= 19 ? "other" : n10 == 1 ? "one" : n10 >= 2 ? "few" : "other";
    if (code == "lv") return n10 == 0 || (n100 >= 11 && n100 <= 19) ? "zero" : n10 == 1 ? "one" : "other";
    if (code == "ro") return n == 1 ? "one" : n == 0 || (n100 >= 1 && n100 <= 19) ? "few" : "other";
    if (code == "ar") {
        if (n <= 2) return n == 0 ? "zero" : n == 1 ? "one" : "two";
        return n100 >= 3 && n100 <= 10 ? "few" : n100 >= 11 ? "many" : "other";
    }
    if (code == "he") return n == 1 ? "one" : n == 2 ? "two" : "other";
    if (code == "ga") return n == 1 ? "one" : n == 2 ? "two" : n >= 3 && n <= 6 ? "few" : n >= 7 && n <= 10 ? "many" : "other";
    return n == 1 ? "one" : "other";
}

// The locale Omarchy formats this language with, from its registry, so the
// app's numbers and dates match the desktop's (Arabic there uses Western
// digits); without Omarchy, Qt's own locale for the code.
QLocale Translator::formatLocale(const QString &language) {
    QFile registry(qEnvironmentVariable("OMARCHY_PATH") + "/default/i18n/locales.json");
    if (registry.open(QIODevice::ReadOnly)) {
        const QString name = QJsonDocument::fromJson(registry.readAll()).object()
                                 .value(language).toObject().value("formatLocale").toString();
        if (!name.isEmpty())
            return QLocale(name);
    }
    return QLocale(language);
}

QString Translator::translate(const char *, const char *sourceText, const char *, int n) const {
    // A null string tells Qt there is no translation, so it shows the English.
    QReadLocker locker(&m_lock);
    const Entry entry = m_strings.value(QString::fromUtf8(sourceText));
    const QJsonValue &value = entry.value;
    if (value.isString())
        return value.toString();
    if (value.isObject()) {
        const QJsonObject forms = value.toObject();
        const QString form = forms.value(n < 0 ? "other" : pluralCategory(entry.language, n)).toString();
        return form.isEmpty() ? forms.value("other").toString() : form;
    }
    return {};
}

void Translator::reload() {
    const auto paths = m_watcher.files() + m_watcher.directories();
    if (!paths.isEmpty())
        m_watcher.removePaths(paths);

    // omarchy-language replaces the file, which drops it from the watch, and a
    // first pick creates it, and maybe its directory; watch the nearest
    // existing directory too and re-arm every time.
    QString directory = QFileInfo(m_languageFile).absolutePath();
    while (!QFileInfo::exists(directory) && directory != "/")
        directory = QFileInfo(directory).absolutePath();
    m_watcher.addPath(directory);
    if (QFileInfo::exists(m_languageFile))
        m_watcher.addPath(m_languageFile);

    // Catalogs are compiled in, so only a different language needs a reload.
    const QString language = readLanguage(m_languageFile);
    if (language == this->language())
        return;

    // English first (it carries the plural forms of counted strings), then
    // the base language and the regional file over it (pt, then pt-BR), so a
    // missing string falls back toward English one step at a time.
    QHash<QString, Entry> strings;
    QStringList codes{"en", language.section('-', 0, 0), language};
    codes.removeDuplicates();
    for (const auto &code : codes) {
        QFile catalog(m_catalogDirectory + "/" + code + ".json");
        if (!catalog.open(QIODevice::ReadOnly))
            continue;
        const QJsonObject object = QJsonDocument::fromJson(catalog.readAll()).object();
        for (auto it = object.begin(); it != object.end(); ++it)
            if ((it.value().isString() && !it.value().toString().isEmpty()) || it.value().isObject())
                strings.insert(it.key(), {it.value(), code});
    }

    {
        QWriteLocker locker(&m_lock);
        m_language = language;
        m_strings = strings;
    }
    // Dates, numbers, and Qt's own day and month names follow the language
    // too, and right-to-left languages mirror the window.
    const QLocale locale = formatLocale(language);
    QLocale::setDefault(locale);
    QGuiApplication::setLayoutDirection(locale.textDirection());
    emit changed();
}
```

## `src/backend.h` and `src/backend.cpp`

The C++ side of the app's one job, exposed to QML as `backend`. Start with the single action the Space shortcut runs, then grow it.

```cpp
#pragma once

#include <QObject>

class Backend : public QObject {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit Backend(QObject *parent = nullptr) : QObject(parent) {}

    int count() const { return m_count; }
    Q_INVOKABLE void primaryAction();

signals:
    void countChanged();

private:
    int m_count = 0;
};
```

```cpp
#include "backend.h"

void Backend::primaryAction() {
    ++m_count;
    emit countChanged();
}
```

## `src/Main.qml`

For an app you type into, the shortcuts become F1 and Ctrl+? for the overlay, Ctrl+Q to quit, and Ctrl and a letter for actions, as the skill's *Keyboard first* says.

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

ApplicationWindow {
    id: win
    width: 960
    height: 680
    minimumWidth: 640
    minimumHeight: 460
    visible: true
    title: "<Name>"
    color: theme.background

    Material.theme: theme.light ? Material.Light : Material.Dark
    Material.accent: theme.accent
    Material.background: theme.background
    Material.foreground: theme.foreground

    readonly property bool rightToLeft: Qt.application.layoutDirection === Qt.RightToLeft

    Shortcut { sequence: "?"; onActivated: help.opened ? help.close() : help.open() }
    Shortcut { sequence: "Q"; onActivated: Qt.quit() }
    Shortcut { sequence: "Space"; onActivated: backend.primaryAction() }

    // Right-to-left languages mirror the window; the Translator sets the
    // application's layout direction.
    Item {
        anchors.fill: parent
        LayoutMirroring.enabled: win.rightToLeft
        LayoutMirroring.childrenInherit: true

        // The app's one job goes here.
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 24

            Label {
                objectName: "count"
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("%Ln presses", "", backend.count)
                font.pixelSize: 32
            }

            Button {
                id: countButton
                objectName: "countButton"
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Count")
                highlighted: true
                // Material.roundedScale isn't inherited, and takes a binding,
                // not a literal number.
                Material.roundedScale: theme.radius
                focusPolicy: Qt.NoFocus
                onClicked: backend.primaryAction()
                // A highlighted button colors its caption by Material's own
                // rule, not Material.foreground, so it can't read on every accent.
                contentItem: Label {
                    text: countButton.text
                    font: countButton.font
                    color: theme.accentForeground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    Popup {
        id: help
        objectName: "help"
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true
        padding: 24
        background: Rectangle {
            color: theme.background
            border.color: theme.colors.selection
            radius: theme.radius
        }

        ColumnLayout {
            spacing: 8
            // A popup is not an Item and doesn't inherit the window's
            // mirroring, so its content opts in.
            LayoutMirroring.enabled: win.rightToLeft
            LayoutMirroring.childrenInherit: true

            Repeater {
                model: [
                    { keys: "Space", action: qsTr("Count one more") },
                    { keys: "?", action: qsTr("Show or hide the shortcuts") },
                    { keys: "Q", action: qsTr("Quit") }
                ]
                delegate: RowLayout {
                    required property var modelData
                    spacing: 24

                    Label {
                        Layout.preferredWidth: 64
                        text: modelData.keys
                        color: theme.accent
                        font.bold: true
                    }
                    Label { text: modelData.action }
                }
            }
        }
    }
}
```

## `src/resources.qrc`

List one `<file>` line per catalog in `src/i18n/`.

```xml
<RCC>
    <qresource prefix="/">
        <file alias="Main.qml">Main.qml</file>
        <file alias="<name>.svg">../share/<name>.svg</file>
        <file alias="i18n/en.json">i18n/en.json</file>
        <file alias="i18n/da.json">i18n/da.json</file>
    </qresource>
</RCC>
```

## `src/i18n/en.json` and `src/i18n/<code>.json`

One flat JSON object per language, keyed by the English exactly as it appears in `qsTr()`, with Omarchy's language codes as file names (`$OMARCHY_PATH/default/i18n/locales.json` lists all 50: `da`, `de`, `pt-BR`, `zh-CN`, ...). `en.json` lists every string the app translates, each as itself, which is what translators and the tests work from. Keep `%1` placeholders, which `.arg()` fills, so a translation can reorder them. A counted string's value is an object of plural forms keyed by CLDR category: English gives `one` and `other`, and each language the categories it uses (Russian `one`, `few`, `many`, `other`; Arabic six; Japanese only `other`; `Translator::pluralCategory` lists them).

```json
{
  "%Ln presses": { "one": "%Ln press", "other": "%Ln presses" },
  "Count": "Count",
  "Count one more": "Count one more",
  "Quit": "Quit",
  "Show or hide the shortcuts": "Show or hide the shortcuts"
}
```

```json
{
  "%Ln presses": { "one": "%Ln tryk", "other": "%Ln tryk" },
  "Count": "Tæl",
  "Count one more": "Tæl en mere",
  "Quit": "Afslut",
  "Show or hide the shortcuts": "Vis eller skjul genvejene"
}
```

## `tests/<name>_tests.cpp`

One `private slots:` case per behavior. These cover the backend, the theme's palette and rounding, the translator's language file, fallbacks, and plurals, the catalogs against the sources, and the real window answering the keyboard, so a broken theme, catalog, or binding shows up in `bin/test`. The catalog tests read the sources beside the test file through `QFINDTESTDATA`.

```cpp
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocalServer>
#include <QLocalSocket>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickItem>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QRegularExpression>
#include <QTemporaryDir>
#include <QtTest>

#include "backend.h"
#include "theme.h"
#include "translator.h"

namespace {

bool write(const QString &path, const QByteArray &contents) {
    QFile file(path);
    return file.open(QIODevice::WriteOnly) && file.write(contents) == contents.size();
}

int lines(const QString &path) {
    QFile file(path);
    return file.open(QIODevice::ReadOnly) ? file.readAll().count('\n') : 0;
}

// A hyprctl that answers with response.json beside it and counts its calls.
QString fakeHyprctl(const QString &directory) {
    const QString command = directory + "/hyprctl";
    write(command, "#!/bin/bash\necho >> '" + directory.toUtf8() + "/calls'\ncat '" + directory.toUtf8()
                       + "/response.json'\n");
    QFile::setPermissions(command, QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner);
    return command;
}

QJsonObject readCatalog(const QString &path) {
    QFile file(path);
    return file.open(QIODevice::ReadOnly) ? QJsonDocument::fromJson(file.readAll()).object() : QJsonObject();
}

// The placeholders in a text, sorted: %1 to %99, and the count (%n, %Ln).
QStringList placeholders(const QString &text) {
    static const QRegularExpression placeholder("%L?(?:[1-9][0-9]?|n)");
    QStringList found;
    for (auto it = placeholder.globalMatch(text); it.hasNext();)
        found << it.next().captured();
    found.sort();
    return found;
}

// Every text the sources hand to qsTr() or tr(), and whether a call passes it
// a count. It walks the code a token at a time, so a string never hides a
// comment or the other way round, C++'s adjacent literals join, and QML's
// single quotes count. A text that isn't a literal can't be in a catalog.
QMap<QString, bool> translatables(const QString &folder, QStringList *problems) {
    QMap<QString, bool> found;
    for (const QFileInfo &info : QDir(folder).entryInfoList({"*.qml", "*.js", "*.cpp", "*.h"}, QDir::Files)) {
        QFile file(info.filePath());
        if (!file.open(QIODevice::ReadOnly))
            continue;
        const QString code = QString::fromUtf8(file.readAll());
        qsizetype i = 0;
        auto literal = [&](QString *text) {
            const QChar quote = code[i++];
            for (; i < code.size() && code[i] != quote; ++i) {
                if (code[i] == '\\' && i + 1 < code.size()) {
                    const QChar escaped = code[++i];
                    const int digits = escaped == 'u' ? 4 : escaped == 'x' ? 2 : 0;
                    bool hex = false;
                    const ushort unit = code.mid(i + 1, digits).toUShort(&hex, 16);
                    if (digits && hex) {
                        *text += QChar(unit);
                        i += digits;
                    } else {
                        *text += escaped == 'n' ? QChar('\n') : escaped == 't' ? QChar('\t') : escaped;
                    }
                } else {
                    *text += code[i];
                }
            }
            ++i;
        };
        auto skipSpace = [&] {
            while (i < code.size() && code[i].isSpace())
                ++i;
        };
        while (i < code.size()) {
            const QChar c = code[i];
            if (code.mid(i, 2) == "//") {
                i = code.indexOf('\n', i);
                if (i < 0)
                    break;
            } else if (code.mid(i, 2) == "/*") {
                i = code.indexOf("*/", i + 2);
                if (i < 0)
                    break;
                i += 2;
            } else if (c == '"' || c == '\'') {
                QString skipped;
                literal(&skipped);
            } else if (c.isLetter() || c == '_') {
                const qsizetype start = i;
                while (i < code.size() && (code[i].isLetterOrNumber() || code[i] == '_'))
                    ++i;
                const QString word = code.mid(start, i - start);
                skipSpace();
                if ((word != "qsTr" && word != "tr") || i >= code.size() || code[i] != '(')
                    continue;
                ++i;
                skipSpace();
                if (i >= code.size() || (code[i] != '"' && code[i] != '\'')) {
                    *problems << info.fileName() + ": not a literal: " + code.mid(start, 40);
                    continue;
                }
                QString text;
                do {
                    literal(&text);
                    skipSpace();
                } while (i < code.size() && code[i] == '"');
                // The arguments after the text, to the call's closing parenthesis.
                int depth = 0, commas = 0;
                while (i < code.size()) {
                    const QChar d = code[i];
                    if (d == '"' || d == '\'') {
                        QString skipped;
                        literal(&skipped);
                        continue;
                    }
                    if (d == '(' || d == '[' || d == '{')
                        ++depth;
                    else if ((d == ')' || d == ']' || d == '}') && depth-- == 0)
                        break;
                    else if (d == ',' && depth == 0)
                        ++commas;
                    ++i;
                }
                found[text] = found.value(text) || commas >= 2;
            } else {
                ++i;
            }
        }
    }
    return found;
}

} // namespace

class <Name>Tests : public QObject {
    Q_OBJECT

private slots:
    void initTestCase() { QQuickStyle::setStyle("Material"); }

    void primaryActionCounts() {
        Backend backend;
        backend.primaryAction();
        QCOMPARE(backend.count(), 1);
    }

    void themeFallsBack() {
        QTemporaryDir dir;
        Theme theme(dir.path());
        QCOMPARE(theme.accent(), QColor("#FFD60A"));
        QCOMPARE(theme.accentForeground(), QColor("black"));
        QVERIFY(!theme.light());
        QCOMPARE(theme.radius(), 0);
    }

    void themeReadsThePalette() {
        QTemporaryDir dir;
        QVERIFY(QDir(dir.path()).mkpath("theme"));
        QVERIFY(write(dir.path() + "/theme/colors.toml", "mode = \"light\"\n"
                                                         "theme_type = \"dark\"\n"
                                                         "accent = \"#112233\"\n"
                                                         "bg = #fafafa # paper\n"
                                                         "foreground = '#202020'\n"
                                                         "color1 = \"#aa0000\"\n"));

        Theme theme(dir.path());
        QCOMPARE(theme.accent(), QColor("#112233"));
        QCOMPARE(theme.accentForeground(), QColor("white"));
        QCOMPARE(theme.background(), QColor("#fafafa"));
        QCOMPARE(theme.foreground(), QColor("#202020"));
        QCOMPARE(theme.colors().value("red").value<QColor>(), QColor("#aa0000"));
        QVERIFY(theme.light());
    }

    void themeAsksHyprlandAgainOnlyWhenItReloads() {
        // The fake Hyprland lives outside the theme directory, whose changes
        // the Theme also follows.
        QTemporaryDir dir, hypr;
        const QString command = fakeHyprctl(hypr.path());
        QVERIFY(write(hypr.filePath("response.json"), "{\"int\":4}"));
        QLocalServer events;
        QVERIFY(events.listen(hypr.filePath("events.sock")));

        // Once on start, and once more when the event socket connects.
        Theme theme(dir.path(), nullptr, command, events.fullServerName());
        QTRY_VERIFY(events.hasPendingConnections());
        QLocalSocket *hyprland = events.nextPendingConnection();
        QTRY_COMPARE(lines(hypr.filePath("calls")), 2);
        QTRY_COMPARE(theme.radius(), 4);

        QVERIFY(write(hypr.filePath("response.json"), "{\"int\":10}"));
        QTest::qWait(300);
        QCOMPARE(lines(hypr.filePath("calls")), 2);
        // Events arrive in pieces; only a whole configreloaded line counts.
        hyprland->write("activewindow>>kitty,~\nconfigrel");
        hyprland->flush();
        QTest::qWait(100);
        QCOMPARE(lines(hypr.filePath("calls")), 2);
        hyprland->write("oaded>>\n");
        QTRY_COMPARE(theme.radius(), 10);
        QCOMPARE(lines(hypr.filePath("calls")), 3);
    }

    void themeReachesHyprlandOnceItListens() {
        QTemporaryDir dir, hypr;
        const QString command = fakeHyprctl(hypr.path());
        QVERIFY(write(hypr.filePath("response.json"), "{\"int\":4}"));
        Theme theme(dir.path(), nullptr, command, hypr.filePath("events.sock"));
        QTRY_COMPARE(theme.radius(), 4);

        QVERIFY(write(hypr.filePath("response.json"), "{\"int\":8}"));
        QLocalServer events;
        QVERIFY(events.listen(hypr.filePath("events.sock")));
        QTRY_VERIFY_WITH_TIMEOUT(events.hasPendingConnections(), 5000);
        QTRY_COMPARE(theme.radius(), 8);
    }

    void translatorFallsBackToEnglish() {
        QTemporaryDir dir;
        Translator translator(dir.path() + "/language", dir.path());
        QCOMPARE(translator.language(), QString("en"));
        QVERIFY(translator.translate("Main", "Save").isNull());
    }

    void translatorFollowsTheLanguageFile() {
        QTemporaryDir dir;
        QVERIFY(write(dir.path() + "/language", "pt-BR\n"));
        QVERIFY(write(dir.path() + "/pt.json", R"({"Save": "Guardar", "Open": "Abrir"})"));
        QVERIFY(write(dir.path() + "/pt-BR.json", R"({"Save": "Salvar"})"));

        Translator translator(dir.path() + "/language", dir.path());
        QCOMPARE(translator.language(), QString("pt-BR"));
        QCOMPARE(translator.translate("Main", "Save"), QString("Salvar"));
        QCOMPARE(translator.translate("Main", "Open"), QString("Abrir"));
        QVERIFY(translator.translate("Main", "Quit").isNull());
    }

    void translatorSeesAFirstPick() {
        // Before the first pick there is no ~/.config/omarchy to watch.
        QTemporaryDir dir;
        QVERIFY(write(dir.path() + "/da.json", R"({"Save": "Gem"})"));
        Translator translator(dir.path() + "/omarchy/language", dir.path());
        QVERIFY(QDir(dir.path()).mkpath("omarchy"));
        QVERIFY(write(dir.path() + "/omarchy/language", "da\n"));
        QTRY_COMPARE(translator.translate("Main", "Save"), QString("Gem"));
    }

    void translatorPicksPluralForms() {
        QTemporaryDir dir;
        QVERIFY(write(dir.path() + "/language", "ru\n"));
        QVERIFY(write(dir.path() + "/en.json", R"({"%n clips": {"one": "%n clip", "other": "%n clips"},
                                                   "%n files": {"one": "%n file", "other": "%n files"}})"));
        QVERIFY(write(dir.path() + "/ru.json", R"({"%n clips": {"one": "%n клип", "few": "%n клипа", "many": "%n клипов", "other": "%n клипа"}})"));

        Translator translator(dir.path() + "/language", dir.path());
        QCOMPARE(translator.translate("Main", "%n clips", nullptr, 21), QString("%n клип"));
        QCOMPARE(translator.translate("Main", "%n clips", nullptr, 22), QString("%n клипа"));
        QCOMPARE(translator.translate("Main", "%n clips", nullptr, 25), QString("%n клипов"));
        // An untranslated counted string falls back to English, with English rules.
        QCOMPARE(translator.translate("Main", "%n files", nullptr, 21), QString("%n files"));
    }

    void englishCatalogListsEveryString() {
        // en.json is what translators work from: every text the sources
        // translate is in it, as itself or, when counted, as its English
        // plural forms, and nothing else is.
        const QString sources = QFileInfo(QFINDTESTDATA("../src/Main.qml")).absolutePath();
        QStringList problems;
        const QMap<QString, bool> used = translatables(sources, &problems);
        const QJsonObject english = readCatalog(sources + "/i18n/en.json");
        for (auto it = used.begin(); it != used.end(); ++it) {
            const QJsonValue value = english.value(it.key());
            if (value.isUndefined())
                problems << "missing from en.json: " + it.key();
            else if (it.value() && (value.toObject().keys() != QStringList{"one", "other"}
                                    || value.toObject().value("other").toString() != it.key()))
                problems << "counted, so needs its one and other forms: " + it.key();
            else if (!it.value() && value.toString() != it.key())
                problems << "should be itself: " + it.key();
        }
        for (const QString &key : english.keys())
            if (!used.contains(key))
                problems << "in en.json but no source translates it: " + key;
        QVERIFY2(problems.isEmpty(), qPrintable(problems.join('\n')));
    }

    void catalogsMatchTheEnglishOne() {
        // A catalog may lack a string (it shows in English meanwhile), but what
        // it has translates something in en.json, with the same placeholders,
        // and a counted string has every form its language uses.
        const QString folder = QFileInfo(QFINDTESTDATA("../src/i18n/en.json")).absolutePath();
        const QJsonObject english = readCatalog(folder + "/en.json");
        QStringList problems;
        for (const QFileInfo &file : QDir(folder).entryInfoList({"*.json"}, QDir::Files)) {
            const QString code = file.completeBaseName();
            const QJsonObject catalog = readCatalog(file.filePath());
            if (catalog.isEmpty())
                problems << code + ": not a JSON object, or empty";
            // Some languages reach a form only at a million ("many" in French).
            QSet<QString> categories{"other", Translator::pluralCategory(code, 1000000)};
            for (long long n = 0; n <= 1000; ++n)
                categories << Translator::pluralCategory(code, n);
            for (auto it = catalog.begin(); it != catalog.end(); ++it) {
                const QString where = code + ": " + it.key() + ": ";
                const QJsonValue source = english.value(it.key());
                if (source.isUndefined()) {
                    problems << where + "not in en.json";
                } else if (source.isString()) {
                    if (!it.value().isString() || it.value().toString().isEmpty())
                        problems << where + "needs a translation";
                    else if (placeholders(it.value().toString()) != placeholders(it.key()))
                        problems << where + "has other placeholders than the English";
                } else {
                    const QJsonObject forms = it.value().toObject();
                    const QStringList wanted = placeholders(source.toObject().value("other").toString());
                    for (const QString &category : categories)
                        if (forms.value(category).toString().isEmpty())
                            problems << where + "needs its " + category + " form";
                    // A form other than "other" may say its number in words.
                    for (auto form = forms.begin(); form != forms.end(); ++form) {
                        const QStringList has = placeholders(form.value().toString());
                        QStringList needed = wanted;
                        if (form.key() != "other")
                            needed.removeIf([&](const QString &p) { return p.endsWith('n') && !has.contains(p); });
                        if (has != needed)
                            problems << where + form.key() + " has other placeholders than the English";
                    }
                }
            }
        }
        QVERIFY2(problems.isEmpty(), qPrintable(problems.join('\n')));
    }

    void windowLoadsAndAnswersTheKeyboard() {
        // A temp language and theme, so the test never depends on the desktop's.
        QTemporaryDir dir;
        Translator translator(dir.path() + "/language");
        QCoreApplication::installTranslator(&translator);
        Theme theme(dir.path());
        Backend backend;

        QQmlApplicationEngine engine;
        QStringList warnings;
        connect(&engine, &QQmlEngine::warnings, this, [&](const QList<QQmlError> &errors) {
            for (const auto &error : errors)
                warnings << error.toString();
        });
        engine.rootContext()->setContextProperty("translator", &translator);
        engine.rootContext()->setContextProperty("theme", &theme);
        engine.rootContext()->setContextProperty("backend", &backend);
        engine.load(QUrl("qrc:/Main.qml"));
        QVERIFY(!engine.rootObjects().isEmpty());
        auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
        QVERIFY(window);
        QVERIFY(QTest::qWaitForWindowExposed(window));
        window->requestActivate();
        QVERIFY(QTest::qWaitForWindowActive(window));

        auto *count = window->findChild<QObject *>("count");
        QTest::keyClick(window, Qt::Key_Space);
        QCOMPARE(count->property("text").toString(), QString("1 press"));
        QTest::keyClick(window, Qt::Key_Space);
        QCOMPARE(count->property("text").toString(), QString("2 presses"));
        QCOMPARE(backend.count(), 2);

        // The caption reads on the accent: black on the fallback yellow.
        auto *button = window->findChild<QQuickItem *>("countButton");
        QCOMPARE(button->property("contentItem").value<QQuickItem *>()->property("color").value<QColor>(),
                 theme.accentForeground());

        auto *help = window->findChild<QObject *>("help");
        QTest::keyClick(window, '?');
        QTRY_VERIFY(help->property("opened").toBool());
        // A Material popup animates out: `opened` drops at once, `visible` after.
        QTest::keyClick(window, Qt::Key_Escape);
        QTRY_VERIFY(!help->property("visible").toBool());

        QVERIFY2(warnings.isEmpty(), qPrintable(warnings.join('\n')));
        QCoreApplication::removeTranslator(&translator);
    }
};

QTEST_MAIN(<Name>Tests)
#include "<name>_tests.moc"
```

## `share/<name>.desktop`

```ini
[Desktop Entry]
Type=Application
Name=<Name>
Comment=One line on what it does
Exec=<name> %f
Icon=<name>
Terminal=false
Categories=Utility;
StartupWMClass=<name>
```

Add `Name[<code>]=` and `Comment[<code>]=` lines for each language the app ships, so the launcher shows the translated name (`Name[da]=…`, `Comment[pt_BR]=…`; desktop files spell regions with an underscore).

A click on a running app in Omarchy's dock brings its window forward. An app whose windows are each wanted fresh says so with `X-Omarchy-Dock-Click=new`, and the dock opens a new window on every click (Terminal, Agent). `X-Omarchy-Dock-Click=workspace` brings back a window only from the workspace in front of the user and opens a new one otherwise (Files). With either, a minimized window comes back first. Leave it out for the usual behavior.

## `share/<name>.svg`

The icon is a single square SVG. Start from a rounded square in the accent and draw the app's mark on it.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64">
  <rect width="64" height="64" rx="14" fill="#FFD60A"/>
</svg>
```

## `.gitignore`

```text
/build/
```

## `LICENSE`

The MIT license, with the user's name and the year, keeping the attribution above for the files that came from here. The install rules ship it, so it must exist.

## The recipe in omarchy-pkgs: `pkgbuilds/<name>/PKGBUILD`

This lives in `omacom/omarchy-pkgs`, not in the app, and is added once the app has a release (the skill's *README and release*). It builds from the release tarball, runs the tests, and installs through the same rules as `cmake --install`. Add `ffmpeg`, `qt6-multimedia`, or other packages to `depends` when the app uses them, and whatever only the tests need (fonts, codecs, tools) to `checkdepends`. Run `updpkgsums` to fill the checksum.

```bash
pkgname=<name>
pkgver=0.1.0
pkgrel=1
pkgdesc='One line on what it does'
arch=('x86_64' 'aarch64')
url='https://github.com/<owner>/<name>'
license=('MIT')
options=('!debug')
depends=('hicolor-icon-theme' 'qt6-base' 'qt6-declarative' 'qt6-svg' 'qt6-wayland' 'xdg-desktop-portal')
makedepends=('cmake' 'gcc' 'make')
checkdepends=()
source=("$pkgname-$pkgver.tar.gz::$url/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=()

build() {
  cd "$srcdir/$pkgname-$pkgver"
  ./bin/build
}

check() {
  cd "$srcdir/$pkgname-$pkgver"
  ctest --test-dir build --output-on-failure
}

package() {
  cd "$srcdir/$pkgname-$pkgver"
  DESTDIR="$pkgdir" cmake --install build --prefix /usr
}
```

And `pkgbuilds/<name>/.omarchy/package.json`, so each new release becomes a package update on its own:

```json
{
  "source": "local",
  "auto_merge": true,
  "upstream": {
    "watch": {
      "github": "<owner>/<name>",
      "pattern": "v(?P<version>[0-9]+(?:\\.[0-9]+)*)"
    }
  }
}
```
