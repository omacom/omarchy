#include "ttfxlogo.h"

#include <QQuickWindow>
#include <QSGImageNode>
#include <QSGTexture>

#include <algorithm>
#include <cmath>
#include <cstring>

// Generated from native/plymouth-ttfx-plugin (#18522): the embedded logo
// (embedded-logo-v2.txt through generate-embedded-logo.py) and the 5x10 glyph
// atlas the Plymouth renderer draws every non-block symbol with.
#include "embedded-logo.h"
#include "glyph-atlas.generated.h"

namespace {

// The Plymouth renderer's boot contract.
constexpr uint32_t ENGINE_WIDTH = 162;
constexpr uint32_t ENGINE_HEIGHT = 20;
constexpr uint32_t ENGINE_FPS = 240;
constexpr uint64_t ENGINE_SEED = UINT64_C(22321466108495961);
// A reverse playback needs the forward one recorded from its first frame.
constexpr uint32_t HISTORY_FRAMES = 128;
constexpr size_t HISTORY_BYTES = size_t(4) * 1024 * 1024;
// A frame later than this (a quarter second of ticks) drops the rest rather
// than run the engine for all of it at once.
constexpr uint64_t MAX_CATCH_UP_TICKS = ENGINE_FPS / 4;
// 162 cells of 64px are an 8K screen's width: anything taller is a layout's
// mistake, not a logo.
constexpr unsigned int MAX_CELL_HEIGHT = 64;

uint32_t rgb(const QColor &color)
{
  return color.rgb() & 0xffffffu;
}

uint32_t rgbaOverRgb(uint32_t rgba, uint32_t background)
{
  const uint32_t alpha = rgba & 0xffu;
  const uint32_t inverse = 255u - alpha;
  const uint32_t red = ((((rgba >> 24) & 0xffu) * alpha) + (((background >> 16) & 0xffu) * inverse) + 127u) / 255u;
  const uint32_t green = ((((rgba >> 16) & 0xffu) * alpha) + (((background >> 8) & 0xffu) * inverse) + 127u) / 255u;
  const uint32_t blue = ((((rgba >> 8) & 0xffu) * alpha) + ((background & 0xffu) * inverse) + 127u) / 255u;
  return (red << 16) | (green << 8) | blue;
}

size_t glyphIndex(uint32_t codepoint)
{
  if (codepoint >= 33u && codepoint <= 126u)
    return codepoint - 33u;
  if (codepoint >= 174u && codepoint <= 451u)
    return 94u + (codepoint - 174u);
  if (codepoint >= 9472u && codepoint <= 9598u)
    return 372u + (codepoint - 9472u);
  if (codepoint >= 9608u && codepoint <= 9631u)
    return 499u + (codepoint - 9608u);
  return size_t('?' - 33);
}

void fillRect(uint32_t *pixels, qsizetype stride, unsigned int x, unsigned int y, unsigned int width,
              unsigned int height, uint32_t color)
{
  const uint32_t argb = 0xff000000u | color;
  for (unsigned int row = 0; row < height; row++)
    std::fill_n(pixels + qsizetype(y + row) * stride + x, width, argb);
}

bool parseSeed(const QString &text, uint64_t *seed)
{
  if (text.isEmpty() || text.size() > 20)
    return false;
  bool ok = false;
  const qulonglong value = text.toULongLong(&ok, 10);
  if (!ok || (text.size() > 1 && text.startsWith(QLatin1Char('0'))))
    return false;
  *seed = value;
  return true;
}

} // namespace

TtfxLogo::TtfxLogo(QQuickItem *parent) : QQuickItem(parent)
{
  setFlag(ItemHasContents, true);
  // The Plymouth renderer's logo at 1x: 10px cells.
  setImplicitSize(ENGINE_WIDTH * 10 * 51 / 100.0, ENGINE_HEIGHT * 10);
}

TtfxLogo::~TtfxLogo()
{
  freeEngine();
}

