import QtQuick
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  readonly property var idleService: bar?.shell?.firstPartyServiceFor("omarchy.idle")
  readonly property string stayMode: idleService && idleService.stayAwakeMode ? String(idleService.stayAwakeMode) : "allow"
  readonly property bool agentsMode: stayMode === "agents"
  readonly property bool agentsHolding: agentsMode && idleService ? idleService.agentsWorking === true : false

  active: agentsMode || (idleService ? idleService.stayAwake : false)
  activeText: "󰅶"
  inactiveText: "󰅶"
  activeTooltipText: agentsMode ? "Allow Idle Lock & Screensaver" : "Stay Awake While Agents Work"
  inactiveTooltipText: agentsMode ? "Allow Idle Lock & Screensaver" : "Stay Awake"
  iconComponent: agentsMode ? agentsIcon : null

  function toggle() {
    if (root.idleService && typeof root.idleService.cycleStayAwakeMode === "function") root.idleService.cycleStayAwakeMode()
    else if (root.idleService) root.idleService.setIdleEnabled(root.active)
  }

  onPressed: function() { root.toggle() }

  // Coffee cup with a loading spinner superimposed in the bottom right: the
  // "stay awake while agents work" mode. The cup reuses the indicator glyph,
  // drawn into a canvas so the badge area can be knocked out to transparent
  // negative space; the monochrome spinner ring then floats clear of it.
  Component {
    id: agentsIcon
    Item {
      // Badge geometry, shared by the knockout below and the badge item:
      // small, and nudged up and right from the corner.
      readonly property real badgeSizeFrac: 0.38
      readonly property real badgeCX: 0.875
      readonly property real badgeCY: 0.6875
      Canvas {
        id: cupLayer
        anchors.fill: parent
        onPaint: {
          var ctx = getContext("2d")
          ctx.clearRect(0, 0, width, height)
          var s = Math.round(parent.height * 0.66)
          ctx.font = s + "px '" + root.fontFamily + "'"
          ctx.textAlign = "center"
          ctx.textBaseline = "middle"
          ctx.fillStyle = root.foreground
          ctx.fillText(root.activeText, width / 2, height / 2)
          var bw = width * badgeSizeFrac
          ctx.save()
          ctx.globalCompositeOperation = "destination-out"
          ctx.beginPath()
          ctx.arc(width * badgeCX, height * badgeCY, bw / 2 + 1, 0, Math.PI * 2)
          ctx.fill()
          ctx.restore()
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
      }
      Item {
        id: badge
        width: Math.round(parent.width * badgeSizeFrac)
        height: Math.round(parent.height * badgeSizeFrac)
        x: parent.width * badgeCX - width / 2
        y: parent.height * badgeCY - height / 2

        Canvas {
          id: spinner
          anchors.fill: parent
          onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var d = Math.min(width, height)
            ctx.lineWidth = Math.max(1.5, d * 0.2)
            ctx.lineCap = "round"
            ctx.strokeStyle = root.foreground
            ctx.beginPath()
            ctx.arc(width / 2, height / 2, d / 2 - ctx.lineWidth / 2, -Math.PI / 2, Math.PI * 0.75)
            ctx.stroke()
          }
          onWidthChanged: requestPaint()
          onHeightChanged: requestPaint()
        }

        RotationAnimation on rotation {
          from: 0
          to: 360
          duration: 1200
          loops: Animation.Infinite
          running: root.agentsHolding && !Style.reduceMotion
        }

        Connections {
          target: root
          function onForegroundChanged() { spinner.requestPaint(); cupLayer.requestPaint() }
        }
      }
    }
  }
}
