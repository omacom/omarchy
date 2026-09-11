#include <QCoreApplication>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusObjectPath>
#include <QDBusVariant>
#include <QDBusVirtualObject>
#include <QTimer>
#include <QVariantMap>

// Test-only player on an explicitly supplied private bus. No GUI, files, media
// playback, URI opening, or host operations are performed by any method.
class Player : public QDBusVirtualObject {
public:
  QString introspect(const QString &) const override {
    return QStringLiteral("<interface name=\"org.mpris.MediaPlayer2.Player\">"
      "<method name=\"PlayPause\"/><property name=\"PlaybackStatus\" type=\"s\" access=\"read\"/>"
      "</interface>");
  }
  bool handleMessage(const QDBusMessage &message, const QDBusConnection &bus) override {
    const QString player = QStringLiteral("org.mpris.MediaPlayer2.Player");
    const auto args = message.arguments();
    QVariantMap metadata{{"xesam:title", track == 0 ? QStringLiteral("Sandbox track") : QStringLiteral("Sandbox track %1").arg(track)},
      {"xesam:artist", QStringList{"Test artist"}}, {"xesam:album", "Private test album"}, {"mpris:artUrl", "file:///plugin/cover.svg"},
      {"mpris:trackid", QVariant::fromValue(QDBusObjectPath("/track/test"))}, {"mpris:length", qint64(120000000)}};
    QVariantMap properties{{"PlaybackStatus", status}, {"Metadata", metadata},
      {"CanControl", true}, {"CanPlay", true}, {"CanPause", true}, {"CanGoNext", true}, {"CanGoPrevious", true},
      {"CanSeek", true}, {"Rate", 1.0}, {"MinimumRate", 1.0}, {"MaximumRate", 1.0},
      {"Volume", 1.0}, {"Position", qint64(0)}, {"Shuffle", false}, {"LoopStatus", "None"}};
    if (message.interface() == "org.freedesktop.DBus.Properties" && !args.isEmpty()) {
      if (args[0].toString() != player) properties = {{"Identity", "Private test player"}, {"DesktopEntry", "test"}, {"CanRaise", false}, {"CanQuit", false}, {"HasTrackList", false}};
      if (message.member() == "GetAll") return bus.send(message.createReply(QVariantList{properties}));
      if (message.member() == "Get" && args.size() == 2)
        return bus.send(message.createReply(QVariantList{QVariant::fromValue(QDBusVariant(properties.value(args[1].toString())))}));
    }
    if (message.interface() == player && QStringList{"PlayPause", "Play", "Pause", "Stop"}.contains(message.member())) {
      if (message.member() == "PlayPause") status = status == "Playing" ? "Paused" : "Playing";
      else if (message.member() == "Play") status = "Playing";
      else status = message.member() == "Stop" ? "Stopped" : "Paused";
      auto signal = QDBusMessage::createSignal("/org/mpris/MediaPlayer2", "org.freedesktop.DBus.Properties", "PropertiesChanged");
      signal.setArguments({player, QVariantMap{{"PlaybackStatus", status}}, QStringList{}});
      bus.send(signal);
    }
    if (message.interface() == player && QStringList{"Next", "Previous"}.contains(message.member())) {
      track += message.member() == "Next" ? 1 : -1;
      metadata["xesam:title"] = track == 0 ? QStringLiteral("Sandbox track") : QStringLiteral("Sandbox track %1").arg(track);
      auto signal = QDBusMessage::createSignal("/org/mpris/MediaPlayer2", "org.freedesktop.DBus.Properties", "PropertiesChanged");
      signal.setArguments({player, QVariantMap{{"Metadata", metadata}}, QStringList{}});
      bus.send(signal);
    }
    // Even forbidden methods return success here, so test denial must come from
    // the proxy, not from a service-side UnknownMethod or signature rejection.
    return bus.send(message.createReply());
  }
private:
  QString status = "Paused";
  int track = 0;
};

int main(int argc, char **argv) {
  QCoreApplication app(argc, argv);
  if (argc < 2 || !qgetenv("DBUS_SESSION_BUS_ADDRESS").startsWith("unix:path=/")) return 1;
  auto bus = QDBusConnection::sessionBus();
  Player player;
  if (!bus.isConnected() || !bus.registerService(QString::fromLocal8Bit(argv[1]))
      || !bus.registerVirtualObject("/org/mpris/MediaPlayer2", &player)) return 2;
  if (argc > 2 && !bus.registerService(QString::fromLocal8Bit(argv[2]))) return 3;
  QTimer::singleShot(30000, &app, &QCoreApplication::quit);
  return app.exec();
}