void TtfxLogo::setEffect(const QString &effect)
{
  if (effect == m_effect)
    return;
  m_effect = effect;
  emit effectChanged();
  if (m_completed)
    createEngine();
}

void TtfxLogo::setSeed(const QString &seed)
{
  if (seed == m_seed)
    return;
  m_seed = seed;
  emit seedChanged();
  if (m_completed)
    createEngine();
}

void TtfxLogo::setMode(Mode mode)
{
  if (mode == m_mode)
    return;
  const Mode previous = m_mode;
  m_mode = mode;
  emit modeChanged();
  if (m_engine == nullptr)
    return;
  setComplete(false);
  if (mode == Reverse) {
    beginReverse();
  } else if (previous == Reverse) {
    // ttfx_engine_reset ends the reverse playback, back at the first frame.
    if (ttfx_engine_reset(m_engine) != TTFX_STATUS_OK || !drawCalls(0)) {
      freeEngine();
      return;
    }
    startClock();
  } else {
    // Carry on from the exposed frame at the same pace.
    startClock();
  }
  scheduleFrame();
}

void TtfxLogo::setStepsPerTick(int steps)
{
  steps = std::clamp(steps, 1, 64);
  if (steps == m_stepsPerTick)
    return;
  m_stepsPerTick = steps;
  emit stepsPerTickChanged();
}

void TtfxLogo::setReverseDuration(int ms)
{
  ms = std::clamp(ms, 1, 60000);
  if (ms == m_reverseDuration)
    return;
  m_reverseDuration = ms;
  emit reverseDurationChanged();
}

void TtfxLogo::setColor(const QColor &color)
{
  if (color == m_color)
    return;
  m_color = color;
  emit colorChanged();
  m_fullRedraw = true;
  scheduleFrame();
}

void TtfxLogo::setBackground(const QColor &background)
{
  if (background == m_background)
    return;
  m_background = background;
  emit backgroundChanged();
  // The engine blends its effects towards the background it was made with.
  if (m_completed)
    createEngine();
}

void TtfxLogo::setRunning(bool running)
{
  if (running == m_running)
    return;
  m_running = running;
  emit runningChanged();
  if (running) {
    startClock();
    scheduleFrame();
  }
}

void TtfxLogo::restart()
{
  createEngine();
}

void TtfxLogo::componentComplete()
{
  QQuickItem::componentComplete();
  m_completed = true;
  createEngine();
}

void TtfxLogo::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
  QQuickItem::geometryChange(newGeometry, oldGeometry);
  if (newGeometry.size() != oldGeometry.size()) {
    m_fullRedraw = true;
    scheduleFrame();
  }
}

void TtfxLogo::itemChange(ItemChange change, const ItemChangeData &value)
{
  QQuickItem::itemChange(change, value);
  if (change == ItemSceneChange && value.window != nullptr) {
    // One engine advance per presented frame, and none while nothing moves.
    connect(value.window, &QQuickWindow::frameSwapped, this, [this] {
      if (animating())
        scheduleFrame();
    });
    m_fullRedraw = true;
    scheduleFrame();
  } else if (change == ItemDevicePixelRatioHasChanged) {
    m_fullRedraw = true;
    scheduleFrame();
  } else if (change == ItemVisibleHasChanged && value.boolValue) {
    startClock();
    scheduleFrame();
  }
}

void TtfxLogo::freeEngine()
{
  if (m_engine == nullptr)
    return;
  TtfxEngine *engine = m_engine;
  m_engine = nullptr;
  ttfx_engine_free(engine);
  emit readyChanged();
}

