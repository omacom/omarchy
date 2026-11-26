#include "backend.h"
#include <QDBusConnectionInterface>
#include <QDir>
#include <QFutureWatcher>
#include <QProcess>
#include <QSet>
#include <QtConcurrentRun>

static QString disabledPath() {
  return QDir::homePath() + "/.local/state/omarchy/toggles/lock-fingerprint-off";
}

Backend::Backend(Appearance &appearance, const SystemFiles &files, QObject *parent)
    : QObject(parent), appearance(appearance), files(files) {
  connect(&guide, &ScanGuide::changed, this, &Backend::changed);
  connect(&appearance, &Appearance::changed, this, &Backend::changed);
  pamWatcher.addPath(QFileInfo(files.lockPam).absolutePath());
  connect(&pamWatcher, &QFileSystemWatcher::directoryChanged, this, [this] {
    if (page == "home") refresh();
  });
  refresh();
}

int Backend::capacity() const {
  // Apple's Aurora reader reports ten fprintd names for three physical slots.
  return device().model == Fprint::apple ? 3 : Fprint::slotsInOrder().size();
}
bool Backend::unlockOn() const {
  return QFileInfo::exists(files.lockPam) && (!devices.lockerSupportsPreference || !QFileInfo::exists(disabledPath()));
}
bool Backend::mayEnroll() const {
  return hasDevice() && devices.fingers.size() < capacity() &&
         (devices.configured || !QFileInfo::exists(files.lockPam) || devices.lockerSupportsPreference);
}
QString Backend::label(const QString &finger) const {
  if (finger == "any") return t("fingerprintApp.useAny");
  QSet<int> used;
  for (const auto &row : prints) {
    const auto item = row.toMap();
    const int n = item.value("number").toInt();
    if (item.value("slot") == finger) {
      const auto custom = item.value("name").toString();
      return custom.isEmpty() ? t("fingerprintApp.numbered").arg(n) : custom;
    }
    used.insert(n);
  }
  int n = 1;
  while (used.contains(n)) ++n;
  return t("fingerprintApp.numbered").arg(n);
}

QVariantMap Backend::view() const {
  QStringList models;
  for (const auto &d : devices.devices) models << d.model;
  QVariantList rows;
  for (const auto &p : prints) {
    auto row = p.toMap();
    row.insert("label", label(row.value("slot").toString()));
    rows << row;
  }
  QString cue;
  if (guide.prompt == "touch") cue = t(device().swipe ? "fingerprintApp.swipe" : "fingerprintApp.touch");
  else if (guide.prompt == "hold") cue = t(device().swipe ? "fingerprintApp.swipe" : mode == "Enroll" ? "fingerprintApp.keepTouching" : "fingerprintApp.hold");
  else if (guide.prompt == "retouch") cue = t(device().swipe ? "fingerprintApp.swipeAgain" : "fingerprintApp.retouch");
  else if (guide.prompt == "lift") cue = t("fingerprintApp.lift");
  else cue = explain(guide.prompt);
  return {{"page", page}, {"notice", notice}, {"title", title}, {"models", models}, {"selected", devices.selected},
          {"apple", device().model == Fprint::apple}, {"model", device().model}, {"prints", rows},
          {"consent", devices.consent}, {"lockSupported", devices.lockerSupportsPreference},
          {"unlockOn", unlockOn()}, {"sudoState", devices.sudoState}, {"canEnroll", mayEnroll()},
          {"full", devices.fingers.size() >= capacity()}, {"capacity", capacity()}, {"canRename", !labelKey.isEmpty()},
          {"mode", mode}, {"label", label(subject)}, {"prompt", cue}, {"contact", guide.prompt == "hold"},
          {"samples", guide.samples}, {"swipe", device().swipe}};
}

