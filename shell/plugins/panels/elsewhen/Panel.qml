import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model
import "GlobeModel.js" as Solar

// A bar button that opens a panel of clocks, one row per city, and zooms into
// a globe. QML has no Intl, so a `date` probe supplies each zone's offset and
// the rows tick locally against it; the probe re-runs on open and every five
// minutes to catch DST.
Panel {
  id: root
  moduleName: "omarchy.elsewhen"
  ipcTarget: "omarchy.elsewhen"
  manageIpc: false


  // ---- settings
  readonly property var zones: Model.parseZones(setting("zones", ""))
  readonly property var zoneIds: zones.map(function(z) { return z.id })
  // Never written: the first probe seeds the list around the local zone.
  readonly property bool needsSeed: String(setting("zones", "")).trim() === ""
  readonly property var probeIds: needsSeed ? zoneIds.concat(Model.seedCandidateZones()) : zoneIds

  readonly property bool autoHour24: Model.usesTwentyFourHour(Qt.locale().timeFormat(Locale.ShortFormat))
  readonly property bool hour24: Model.resolveHour24(setting("hour24", ""), autoHour24)
  // "home" shows the distance from here ("+2h"), "utc" the zone itself ("UTC-5").
  readonly property string offsetMode: setting("offsetMode", "home") === "utc" ? "utc" : "home"
  // Only the US measurement system means Fahrenheit.
  readonly property string autoUnits: Qt.locale().measurementSystem === Locale.ImperialUSSystem ? "F" : "C"
  readonly property string units: Model.resolveUnits(setting("units", ""), autoUnits)
  readonly property bool globeEnabled: setting("globeEnabled", true) !== false
  // Draw the globe with less in it while it moves.
  readonly property bool smoothMotion: setting("smoothMotion", true) !== false

  function toggleHour24() { persistSettings({ hour24: !hour24 }) }
  function toggleOffsetMode() { persistSettings({ offsetMode: offsetMode === "utc" ? "home" : "utc" }) }
  function toggleUnits() { persistSettings({ units: units === "C" ? "F" : "C" }) }

  function offsetTextFor(rowData) {
    if (!rowData || !rowData.ready) return ""
    return offsetMode === "utc" ? Model.utcOffsetLabel(rowData.offsetMinutes) : rowData.relative
  }

  // ---- state
  property var probe: ({})
  property var searchProbe: ({})
  property string zoneCatalogText: ""
  property var facts: ({})
  // Geocoder answers are final for the session; fallbacks are retried.
  property var geo: ({})
  property var fallbackGeo: ({})
  property var weather: ({})
  // Cities jumped to on the globe; never persisted.
  property var sessionCities: []
  property int localOffsetMinutes: -(new Date().getTimezoneOffset())
  property string localZone: ""
  property double nowMs: Date.now()
  property bool probeQueued: false
  property bool searchProbeQueued: false
  property bool factsQueued: false

  readonly property bool adding: citySearch.active
  onAddingChanged: if (!adding) scroller.scrollToTop()
  readonly property var zoneOptions: Model.zoneOptions(zoneCatalogText, zones)
  // The globe's jump box may go to a city that is already tracked.
  readonly property var allZoneOptions: Model.zoneOptions(zoneCatalogText, [])
  readonly property var searchZoneIds: {
    var out = []
    for (var i = 0; i < citySearch.matches.length; i++) {
      var id = citySearch.matches[i].value
      if (out.indexOf(id) < 0) out.push(id)
    }
    return out
  }
  onSearchZoneIdsChanged: probeSearchZones()

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property color fainter: Qt.darker(foreground, 2.1)
  // A literal gold: several themes' "yellow" is not yellow.
  readonly property color daylightMarker: "#E5C736"
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  // ---- the zoom
  // One number drives the list-to-globe transition: 0 is the list, 1 the globe.
  property bool globeMode: false
  property real zoom: globeMode ? 1 : 0
  readonly property bool zoomIdle: zoom === 0 || zoom === 1
  readonly property real bigGlobeOpacity: Util.clamp(zoom / 0.12, 0, 1)
  readonly property real globeStageHeight: Style.space(378)
  // Far enough for the top row to fall past the whole list.
  readonly property real knockFall: listWrap.implicitHeight + Style.space(220)

  // Shift-click the globe to run the transition at a third of the speed.
  readonly property int slowMotionFactor: 3
  // Set before globeMode flips, so the animation never reads a stale duration.
  property int zoomDuration: 800
  property int zoomEasing: Easing.OutQuart

  function setGlobeMode(on, slow) {
    if (on) addSelected = false
    zoomDuration = (on ? 800 : 500) * (slow === true ? slowMotionFactor : 1)
    zoomEasing = on ? Easing.OutQuart : Easing.InOutCubic
    globeMode = on
    if (on && globeLoader.item) showFocusOnGlobe()
  }

  // The globe opens on the list's focus, when its coordinates are known.
  function showFocusOnGlobe() {
    var g = globeLoader.item
    if (!g) return
    if (focusIndex >= 0 && focusKnown) g.goTo(focusZone.label, focusZone.id)
    else g.showHome()
  }

  function claimHome(label, zone) {
    var stored = Model.homeCityAfterTap(label, zone, setting("homeCity", ""), localZone)
    if (stored === null) return
    persistSettings({ homeCity: stored })
    refreshFacts()
  }

  function focusFromGlobe(label, zone) {
    var i = Model.indexOfZone(zones, label, zone)
    if (i >= 0) focusOn(i)
  }

  // The little globe's center in stage coordinates, where the big one grows
  // from. The unused sum makes it recompute when the layout above moves.
  readonly property var heroCenter: {
    var _ = hero.icon.width + hero.icon.height + stage.y + stage.width
    var pt = hero.icon.mapToItem(stage, hero.icon.width / 2, hero.icon.height / 2)
    return (pt && pt.x !== undefined) ? pt : null
  }
  readonly property real heroCenterX: heroCenter ? heroCenter.x : stage.width / 2
  readonly property real heroCenterY: heroCenter ? heroCenter.y : 0
  readonly property real heroDiscRadius: Math.max(1, hero.icon.width / 2 - 1)

  // ---- drag to reorder
  // Rows move by transform while dragging; the order is committed on drop.
  property int dragIndex: -1
  property real dragOffset: 0
  property real rowPitch: 0
  property int dragTarget: -1

  function beginRowDrag(index, pitch) {
    dropAnimation.stop()
    dragIndex = index
    dragTarget = index
    rowPitch = pitch
  }

  function moveRowDrag(offset) {
    dragOffset = offset
    dragTarget = Model.dragTargetFor(dragIndex, dragOffset, rowPitch, dragTarget, zones.length)
  }

  // Glide into the slot, then commit.
  function releaseRowDrag() {
    if (dragIndex < 0) { cancelRowDrag(); return }
    dropAnimation.to = (dragTarget - dragIndex) * rowPitch
    dropAnimation.restart()
  }

  function commitRowDrag() {
    if (dragIndex >= 0 && dragTarget >= 0 && dragTarget !== dragIndex)
      persistSettings({ zones: Model.serializeZones(Model.moveZone(zones, dragIndex, dragTarget)) })
    cancelRowDrag()
  }

  function cancelRowDrag() {
    dropAnimation.stop()
    dragIndex = -1
    dragTarget = -1
    dragOffset = 0
  }

  // ---- scrubbing
  // Set absolutely from the pointer, held briefly after release, then back to now.
  property real scrubMinutes: 0
  readonly property double effectiveMs: nowMs + scrubMinutes * 60000
  readonly property string scrubLabel: Model.formatScrubDelta(scrubMinutes)

  // Measured against the unscrubbed present, so a drag cannot drift.
  function scrubTo(rowData, fraction) {
    if (!rowData || !rowData.ready) return
    var parts = Model.zoneParts(nowMs, rowData.offsetMinutes)
    scrubMinutes = Model.scrubDeltaMinutes(fraction, parts.hour * 60 + parts.minute)
  }

  function beginScrub(rowData, fraction) {
    scrubHold.stop()
    scrubTo(rowData, fraction)
  }

  function endScrub() { scrubHold.restart() }

  // Held until Escape or close: a key press has no release to time from. Unlike a
  // drag, which stays within the strip's day, the keys can run on into other days.
  function shiftHour(step) {
    scrubHold.stop()
    scrubMinutes = Math.round(scrubMinutes) + step * 60
  }

  // ---- the moon
  // Shift-click a moon marker to walk the phase through a lunation.
  property bool moonShowing: false
  property real moonDemo: -1
  readonly property var moonShowStops: [0, 0.12, 0.25, 0.38, 0.5, 0.62, 0.75, 0.88, 1]
  property int moonShowStep: 0
  readonly property real moonPhase: moonShowing && moonDemo >= 0 ? moonDemo : Solar.moonPhase(effectiveMs)

  function startMoonShow() {
    moonShowStep = 0
    moonShowing = true
    moonDemo = moonShowStops[0]
    moonShowTimer.restart()
  }

  function stopMoonShow() {
    moonShowTimer.stop()
    // Before the value, so the tween does not run the phase back to -1.
    moonShowing = false
    moonDemo = -1
  }

  // ---- places
  readonly property var clockRows: Model.rows(zones, probe, effectiveMs, localOffsetMinutes, hour24)

  // The system zone names a representative city; `homeCity` overrides it.
  readonly property string homeCity: {
    var override = String(setting("homeCity", "")).trim()
    if (override !== "") return override
    return localZone === "" ? "" : Model.labelForZoneId(localZone)
  }
  readonly property var homeZone: ({ label: homeCity, id: localZone })

  function placeOf(zone) {
    var f = facts[Model.factsKey(zone)]
    return (f && f.lat !== undefined && f.lon !== undefined) ? f : null
  }

  readonly property var homePlace: homeCity === "" || localZone === "" ? null : placeOf(homeZone)

  // Matched by name: Miami should not light up New York.
  readonly property var trackedNames: zones.map(function(z) { return String(z.label).toLowerCase() })

  function globeRows(list, rank) {
    var out = []
    for (var i = 0; i < list.length; i++) {
      var f = placeOf(list[i])
      if (f) out.push([list[i].label, list[i].id, f.lat, f.lon, rank])
    }
    return out
  }
  readonly property var trackedCities: globeRows(zones, 0)
  readonly property var sessionPlaces: globeRows(sessionCities, 1)

  // Held as the city's key, not a row index, so a reorder carries the focus
  // with the city and a removal drops it back to home.
  property string focusKey: ""
  readonly property int focusIndex: Model.indexOfZoneKey(zones, focusKey)
  readonly property var focusZone: focusIndex >= 0 ? zones[focusIndex] : homeZone
  readonly property var focusPlace: placeOf(focusZone)
  readonly property bool focusKnown: focusPlace !== null
  readonly property real focusLat: focusKnown ? focusPlace.lat : 0
  readonly property real focusLon: focusKnown ? focusPlace.lon : 0

  function focusOn(index) {
    addSelected = false
    var from = hero.spin
    focusKey = index >= 0 && index < zones.length ? Model.factsKey(zones[index]) : ""
    if (focusKnown) hero.turn(from, focusLon)
  }

  // Past the last city, the list's cursor rests on "Add a city"; the globe stays put.
  property bool addSelected: false

  // Up and down walk home, each city and then "Add a city", wrapping round like the
  // search list. The globe has no add row, so there the walk skips it.
  function moveFocus(step) {
    var at = addSelected ? zones.length : focusIndex
    var next = Model.moveSelection(at + 1, step, zones.length + (globeMode ? 1 : 2)) - 1
    if (next === zones.length) {
      addSelected = true
      scrollToItem(citySearch)
      return
    }
    focusOn(next)
    if (globeMode) showFocusOnGlobe()
    else scrollToItem(next >= 0 ? cityRows.itemAt(next) : null)
  }

  // The picked city goes, as with its × button, and the cursor lands on the city
  // that takes its place. The last city stays, so there is always one clock.
  function deleteFocused() {
    if (globeMode || addSelected || focusIndex < 0 || zones.length < 2) return
    var at = focusIndex
    removeCityAt(at)
    focusOn(Math.min(at, zones.length - 1))
  }

  function scrollToItem(item) {
    if (!item) { scroller.scrollToTop(); return }
    var top = item.mapToItem(content, 0, 0).y
    if (top < scroller.contentY) scroller.scrollTo(top)
    else if (top + item.height > scroller.contentY + scroller.height)
      scroller.scrollTo(Math.min(scroller.maxScroll, top + item.height - scroller.height))
  }

  // Surrogate pairs rather than literal glyphs, which re-encoding can break.
  function weatherGlyph(zone) {
    var f = facts[Model.factsKey(zone)]
    if (!f || f.w === undefined) return ""
    var kind = Model.weatherKind(f.w)
    if (kind === "sunny") return "\udb81\udda8"  // white-balance-sunny: a solid disc
    if (kind === "partly") return "\udb81\udd95"
    if (kind === "cloudy") return "\udb81\udd90"
    if (kind === "rain") return "\udb81\udd97"
    if (kind === "snow") return "\udb81\udd98"
    return ""
  }

  readonly property string localTime: {
    var here = Model.localParts(effectiveMs)
    var text = Model.formatTime(here, hour24)
    return hour24 ? text : text + " " + Model.meridiem(here)
  }

  // No full stop: a period hanging off the arc reads as a speck.
  readonly property string hereLine: "It's " + localTime + " here"
    + (homeCity !== "" ? " in " + homeCity : "")
    + (scrubLabel !== "" ? "  " + scrubLabel : "")

  // A capital's line box has empty space above it; the row's top pad drops by it.
  FontMetrics {
    id: nameFontMetrics
    font.family: root.fontFamily
    font.pixelSize: Style.font.subtitle
  }

  TextMetrics {
    id: nameCapMetrics
    font.family: root.fontFamily
    font.pixelSize: Style.font.subtitle
    text: "M"
  }

  readonly property real capGap: Math.max(0,
    nameFontMetrics.height - nameFontMetrics.descent + nameCapMetrics.tightBoundingRect.y)

  // The widest a row's time gets, so every row's weather lines up against one
  // column rather than hugging "4:06" in one row and "10:06" in the next.
  TextMetrics {
    id: widestTimeMetrics
    font.family: root.fontFamily
    font.pixelSize: Style.font.heading
    font.weight: Font.DemiBold
    text: "00:00"
  }

  TextMetrics {
    id: meridiemMetrics
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    text: "PM"
  }

  readonly property real timeColumnWidth: Math.ceil(widestTimeMetrics.advanceWidth
    + (hour24 ? 0 : Style.spacing.xs + meridiemMetrics.advanceWidth))

  function tick() {
    nowMs = Date.now()
    localOffsetMinutes = -(new Date().getTimezoneOffset())
  }

  // Written straight back to this widget's shell.json entry, like the clock's.
  function persistSettings(values) {
    var entry = { id: root.moduleName }
    for (var existing in root.settings) if (existing !== "id") entry[existing] = root.settings[existing]
    for (var key in values) entry[key] = values[key]

    root.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
  }

  function setZones(next) {
    if (next === zones) return
    persistSettings({ zones: Model.serializeZones(next) })
    refresh()
    refreshFacts()
  }

  // The label matters as much as the zone: many cities share one.
  function addCity(id, label) { setZones(Model.addZone(zones, id, label || "")) }
  function removeCity(id) { setZones(Model.removeZone(zones, id)) }
  function removeCityAt(index) { setZones(Model.removeZoneAt(zones, index)) }

  function startAdding() { citySearch.start() }

  function addSessionCity(label, id) {
    for (var i = 0; i < sessionCities.length; i++)
      if (sessionCities[i].label === label && sessionCities[i].id === id) return
    sessionCities = sessionCities.concat([{ label: label, id: id }])
    refreshFacts()
  }

  // The local city plus four places spread round the clock from it.
  function seedFirstRun() {
    var offs = ({})
    for (var id in probe) offs[id] = probe[id].offsetMinutes

    var seeded = localZone === "" ? []
      : Model.seedZones({ label: Model.labelForZoneId(localZone), id: localZone }, offs, 4)
    if (seeded.length === 0) seeded = Model.parseZones(Model.DEFAULT_ZONES)
    if (seeded.length === 0) return

    persistSettings({ zones: Model.serializeZones(seeded) })
    refresh()
    refreshFacts()
  }

  // ---- processes
  // Each refresh queues behind one in flight rather than being dropped.
  function refresh() {
    if (probeIds.length === 0) return
    if (probeProc.running) { probeQueued = true; return }
    probeProc.running = true
  }

  function probeSearchZones() {
    if (searchZoneIds.length === 0) return
    if (searchProc.running) { searchProbeQueued = true; return }
    searchProc.running = true
  }

  function refreshFacts() {
    if (zones.length === 0) return
    if (geoProc.running || weatherProc.running) { factsQueued = true; return }
    var missing = factsRequest.filter(function(row) { return !geo[Model.factsKey(row)] })
    if (missing.length === 0) { fetchWeather(); return }
    geoProc.rows = missing
    geoProc.command = ["bash", "-c", 'for url; do curl -fsS --max-time 8 "$url"; printf "\\n\\036\\n"; done', "bash"]
      .concat(missing.map(function(row) { return Model.geocodeUrl(row.label) }))
    geoProc.running = true
  }

  function coordsFor(key) {
    return geo[key] || fallbackGeo[key] || null
  }

  function fetchWeather() {
    var now = Date.now()
    var stale = factsRequest.map(Model.factsKey).filter(function(key) {
      return coordsFor(key) && Model.weatherStale(weather[key], now)
    })
    if (stale.length === 0) { publishFacts(); return }
    weatherProc.keys = stale
    weatherProc.command = ["curl", "-fsS", "--max-time", "8", Model.forecastUrl(stale.map(coordsFor))]
    weatherProc.running = true
  }

  function publishFacts() {
    var coords = {}
    var keys = factsRequest.map(Model.factsKey)
    keys.forEach(function(key) { coords[key] = coordsFor(key) })
    facts = Model.mergeFacts(keys, coords, weather)
    if (!factsQueued) return
    factsQueued = false
    Qt.callLater(refreshFacts)
  }

  function loadCatalog() {
    if (zoneCatalogText !== "" || catalogProc.running) return
    catalogProc.running = true
  }

  function utcLabelFor(zoneId) {
    var known = searchProbe[zoneId]
    return known === undefined ? "" : Model.utcOffsetLabel(known.offsetMinutes)
  }

  // Tracked cities, the city you are in (for the globe's home) and session cities.
  readonly property var factsRequest: {
    var out = zones.map(function(z) { return { label: z.label, id: z.id } })
    if (localZone !== "" && homeCity !== "") out.push({ label: homeCity, id: localZone })
    return out.concat(sessionCities)
  }

  // ---- opening spin
  // It lands on the home meridian, so it waits for home's coordinates, read
  // straight from the facts: focusKnown can flip a beat before focusLon lands.
  property bool spinPending: false

  function homeMeridian() {
    var f = facts[Model.factsKey(focusZone)]
    return (f && f.lon !== undefined && f.lon !== null) ? f.lon : null
  }

  function startOpeningSpin() {
    var lon = homeMeridian()
    if (lon === null) { spinPending = true; spinFallback.restart(); return }
    spinPending = false
    spinFallback.stop()
    hero.spinOpening(lon)
  }

  onFactsChanged: if (spinPending) startOpeningSpin()

  // No coordinates on a cold cache without network: spin anyway.
  Timer {
    id: spinFallback
    interval: 1500
    onTriggered: if (root.spinPending) { root.spinPending = false; hero.spinOpening(null) }
  }

  onOpenedChanged: {
    if (opened) {
      focusKey = ""
      addSelected = false
      tick(); refresh(); refreshFacts(); loadCatalog()
      startOpeningSpin()
    } else {
      citySearch.stop(); setGlobeMode(false, false); scrubMinutes = 0
      spinPending = false; spinFallback.stop()
    }
  }
  Component.onCompleted: refresh()

  Process {
    id: probeProc
    command: Model.probeCommand(root.probeIds, true)
    stdout: StdioCollector {
      onStreamFinished: {
        root.probe = Model.parseProbe(text)
        var lz = Model.localZoneFromProbe(text)
        if (lz !== "") root.localZone = lz
        if (root.needsSeed) root.seedFirstRun()
        root.tick()
        Qt.callLater(function() {
          if (!root.probeQueued) return
          root.probeQueued = false
          root.refresh()
        })
      }
    }
  }

  // Merged, so a known offset stays on screen while the next probe runs.
  Process {
    id: searchProc
    command: Model.probeCommand(root.searchZoneIds, false)
    stdout: StdioCollector {
      onStreamFinished: {
        var merged = {}
        for (var known in root.searchProbe) merged[known] = root.searchProbe[known]
        var fresh = Model.parseProbe(text)
        for (var id in fresh) merged[id] = fresh[id]
        root.searchProbe = merged
        Qt.callLater(function() {
          if (!root.searchProbeQueued) return
          root.searchProbeQueued = false
          root.probeSearchZones()
        })
      }
    }
  }

  Process {
    id: catalogProc
    command: ["timedatectl", "list-timezones"]
    stdout: StdioCollector {
      onStreamFinished: root.zoneCatalogText = text
    }
  }

  FileView {
    id: zoneTab
    path: "/usr/share/zoneinfo/zone1970.tab"
    printErrors: false
  }

  Process {
    id: geoProc
    property var rows: []
    stdout: StdioCollector {
      onStreamFinished: {
        var answers = text.split("\n\u001e\n")
        var nextGeo = Object.assign({}, root.geo)
        var nextFallback = {}
        geoProc.rows.forEach(function(row, i) {
          var key = Model.factsKey(row)
          var found = Model.pickGeocode(answers[i] || "", row.id)
          var place = found.place || Model.zoneTabCoords(zoneTab.text(), row.id)
          if (!place) return
          if (found.answered) nextGeo[key] = place
          else nextFallback[key] = place
        })
        root.geo = nextGeo
        root.fallbackGeo = nextFallback
        root.fetchWeather()
      }
    }
  }

  Process {
    id: weatherProc
    property var keys: []
    stdout: StdioCollector {
      onStreamFinished: {
        root.weather = Object.assign({}, root.weather, Model.parseForecast(text, weatherProc.keys, Date.now()))
        root.publishFacts()
      }
    }
  }

  Timer {
    interval: 900000
    running: root.opened
    repeat: true
    onTriggered: root.refreshFacts()
  }

  // Heavy on the way out, brisk on the way back.
  Behavior on zoom {
    NumberAnimation {
      duration: Style.duration(root.zoomDuration)
      easing.type: root.zoomEasing
    }
  }

  Timer {
    id: moonShowTimer
    interval: 620
    repeat: true
    onTriggered: {
      root.moonShowStep++
      if (root.moonShowStep >= root.moonShowStops.length) root.stopMoonShow()
      else root.moonDemo = root.moonShowStops[root.moonShowStep]
    }
  }

  Behavior on moonDemo {
    enabled: root.moonShowing
    NumberAnimation { duration: Style.duration(460); easing.type: Easing.InOutSine }
  }

  NumberAnimation {
    id: dropAnimation
    target: root
    property: "dragOffset"
    duration: Style.duration(150)
    easing.type: Easing.OutCubic
    onFinished: root.commitRowDrag()
  }

  Timer {
    id: scrubHold
    interval: 2500
    onTriggered: root.scrubMinutes = 0
  }

  Timer {
    interval: 1000
    running: root.opened
    repeat: true
    onTriggered: root.tick()
  }

  Timer {
    interval: 300000
    running: root.opened
    repeat: true
    onTriggered: root.refresh()
  }

  ShellIpc {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { root.refresh(); return "ok" }

    function globe(): string {
      if (!root.globeEnabled) return "disabled"
      root.setGlobeMode(!root.globeMode, false)
      return root.globeMode ? "globe" : "list"
    }

    // Ticks first: the clock only runs while the panel is open.
    function times(): string {
      root.tick()
      return JSON.stringify(root.clockRows)
    }
    function add(zone: string, label: string): string {
      root.setZones(Model.addZone(root.zones, zone, label))
      return Model.serializeZones(root.zones)
    }
    function remove(zone: string): string { root.removeCity(zone); return Model.serializeZones(root.zones) }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰇧"
    tooltipText: "World clock"
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton || buttonCode === Qt.MiddleButton) root.refresh()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(content.implicitHeight, Style.space(680))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: root.adding
      // Escape unwinds one layer: search (its own field), a shifted time, globe, then panel.
      onCloseRequested: {
        if (root.scrubMinutes !== 0) { scrubHold.stop(); root.scrubMinutes = 0 }
        else if (root.globeMode) root.setGlobeMode(false, false)
        else root.close()
      }
      onDeleteRequested: root.deleteFocused()
      // Up and down pick a city; left and right move the clocks an hour.
      onMoveRequested: function(dx, dy) {
        if (dy !== 0) root.moveFocus(dy)
        else root.shiftHour(dx)
      }
      // Return or Space on "Add a city" opens the search. Otherwise Space toggles
      // the globe, and Return, which also arrives as an activate, does nothing.
      property bool returnHandled: false
      onReturnRequested: returnHandled = true
      onActivateRequested: {
        var fromReturn = returnHandled
        returnHandled = false
        if (root.addSelected) root.startAdding()
        else if (!fromReturn && root.globeEnabled) root.setGlobeMode(!root.globeMode, false)
      }
      onTabRequested: function(direction) { root.switchPanel(direction) }
      // "+" searches in either view; "j" jumps on the globe, "a" adds on the list.
      // "t" flips 24-hour and AM/PM time, like clicking a row's time, and Alt+T
      // flips Fahrenheit and Celsius, like clicking a temperature.
      onTextKey: function(text, modifiers) {
        var key = text.toLowerCase()
        if (key === "r") root.refresh()
        else if (key === "t" && (modifiers & Qt.AltModifier)) root.toggleUnits()
        else if (key === "t") root.toggleHour24()
        else if (root.globeMode && (key === "+" || key === "j")) {
          if (globeLoader.item) globeLoader.item.startJump()
        } else if (!root.globeMode && (key === "+" || key === "a")) {
          root.startAdding()
        }
      }

      // Clipped to the card and scrolled by the wheel only: the rows own drags.
      Flickable {
        id: scroller
        anchors.fill: parent
        clip: true
        interactive: false
        contentWidth: width
        contentHeight: content.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        readonly property real maxScroll: Math.max(0, contentHeight - height)

        function clamp() { contentY = Util.clamp(contentY, 0, maxScroll) }
        onHeightChanged: clamp()
        onContentHeightChanged: clamp()

        function scrollTo(y) {
          scrollAnim.stop()
          scrollAnim.from = contentY
          scrollAnim.to = y
          scrollAnim.start()
        }
        function scrollToTop() { scrollTo(0) }

        // Follows maxScroll: the results arrive over several frames after the
        // search opens, so a one-shot scroll lands short.
        onMaxScrollChanged: if (root.adding) scrollTo(maxScroll)

        // Not a Behavior: the wheel writes contentY too and must track directly.
        NumberAnimation {
          id: scrollAnim
          target: scroller
          property: "contentY"
          duration: Style.duration(160)
          easing.type: Easing.OutCubic
        }

        WheelHandler {
          acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
          onWheel: function(event) {
            var d = event.pixelDelta.y !== 0 ? event.pixelDelta.y : event.angleDelta.y / 120 * Style.space(40)
            scroller.contentY -= d
            scroller.clamp()
          }
        }

        Column {
          id: content
          width: scroller.width
          spacing: Style.spacing.panelGap

          HeroTitle {
            id: hero
            width: parent.width
            caption: root.hereLine
            // Accent while scrubbed, so a shifted time is never taken for now.
            captionColor: root.scrubMinutes !== 0 ? Color.accent : root.dim
            captionClickable: root.focusIndex >= 0
            foreground: root.foreground
            dim: root.dim
            fontFamily: root.fontFamily
            zoom: root.zoom
            globeEnabled: root.globeEnabled
            bigGlobeOpacity: root.bigGlobeOpacity
            restLon: root.focusLon
            markerShown: root.focusKnown
            markerLat: root.focusLat
            markerLon: root.focusLon
            onCaptionClicked: root.focusOn(-1)
            onGlobeClicked: function(slow) { root.setGlobeMode(!root.globeMode, slow) }
          }

          // ---- stage
          // The list and the globe share it; it grows with the zoom. Not
          // clipped, so the globe can start from the header above it.
          Item {
            id: stage
            width: parent.width
            height: Math.max(1, listWrap.implicitHeight
                    + (root.globeStageHeight - listWrap.implicitHeight) * root.zoom)

            // Clipped, so knocked rows fall out of the panel.
            Item {
              anchors.fill: parent
              clip: true

              Column {
                id: listWrap
                width: parent.width
                spacing: Style.spacing.panelGap

                Column {
                  visible: root.zoom < 1
                  width: parent.width
                  spacing: Style.spacing.md

                  // The zone list, not clockRows: that ticks, and would
                  // rebuild every delegate mid-drag.
                  Repeater {
                    id: cityRows
                    model: root.zones

                    CityRow { panel: root }
                  }
                }

                CitySearch {
                  id: citySearch
                  visible: root.zoom < 1
                  width: parent.width
                  options: root.zoneOptions
                  loading: root.zoneCatalogText === ""
                  offsetLabel: function(zoneId) { return root.utcLabelFor(zoneId) }
                  hasCursor: root.addSelected
                  foreground: root.foreground
                  dim: root.dim
                  fainter: root.fainter
                  fontFamily: root.fontFamily
                  onActiveChanged: if (active) root.loadCatalog()
                  onPicked: function(label, id) { root.addCity(id, label) }
                  onDismissed: Qt.callLater(function() { keyCatcher.forceActiveFocus() })

                  // Knocked aside last, after every row.
                  transform: Translate {
                    x: Model.knockX(root.zones.length, root.zoom, Style.space(95))
                    y: Model.knockY(root.zones.length, root.zoom, root.knockFall)
                  }
                }
              }
            }

            // ---- globe
            // Loaded early on hover and kept for the whole flight, so reading
            // its data never lands mid-animation.
            Loader {
              id: globeLoader
              active: root.globeEnabled && (root.globeMode || root.zoom > 0 || hero.iconHovered)
              visible: root.zoom > 0
              opacity: root.bigGlobeOpacity
              width: parent.width
              height: root.globeStageHeight
              source: "Globe.qml"

              // The disc's center, above the globe's footer and jump bar.
              readonly property real discCX: width / 2
              readonly property real discCY: item ? (height - item.footerHeight - item.jumpHeight) / 2 : height / 2
              readonly property real discR: item && item.radius > 0 ? item.radius : 1
              readonly property real startScale: root.heroDiscRadius / discR
              readonly property real zoomScale: startScale + (1 - startScale) * root.zoom

              // Scaled about the disc, then carried from the little globe.
              transform: [
                Scale {
                  origin.x: globeLoader.discCX
                  origin.y: globeLoader.discCY
                  xScale: globeLoader.zoomScale
                  yScale: globeLoader.zoomScale
                },
                Translate {
                  x: (root.heroCenterX - globeLoader.discCX) * (1 - root.zoom)
                  y: (root.heroCenterY - globeLoader.discCY) * (1 - root.zoom)
                }
              ]

              onLoaded: {
                item.foreground = Qt.binding(function() { return root.foreground })
                item.dim = Qt.binding(function() { return root.dim })
                item.fainter = Qt.binding(function() { return root.fainter })
                item.daylightMarker = Qt.binding(function() { return root.daylightMarker })
                item.moonPhase = Qt.binding(function() { return root.moonPhase })
                item.fontFamily = Qt.binding(function() { return root.fontFamily })
                item.hour24 = Qt.binding(function() { return root.hour24 })
                item.trackedNames = Qt.binding(function() { return root.trackedNames })
                item.trackedCities = Qt.binding(function() { return root.trackedCities })
                item.sessionCities = Qt.binding(function() { return root.sessionPlaces })
                item.homeRow = Qt.binding(function() {
                  var home = root.homePlace
                  return home ? [root.homeCity, root.localZone, home.lat, home.lon, 0] : []
                })
                item.offsetMode = Qt.binding(function() { return root.offsetMode })
                item.homeOffsetMinutes = Qt.binding(function() { return root.localOffsetMinutes })
                item.smoothMotion = Qt.binding(function() { return root.smoothMotion })
                item.transitioning = Qt.binding(function() { return !root.zoomIdle })
                item.zoomLevel = Qt.binding(function() { return root.zoom })
                // The footer and jump bar arrive once the globe has landed.
                item.chromeOpacity = Qt.binding(function() { return Util.clamp((root.zoom - 0.74) / 0.26, 0, 1) })
                item.jumpOptions = Qt.binding(function() { return root.allZoneOptions })
                item.offsetModeToggleRequested.connect(function() { root.toggleOffsetMode() })
                item.jumpRequested.connect(function(label, zone) { root.addSessionCity(label, zone) })
                item.exitRequested.connect(function() { root.setGlobeMode(false, false) })
                item.jumpDismissed.connect(function() { Qt.callLater(function() { keyCatcher.forceActiveFocus() }) })
                item.citySelected.connect(function(label, zone) { root.focusFromGlobe(label, zone) })
                item.cityTapped.connect(function(label, zone) { root.claimHome(label, zone) })
                // A cold start can finish loading after the mode switched on.
                if (root.globeMode) root.showFocusOnGlobe()
              }
            }
          }
        }
      }
    }
  }
}