void TtfxLogo::createEngine()
{
  const bool wasReady = m_engine != nullptr;
  if (m_engine != nullptr) {
    ttfx_engine_free(m_engine);
    m_engine = nullptr;
  }

  uint64_t seed = ENGINE_SEED;
  if (!m_seed.isEmpty() && !parseSeed(m_seed, &seed))
    qWarning("TtfxLogo: seed \"%s\" is not a decimal 64-bit number; using the default", qPrintable(m_seed));
  const QByteArray effect = m_effect.toUtf8();
  TtfxEngine *engine = nullptr;
  if (effect.isEmpty() || effect.size() >= TTFX_MAX_EFFECT_NAME_BYTES ||
      ttfx_engine_create_with_background(effect.constData(), seed, ttfx_embedded_logo, ttfx_embedded_logo_len,
                                         ENGINE_WIDTH, ENGINE_HEIGHT, ENGINE_FPS, rgb(m_background),
                                         &engine) != TTFX_STATUS_OK ||
      engine == nullptr) {
    qWarning("TtfxLogo: cannot start the \"%s\" effect", effect.constData());
    if (engine != nullptr)
      ttfx_engine_free(engine);
    if (wasReady)
      emit readyChanged();
    update();
    return;
  }
  m_engine = engine;
  // Without a record (refused or out of memory) a reverse playback just ends
  // on the blank canvas.
  ttfx_engine_record_history(m_engine, HISTORY_FRAMES, HISTORY_BYTES);
  setComplete(false);
  if (!drawCalls(0))
    return;
  if (!wasReady)
    emit readyChanged();
  startClock();
  if (m_mode == Reverse)
    beginReverse();
  m_fullRedraw = true;
  scheduleFrame();
}

void TtfxLogo::startClock()
{
  m_clock.start();
  m_ticksDone = 0;
  m_reverseDone = 0;
}

bool TtfxLogo::beginReverse()
{
  const uint32_t maxCalls =
    std::clamp<uint32_t>(uint32_t(uint64_t(m_reverseDuration) * ENGINE_FPS / 1000), 1u, TTFX_MAX_REVERSE_CALLS);
  uint32_t calls = 0;
  if (ttfx_engine_begin_reverse(m_engine, maxCalls, 2, &calls) != TTFX_STATUS_OK || calls == 0) {
    // Nothing recorded: straight to the blank canvas.
    for (TtfxCell &cell : m_cells)
      cell = TtfxCell{0x20, 0, 0, 0};
    setComplete(true);
    return false;
  }
  m_reverseCalls = calls;
  startClock();
  return true;
}

bool TtfxLogo::drawCalls(unsigned int calls)
{
  for (unsigned int call = 0; call < calls; call++) {
    uint8_t looped = 0;
    uint8_t finished = 0;
    if (ttfx_engine_draw_logo(m_engine, uint32_t(m_mode), &looped, &finished) != TTFX_STATUS_OK) {
      qWarning("TtfxLogo: the engine stopped; the logo stays on its last frame");
      freeEngine();
      return false;
    }
    if (m_mode == Reverse)
      m_reverseDone++;
    if (finished && m_mode != Loop) {
      setComplete(true);
      break;
    }
  }

  const TtfxCell *cells = nullptr;
  size_t count = 0;
  uint32_t width = 0;
  uint32_t height = 0;
  if (ttfx_engine_cells(m_engine, &cells, &count, &width, &height) != TTFX_STATUS_OK || cells == nullptr ||
      width == 0 || height == 0 || width > TTFX_MAX_WIDTH || height > TTFX_MAX_HEIGHT ||
      count != size_t(width) * height) {
    freeEngine();
    return false;
  }
  if (width != m_columns || height != m_rows)
    m_fullRedraw = true;
  m_columns = width;
  m_rows = height;
  m_cells.assign(cells, cells + count);
  return true;
}

void TtfxLogo::setComplete(bool complete)
{
  if (complete == m_complete)
    return;
  m_complete = complete;
  emit completeChanged();
  if (complete)
    emit finished();
}

bool TtfxLogo::animating() const
{
  // Nothing on screen to move: no frames asked for until there is.
  return m_engine != nullptr && m_running && !m_complete && isVisible() && window() != nullptr &&
         width() > 0 && height() > 0;
}

