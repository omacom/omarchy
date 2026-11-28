import QtQuick
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  readonly property var idleService: bar?.shell?.firstPartyServiceFor("omarchy.idle")

  active: idleService ? idleService.stayAwake : false
  // An outline mug without a saucer. A saucer drew a line under the cup, and
  // a solid mug carries three times the ink of its neighbors, so it read
  // bigger and lower than them.
  activeText: ""
  inactiveText: ""
  activeTooltipText: I18n.t("bar.allowIdleLock")
  inactiveTooltipText: I18n.t("bar.stayAwake")

  function toggle() {
    if (root.idleService) root.idleService.setIdleEnabled(root.active)
  }

  onPressed: function() { root.toggle() }
}
