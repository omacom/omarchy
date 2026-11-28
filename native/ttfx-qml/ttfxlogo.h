#pragma once

#include <QColor>
#include <QElapsedTimer>
#include <QImage>
#include <QQuickItem>
#include <QString>

#include <cstdint>
#include <vector>

#include "ttfx_plymouth.h"

// The Omarchy wordmark played by the TTFX engine (native/plymouth-ttfx-engine),
// drawn on the CPU into one image the size of the logo, so it runs on Qt
// Quick's software backend. The engine advances at a fixed 240 ticks per
// second, two draws per tick, whatever the display's refresh: a frame shows
// the latest state, and a slow frame catches up instead of slowing the
// animation down. Nothing runs once a one-time or reverse playback ends.
class TtfxLogo : public QQuickItem {
  Q_OBJECT
  QML_ELEMENT

  // A TTFX effect name (effects.txt); "decrypt" by default.
  Q_PROPERTY(QString effect READ effect WRITE setEffect NOTIFY effectChanged)
  // A decimal unsigned 64-bit seed; empty for the boot splash's default.
  Q_PROPERTY(QString seed READ seed WRITE setSeed NOTIFY seedChanged)
  Q_PROPERTY(Mode mode READ mode WRITE setMode NOTIFY modeChanged)
  // Engine draws per tick: 2 is the boot contract; more speeds a one-time
  // playback towards its end, as Plymouth did once the password was in.
  Q_PROPERTY(int stepsPerTick READ stepsPerTick WRITE setStepsPerTick NOTIFY stepsPerTickChanged)
  // How long a reverse playback takes, in ms.
  Q_PROPERTY(int reverseDuration READ reverseDuration WRITE setReverseDuration NOTIFY reverseDurationChanged)
  // The colour of cells the effect leaves uncoloured: the logo's.
  Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
  // What the logo is drawn over; the engine blends towards it.
  Q_PROPERTY(QColor background READ background WRITE setBackground NOTIFY backgroundChanged)
  Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)
  // The engine started: false for an unknown effect, so the caller can fall
  // back to a static logo.
  Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
  // A one-time playback holds its last frame, or a reverse one shows the blank
  // canvas.
  Q_PROPERTY(bool complete READ complete NOTIFY completeChanged)

public:
  enum Mode { Loop = TTFX_LOGO_MODE_LOOP, OneTime = TTFX_LOGO_MODE_ONE_TIME, Reverse = TTFX_LOGO_MODE_REVERSE };
  Q_ENUM(Mode)

  explicit TtfxLogo(QQuickItem *parent = nullptr);
  ~TtfxLogo() override;

  QString effect() const { return m_effect; }
  void setEffect(const QString &effect);
  QString seed() const { return m_seed; }
  void setSeed(const QString &seed);
  Mode mode() const { return m_mode; }
  void setMode(Mode mode);
  int stepsPerTick() const { return m_stepsPerTick; }
  void setStepsPerTick(int steps);
  int reverseDuration() const { return m_reverseDuration; }
  void setReverseDuration(int ms);
  QColor color() const { return m_color; }
  void setColor(const QColor &color);
  QColor background() const { return m_background; }
  void setBackground(const QColor &background);
  bool running() const { return m_running; }
  void setRunning(bool running);
  bool ready() const { return m_engine != nullptr; }
  bool complete() const { return m_complete; }

  // Back to the effect's first frame, in the current mode.
  Q_INVOKABLE void restart();

signals:
  void effectChanged();
  void seedChanged();
  void modeChanged();
  void stepsPerTickChanged();
  void reverseDurationChanged();
  void colorChanged();
  void backgroundChanged();
  void runningChanged();
  void readyChanged();
  void completeChanged();
  // A one-time playback reached its last frame, or a reverse one the blank
  // canvas.
  void finished();

protected:
  void componentComplete() override;
  void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
  void itemChange(ItemChange change, const ItemChangeData &value) override;
  void updatePolish() override;
  QSGNode *updatePaintNode(QSGNode *node, UpdatePaintNodeData *data) override;

private:
  void createEngine();
  void freeEngine();
  void startClock();
  bool beginReverse();
  bool drawCalls(unsigned int calls);
  void setComplete(bool complete);
  void scheduleFrame();
  bool animating() const;
  void rasterize(bool full);
  void drawCell(uint32_t *pixels, qsizetype stride, unsigned int row, unsigned int column, const TtfxCell &cell);

  TtfxEngine *m_engine = nullptr;
  QString m_effect = QStringLiteral("decrypt");
  QString m_seed;
  Mode m_mode = Loop;
  int m_stepsPerTick = 2;
  int m_reverseDuration = 700;
  QColor m_color = QColor(0xf4, 0xf4, 0xf5);
  QColor m_background = QColor(0x1a, 0x1b, 0x26);
  bool m_running = true;
  bool m_complete = false;
  bool m_completed = false; // componentComplete ran

  QElapsedTimer m_clock;
  uint64_t m_ticksDone = 0;
  uint32_t m_reverseCalls = 0;
  uint32_t m_reverseDone = 0;

  // The engine's last frame, copied: what the image shows.
  std::vector<TtfxCell> m_cells;
  std::vector<TtfxCell> m_drawn;
  uint32_t m_columns = 0;
  uint32_t m_rows = 0;
  unsigned int m_cellHeight = 0;
  QImage m_image;
  bool m_imageChanged = false;
  bool m_fullRedraw = true;
};
