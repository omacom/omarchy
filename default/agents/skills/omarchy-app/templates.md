# Omarchy App Templates

Read this when starting an app from the omarchy-app skill. Replace `<name>`
with the app's name and `<Name>` with its display name. These come from
Omacut and Monologue (MIT, David Heinemeier Hansson); keep that attribution in
the LICENSE of any app that copies them.

## `<name>.pro`

Add `multimedia`, `concurrent`, or other modules only when the app uses them.

```qmake
QT += core gui qml quick quickcontrols2 dbus

CONFIG += c++17 release
TARGET = <name>
TEMPLATE = app

HEADERS += \
    src/backend.h \
    src/theme.h

SOURCES += \
    src/main.cpp \
    src/backend.cpp \
    src/theme.cpp

RESOURCES += src/resources.qrc
```

## `bin/build`

```sh
#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
mkdir -p "$ROOT/build"
cd "$ROOT/build"

qmake6 "$ROOT/<name>.pro"
make -j"$(nproc)"

echo "Built $ROOT/build/<name>"
```

## `bin/test`

```sh
#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
mkdir -p "$ROOT/build/tests"
cd "$ROOT/build/tests"

qmake6 "$ROOT/tests/<name>_tests.pro"
make -j"$(nproc)"
QT_QPA_PLATFORM=offscreen ./<name>_tests
```

## `bin/install`

```sh
#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
"$ROOT/bin/build"
cd "$ROOT/pkgbuild"
exec makepkg -fsi "$@"
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

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("<name>");
    app.setApplicationVersion("0.1.0");

    // Matches the window to <name>.desktop, so the compositor (Wayland app_id)
    // and the launcher pick up the installed icon.
    app.setDesktopFileName("<name>");
    app.setWindowIcon(QIcon::fromTheme("<name>"));

    QQuickStyle::setStyle("Material");

    Theme theme;
    Backend backend;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("theme", &theme);
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.load(QUrl("qrc:/Main.qml"));
    if (engine.rootObjects().isEmpty())
        return 1;

    return app.exec();
}
```

## `src/theme.h` and `src/theme.cpp`

Follows the Omarchy accent live, and hands QML a readable color to put on it.
Tests construct it with a temp directory.

```cpp
#pragma once

#include <QFileSystemWatcher>
#include <QObject>
#include <QTimer>

class Theme : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString accent READ accent NOTIFY changed)
    Q_PROPERTY(QString accentForeground READ accentForeground NOTIFY changed)

public:
    explicit Theme(const QString &currentDirectory = {}, QObject *parent = nullptr);

    QString accent() const { return m_accent; }
    QString accentForeground() const;

    static QString readAccent(const QString &path);

signals:
    void changed();

private:
    void reload();

    QString m_directory;
    QString m_accent = "#FFD60A";
    QFileSystemWatcher m_watcher;
    QTimer m_debounce;
};
```

```cpp
// Theme watching follows Omacut (MIT, David Heinemeier Hansson).
#include "theme.h"

#include <QColor>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>
#include <cmath>

Theme::Theme(const QString &directory, QObject *parent)
    : QObject(parent),
      m_directory(directory.isEmpty() ? QDir::homePath() + "/.local/state/omarchy/current" : directory) {
    m_debounce.setSingleShot(true);
    m_debounce.setInterval(80);
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged, this, [this] { m_debounce.start(); });
    connect(&m_watcher, &QFileSystemWatcher::fileChanged, this, [this] { m_debounce.start(); });
    connect(&m_debounce, &QTimer::timeout, this, &Theme::reload);
    reload();
}

QString Theme::readAccent(const QString &path) {
    QFile file(path);
    if (file.open(QIODevice::ReadOnly)) {
        const QRegularExpression expression(R"re(^\s*accent\s*=\s*["'](#[0-9a-fA-F]{6})["'])re",
                                            QRegularExpression::MultilineOption);
        const auto match = expression.match(QString::fromUtf8(file.readAll()));
        if (match.hasMatch())
            return match.captured(1);
    }
    return "#FFD60A";
}

// Black or white, whichever reads on the accent (WCAG relative luminance).
QString Theme::accentForeground() const {
    const QColor c(m_accent);
    auto linear = [](double v) { return v <= .04045 ? v / 12.92 : std::pow((v + .055) / 1.055, 2.4); };
    const double luminance = .2126 * linear(c.redF()) + .7152 * linear(c.greenF()) + .0722 * linear(c.blueF());
    return luminance > .179 ? "black" : "white";
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

    const auto accent = readAccent(m_directory + "/theme/colors.toml");
    if (accent != m_accent) {
        m_accent = accent;
        emit changed();
    }
}
```