void Backend::stop() {
  guide.stop();
  delete reader;
  reader = nullptr;
}
void Backend::refresh() { if (!privilegedPending) reload(); }
void Backend::reload(const QString &message, bool resume) {
  stop();
  const auto request = ++generation;
  const auto oldKey = labelKey;
  const auto previous = device();
  page = "loading";
  notice = message;
  emit changed();
  auto *watch = new QFutureWatcher<Discovery>(this);
  connect(watch, &QFutureWatcher<Discovery>::finished, this, [this, watch, request, resume, oldKey] {
    const auto result = watch->result();
    watch->deleteLater();
    if (request != generation) return;
    devices = result;
    prints.clear();
    labelKey.clear();
    if (!hasDevice()) {
      page = "unavailable";
      if (notice.isEmpty()) notice = devices.consent ? t("fingerprintApp.consent") :
          devices.error.isEmpty() ? t("fingerprintApp.openLid") : devices.error;
    } else {
      QStringList models;
      for (const auto &d : devices.devices) models << d.model;
      try {
        labelKey = names.bind(models, device().model, devices.guid + "|" + devices.owner + device().path);
        prints = names.sync(labelKey, devices.fingers);
      } catch (const std::exception &error) {
        labelKey.clear();
        notice = QString::fromUtf8(error.what());
        for (const auto &finger : devices.fingers)
          prints << QVariantMap{{"slot", finger}, {"number", prints.size() + 1}};
      }
      page = "home";
      if (resume && !oldKey.isEmpty() && labelKey == oldKey && (slot == "any" || devices.fingers.contains(slot))) {
        scan("Verify", slot, afterMatch);
        return;
      }
    }
    emit changed();
  });
  watch->setFuture(QtConcurrent::run(discover, files, devices.owner, previous.path, resume ? previous.model : QString()));
}
void Backend::selectDevice(int index) {
  if (page != "home" || index < 0 || index >= devices.devices.size()) return;
  devices.selected = index;
  refresh();
}
bool Backend::optOut() {
  const auto path = disabledPath();
  QFile marker(path);
  if (QDir().mkpath(QFileInfo(path).absolutePath()) && marker.open(QIODevice::WriteOnly | QIODevice::Append)) return true;
  reload(marker.errorString());
  return false;
}
void Backend::enroll() {
  if (page != "home" || !mayEnroll()) return;
  for (const auto &finger : Fprint::slotsInOrder()) {
    if (!devices.fingers.contains(finger)) { scan("Enroll", finger); return; }
  }
}
void Backend::verify(const QString &finger) {
  if (page == "home" && devices.fingers.contains(finger)) scan("Verify", finger);
}
void Backend::edit(const QString &finger) {
  if (page != "home" || !devices.fingers.contains(finger)) return;
  slot = subject = finger;
  page = "edit";
  emit changed();
}
void Backend::saveName(const QString &name) {
  if (page != "edit" && page != "added") return;
  if (!labelKey.isEmpty()) {
    QString custom = name.trimmed().left(64);
    for (const auto &row : prints) {
      const auto p = row.toMap();
      if (p.value("slot") == slot && custom == t("fingerprintApp.numbered").arg(p.value("number").toInt())) custom.clear();
    }
    try { names.rename(labelKey, slot, custom); }
    catch (const std::exception &error) { reload(QString::fromUtf8(error.what())); return; }
  }
  refresh();
}
void Backend::confirmRemove() {
  if (page == "edit") { page = "confirm"; emit changed(); }
}
void Backend::remove() {
  if (page == "confirm") scan("Delete", slot);
}
void Backend::retry() {
  if (page == "failed" && mode == "Verify") reload({}, true);
}

void Backend::scan(const QString &operation, const QString &finger, const QString &onMatch) {
  if (!hasDevice() || reader) return;
  mode = operation;
  slot = subject = finger;
  afterMatch = onMatch;
  auto bus = QDBusConnection::systemBus();
  if (!bus.interface() || bus.interface()->serviceOwner(Fprint::service).value() != devices.owner) {
    reload(t("fingerprintApp.readerChanged"), mode == "Verify");
    return;
  }
  if (mode == "Enroll" && !devices.configured && !optOut()) return;
  page = mode == "Delete" ? "removing" : "scan";
  guide.reset(mode == "Enroll" && !device().swipe);
  reader = new Reader(devices.owner, device().path, this);
  connect(reader, &Reader::event, this, [this](const QString &event, const QString &detail) {
    if (event == "verify-finger-selected") {
      if (devices.fingers.contains(detail)) { subject = detail; emit changed(); }
    } else guide.update(event);
  });
  connect(reader, &Reader::finished, this, &Backend::finish);
  reader->start(mode, slot, capacity());
}

void Backend::finish(const QString &result, const QString &detail) {
  guide.stop();
  reader->deleteLater();
  reader = nullptr;
  if (result == "removed") { reload(t("fingerprintApp.removed")); return; }
  if (result == "enroll-completed") {
    if (labelKey.isEmpty()) { reload(t("fingerprintApp.added")); return; }
    try { prints = names.sync(labelKey, {slot}, false); }
    catch (const std::exception &error) { reload(QString::fromUtf8(error.what())); return; }
    page = "added";
  } else if (result == "verify-match") {
    if (afterMatch == "unlock") { enableUnlock(); return; }
    if (afterMatch == "sudo") { changeSudo(true); return; }
    page = "matched";
  } else {
    page = "failed";
    title = t(mode == "Delete" ? "fingerprintApp.removeFailed" : mode == "Enroll" ? "fingerprintApp.notAdded" :
              result == "verify-unknown-error" ? "fingerprintApp.verifyReaderError" : "fingerprintApp.notVerified");
    notice = result == "verify-unknown-error" ? t("fingerprintApp.noVerdict") : detail.isEmpty() ? explain(result) : detail;
  }
  emit changed();
}

