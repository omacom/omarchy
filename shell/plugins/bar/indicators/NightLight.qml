import QtQuick
import qs.Ui

BarIndicator {
  id: root

  readonly property var nightlightService: bar?.shell?.firstPartyServiceFor("omarchy.nightlight")

  active: nightlightService ? nightlightService.enabled : false
  activeText: "󰔎"
  inactiveText: "󰔎"
  activeTooltipText: "Day Light"
  inactiveTooltipText: "Night Light"

  // The service re-reads the screen before choosing a direction, so a click
  // after the schedule switched profiles still does the opposite of what is
  // on screen.
  function toggle() {
    if (root.nightlightService) root.nightlightService.toggle()
  }

  onPressed: function() { root.toggle() }
}
