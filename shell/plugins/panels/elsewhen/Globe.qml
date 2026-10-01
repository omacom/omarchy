import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "GlobeModel.js" as Solar
import "Model.js" as Model

// A spinnable orthographic globe: coastlines, the day/night terminator and the
// major city of every zone. Owns its data files and clock probe; Panel mounts it.
Item {
  id: root

  property color foreground: Color.foreground
  property color dim: Qt.darker(foreground, 1.55)
  property color fainter: Qt.darker(foreground, 2.1)
  property color daylightMarker
  // Passed in so the footer's moon agrees with the rows' strips.
  property real moonPhase: 0.5
  // Night dots are dark so they read against the bright continents.
  readonly property color nightMarker: Util.alpha(Color.background, 0.92)
  property string fontFamily: Style.font.family
  property bool hour24: false
  // The panel's offset setting, and the offset "home" is measured from.
  property string offsetMode: "home"
  property int homeOffsetMinutes: 0
  // Cities the list tracks, lower-cased: accent color and first label slots.
  property var trackedNames: []
  // Faded in near the end of the zoom, where footer and jump bar are legible.
  property real chromeOpacity: 1

  // Opaque tones mixed against the background, so the rows behind never show through.
  readonly property color surfaceBase: Color.popups.background
  // Light names over sea, dark over land, split at the coastline.
  readonly property color seaInk: foreground
  readonly property color landInk: surfaceBase

  // Merged into the built-ins so a tracked city always appears. [name, zone, lat, lon, rank]
  property var trackedCities: []
  // Reached with the jump box; the panel never saves them.
  property var sessionCities: []
  property var jumpOptions: []          // the whole zone catalogue, unfiltered

  // Always shown, always labelled, drawn in the accent like the hero globe's marker.
  property var homeRow: []
  readonly property string homeName:
    homeRow.length > 0 ? String(homeRow[0]).toLowerCase() : ""

  property string pendingJump: ""       // waiting on coordinates to arrive

  signal jumpRequested(string label, string zone)
  // The jump box closed; the host should take the keyboard back.
  signal jumpDismissed()
  signal exitRequested()
  // The footer offset was clicked; the panel owns the setting.
  signal offsetModeToggleRequested()
  // Only real selections: -1 means "no city" here but "home" in the list.
  signal citySelected(string label, string zone)
  signal cityTapped(string label, string zone)

  // ---- data -------------------------------------------------------------
  property var land: []            // coastline rings, flat [lon,lat,...]
  property var landCoarse: []      // half the vertices, for the small end of the zoom
  property var cities: []          // [name, zone, lat, lon, rank]
  property var offsets: ({})       // zone -> minutes east of UTC

  property real spin: 20           // degrees; the meridian facing the viewer
  // Latitude under the viewer. Not "tilt": the hero globe uses that for the axial lean.
  property real viewLat: 20
  property real velocity: 0        // degrees per tick, for the throw

  readonly property real dragSpinRate: 0.45     // degrees per pixel
  readonly property real dragTiltRate: 0.35
  readonly property real dragLatLimit: 80
  readonly property real flyLatLimit: 70
  readonly property real throwDecay: 0.96       // per 16 ms tick

  // A "label|zone" key, not an index: allCities is rebuilt as its inputs land
  // and an index would silently move to another city.
  property string selectedKey: ""
  readonly property int selected: {
    if (selectedKey === "") return -1
    for (var i = 0; i < allCities.length; i++)
      if (keyAt(i) === selectedKey) return i
    return -1
  }

  function keyAt(i) {
    var c = allCities[i]
    return (c === undefined || c === null) ? "" : Model.factsKey({ label: c[0], id: c[1] })
  }

  function selectAt(i) { selectedKey = i >= 0 ? keyAt(i) : "" }

  // A click at disc-centered coordinates: select the hit and turn it to face
  // you. A miss only clears. On root so tests share the pointer's code path.
  function pickAt(cx, cy) {
    var hit = hitAt(cx, cy)
    selectAt(hit)
    if (hit >= 0) {
      flyTo(allCities[hit][2], allCities[hit][3])
      cityTapped(allCities[hit][0], allCities[hit][1])
    }
    return hit
  }

  property double nowMs: Date.now()
  property bool dragging: false

  // Both set from Panel, which owns the zoom: 0 in the header, 1 full size.
  property bool transitioning: false
  property real zoomLevel: 1
  property bool smoothMotion: true

  // A full paint is ~14 ms; names and the graticule are the expensive parts,
  // so they drop while the globe moves and nobody can read them anyway.
  readonly property bool reduced: smoothMotion
    && (dragging || flight.running || transitioning || Math.abs(velocity) > 0.01)

  onReducedChanged: canvas.requestPaint()

  readonly property var allCities:
    Model.mergeCities(homeRow, cities, trackedCities, sessionCities)

  readonly property var jumpMatches: jumpSearch.matches
  onJumpMatchesChanged: probeZones()

  // Centering a city is setting spin and viewLat to its own coordinates.
  function flyTo(lat, lon) {
    flight.stop()
    velocity = 0
    flightSpin.from = spin
    flightSpin.to = spin + Solar.shortestTurn(spin, lon)
    flightViewLat.from = viewLat
    flightViewLat.to = Util.clamp(lat, -flyLatLimit, flyLatLimit)
    flight.restart()
  }

  // Home's coordinates can land after the globe on a cold cache; hold the request.
  property bool homePending: false

  // Opening lands on home and selects it, so the footer names it.
  function showHome() {
    if (homeRow.length < 4 || homeRow[2] === undefined || homeRow[2] === null) {
      homePending = true
      return
    }
    homePending = false
    selectAt(indexOfCity(homeRow[0], homeRow[1]))
    flyTo(homeRow[2], homeRow[3])
  }

  onHomeRowChanged: if (homePending) showHome()

  function indexOfCity(label, zone) {
    for (var i = 0; i < allCities.length; i++)
      if (allCities[i][0] === label && allCities[i][1] === zone) return i
    return -1
  }

  function goTo(label, zone) {
    var i = indexOfCity(label, zone)
    if (i >= 0) {
      selectedKey = keyAt(i)
      flyTo(allCities[i][2], allCities[i][3])
      pendingJump = ""
      return
    }
    // Not on the globe yet: ask for it, and fly once its coordinates land.
    pendingJump = label + "|" + zone
    jumpRequested(label, zone)
  }

  onAllCitiesChanged: {
    probeZones()
    canvas.requestPaint()
    if (pendingJump === "") return
    var parts = pendingJump.split("|")
    if (indexOfCity(parts[0], parts[1]) >= 0) goTo(parts[0], parts[1])
  }

  function startJump() {
    jumpSearch.start()
  }

  // Sub-pixel scale (spaceReal, not space) so thin strokes keep their weights.
  readonly property real uiScale: Style.spaceReal(1)

  function scaled(px) { return Solar.scalePx(px, uiScale, 1) }

  readonly property real footerHeight: Style.space(34)
  readonly property real jumpHeight: Style.space(4) + jumpSearch.implicitHeight
  readonly property real radius: Math.max(40,
    Math.min(width, height - footerHeight - jumpHeight) / 2 - Style.space(6))
  readonly property var sub: Solar.subsolarPoint(nowMs)

  // FileView, not XMLHttpRequest: XHR on file:// comes back empty in the shell.
  readonly property string pluginDir: Quickshell.env("OMARCHY_PATH") + "/shell/plugins/panels/elsewhen"

  // "UTC+2" or "+9h", per the panel's setting, exactly as the rows print it.
  function offsetLabelFor(zone) {
    var off = offsets[zone]
    if (off === undefined) return ""
    return offsetMode === "utc" ? Model.utcOffsetLabel(off)
                                : Model.relativeOffsetLabel(off, homeOffsetMinutes)
  }

  function isTracked(i) {
    var c = allCities[i]
    return c !== undefined
           && trackedNames.indexOf(String(c[0]).toLowerCase()) >= 0
  }

  // Guarded: read from paints while the city list is still being assembled.
  function isHome(i) {
    var c = allCities[i]
    return c !== undefined && homeName !== ""
           && String(c[0]).toLowerCase() === homeName
  }

  function cityDaylight(i) {
    var c = allCities[i]
    if (c === undefined) return false
    return Solar.isDaylight(c[2], c[3], sub)
  }

  // Labels count as part of their city and win over a neighbouring dot.
  function hitAt(px, py) {
    var pad = Style.space(3)
    for (var i = 0; i < labels.length; i++) {
      var b = labels[i].box
      if (px >= b.x - pad && px <= b.x + b.w + pad
       && py >= b.y - pad && py <= b.y + b.h + pad) return labels[i].index
    }
    var best = -1, bestD = Style.space(13)
    for (var j = 0; j < plotted.length; j++) {
      var d = Math.hypot(px - plotted[j].x, py - plotted[j].y)
      if (d < bestD) { bestD = d; best = plotted[j].index }
    }
    return best
  }

  // ---- what actually gets drawn -----------------------------------------
  // Near-side cities in priority order, thinned; `keep` always survives.
  readonly property var plotted: {
    if (allCities.length === 0 || radius <= 0) return []
    var cand = []
    for (var i = 0; i < allCities.length; i++) {
      var p = Solar.project(allCities[i][2], allCities[i][3], spin, viewLat, radius)
      if (!p.visible) continue
      var must = isHome(i) || isTracked(i) || i === selected
      cand.push({ index: i, x: p.x, y: p.y, cosc: p.cosc,
                  rank: allCities[i][4], keep: must })
    }
    cand.sort(function(a, b) {
      if (a.keep !== b.keep) return a.keep ? -1 : 1
      if (a.rank !== b.rank) return a.rank - b.rank
      return b.cosc - a.cosc
    })
    return Solar.declutter(cand, Style.space(19))
  }

  // ---- labels -----------------------------------------------------------
  readonly property var labels: {
    if (reduced) return []
    var cand = []
    for (var i = 0; i < plotted.length; i++) {
      var p = plotted[i]
      if (p.cosc < 0.12) continue                  // the rim; labels run off
      cand.push({ index: p.index, name: allCities[p.index][0], x: p.x, y: p.y,
                  rank: p.keep ? 0 : p.rank, cosc: p.cosc })
    }
    var charW = Style.font.caption * 0.62
    return Solar.layoutLabels(cand, charW, Style.font.caption + Style.space(3), 14,
                              width / 2 - Style.space(4), scaled(6))
  }

  FileView {
    path: root.pluginDir + "/world.json"
    printErrors: true
    onLoaded: {
      try {
        root.land = JSON.parse(text())
        var coarse = []
        for (var i = 0; i < root.land.length; i++)
          coarse.push(Solar.decimateRing(root.land[i], 2, 8))
        root.landCoarse = coarse
        canvas.requestPaint()
      } catch (e) { }
    }
  }

  FileView {
    path: root.pluginDir + "/cities.json"
    printErrors: true
    onLoaded: {
      try { root.cities = JSON.parse(text()); root.probeZones() } catch (e) { }
    }
  }

  property bool probeQueued: false

  // Queued rather than dropped while running, or late zones never get an offset.
  // Includes the jump matches, whose offsets tell two results apart.
  function probeZones() {
    if (allCities.length === 0) return
    if (zoneProc.running) { probeQueued = true; return }
    var zones = [], seen = {}
    function add(id) { if (!seen[id]) { seen[id] = true; zones.push(id) } }
    for (var i = 0; i < allCities.length; i++) add(allCities[i][1])
    for (var j = 0; j < jumpMatches.length; j++) add(jumpMatches[j].value)
    zoneProc.command = Model.probeCommand(zones, false)
    zoneProc.running = true
  }

  Process {
    id: zoneProc
    stdout: StdioCollector {
      onStreamFinished: {
        var probe = Model.parseProbe(text)
        var map = {}
        for (var id in probe) map[id] = probe[id].offsetMinutes
        root.offsets = map
        canvas.requestPaint()
        Qt.callLater(function() {
          if (!root.probeQueued) return
          root.probeQueued = false
          root.probeZones()
        })
      }
    }
  }

  Timer { interval: 20000; running: true; repeat: true
          onTriggered: { root.nowMs = Date.now(); canvas.requestPaint() } }
  Timer { interval: 300000; running: true; repeat: true; onTriggered: root.probeZones() }

  ParallelAnimation {
    id: flight
    NumberAnimation { id: flightSpin; target: root; property: "spin"
                      duration: Style.duration(800); easing.type: Easing.OutCubic }
    NumberAnimation { id: flightViewLat; target: root; property: "viewLat"
                      duration: Style.duration(800); easing.type: Easing.OutCubic }
  }

  // The throw: spin keeps going after the drag and eases to a stop.
  Timer {
    interval: 16
    running: !root.dragging && Math.abs(root.velocity) > 0.01
    repeat: true
    onTriggered: {
      root.spin += root.velocity
      root.velocity *= root.throwDecay
      canvas.requestPaint()
    }
  }

  onPlottedChanged: canvas.requestPaint()
  onTrackedNamesChanged: canvas.requestPaint()
  onSpinChanged: canvas.requestPaint()
  onViewLatChanged: canvas.requestPaint()
  onSelectedChanged: {
    canvas.requestPaint()
    var c = selected >= 0 ? allCities[selected] : null
    if (c !== null && c !== undefined) citySelected(String(c[0]), String(c[1]))
  }

  // ---- the globe --------------------------------------------------------
  Canvas {
    id: canvas
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: parent.height - root.footerHeight - root.jumpHeight
    renderStrategy: Canvas.Cooperative

    // The clipped continents from the last paint, reused by the label pass.
    property var landPolys: []

    function paintLabels(ctx, ink) {
      ctx.fillStyle = ink
      for (var i = 0; i < root.labels.length; i++) {
        var L = root.labels[i]
        var idx = L.index
        var city = root.allCities[idx]
        if (city === undefined) continue
        var strong = root.isHome(idx) || root.isTracked(idx)
        ctx.font = (strong ? "bold " : "") + Style.font.caption
                   + "px \"" + root.fontFamily + "\""
        ctx.fillText(city[0], L.box.x, L.box.y + L.box.h / 2)
      }
    }

    // Points arrive as [lat, lon]; runs end exactly on the horizon.
    function strokePath(ctx, pts) {
      var segs = Solar.visibleSegments(pts, root.spin, root.viewLat, root.radius)
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
      var fg = root.foreground

      // Ocean disc.
      ctx.beginPath()
      ctx.arc(0, 0, r, 0, Math.PI * 2)
      ctx.fillStyle = Model.mix(root.surfaceBase, fg, 0.05)
      ctx.fill()
      ctx.lineWidth = root.scaled(1)
      ctx.strokeStyle = Util.alpha(fg, 0.22)
      ctx.stroke()

      // Graticule every 30 degrees, or 60 while moving.
      var gStep = root.reduced ? 60 : 30
      ctx.beginPath()
      var lat, lon, pts, i
      for (lon = -180; lon < 180; lon += gStep) {
        pts = []
        for (lat = -90; lat <= 90; lat += 3) pts.push([lat, lon])
        strokePath(ctx, pts)
      }
      for (lat = -60; lat <= 60; lat += gStep) {
        pts = []
        for (lon = -180; lon <= 180; lon += 3) pts.push([lat, lon])
        strokePath(ctx, pts)
      }
      ctx.lineWidth = root.scaled(1)
      ctx.strokeStyle = Util.alpha(fg, 0.10)
      ctx.stroke()

      // Land, filled bright with no coastline stroke (the stroke pass cost ~4 ms).
      // Coarse rings only below half size, where the dropped islands are invisible.
      var coarseOk = root.reduced && root.zoomLevel < 0.5 && root.landCoarse.length > 0
      var rings = coarseOk ? root.landCoarse : root.land
      var landPolys = []
      ctx.beginPath()
      for (i = 0; i < rings.length; i++) {
        var poly = Solar.clipRingToDisc(rings[i], root.spin, root.viewLat, root.radius)
        if (poly.length < 3) continue
        landPolys.push(poly)
        ctx.moveTo(poly[0].x, poly[0].y)
        for (var q = 1; q < poly.length; q++) ctx.lineTo(poly[q].x, poly[q].y)
        ctx.closePath()
      }
      ctx.fillStyle = Model.mix(root.surfaceBase, fg, 0.92)
      ctx.fill()
      canvas.landPolys = landPolys

      // Day/night line.
      ctx.beginPath()
      strokePath(ctx, Solar.terminator(root.sub, 180))
      ctx.lineWidth = root.scaled(1)
      ctx.strokeStyle = Util.alpha(root.daylightMarker, 0.55)
      ctx.stroke()

      // Cities: gold in daylight, dark at night, each edged in the opposite tone.
      for (var pi = 0; pi < root.plotted.length; pi++) {
        var p = root.plotted[pi]
        i = p.index
        var day = root.cityDaylight(i)
        var isSel = (i === root.selected)
        ctx.beginPath()
        ctx.arc(p.x, p.y, root.scaled(isSel ? 3.6 : 2.2), 0, Math.PI * 2)
        ctx.fillStyle = day ? root.daylightMarker : root.nightMarker
        ctx.fill()
        ctx.lineWidth = root.scaled(1.2)
        ctx.strokeStyle = day ? Util.alpha(Color.background, 0.7) : Util.alpha(fg, 0.85)
        ctx.stroke()
        if (root.isHome(i)) {
          ctx.beginPath()
          ctx.arc(p.x, p.y, root.scaled(3.4), 0, Math.PI * 2)
          ctx.fillStyle = Color.accent
          ctx.fill()
          ctx.lineWidth = root.scaled(1.2)
          ctx.strokeStyle = Util.alpha(Color.background, 0.5)
          ctx.stroke()
          ctx.beginPath()
          ctx.arc(p.x, p.y, root.scaled(6.4), 0, Math.PI * 2)
          ctx.lineWidth = root.scaled(1.4)
          ctx.strokeStyle = Util.alpha(Color.accent, 0.65)
          ctx.stroke()
        } else if (root.isTracked(i)) {
          ctx.beginPath()
          ctx.arc(p.x, p.y, root.scaled(4.6), 0, Math.PI * 2)
          ctx.lineWidth = root.scaled(1.3)
          ctx.strokeStyle = Color.accent
          ctx.stroke()
        }
        if (isSel) {
          ctx.beginPath()
          ctx.arc(p.x, p.y, root.scaled(7.5), 0, Math.PI * 2)
          ctx.lineWidth = root.scaled(1.4)
          ctx.strokeStyle = day ? root.daylightMarker : fg
          ctx.stroke()
        }
      }

      // ---- city names: light everywhere, then dark clipped to the land ----
      ctx.textBaseline = "middle"
      paintLabels(ctx, root.seaInk)

      ctx.save()
      ctx.beginPath()
      for (var lp = 0; lp < landPolys.length; lp++) {
        var poly2 = landPolys[lp]
        ctx.moveTo(poly2[0].x, poly2[0].y)
        for (var r2 = 1; r2 < poly2.length; r2++) ctx.lineTo(poly2[r2].x, poly2[r2].y)
        ctx.closePath()
      }
      ctx.clip()
      paintLabels(ctx, root.landInk)
      ctx.restore()
    }

    MouseArea {
      anchors.fill: parent
      property real lastX: 0
      property real lastY: 0
      property bool moved: false

      onPressed: function(mouse) {
        lastX = mouse.x; lastY = mouse.y
        moved = false
        root.dragging = true
        root.velocity = 0
      }
      onPositionChanged: function(mouse) {
        var dx = mouse.x - lastX, dy = mouse.y - lastY
        if (Math.abs(dx) + Math.abs(dy) > 2) moved = true
        root.spin -= dx * root.dragSpinRate
        root.viewLat = Util.clamp(root.viewLat + dy * root.dragTiltRate,
                                  -root.dragLatLimit, root.dragLatLimit)
        root.velocity = -dx * root.dragSpinRate
        lastX = mouse.x; lastY = mouse.y
      }
      onReleased: function(mouse) {
        root.dragging = false
        if (moved) return
        root.velocity = 0
        root.pickAt(mouse.x - canvas.width / 2, mouse.y - canvas.height / 2)
      }
    }
  }

  GlobeFooter {
    id: footer
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: jumpSearch.top
    anchors.bottomMargin: Style.space(4)
    height: root.footerHeight
    opacity: root.chromeOpacity

    city: root.selected >= 0 ? root.allCities[root.selected] : null
    // The globe's solar daylight, so the mark agrees with the city's dot.
    daylight: footer.has && root.cityDaylight(root.selected)
    clock: footer.has ? Model.formatClock(root.nowMs, root.offsets[footer.city[1]], root.hour24) : ""
    offsetLabel: footer.has ? root.offsetLabelFor(footer.city[1]) : ""
    badge: root.isHome(root.selected) ? "home" : (root.isTracked(root.selected) ? "tracked" : "")
    moonPhase: root.moonPhase
    foreground: root.foreground
    dim: root.dim
    fainter: root.fainter
    daylightMarker: root.daylightMarker
    fontFamily: root.fontFamily
    onOffsetClicked: root.offsetModeToggleRequested()
  }

  // ---- jump to a city -----------------------------------------------------
  // Searches the whole catalogue; a city not on the globe joins for this session.
  CitySearch {
    id: jumpSearch
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    opacity: root.chromeOpacity
    options: root.jumpOptions
    limit: 5
    inlineResults: false
    loading: root.jumpOptions.length === 0
    buttonText: "Jump to a city"
    loadingText: "Loading cities\u2026"
    offsetLabel: function(zoneId) { return Model.utcOffsetLabel(root.offsets[zoneId]) }
    foreground: root.foreground
    dim: root.dim
    fainter: root.fainter
    fontFamily: root.fontFamily
    onPicked: function(label, id) { root.goTo(label, id) }
    onDismissed: root.jumpDismissed()
  }

  // Results overlay the globe so it never resizes under the pointer mid-search.
  Rectangle {
    visible: jumpSearch.active
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: jumpSearch.top
    anchors.bottomMargin: Style.space(4)
    height: Math.min(results.implicitHeight + Style.space(8),
                     parent.height - root.jumpHeight - Style.space(20))
    radius: Style.cornerRadius
    color: root.surfaceBase

    CityMatches {
      id: results
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: Style.space(4)
      citySearch: jumpSearch
    }
  }
}
