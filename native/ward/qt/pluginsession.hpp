#pragma once
#include "omarchy-ward/src/qt.rs.h"
#include <QObject>
#include <QPointer>
#include <QTimer>
#include <QJsonObject>
#include <QVariantMap>
#include <QSet>
#include <QtQml/qqmlregistration.h>
#include <map>
#include <optional>
#include <vector>

class PluginView;

// One logical plugin/session, with at most one independent importer per output.
class PluginSession : public QObject {
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(bool ready READ ready NOTIFY stateChanged)
  Q_PROPERTY(bool desktopGeometry READ desktopGeometry NOTIFY stateChanged)
  Q_PROPERTY(QString error READ error NOTIFY stateChanged)
  Q_PROPERTY(bool panelOpen READ panelOpen NOTIFY panelChanged)
  Q_PROPERTY(uint panelSerial READ panelSerial NOTIFY panelChanged)
  Q_PROPERTY(QVariantMap widgetSizes READ widgetSizes NOTIFY widgetSizesChanged)
public:
  explicit PluginSession(QObject *parent = nullptr);
  ~PluginSession() override;
  bool ready() const { return m_ready; }
  bool desktopGeometry() const { return m_desktopGeometry; }
  QString error() const { return m_error; }
  bool panelOpen() const { return m_panelOpen; }
  uint panelSerial() const { return m_panelSerial; }
  QVariantMap widgetSizes() const { return m_widgetSizes; }
  Q_INVOKABLE void start(const QString &store, const QString &id, const QString &controller, const QString &topology, const QString &context, const QString &runtime = QString());
  Q_INVOKABLE void configure(const QString &topology);
  Q_INVOKABLE void setContext(const QString &context);
  Q_INVOKABLE void stop();
  void fail(const QString &message);
  void attach(PluginView *view);
  void detach(PluginView *view);
  const omarchy::Session *connection() const { return m_session ? &**m_session : nullptr; }
signals:
  void stateChanged();
  void panelChanged();
  void widgetSizesChanged();
  void operationBlocked(uint action);
private:
  void poll();
  void prepare(const QString &topology);
  void trackViews(const QString &context);
  std::optional<rust::Box<omarchy::Session>> m_session;
  std::map<uint, QPointer<PluginView>> m_views;
  std::map<uint, QJsonObject> m_allocations;
  std::map<uint, std::vector<omarchy::NativeEvent>> m_waiting;
  QTimer m_timer;
  QString m_error;
  QVariantMap m_widgetSizes;
  QSet<QString> m_activeViews;
  uint m_epoch = 0;
  uint m_panelSerial = 0;
  bool m_panelOpen = false;
  bool m_ready = false;
  bool m_desktopGeometry = false;
  bool m_started = false;
};
