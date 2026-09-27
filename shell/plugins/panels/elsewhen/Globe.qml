import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "GlobeModel.js" as Globe
import "Model.js" as Model
import "Sky.js" as Sky

// A spinnable orthographic globe: coastlines, a day/night terminator, and the
// major cities of every time zone. Drag to spin; tap a city for its local
// time. The globe button in the hero returns to the list.
//
// Self-contained on purpose - it owns its own data loading and its own clock
// probe - so removing the feature is deleting this file plus the Loader that
// mounts it. See README, "Globe mode".
Item {
  id: root

  property QtObject bar: null
  property color foreground: Color.foreground
  property color dim: Qt.darker(foreground, 1.55)
  property color fainter: Qt.darker(foreground, 2.1)
  property color daylightMarker: "#E5C736"
  // Tonight's moon, for the footer's marker. Passed in rather than computed
  // here: the panel already works it out for every row's strip, and two
  // calculations of the same sky could disagree by a day.
  property real moonPhase: 0.5
  // Night dots are drawn dark, so they read against the bright continents.
  // Derived from the panel background rather than fixed, so it holds up in a
  // light theme as well as a dark one.
  readonly property color nightMarker: Qt.rgba(Color.background.r, Color.background.g,
                                               Color.background.b, 0.92)
  property string fontFamily: Style.font.family
  property bool hour24: false
  // Which offset the footer prints, and where "home" is measured from. Both
  // come from the panel: the setting is one setting for the whole widget, so
  // flipping it here and flipping it in the list are the same act, and the
  // globe reads back whatever the rows are already showing.
  property string offsetMode: "home"
  property int homeOffsetMinutes: 0
  // Cities the list is already tracking, lower-cased. They get the accent
  // colour and first claim on a label slot.
  property var trackedNames: []
  property bool skyTint: false
  // Faded in near the end of the zoom: at a fraction of full size the footer
  // and the jump bar are illegible specks.
  property real chromeOpacity: 1

  // The globe has to be genuinely opaque, not a tinted pane. Painting the
  // ocean at a low alpha over the panel background gives the right tone but
  // leaves the rows visible straight through it, which ruins the illusion
  // that the globe is a solid object arriving in front of them. These mix the
  // same tones against the background and hand back a colour with no alpha at
  // all.
  readonly property color surfaceBase: Color.popups.background
  // Names are light over the sea and dark over the land, so each half of a
  // name that straddles a coastline contrasts with what is under it.
  readonly property color seaInk: foreground
  readonly property color landInk: surfaceBase
  function solid(tone, t) {
    return Qt.rgba(surfaceBase.r + (tone.r - surfaceBase.r) * t,
                   surfaceBase.g + (tone.g - surfaceBase.g) * t,
                   surfaceBase.b + (tone.b - surfaceBase.b) * t, 1)
  }
  // Tracked cities as [name, zone, lat, lon, rank]. Merged into the globe's
  // own set so a city in the list always appears, even when it is nowhere in
  // cities.json - Copenhagen was exactly that case.
  property var trackedCities: []

  // Cities reached with the jump box. Session-only: the panel never writes
  // them to settings, so they vanish when the panel does.
  property var sessionCities: []
  property var jumpOptions: []          // the whole zone catalogue, unfiltered

  // The city you are in: always on the globe, always labelled, and drawn in
  // its own sky the way the panel globe draws it - so "you" looks the same
  // on both.
  property var homeRow: []
  // The home dot and its label; falls back to the accent when tinting is off.
  readonly property color homeSky: {
    for (var i = 0; i < allCities.length; i++) {
      if (!isHome(i)) continue
      var hex = skyOf(i)
      return hex === "" ? Color.accent : hex
    }
    return Color.accent
  }
  readonly property string homeName:
    homeRow.length > 0 ? String(homeRow[0]).toLowerCase() : ""

  property bool jumping: false
  property string jumpQuery: ""
  property string pendingJump: ""       // waiting on coordinates to arrive

  signal jumpRequested(string label, string zone)
  // The jump box has closed and is no longer entitled to the keyboard.
  signal jumpDismissed()

  signal exitRequested()

  // The footer's offset was clicked. The globe does not own the setting - it
  // asks the panel to flip it, and the change comes back down through
  // offsetMode like any other.
  signal offsetModeToggleRequested()

  // The globe's selection, on its way back to the list so a city picked here
  // is still the focused one when the globe closes. Carries the label and the
  // zone rather than an index: `selected` indexes the globe's own catalogue,
  // which the list has no way to read.
  //
  // Only a real selection is announced. Clicking empty ocean clears the
  // selection, which on the globe means "no city"; -1 in the list means home,
  // so forwarding it would send the list somewhere nobody asked to go.
  signal citySelected(string label, string zone)

  // ---- data -------------------------------------------------------------
  property var land: []            // coastline rings, flat [lon,lat,...]
  // The same coastlines at half the vertices, built once when the file lands
  // and used only while the globe is riding the zoom - see decimateRing.
  property var landCoarse: []
  property var cities: []          // [name, zone, lat, lon, rank]
  property var offsets: ({})       // zone -> minutes east of UTC

  property real spin: 20           // degrees; the meridian facing the viewer
  // Degrees; the latitude the viewer is over. Named viewLat and not tilt:
  // the hero globe in the panel uses "tilt" for Earth's axial lean, an
  // unrelated angle, and the two meanings sharing one word cost an hour.
  property real viewLat: 20
  property real velocity: 0        // degrees per tick, for the throw
  // The selection is held as the city's own "label|zone" and not as an index.
  //
  // allCities is a binding over home, the built-ins, the tracked rows and the
  // session cities, so it is rebuilt whenever any of those lands - and an
  // index into it then silently means a different city. Opening the globe on
  // a focused Auckland and finding the footer naming Honolulu was exactly
  // this: the flight was right, the index had moved under it. A key survives
  // the rebuild; an index only looks like it does.
  property string selectedKey: ""
  readonly property int selected: {
    if (selectedKey === "") return -1
    for (var i = 0; i < allCities.length; i++)
      if (keyAt(i) === selectedKey) return i
    return -1
  }

  function keyAt(i) {
    var c = allCities[i]
    return (c === undefined || c === null) ? ""
         : String(c[0]) + "|" + String(c[1])
  }

  function selectAt(i) { selectedKey = i >= 0 ? keyAt(i) : "" }

  // A pick on the globe itself, in canvas coordinates measured from the disc's
  // centre. Selects what was hit and brings it round to face you, the same as
  // opening the globe or jumping to a city already does. A pick left where it
  // was landed off centre and often near the limb, where the projection is at
  // its most foreshortened and the city just chosen is the least legible thing
  // on the globe; the click was the one way of choosing that did not centre.
  //
  // Only on a hit. Tapping open ocean clears the selection, and turning the
  // globe because someone missed would be answering a gesture nobody made.
  //
  // A function on the root rather than a body inside the MouseArea, so a test
  // can exercise the same code the pointer does instead of a copy of it.
  function pickAt(cx, cy) {
    var hit = hitAt(cx, cy)
    selectAt(hit)
    if (hit >= 0) flyTo(allCities[hit][2], allCities[hit][3])
    return hit
  }

  property double nowMs: Date.now()
  property bool dragging: false

  // True while the panel is between the list and the globe. Set from Panel,
  // which owns the zoom.
  property bool transitioning: false
  // How big the globe is being drawn, 0 in the header to 1 filling the panel.
  // Set from Panel, which owns the zoom.
  property real zoomLevel: 1
  // The kill switch for everything below. Off means always draw at full
  // detail, however that costs.
  property bool smoothMotion: true

  // Whether the globe is moving right now - turning, being dragged, coasting
  // after a throw, or riding the zoom in or out of the panel.
  //
  // A moving globe is drawn with less in it. Measured on this machine, a full
  // paint costs about 14ms, which is already over a 120Hz frame at 8.3ms, and
  // the globe was managing roughly 20 paints a second whenever it moved. The
  // two expensive parts are the city names - the layout, and two passes of
  // text, one of them through a clip rebuilt from every coastline - and the
  // graticule, which is 17 stroked polylines. Dropping both while the globe
  // is in motion roughly doubled the frame rate in measurement.
  //
  // Nothing is lost that could be read: names on a turning globe are a smear,
  // and during the zoom the whole thing is a few dozen pixels across. Detail
  // comes back the moment it stops, which is the only time anyone reads it.
  readonly property bool reduced: smoothMotion
    && (dragging || flight.running || transitioning || Math.abs(velocity) > 0.01)

  // The globe stopped moving: draw it properly.
  onReducedChanged: canvas.requestPaint()

  readonly property var allCities: {
    var out = []
    var seen = {}
    // Home first, so a tracked row or a built-in of the same name does not
    // shadow it and it keeps its own marker.
    if (homeRow.length > 0 && homeRow[2] !== undefined) {
      out.push(homeRow)
      seen[String(homeRow[0]).toLowerCase()] = true
    }
    for (var b = 0; b < cities.length; b++) {
      var bk = String(cities[b][0]).toLowerCase()
      if (seen[bk]) continue
      seen[bk] = true
      out.push(cities[b])
    }
    for (var j = 0; j < trackedCities.length; j++) {
      var t = trackedCities[j]
      if (t[2] === null || t[2] === undefined) continue
      var key = String(t[0]).toLowerCase()
      if (seen[key]) continue
      seen[key] = true
      out.push(t)
    }
    for (var m = 0; m < sessionCities.length; m++) {
      var c = sessionCities[m]
      if (c[2] === null || c[2] === undefined) continue
      var ck = String(c[0]).toLowerCase()
      if (seen[ck]) continue
      seen[ck] = true
      out.push(c)
    }
    return out
  }

  readonly property var jumpMatches:
    jumping ? Model.searchZones(jumpOptions, jumpQuery, 5) : []

  // Which match the keyboard is on, by the same rules as the panel's city
  // search: an index rather than the match itself, because the list is rebuilt
  // on every keystroke; back to the top whenever the query changes, because
  // the list under the selection has been replaced; and wrapping, because five
  // results are entirely on screen and there is no edge to guard.
  property int jumpIndex: 0
  onJumpQueryChanged: jumpIndex = 0
  onJumpMatchesChanged: {
    if (jumpIndex >= jumpMatches.length) jumpIndex = 0
    probeZones()
  }

  function moveJumpSelection(delta) {
    var count = jumpMatches.length
    if (count === 0) { jumpIndex = 0; return }
    jumpIndex = ((jumpIndex + delta) % count + count) % count
  }

  function commitJump() {
    if (jumpMatches.length === 0) return
    var hit = jumpMatches[Math.max(0, Math.min(jumpIndex, jumpMatches.length - 1))]
    goTo(hit.label, hit.value)
    stopJump()
  }

  // Turn and lean the globe until a city is centred. Spin is the longitude
  // facing the viewer and viewLat is the latitude under it, so centring is just
  // setting them to the city's own coordinates - taking the short way round,
  // as the panel globe does.
  function flyTo(lat, lon) {
    var d = lon - spin
    while (d > 180) d -= 360
    while (d <= -180) d += 360
    flight.stop()
    velocity = 0
    flightSpin.from = spin
    flightSpin.to = spin + d
    flightViewLat.from = viewLat
    flightViewLat.to = Math.max(-70, Math.min(70, lat))
    flight.restart()
  }

  // Turn to the city you are in when the globe opens. Held rather than
  // dropped if home is not known yet: the coordinates arrive from the
  // fetcher's geocode, which on a cold cache lands after the globe does.
  property bool homePending: false

  // Opening the globe lands on the city you are in - and selects it, so the
  // footer names it like any other pick. Flying without selecting left the
  // globe pointed at home with nothing written underneath, which read as a
  // bug in the footer rather than as "nothing is selected yet": the marker
  // was clearly on a city.
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
    jumpQuery = ""
    jumpIndex = 0
    jumping = true
    Qt.callLater(function() { jumpField.text = ""; jumpField.forceActiveFocus() })
  }

  function stopJump() {
    jumping = false
    jumpQuery = ""
    // The field that was taking the keys is now hidden, and a hidden item
    // keeps its focus - so every key after this went into it and vanished,
    // Escape included. Whoever is hosting the globe has to take the keyboard
    // back; this globe does not know who that is.
    jumpDismissed()
  }

  // How much bigger everything drawn is than its pixel literal, so stroke
  // widths and marker radii track the shell's base font size the way the
  // globe's own radius and the city labels already do.
  //
  // Style.spaceReal and not Style.space: space() rounds to whole pixels,
  // which would flatten every sub-pixel stroke here to a flat 1 and lose the
  // weight difference between a city's edge and its selection ring. This is
  // the same scale radius and padding below are built from, so the drawing
  // moves as one piece rather than in two halves.
  readonly property real uiScale: Style.spaceReal(1)

  // Every drawn constant in the canvas goes through here, so the rule lives
  // in one tested place instead of being re-derived at each call site.
  function scaled(px) { return Globe.scalePx(px, uiScale, 1) }

  readonly property real footerHeight: Style.space(34)
  readonly property real jumpHeight: Style.space(34)
  readonly property real radius: Math.max(40,
    Math.min(width, height - footerHeight - jumpHeight) / 2 - Style.space(6))
  readonly property var sub: Globe.subsolarPoint(nowMs)

  // Data files sit next to this one. FileView rather than XMLHttpRequest:
  // XHR against a file:// URL comes back empty inside the shell.
  readonly property string here: {
    var u = Qt.resolvedUrl(".").toString()
    return u.replace(/^file:\/\//, "").replace(/\/$/, "")
  }

  function zoneTime(zone) {
    var off = offsets[zone]
    if (off === undefined) return ""
    var d = new Date(nowMs + off * 60000)
    var h = d.getUTCHours(), m = d.getUTCMinutes()
    var mm = (m < 10 ? "0" : "") + m
    if (hour24) return (h < 10 ? "0" : "") + h + ":" + mm
    var h12 = h % 12; if (h12 === 0) h12 = 12
    return h12 + ":" + mm + (h < 12 ? " AM" : " PM")
  }

  // The same two readings the rows offer, chosen by the same setting: where
  // the zone actually sits ("UTC+2"), or how far it is from you ("+9h"). A
  // zone on your own offset has no relative label - saying "same time" to
  // someone who can read both clocks is noise - so that case falls back to
  // nothing, exactly as it does in the list.
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

  // The sky over any city on the globe. Computed here rather than handed in:
  // every city already carries its coordinates, so the panel does not need to
  // ship a colour table alongside them.
  function skyOf(i) {
    if (!skyTint) return ""
    var c = allCities[i]
    if (c === undefined) return ""
    var hex = Sky.tint(Globe.solarElevation(c[2], c[3], sub))
    return hex === null ? "" : hex
  }

  // Guarded, along with the two below. These are read both from bindings and
  // from inside a paint, and the city list is assembled in stages as the file
  // load, the tracked rows and the session cities each arrive - so an index
  // can briefly outlive the array it came from.
  function isHome(i) {
    var c = allCities[i]
    return c !== undefined && homeName !== ""
           && String(c[0]).toLowerCase() === homeName
  }

  function cityDaylight(i) {
    var c = allCities[i]
    if (c === undefined) return false
    return Globe.isDaylight(c[2], c[3], sub)
  }

  // Nearest city to a point, for click-to-select.
  // What a click at this point selects. Label text counts as part of its city
  // - a name is a far easier target than a two-pixel dot - and is checked
  // first, since a label sits beside its own dot and would otherwise lose to
  // a neighbouring one.
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
  // Cities on the near side, in priority order, thinned so a dense region
  // shows a few legible cities rather than a smear. Tracked cities and the
  // current selection carry `keep` and always survive the thinning.
  readonly property var plotted: {
    if (allCities.length === 0 || radius <= 0) return []
    var cand = []
    for (var i = 0; i < allCities.length; i++) {
      var p = Globe.project(allCities[i][2], allCities[i][3], spin, viewLat, radius)
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
    return Globe.declutter(cand, Style.space(19))
  }

  // ---- labels -----------------------------------------------------------
  // Recomputed whenever the view moves; the greedy pass in GlobeModel keeps
  // names from stacking on top of each other.
  readonly property var labels: {
    // Not merely unpainted - not laid out either. layoutLabels is the
    // expensive half, and it ran on every frame of every turn.
    if (reduced) return []
    var cand = []
    for (var i = 0; i < plotted.length; i++) {
      var p = plotted[i]
      if (p.cosc < 0.12) continue                  // the rim; labels run off
      cand.push({ index: p.index, name: allCities[p.index][0], x: p.x, y: p.y,
                  rank: p.keep ? 0 : p.rank, cosc: p.cosc })
    }
    var charW = Style.font.caption * 0.62
    // Bounded, so a name near the right limb is placed to the left of its dot
    // rather than running off the edge of the panel.
    return Globe.layoutLabels(cand, charW, Style.font.caption + Style.space(3), 14,
                              width / 2 - Style.space(4), scaled(6))
  }

  FileView {
    path: root.here + "/world.json"
    printErrors: true
    onLoaded: {
      try {
        root.land = JSON.parse(text())
        var coarse = []
        for (var i = 0; i < root.land.length; i++)
          coarse.push(Globe.decimateRing(root.land[i], 2, 8))
        root.landCoarse = coarse
        canvas.requestPaint()
      } catch (e) { }
    }
  }

  FileView {
    path: root.here + "/cities.json"
    printErrors: true
    onLoaded: {
      try { root.cities = JSON.parse(text()); root.probeZones() } catch (e) { }
    }
  }

  property bool probeQueued: false

  // The city set grows in two steps - the built-ins land when the file loads,
  // the tracked ones when the panel binds them - so a probe is often already
  // running when the set changes. Queue it rather than dropping it, or the
  // zones that arrived late never get an offset.
  function probeZones() {
    if (allCities.length === 0) return
    if (zoneProc.running) { probeQueued = true; return }
    var zones = [], seen = {}
    for (var i = 0; i < allCities.length; i++) {
      zones.push(allCities[i][1])
      seen[allCities[i][1]] = true
    }
    // The cities the search is offering, which are not on the globe yet and
    // so are not in allCities. Their offsets are wanted before they are
    // picked, not after: the offset is half of what tells two results apart.
    for (var j = 0; j < jumpMatches.length; j++) {
      var id = jumpMatches[j].value
      if (!seen[id]) { seen[id] = true; zones.push(id) }
    }
    zoneProc.command = ["bash", "-c",
      "for z in \"$@\"; do TZ=\"$z\" date \"+$z|%z\"; done", "bash"].concat(zones)
    zoneProc.running = true
  }

  Process {
    id: zoneProc
    stdout: StdioCollector {
      onStreamFinished: {
        var map = {}
        var lines = String(text).split("\n")
        for (var i = 0; i < lines.length; i++) {
          var parts = lines[i].split("|")
          if (parts.length < 2) continue
          var m = /^([+-])(\d{2})(\d{2})$/.exec(parts[1].trim())
          if (!m) continue
          var mins = parseInt(m[2], 10) * 60 + parseInt(m[3], 10)
          map[parts[0].trim()] = m[1] === "-" ? -mins : mins
        }
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
                      duration: 800; easing.type: Easing.OutCubic }
    NumberAnimation { id: flightViewLat; target: root; property: "viewLat"
                      duration: 800; easing.type: Easing.OutCubic }
  }

  // The throw: spin keeps going after the drag and eases to a stop.
  Timer {
    interval: 16
    running: !root.dragging && Math.abs(root.velocity) > 0.01
    repeat: true
    onTriggered: {
      root.spin += root.velocity
      root.velocity *= 0.96
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

    // The clipped continents from the last paint, reused by the label pass.
    property var landPolys: []

    // City names are drawn twice: once light over everything, then again dark
    // through a clip of the continents. A name that straddles a coastline
    // comes out dark on the land half and light on the sea half, so every
    // part of it sits against something it contrasts with. An outline cannot
    // do that - it only fattens the letters and dulls both halves.
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
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: parent.height - root.footerHeight - root.jumpHeight
    renderStrategy: Canvas.Cooperative

    // Points arrive as [lat, lon]. Runs begin and end exactly on the horizon
    // rather than at the last vertex before it, so lines do not snap by up to
    // a segment as the globe turns. Shared with the panel globe.
    function strokePath(ctx, pts) {
      var segs = Globe.visibleSegments(pts, root.spin, root.viewLat, root.radius)
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
      ctx.fillStyle = root.solid(fg, 0.05)
      ctx.fill()
      ctx.lineWidth = root.scaled(1)
      ctx.strokeStyle = Qt.rgba(fg.r, fg.g, fg.b, 0.22)
      ctx.stroke()

      // Graticule every 30 degrees, or every 60 while the globe is moving:
      // 17 stroked polylines against 8, and at 10% alpha on a globe in motion
      // the difference is not something the eye can catch.
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
      // Set explicitly rather than inheriting whatever the ocean disc left
      // on the context - that was an invisible dependency between two passes
      // that only held while both wanted the same width.
      ctx.lineWidth = root.scaled(1)
      ctx.strokeStyle = Qt.rgba(fg.r, fg.g, fg.b, 0.10)
      ctx.stroke()

      // Land: filled bright, as on the panel globe, so the two read as the
      // same planet. Anything dimmer and the labels have to compete with a
      // mid-tone continent, which is exactly what makes them hard to read.
      //
      // No separate coastline stroke: the fill's own edge is the coastline,
      // and that second pass over every ring was the expensive part - filling
      // and stroking measured 13.4ms a paint against 9.1ms for filling alone
      // and 8.1ms for the outlines this replaced.
      // Kept, because the label pass below reuses exactly this shape as a
      // clip so that text lands dark on the continents and light on the sea.
      // Half the vertices while the globe is riding the zoom: it is scaled
      // down to a fraction of its size then, so the dropped points are not on
      // screen to be missed. A drag or a throw keeps every one of them - the
      // globe is full size for those, and the coast would visibly simplify.
      // Half the vertices, but only while the globe is drawn at less than
      // half size. Tying this to "is it transitioning" rather than "how big is
      // it" would have kept the coarse coastline through the slow tail of the
      // zoom, where the globe is nearly full size and the missing islands are
      // there to be seen - then snapped them back in. The easing spends its
      // early, fast frames down here, which is where the dropped frames were.
      var coarseOk = root.reduced && root.zoomLevel < 0.5 && root.landCoarse.length > 0
      var rings = coarseOk ? root.landCoarse : root.land
      var landPolys = []
      ctx.beginPath()
      for (i = 0; i < rings.length; i++) {
        var poly = Globe.clipRingToDisc(rings[i], root.spin, root.viewLat, root.radius)
        if (poly.length < 3) continue
        landPolys.push(poly)
        ctx.moveTo(poly[0].x, poly[0].y)
        for (var q = 1; q < poly.length; q++) ctx.lineTo(poly[q].x, poly[q].y)
        ctx.closePath()
      }
      ctx.fillStyle = root.solid(fg, 0.92)
      ctx.fill()
      canvas.landPolys = landPolys



      // Day/night line.
      ctx.beginPath()
      strokePath(ctx, Globe.terminator(root.sub, 180))
      ctx.lineWidth = root.scaled(1)
      ctx.strokeStyle = Qt.rgba(root.daylightMarker.r, root.daylightMarker.g,
                                root.daylightMarker.b, 0.55)
      ctx.stroke()

      // Cities: gold in daylight, pale at night - the same rule the list uses.
      for (var pi = 0; pi < root.plotted.length; pi++) {
        var p = root.plotted[pi]
        i = p.index
        var day = root.cityDaylight(i)
        var isSel = (i === root.selected)
        ctx.beginPath()
        ctx.arc(p.x, p.y, root.scaled(isSel ? 3.6 : 2.2), 0, Math.PI * 2)
        // Gold in daylight, dark at night - the same rule the daylight strips
        // in the list use. The night colour is a dark ink rather than a pale
        // one: the continents are filled bright, and a pale dot sitting on
        // one reads as an empty ring. (With skyTint on, each dot takes its
        // own sky instead.)
        var sky = root.skyOf(i)
        ctx.fillStyle = sky !== "" ? sky
                      : (day ? root.daylightMarker : root.nightMarker)
        ctx.fill()
        // Every dot is edged so it survives whichever background it lands on:
        // a dark ring around a light dot, a light ring around a dark one.
        var lightDot = sky !== "" || day
        ctx.lineWidth = root.scaled(1.2)
        ctx.strokeStyle = lightDot ? Qt.rgba(0, 0, 0, 0.7)
                                   : Qt.rgba(fg.r, fg.g, fg.b, 0.85)
        ctx.stroke()
        if (root.isHome(i)) {
          // Same treatment as the panel globe: the dot in its own sky, a dark
          // edge so a daylight sky does not vanish into the land, and a halo.
          ctx.beginPath()
          ctx.arc(p.x, p.y, root.scaled(3.4), 0, Math.PI * 2)
          ctx.fillStyle = root.homeSky
          ctx.fill()
          ctx.lineWidth = root.scaled(1.2)
          ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.5)
          ctx.stroke()
          ctx.beginPath()
          ctx.arc(p.x, p.y, root.scaled(6.4), 0, Math.PI * 2)
          ctx.lineWidth = root.scaled(1.4)
          ctx.strokeStyle = Qt.rgba(root.homeSky.r, root.homeSky.g,
                                    root.homeSky.b, 0.65)
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

      // ---- city names, in two tones -------------------------------------
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
        root.spin -= dx * 0.45
        root.viewLat = Math.max(-80, Math.min(80, root.viewLat + dy * 0.35))
        root.velocity = -dx * 0.45
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

  // ---- footer -----------------------------------------------------------
  // Blank until a city is picked; the height stays reserved either way so the
  // globe does not shift. The parts are separate items in a centred Row, so
  // the gaps between them are pixel values rather than runs of monospace
  // spaces, and the whole line sits under the middle of the globe.
  Item {
    id: footer
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: jumpBar.top
    height: root.footerHeight
    opacity: root.chromeOpacity

    readonly property bool has: root.selected >= 0
    readonly property var city: has ? root.allCities[root.selected] : null

    // Two lines. The zone and its offset will not fit beside the name at this
    // width - "Johannesburg Africa/Johannesburg UTC+2 7:50 PM daylight" runs
    // off the end of the panel - and the footer's reserved height already
    // holds two caption lines, so nothing above it has to move.
    Column {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(1)
      visible: parent.has

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: Style.space(7)

      // The same mark the rows carry on their strips: a lit dot by day, and
      // tonight's moon by night. One vocabulary for what the sky is doing
      // there, wherever the city happens to be named.
      //
      // Judged by this globe's own daylight, which is real solar geometry
      // rather than the rows' fixed civil hours - so it agrees with the dot
      // already drawn on the city an inch above it. Those two definitions
      // disagree near sunrise, and of the two disagreements the visible one
      // is worse.
      // The mark and the name are their own Row inside the line, so the gap
      // between them can be tighter than the gaps between everything else -
      // the mark belongs to the name, not to the row of facts after it.
      Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(4)

        // Measured, not guessed: the mark is exactly the cap height of the
        // name beside it. tightBoundingRect is the ink of the glyph rather
        // than its line box, which is the number the eye compares against.
        //
        // One pixel under that measurement, which is what actually rasterises
        // to the same height as the M: a circle's antialiased edge reads a
        // pixel wider than a glyph's, so taking the number at face value drew
        // a dot one pixel taller than the capital beside it. Counted, not
        // guessed - the two now come out at 14 device pixels each.
        //
        // Do not shrink it further. Two pixels under the cap turned the moon
        // into a bullet point; a crescent needs room to be a crescent.
        TextMetrics {
          id: capHeight
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          font.weight: Font.DemiBold
          text: "M"
        }

        Rectangle {
          // Standing on the name's own baseline, so it occupies exactly the
          // band the capital does and cannot ride above the cap or hang below
          // the letters.
          //
          // Positioned rather than anchored. `anchors.baseline` looks like the
          // right tool and is not: inside a Row, anchoring to a sibling whose
          // own position depends on the Row's height is a loop, and it settled
          // by dropping the dot onto the line underneath, on top of the zone
          // name. A Row leaves y alone, so both items start at the top of it
          // and the dot's underside can be put on the baseline directly -
          // Text publishes that as baselineOffset, the ascent of its first
          // line, which is the same number the glyph is drawn from.
          y: cityName.baselineOffset - height
          width: Math.max(6, Math.round(capHeight.tightBoundingRect.height) - 1)
          height: width
          radius: width / 2
          visible: footer.has
          readonly property bool day: footer.has && root.cityDaylight(root.selected)
          color: day ? root.daylightMarker : "transparent"

          MoonDot {
            anchors.fill: parent
            visible: !parent.day
            phase: root.moonPhase
            color: root.foreground
          }
        }

        Text {
          id: cityName
          textFormat: Text.PlainText
          text: footer.has ? footer.city[0] : ""
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          font.weight: Font.DemiBold
        }
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: footer.has ? root.zoneTime(footer.city[1]) : ""
        visible: text !== ""
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: root.isHome(root.selected) ? "home" : "tracked"
        visible: footer.has
                 && (root.isHome(root.selected) || root.isTracked(root.selected))
        color: root.isHome(root.selected) ? root.homeSky : Color.accent
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }
    }

    // Which zone that city keeps, and where the zone is. The offset reads
    // whichever way the list is reading - click it to swap both at once, the
    // same gesture and the same setting as the offset on a row. The zone name
    // is part of the target rather than only the number: on your own home
    // city the relative offset is blank, and a control that vanishes on one
    // city out of the list is not a control.
    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: Style.space(6)

      Text {
        textFormat: Text.PlainText
        text: footer.has ? footer.city[1] : ""
        color: offsetHover.hovered ? root.dim : root.fainter
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        textFormat: Text.PlainText
        text: footer.has ? root.offsetLabelFor(footer.city[1]) : ""
        visible: text !== ""
        color: offsetHover.hovered ? root.foreground : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      HoverHandler {
        id: offsetHover
        cursorShape: Qt.PointingHandCursor
      }
      TapHandler { onTapped: root.offsetModeToggleRequested() }
    }
    }
  }

  // ---- jump to a city -----------------------------------------------------
  // Search the whole zone catalogue and turn the globe to whatever is picked.
  // A city that is not on the globe is added for this session only - nothing
  // is saved, so there is nothing to tidy up later. Want it again, type it
  // again.
  Item {
    id: jumpBar
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: root.jumpHeight
    opacity: root.chromeOpacity

    Rectangle {
      anchors.fill: parent
      anchors.topMargin: Style.space(4)
      visible: !root.jumping
      radius: Style.cornerRadius
      color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b,
                     jumpHover.hovered ? 0.10 : 0.05)

      Text {
        anchors.centerIn: parent
        text: "Jump to a city"
        color: jumpHover.hovered ? root.foreground : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      HoverHandler { id: jumpHover; cursorShape: Qt.PointingHandCursor }
      TapHandler { onTapped: root.startJump() }
    }

    TextField {
      id: jumpField
      visible: root.jumping
      anchors.fill: parent
      anchors.topMargin: Style.space(4)
      placeholderText: "Search cities\u2026"
      foreground: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      onTextChanged: root.jumpQuery = text
      Keys.onEscapePressed: root.stopJump()
      Keys.onReturnPressed: root.commitJump()
      Keys.onEnterPressed: root.commitJump()
      // The results grow upward out of this field, but the first match is at
      // the top of them, so Down still moves down the screen as well as down
      // the list. Nothing to invert.
      Keys.onUpPressed: root.moveJumpSelection(-1)
      Keys.onDownPressed: root.moveJumpSelection(1)
    }
  }

  // Results sit over the globe rather than growing the panel, so the globe
  // never resizes underneath the pointer while a search is being typed.
  Rectangle {
    visible: root.jumping
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: jumpBar.top
    height: Math.min(results.implicitHeight + Style.space(8),
                     parent.height - root.jumpHeight - Style.space(20))
    radius: Style.cornerRadius
    color: root.surfaceBase

    Column {
      id: results
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: Style.space(4)
      spacing: Style.space(1)

      Repeater {
        model: root.jumpMatches

        Rectangle {
          id: hit
          required property var modelData
          required property int index

          // Two marks, not one: a pointer resting over the results must not
          // pull the selection away from the arrow keys mid-search.
          readonly property bool selected: root.jumpIndex === hit.index

          width: parent.width
          implicitHeight: Style.spacing.popupRowHeight
          radius: Style.cornerRadius
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b,
                         hit.selected ? 0.20 : (hitHover.hovered ? 0.10 : 0.0))

          Text {
            anchors.left: parent.left
            anchors.leftMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: hit.modelData.label
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          Row {
            anchors.right: parent.right
            anchors.rightMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(6)

            Text {
              textFormat: Text.PlainText
              text: hit.modelData.value
              color: root.fainter
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }

            Text {
              textFormat: Text.PlainText
              text: Model.utcOffsetLabel(root.offsets[hit.modelData.value])
              visible: text !== ""
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }
          }

          HoverHandler { id: hitHover; cursorShape: Qt.PointingHandCursor }
          TapHandler {
            onTapped: {
              root.goTo(hit.modelData.label, hit.modelData.value)
              root.stopJump()
            }
          }
        }
      }

      Text {
        visible: root.jumpMatches.length === 0
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        topPadding: Style.space(4)
        textFormat: Text.PlainText
        text: root.jumpOptions.length === 0 ? "Loading cities\u2026" : "No matches"
        color: root.fainter
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }
    }
  }
}
