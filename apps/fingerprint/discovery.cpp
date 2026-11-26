#include "discovery.h"
#include "reader.h"
#include <QDBusReply>
#include <QDBusConnectionInterface>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QProcess>
#include <dbus/dbus.h>
#include <glob.h>
#include <stdexcept>

SystemFiles::SystemFiles() : sudoHelper(FINGERPRINT_PAM_HELPER) {}

static QByteArray output(const QString &program, const QStringList &args) {
  QProcess process;
  process.start(program, args);
  if (!process.waitForFinished(2500)) {
    process.kill();
    process.waitForFinished();
    return {};
  }
  return process.exitCode() == 0 ? process.readAllStandardOutput().trimmed() : QByteArray();
}

static bool needsConsent(const QString &path) {
  QFile contract(path);
  if (!contract.open(QIODevice::ReadOnly)) return false;
  while (!contract.atEnd()) {
    const auto parts = contract.readLine().simplified().split(' ');
    if (parts.size() != 2 || !parts[0].startsWith('/') || parts[1] != "available") continue;
    glob_t paths{};
    glob(parts[0].constData(), GLOB_NOSORT, nullptr, &paths);
    bool found = false;
    for (size_t i = 0; i < paths.gl_pathc && !found; ++i) {
      QFile marker(QFile::decodeName(paths.gl_pathv[i]));
      found = marker.open(QIODevice::ReadOnly) && marker.readAll().trimmed() == "available";
    }
    globfree(&paths);
    if (found) return true;
  }
  return false;
}

Discovery discover(const SystemFiles &files, const QString &previousOwner, const QString &selectedPath, const QString &resumeModel) {
  Discovery result;
  result.consent = needsConsent(files.consentContract);
  result.sudoState = QString::fromUtf8(output(files.sudoHelper, {"status"}));
  if (result.sudoState != "enabled" && result.sudoState != "disabled") result.sudoState = "custom";
  const auto bus = QDBusConnection::systemBus();
  auto call = [&](const QString &name, const QString &path, const QString &iface, const QString &method,
                  const QVariantList &args = {}) {
    auto request = QDBusMessage::createMethodCall(name, path, iface, method);
    request.setArguments(args);
    return bus.call(request, QDBus::Block, 15000);
  };
  try {
    if (!bus.interface()) throw std::runtime_error(bus.lastError().message().toStdString());
    auto owner = bus.interface()->serviceOwner(Fprint::service);
    if (!owner.isValid()) {
      auto started = bus.interface()->startService(Fprint::service);
      if (!started.isValid()) throw std::runtime_error(started.error().message().toStdString());
      owner = bus.interface()->serviceOwner(Fprint::service);
    }
    if (!owner.isValid()) throw std::runtime_error(owner.error().message().toStdString());
    result.owner = owner.value();
    // Bind enumeration and every operation on its object paths to the same daemon.
    QDBusReply<QList<QDBusObjectPath>> devices(call(result.owner, Fprint::manager, Fprint::service + ".Manager", "GetDevices"));
    if (!devices.isValid()) throw std::runtime_error(devices.error().message().toStdString());
    // Match the authentication GUID used by GDBus for existing reader labels.
    char *guid = dbus_connection_get_server_id(static_cast<DBusConnection *>(bus.internalPointer()));
    if (!guid) throw std::runtime_error("Could not identify the system bus.");
    result.guid = QString::fromLatin1(guid);
    dbus_free(guid);
    QList<int> matching;
    for (const auto &device : devices.value()) {
      QDBusReply<QVariantMap> props(call(result.owner, device.path(), Fprint::properties, "GetAll", {Fprint::device}));
      if (!props.isValid()) throw std::runtime_error(props.error().message().toStdString());
      const auto model = props.value().value("name").toString();
      if (result.consent && model == Fprint::apple) continue;
      if (result.owner == previousOwner && device.path() == selectedPath) result.selected = result.devices.size();
      if (model == resumeModel) matching << result.devices.size();
      result.devices << DeviceInfo{device.path(), model, props.value().value("scan-type") == "swipe"};
    }
    if (matching.size() == 1) result.selected = matching.first();
    if (result.devices.isEmpty()) return result;
    auto list = [&](const DeviceInfo &device) -> QStringList {
      QDBusReply<QStringList> fingers(call(result.owner, device.path, Fprint::device, "ListEnrolledFingers", {QString()}));
      if (!fingers.isValid() && fingers.error().name() != Fprint::service + ".Error.NoEnrolledPrints")
        throw std::runtime_error(fingers.error().message().toStdString());
      return fingers.value();
    };
    result.fingers = list(result.devices.at(result.selected));
    if (QFileInfo::exists(files.lockPam)) {
      result.configured = !result.fingers.isEmpty();
      for (int i = 0; !result.configured && i < result.devices.size(); ++i)
        if (i != result.selected) result.configured = !list(result.devices.at(i)).isEmpty();
    }
    result.lockerSupportsPreference = QJsonDocument::fromJson(output("omarchy-shell", {"lock", "status"}))
        .object().value("fingerprintPreferenceSupported").toBool();
  } catch (const std::exception &error) {
    result.error = QString::fromUtf8(error.what());
    result.devices.clear();
  }
  return result;
}
