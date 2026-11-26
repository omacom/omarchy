#include "backend.h"
#include <QDBusReply>
#include <QDBusConnectionInterface>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QWindow>

class Activation : public QObject {
  Q_OBJECT
  Q_CLASSINFO("D-Bus Interface", "org.freedesktop.Application")
public:
  QWindow *window = nullptr;
public slots:
  void Activate(const QVariantMap &platformData) {
    if (!window) return;
    const auto token = platformData.value("activation-token").toString().toUtf8();
    const bool forward = !token.isEmpty() && QGuiApplication::platformName().startsWith("wayland");
    window->show();
    if (forward) qputenv("XDG_ACTIVATION_TOKEN", token);
    if (!QGuiApplication::platformName().startsWith("wayland")) window->raise();
    window->requestActivate();
    if (forward) qunsetenv("XDG_ACTIVATION_TOKEN");
  }
};

int main(int argc, char **argv) {
  QGuiApplication app(argc, argv);
  const QString id = "org.omarchy.FingerprintSetup";
  app.setApplicationName("Fingerprint Setup");
  app.setDesktopFileName(id);
  auto session = QDBusConnection::sessionBus();
  Activation activation;
  const QString path = "/org/omarchy/FingerprintSetup";
  session.registerObject(path, &activation, QDBusConnection::ExportAllSlots);
  if (session.isConnected() && !session.registerService(id)) {
    if (session.interface()->isServiceRegistered(id).value()) {
      auto activate = QDBusMessage::createMethodCall(id, path, "org.freedesktop.Application", "Activate");
      QVariantMap platformData;
      for (const auto &[key, env] : {std::pair{"activation-token", "XDG_ACTIVATION_TOKEN"},
                                     std::pair{"desktop-startup-id", "DESKTOP_STARTUP_ID"}}) {
        const auto value = qEnvironmentVariable(env);
        if (!value.isEmpty()) platformData.insert(key, value);
      }
      activate << platformData;
      QDBusReply<void> reply(session.call(activate, QDBus::Block, 2000));
      if (!reply.isValid()) qWarning() << reply.error().message();
      return reply.isValid() ? 0 : 1;
    }
  }
  QQuickStyle::setStyle("Basic");
  Appearance appearance;
  Backend backend(appearance);
  QQmlApplicationEngine engine;
  engine.setInitialProperties({{"backend", QVariant::fromValue(&backend)}, {"appearance", QVariant::fromValue(&appearance)}});
  engine.load(QUrl("qrc:/Main.qml"));
  if (engine.rootObjects().isEmpty()) return 1;
  activation.window = qobject_cast<QWindow *>(engine.rootObjects().first());
  return app.exec();
}

#include "main.moc"
