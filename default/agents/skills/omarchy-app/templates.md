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
    src/theme.h \
    src/translator.h

SOURCES += \
    src/main.cpp \
    src/backend.cpp \
    src/theme.cpp \
    src/translator.cpp

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

The everyday install. It needs no sudo, so the agent runs it itself and the
app is in the launcher straight away.

```sh
#!/bin/sh
# Builds the app and installs it for this user under ~/.local, with no sudo.
# The Omarchy launcher watches ~/.local/share/applications, so the app is
# listed as soon as this finishes.
set -eu

NAME=<name>
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
BIN="$HOME/.local/bin"
ENTRY="$ROOT/build/$NAME.desktop"

# Omarchy hides these desktop ids from its launcher, so an app with one of
# their names would install fine and never show up.
if grep -qx "$NAME" "${OMARCHY_PATH:-/usr/share/omarchy}/default/omarchy/launcher.hides" 2>/dev/null; then
  echo "Omarchy hides '$NAME' from its launcher; rename the app" >&2
  exit 1
fi

"$ROOT/bin/build"

# The launcher may not have ~/.local/bin on its PATH, so Exec names the
# installed binary in full. Check the entry before installing it, so a broken
# one never reaches the launcher.
sed -E "s#^Exec=$NAME( |\$)#Exec=$BIN/$NAME\1#" "$ROOT/pkgbuild/$NAME.desktop" > "$ENTRY"
if ! grep -Eq "^Exec=$BIN/$NAME( |\$)" "$ENTRY"; then
  echo "pkgbuild/$NAME.desktop needs a line Exec=$NAME" >&2
  exit 1
fi
if command -v desktop-file-validate >/dev/null; then
  desktop-file-validate "$ENTRY"
fi

install -Dm755 "$ROOT/build/$NAME" "$BIN/$NAME"
install -Dm644 "$ROOT/pkgbuild/$NAME.svg" "$DATA/icons/hicolor/scalable/apps/$NAME.svg"
install -Dm644 "$ENTRY" "$DATA/applications/$NAME.desktop"
if command -v update-desktop-database >/dev/null; then
  update-desktop-database -q "$DATA/applications"
fi

echo "Installed $NAME: $BIN/$NAME and $DATA/applications/$NAME.desktop"
```

## `bin/uninstall`

```sh
#!/bin/sh
# Removes what bin/install put under ~/.local.
set -eu

NAME=<name>
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
rm -f "$HOME/.local/bin/$NAME" "$DATA/applications/$NAME.desktop" \
      "$DATA/icons/hicolor/scalable/apps/$NAME.svg"
if command -v update-desktop-database >/dev/null; then
  update-desktop-database -q "$DATA/applications"
fi
echo "Uninstalled $NAME from ~/.local"
```

## `bin/package`

The system-wide Arch package. `pacman` asks for sudo, which an agent's shell
can't answer, so use it only when the user asks for it or for a release, and
have the user run it in a terminal.

```sh
#!/bin/sh
# Builds the Arch package and installs it system-wide with pacman, which asks
# for sudo. bin/install is the everyday path and needs no password.
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT/pkgbuild"
makepkg -fsi "$@"

# A ~/.local install has the same desktop id, so it would shadow the package's
# launcher entry and keep starting the old binary.
"$ROOT/bin/uninstall"
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
    // and the launcher pick up the installed icon.
    app.setDesktopFileName("<name>");
    app.setWindowIcon(QIcon::fromTheme("<name>"));

    QQuickStyle::setStyle("Material");

    // Installed before anything is translated, and every qsTr() binding is
    // re-evaluated when the Omarchy language changes.
    Translator translator;
    app.installTranslator(&translator);

    Theme theme;
    Backend backend;

    QQmlApplicationEngine engine;
    QObject::connect(&translator, &Translator::changed, &engine, &QQmlEngine::retranslate);
    QObject::connect(&translator, &Translator::changed, &backend, &Backend::retranslate);
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

Follows the Omarchy accent live, hands QML a readable color to put on it, and
tracks Hyprland's window rounding as `radius`. Tests construct it with a temp
directory and a fake `hyprctl`.

```cpp
#pragma once

#include <QFileSystemWatcher>
#include <QObject>
#include <QProcess>
#include <QTimer>

class Theme : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString accent READ accent NOTIFY changed)
    Q_PROPERTY(QString accentForeground READ accentForeground NOTIFY changed)
    Q_PROPERTY(int radius READ radius NOTIFY changed)

