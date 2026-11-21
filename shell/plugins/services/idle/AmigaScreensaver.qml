import QtQuick
import qs.Commons

// Optional native dependency is loaded only on demand, never at shell startup.
Item {
  id: root
  signal opened(string owner)
  signal closed(string owner)
  readonly property bool open: !!(guard.item && guard.item.active)
  property string runtimeSource: "file:///usr/lib/omarchy-amiga-runtime/guard/Guard.qml"
  function configure(source) {
    if (guard.item && guard.item.active) return "busy"
    guard.active = false
    runtimeSource = source
    return "ok"
  }
  function begin(owner, monitor) {
    if (guard.status === Loader.Error) guard.active = false
    if (!guard.item) { guard.active = true; return "preparing" }
    return guard.item.begin(owner, monitor)
  }
  function poll(owner) { return guard.item ? guard.item.poll(owner) : "closed" }
  function present(owner, monitor, appId, title) { return guard.item ? guard.item.present(owner, monitor, appId, title) : "closed" }
  function commit(owner) { return guard.item ? guard.item.commit(owner) : "closed" }
  function direct(owner) { return guard.item ? guard.item.direct(owner) : "closed" }
  function audioApplied(owner, revision, muted) { return guard.item ? guard.item.audioApplied(owner, revision, muted) : "closed" }
  function cover(owner) { return guard.item ? guard.item.cover(owner) : "closed" }
  function dismiss() { if (guard.item) guard.item.dismiss("locked") }
  function end(owner) { return guard.item ? guard.item.end(owner) : "closed" }
  Loader {
    id: guard
    active: false
    source: root.runtimeSource
  }
  // Bound, not copied, so an open guard follows a language switch.
  Binding { target: guard.item; property: "hintOn"; value: I18n.t("screensaver.amigaAudioOn"); when: !!guard.item }
  Binding { target: guard.item; property: "hintOff"; value: I18n.t("screensaver.amigaAudioOff"); when: !!guard.item }
  Connections {
    target: guard.item
    function onOpened(owner) { root.opened(owner) }
    function onClosed(owner) { root.closed(owner); guard.active = false }
  }
}
