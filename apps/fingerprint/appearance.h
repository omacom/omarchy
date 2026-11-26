#pragma once
#include <QFileSystemWatcher>
#include <QVariantMap>

class Appearance : public QObject {
  Q_OBJECT
  Q_PROPERTY(bool rightToLeft READ rightToLeft NOTIFY changed)
  Q_PROPERTY(QVariantMap colors READ colors NOTIFY changed)
  Q_PROPERTY(QVariantMap strings READ strings NOTIFY changed)
public:
  explicit Appearance(QObject *parent = nullptr);
  QVariantMap colors() const { return palette; }
  QVariantMap strings() const { return catalog; }
  bool rightToLeft() const { return rtl; }
  QString text(const QString &key) const;
signals:
  void changed();
private:
  QFileSystemWatcher watcher;
  QVariantMap palette, catalog;
  bool rtl = false;
  void reload();
};
