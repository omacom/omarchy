// Runs smoke.qml on Qt Quick's software backend: the decrypt logo must start,
// draw, reach its end, hold its last frame without asking for more frames,
// and an unknown effect must not start.
// Usage: ttfx-qml-smoke <qml import dir> <smoke.qml> [screenshot.png]

#include <QElapsedTimer>
#include <QEventLoop>
#include <QGuiApplication>
#include <QImage>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTimer>
#include <QUrl>

#include <cstdio>

int main(int argc, char **argv)
{
  if (argc < 3)
    return 2;
  QQuickWindow::setGraphicsApi(QSGRendererInterface::Software);
  QGuiApplication app(argc, argv);
  QQmlApplicationEngine engine;
  engine.addImportPath(QString::fromLocal8Bit(argv[1]));
  engine.load(QUrl::fromLocalFile(QString::fromLocal8Bit(argv[2])));
  auto *window = engine.rootObjects().isEmpty() ? nullptr : qobject_cast<QQuickWindow *>(engine.rootObjects().first());
  QObject *logo = window ? window->findChild<QObject *>("logo") : nullptr;
  QObject *unknown = window ? window->findChild<QObject *>("unknown") : nullptr;
  if (!logo || !unknown) {
    std::fprintf(stderr, "smoke: scene did not load\n");
    return 1;
  }

  int frames = 0;
  QObject::connect(window, &QQuickWindow::frameSwapped, [&] { frames++; });
  QElapsedTimer clock;
  clock.start();
  QEventLoop loop;
  QObject::connect(logo, SIGNAL(finished()), &loop, SLOT(quit()));
  QTimer::singleShot(30000, &loop, &QEventLoop::quit);
  if (!logo->property("complete").toBool())
    loop.exec();
  const qint64 playMs = clock.elapsed();
  const int playFrames = frames;

  // Once complete, the item asks for no more frames.
  QTimer::singleShot(500, &loop, &QEventLoop::quit);
  loop.exec();
  const int idleFrames = frames - playFrames;

  const QImage image = window->grabWindow();
  const QRgb empty = image.pixel(0, 0);
  int lit = 0;
  for (int y = 0; y < image.height(); y += 3)
    for (int x = 0; x < image.width(); x += 3)
      lit += image.pixel(x, y) != empty;
  if (argc > 3)
    image.save(QString::fromLocal8Bit(argv[3]));

  const bool ok = logo->property("ready").toBool() && logo->property("complete").toBool() &&
                  !unknown->property("ready").toBool() && lit > 100 && idleFrames < 5;
  std::printf("ready=%d complete=%d unknownReady=%d playMs=%lld playFrames=%d idleFrames=%d litSamples=%d\n",
              logo->property("ready").toBool(), logo->property("complete").toBool(),
              unknown->property("ready").toBool(), static_cast<long long>(playMs), playFrames, idleFrames, lit);
  return ok ? 0 : 1;
}
