#pragma once
#include "omarchy-ward/src/qt.rs.h"
#include "pluginsession.hpp"
#include <QElapsedTimer>
#include <QQuickItem>
#include <QRegion>
#include <QTimer>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>
#include <array>
#include <optional>

// Trusted host component: never load this module into the plugin worker.
class PluginView : public QQuickItem {
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(PluginSession *session READ session WRITE setSession NOTIFY sessionChanged)
  Q_PROPERTY(uint outputId READ outputId WRITE setOutputId NOTIFY sessionChanged)
  Q_PROPERTY(QVariantList renderRegions READ renderRegions WRITE setRenderRegions NOTIFY renderRegionsChanged)
  Q_PROPERTY(QVariantList hostInputRegions READ hostInputRegions WRITE setHostInputRegions NOTIFY hostInputRegionsChanged)
  Q_PROPERTY(bool ready READ ready NOTIFY stateChanged)
  Q_PROPERTY(bool resizing READ resizing NOTIFY stateChanged)
  Q_PROPERTY(bool presented READ presented NOTIFY stateChanged)
  Q_PROPERTY(QString error READ error NOTIFY stateChanged)
  Q_PROPERTY(QVariantList inputRegions READ inputRegions NOTIFY stateChanged)
  Q_PROPERTY(bool panelOpen READ panelOpen NOTIFY panelChanged)
  Q_PROPERTY(uint panelSerial READ panelSerial NOTIFY panelChanged)
  Q_PROPERTY(QSize widgetSize READ widgetSize NOTIFY widgetSizeChanged)
public:
  explicit PluginView(QQuickItem *parent = nullptr);
  ~PluginView() override;
  PluginSession *session() const { return m_hostSession; }
  void setSession(PluginSession *session);
  uint outputId() const { return m_outputId; }
  void setOutputId(uint output);
  QVariantList renderRegions() const { return m_renderRegions; }
  void setRenderRegions(const QVariantList &regions);
  QVariantList hostInputRegions() const { return m_hostInputRegions; }
  void setHostInputRegions(const QVariantList &regions);
  bool ready() const { return m_ready; }
  bool resizing() const { return m_resizing; }
  bool presented() const { return m_presented; }
  QString error() const { return m_error; }
  bool panelOpen() const { return m_panelOpen; }
  uint panelSerial() const { return m_panelSerial; }
  QSize widgetSize() const { return m_widgetSize; }
  QVariantList inputRegions() const;
  bool contains(const QPointF &) const override;
  Q_INVOKABLE void start(const QString &store, const QString &id, const QString &controller,
    int logicalWidth, int logicalHeight, int scale = 1, const QString &context = QString());
  Q_INVOKABLE void setContext(const QString &context);
  Q_INVOKABLE void stop();
  Q_INVOKABLE void configure(int logicalWidth, int logicalHeight, int scale = 1);
  Q_INVOKABLE void dismiss();
  void acknowledge(quint64 serial, quint64 generation);
  void fail(const QString &message);
signals:
  void sessionChanged();
  void renderRegionsChanged();
  void hostInputRegionsChanged();
  void stateChanged();
  void panelChanged();
  void widgetSizeChanged();
  void focusRequested(QPointF point);
  void panelSwitchRequested(int direction);
protected:
  QSGNode *updatePaintNode(QSGNode *, UpdatePaintNodeData *) override;
  void mousePressEvent(QMouseEvent *) override;
  void mouseReleaseEvent(QMouseEvent *) override;
  void mouseMoveEvent(QMouseEvent *) override;
  void hoverEnterEvent(QHoverEvent *) override;
  void hoverMoveEvent(QHoverEvent *) override;
  void hoverLeaveEvent(QHoverEvent *) override;
  void wheelEvent(QWheelEvent *) override;
  void keyPressEvent(QKeyEvent *) override;
  void keyReleaseEvent(QKeyEvent *) override;
  void focusOutEvent(QFocusEvent *) override;
private:
  friend class PluginSession;
  void receive(omarchy::NativeEvent event);
  void prepare(uint epoch, const QJsonObject &allocation);
  const omarchy::Session *connection() const;
  void poll();
  void input(uint32_t kind, uint32_t code, QPointF point = {});
  void key(QKeyEvent *event, bool pressed);
  std::optional<rust::Box<omarchy::Session>> m_session;
  QPointer<PluginSession> m_hostSession;
  uint m_outputId = 0;
  uint m_epoch = 0;
  uint m_requestedEpoch = 0;
  std::array<std::optional<rust::Box<omarchy::NativeBuffer>>, 2> m_buffers;
  QTimer m_timer;
  QElapsedTimer m_panelSwitchAge;
  int m_panelSwitchDirection = 0;
  QSize m_viewport;
  QSize m_widgetSize = QSize(0, 0);
  QSize m_requestedViewport;
  int m_scale = 1;
  int m_requestedScale = 1;
  QRegion m_mask;
  QRegion m_renderMask;
  QRegion m_hostInputMask;
  QVariantList m_hostInputRegions;
  QPointF m_lastPointer;
  bool m_hasHostInputRegions = false;
  QVariantList m_renderRegions;
  bool m_hasRenderRegions = false;
  QString m_error;
  bool m_started = false;
  bool m_panelOpen = false;
  uint m_panelSerial = 0;
  bool m_ready = false;
  bool m_hasSurface = false;
  bool m_presented = false;
  bool m_resizing = true;
  int m_pending = -1;
  int m_current = -1;
  quint64 m_serial = 0;
  quint64 m_generation = 0;
  quint64 m_requestedAfter = 0;
};
