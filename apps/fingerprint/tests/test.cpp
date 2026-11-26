#include "../backend.h"
#include <QAccessible>
#include <QDBusConnectionInterface>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSignalSpy>
#include <QDir>
#include <QTest>

class FingerprintTest : public QObject {
  Q_OBJECT
  QDBusConnection bus = QDBusConnection::systemBus();
  QString finger = "right-index-finger", added = "right-thumb";
  void reset(const QStringList &fingers, bool hold = false, const QString &verdict = "verify-match") {
    auto msg = QDBusMessage::createMethodCall(Fprint::service, "/test", "test.Fingerprint", "Reset");
    msg.setArguments({fingers, hold, verdict});
    QCOMPARE(bus.call(msg).type(), QDBusMessage::ReplyMessage);
  }
  QStringList calls() {
    return QDBusReply<QStringList>(bus.call(QDBusMessage::createMethodCall(
        Fprint::service, "/test", "test.Fingerprint", "Calls"))).value();
  }
  QString read(Backend &b, const QString &key) { return b.view().value(key).toString(); }
  QQuickItem *button(QQuickItem *node, const QString &label) {
    if (!node->isVisible()) return nullptr;
    if (node->metaObject()->indexOfMethod("click()") >= 0 && node->property("text") == label) return node;
    for (auto *child : node->childItems()) if (auto *hit = button(child, label)) return hit;
    return nullptr;
  }
  void screenshot(QQuickWindow *window, const QString &name) {
    const auto dir = qEnvironmentVariable("FINGERPRINT_SCREENSHOTS");
    if (!dir.isEmpty()) {
      QTest::qWait(120);
      QVERIFY(window->grabWindow().save(dir + "/" + name + ".png"));
    }
  }
private slots:
  void cuesFollowContact() {
    ScanGuide guide;
    guide.reset(true);
    for (int i = 1; i <= 2; ++i) {
      guide.update("finger-down"); guide.update("finger-up"); guide.update("enroll-stage-passed");
      QCOMPARE(guide.prompt, "hold");
      QTRY_COMPARE(guide.prompt, "lift");
      guide.update("finger-needed"); guide.update("finger-down");
      QCOMPARE(guide.prompt, "lift");
      guide.update("finger-up");
      QTRY_COMPARE(guide.prompt, "touch");
      QCOMPARE(guide.samples, i);
    }
    guide.reset(true);
    guide.update("enroll-stage-passed");
    QCOMPARE(guide.prompt, "retouch");
  }
  void legacyNamesSurviveReconnect() {
    Names db;
    const auto incumbent = db.bind({"USB"}, "USB", ":1.4/0");
    QCOMPARE(incumbent, "USB");
    db.sync(incumbent, {finger, added});
    db.rename(incumbent, added, "Trackpad hand");
    db.bind({"USB", "USB", "Built-in"}, "Built-in", ":1.4/2");
    const auto other = db.bind({"USB"}, "USB", ":1.4/1");
    QVERIFY(other != incumbent);
    QCOMPARE(db.sync(other, {added}).first().toMap()["name"].toString(), "");
    auto saved = db.sync(incumbent, {added}).first().toMap();
    QCOMPARE(saved["name"].toString(), "Trackpad hand");
    QCOMPARE(saved["number"].toInt(), 2);
    QCOMPARE(db.sync(incumbent, {added, finger}).first().toMap()["number"].toInt(), 1);
  }
  void fullAndOccupiedAreCheckedUnderClaim() {
    const QString owner = bus.interface()->serviceOwner(Fprint::service);
    auto scan = [&](const QString &target, const QString &operation, const QString &slot) {
      Reader reader(target, "/net/reactivated/Fprint/Device/0", this);
      QSignalSpy result(&reader, &Reader::finished);
      reader.start(operation, slot, 3);
      if (!result.wait(4000)) return QString("timeout");
      return result.first().first().toString();
    };
    reset({finger, added, "left-thumb"});
    QCOMPARE(scan(owner, "Enroll", "right-ring-finger"), "enroll-data-full");
    QCOMPARE(scan(owner, "Enroll", finger), "enroll-duplicate");
    const auto before = calls();
    QCOMPARE(before, QStringList({"claim", "release", "claim", "release"}));
    QVERIFY(scan(":1.999999", "Delete", finger) != "removed");
    QCOMPARE(calls(), before);
    QCOMPARE(scan(owner, "Delete", added), "removed");
    QVERIFY(calls().contains("delete " + added));
  }
  void standaloneWindow() {
    QAccessible::setActive(true);
    reset({finger});
    const auto config = qEnvironmentVariable("XDG_CONFIG_HOME") + "/omarchy";
    QVERIFY(QDir().mkpath(config));
    Appearance style;
    SystemFiles files;
    const auto home = QDir::homePath();
    files.consentContract = home + "/consent";
    files.lockPam = home + "/pam/omarchy-lock-fingerprint";
    files.sudoHelper = home + "/bin/sudo-status";
    files.elevation = home + "/bin/elevate";
    Backend b(style, files);
    QQmlApplicationEngine engine;
    engine.setInitialProperties({{"backend", QVariant::fromValue(&b)}, {"appearance", QVariant::fromValue(&style)}});
    engine.load(QUrl("qrc:/Main.qml"));
    QVERIFY(!engine.rootObjects().isEmpty());
    auto *win = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    QVERIFY(win);
    auto click = [&](const QString &label) {
      auto *item = button(win->contentItem(), label);
      QVERIFY2(item, qPrintable(label));
      QVERIFY(QMetaObject::invokeMethod(item, "click"));
    };
    QTRY_VERIFY_WITH_TIMEOUT(read(b, "page") != "loading", 5000);
    QVERIFY2(read(b, "page") == "home", qPrintable(read(b, "notice")));
    QCOMPARE(read(b, "model"), Fprint::apple);
    screenshot(win, "home");
    const QSize normalSize = win->size();
    reset({finger, added, "left-thumb"});
    b.refresh();
    QTRY_VERIFY(b.view()["full"].toBool() && read(b, "page") == "home");
    auto doneVisible = [&] {
      auto *done = button(win->contentItem(), "Done");
      return done && done->mapToScene(QPointF(0, done->height() + 3)).y() <= win->height();
    };
    QTRY_VERIFY(doneVisible());
    win->resize(350, 360);
    QTRY_VERIFY(doneVisible());
    reset({finger});
    b.refresh();
    QTRY_VERIFY(b.view()["prints"].toList().size() == 1 && read(b, "page") == "home");
    auto *verify = button(win->contentItem(), "Verify");
    auto *done = button(win->contentItem(), "Done");
    QVERIFY(verify && done);
    verify->forceActiveFocus(Qt::TabFocusReason);
    for (int i = 0; i < 12 && !done->hasActiveFocus(); ++i)
      QTest::keyClick(win, Qt::Key_Tab);
    QVERIFY(done->hasActiveFocus());
    QTRY_VERIFY(done->mapToScene(QPointF(0, done->height())).y() <= win->height());
    for (int i = 0; i < 12 && !verify->hasActiveFocus(); ++i)
      QTest::keyClick(win, Qt::Key_Backtab);
    QVERIFY(verify->hasActiveFocus());
    QTRY_VERIFY(verify->mapToScene(QPointF()).y() >= 0);
    win->resize(normalSize);
    QFile language(config + "/language");
    QVERIFY(language.open(QIODevice::WriteOnly));
    language.write("ar"); language.close();
    QTRY_VERIFY(style.rightToLeft());
    QVERIFY(language.remove());
    QTRY_VERIFY(!style.rightToLeft());
    click("Verify");
    QTRY_COMPARE(read(b, "page"), "matched");
    screenshot(win, "match");
    win->resize(350, 360);
    auto *back = button(win->contentItem(), "Back to fingerprints");
    QVERIFY(back);
    back->forceActiveFocus(Qt::TabFocusReason);
    click("Back to fingerprints");
    QTRY_COMPARE(read(b, "page"), "home");
    QTRY_VERIFY(button(win->contentItem(), "Verify"));
    QSignalSpy frame(win, &QQuickWindow::frameSwapped);
    win->update();
    QTRY_VERIFY(!frame.isEmpty());
    QVERIFY(button(win->contentItem(), "Verify")->mapToScene(QPointF()).y() > 0);
    win->resize(normalSize);
    reset({finger}, true);
    click("Add fingerprint");
    QTRY_VERIFY(calls().contains("enroll " + added));
    screenshot(win, "enroll");
    const QDBusReply<QString> client = bus.call(QDBusMessage::createMethodCall(
        Fprint::service, "/test", "test.Fingerprint", "LastClient"));
    QVERIFY(client.isValid());
    QVERIFY(bus.interface()->isServiceRegistered(client.value()).value());
    click("Cancel");
    QTRY_COMPARE(read(b, "page"), "home");
    QTRY_VERIFY(!bus.interface()->isServiceRegistered(client.value()).value());
    reset({finger});
    click("Add fingerprint");
    QTRY_COMPARE(read(b, "page"), "added");
    QVERIFY(calls().contains("enroll stop"));
    screenshot(win, "added");
    win->resize(350, 360);
    QTRY_VERIFY(doneVisible());
    auto *input = win->activeFocusItem();
    QVERIFY(input && input->metaObject()->indexOfMethod("selectAll()") >= 0);
    QVERIFY(input->setProperty("text", "Travel"));
    auto *save = button(win->contentItem(), "Done");
    QVERIFY(save);
    save->forceActiveFocus(Qt::TabFocusReason);
    QTRY_VERIFY(save->mapToScene(QPointF(0, save->height())).y() <= win->height());
    win->resize(normalSize);
    click("Done");
    QTRY_COMPARE(read(b, "page"), "home");
    b.edit(added);
    QCOMPARE(read(b, "label"), "Travel");
    click("Remove fingerprint…");
    QCOMPARE(read(b, "page"), "confirm");
    click("Cancel");
    QTRY_COMPARE(read(b, "page"), "home");
    QVERIFY(!calls().contains("delete " + added));
    b.edit(added); b.confirmRemove(); b.remove();
    QTRY_COMPARE(read(b, "page"), "home");
    QVERIFY(calls().contains("delete " + added));
    reset({finger}, false, "verify-unknown-error");
    click("Verify");
    QTRY_COMPARE(read(b, "page"), "failed");
    QCOMPARE(read(b, "notice"), "The reader stopped before returning a verification result.");
    reset({finger}, false, "verify-no-match");
    click("Try verification again");
    QTRY_COMPARE(read(b, "page"), "failed");
    QCOMPARE(read(b, "notice"), "That finger did not match. Try a saved finger.");
    click("Back to fingerprints");
    QTRY_COMPARE(read(b, "page"), "home");
    auto toggle = [&](const QString &label) {
      std::function<QQuickItem *(QQuickItem *)> find = [&](QQuickItem *node) -> QQuickItem * {
        if (node->isVisible() && node->objectName() == label) return node;
        for (auto *child : node->childItems()) if (auto *hit = find(child)) return hit;
        return nullptr;
      };
      auto *control = find(win->contentItem());
      QVERIFY(control);
      auto *accessible = QAccessible::queryAccessibleInterface(control);
      QVERIFY(accessible);
      QCOMPARE(accessible->role(), QAccessible::Switch);
      QVERIFY(accessible->state().checkable);
      QCOMPARE(bool(accessible->state().checked), control->property("checked").toBool());
      QVERIFY(QMetaObject::invokeMethod(control, "click"));
    };
    // A mismatch cannot opt the account into either authentication path.
    QFile pam(files.lockPam);
    QVERIFY(pam.open(QIODevice::WriteOnly)); pam.close();
    b.refresh();
    QTRY_COMPARE(read(b, "page"), "home");
    toggle("Unlock with a fingerprint");
    QTRY_COMPARE(read(b, "page"), "failed");
    const auto marker = home + "/.local/state/omarchy/toggles/lock-fingerprint-off";
    QVERIFY(QFileInfo::exists(marker));
    click("Back to fingerprints");
    QTRY_COMPARE(read(b, "page"), "home");
    toggle("Use fingerprint for sudo");
    QTRY_COMPARE(read(b, "page"), "failed");
    QCOMPARE(read(b, "sudoState"), "disabled");
    reset({finger});
    QFile decline(home + "/decline");
    QVERIFY(decline.open(QIODevice::WriteOnly)); decline.close();
    click("Try verification again");
    QTRY_COMPARE(read(b, "page"), "home");
    QCOMPARE(read(b, "sudoState"), "disabled");
    QCOMPARE(read(b, "notice"), "");
    QVERIFY(decline.remove());
    toggle("Use fingerprint for sudo");
    QTRY_COMPARE(read(b, "page"), "home");
    QCOMPARE(read(b, "sudoState"), "enabled");
    QVERIFY(QFileInfo::exists(marker));
    toggle("Unlock with a fingerprint");
    QTRY_COMPARE(read(b, "page"), "home");
    QVERIFY(!QFileInfo::exists(marker));
    toggle("Unlock with a fingerprint");
    QTRY_COMPARE(read(b, "page"), "home");
    QVERIFY(QFileInfo::exists(marker));
    // Hide the fake built-in reader behind the platform consent contract.
    QFile markerFile(home + "/reader-state");
    QVERIFY(markerFile.open(QIODevice::WriteOnly));
    markerFile.write("available"); markerFile.close();
    QFile contract(files.consentContract);
    QVERIFY(contract.open(QIODevice::WriteOnly));
    contract.write((markerFile.fileName() + " available\n").toUtf8()); contract.close();
    b.refresh();
    QTRY_COMPARE(read(b, "page"), "unavailable");
    toggle("Use fingerprint for sudo");
    QTRY_COMPARE(read(b, "page"), "unavailable");
    QCOMPARE(read(b, "sudoState"), "disabled");
  }
};
QTEST_MAIN(FingerprintTest)
#include "test.moc"
