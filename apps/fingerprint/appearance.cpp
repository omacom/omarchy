#include "appearance.h"
#include <QColor>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QLocale>
#include <QRegularExpression>
#include <QStandardPaths>

static QByteArray read(const QString &path) {
  QFile file(path);
  return file.open(QIODevice::ReadOnly) ? file.readAll() : QByteArray();
}

Appearance::Appearance(QObject *parent) : QObject(parent) {
  connect(&watcher, &QFileSystemWatcher::fileChanged, this, &Appearance::reload);
  connect(&watcher, &QFileSystemWatcher::directoryChanged, this, &Appearance::reload);
  reload();
}

void Appearance::reload() {
  const QString current = QStandardPaths::writableLocation(QStandardPaths::GenericStateLocation) + "/omarchy/current";
  const QString colors = current + "/theme/colors.toml";
  const QString config = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation) + "/omarchy";
  const QString language = config + "/language";
  for (const auto &path : QStringList{current, current + "/theme", colors, config, language})
    if (QFileInfo::exists(path) && !watcher.files().contains(path) && !watcher.directories().contains(path))
      watcher.addPath(path);
  QVariantMap next;
  static const QRegularExpression assignment(R"toml(^\s*(\w+)\s*=\s*"(#[0-9a-fA-F]{6})"\s*(?:#.*)?$)toml");
  for (const auto &line : QString::fromUtf8(read(colors)).split('\n')) {
    auto match = assignment.match(line);
    if (match.hasMatch()) next.insert(match.captured(1), QColor(match.captured(2)));
  }
  palette = next;
  const auto english = QJsonDocument::fromJson(read(":/i18n/cli.json")).toVariant().toMap();
  catalog = english;
  const QString locale = QString::fromUtf8(read(language)).trimmed();
  static const QRegularExpression valid("^[a-zA-Z]+(-[a-zA-Z]+)*$");
  rtl = valid.match(locale).hasMatch() && QLocale(locale).textDirection() == Qt::RightToLeft;
  if (valid.match(locale).hasMatch()) {
    const auto local = QJsonDocument::fromJson(read(qEnvironmentVariable("OMARCHY_PATH") + "/default/i18n/" + locale + "/cli.json")).toVariant().toMap();
    for (auto it = local.begin(); it != local.end(); ++it)
      if (it.value().typeId() == QMetaType::QString && !it.value().toString().isEmpty()) catalog.insert(it.key(), it.value());
  }
  emit changed();
}

QString Appearance::text(const QString &key) const {
  return catalog.value(key, key).toString();
}
