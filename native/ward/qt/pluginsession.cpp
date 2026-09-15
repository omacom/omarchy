#include "pluginsession.hpp"
#include "pluginview.hpp"
#include "rust/cxx.h"
#include <QJsonArray>
#include <QJsonDocument>

PluginSession::PluginSession(QObject *parent) : QObject(parent) {
  m_timer.setInterval(16);
  connect(&m_timer, &QTimer::timeout, this, &PluginSession::poll);
}
PluginSession::~PluginSession() { stop(); }

void PluginSession::start(const QString &store, const QString &id, const QString &controller, const QString &topology, const QString &context, const QString &runtime) {
  if (m_started) { fail("PluginSession cannot be restarted; create a new session"); return; }
  m_started = true;
  try {
    const auto root = store.toUtf8(), name = id.toUtf8(), program = controller.toUtf8(), layout = topology.toUtf8(), json = context.toUtf8(), assets = runtime.toUtf8();
    m_session.emplace(omarchy::begin_streams(root.constData(), name.constData(), program.constData(), layout.constData(), json.constData(), assets.constData()));
    trackViews(context);
    prepare(topology);
    m_timer.start();
  } catch (const rust::Error &error) { fail(QString::fromUtf8(error.what())); }
}
void PluginSession::configure(const QString &topology) {
  if (!m_session) return;
  try {
    const auto json = topology.toUtf8();
    omarchy::configure_streams(**m_session, json.constData());
    prepare(topology);
  } catch (const rust::Error &error) { fail(QString::fromUtf8(error.what())); }
}
void PluginSession::prepare(const QString &topology) {
  // Rust has validated this exact snapshot before it can reach this method.
  const auto document = QJsonDocument::fromJson(topology.toUtf8()).object();
  m_epoch = uint(document.value("generation").toInteger());
  m_allocations.clear();
  for (const auto &value : document.value("outputs").toArray()) {
    const auto allocation = value.toObject();
    m_allocations.emplace(uint(allocation.value("id").toInteger()), allocation);
  }
  for (const auto &[id, view] : m_views) {
    if (!view) continue;
    const auto allocation = m_allocations.find(id);
    if (allocation == m_allocations.end()) view->stop();
    else view->prepare(m_epoch, allocation->second);
  }
  for (auto it = m_waiting.begin(); it != m_waiting.end();) {
    if (!m_allocations.count(it->first)) it = m_waiting.erase(it);
    else ++it;
  }
}
void PluginSession::setContext(const QString &context) {
  if (!m_session) return;
  try {
    const auto json = context.toUtf8();
    omarchy::context(**m_session, json.constData());
    trackViews(context);
  } catch (const rust::Error &error) { fail(QString::fromUtf8(error.what())); }
}
void PluginSession::trackViews(const QString &context) {
  m_activeViews.clear();
  const auto document = QJsonDocument::fromJson(context.toUtf8()).object();
  for (const auto &view : document.value("views").toArray()) m_activeViews.insert(QString::number(view.toObject().value("id").toInteger()));
  bool changed = false;
  for (auto it = m_widgetSizes.begin(); it != m_widgetSizes.end();) {
    if (!m_activeViews.contains(it.key())) { it = m_widgetSizes.erase(it); changed = true; }
    else ++it;
  }
  if (changed) emit widgetSizesChanged();
}
void PluginSession::attach(PluginView *view) {
  const auto id = view->outputId();
  if (!id) return;
  const auto existing = m_views.find(id);
  if (existing != m_views.end() && existing->second && existing->second != view) { fail("Only one importer is allowed for each output stream"); return; }
  if (existing == m_views.end() && m_views.size() >= 8) { fail("Too many output views"); return; }
  m_views[id] = view;
  const auto allocation = m_allocations.find(id);
  if (allocation != m_allocations.end()) view->prepare(m_epoch, allocation->second);
  auto waiting = m_waiting.find(id);
  if (waiting != m_waiting.end()) {
    auto events = std::move(waiting->second);
    m_waiting.erase(waiting);
    for (auto &event : events) view->receive(std::move(event));
  }
}
void PluginSession::detach(PluginView *view) {
  const auto found = m_views.find(view->outputId());
  if (found != m_views.end() && found->second == view) m_views.erase(found);
}
void PluginSession::stop() {
  m_timer.stop();
  m_session.reset();
  m_waiting.clear();
  m_ready = false;
  m_desktopGeometry = false;
  m_panelOpen = false;
  m_panelSerial = 0;
  m_widgetSizes.clear();
  for (const auto &[id, view] : m_views) {
    Q_UNUSED(id);
    if (view) { view->m_error = m_error; view->stop(); }
  }
  emit stateChanged();
  emit panelChanged();
  emit widgetSizesChanged();
}
void PluginSession::fail(const QString &message) { m_error = message; stop(); }
void PluginSession::poll() {
  if (!m_session) return;
  try {
    for (int count = 0; count < 64; ++count) {
      auto event = omarchy::next(**m_session);
      if (event.kind == omarchy::EventKind::Empty) return;
      if (event.output) {
        if (event.epoch > m_epoch) { fail("Unrequested presentation epoch"); return; }
        if (!m_allocations.count(event.output)) continue;
        const auto view = m_views.find(event.output);
        if (view != m_views.end() && view->second) view->second->receive(std::move(event));
        else {
          auto &waiting = m_waiting[event.output];
          if (waiting.size() >= 6) { fail("Output view did not consume its presentation"); return; }
          waiting.push_back(std::move(event));
        }
        if (!m_session) return;
        continue;
      }
      switch (event.kind) {
        case omarchy::EventKind::Ready: m_ready = true; emit stateChanged(); break;
        case omarchy::EventKind::Observation: m_desktopGeometry = event.desktop_geometry; emit stateChanged(); break;
        case omarchy::EventKind::TopologyReady: break;
        case omarchy::EventKind::Blocked: emit operationBlocked(event.blocked_action); break;
        case omarchy::EventKind::PanelState:
          m_panelOpen = event.panel_open;
          m_panelSerial = event.panel_serial;
          emit panelChanged();
          break;
        case omarchy::EventKind::WidgetSize:
          if (!m_activeViews.contains(QString::number(event.view))) break;
          m_widgetSizes.insert(QString::number(event.view), QSize(event.width, event.height));
          emit widgetSizesChanged();
          break;
        case omarchy::EventKind::PanelSwitch:
          for (const auto &[id, view] : m_views) {
            Q_UNUSED(id);
            if (view && view->hasActiveFocus()) { view->receive(std::move(event)); break; }
          }
          break;
        case omarchy::EventKind::Failed: fail(QString::fromUtf8(event.error.data(), event.error.size())); return;
        default: fail("Unexpected shared-session event"); return;
      }
    }
  } catch (const rust::Error &error) { fail(QString::fromUtf8(error.what())); }
}