public:
    explicit Theme(const QString &currentDirectory = {}, QObject *parent = nullptr, const QString &hyprctl = {});
    ~Theme() override;

    QString accent() const { return m_accent; }
    QString accentForeground() const;
    int radius() const { return m_radius; }

    static QString readAccent(const QString &path);

signals:
    void changed();

private:
    void reload();
    void refreshRounding();

    QString m_directory;
    QString m_accent = "#FFD60A";
    QFileSystemWatcher m_watcher;
    QTimer m_debounce;
    QString m_hyprctl;
    int m_radius = 0;
    QProcess m_roundingProcess;
    QTimer m_roundingPoll, m_roundingTimeout;
};
```

```cpp
// Theme watching follows Omacut (MIT, David Heinemeier Hansson).
#include "theme.h"

#include <QColor>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QStandardPaths>
#include <cmath>

Theme::Theme(const QString &directory, QObject *parent, const QString &hyprctl)
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
    m_hyprctl = !hyprctl.isEmpty() ? hyprctl
              : directory.isEmpty() && !qEnvironmentVariableIsEmpty("HYPRLAND_INSTANCE_SIGNATURE")
                  ? QStandardPaths::findExecutable("hyprctl") : QString();
    m_roundingTimeout.setSingleShot(true);
    m_roundingTimeout.setInterval(500);
    connect(&m_roundingTimeout, &QTimer::timeout, &m_roundingProcess, &QProcess::kill);
    connect(&m_roundingProcess, &QProcess::errorOccurred, this, [this] { m_roundingTimeout.stop(); });
    connect(&m_roundingProcess, &QProcess::finished, this, [this](int code, QProcess::ExitStatus status) {
        m_roundingTimeout.stop();
        const auto value = QJsonDocument::fromJson(m_roundingProcess.readAllStandardOutput()).object().value("int");
        if (code != 0 || status != QProcess::NormalExit || !value.isDouble() || value.toInt(-1) < 0)
            return;
        if (value.toInt() != m_radius) {
            m_radius = value.toInt();
            emit changed();
        }
    });
    m_roundingPoll.setInterval(1000);
    connect(&m_roundingPoll, &QTimer::timeout, this, &Theme::refreshRounding);
    if (!m_hyprctl.isEmpty())
        m_roundingPoll.start();
    reload();
}

Theme::~Theme() {
    if (m_roundingProcess.state() != QProcess::NotRunning) {
        m_roundingProcess.kill();
        m_roundingProcess.waitForFinished(1000);
    }
}

