import QtQuick
import Quickshell.Io
import qs.Commons
import "GlobeModel.js" as Solar

// A small drawn globe, for use where an icon would otherwise go.
//
// It is drawn rather than glyphed because a glyph cannot spin: rotating a
// flat image about the vertical axis squashes it to a line and flips it,
// which reads as a coin. A sphere keeps its circular outline and moves only
// its surface across it, which is what this does - the disc is constant and
// the graticule and coastlines are re-projected as `spin` advances.
//
// `spin` is the longitude facing the viewer, so animating it 0 -> 360 is one
// full rotation of the earth. Tilt the whole item to lean the axis.
Item {
  id: root

  property real spin: 0
  property color color: Color.foreground
  // Landmasses are the point of a globe, but below about this size they turn
  // to noise, so small instances draw the graticule alone.
  readonly property bool showLand: width >= 22

  property var land: []

  // Heavier strokes and fuller fills, for when the globe is a centrepiece
  // rather than an icon sitting inside a line of text.
  property bool bold: false

  // "You are here".
  property bool showMarker: false
  property real markerLat: 0
  property real markerLon: 0
  property color markerColor: Color.accent

  readonly property real radius: Math.min(width, height) / 2 - 1
  readonly property string here: {
    var u = Qt.resolvedUrl(".").toString()
    return u.replace(/^file:\/\//, "").replace(/\/$/, "")
  }

  onSpinChanged: canvas.requestPaint()
  onColorChanged: canvas.requestPaint()
  onShowMarkerChanged: canvas.requestPaint()
  onMarkerLatChanged: canvas.requestPaint()
  onMarkerLonChanged: canvas.requestPaint()

  FileView {
    path: root.here + "/world.json"
    printErrors: false
    onLoaded: {
      try { root.land = JSON.parse(text()); canvas.requestPaint() } catch (e) { }
    }
  }

  Canvas {
    id: canvas
    anchors.fill: parent
    renderStrategy: Canvas.Cooperative

    // Both helpers live in GlobeModel now, shared with the large globe.
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

      // The ocean. Its outline never changes shape, which is the whole
      // difference between a turning globe and a flipping coin.
      ctx.beginPath()
      ctx.arc(0, 0, r, 0, Math.PI * 2)
      // Opaque, like the large globe: a globe that lets the panel show
      // through is a tinted disc, not an object.
      var base = Color.popups.background
      ctx.fillStyle = Qt.rgba(base.r + (c.r - base.r) * (root.bold ? 0.16 : 0.13),
                              base.g + (c.g - base.g) * (root.bold ? 0.16 : 0.13),
                              base.b + (c.b - base.b) * (root.bold ? 0.16 : 0.13), 1)
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
      ctx.strokeStyle = Qt.rgba(c.r, c.g, c.b,
        root.showLand ? (root.bold ? 0.42 : 0.30) : 0.85)
      ctx.stroke()

      if (root.showLand && root.land.length > 0) {
        ctx.beginPath()
        for (i = 0; i < root.land.length; i++) {
          var ring = root.land[i]
          // Only the major landmasses. Islands are single pixels here and
          // read as dirt on the lens.
          if (ring.length < 40) continue
          var poly = Solar.clipRingToDisc(ring, root.spin, 0, root.radius)
          if (poly.length < 3) continue
          ctx.moveTo(poly[0].x, poly[0].y)
          for (var q = 1; q < poly.length; q++) ctx.lineTo(poly[q].x, poly[q].y)
          ctx.closePath()
        }
        ctx.fillStyle = Qt.rgba(c.r, c.g, c.b, root.bold ? 1.0 : 0.85)
        ctx.fill()
      }

      // "You are here", drawn only while it is on the near side - so it
      // sweeps around with the spin and is facing you when it stops.
      if (root.showMarker) {
        var mp = Solar.project(root.markerLat, root.markerLon, root.spin, 0, r)
        if (mp.visible) {
          var mr = Math.max(1.6, r * 0.13)
          ctx.beginPath()
          ctx.arc(mp.x, mp.y, mr, 0, Math.PI * 2)
          ctx.fillStyle = root.markerColor
          ctx.fill()
          // A dark edge, because a daylight sky is nearly the same lightness
          // as the filled continents and the dot would otherwise dissolve
          // into whichever landmass it happens to be sitting on.
          ctx.lineWidth = Math.max(1, r * 0.04)
          ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.5)
          ctx.stroke()

          ctx.beginPath()
          ctx.arc(mp.x, mp.y, mr * 1.9, 0, Math.PI * 2)
          ctx.lineWidth = Math.max(1, r * 0.045)
          ctx.strokeStyle = Qt.rgba(root.markerColor.r, root.markerColor.g,
                                    root.markerColor.b, 0.65)
          ctx.stroke()
        }
      }

      ctx.restore()

      // The rim last, so nothing spills over it.
      ctx.beginPath()
      ctx.arc(0, 0, r, 0, Math.PI * 2)
      ctx.lineWidth = Math.max(1, r * (root.bold ? 0.095 : 0.08))
      ctx.strokeStyle = Qt.rgba(c.r, c.g, c.b, root.bold ? 1.0 : 0.95)
      ctx.stroke()
    }
  }
}
