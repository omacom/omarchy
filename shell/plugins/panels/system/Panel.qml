import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model

// Memory by what holds it (each local model by name, apps, cache, free), CPU
// load over the last minute and per core, and space on each disk. None of it
// has a change signal, so it's read only while the panel is open: the /proc
// files every second, df and the models' memory every five.
Panel {
  id: root
  moduleName: "omarchy.system"
  ipcTarget: "omarchy.system"

  readonly property color foreground: bar ? bar.foreground : Commons.Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.4)
  readonly property color track: Style.selectedFillFor(foreground, Commons.Color.accent)
  readonly property color urgent: bar ? bar.urgent : Commons.Color.urgent
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string icon: "󰍛"

  // ---------------------------------------------------------------- memory

  // The local models service knows which models run and what each holds.
  readonly property var localModels: bar && bar.shell ? bar.shell.firstPartyServiceFor("omarchy.local-models") : null
  property var meminfo: null
  readonly property var memory: Model.memoryBreakdown(meminfo, Model.runningModels(
    localModels ? (localModels.localModel || {}).models : null,
    localModels ? localModels.modelMemory : null))
  // The slice under the pointer, in the bar or its legend; the rest dim.
  property int hoveredSegment: -1
  // The repeaters count slices rather than take the list, so a fresh reading
  // every second updates them in place instead of rebuilding them.
  readonly property var noSegment: ({ kind: "free", gib: 0 })

  function segmentLabel(segment) {
    if (segment.kind === "model") return segment.name
    if (segment.kind === "apps") return Commons.I18n.t("system.apps")
    if (segment.kind === "cache") return Commons.I18n.t("system.cache")
    return Commons.I18n.t("system.free")
  }

  function segmentColor(kind) {
    if (kind === "model") return Commons.Color.accent
    if (kind === "apps") return root.foreground
    if (kind === "cache") return Util.alpha(root.foreground, 0.35)
    return "transparent"
  }

  readonly property real swapUsed: meminfo ? Math.max(0, (meminfo.SwapTotal || 0) - (meminfo.SwapFree || 0)) / (1024 * 1024) : 0

  // ------------------------------------------------------------------- cpu

  readonly property int historyLength: 60
  property var cpuStat: []
  // Busy fraction of the whole CPU first, then of each core.
  property var cpuNow: []
  property var cpuHistory: []
  readonly property var coreUsage: cpuNow.slice(1)
  property var loadAverage: []
  property real uptimeSeconds: 0

  function takeCpu(raw) {
    var next = Model.parseCpuStat(raw)
    if (cpuStat.length > 0) {
      cpuNow = Model.cpuUsage(cpuStat, next)
      cpuHistory = cpuHistory.concat([cpuNow[0]]).slice(-historyLength)
    }
    cpuStat = next
  }

  // ------------------------------------------------------------------ disk

  property var disks: []

  // ---------------------------------------------------------------- format

  function size(gib) { return Model.formatSize(gib, Commons.I18n.formatNumber, Commons.I18n.t) }
  function percent(fraction) { return Commons.I18n.t("system.percent").arg(Commons.I18n.formatNumber(Math.round(fraction * 100))) }

  function uptimeText() {
    var minutes = Math.floor(uptimeSeconds / 60)
    var f = Commons.I18n.formatNumber
    var duration = minutes >= 1440
      ? Commons.I18n.t("system.uptimeDays").arg(f(Math.floor(minutes / 1440))).arg(f(Math.floor(minutes % 1440 / 60)))
      : Commons.I18n.t("system.uptimeHours").arg(f(Math.floor(minutes / 60))).arg(f(minutes % 60))
    return Commons.I18n.t("system.uptime").arg(duration)
  }

  readonly property string heroMeta: {
    var parts = []
    if (coreUsage.length > 0) parts.push(Commons.I18n.tn("system.cores", coreUsage.length).arg(Commons.I18n.formatNumber(coreUsage.length)))
    if (uptimeSeconds > 0) parts.push(uptimeText())
    return parts.join(" · ")
  }

  // --------------------------------------------------------------- reading

  function sample() {
    meminfoFile.reload()
    statFile.reload()
    loadFile.reload()
    uptimeFile.reload()
  }

  function sampleSlow() {
    if (!dfProc.running) dfProc.running = true
    if (localModels && typeof localModels.readMemory === "function") localModels.readMemory()
  }

  onOpenedChanged: {
    if (opened) {
      sampleSlow()
    } else {
      // A minute's history with a gap in it would read as an idle spell.
      cpuStat = []
      cpuNow = []
      cpuHistory = []
      hoveredSegment = -1
    }
  }

  // The paths are set only while open, so nothing is read while closed.
  FileView {
    id: meminfoFile
    path: root.opened ? "/proc/meminfo" : ""
    printErrors: false
    onLoaded: root.meminfo = Model.parseMeminfo(text()) || root.meminfo
  }

  FileView {
    id: statFile
    path: root.opened ? "/proc/stat" : ""
    printErrors: false
    onLoaded: root.takeCpu(text())
  }

  FileView {
    id: loadFile
    path: root.opened ? "/proc/loadavg" : ""
    printErrors: false
    onLoaded: root.loadAverage = text().trim().split(/\s+/).slice(0, 3).map(Number)
  }

  FileView {
    id: uptimeFile
    path: root.opened ? "/proc/uptime" : ""
    printErrors: false
    onLoaded: root.uptimeSeconds = Number(text().trim().split(/\s+/)[0]) || 0
  }

  // -l keeps a stalled network mount from hanging the read.
  Process {
    id: dfProc
    command: ["df", "-l", "-B1", "--output=source,fstype,size,used,avail,target"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.disks = Model.parseDf(text)
    }
  }

  Timer { interval: 1000; running: root.opened; repeat: true; onTriggered: root.sample() }
  Timer { interval: 5000; running: root.opened; repeat: true; onTriggered: root.sampleSlow() }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon
    tooltipText: ""
    onPressed: function(b) { root.toggle() }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(400))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: PanelKeyCatcher {
      anchors.fill: parent
      implicitHeight: column.implicitHeight
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(14)

        PanelHero {
          iconComponent: Component {
            Text {
              textFormat: Text.PlainText
              text: root.icon
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.display
            }
          }
          title: Commons.I18n.t("system.title")
          meta: root.heroMeta
          foreground: root.foreground
          fontFamily: root.fontFamily
        }

        // -------------------------------------------------------- memory
        PanelSeparator { foreground: root.foreground }

        Column {
          width: parent.width
          spacing: Style.space(10)

          SectionHeading {
            title: Commons.I18n.t("system.memory")
            value: root.memory.total > 0 ? Commons.I18n.t("system.ofTotal").arg(root.size(root.memory.used)).arg(root.size(root.memory.total)) : ""
          }

          MemoryBar { width: parent.width }

          Repeater {
            model: root.memory.segments.length

            LegendRow {
              required property int index
              readonly property var segment: root.memory.segments[index] || root.noSegment
              width: parent.width
              visible: segment.gib > 0 || segment.kind === "free"
              segmentIndex: index
              kind: segment.kind
              label: root.segmentLabel(segment)
              value: root.size(segment.gib)
            }
          }

          Text {
            visible: root.swapUsed >= 0.1
            width: parent.width
            textFormat: Text.PlainText
            text: Commons.I18n.t("system.swapUsed").arg(root.size(root.swapUsed)).arg(root.size((root.meminfo ? root.meminfo.SwapTotal : 0) / (1024 * 1024)))
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        // ----------------------------------------------------------- cpu
        PanelSeparator { foreground: root.foreground }

        Column {
          width: parent.width
          spacing: Style.space(10)

          SectionHeading {
            title: Commons.I18n.t("system.cpu")
            value: root.cpuNow.length > 0 ? root.percent(root.cpuNow[0]) : ""
          }

          CpuHistory { width: parent.width; height: Style.space(40) }

          CoreStrip { width: parent.width; height: Style.space(18) }

          Text {
            visible: root.loadAverage.length === 3
            width: parent.width
            textFormat: Text.PlainText
            text: visible ? Commons.I18n.t("system.load")
              .arg(Commons.I18n.formatNumber(root.loadAverage[0], 2))
              .arg(Commons.I18n.formatNumber(root.loadAverage[1], 2))
              .arg(Commons.I18n.formatNumber(root.loadAverage[2], 2)) : ""
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        // ---------------------------------------------------------- disk
        PanelSeparator { foreground: root.foreground; visible: root.disks.length > 0 }

        Column {
          visible: root.disks.length > 0
          width: parent.width
          spacing: Style.space(10)

          SectionHeading { title: Commons.I18n.t("system.disk") }

          Repeater {
            model: root.disks.length
            DiskRow {
              required property int index
              width: parent.width
              disk: root.disks[index] || ({})
            }
          }
        }
      }
    }
  }

  // A section's caps title with its headline figure at the trailing edge.
  component SectionHeading: Item {
    id: heading
    property string title: ""
    property string value: ""
    width: parent ? parent.width : 0
    implicitHeight: headingText.implicitHeight

    PanelSectionHeader {
      id: headingText
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: heading.title.toUpperCase()
      foreground: root.foreground
      fontFamily: root.fontFamily
    }

    Text {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      textFormat: Text.PlainText
      text: heading.value
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true
    }
  }

  // The machine's memory as one bar, to scale. Every slice is at least as
  // wide as the bar is thick, so a small one still shows; free takes what the
  // others leave.
  component MemoryBar: Item {
    id: memoryBar
    readonly property real thickness: Math.max(Style.space(8), Math.round(Style.spacing.controlHeight * 0.3))
    readonly property real gap: Style.space(2)
    readonly property var shown: root.memory.segments.filter(function(segment) { return segment.gib > 0 })
    readonly property real room: Math.max(0, width - gap * Math.max(0, shown.length - 1))

    function sliceWidth(segment) {
      if (!(segment.gib > 0)) return 0
      if (segment.kind === "free") {
        var used = 0
        for (var i = 0; i < shown.length; i++) if (shown[i].kind !== "free") used += sliceWidth(shown[i])
        return Math.max(thickness, room - used)
      }
      return Math.max(thickness, root.memory.total > 0 ? room * segment.gib / root.memory.total : 0)
    }

    implicitHeight: thickness

    Row {
      anchors.fill: parent
      spacing: memoryBar.gap

      Repeater {
        model: root.memory.segments.length

        Rectangle {
          required property int index
          readonly property var segment: root.memory.segments[index] || root.noSegment
          visible: segment.gib > 0
          height: parent.height
          width: memoryBar.sliceWidth(segment)
          radius: Math.min(height / 2, Style.cornerRadius)
          color: root.segmentColor(segment.kind)
          border.width: segment.kind === "free" ? Math.max(1, Style.hoverBorderWidth) : 0
          border.color: root.track
          opacity: root.hoveredSegment < 0 || root.hoveredSegment === index ? 1 : 0.35

          Behavior on width { NumberAnimation { duration: Style.duration(240); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
          Behavior on opacity { NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutCubic } }

          HoverHandler {
            onHoveredChanged: {
              if (hovered) root.hoveredSegment = index
              else if (root.hoveredSegment === index) root.hoveredSegment = -1
            }
          }
        }
      }
    }
  }

  // One line of the memory legend: the slice's swatch, what holds it, how much.
  component LegendRow: Item {
    id: legend
    property int segmentIndex: -1
    property string kind: ""
    property string label: ""
    property string value: ""
    readonly property bool lit: root.hoveredSegment === segmentIndex
    implicitHeight: legendLabel.implicitHeight
    opacity: root.hoveredSegment < 0 || lit ? 1 : 0.5

    Behavior on opacity { NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutCubic } }

    Rectangle {
      id: swatch
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      width: Style.space(8)
      height: width
      radius: Math.min(width / 2, Style.cornerRadius)
      color: root.segmentColor(legend.kind)
      border.width: legend.kind === "free" ? Math.max(1, Style.hoverBorderWidth) : 0
      border.color: Util.alpha(root.foreground, 0.4)
    }

    Text {
      id: legendLabel
      anchors.left: swatch.right
      anchors.leftMargin: Style.space(10)
      anchors.right: legendValue.left
      anchors.rightMargin: Style.space(10)
      anchors.verticalCenter: parent.verticalCenter
      textFormat: Text.PlainText
      text: legend.label
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
    }

    Text {
      id: legendValue
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      textFormat: Text.PlainText
      text: legend.value
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }

    HoverHandler {
      onHoveredChanged: {
        if (hovered) root.hoveredSegment = legend.segmentIndex
        else if (root.hoveredSegment === legend.segmentIndex) root.hoveredSegment = -1
      }
    }
  }

  // The whole CPU's load over the last minute, a bar a second, newest at the
  // trailing edge; seconds not seen yet stand as stubs.
  component CpuHistory: Item {
    id: history
    readonly property real gap: Style.space(2)
    readonly property real stub: Math.max(Style.space(2), Math.round(Style.spacing.controlHeight * 0.07))
    readonly property real barWidth: Math.max(1, (width - gap * (root.historyLength - 1)) / root.historyLength)

    Row {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      spacing: history.gap

      Repeater {
        model: root.historyLength

        Rectangle {
          required property int index
          readonly property int sampleIndex: index - (root.historyLength - root.cpuHistory.length)
          readonly property bool seen: sampleIndex >= 0
          anchors.bottom: parent.bottom
          width: history.barWidth
          height: seen ? Math.max(history.stub, history.height * root.cpuHistory[sampleIndex]) : history.stub
          radius: Math.min(width / 2, Style.cornerRadius)
          color: seen ? root.foreground : root.track
          opacity: seen && sampleIndex < root.cpuHistory.length - 1 ? 0.55 : 1
        }
      }
    }
  }

  // Each core's load now, side by side, with its number and load on hover.
  component CoreStrip: Item {
    id: strip
    readonly property int count: root.coreUsage.length
    readonly property real gap: count > 64 ? Style.space(1) : Style.space(2)
    readonly property real barWidth: count > 0 ? Math.max(1, (width - gap * (count - 1)) / count) : 0
    readonly property int hoveredCore: coreHover.hovered && count > 0
      ? Math.max(0, Math.min(count - 1, Math.floor((LayoutMirroring.enabled ? width - coreHover.point.position.x : coreHover.point.position.x) / (barWidth + gap))))
      : -1

    Row {
      anchors.fill: parent
      spacing: strip.gap

      Repeater {
        model: strip.count

        Item {
          required property int index
          width: strip.barWidth
          height: strip.height

          Rectangle {
            anchors.fill: parent
            radius: Math.min(width / 2, Style.cornerRadius)
            color: root.track
          }

          Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height * (root.coreUsage[index] || 0)
            radius: Math.min(width / 2, Style.cornerRadius)
            color: strip.hoveredCore === index ? Commons.Color.accent : root.foreground

            Behavior on height { NumberAnimation { duration: Style.duration(240); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
          }
        }
      }
    }

    HoverHandler { id: coreHover }
    PanelToolTip {
      visible: strip.hoveredCore >= 0
      text: visible ? Commons.I18n.t("system.coreUsage").arg(Commons.I18n.formatNumber(strip.hoveredCore)).arg(root.percent(root.coreUsage[strip.hoveredCore] || 0)) : ""
      fontFamily: root.fontFamily
    }
  }

  // One filesystem: where it's mounted, how full, and what's free.
  component DiskRow: Item {
    id: diskRow
    property var disk: ({})
    readonly property bool alarming: Number(disk.fraction) >= 0.9
    implicitHeight: diskTitle.implicitHeight

    Text {
      id: diskTitle
      width: parent.width * 0.3
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      textFormat: Text.PlainText
      text: Model.mountLabel(diskRow.disk.target, Commons.I18n.t)
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
    }

    Item {
      id: diskMeter
      anchors.left: diskTitle.right
      anchors.right: diskValue.left
      anchors.rightMargin: Style.space(20)
      anchors.verticalCenter: parent.verticalCenter
      height: Math.max(Style.space(4), Math.round(Style.spacing.controlHeight * 0.14))

      Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.track
      }

      Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        radius: height / 2
        width: parent.width * Math.max(0, Math.min(1, Number(diskRow.disk.fraction) || 0))
        color: diskRow.alarming ? root.urgent : root.foreground

        Behavior on width { NumberAnimation { duration: Style.duration(240); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      }
    }

    TextMetrics {
      id: diskValueMetrics
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      text: Commons.I18n.t("system.diskFree").arg(root.size(999))
    }

    Text {
      id: diskValue
      width: Math.max(Math.ceil(diskValueMetrics.advanceWidth), implicitWidth)
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      horizontalAlignment: Text.AlignRight
      textFormat: Text.PlainText
      text: Commons.I18n.t("system.diskFree").arg(root.size(diskRow.disk.free))
      color: diskRow.alarming ? root.urgent : root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }

    HoverHandler { id: diskHover }
    PanelToolTip {
      visible: diskHover.hovered
      text: Commons.I18n.t("system.diskTooltip")
        .arg(root.size(diskRow.disk.used))
        .arg(root.size(diskRow.disk.size))
        .arg(String(diskRow.disk.target || "")) // i18n: ignore
        .arg(String(diskRow.disk.fstype || "")) // i18n: ignore
      fontFamily: root.fontFamily
    }
  }
}