## `src/backend.h` and `src/backend.cpp`

The C++ side of the app's one job, exposed to QML as `backend`. Start with
the single action the Space shortcut runs, then grow it.

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

void Backend::primaryAction()
{
    ++m_count;
    emit countChanged();
}
```

## `src/Main.qml`

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
    title: "<name>"
    color: "#0e0e10"

    Material.theme: Material.Dark
    Material.accent: theme.accent

    property bool helpVisible: false

    Shortcut { sequence: "?"; context: Qt.ApplicationShortcut; onActivated: win.helpVisible = !win.helpVisible }
    Shortcut { sequence: "Q"; context: Qt.ApplicationShortcut; onActivated: Qt.quit() }
    Shortcut { sequence: "Space"; context: Qt.ApplicationShortcut; onActivated: backend.primaryAction() }

    // The app's one job goes here.
}
```

## `src/resources.qrc`

```xml
<RCC>
    <qresource prefix="/">
        <file alias="Main.qml">Main.qml</file>
    </qresource>
</RCC>
```

## `tests/<name>_tests.pro`

```qmake
QT += core gui quick quickcontrols2 testlib dbus
CONFIG += c++17 testcase
TARGET = <name>_tests
TEMPLATE = app

INCLUDEPATH += ../src

HEADERS += ../src/backend.h ../src/theme.h
SOURCES += <name>_tests.cpp ../src/backend.cpp ../src/theme.cpp
```

## `tests/<name>_tests.cpp`

One `private slots:` case per behavior. These cover the backend and the
theme fallback and accent read, so a broken theme shows up in `bin/test`.

```cpp
#include <QDir>
#include <QFile>
#include <QTemporaryDir>
#include <QtTest>

#include "backend.h"
#include "theme.h"

class <Name>Tests : public QObject {
    Q_OBJECT

private slots:
    void primaryActionCounts()
    {
        Backend backend;
        backend.primaryAction();
        QCOMPARE(backend.count(), 1);
    }

    void themeFallsBack()
    {
        QTemporaryDir dir;
        Theme theme(dir.path());
        QCOMPARE(theme.accent(), QString("#FFD60A"));
        QCOMPARE(theme.accentForeground(), QString("black"));
    }

    void themeReadsAccent()
    {
        QTemporaryDir dir;
        QDir(dir.path()).mkpath("theme");
        QFile colors(dir.path() + "/theme/colors.toml");
        QVERIFY(colors.open(QIODevice::WriteOnly));
        colors.write("accent = \"#112233\"\n");
        colors.close();

        Theme theme(dir.path());
        QCOMPARE(theme.accent(), QString("#112233"));
        QCOMPARE(theme.accentForeground(), QString("white"));
    }
};

QTEST_MAIN(<Name>Tests)
#include "<name>_tests.moc"
```

## `pkgbuild/PKGBUILD`

```sh
pkgname=<name>
pkgver=0.1.0
pkgrel=1
pkgdesc='One line on what it does'
arch=('x86_64' 'aarch64')
license=('MIT')
depends=('qt6-base' 'qt6-declarative' 'qt6-wayland' 'xdg-desktop-portal')
makedepends=('gcc' 'make')
source=()
sha256sums=()

build() {
  cd "$startdir/.."
  ./bin/build
}

package() {
  cd "$startdir/.."
  install -Dm755 build/<name> "$pkgdir/usr/bin/<name>"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  install -Dm644 "$startdir/<name>.svg" "$pkgdir/usr/share/icons/hicolor/scalable/apps/<name>.svg"
  install -Dm644 "$startdir/<name>.desktop" "$pkgdir/usr/share/applications/<name>.desktop"
}
```

Add `ffmpeg`, `qt6-multimedia`, or `qt6-svg` to `depends` when the app uses
them. Omarchy installs all three, but the package should still say what it
needs. `package()` also installs `LICENSE` from the project root (the MIT text
with the user's name and year) and the icon below, so both must exist.

## `pkgbuild/<name>.desktop`

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

## `pkgbuild/<name>.svg`

The icon is a single square SVG. Start from a rounded square in the accent
and draw the app's mark on it.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64">
  <rect width="64" height="64" rx="14" fill="#FFD60A"/>
</svg>
```

## `.gitignore`

```text
/build/
/pkgbuild/pkg/
/pkgbuild/src/
*.pkg.tar.*
```
