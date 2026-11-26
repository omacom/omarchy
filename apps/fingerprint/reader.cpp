#include "reader.h"
#include <QDBusPendingCallWatcher>
#include <QDBusReply>
#include <QUuid>

const QStringList &Fprint::slotsInOrder() {
  static const QStringList fingers = [] {
    QStringList result;
    for (const auto &side : {"right-", "left-"})
      for (const auto &digit : {"index-finger", "thumb", "middle-finger", "ring-finger", "little-finger"})
        result << QString::fromLatin1(side) + digit;
    return result;
  }();
  return fingers;
}

Reader::Reader(const QString &owner, const QString &path, QObject *parent)
    : QObject(parent), owner(owner), path(path), connectionName(QUuid::createUuid().toString()),
      bus(QDBusConnection::connectToBus(QDBusConnection::SystemBus, connectionName)) {
  auto *watch = new QDBusServiceWatcher(owner, bus, QDBusServiceWatcher::WatchForUnregistration, this);
  connect(watch, &QDBusServiceWatcher::serviceUnregistered, this, [this] {
    if (!ending) { ending = true; emit finished("disconnected", {}); }
  });
  bus.connect(owner, path, Fprint::device, "VerifyFingerSelected", this, SLOT(selected(QString)));
  bus.connect(owner, path, Fprint::properties, "PropertiesChanged", this,
              SLOT(propertiesChanged(QString,QVariantMap,QStringList)));
}

Reader::~Reader() {
  QDBusConnection::disconnectFromBus(connectionName);
}

void Reader::call(const QString &method, const QVariantList &args, std::function<void(const QDBusMessage &)> callback) {
  auto message = QDBusMessage::createMethodCall(owner, path, Fprint::device, method);
  message.setArguments(args);
  message.setInteractiveAuthorizationAllowed(true);
  auto *watch = new QDBusPendingCallWatcher(bus.asyncCall(message, 120000), this);
  connect(watch, &QDBusPendingCallWatcher::finished, this, [watch, callback] {
    auto reply = watch->reply();
    watch->deleteLater();
    callback(reply);
  });
}

void Reader::start(const QString &operation, const QString &finger, int capacity) {
  mode = operation;
  if (mode != "Delete")
    bus.connect(owner, path, Fprint::device, mode + "Status", this, SLOT(status(QString,bool)));
  auto begin = [this, finger] {
    call(mode + "Start", {finger}, [this](const QDBusMessage &r) {
      if (r.type() == QDBusMessage::ErrorMessage) finish("error", r.errorMessage());
    });
  };
  call("Claim", {QString()}, [this, finger, capacity, begin](const QDBusMessage &r) {
    if (ending) return;
    if (r.type() == QDBusMessage::ErrorMessage) { finish("error", r.errorMessage()); return; }
    claimed = true;
    if (mode == "Delete") {
      call("DeleteEnrolledFinger", {finger}, [this](const QDBusMessage &r) {
        finish(r.type() == QDBusMessage::ErrorMessage ? "error" : "removed", r.errorMessage());
      });
    } else if (mode == "Enroll") {
      call("ListEnrolledFingers", {QString()}, [this, finger, capacity, begin](const QDBusMessage &r) {
        if (ending) return;
        QDBusReply<QStringList> list(r);
        if (!list.isValid() && r.errorName() != Fprint::service + ".Error.NoEnrolledPrints")
          finish("error", r.errorMessage());
        else if (list.value().contains(finger)) finish("enroll-duplicate");
        else if (list.value().size() >= capacity) finish("enroll-data-full");
        else begin();
      });
    } else begin();
  });
}

void Reader::status(const QString &result, bool done) {
  if (ending || mode.isEmpty()) return;
  if (!done) { emit event(result, {}); return; }
  const QString stop = mode + "Stop";
  mode.clear();
  call(stop, {}, [this, result](const QDBusMessage &) { finish(result); });
}

void Reader::finish(const QString &result, const QString &detail) {
  if (ending) return;
  ending = true;
  if (!claimed) { emit finished(result, detail); return; }
  call("Release", {}, [this, result, detail](const QDBusMessage &r) {
    if (r.type() == QDBusMessage::ErrorMessage) emit finished("error", r.errorMessage());
    else emit finished(result, detail);
  });
}

void Reader::selected(const QString &finger) {
  if (!ending && mode == "Verify") emit event("verify-finger-selected", finger);
}

void Reader::propertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &) {
  if (ending || mode.isEmpty() || interface != Fprint::device) return;
  if (changed.contains("finger-present")) emit event(changed.value("finger-present").toBool() ? "finger-down" : "finger-up", {});
}

ScanGuide::ScanGuide(QObject *parent) : QObject(parent) {
  timer.setSingleShot(true);
  connect(&timer, &QTimer::timeout, this, [this] { show(next); });
}
void ScanGuide::stop() { timer.stop(); next.clear(); }
void ScanGuide::reset(bool pressEnrollment) {
  stop(); samples = 0; present = -1; press = pressEnrollment; show("touch");
}
void ScanGuide::after(int ms, const QString &value) { next = value; timer.start(ms); }
void ScanGuide::show(const QString &value) {
  prompt = value;
  stop();
  if (prompt == "hold") hold.start();
  emit changed();
  if (present == 0 && prompt != "touch" && prompt != "hold") after(500, "touch");
}
void ScanGuide::update(const QString &event) {
  if (event == "finger-needed") return;
  if (event == "enroll-stage-passed") {
    ++samples;
    const bool lift = press && present >= 0;
    if (lift && prompt == "hold" && hold.elapsed() < 500) {
      after(qMax(1, 500 - int(hold.elapsed())), "lift");
      emit changed();
    } else show(lift ? "lift" : "retouch");
  } else if (event == "finger-down" || event == "finger-up") {
    present = event == "finger-down";
    if (next == "lift") return;
    if (present) {
      stop();
      if (prompt == "touch") show("hold");
    } else if (prompt == "hold" && !press) show("touch");
    else if (prompt != "touch" && !timer.isActive()) after(500, "touch");
  } else show(event);
}
