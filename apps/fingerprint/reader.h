#pragma once
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusServiceWatcher>
#include <QElapsedTimer>
#include <QTimer>
#include <functional>

namespace Fprint {
inline const QString service = QStringLiteral("net.reactivated.Fprint");
inline const QString device = service + ".Device";
inline const QString manager = QStringLiteral("/net/reactivated/Fprint/Manager");
inline const QString properties = QStringLiteral("org.freedesktop.DBus.Properties");
inline const QString apple = QStringLiteral("Apple secure enclave fingerprint sensor");
const QStringList &slotsInOrder();
}

// One connection per claim lets fprintd release an operation even if its
// authorization dialog was still open when the window was closed.
class Reader : public QObject {
  Q_OBJECT
public:
  Reader(const QString &owner, const QString &path, QObject *parent);
  ~Reader() override;
  void start(const QString &mode, const QString &finger, int capacity);
signals:
  void event(const QString &status, const QString &detail);
  void finished(const QString &status, const QString &detail);
private slots:
  void status(const QString &result, bool done);
  void selected(const QString &finger);
  void propertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalidated);
private:
  QString owner, path, connectionName, mode;
  QDBusConnection bus;
  bool claimed = false, ending = false;
  void call(const QString &method, const QVariantList &args, std::function<void(const QDBusMessage &)> callback);
  void finish(const QString &result, const QString &detail = {});
};

class ScanGuide : public QObject {
  Q_OBJECT
public:
  explicit ScanGuide(QObject *parent = nullptr);
  void reset(bool pressEnrollment);
  void update(const QString &event);
  void stop();
  QString prompt;
  int samples = 0;
signals:
  void changed();
private:
  int present = -1;
  bool press = false;
  QString next;
  QTimer timer;
  QElapsedTimer hold;
  void show(const QString &value);
  void after(int ms, const QString &value);
};