void TtfxLogo::scheduleFrame()
{
  polish();
  update();
}

void TtfxLogo::updatePolish()
{
  if (animating() && m_clock.isValid()) {
    const qint64 elapsed = m_clock.nsecsElapsed();
    unsigned int calls = 0;
    if (m_mode == Reverse) {
      // The record's draws spread over the duration, as the Plymouth outro.
      const uint64_t due = std::min<uint64_t>(
        m_reverseCalls, uint64_t(std::ceil(double(elapsed) / 1e6 * m_reverseCalls / m_reverseDuration)));
      calls = due > m_reverseDone ? unsigned(due - m_reverseDone) : 0u;
    } else {
      const uint64_t target = uint64_t(elapsed) * ENGINE_FPS / 1000000000u;
      const uint64_t ticks = std::min(target - std::min(target, m_ticksDone), MAX_CATCH_UP_TICKS);
      m_ticksDone = target;
      calls = unsigned(ticks) * unsigned(m_stepsPerTick);
    }
    if (calls > 0 && !drawCalls(calls))
      return;
  }
  rasterize(m_fullRedraw);
}

void TtfxLogo::rasterize(bool full)
{
  if (m_columns == 0 || m_rows == 0 || window() == nullptr)
    return;

  // Cells as tall as fit the item, in device pixels: nothing to draw until the
  // item has a size (a layout can hand it a negative one at first).
  const qreal ratio = window()->effectiveDevicePixelRatio();
  qreal fit = width() * ratio * 100.0 / (m_columns * 51.0);
  if (height() > 0)
    fit = std::min(fit, height() * ratio / m_rows);
  if (!(fit >= 1.0))
    return;
  const unsigned int cellHeight = unsigned(std::min(fit, qreal(MAX_CELL_HEIGHT)));
  const int imageWidth = int(uint64_t(m_columns) * cellHeight * 51u / 100u);
  const int imageHeight = int(m_rows * cellHeight);
  if (cellHeight != m_cellHeight || m_image.width() != imageWidth || m_image.height() != imageHeight) {
    m_cellHeight = cellHeight;
    m_image = QImage(imageWidth, imageHeight, QImage::Format_RGB32);
    if (m_image.isNull()) {
      m_cellHeight = 0;
      return;
    }
    m_image.setDevicePixelRatio(ratio);
    full = true;
  }

  const bool sameCount = m_drawn.size() == m_cells.size();
  uint32_t *pixels = reinterpret_cast<uint32_t *>(m_image.bits());
  const qsizetype stride = m_image.bytesPerLine() / 4;
  bool changed = false;
  for (unsigned int row = 0; row < m_rows; row++) {
    for (unsigned int column = 0; column < m_columns; column++) {
      const size_t index = size_t(row) * m_columns + column;
      const TtfxCell &cell = m_cells[index];
      if (!full && sameCount && std::memcmp(&cell, &m_drawn[index], sizeof(TtfxCell)) == 0)
        continue;
      drawCell(pixels, stride, row, column, cell);
      changed = true;
    }
  }
  m_drawn = m_cells;
  m_fullRedraw = false;
  if (changed) {
    m_imageChanged = true;
    update();
  }
}