void Theme::refreshRounding() {
    if (m_hyprctl.isEmpty() || m_roundingProcess.state() != QProcess::NotRunning)
        return;
    m_roundingProcess.start(m_hyprctl, {"-j", "getoption", "decoration:rounding"});
    m_roundingTimeout.start();
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
    refreshRounding();
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

## `src/translator.h` and `src/translator.cpp`

Follows the language picked under Omarchy's Setup > Language, live. QML
writes `qsTr("Save")` and C++ writes `tr("Save")`; the English text is the
key, so an untranslated string simply shows in English. A counted string is
`qsTr("%n clips", "", count)`, its forms picked by the language's plural
rules. It also sets the default locale and layout direction, so numbers,
dates, and right-to-left mirroring follow the language. Tests construct it
with a temp language file and catalog directory.

```cpp
#pragma once

#include <QFileSystemWatcher>
#include <QHash>
#include <QJsonValue>
#include <QLocale>
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

    QString language() const { return m_language; }
    bool isEmpty() const override { return m_strings.isEmpty(); }
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
    QString m_language;
    QHash<QString, QJsonValue> m_strings;
    QFileSystemWatcher m_watcher;
    QTimer m_debounce;
};
```

```cpp
#include "translator.h"

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
    const QJsonValue value = m_strings.value(QString::fromUtf8(sourceText));
    if (value.isString())
        return value.toString();
    if (value.isObject()) {
        const QJsonObject forms = value.toObject();
        const QString form = forms.value(n < 0 ? "other" : pluralCategory(m_language, n)).toString();
        return form.isEmpty() ? forms.value("other").toString() : form;
    }
    return {};
}

void Translator::reload() {
    const auto paths = m_watcher.files() + m_watcher.directories();
    if (!paths.isEmpty())
        m_watcher.removePaths(paths);

    // omarchy-language replaces the file, which drops it from the watch, and a
    // first pick creates it; watch its directory too and re-arm every time.
    const QString directory = QFileInfo(m_languageFile).absolutePath();
    if (QFileInfo::exists(directory))
        m_watcher.addPath(directory);
    if (QFileInfo::exists(m_languageFile))
        m_watcher.addPath(m_languageFile);

    // Catalogs are compiled in, so only a different language needs a reload.
    const QString language = readLanguage(m_languageFile);
    if (language == m_language)
        return;

    // English first (it carries the plural forms of counted strings), then
    // the base language and the regional file over it (pt, then pt-BR), so a
    // missing string falls back toward English one step at a time.
    QHash<QString, QJsonValue> strings;
    QStringList codes{"en", language.section('-', 0, 0), language};
    codes.removeDuplicates();
    for (const auto &code : codes) {
        QFile catalog(m_catalogDirectory + "/" + code + ".json");
        if (!catalog.open(QIODevice::ReadOnly))
            continue;
        const QJsonObject object = QJsonDocument::fromJson(catalog.readAll()).object();
        for (auto it = object.begin(); it != object.end(); ++it)
            if ((it.value().isString() && !it.value().toString().isEmpty()) || it.value().isObject())
                strings.insert(it.key(), it.value());
    }

    m_language = language;
    m_strings = strings;
    // Dates, numbers, and Qt's own day and month names follow the language
    // too, and right-to-left languages mirror the window.
    const QLocale locale = formatLocale(language);
    QLocale::setDefault(locale);
    QGuiApplication::setLayoutDirection(locale.textDirection());
    emit changed();
}
```

## `src/backend.h` and `src/backend.cpp`

The C++ side of the app's one job, exposed to QML as `backend`. Start with
the single action the Space shortcut runs, then grow it. Keep any translated
status or error string in a `std::function<QString()>` builder so
`Backend::retranslate()` updates visible banners live when the language
switches.

```cpp
#pragma once

#include <QObject>
#include <QString>
#include <functional>

class Backend : public QObject {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusChanged)

public:
    explicit Backend(QObject *parent = nullptr) : QObject(parent) {}

    int count() const { return m_count; }
    QString statusMessage() const { return m_statusMessage; }

    Q_INVOKABLE void primaryAction();
    Q_INVOKABLE void clearStatus();
    void retranslate();

signals:
    void countChanged();
    void statusChanged();

private:
    void setStatusBuilder(std::function<QString()> builder);

    int m_count = 0;
    QString m_statusMessage;
    std::function<QString()> m_statusBuilder;
};
```

```cpp
#include "backend.h"

void Backend::primaryAction()
{
    ++m_count;
    emit countChanged();
}

void Backend::clearStatus()
{
    setStatusBuilder({});
}

void Backend::retranslate()
{
    if (!m_statusBuilder)
        return;
    const QString updated = m_statusBuilder();
    if (updated != m_statusMessage) {
        m_statusMessage = updated;
        emit statusChanged();
    }
}

// Pass a lambda calling tr(…) so retranslate() updates visible banners live
// when the Omarchy language switches.
void Backend::setStatusBuilder(std::function<QString()> builder)
{
    m_statusBuilder = std::move(builder);
    const QString next = m_statusBuilder ? m_statusBuilder() : QString();
    if (next != m_statusMessage) {
        m_statusMessage = next;
        emit statusChanged();
    }
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
    title: "<Name>"
    color: "#0e0e10"

    Material.theme: Material.Dark
    Material.accent: theme.accent

    property bool helpVisible: false
    readonly property bool editingText: activeFocusItem instanceof TextInput || activeFocusItem instanceof TextEdit

    // Single-key shortcuts are disabled while typing in a TextField or TextArea.
    Shortcut { sequence: "?"; context: Qt.ApplicationShortcut; enabled: !win.editingText; onActivated: win.helpVisible = !win.helpVisible }
    Shortcut { sequence: "Q"; context: Qt.ApplicationShortcut; enabled: !win.editingText; onActivated: Qt.quit() }
    Shortcut { sequence: "Space"; context: Qt.ApplicationShortcut; enabled: !win.editingText; onActivated: backend.primaryAction() }

    // Consistent button matching Hyprland's window rounding (theme.radius) and
    // readable on light accents like #FFD60A. TabFocus keeps mouse clicks from
    // stealing the global Space shortcut.
    component UiButton : Button {
        id: btn
        property bool primary: false
        property bool active: false
        focusPolicy: Qt.TabFocus
        flat: true
        topInset: 0
        bottomInset: 0
        leftPadding: 14
        rightPadding: 14
        implicitHeight: 34
        background: Rectangle {
            radius: theme.radius
            color: btn.primary
                   ? (btn.down ? Qt.darker(theme.accent, 1.15) : (btn.hovered ? Qt.lighter(theme.accent, 1.08) : theme.accent))
                   : btn.active
                     ? Qt.rgba(Qt.color(theme.accent).r, Qt.color(theme.accent).g, Qt.color(theme.accent).b, btn.hovered ? 0.24 : 0.16)
                     : (btn.down ? "#232a35" : (btn.hovered ? "#1b212a" : "#141820"))
            border.width: btn.primary ? 0 : 1
            border.color: btn.active ? theme.accent : (btn.hovered ? "#38414f" : "#252b35")
        }
        contentItem: Text {
            text: btn.text
            font.pixelSize: 12
            font.weight: (btn.primary || btn.active) ? Font.DemiBold : Font.Medium
            color: btn.primary ? theme.accentForeground : (btn.enabled ? "#e5e7eb" : "#6b7280")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    // For TextArea / TextField with a custom background:
    // - Set explicit padding (TextArea: leftPadding: 12; rightPadding: 12; topPadding: 10; bottomPadding: 10;
    //   TextField: leftPadding: 10; rightPadding: 10; topPadding: 0; bottomPadding: 0; verticalAlignment: TextInput.AlignVCenter)
    // - Draw placeholders as a child Label at x: parent.leftPadding; y: parent.topPadding (not Material's floating placeholderText)
    // - On TextArea, forward Tab/Backtab with nextItemInFocusChain(true/false).forceActiveFocus(Qt.TabFocusReason)
    // For scrollable views:
    // - Use Flickable { clip: true; contentWidth: width; contentHeight: layout.implicitHeight + 36 }
    //   and position layout with x/y (never anchors.top or anchors.horizontalCenter inside Flickable/ScrollView).

    // Right-to-left languages mirror the window; the Translator sets the
    // application's layout direction.
    Item {
        anchors.fill: parent
        LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
        LayoutMirroring.childrenInherit: true

        // The app's one job goes here.
    }
}
```

## `src/resources.qrc`

```xml
<RCC>
    <qresource prefix="/">
        <file alias="Main.qml">Main.qml</file>
        <file alias="i18n/en.json">i18n/en.json</file>
        <file alias="i18n/da.json">i18n/da.json</file>
    </qresource>
</RCC>
```

List one `<file>` line per catalog in `src/i18n/`. English needs a file only
for the plural forms of counted strings.

## `src/i18n/<code>.json`

One flat JSON object per language, keyed by the English exactly as it appears
in `qsTr()`, with Omarchy's language codes as file names
(`$OMARCHY_PATH/default/i18n/locales.json` lists all 50: `da`, `de`, `pt-BR`,
`zh-CN`, ...). Keep `%1` placeholders, which `.arg()` fills, so a translation
can reorder them. A counted string's value is an object of plural forms keyed
by CLDR category: English gives `one` and `other` in `en.json`, and each
language the categories it uses (Russian `one`, `few`, `many`, `other`;
Arabic six; Japanese only `other`; `Translator::pluralCategory` lists them).

```json
{
  "Save": "Gem",
  "%n clips": { "one": "%n klip", "other": "%n klip" }
}
```

## `tests/<name>_tests.pro`

```qmake
QT += core gui quick quickcontrols2 testlib dbus
CONFIG += c++17 testcase
TARGET = <name>_tests
TEMPLATE = app

INCLUDEPATH += ../src
# Lets the tests find src/ to check the QML's strings against the catalogs.
DEFINES += SRCDIR=\\\"$$PWD\\\"

HEADERS += ../src/backend.h ../src/theme.h ../src/translator.h
SOURCES += <name>_tests.cpp ../src/backend.cpp ../src/theme.cpp ../src/translator.cpp
```

## `tests/<name>_tests.cpp`

One `private slots:` case per behavior. These cover the backend, the theme
fallback, accent and rounding, the translator's language file and fallbacks,
and the catalogs themselves: each one must parse and hold every `qsTr()`
string in the QML. So a broken theme, a broken catalog, or a string left in
English shows up in `bin/test`.

```cpp
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QTemporaryDir>
#include <QtTest>

#include "backend.h"
#include "theme.h"
#include "translator.h"

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

    void themeFollowsHyprlandRounding()
    {
        QTemporaryDir dir;
        const QString response = dir.filePath("response.json"), command = dir.filePath("hyprctl");
        auto write = [](const QString &path, const QByteArray &data) {
            QFile file(path);
            return file.open(QIODevice::WriteOnly) && file.write(data) == data.size();
        };
        QVERIFY(write(command, "#!/bin/sh\ncat '" + response.toUtf8() + "'\n"));
        QVERIFY(QFile::setPermissions(command, QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner));
        QVERIFY(write(response, "{\"int\":0}"));

        Theme theme(dir.path(), nullptr, command);
        QCOMPARE(theme.radius(), 0);
        QVERIFY(write(response, "{\"int\":6}"));
        QTRY_COMPARE(theme.radius(), 6);
    }

    void translatorFallsBackToEnglish()
    {
        QTemporaryDir dir;
        Translator translator(dir.path() + "/language", dir.path());
        QCOMPARE(translator.language(), QString("en"));
        QVERIFY(translator.translate("Main", "Save").isNull());
    }

    void translatorFollowsTheLanguageFile()
    {
        QTemporaryDir dir;
        write(dir.path() + "/language", "pt-BR\n");
        write(dir.path() + "/pt.json", R"({"Save": "Guardar", "Open": "Abrir"})");
        write(dir.path() + "/pt-BR.json", R"({"Save": "Salvar"})");

        Translator translator(dir.path() + "/language", dir.path());
        QCOMPARE(translator.language(), QString("pt-BR"));
        QCOMPARE(translator.translate("Main", "Save"), QString("Salvar"));
        QCOMPARE(translator.translate("Main", "Open"), QString("Abrir"));
        QVERIFY(translator.translate("Main", "Quit").isNull());
    }

    void translatorPicksPluralForms()
    {
        QTemporaryDir dir;
        write(dir.path() + "/language", "ru\n");
        write(dir.path() + "/en.json", R"({"%n clips": {"one": "%n clip", "other": "%n clips"}})");
        write(dir.path() + "/ru.json", R"({"%n clips": {"one": "%n клип", "few": "%n клипа", "many": "%n клипов", "other": "%n клипа"}})");

        Translator translator(dir.path() + "/language", dir.path());
        QCOMPARE(translator.translate("Main", "%n clips", nullptr, 21), QString("%n клип"));
        QCOMPARE(translator.translate("Main", "%n clips", nullptr, 22), QString("%n клипа"));
        QCOMPARE(translator.translate("Main", "%n clips", nullptr, 25), QString("%n клипов"));
        QCOMPARE(Translator::pluralCategory("ar", 11), QString("many"));
        QCOMPARE(Translator::pluralCategory("ja", 1), QString("other"));
    }

    // Every qsTr("…") string in QML and every tr("…") / translate("…", "…")
    // string in C++ is in every shipped catalog, so nothing stays in English
    // after a language switch. English itself needs only the plural forms of
    // counted strings, so en.json is only parsed.
    void everyStringIsTranslated()
    {
        // Ordinary strings, not raw ones: moc reads this file, and a raw
        // string containing )" stops it from generating anything.
        const QRegularExpression qmlCall("\\bqsTr\\(\"((?:[^\"\\\\]|\\\\.)*)\"");
        const QRegularExpression cppTrCall("\\btr\\(\"((?:[^\"\\\\]|\\\\.)*)\"");
        const QRegularExpression cppTranslateCall("\\btranslate\\(\"[^\"]*\",\\s*\"((?:[^\"\\\\]|\\\\.)*)\"");
        QCOMPARE(qmlCall.match("qsTr(\"Save\")").captured(1), QString("Save"));
        QCOMPARE(cppTrCall.match("tr(\"Save\")").captured(1), QString("Save"));
        QCOMPARE(cppTranslateCall.match("QCoreApplication::translate(\"Main\", \"Save\")").captured(1), QString("Save"));

        const QDir src(QStringLiteral(SRCDIR "/../src"));
        QStringList strings;
        auto collect = [&](const QStringList &filters, const QRegularExpression &expr) {
            for (const auto &name : src.entryList(filters)) {
                QFile file(src.filePath(name));
                QVERIFY(file.open(QIODevice::ReadOnly));
                auto matches = expr.globalMatch(QString::fromUtf8(file.readAll()));
                while (matches.hasNext()) {
                    const QString s = matches.next().captured(1).replace(QStringLiteral("\\\""), QStringLiteral("\""));
                    if (!strings.contains(s))
                        strings.append(s);
                }
            }
        };
        collect({"*.qml"}, qmlCall);
        collect({"*.cpp", "*.h"}, cppTrCall);
        collect({"*.cpp", "*.h"}, cppTranslateCall);

        const QDir i18n(src.filePath("i18n"));
        for (const auto &name : i18n.entryList({"*.json"})) {
            QFile file(i18n.filePath(name));
            QVERIFY(file.open(QIODevice::ReadOnly));
            QJsonParseError error;
            const QJsonObject catalog = QJsonDocument::fromJson(file.readAll(), &error).object();
            QVERIFY2(error.error == QJsonParseError::NoError, qPrintable(name + ": " + error.errorString()));
            if (name == "en.json")
                continue;
            for (const auto &string : strings)
                QVERIFY2(catalog.contains(string), qPrintable(name + " has no \"" + string + "\""));
        }
    }

private:
    static void write(const QString &path, const QByteArray &contents)
    {
        QFile file(path);
        QVERIFY(file.open(QIODevice::WriteOnly));
        file.write(contents);
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

Add `Name[<code>]=` and `Comment[<code>]=` lines for each language the app
ships, so the launcher shows the translated name (`Name[da]=…`,
`Comment[pt_BR]=…`; desktop files spell regions with an underscore).

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

## Scratchpad harness

Not part of the project: build it in the scratchpad to see the real window
without touching the user's desktop. `harness.pro` points at the project's
`src/` by absolute path. Build it with `qmake6 && make`, then run
`./harness da shot.png` and read the image.

```qmake
QT += core gui qml quick quickcontrols2 testlib
CONFIG += c++17
TARGET = harness
SRC = /home/<user>/Work/<name>/src
INCLUDEPATH += $$SRC
HEADERS += $$SRC/backend.h $$SRC/theme.h $$SRC/translator.h
SOURCES += harness.cpp $$SRC/backend.cpp $$SRC/theme.cpp $$SRC/translator.cpp
RESOURCES += $$SRC/resources.qrc
```

```cpp
// Drives the app's real QML offscreen and saves what the user would see.
// Usage: harness [language] [output.png]
#include <QFile>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QTemporaryDir>
#include <QTest>

#include "backend.h"
#include "theme.h"
#include "translator.h"

int main(int argc, char *argv[]) {
    // Offscreen, but drawn with OpenGL like the real window: Qt Quick's
    // software renderer, the offscreen default, leaves out Material's button
    // backgrounds. QML warnings go to the terminal, not the journal.
    qputenv("QT_QPA_PLATFORM", "offscreen");
    if (!qEnvironmentVariableIsSet("QT_QUICK_BACKEND")) {
        qputenv("QT_QUICK_BACKEND", "rhi");
        qputenv("QSG_RHI_BACKEND", "opengl");
    }
    qputenv("QT_FORCE_STDERR_LOGGING", "1");
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Material");

    // A language file of its own and no Omarchy theme, so the picture has
    // the default accent and sharp corners, and the user's settings neither
    // change nor leak into it.
    QTemporaryDir dir;
    QFile language(dir.filePath("language"));
    if (!language.open(QIODevice::WriteOnly))
        return 1;
    language.write(argc > 1 ? argv[1] : "en");
    language.close();
    Translator translator(dir.filePath("language"));
    app.installTranslator(&translator);
    Theme theme(dir.filePath("no-omarchy"));
    Backend backend;

    QQmlApplicationEngine engine;
    QObject::connect(&translator, &Translator::changed, &engine, &QQmlEngine::retranslate);
    QObject::connect(&translator, &Translator::changed, &backend, &Backend::retranslate);
    engine.rootContext()->setContextProperty("translator", &translator);
    engine.rootContext()->setContextProperty("theme", &theme);
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.load(QUrl("qrc:/Main.qml"));
    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().value(0));
    if (!window || !QTest::qWaitForWindowExposed(window))
        return 1;

    // Use it the way the user would: keys, typed characters, clicks
    // (QTest::mouseClick(window, Qt::LeftButton, {}, QPoint(x, y))).
    QTest::keyClick(window, Qt::Key_Space);
    QTest::qWait(400); // Let animations settle before the picture.

    window->grabWindow().save(argc > 2 ? argv[2] : "shot.png");
    return 0;
}
```
