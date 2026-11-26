#pragma once
#include "appearance.h"
#include "discovery.h"
#include "names.h"
#include "reader.h"

class Backend : public QObject {
  Q_OBJECT
  Q_PROPERTY(QVariantMap view READ view NOTIFY changed)
public:
  explicit Backend(Appearance &appearance, const SystemFiles &files = {}, QObject *parent = nullptr);
  QVariantMap view() const;
  Q_INVOKABLE void refresh();
  Q_INVOKABLE void selectDevice(int index);
  Q_INVOKABLE void enroll();
  Q_INVOKABLE void verify(const QString &slot);
  Q_INVOKABLE void edit(const QString &slot);
  Q_INVOKABLE void saveName(const QString &name);
  Q_INVOKABLE void confirmRemove();
  Q_INVOKABLE void remove();
  Q_INVOKABLE void toggleUnlock();
  Q_INVOKABLE void toggleSudo();
  Q_INVOKABLE void prepare();
  Q_INVOKABLE void retry();
signals:
  void changed();
private:
  Appearance &appearance;
  const SystemFiles files;
  Discovery devices;
  Names names;
  ScanGuide guide;
  QFileSystemWatcher pamWatcher;
  Reader *reader = nullptr;
  int generation = 0;
  QString page = "loading", notice, title, mode, slot, subject, afterMatch, labelKey;
  QVariantList prints;
  bool privilegedPending = false;
  QString t(const QString &key) const { return appearance.text(key); }
  QString explain(const QString &result) const;
  bool hasDevice() const { return !devices.devices.isEmpty(); }
  DeviceInfo device() const { return devices.devices.value(devices.selected); }
  int capacity() const;
  bool unlockOn() const;
  bool mayEnroll() const;
  QString label(const QString &finger) const;
  void reload(const QString &message = {}, bool resume = false);
  void stop();
  void scan(const QString &operation, const QString &finger, const QString &onMatch = {});
  void finish(const QString &result, const QString &detail);
  bool optOut();
  void enableUnlock();
  void changeSudo(bool enable);
  void run(const QString &program, const QStringList &args, const QString &heading, const QString &message);
};