void Backend::toggleUnlock() {
  if (page != "home" || !devices.lockerSupportsPreference || prints.isEmpty()) return;
  if (unlockOn()) { if (optOut()) refresh(); }
  else scan("Verify", "any", "unlock");
}
void Backend::enableUnlock() {
  if (QFileInfo::exists(files.lockPam)) {
    QFile marker(disabledPath());
    if (marker.exists() && !marker.remove()) { reload(marker.errorString()); return; }
    reload(t("fingerprintApp.enabled"));
  } else if (optOut()) {
    run("xdg-terminal-exec", {"--title=Fingerprint Setup", "-e", "/bin/bash", "-c",
        "\"$1\" && [[ -f $2 ]] && rm -f -- \"$3\"", "enable-unlock",
        qEnvironmentVariable("OMARCHY_PATH") + "/bin/omarchy-apply-lock", files.lockPam, disabledPath()},
        t("fingerprintApp.enableTitle"), t("fingerprintApp.confirmAdmin"));
  }
}
void Backend::toggleSudo() {
  if (page != "home" && page != "unavailable") return;
  if (devices.sudoState == "enabled") changeSudo(false);
  else if (devices.sudoState == "disabled" && !prints.isEmpty()) scan("Verify", "any", "sudo");
}
void Backend::changeSudo(bool enable) {
  // Privileged code always comes from the root-owned package.
  run(files.elevation, {files.sudoHelper, enable ? "enable" : "disable"}, t("fingerprintApp.useSudo"), t("fingerprintApp.sudoConfirm"));
}
void Backend::prepare() {
  if (page != "unavailable" && !(page == "home" && devices.consent)) return;
  run("xdg-terminal-exec", {"--title=Fingerprint Setup", "-e", "/bin/bash",
      qEnvironmentVariable("OMARCHY_PATH") + "/default/fingerprint/prepare-reader"}, t("fingerprintApp.setupReader"), t("fingerprintApp.prepare"));
}
void Backend::run(const QString &program, const QStringList &args, const QString &heading, const QString &message) {
  privilegedPending = true;
  page = "working"; title = heading; notice = message;
  emit changed();
  auto *process = new QProcess(this);
  auto complete = [this, process](bool ok) {
    if (!privilegedPending) return;
    privilegedPending = false;
    const auto detail = QString::fromUtf8(process->readAllStandardError()).trimmed();
    reload(ok ? QString() : detail.isEmpty() ? (process->program() == files.elevation ? t("fingerprintApp.sudoError") : process->errorString()) : detail);
    process->deleteLater();
  };
  connect(process, &QProcess::finished, this, [this, process, complete](int code, QProcess::ExitStatus status) {
    const bool cancelled = process->program() == files.elevation && code == 126;
    complete((code == 0 || cancelled) && status == QProcess::NormalExit);
  });
  connect(process, &QProcess::errorOccurred, this, [complete](QProcess::ProcessError error) {
    if (error == QProcess::FailedToStart) complete(false);
  });
  process->start(program, args);
}
QString Backend::explain(const QString &result) const {
  static const QMap<QString, QString> reasons{
    {"unknown-error", "fingerprintApp.readerError"}, {"too-fast", "fingerprintApp.tooFast"}, {"not-centered", "fingerprintApp.center"},
    {"swipe-too-short", "fingerprintApp.swipeLonger"}, {"remove-and-retry", "fingerprintApp.removeAndRetry"}, {"retry-scan", "fingerprintApp.moveFingertip"},
    {"duplicate", "fingerprintApp.duplicate"}, {"no-match", "fingerprintApp.noMatch"}, {"data-full", "fingerprintApp.storageFull"},
    {"disconnected", "fingerprintApp.disconnected"}, {"failed", "fingerprintApp.stopped"}};
  for (auto it = reasons.begin(); it != reasons.end(); ++it)
    if (result.endsWith(it.key())) return t(it.value());
  return t("fingerprintApp.reported").arg(result);
}
