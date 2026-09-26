import QtQuick
import Quickshell.Wayland
import "IdleModel.js" as IdleModel

// Owns the ext-idle-notify subscription. The service stays subscribed while
// stay-awake is on; this object only decides when that subscription exists.
QtObject {
  id: host

  property bool ready: false
  property real timeoutSeconds: 0
  property bool respectInhibitors: true
  property bool isIdle: false
  property bool subscribed: false
  property real subscribedTimeout: -1

  signal idleChanged()

  property var monitor: null
  property real armedTimeout: -1

  function publish() {
    var enabled = host.monitor !== null && !!host.monitor.enabled
    host.subscribed = enabled
    host.subscribedTimeout = enabled ? host.monitor.timeout : -1
  }

  function noteIdle(source) {
    host.publish()
    if (source !== host.monitor || !host.monitor) return
    var idle = !!host.monitor.isIdle
    if (host.isIdle === idle) return
    host.isIdle = idle
    host.idleChanged()
  }

  function applySubscription() {
    var live = host.monitor !== null && !!host.monitor.enabled
    var plan = IdleModel.monitorSubscription(host.ready, host.timeoutSeconds, live, host.armedTimeout)
    if (!plan.recreate) return
    host.armedTimeout = plan.timeout
    if (!host.monitor) {
      if (!plan.live) return
      Qt.callLater(host.arm)
      return
    }
    host.retarget()
  }

  function arm() {
    if (host.monitor) {
      host.retarget()
      return
    }
    if (!host.ready) return
    // The timeout has to be the initial value. Writing it later makes
    // Quickshell replace the notification, and a reused address drops idled.
    host.monitor = monitorComponent.createObject(host, {
      timeout: host.timeoutSeconds,
      respectInhibitors: host.respectInhibitors,
      enabled: true
    })
    host.armedTimeout = host.timeoutSeconds
    host.publish()
    host.noteIdle(host.monitor)
  }

  function retarget() {
    if (!host.monitor) return
    var timeout = host.timeoutSeconds
    var enable = host.ready
    if (!!host.monitor.enabled === enable && host.monitor.timeout === timeout) {
      host.armedTimeout = timeout
      host.noteIdle(host.monitor)
      return
    }
    // Drop the notification before changing timeout, then subscribe again.
    // An in-place timeout write can reuse the native address and stop
    // delivering idled; disabling first forces the null-to-object transition.
    host.monitor.enabled = false
    host.monitor.timeout = timeout
    host.armedTimeout = timeout
    host.monitor.enabled = enable
    host.publish()
    host.noteIdle(host.monitor)
  }

  onReadyChanged: host.applySubscription()
  onTimeoutSecondsChanged: host.applySubscription()
  Component.onCompleted: host.applySubscription()

  property Component monitorComponent: Component {
    IdleMonitor {
      onIsIdleChanged: host.noteIdle(this)
    }
  }
}
