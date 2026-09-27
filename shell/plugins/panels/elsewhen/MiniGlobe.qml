import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "GlobeModel.js" as Solar
import "Model.js" as Model

// A small drawn globe for where an icon would go. Drawn, not glyphed, so it
// can spin: `spin` is the longitude facing the viewer; rotate the item to lean it.
Item {
  id: root

  property real spin: 0
  property color color: Color.foreground
  // Below this size land turns to noise; draw the graticule alone.
  readonly property bool showLand: width >= 22

  property var land: []

  // Heavier strokes and fuller fills, for a centerpiece rather than an inline icon.
  property bool bold: false

  // "You are here".
  property bool showMarker: false
  property real markerLat: 0
  property real markerLon: 0
  property color markerColor: Color.accent

  readonly property real radius: Math.min(width, height) / 2 - 1
  readonly property string pluginDir: Quickshell.env("OMARCHY_PATH") + "/shell/plugins/panels/elsewhen"

  onSpinChanged: canvas.requestPaint()
  onColorChanged: canvas.requestPaint()
  onShowMarkerChanged: canvas.requestPaint()
  onMarkerLatChanged: canvas.requestPaint()
  onMarkerLonChanged: canvas.requestPaint()

  FileView {
    path: root.pluginDir + "/world.json"
    printErrors: false
    onLoaded: {
      try { root.land = JSON.parse(text()); canvas.requestPaint() } catch (e) { }
    }
  }

  Canvas {
    id: canvas
    anchors.fill: parent
    renderStrategy: Canvas.Cooperative

    function strokePath(ctx, pts) {
      var segs = Solar.visibleSegments(pts, root.spin, 0, root.radius)
      for (var i = 0; i < segs.length; i++) {
        ctx.moveTo(segs[i][0].x, segs[i][0].y)
        for (var j = 1; j < segs[i].length; j++) ctx.lineTo(segs[i][j].x, segs[i][j].y)
      }
    }

    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.translate(width / 2, height / 2)
      var r = root.radius
      if (r <= 0) return
      var c = root.color
      var lat, lon, pts, i

      // The ocean, opaque like the large globe.
      ctx.beginPath()
      ctx.arc(0, 0, r, 0, Math.PI * 2)
      ctx.fillStyle = Model.mix(Color.popups.background, c, root.bold ? 0.16 : 0.13)
      ctx.fill()

      ctx.save()
      ctx.beginPath()
      ctx.arc(0, 0, r, 0, Math.PI * 2)
      ctx.clip()

      // Graticule first, so the land sits on top of it.
      ctx.beginPath()
      for (lon = -90; lon < 90; lon += 90) {
        pts = []
        for (lat = -90; lat <= 90; lat += 6) pts.push([lat, lon])
        strokePath(ctx, pts)
      }
      pts = []
      for (lon = -180; lon <= 180; lon += 6) pts.push([0, lon])
      strokePath(ctx, pts)
      ctx.lineWidth = Math.max(1, r * (root.bold ? 0.055 : 0.045))
      ctx.strokeStyle = Util.alpha(c, root.showLand ? (root.bold ? 0.42 : 0.30) : 0.85)
      ctx.stroke()

      if (root.showLand && root.land.length > 0) {
        ctx.beginPath()
        for (i = 0; i < root.land.length; i++) {
          var ring = root.land[i]
          // Major landmasses only; islands read as dirt on the lens.
          if (ring.length < 40) continue
          var poly = Solar.clipRingToDisc(ring, root.spin, 0, root.radius)
          if (poly.length < 3) continue
          ctx.moveTo(poly[0].x, poly[0].y)
          for (var q = 1; q < poly.length; q++) ctx.lineTo(poly[q].x, poly[q].y)
          ctx.closePath()
        }
        ctx.fillStyle = Util.alpha(c, root.bold ? 1.0 : 0.85)
        ctx.fill()
      }

      // "You are here", only while on the near side.
      if (root.showMarker) {
        var mp = Solar.project(root.markerLat, root.markerLon, root.spin, 0, r)
        if (mp.visible) {
          var mr = Math.max(1.6, r * 0.13)
          ctx.beginPath()
          ctx.arc(mp.x, mp.y, mr, 0, Math.PI * 2)
          ctx.fillStyle = root.markerColor
          ctx.fill()
          // Edged so it does not dissolve into a continent of similar lightness.
          ctx.lineWidth = Math.max(1, r * 0.04)
          ctx.strokeStyle = Util.alpha(Color.background, 0.5)
          ctx.stroke()

          ctx.beginPath()
          ctx.arc(mp.x, mp.y, mr * 1.9, 0, Math.PI * 2)
          ctx.lineWidth = Math.max(1, r * 0.045)
          ctx.strokeStyle = Util.alpha(root.markerColor, 0.65)
          ctx.stroke()
        }
      }

      ctx.restore()

      // The rim last, so nothing spills over it.
      ctx.beginPath()
      ctx.arc(0, 0, r, 0, Math.PI * 2)
      ctx.lineWidth = Math.max(1, r * (root.bold ? 0.095 : 0.08))
      ctx.strokeStyle = Util.alpha(c, root.bold ? 1.0 : 0.95)
      ctx.stroke()
    }
  }
}