void TtfxLogo::drawCell(uint32_t *pixels, qsizetype stride, unsigned int row, unsigned int column,
                        const TtfxCell &cell)
{
  // Cumulative edges, as the Plymouth renderer: cells are 0.51 of their height
  // wide, rounded so the columns add up exactly.
  const unsigned int left = unsigned(uint64_t(column) * m_cellHeight * 51u / 100u);
  const unsigned int right = unsigned(uint64_t(column + 1) * m_cellHeight * 51u / 100u);
  const unsigned int top = row * m_cellHeight;
  const unsigned int width = right - left;
  unsigned int height = m_cellHeight;
  if (width == 0)
    return;

  const uint32_t surface = rgb(m_background);
  uint32_t background = surface;
  uint32_t foreground = rgb(m_color);
  const bool hasBackground = (cell.flags & TTFX_CELL_BG) != 0;
  bool hasForeground = (cell.flags & TTFX_CELL_FG) != 0;
  if (hasBackground)
    background = rgbaOverRgb(cell.bg_rgba, surface);
  if (hasForeground)
    foreground = rgbaOverRgb(cell.fg_rgba, background);
  if (cell.flags & TTFX_CELL_REVERSE) {
    std::swap(background, foreground);
    hasForeground = true;
  }
  fillRect(pixels, stride, left, top, width, height, background);

  if (cell.codepoint == 0x20 || cell.codepoint == 0 || !hasForeground || (cell.flags & TTFX_CELL_HIDDEN))
    return;

  // The logo's blocks keep their geometry; every other symbol is drawn from the
  // shared 5x10 glyph atlas.
  unsigned int y = top;
  const unsigned int half = height / 2;
  if (cell.codepoint == 0x2580) {
    height = half;
  } else if (cell.codepoint == 0x2584) {
    y += half;
    height -= half;
  } else if (cell.codepoint != 0x2588) {
    const uint8_t *rows = &ttfx_decrypt_glyph_atlas[glyphIndex(cell.codepoint) * TTFX_GLYPH_HEIGHT];
    for (unsigned int glyphY = 0; glyphY < TTFX_GLYPH_HEIGHT; glyphY++) {
      const uint8_t bits = rows[glyphY];
      const unsigned int runTop = glyphY * m_cellHeight / TTFX_GLYPH_HEIGHT;
      const unsigned int runBottom = (glyphY + 1) * m_cellHeight / TTFX_GLYPH_HEIGHT;
      if (runBottom <= runTop)
        continue;
      unsigned int glyphX = 0;
      while (glyphX < TTFX_GLYPH_WIDTH) {
        while (glyphX < TTFX_GLYPH_WIDTH && (bits & (1u << glyphX)) == 0)
          glyphX++;
        if (glyphX == TTFX_GLYPH_WIDTH)
          break;
        const unsigned int start = glyphX;
        while (glyphX < TTFX_GLYPH_WIDTH && (bits & (1u << glyphX)) != 0)
          glyphX++;
        const unsigned int runLeft = start * width / TTFX_GLYPH_WIDTH;
        const unsigned int runRight = glyphX * width / TTFX_GLYPH_WIDTH;
        if (runRight > runLeft)
          fillRect(pixels, stride, left + runLeft, top + runTop, runRight - runLeft, runBottom - runTop, foreground);
      }
    }
    return;
  }
  if (height > 0)
    fillRect(pixels, stride, left, y, width, height, foreground);
}

QSGNode *TtfxLogo::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *)
{
  auto *node = static_cast<QSGImageNode *>(oldNode);
  if (m_engine == nullptr || m_image.isNull()) {
    delete node;
    return nullptr;
  }
  if (node == nullptr) {
    node = window()->createImageNode();
    node->setOwnsTexture(true);
    node->setFiltering(QSGTexture::Nearest);
    m_imageChanged = true;
  }
  if (m_imageChanged) {
    node->setTexture(window()->createTextureFromImage(m_image));
    m_imageChanged = false;
  }
  // Centred in the item at its own size, on whole device pixels: one image
  // pixel per device pixel, so nothing is scaled.
  const qreal ratio = m_image.devicePixelRatio();
  const QSizeF size = m_image.deviceIndependentSize();
  const qreal x = std::round((width() - size.width()) / 2 * ratio) / ratio;
  const qreal y = std::round((height() - size.height()) / 2 * ratio) / ratio;
  node->setRect(QRectF(x, y, size.width(), size.height()));
  node->setSourceRect(QRectF(0, 0, m_image.width(), m_image.height()));
  return node;
}
