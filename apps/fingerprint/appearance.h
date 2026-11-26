#pragma once
#include <QFileSystemWatcher>
#include <QVariantMap>
#include <QLocalSocket>
#include <QProcess>
#include <QTimer>

class Appearance : public QObject {
  Q_OBJECT
  Q_PROPERTY(bool rightToLeft READ rightToLeft NOTIFY changed)
  Q_PROPERTY(int cornerRadius READ cornerRadius NOTIFY radiusChanged)
  Q_PROPERTY(QVariantMap colors READ colors NOTIFY changed)
  Q_PROPERTY(QVariantMap strings READ strings NOTIFY changed)
public:
  explicit Appearance(QObject *parent = nullptr);
  ~Appearance() override;
  QVariantMap colors() const { return palette; }
  QVariantMap strings() const { return catalog; }
  bool rightToLeft() const { return rtl; }
  int cornerRadius() const { return radius; }
  QString text(const QString &key) const;
signals:
  void changed();
  void radiusChanged();
private:
  QFileSystemWatcher watcher;
  QVariantMap palette, catalog;
  bool rtl = false;
  int radius = 0;
  QLocalSocket compositorEvents;
  QTimer reconnect;
  bool roundingPending = false;
  QProcess rounding;
  QTimer roundingTimeout;
  void readRounding();
  void reload();
};
