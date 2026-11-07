pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import "Model.js" as Model

Item {
  id: root

  property bool active: false
  property var coordinates: null
  property string locationName: ""
  property string timeFormat: Commons.Time.timeFormat
  property color foreground: Commons.Color.popups.text
  property string fontFamily: Style.fontFamily
  readonly property var formatLocale: Qt.locale(Commons.I18n.formatLocale)
  readonly property string coordinateKey: coordinates ? coordinates.key : ""

  property var stationCache: ({})
  property string station: ""
  property var frames: []
  property int frameIndex: -1
  property bool playing: false
  property bool followLatest: true
  property int generation: 0
  property var request: null
  property double refreshedAt: 0
  property double now: Date.now()
  property bool resident: false
  readonly property real zoom: 7.65
  readonly property int sourceZoom: Math.ceil(zoom)
  readonly property real tileSize: 256 * Math.pow(2, zoom - sourceZoom)
  readonly property var tiles: resident ? Model.radarTileGrid(coordinates, zoom, width, mapLoader.height, sourceZoom) : []
  readonly property bool live: frameIndex === frames.length - 1 && frames.length > 0 && now - frames[frameIndex].time < 900000
  readonly property string scanTime: frames[frameIndex] ? new Date(frames[frameIndex].time).toLocaleTimeString(formatLocale, timeFormat) : ""

  visible: frames.length > 0
  implicitHeight: frames.length > 0 ? content.implicitHeight : 0
  height: implicitHeight

  onActiveChanged: {
    if (active) {
      releaseImages.stop()
      resident = true
      Qt.callLater(refresh)
    } else {
      playing = false
      cancelRequest()
      releaseImages.restart()
    }
  }
  onCoordinateKeyChanged: {
    cancelRequest()
    frames = []
    frameModel.clear()
    frameIndex = -1
    station = ""
    refreshedAt = 0
    playing = false
    followLatest = true
    Qt.callLater(refresh)
  }
  Component.onDestruction: cancelRequest()
  Component.onCompleted: if (active) { resident = true; Qt.callLater(refresh) }

  function cancelRequest() {
    generation++
    if (request) {
      var previous = request
      request = null
      previous.running = false
    }
  }

  function refresh() {
    now = Date.now()
    if (!active || !coordinates || request || now - refreshedAt < 180000) return
    var cached = stationCache[coordinateKey]
    if (cached === null) return
    if (cached === undefined) {
      fetch("station", "https://api.weather.gov/points/" + coordinateKey)
    } else {
      station = cached
      fetch("scans", Model.radarScansUrl(station, now))
    }
  }

  function fetch(kind, url) {
    request = fetchProcess.createObject(root, {
      kind: kind, token: generation, key: coordinateKey,
      command: ["curl", "--fail", "--silent", "--location", "--proto-redir", "=https", "--max-time", "15", "--max-filesize", "1048576", "--user-agent", "omarchy-weather (https://github.com/omacom/omarchy)", "--write-out", "\n%{http_code}", url]
    })
    request.running = true
  }

  function acceptResponse(kind, raw, status) {
    if (kind === "station") {
      var resolved = Model.parseRadarStation(raw, status)
      if (resolved !== undefined) {
        stationCache[coordinateKey] = resolved
        station = resolved || ""
        if (station) refresh()
      }
      return
    }
    if (status !== 200) return
    var scans = Model.parseRadarScans(raw)
    if (scans.length === 0) return
    refreshedAt = Date.now()
    var selected = frames[frameIndex]
    if (selected && !scans.some(function(frame) { return frame.stamp === selected.stamp }))
      scans.unshift(selected)
    for (var i = frameModel.count - 1; i >= 0; i--) {
      var stamp = frameModel.get(i).stamp
      if (!scans.some(function(frame) { return frame.stamp === stamp })) frameModel.remove(i)
    }
    for (var j = 0; j < scans.length; j++) {
      if (j >= frameModel.count || frameModel.get(j).stamp !== scans[j].stamp)
        frameModel.insert(j, scans[j])
    }
    frames = scans
    frameIndex = selected ? scans.findIndex(function(frame) { return frame.stamp === selected.stamp }) : -1
    Qt.callLater(checkReady)
  }

  function ready(index) {
    var layer = mapLoader.item ? mapLoader.item.layers.itemAt(index) : null
    return layer !== null && layer.ready
  }

  function checkReady() {
    if (!resident) return
    if (followLatest || frameIndex < 0) {
      for (var i = frames.length - 1; i >= 0; i--) {
        if (ready(i)) { frameIndex = i; break }
      }
    }
  }

  function selectFrame(index) {
    if (ready(index)) {
      followLatest = index === frames.length - 1
      frameIndex = index
    }
  }

  function togglePlayback() {
    if (frames.length < 2) return
    followLatest = false
    playing = !playing
  }

  Image {
    id: paletteTexture
    source: "n0b-palette.png"
    visible: false
    smooth: false
  }

  ListModel { id: frameModel }

  Component {
    id: fetchProcess
    Process {
      id: job
      required property string kind
      required property int token
      required property string key
      stdout: StdioCollector { id: response; waitForEnd: true }
      onExited: {
        if (root.request === job) root.request = null
        if (root.active && token === root.generation && key === root.coordinateKey) {
          var status = Number(response.text.slice(-3))
          root.acceptResponse(kind, response.text.slice(0, -4), status)
        }
        destroy()
      }
    }
  }

  Timer {
    id: releaseImages
    interval: Style.duration(200)
    onTriggered: root.resident = false
  }

  Timer {
    interval: 180000
    repeat: true
    running: root.active && root.coordinates !== null
    onTriggered: root.refresh()
  }

  Timer {
    interval: 650
    repeat: true
    running: root.active && root.playing && root.frames.length > 1
    onTriggered: {
      for (var step = 1; step <= root.frames.length; step++) {
        var next = (root.frameIndex + step) % root.frames.length
        if (root.ready(next)) { root.frameIndex = next; break }
      }
    }
  }

  Column {
    id: content
    width: parent.width
    spacing: Style.space(10)

    Rectangle {
      width: parent.width
      height: Style.spacing.hairline
      color: root.foreground
      opacity: 0.25
    }

    Item {
      width: parent.width
      height: Style.space(12)

      Text {
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: Commons.I18n.t("weather.radar")
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
        font.letterSpacing: 1.5
      }

      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(16)

        Text {
          textFormat: Text.PlainText
          text: root.station
          color: root.foreground
          opacity: 0.7
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
        }

        Row {
          spacing: Style.space(6)
          visible: root.live
          anchors.verticalCenter: parent.verticalCenter

          Rectangle {
            width: Style.space(6)
            height: width
            radius: width / 2
            color: Commons.Color.accent
            anchors.verticalCenter: parent.verticalCenter
          }
          Text {
            textFormat: Text.PlainText
            text: Commons.I18n.t("weather.live")
            color: Commons.Color.accent
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.letterSpacing: 1
          }
        }
      }
    }

    Loader {
      id: mapLoader
      width: parent.width
      height: Math.round(width * 7 / 16)
      active: root.resident && root.frames.length > 0
      sourceComponent: Rectangle {
        id: map
        property alias layers: frameLayers
        color: Commons.Color.popups.background
        border.width: Style.spacing.hairline
        border.color: Util.alpha(root.foreground, 0.35)
        clip: true
        LayoutMirroring.enabled: false

        Repeater {
          model: root.tiles
          delegate: Item {
            id: baseLayer
            required property var modelData
            x: modelData.left
            y: modelData.top
            width: root.tileSize
            height: width

            // Basemap: MIERUNE Inc., © OpenMapTiles, © OpenStreetMap contributors
            // (https://www.openstreetmap.org/copyright). Radar: NWS NEXRAD via IEM.
            Image {
              id: baseTile
              anchors.fill: parent
              visible: false
              asynchronous: true
              source: "https://tile.mierune.co.jp/mierune_mono/" + root.sourceZoom + "/" + baseLayer.modelData.x + "/" + baseLayer.modelData.y + "@2x.png"
            }
            ShaderEffect {
              anchors.fill: parent
              property var source: baseTile
              property color backgroundColor: Commons.Color.popups.background
              property color foregroundColor: root.foreground
              fragmentShader: "basemap.frag.qsb"
            }
          }
        }

        Repeater {
          id: frameLayers
          model: frameModel
          delegate: Item {
            id: frameLayer
            required property string stamp
            required property int index
            readonly property bool ready: {
              if (radarTiles.count === 0) return false
              for (var i = 0; i < radarTiles.count; i++) {
                var tile = radarTiles.itemAt(i)
                if (!tile || tile.status !== Image.Ready) return false
              }
              return true
            }
            onReadyChanged: Qt.callLater(root.checkReady)
            anchors.fill: parent
            opacity: index === root.frameIndex && ready ? 1 : 0

            Repeater {
              id: radarTiles
              model: root.tiles
              delegate: Item {
                id: tileLayer
                required property var modelData
                readonly property int status: radarTile.status
                x: modelData.left
                y: modelData.top
                width: root.tileSize
                height: width

                Image {
                  id: radarTile
                  anchors.fill: parent
                  visible: false
                  asynchronous: true
                  smooth: false
                  source: Model.radarTileUrl(root.station, frameLayer.stamp, root.sourceZoom, tileLayer.modelData.x, tileLayer.modelData.y)
                }
                ShaderEffect {
                  anchors.fill: parent
                  anchors.margins: -2
                  property var source: radarTile
                  property var n0bPalette: paletteTexture
                  property real tileSize: root.tileSize
                  property vector2d tileOffset: Qt.vector2d(tileLayer.modelData.left, tileLayer.modelData.top)
                  fragmentShader: "radar.frag.qsb"
                }
              }
            }
          }
        }

        Row {
          x: map.width / 2 - locationDot.width / 2
          y: map.height / 2 - height / 2
          spacing: Style.space(5)

          Rectangle {
            id: locationDot
            width: Style.space(8)
            height: width
            radius: width / 2
            color: root.foreground
            anchors.verticalCenter: parent.verticalCenter
          }
          Rectangle {
            width: locationLabel.width + Style.space(8)
            height: locationLabel.height + Style.space(4)
            y: -height
            color: Commons.Color.popups.background

            Text {
              id: locationLabel
              anchors.centerIn: parent
              text: root.locationName
              textFormat: Text.PlainText
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              width: Math.min(implicitWidth, map.width / 2 - Style.space(24))
              elide: Text.ElideRight
            }
          }
        }
      }
    }

    Text {
      id: attribution
      width: parent.width
      text: `<a href="https://www.mierune.co.jp/" style="color: ${attribution.color}; text-decoration: none;">MIERUNE Inc.</a> © <a href="https://openmaptiles.org/" style="color: ${attribution.color}; text-decoration: none;">OpenMapTiles</a> © <a href="https://www.openstreetmap.org/copyright" style="color: ${attribution.color}; text-decoration: none;">OpenStreetMap contributors</a>` // i18n: ignore
      textFormat: Text.RichText
      color: Commons.Color.muted
      linkColor: attribution.color
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.Wrap
      onLinkActivated: function(url) { Qt.openUrlExternally(url) }
    }

    Item {
      width: parent.width
      height: Style.space(20)

      Text {
        id: play
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.playing ? "󰏤" : "󰐊"
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.heading
      }
      MouseArea {
        anchors.centerIn: play
        width: Style.space(28)
        height: Style.space(26)
        cursorShape: Qt.PointingHandCursor
        enabled: root.frames.length > 1
        onClicked: root.togglePlayback()
      }

      Text {
        id: time
        textFormat: Text.PlainText
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.scanTime
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }

      Item {
        id: scrubber
        readonly property bool mirrored: LayoutMirroring.enabled
        anchors.left: play.right
        anchors.leftMargin: Style.space(16)
        anchors.right: time.left
        anchors.rightMargin: Style.space(14)
        height: parent.height

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width
          height: Style.space(2)
          color: Util.alpha(root.foreground, 0.45)
          radius: height / 2
        }
        Rectangle {
          property real progress: root.frames.length > 1 ? root.frameIndex / (root.frames.length - 1) : 1
          x: (scrubber.mirrored ? 1 - progress : progress) * (parent.width - width)
          anchors.verticalCenter: parent.verticalCenter
          width: Style.space(9)
          height: width
          radius: width / 2
          color: root.foreground
        }
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          function scrub(x) {
            root.playing = false
            var fraction = (scrubber.mirrored ? width - x : x) / width
            root.selectFrame(Math.round(Math.max(0, Math.min(1, fraction)) * (root.frames.length - 1)))
          }
          onPressed: function(mouse) { scrub(mouse.x) }
          onPositionChanged: function(mouse) { if (pressed) scrub(mouse.x) }
        }
      }
    }
  }
}
