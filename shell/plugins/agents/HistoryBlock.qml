import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// One provider's tokens by day and model: a stacked bar per day (the most
// used model at the bottom), a 7 or 30 day toggle, and the window's top
// models with their totals. Colors follow a model's all-time rank, so a
// model keeps its color when the toggle changes the window.
//
// `days` is the record's `history`, {"YYYY-MM-DD": {"<model id>": tokens}}.
// `source` is the Agents service, for friendlyModelName() and
// formatTokenCount().
Column {
  id: block

  property var source: null
  property var days: ({})
  property int range: 7
  property double nowMs: Date.now()
  property color foreground: Commons.Color.foreground
  property string fontFamily: Style.font.family
  // The range (7 or 30) the keyboard cursor is on, or 0 when it is elsewhere.
  property int litRange: 0
  signal rangeRequested(int range)
  signal rangeHovered(int range)
  // The title and 7d/30d row, so the panel can scroll to just that.
  readonly property Item toggleRow: header

  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property int maxSegments: 5
  readonly property real chartHeight: Style.space(84)
  readonly property var ranges: [7, 30]
  readonly property var locale: Qt.locale(Commons.I18n.formatLocale)

  spacing: Style.space(10)

  function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
  function pad(n) { return n < 10 ? "0" + n : "" + n }
  function ymd(d) { return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()) }
  function tokens(n) { return source ? source.formatTokenCount(n) : String(n) }
  function modelName(id) { return source ? source.friendlyModelName(id) : id }

  // The hue walks away from the theme's accent by rank.
  function colorFor(rank) {
    var a = Commons.Color.accent
    var h = (a.hslHue < 0 ? 0.58 : a.hslHue) + rank * 0.17
    h = h - Math.floor(h)
    return Qt.hsla(h, 0.5, 0.62, 1)
  }

  // Every model, most used first, over all the days the record holds.
  readonly property var ranking: {
    var totals = {}
    for (var day in days) for (var m in days[day]) totals[m] = (totals[m] || 0) + days[day][m]
    return Object.keys(totals).sort(function(a, b) { return totals[b] - totals[a] })
  }

  readonly property var chart: {
    var now = new Date(nowMs)
    var cols = []
    var windowTotals = {}
    var peak = 0
    var rank = {}
    for (var r = 0; r < ranking.length; r++) rank[ranking[r]] = r
    for (var i = range - 1; i >= 0; i--) {
      var date = new Date(now.getFullYear(), now.getMonth(), now.getDate() - i)
      var key = ymd(date)
      var models = days[key] || ({})
      var ids = Object.keys(models).sort(function(a, b) { return rank[a] - rank[b] })
      var total = 0
      var segs = []
      var other = 0
      for (var k = 0; k < ids.length; k++) {
        var v = models[ids[k]]
        total += v
        windowTotals[ids[k]] = (windowTotals[ids[k]] || 0) + v
        if (rank[ids[k]] < maxSegments) segs.push({ id: ids[k], value: v, color: colorFor(rank[ids[k]]) })
        else other += v
      }
      if (other > 0) segs.push({ id: "", value: other, color: alpha(foreground, 0.35) })
      peak = Math.max(peak, total)
      cols.push({ key: key, date: date, total: total, segs: segs, models: models, today: i === 0 })
    }
    var rows = Object.keys(windowTotals).sort(function(a, b) { return windowTotals[b] - windowTotals[a] }).map(function(id) {
      return { id: id, name: modelName(id), total: windowTotals[id], color: rank[id] < maxSegments ? colorFor(rank[id]) : alpha(foreground, 0.35) }
    })
    return { cols: cols, peak: peak, rows: rows.slice(0, maxSegments) }
  }

  function dayTip(col) {
    var lines = [Commons.I18n.tn("agents.historyDayTotal", col.total)
      .arg(locale.toString(col.date, Commons.I18n.t("agents.historyDayFormat"))).arg(tokens(col.total))]
    var ids = Object.keys(col.models).sort(function(a, b) { return col.models[b] - col.models[a] })
    for (var i = 0; i < ids.length && i < 6; i++) lines.push(modelName(ids[i]) + " · " + tokens(col.models[ids[i]]))
    return lines.join("\n")
  }

  // Title and the 7 / 30 day toggle.
  Item {
    id: header
    width: parent.width
    implicitHeight: Math.max(title.implicitHeight, toggle.height)

    Text {
      id: title
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      textFormat: Text.PlainText
      text: Commons.I18n.t("agents.historyTitle")
      color: block.dim
      font.family: block.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true
    }

    Row {
      id: toggle
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(2)

      Repeater {
        model: block.ranges

        Rectangle {
          required property int modelData
          readonly property bool picked: block.range === modelData
          width: pillText.implicitWidth + Style.space(14)
          height: pillText.implicitHeight + Style.space(6)
          radius: height / 2
          color: picked ? block.alpha(block.foreground, 0.16) : "transparent"

          // The keyboard cursor, and the mouse through the panel's own cursor.
          CursorSurface {
            anchors.fill: parent
            z: -1
            radius: parent.radius
            hasCursor: block.litRange === parent.modelData
            foreground: block.foreground
          }

          Text {
            id: pillText
            anchors.centerIn: parent
            textFormat: Text.PlainText
            text: Commons.I18n.t("agents.historyRange").arg(Commons.I18n.formatNumber(parent.modelData))
            color: parent.picked ? block.foreground : block.dim
            font.family: block.fontFamily
            font.pixelSize: Style.font.caption
            font.bold: parent.picked
          }

          MouseArea {
            id: pillHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: block.rangeHovered(parent.modelData)
            onClicked: block.rangeRequested(parent.modelData)
          }

          PanelToolTip {
            visible: pillHover.containsMouse
            text: Commons.I18n.tn("agents.historyRangeTip", parent.modelData).arg(Commons.I18n.formatNumber(parent.modelData))
            fontFamily: block.fontFamily
          }
        }
      }
    }
  }

  // The chart, the baseline, and under it the first day, the peak, and today.
  Item {
    id: plot
    width: parent.width
    height: block.chartHeight + axis.implicitHeight + Style.space(4)
    readonly property real gap: block.range > 14 ? Style.space(2) : Style.space(6)
    readonly property real colWidth: (width - gap * (block.range - 1)) / block.range

    Rectangle {
      width: parent.width
      height: 1
      y: block.chartHeight
      color: block.alpha(block.foreground, 0.15)
    }

    Repeater {
      model: block.chart.cols

      Item {
        id: col
        required property var modelData
        required property int index
        x: LayoutMirroring.enabled
          ? plot.width - plot.colWidth - index * (plot.colWidth + plot.gap)
          : index * (plot.colWidth + plot.gap)
        width: plot.colWidth
        height: block.chartHeight

        Column {
          id: stack
          anchors.bottom: parent.bottom
          width: parent.width
          spacing: 0
          opacity: col.modelData.today || colHover.containsMouse ? 1.0 : 0.82

          Repeater {
            model: col.modelData.segs.slice().reverse()

            Rectangle {
              required property var modelData
              width: stack.width
              height: block.chart.peak > 0 ? Math.max(1, block.chartHeight * modelData.value / block.chart.peak) : 0
              color: modelData.color
              radius: 1
            }
          }
        }

        MouseArea {
          id: colHover
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.NoButton
        }

        PanelToolTip {
          visible: colHover.containsMouse && col.modelData.total > 0
          text: block.dayTip(col.modelData)
          fontFamily: block.fontFamily
        }
      }
    }

    Item {
      id: axis
      anchors.bottom: parent.bottom
      width: parent.width
      implicitHeight: axisFirst.implicitHeight

      Text {
        id: axisFirst
        anchors.left: parent.left
        textFormat: Text.PlainText
        text: block.chart.cols.length > 0 ? block.locale.toString(block.chart.cols[0].date, Commons.I18n.t("agents.historyAxisFormat")) : ""
        color: block.dim
        font.family: block.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: block.chart.peak > 0 ? Commons.I18n.t("agents.historyPeak").arg(block.tokens(block.chart.peak)) : ""
        color: block.dim
        font.family: block.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        anchors.right: parent.right
        textFormat: Text.PlainText
        text: Commons.I18n.t("agents.historyToday")
        color: block.dim
        font.family: block.fontFamily
        font.pixelSize: Style.font.caption
      }
    }
  }

  // Tokens per model over the window: a share bar scaled to the top model,
  // the name on the left, the count on the right, and a dot in the model's
  // color from the chart.
  Repeater {
    model: block.chart.rows

    Item {
      id: row
      required property var modelData
      width: block.width
      implicitHeight: rowName.implicitHeight + Style.spacing.lg

      Rectangle {
        anchors.fill: parent
        radius: Style.cornerRadius
        color: block.alpha(block.foreground, 0.05)
      }

      Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * Math.max(0, Math.min(1, row.modelData.total / Math.max(1, block.chart.rows[0].total)))
        radius: Style.cornerRadius
        color: block.alpha(row.modelData.color, 0.28)

        Behavior on width {
          NumberAnimation {
            duration: Style.duration(160)
            easing.type: Easing.Bezier
            easing.bezierCurve: Style.easeOut
          }
        }
      }

      Rectangle {
        id: swatch
        anchors.left: parent.left
        anchors.leftMargin: Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
        width: Style.space(8)
        height: width
        radius: width / 2
        color: row.modelData.color
      }

      Text {
        id: rowName
        anchors.left: swatch.right
        anchors.leftMargin: Style.space(8)
        anchors.right: rowTokens.left
        anchors.rightMargin: Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: row.modelData.name
        color: block.foreground
        font.family: block.fontFamily
        font.pixelSize: Style.font.bodySmall
        elide: Text.ElideRight
      }

      Text {
        id: rowTokens
        anchors.right: parent.right
        anchors.rightMargin: Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: block.tokens(row.modelData.total)
        color: block.dim
        font.family: block.fontFamily
        font.pixelSize: Style.font.bodySmall
        font.bold: true
      }
    }
  }
}
