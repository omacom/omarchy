import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model
import "GlobeModel.js" as Solar
import "Sky.js" as Sky
import "Sun.js" as Sun
import "Greetings.js" as Greet

// A sidebar button that opens a panel of clocks — one row per city.
//
// The times come from a `date` probe rather than from JavaScript: Qt's QML
// engine ships no Intl, so asking JS for the time in Asia/Tokyo is not an
// option. The probe returns each zone's current UTC offset, and the rows tick
// locally against those offsets. Offsets only move at a DST boundary, so the
// probe re-runs when the panel opens and periodically while it stays open,
// and the seconds in between cost nothing.
Panel {
  id: root
  moduleName: "omarchy.elsewhen"
  ipcTarget: "omarchy.elsewhen"
  manageIpc: false

  readonly property var zones: Model.parseZones(setting("zones", ""))
  readonly property var zoneIds: {
    var out = []
    for (var i = 0; i < zones.length; i++) out.push(zones[i].id)
    return out
  }
  // A fresh install: the setting has never been written. The panel seeds
  // itself rather than asking anyone to configure anything.
  readonly property bool needsSeed: String(setting("zones", "")).trim() === ""

  // On a fresh install the probe also prices the candidate cities, so the
  // whole first-run choice costs one process rather than a second round trip.
  readonly property var probeIds:
    needsSeed ? zoneIds.concat(Model.seedCandidateZones()) : zoneIds

  // Twelve or twenty-four, from the system's own short time format until
  // someone says otherwise by clicking a time. Same shape as the units below:
  // the panel asks Qt what the locale does, Model decides what that means and
  // what an explicit setting overrides.
  readonly property bool autoHour24:
    Model.usesTwentyFourHour(Qt.locale().timeFormat(Locale.ShortFormat))
  readonly property bool hour24: Model.resolveHour24(setting("hour24", ""), autoHour24)

  function toggleHour24() { persistSettings({ hour24: !root.hour24 }) }

  // Which offset the rows show: "home" is the distance from where you are
  // ("+2h"), "utc" is where the zone actually sits ("UTC-5"). One setting for
  // the whole list rather than one per row - the list is read down a column,
  // and a column where each row had chosen its own units would be unreadable.
  // Clicking any row's offset flips all of them.
  readonly property string offsetMode: setting("offsetMode", "home") === "utc" ? "utc" : "home"

  function toggleOffsetMode() {
    persistSettings({ offsetMode: root.offsetMode === "utc" ? "home" : "utc" })
  }

  function offsetTextFor(rowData) {
    if (!rowData || !rowData.ready) return ""
    return offsetMode === "utc" ? Model.utcOffsetLabel(rowData.offsetMinutes)
                                : rowData.relative
  }

  // The Earth's own row at the foot of the list: a 4.54-billion-year day
  // reading a minute to midnight. Built, lived with, and switched off on
  // 2026-08-29 - it did not land. Off by default, code and tests intact; the
  // README says what was wrong with it.
  readonly property bool showEarth: setting("showEarth", false) === true
  // Degrees in whichever unit the machine measures in, until someone says
  // otherwise by clicking a temperature. Qt reads the measurement system from
  // the system locale, and only the US system means Fahrenheit - the UK
  // reports its own imperial system but has taken its weather in Celsius for
  // fifty years. Shipping "F" as the default was reasonable while this ran on
  // one desktop and wrong for everywhere else.
  //
  // The stored setting still wins whenever it says C or F; the automatic
  // answer is only what an unset setting falls through to.
  readonly property string autoUnits:
    Qt.locale().measurementSystem === Locale.ImperialUSSystem ? "F" : "C"
  readonly property string units: Model.resolveUnits(setting("units", ""), autoUnits)

  function toggleUnits() { persistSettings({ units: root.units === "C" ? "F" : "C" }) }
  // Off by default. The plumbing stays in place - flip this to true and the
  // currency comes back with no code change.
  readonly property bool showCurrency: setting("showCurrency", false) === true
  // The overlap band and its briefcase toggles, shelved for now. All the
  // machinery stays - flip this to true and it comes back whole. The time
  // scrubber is independent and unaffected.
  readonly property bool showOverlap: setting("showOverlap", false) === true
  // Sky tint: colour each city name, and each dot on the globe, by the sky
  // where it is. Shelved - the colours were pleasant but the rule was never
  // visible from the interface, so they read as decoration. Set skyTint true
  // to bring it back; Sky.js and its tests are untouched.
  readonly property bool skyTint: setting("skyTint", false) === true

  property var probe: ({})
  property string zoneCatalogText: ""
  property var facts: ({})
  // Cities jumped to from the globe. They live for this session only - they
  // are never written to shell.json, so there is nothing to clean up and no
  // delete affordance to design. Want one again? Type it again.
  property var sessionCities: []
  property bool factsQueued: false

  // The helper script lives next to this file; resolve it rather than
  // hard-coding a path, so a renamed or relocated plugin still works.
  readonly property string pluginDir: {
    var here = Qt.resolvedUrl(".").toString()
    return here.replace(/^file:\/\//, "").replace(/\/$/, "")
  }
  // Globe mode. Everything it needs lives in Globe.qml and its two data
  // files; see README, "Globe mode", for how to remove the feature.
  // One switch turns the whole feature off without deleting anything: the
  // hero stops being a button and the Loader never activates.
  readonly property bool globeEnabled: setting("globeEnabled", true) !== false
  // Draw the globe with less in it while it is moving, so the transition and
  // the spin hold their frame rate. Off draws everything, always.
  readonly property bool smoothMotion: setting("smoothMotion", true) !== false
  property bool globeMode: false

  // ---- the zoom -----------------------------------------------------------
  // One number drives the whole transition: 0 is the list, 1 is the globe
  // filling the panel. Everything else - the stage height, the knocked-aside
  // rows, the globe's scale and position, the cross in the header - is a
  // function of it, so nothing can fall out of step with anything else.
  // Not readonly: the Behavior below animates it, which a readonly property
  // cannot be. The binding still drives it; the Behavior only smooths the
  // journey between the two ends.
  property real zoom: globeMode ? 1 : 0
  readonly property bool zoomIdle: zoom === 0 || zoom === 1

  // Hold Shift while clicking the globe to run the whole transition at a
  // third speed. Shift is the gesture macOS has used for slow-motion window
  // animations for years, so it is the one people already try, and nothing in
  // Hyprland claims a bare modifier on a click. Read at the moment of the
  // click, so each transition runs at whatever was held when it began.
  property bool slowMotion: false
  readonly property int slowMotionFactor: 3

  // The animation cannot derive its own duration from globeMode: globeMode is
  // the thing whose change starts it, so whether the binding has updated by
  // the time the animation reads it is a race - and losing that race means an
  // opening transition runs with the closing duration. These are set first,
  // then globeMode is flipped, so the animation always starts correctly
  // configured. Every path into globe mode goes through setGlobeMode.
  property int zoomDuration: 800
  property int zoomEasing: Easing.OutQuart

  function setGlobeMode(on, slow) {
    slowMotion = slow === true
    zoomDuration = (on ? 800 : 500) * (slowMotion ? slowMotionFactor : 1)
    zoomEasing = on ? Easing.OutQuart : Easing.InOutCubic
    globeMode = on
    // Turn the globe as it opens, so the two motions - the zoom out of the
    // header and the spin round - land together. The Loader is synchronous,
    // so the item exists by the time this runs.
    if (on && globeLoader.item) showFocusOnGlobe()
  }

  // Where the globe should be pointing when it opens: the city the list has
  // focused, or home when the list is on home. Without this the globe always
  // reset to home, so clicking a row and then opening the globe threw the
  // choice away and the two views disagreed about what was selected.
  //
  // Only when the coordinates are already known. goTo on a city the globe has
  // never heard of asks for it as a session city, and a tracked row whose
  // geocode has not landed yet does not need adding - it will be there on its
  // own once the facts arrive. Home is the honest thing to show until then.
  function showFocusOnGlobe() {
    var g = globeLoader.item
    if (!g) return
    if (focusIndex >= 0 && focusKnown) g.goTo(focusZone.label, focusZone.id)
    else g.showHome()
  }

  // The other direction: a city picked on the globe becomes the list's focus,
  // so closing the globe leaves the header and the small globe on the city
  // you were just looking at.
  //
  // A globe city the list does not track has no row to focus, so the list is
  // left as it was rather than being forced to home.
  function focusFromGlobe(label, zone) {
    var i = Model.indexOfZone(root.zones, label, zone)
    if (i >= 0) focusOn(i)
  }

  readonly property real globeStageHeight: Style.space(378)

  // The centre of the little circle in the header, in the stage's own
  // coordinates - the point the big globe grows out of and shrinks back into.
  // Guarded, because before layout the mapping is undefined. The unused sum
  // makes the binding depend on the layout, so it recomputes if anything
  // above the stage changes size.
  readonly property var heroCentre: {
    var _ = heroIcon.width + heroIcon.height + stage.y + stage.width
    var pt = heroIcon.mapToItem(stage, heroIcon.width / 2, heroIcon.height / 2)
    return (pt && pt.x !== undefined) ? pt : null
  }
  readonly property real heroCentreX: heroCentre ? heroCentre.x : stage.width / 2
  readonly property real heroCentreY: heroCentre ? heroCentre.y : 0
  readonly property real heroDiscRadius: Math.max(1, heroIcon.width / 2 - 1)

  // The two globes are the same size and in the same place at the moment they
  // trade, so this crossfade is invisible. It exists only so that there are
  // never two globes drawn at once.
  // Cards are solid too: while they are being shoved aside they pass over one
  // another and over the globe's edge, and a translucent card lets whatever is
  // behind it show through mid-flight.
  readonly property color surfaceBase: Color.popups.background
  function solid(t) {
    return Qt.rgba(surfaceBase.r + (foreground.r - surfaceBase.r) * t,
                   surfaceBase.g + (foreground.g - surfaceBase.g) * t,
                   surfaceBase.b + (foreground.b - surfaceBase.b) * t, 1)
  }

  readonly property real bigGlobeOpacity: Math.max(0, Math.min(1, zoom / 0.12))

  // Rows are shoved aside in sequence rather than together, so it reads as
  // something arriving from the top rather than the list simply leaving. Each
  // row waits its turn, then covers the rest of the distance on its own.
  function knockAt(i) {
    var lead = Math.min(0.5, i * 0.09)
    return Math.max(0, Math.min(1, (zoom - lead) / (1 - lead)))
  }
  // Far enough that even the topmost row clears the bottom of the panel: it
  // has the whole list below it to fall past. Measured from the list at rest,
  // so it does not shrink as the stage does.
  readonly property real knockFall: listWrap.implicitHeight + Style.space(220)

  // Squared, so the fall accelerates instead of easing out with the zoom.
  // Rows are dropped; they should not decelerate on the way down.
  function knockY(i) {
    var p = knockAt(i)
    return p * p * knockFall
  }
  // Thrown sideways in alternating directions on the way down, so it reads as
  // scattering rather than as the list politely sliding away.
  function knockX(i) { return knockAt(i) * (i % 2 === 0 ? -Style.space(95) : Style.space(95)) }
  function knockTilt(i) { return knockAt(i) * (i % 2 === 0 ? -14 : 14) }
  function knockShrink(i) { return 1 - 0.18 * knockAt(i) }
  // No fade at all. Rows leave by falling out of the bottom of the panel, and
  // anything that dims on the way reads as dissolving in place rather than
  // dropping into the dark.
  function knockFade(i) { return 1 }
  property bool adding: false
  onAddingChanged: if (!adding) scroller.scrollToTop()
  property string addQuery: ""
  readonly property var addMatches: adding ? Model.searchZones(zoneOptions, addQuery, 6) : []
  readonly property var zoneOptions: Model.zoneOptions(zoneCatalogText, zones)
  // The same catalogue with nothing filtered out - the globe's jump box can
  // go to a city that is already on the globe as happily as a new one.
  readonly property var allZoneOptions: Model.zoneOptions(zoneCatalogText, [])
  property double nowMs: Date.now()

  // Scrubbing. `scrubMinutes` shifts every row off the real present; the
  // drag sets it absolutely from the pointer position rather than
  // accumulating, so a drag maps to a place on the strip, not to a gesture
  // history. It holds briefly after release so the answer can be read, then
  // returns to now.
  // Drag-to-reorder. The list is not touched while the pointer moves - rows
  // are shifted visually with a transform, and the new order is committed
  // once on release. Reordering mid-drag would replace the model array,
  // rebuild every delegate, and drop the gesture.
  property int dragIndex: -1
  property real dragOffset: 0
  property real rowPitch: 0

  // The slot the row would land in. Held rather than recomputed freely: a
  // pointer sitting near a boundary would otherwise flip between two slots
  // on sub-pixel movement, which is what made the drag feel unsteady. The
  // target only changes once the pointer is clearly past the midpoint.
  property int dragTarget: -1

  function updateDragTarget() {
    if (dragIndex < 0 || rowPitch <= 0) { dragTarget = -1; return }
    var raw = dragOffset / rowPitch
    var held = dragTarget < 0 ? 0 : dragTarget - dragIndex
    var next = Math.abs(raw - held) >= 0.6 ? Math.round(raw) : held
    dragTarget = Math.max(0, Math.min(zones.length - 1, dragIndex + next))
  }

  // How far a row is displaced right now: the dragged one follows the
  // pointer, the ones it has passed step aside by exactly one row.
  function rowShift(index) {
    if (dragIndex < 0) return 0
    if (index === dragIndex) return dragOffset
    var t = dragTarget
    if (dragIndex < t && index > dragIndex && index <= t) return -rowPitch
    if (dragIndex > t && index >= t && index < dragIndex) return rowPitch
    return 0
  }

  // On release the row does not vanish from under the pointer: it glides the
  // remaining distance into its slot, and the reorder is committed when it
  // arrives. That is what makes it read as snapping into place.
  function releaseRowDrag() {
    if (dragIndex < 0) { cancelRowDrag(); return }
    dropAnimation.to = (dragTarget - dragIndex) * rowPitch
    dropAnimation.restart()
  }

  function commitRowDrag() {
    var t = dragTarget
    if (dragIndex >= 0 && t >= 0 && t !== dragIndex)
      persistSettings({ zones: Model.serializeZones(Model.moveZone(zones, dragIndex, t)) })
    cancelRowDrag()
  }

  function cancelRowDrag() {
    dropAnimation.stop()
    dragIndex = -1
    dragTarget = -1
    dragOffset = 0
  }

  property real scrubMinutes: 0
  property bool scrubbing: false
  readonly property double effectiveMs: nowMs + scrubMinutes * 60000
  readonly property string scrubLabel: Model.formatScrubDelta(scrubMinutes)

  readonly property int workStart: Math.round(Number(setting("workStartHour", 9)) * 60)
  readonly property int workEnd: Math.round(Number(setting("workEndHour", 17)) * 60)
  property int localOffsetMinutes: -(new Date().getTimezoneOffset())
  property string localZone: ""
  property bool probed: false
  property bool probeQueued: false

  // The bar sizes a widget slot from its root's implicit size; a bare Item
  // reports zero and the icon never gets any room to draw in.
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property color fainter: Qt.darker(foreground, 2.1)

  // A literal gold rather than a theme role: several themes map the palette
  // name "yellow" to something that isn't yellow at all (this one uses it for
  // a green), and the dot is meant to read as daylight.
  readonly property color daylightMarker: "#E5C736"
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  // UTC minute ranges where every tracked city is inside its working window.
  // Empty until every zone has been probed - a partial answer here would be
  // wrong rather than merely incomplete.
  // Only the cities with the briefcase toggled on. Tracking a city and
  // having someone to work with there are different things.
  readonly property var workZones: Model.workZones(zones)

  readonly property var overlap: {
    if (workZones.length < 2) return []
    var offs = []
    for (var i = 0; i < workZones.length; i++) {
      var o = probe[workZones[i].id]
      if (!o) return []
      offs.push(o.offsetMinutes)
    }
    return Model.overlapRuns(offs, workStart, workEnd)
  }

  readonly property string overlapText: {
    if (!showOverlap) return ""
    if (workZones.length < 2) return ""
    if (!probed) return ""
    if (overlap.length === 0) return workZones.length + " cities, no shared hours"
    var parts = []
    for (var i = 0; i < overlap.length; i++) {
      parts.push(Model.formatMinuteOfDay(overlap[i].start + localOffsetMinutes, hour24)
        + " \u2013 " + Model.formatMinuteOfDay(overlap[i].end + localOffsetMinutes, hour24))
    }
    return workZones.length + " cities overlap " + parts.join(", ")
  }

  // Lower-cased labels of the cities in the list, for the globe to highlight.
  // Matching is by name, not zone: tracking Miami should not light up New
  // York just because they share America/New_York.
  readonly property var trackedNames: {
    var out = []
    for (var i = 0; i < zones.length; i++) out.push(String(zones[i].label).toLowerCase())
    return out
  }

  // Tracked cities in the globe's own shape, so it can plot one that is not
  // among its built-ins. Coordinates come from the fetcher's geocode cache.
  readonly property var trackedCities: {
    var out = []
    for (var i = 0; i < zones.length; i++) {
      var f = facts[Model.factsKey(zones[i])]
      if (!f || f.lat === undefined || f.lon === undefined) continue
      out.push([zones[i].label, zones[i].id, f.lat, f.lon, 0])
    }
    return out
  }

  // Computed once per tick rather than per row. Follows the scrubber, so
  // dragging time sweeps the names through dawn and dusk.
  readonly property var subsolar: Solar.subsolarPoint(effectiveMs)

  // Tonight's moon, shared by every row - the phase is the same everywhere on
  // Earth. Follows the scrubber, so dragging time walks the moon through its
  // month.
  // Shift-click a moon marker to walk the phase through a full lunation. The
  // moon is nearly always somewhere unremarkable, so there is no other way to
  // see that the marker really is drawing a phase and not a dot.
  property bool moonShowing: false
  property real moonDemo: -1
  readonly property var moonShowStops:
    [0, 0.12, 0.25, 0.38, 0.5, 0.62, 0.75, 0.88, 1]
  property int moonShowStep: 0

  readonly property real moonPhase:
    moonShowing && moonDemo >= 0 ? moonDemo : Solar.moonPhase(effectiveMs)

  function startMoonShow() {
    moonShowStep = 0
    moonShowing = true
    moonDemo = moonShowStops[0]
    moonShowTimer.restart()
  }

  function stopMoonShow() {
    moonShowTimer.stop()
    // Cleared before the value, so the tween below does not run the phase
    // backwards through the whole month on the way to -1.
    moonShowing = false
    moonDemo = -1
  }

  // Written as surrogate pairs rather than literal characters: these live
  // outside the basic plane, and a stray re-encoding anywhere between here and
  // the font turns them into replacement boxes.
  function weatherGlyph(zone) {
    var f = facts[Model.factsKey(zone)]
    if (!f || f.w === undefined) return ""
    var kind = Model.weatherKind(f.w)
    // white-balance-sunny, not weather-sunny: the latter is a hollow ring
    // inside a six-point burst, which at this size is a snowflake sitting
    // next to an actual snowflake. This one is a solid disc with short rays.
    if (kind === "sunny") return "\udb81\udda8"
    if (kind === "partly") return "\udb81\udd95"
    if (kind === "cloudy") return "\udb81\udd90"
    if (kind === "rain") return "\udb81\udd97"
    if (kind === "snow") return "\udb81\udd98"
    return ""
  }

  // The sky over a city right now, or the plain foreground when the tint is
  // off or the city has not been geocoded yet.
  function skyColorFor(zone) {
    if (!skyTint) return foreground
    var f = facts[Model.factsKey(zone)]
    if (!f || f.lat === undefined || f.lon === undefined) return foreground
    var c = Sky.tint(Solar.solarElevation(f.lat, f.lon, subsolar))
    return c === null ? foreground : c
  }

  readonly property var clockRows: Model.rows(zones, probe, effectiveMs, localOffsetMinutes, hour24)
  // Where "here" is. Derived from the system zone, which names a
  // representative city - so a user in Boca Raton would read "New York".
  // `homeCity` overrides it for exactly that case.
  readonly property string homeCity: {
    var override = String(setting("homeCity", "")).trim()
    if (override !== "") return override
    return localZone === "" ? "" : Model.labelForZoneId(localZone)
  }

  // A text line box has empty space above the capitals, so padding a row
  // equally top and bottom *looks* top-heavy: the eye measures to the letter,
  // not to the line box. This is that gap, so the top margin can be reduced
  // by exactly it. Derived from the font rather than tuned, so it holds at
  // any base size.
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

  // height - descent is the line box top measured down from the baseline;
  // tightBoundingRect.y is the cap top, also from the baseline (negative).
  // Using ascent alone misses the leading QML puts above it.
  readonly property real capGap: Math.max(0,
    nameFontMetrics.height - nameFontMetrics.descent + nameCapMetrics.tightBoundingRect.y)

  // Coordinates of the city you are in, once the fetcher has geocoded it.
  readonly property var homePlace: {
    if (homeCity === "" || localZone === "") return null
    var f = facts[Model.factsKey({ label: homeCity, id: localZone })]
    if (!f || f.lat === undefined || f.lon === undefined) return null
    return f
  }
  readonly property bool homeKnown: homePlace !== null
  readonly property real homeLat: homeKnown ? homePlace.lat : 0
  // The projection centres whatever longitude `spin` holds, so resting at the
  // home longitude is what leaves your city facing you.
  readonly property real homeLon: homeKnown ? homePlace.lon : 0

  // The sky over any city, as a hex string, or "" when it cannot be known.
  function skyHexFor(zone) {
    if (!skyTint || !zone || !zone.id) return ""
    var f = facts[Model.factsKey(zone)]
    if (!f || f.lat === undefined || f.lon === undefined) return ""
    var c = Sky.tint(Solar.solarElevation(f.lat, f.lon, subsolar))
    return c === null ? "" : c
  }

  readonly property var homeZone: ({ label: homeCity, id: localZone })
  readonly property string homeSkyHex: skyHexFor(homeZone)

  // Which city the globe is showing. Home is the empty key, which is where it
  // starts and where the header line sends it back to.
  //
  // Held as the city's own "label|id" and not as a row number. `zones` is a
  // binding, replaced wholesale on a reorder or a removal, so an index into it
  // silently comes to mean a different city: focus Tokyo, drag a row above it,
  // and the header, the small globe and the next globe opening would all have
  // followed the index to whoever now sat in that slot. The globe learned this
  // the hard way with its own selection - see selectedKey in Globe.qml - and
  // this is the same fix.
  //
  // The index is derived rather than stored, so a reorder carries the focus
  // with the city and a removal drops it back to home, both without anyone
  // having to remember to remap it.
  property string focusKey: ""
  readonly property int focusIndex: Model.indexOfZoneKey(zones, focusKey)
  readonly property var focusZone:
    focusIndex >= 0 ? zones[focusIndex] : homeZone
  readonly property var focusPlace: {
    var f = facts[Model.factsKey(focusZone)]
    return (f && f.lat !== undefined && f.lon !== undefined) ? f : null
  }
  readonly property bool focusKnown: focusPlace !== null
  readonly property real focusLat: focusKnown ? focusPlace.lat : 0
  readonly property real focusLon: focusKnown ? focusPlace.lon : 0
  readonly property string focusSkyHex: skyHexFor(focusZone)

  // Turn the globe to a city by the shortest way round, rather than always
  // forward - a neighbouring time zone should be a nudge, not a lap.
  function focusOn(index) {
    var from = heroIcon.spin
    focusKey = index >= 0 && index < zones.length ? Model.factsKey(zones[index]) : ""
    if (!focusKnown) return
    var d = focusLon - from
    while (d > 180) d -= 360
    while (d <= -180) d += 360
    globeSpin.stop()
    focusSpin.from = from
    focusSpin.to = from + d
    focusSpin.restart()
  }

  // Accent while the clock is off the present, so a scrubbed time can never
  // be mistaken for the real one. Shared by all three renderings of the line.
  readonly property color hereColor: scrubMinutes !== 0 ? Color.accent : dim

  // Where the header sentence goes and whether it is bent: "flat" is a
  // straight line under the title, "under" bends it into a shallow smile
  // there, "over" moves it above the title. Under trial, 2026-08-29 - the
  // shape is a matter of taste, so it is a switch until the author has seen
  // all three, and the two that lose come out with this comment.
  property string hereStyle: "over"
  // Ends up (a smile) or ends down (an arch). At this rise it reads as a
  // tilt of the sentence more than as a curve, which is the point. Arching
  // over the title is the one the author picked, 2026-08-29.
  property bool hereSmile: false
  // Chosen against the width of the sentence, not in the abstract: about a
  // fifth of a line's height over ~40 characters is the most it can take
  // before the ends start to look like they are falling off.
  readonly property real hereRise: Style.space(6)

  // The header sentence, as styled runs. The arc draws it a character at a
  // time and has nowhere to put markup; the flat line below builds its markup
  // from these same runs, so the two spellings of the sentence cannot drift.
  readonly property var hereRuns: {
    var runs = [{ text: "It's " + localTime + " here" }]
    if (homeCity !== "") {
      runs.push({ text: " in " })
      // The name is the way back to your own city, and it is underlined to
      // say so - but only when the sky tint is colouring it, since without
      // the colour an underline on its own reads as a defect in the line.
      runs.push({ text: homeCity, color: homeSkyHex,
                  underline: homeSkyHex !== "" && focusIndex >= 0 })
    }
    // No full stop. The line is a caption on a curve rather than a sentence
    // in a paragraph, and a period hanging off the end of the arc reads as a
    // speck of dirt on the panel.
    return scrubLabel === "" ? runs : runs.concat([{ text: "  " + scrubLabel }])
  }

  // Styled rather than split into separate Texts, so the sentence keeps its
  // spacing and stays one centred, elidable line.
  readonly property string hereText: {
    var out = ""
    for (var i = 0; i < hereRuns.length; i++) {
      var run = hereRuns[i]
      var text = run.text
      if (run.underline) text = "<u>" + text + "</u>"
      if (run.color !== undefined && run.color !== "")
        text = "<font color=\"" + run.color + "\">" + text + "</font>"
      out += text
    }
    return out
  }

  readonly property string localTime: {
    var here = Model.localParts(effectiveMs)
    var text = Model.formatTime(here, hour24)
    return hour24 ? text : text + " " + Model.meridiem(here)
  }

  function tick() {
    nowMs = Date.now()
    localOffsetMinutes = -(new Date().getTimezoneOffset())
  }

  // Cities are edited from the panel, so every change has to survive a
  // restart: write the new list straight back to this widget's shell.json
  // entry, the same path the built-in clock uses for its own settings.
  function persistSettings(values) {
    var entry = { id: root.moduleName }
    for (var existing in root.settings) if (existing !== "id") entry[existing] = root.settings[existing]
    for (var key in values) entry[key] = values[key]

    root.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
  }

  function setZones(next) {
    if (next === root.zones) return
    persistSettings({ zones: Model.serializeZones(next) })
    refresh()
    refreshFacts()
  }

  // Offsets do not change, so this skips the re-probe that setZones does.
  function toggleWork(index) {
    persistSettings({ zones: Model.serializeZones(Model.toggleWorkAt(zones, index)) })
  }

  // The label matters as much as the zone. Half a dozen cities share
  // America/Los_Angeles, and the picker offers them by name - so committing
  // the zone alone put "Los Angeles" on the list when Oakland was chosen.
  // Blank still means "name it after the zone", which is what the IPC and a
  // bare zone id get.
  function addCity(id, label) { setZones(Model.addZone(root.zones, id, label || "")) }

  function startAdding() {
    loadCatalog()
    addQuery = ""
    addIndex = 0
    adding = true
    Qt.callLater(function() { searchField.text = ""; searchField.forceActiveFocus() })
  }

  function stopAdding() {
    adding = false
    addQuery = ""
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function commitMatch(id, label) {
    addCity(id, label)
    stopAdding()
  }

  // What each search result's zone is doing right now. The probe that feeds
  // the rows only knows the cities you already track; a search result is a
  // place you have not added yet, and its offset is half of what tells two
  // entries in the same zone apart.
  //
  // Merged rather than replaced on each answer, so a zone that has already
  // been asked about keeps its offset while the next probe is in flight.
  // Replacing blanked the column on every keystroke, which read as flicker.
  property var searchProbe: ({})
  property bool searchProbeQueued: false

  readonly property var searchZoneIds: {
    var out = [], seen = {}
    for (var i = 0; i < addMatches.length; i++) {
      var id = addMatches[i].value
      if (!seen[id]) { seen[id] = true; out.push(id) }
    }
    return out
  }

  onSearchZoneIdsChanged: probeSearchZones()

  function probeSearchZones() {
    if (searchZoneIds.length === 0) return
    if (searchProc.running) { searchProbeQueued = true; return }
    searchProc.running = true
  }

  function utcLabelFor(zoneId) {
    var known = searchProbe[zoneId]
    return known === undefined ? "" : Model.utcOffsetLabel(known.offsetMinutes)
  }

  // Which match the keyboard is on. An index into addMatches rather than the
  // match itself: the list is rebuilt on every keystroke, and an index
  // survives that where an object identity does not.
  property int addIndex: 0

  // A changed query is a different list, so the selection goes back to the
  // top. Leaving it on row four of a list that has just been replaced means
  // Return adds a city nobody looked at.
  onAddQueryChanged: addIndex = 0
  onAddMatchesChanged: if (addIndex >= addMatches.length) addIndex = 0

  // Wraps at both ends. The list is six long at most and entirely on screen,
  // so there is no edge to protect anyone from, and wrapping means holding
  // Down can never strand the selection against the bottom.
  function moveAddSelection(delta) {
    var count = addMatches.length
    if (count === 0) { addIndex = 0; return }
    addIndex = ((addIndex + delta) % count + count) % count
  }

  function commitSelectedMatch() {
    if (addMatches.length === 0) return
    var match = addMatches[Math.max(0, Math.min(addIndex, addMatches.length - 1))]
    commitMatch(match.value, match.label)
  }
  function removeCity(id) { setZones(Model.removeZone(root.zones, id)) }
  function removeCityAt(index) { setZones(Model.removeZoneAt(root.zones, index)) }

  // Temperature and currency. The script caches on disk with its own TTLs, so
  // calling this on every open is cheap - a warm run does no network at all.
  // What the fetcher is asked about: the tracked cities, plus the city you
  // are in - it is not a row, but the header needs its coordinates to tint
  // the name, and a geocode is cached forever anyway.
  readonly property var factsRequest: {
    var out = []
    for (var i = 0; i < zones.length; i++)
      out.push({ label: zones[i].label, id: zones[i].id })
    if (localZone !== "" && homeCity !== "")
      out.push({ label: homeCity, id: localZone })
    for (var j = 0; j < sessionCities.length; j++)
      out.push({ label: sessionCities[j].label, id: sessionCities[j].id })
    return out
  }

  // Session cities in the globe's shape, once their coordinates land.
  readonly property var sessionPlaces: {
    var out = []
    for (var i = 0; i < sessionCities.length; i++) {
      var z = sessionCities[i]
      var f = facts[Model.factsKey(z)]
      if (!f || f.lat === undefined || f.lon === undefined) continue
      out.push([z.label, z.id, f.lat, f.lon, 1])
    }
    return out
  }

  function addSessionCity(label, id) {
    for (var i = 0; i < sessionCities.length; i++)
      if (sessionCities[i].label === label && sessionCities[i].id === id) return
    var next = sessionCities.slice()
    next.push({ label: label, id: id })
    sessionCities = next
    refreshFacts()
  }

  // Write the starting list on a fresh install: the city you are in, plus
  // four well-known places spread round the clock from it. Chosen relative to
  // home rather than fixed, or someone in Paris would be handed a second
  // Paris and a spread that is really a spread around California.
  function seedFirstRun() {
    var offs = ({})
    for (var id in probe) offs[id] = probe[id].offsetMinutes

    var seeded = localZone === "" ? []
      : Model.seedZones({ label: Model.labelForZoneId(localZone), id: localZone },
                        offs, 4)

    // Only if the local zone could not be read at all - a machine with no
    // timedatectl and no /etc/localtime. Better a working clock than none.
    if (seeded.length === 0) seeded = Model.parseZones(Model.DEFAULT_ZONES)
    if (seeded.length === 0) return

    persistSettings({ zones: Model.serializeZones(seeded) })
    refresh()
    refreshFacts()
  }

  function refreshFacts() {
    if (zones.length === 0) return
    if (factsProc.running) { factsQueued = true; return }
    factsProc.running = true
  }

  // The pointer lands at `fraction` across a city's strip; move the clock to
  // that city's local time. Measured against the unscrubbed present so the
  // mapping is absolute and a drag cannot drift.
  function scrubTo(rowData, fraction) {
    if (!rowData || !rowData.ready) return
    var parts = Model.zoneParts(nowMs, rowData.offsetMinutes)
    scrubMinutes = Model.scrubDeltaMinutes(fraction, parts.hour * 60 + parts.minute)
  }

  function beginScrub(rowData, fraction) {
    scrubHold.stop()
    scrubbing = true
    scrubTo(rowData, fraction)
  }

  function endScrub() {
    scrubbing = false
    scrubHold.restart()
  }

  function loadCatalog() {
    if (zoneCatalogText !== "" || catalogProc.running) return
    catalogProc.running = true
  }

  // A city added while a probe is in flight would otherwise sit unprobed —
  // and unprobed means a row with no time on it — until the next open or the
  // five-minute tick. Queue the re-probe instead of dropping it.
  function refresh() {
    // probeIds, not zoneIds: on a fresh install there are no cities yet, and
    // guarding on those would skip the very probe whose answer decides what
    // the first cities should be.
    if (probeIds.length === 0) return
    if (probeProc.running) { probeQueued = true; return }
    probeProc.running = true
  }

  // The opening spin lands on the home meridian, so it cannot start until it
  // knows where home is.
  //
  // globeSpin's from and to are bindings on focusLon, and a NumberAnimation
  // reads them once, when it starts. Home's coordinates arrive from the
  // geocode a couple of hundred milliseconds after the panel opens, so
  // starting immediately captured to: 0, spun three turns to Greenwich, and
  // left the Binding below to snap the globe to the home meridian afterwards.
  // That snap is the jump. Same family as the duration trap in CLAUDE.md: an
  // animation must not read a property that is still settling.
  property bool spinPending: false

  // The meridian the opening spin has to land on, read straight out of the
  // facts rather than through focusLon.
  //
  // focusKnown and focusLon are two bindings over the same focusPlace, and
  // when the geocode lands focusKnown flips to true a beat before focusLon
  // has the coordinate: measured, known=true with lon=0. Gating on focusKnown
  // and then reading focusLon started the spin with to: 0, so it turned three
  // times, stopped on Greenwich, and left the Binding to snap the globe to
  // home - which is the jump.
  function homeMeridian() {
    var f = facts[Model.factsKey(focusZone)]
    return (f && f.lon !== undefined && f.lon !== null) ? f.lon : null
  }

  function startOpeningSpin() {
    var lon = homeMeridian()
    if (lon === null) { spinPending = true; spinFallback.restart(); return }
    spinPending = false
    spinFallback.stop()
    // Set, then start - never leave the endpoints as bindings on a value that
    // is still settling. Same rule as setGlobeMode's duration.
    globeSpin.stop()
    globeSpin.from = lon - 1080
    globeSpin.to = lon
    globeSpin.restart()
  }

  // Driven by the facts arriving, not by focusKnown: this reads the
  // coordinate itself, so there is no ordering to lose.
  onFactsChanged: if (spinPending) startOpeningSpin()

  // If the coordinates never turn up - no network on a cold cache - spin
  // anyway rather than sitting still. It lands wherever it can.
  Timer {
    id: spinFallback
    interval: 1500
    onTriggered: if (root.spinPending) { root.spinPending = false; globeSpin.restart() }
  }

  onOpenedChanged: {
    if (opened) {
      focusKey = ""
      tick(); refresh(); refreshFacts(); loadCatalog()
      startOpeningSpin()
    }
    else {
      stopAdding(); setGlobeMode(false, false); scrubbing = false; scrubMinutes = 0
      spinPending = false; spinFallback.stop()
    }
  }
  Component.onCompleted: refresh()

  // One process, one line per zone: "Asia/Tokyo|JST|+0900". The zone names
  // are passed as arguments rather than interpolated into the script, so a
  // configured zone can never become shell syntax.
  // One `date` for however many zones the search is showing - at most six, and
  // coalesced while one is in flight, so a fast typist spends one process per
  // answer rather than one per keystroke.
  Process {
    id: searchProc
    command: ["bash", "-c",
      "for z in \"$@\"; do TZ=\"$z\" date \"+$z|%Z|%z\"; done", "bash"]
      .concat(root.searchZoneIds)
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
    id: probeProc
    // One extra line, "LOCAL|<zone>", so the panel can name the city you are
    // in without spending a row on it. timedatectl is authoritative; the
    // /etc/localtime symlink is the fallback where it is absent.
    command: ["bash", "-c",
      "tz=$(timedatectl show -p Timezone --value 2>/dev/null"
      + " || readlink -f /etc/localtime | sed 's|.*/zoneinfo/||'); "
      // The local zone is emitted twice: once as the LOCAL marker, and once as
      // an ordinary row, so its offset is available like any other city's -
      // which the first-run seed needs and cannot ask for in advance.
      + "printf 'LOCAL|%s\\n' \"$tz\"; TZ=\"$tz\" date \"+$tz|%Z|%z\"; "
      + "for z in \"$@\"; do TZ=\"$z\" date \"+$z|%Z|%z\"; done", "bash"].concat(root.probeIds)
    stdout: StdioCollector {
      onStreamFinished: {
        root.probe = Model.parseProbe(text)
        var lz = Model.localZoneFromProbe(text)
        if (lz !== "") root.localZone = lz
        root.probed = true
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

  // The pickable zone list. systemd knows it; the zoneinfo tree is the
  // fallback for a system without timedatectl.
  Process {
    id: catalogProc
    command: ["bash", "-c",
      "timedatectl list-timezones 2>/dev/null || find /usr/share/zoneinfo -type f -printf '%P\\n' 2>/dev/null | grep / | sort"]
    stdout: StdioCollector {
      onStreamFinished: root.zoneCatalogText = text
    }
  }

  Process {
    id: factsProc
    command: root.showCurrency
      ? ["python3", root.pluginDir + "/worldclock-data.py", JSON.stringify(root.factsRequest)]
      : ["python3", root.pluginDir + "/worldclock-data.py", JSON.stringify(root.factsRequest), "--no-fx"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var parsed = JSON.parse(text)
          if (parsed && parsed.cities) root.facts = parsed.cities
        } catch (e) {
          // A broken payload leaves the previous values on screen, which is
          // better than blanking every row over one bad fetch.
        }
        Qt.callLater(function() {
          if (!root.factsQueued) return
          root.factsQueued = false
          root.refreshFacts()
        })
      }
    }
  }

  // Weather moves; the script's own TTL decides whether this costs a request.
  Timer {
    interval: 900000
    running: root.opened
    repeat: true
    onTriggered: root.refreshFacts()
  }

  // Heavy on the way out, brisk on the way back. OutQuint spends most of its
  // travel early and then settles for a long time, which is what gives the
  // globe its weight; coming back wants to feel like tidying up, not like
  // being pushed.
  Behavior on zoom {
    NumberAnimation {
      duration: root.zoomDuration
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

  // Only while the show is running, so the reset to -1 is instant.
  Behavior on moonDemo {
    enabled: root.moonShowing
    NumberAnimation { duration: 460; easing.type: Easing.InOutSine }
  }

  NumberAnimation {
    id: dropAnimation
    target: root
    property: "dragOffset"
    duration: 150
    easing.type: Easing.OutCubic
    onFinished: root.commitRowDrag()
  }

  // Hold the scrubbed time briefly after release, so the answer can be read
  // before the clock returns to the present.
  Timer {
    id: scrubHold
    interval: 2500
    onTriggered: root.scrubMinutes = 0
  }

  // Only ticks while the panel is on screen; a closed panel has nothing to
  // repaint.
  Timer {
    interval: 1000
    running: root.opened
    repeat: true
    onTriggered: root.tick()
  }

  // Catches a DST rollover during a long-open panel.
  Timer {
    interval: 300000
    running: root.opened
    repeat: true
    onTriggered: root.refresh()
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { root.refresh(); return "ok" }

    // TEMPORARY - remove with the header-arc trial.
    function hereline(style: string, smile: string): string {
      if (style !== "") root.hereStyle = style
      if (smile !== "") root.hereSmile = smile === "smile"
      return root.hereStyle + " " + (root.hereSmile ? "smile" : "arch")
    }
    // The tick timer only runs while the panel is open, so a caller asking
    // over IPC with the panel closed would otherwise get whatever minute it
    // was when the panel last closed.
    function globeStatus(): string {
      return JSON.stringify({
        mode: root.globeMode,
        active: globeLoader.active,
        status: globeLoader.status,
        source: String(globeLoader.source),
        item: globeLoader.item !== null,
        land: globeLoader.item ? globeLoader.item.land.length : -1,
        cities: globeLoader.item ? globeLoader.item.allCities.length : -1,
        offsets: globeLoader.item ? Object.keys(globeLoader.item.offsets).length : -1,
        labels: globeLoader.item ? globeLoader.item.labels.length : -1,
        plotted: globeLoader.item ? globeLoader.item.plotted.length : -1,
        h: globeLoader.height,
        w: globeLoader.width
      })
    }

    function globe(): string {
      if (!root.globeEnabled) return "disabled"
      root.setGlobeMode(!root.globeMode, false)
      return root.globeMode ? "globe" : "list"
    }

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
    // Leaned over like the real thing, same obliquity as the panel globe.
    textRotation: Solar.AXIAL_TILT
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
      // Escape unwinds one layer at a time rather than closing outright: out
      // of the globe first, then out of the panel. The search fields handle
      // their own Escape before this ever sees it, so the full ladder is
      // search, globe, panel - each press undoing the last thing that opened.
      onCloseRequested: {
        if (root.globeMode) root.setGlobeMode(false, false)
        else root.close()
      }
      // Space opens the globe and closes it again.
      //
      // It was a door rather than a switch for a while, on the argument that
      // Escape already unwinds one layer at a time and one key per direction is
      // easier to hold in the head. That argument is about the keyboard as a
      // system; this is about the hand, which is already on the space bar and
      // has nowhere to go for the round trip. Escape still works, and still
      // unwinds the whole ladder, so nothing is lost by letting Space come back
      // the way it went.
      //
      // The catcher reports Space as "activate", and reports Return as a
      // return *and then* an activate. Only Space is meant to work the globe,
      // so Return marks itself on the way past and the activate behind it
      // steps aside.
      property bool returnHandled: false
      onReturnRequested: returnHandled = true
      onActivateRequested: {
        if (returnHandled) { returnHandled = false; return }
        if (root.globeEnabled) root.setGlobeMode(!root.globeMode, false)
      }
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(text) {
        if (text === "r" || text === "R") root.refresh()
        // One key for "add something", whichever list is in front of you: the
        // globe's jump box and the panel's city search are the same gesture
        // pointed at two different places.
        if (text === "+") {
          if (root.globeMode && globeLoader.item) globeLoader.item.startJump()
          else if (!root.globeMode) root.startAdding()
        }
        // Then a letter per box, each one named after the box it opens: "j"
        // for the globe's "Jump to a city", "a" for the list's "Add a city".
        // "+" stays as the one key that means the same thing in both views.
        // Neither letter crosses over - "a" on the globe would be adding
        // nothing, since a jump is only ever for the session - and a mnemonic
        // that stops matching its own word is worse than no mnemonic.
        if ((text === "j" || text === "J") && root.globeMode && globeLoader.item)
          globeLoader.item.startJump()
        if ((text === "a" || text === "A") && !root.globeMode)
          root.startAdding()
      }

      // The card stops growing at its cap - the screen's height, or space(680),
      // whichever is smaller - but the column inside it does not, so whatever
      // did not fit used to paint straight past the border. The search results
      // were the easy way to see it; a long enough list of cities does it on
      // its own. Clipped here so nothing can leave the card, and scrollable so
      // what overflows is still reachable.
      //
      // Not interactive: the rows own the pointer. Drag-to-reorder and the
      // scrub strip are MouseAreas with preventStealing, and a Flickable that
      // grabbed drags would be fighting them for every gesture. The wheel is
      // free, so that is what scrolls.
      Flickable {
        id: scroller
        anchors.fill: parent
        clip: true
        interactive: false
        contentWidth: width
        contentHeight: content.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        readonly property real maxScroll: Math.max(0, contentHeight - height)

        function clamp() {
          contentY = Math.max(0, Math.min(contentY, maxScroll))
        }
        onHeightChanged: clamp()
        onContentHeightChanged: clamp()

        // While the search is open the results are the point of the panel, so
        // it scrolls to them rather than leaving the last one clipped against
        // the bottom.
        //
        // Driven by maxScroll rather than fired once when the search opens.
        // The card grows into its cap and the Repeater builds the result rows
        // over the frames after `adding` flips, so a one-shot call - even a
        // Qt.callLater - reads a list that has not finished arriving and
        // scrolls to where it used to end. It measured maxScroll 0 doing
        // exactly that. Following the property instead lands on each new
        // bottom as the list settles.
        function scrollToResults() {
          scrollAnim.stop()
          scrollAnim.from = contentY
          scrollAnim.to = maxScroll
          scrollAnim.start()
        }

        onMaxScrollChanged: if (root.adding) scrollToResults()

        function scrollToTop() {
          scrollAnim.stop()
          scrollAnim.from = contentY
          scrollAnim.to = 0
          scrollAnim.start()
        }

        // Set explicitly rather than through a Behavior: the wheel writes
        // contentY too, and a Behavior would animate every notch of it into a
        // slow chase instead of tracking the fingers.
        NumberAnimation {
          id: scrollAnim
          target: scroller
          property: "contentY"
          duration: 160
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
          spacing: Style.space(14)

          // ---- Hero. The title reads "World [globe] Clock" with the globe
          // itself as the button into globe mode, centred over the panel so it
          // sits square above either the list or the globe.
          Column {
            width: parent.width
            spacing: Style.space(2)

            // The same line, above the title. See the note on its twin below.
            ArcText {
              width: parent.width
              visible: root.hereStyle === "over"
              runs: root.hereRuns
              rise: root.hereRise
              smile: root.hereSmile
              color: root.hereColor
              fontFamily: root.fontFamily
              pixelSize: Style.font.caption
              MouseArea {
                anchors.fill: parent
                enabled: root.focusIndex >= 0
                cursorShape: Qt.PointingHandCursor
                onClicked: root.focusOn(-1)
              }
            }

            Row {
              anchors.horizontalCenter: parent.horizontalCenter
              spacing: Style.space(9)

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "World"
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
                font.weight: Font.DemiBold
              }

              // OpticalGlyph is a zero-sized Item that centers its glyph on the
              // box, so without an explicit one the icon paints half its width
              // to the left of where it sits.
              Item {
                id: heroIcon
                anchors.verticalCenter: parent.verticalCenter
                // The centrepiece, so it is drawn larger than a text icon.
                implicitWidth: Math.round(Style.font.display * 1.3)
                implicitHeight: Math.round(Style.font.display * 1.3)

                // Spun about the vertical axis, the way the earth turns -
                // east to west across the face - rather than tumbling in the
                // plane of the screen. Edge-on twice per turn, which is what
                // sells it as a sphere.
                property real spin: 0

                // At rest the globe sits with your city facing you. The
                // animation writes this property directly while it runs, so the
                // binding stands down for the duration.
                Binding {
                  target: heroIcon
                  property: "spin"
                  value: root.focusLon
                  when: !globeSpin.running && !focusSpin.running
                  restoreMode: Binding.RestoreNone
                }

                // Two transforms, applied in order: spin about the polar
                // axis, then lean the whole globe over by Earth's obliquity.
                // Tilting after the spin is what makes the axis itself tilted,
                // rather than the globe wobbling upright inside a tilted frame.
                // The spin is drawn into the globe now, not applied as a
                // transform; all that is left here is leaning the axis over by
                // Earth's obliquity.
                rotation: Solar.AXIAL_TILT

                // The little globe hands over to a cross once the big one has
                // left the circle, so the circle keeps its job: it is the way
                // in, and then it is the way out.
                Text {
                  anchors.centerIn: parent
                  text: "\u00d7"
                  color: heroHover.hovered ? root.foreground : root.dim
                  font.family: root.fontFamily
                  font.pixelSize: Math.round(heroIcon.width * 0.8)
                  // The circle leans with the earth; the cross should not.
                  rotation: -Solar.AXIAL_TILT
                  opacity: Math.max(0, Math.min(1, (root.zoom - 0.2) / 0.35))
                  visible: opacity > 0
                }

                MiniGlobe {
                  anchors.fill: parent
                  opacity: 1 - root.bigGlobeOpacity
                  visible: opacity > 0
                  spin: heroIcon.spin
                  // Full strength always: at this size a dimmed globe reads as
                  // washed out rather than as "inactive".
                  color: root.foreground
                  bold: true
                  showMarker: root.focusKnown
                  markerLat: root.focusLat
                  markerLon: root.focusLon
                  // The same sky the header paints the city name with, so the
                  // dot and the name agree about what time of day it is there.
                  // Falls back to the accent when the tint is switched off.
                  markerColor: root.focusSkyHex !== "" ? root.focusSkyHex : Color.accent
                }

                // One MouseArea rather than a HoverHandler plus a TapHandler:
                // only the classic mouse events carry the keyboard modifiers,
                // and slow motion has to know whether Shift was down at the
                // moment of the click. Doing hover here too keeps a single
                // input item over the circle instead of two that could disagree
                // about which one is receiving the pointer.
                MouseArea {
                  id: heroHover
                  anchors.fill: parent
                  enabled: root.globeEnabled
                  hoverEnabled: true
                  acceptedButtons: Qt.LeftButton
                  cursorShape: Qt.PointingHandCursor
                  readonly property bool hovered: containsMouse
                  onClicked: function(mouse) {
                    root.setGlobeMode(!root.globeMode,
                                      (mouse.modifiers & Qt.ShiftModifier) !== 0)
                  }
                }

                // Three turns on opening the panel, thrown rather than driven:
                // OutQuart puts most of the rotation in the first third and
                // lets the rest coast out, which is what a globe flicked by
                // hand does. Under a second and a half start to stop.
                NumberAnimation {
                  id: globeSpin
                  target: heroIcon
                  property: "spin"
                  // Three whole turns that land on the home meridian, so it
                  // stops with your own city in view rather than wherever the
                  // arithmetic happens to leave it. from and to are set by
                  // startOpeningSpin immediately before it runs, not bound -
                  // see the note there.
                  duration: 1250
                  easing.type: Easing.OutQuart
                }

                // Turning to a city that was clicked: shorter, and decaying the
                // same way so both motions feel like the same globe.
                NumberAnimation {
                  id: focusSpin
                  target: heroIcon
                  property: "spin"
                  duration: 700
                  easing.type: Easing.OutCubic
                }
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Clock"
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
                font.weight: Font.DemiBold
              }
            }

            // The curved sentence, below the title. Declared twice rather
            // than moved, because a Column orders its children by declaration
            // and skips the invisible ones entirely - so which of these two is
            // visible is also which side of the title the line lands on.
            ArcText {
              width: parent.width
              visible: root.hereStyle === "under"
              runs: root.hereRuns
              rise: root.hereRise
              smile: root.hereSmile
              color: root.hereColor
              fontFamily: root.fontFamily
              pixelSize: Style.font.caption
              MouseArea {
                anchors.fill: parent
                enabled: root.focusIndex >= 0
                cursorShape: Qt.PointingHandCursor
                onClicked: root.focusOn(-1)
              }
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              width: parent.width
              visible: root.hereStyle === "flat"
              horizontalAlignment: Text.AlignHCenter
              elide: Text.ElideRight
              textFormat: Text.StyledText
              text: root.hereText

              // Only live while the globe is showing somewhere else, so it is
              // not a dead click target the rest of the time. The whole line is
              // the target rather than just the name - it is a small piece of
              // text to have to hit exactly.
              MouseArea {
                anchors.fill: parent
                enabled: root.focusIndex >= 0
                cursorShape: Qt.PointingHandCursor
                onClicked: root.focusOn(-1)
              }
              color: root.hereColor
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }

            // The answer to "when can we all talk", in your own clock.
            Text {
              width: parent.width
              visible: root.zoom < 1 && text !== ""
              opacity: 1 - root.zoom
              horizontalAlignment: Text.AlignHCenter
              wrapMode: Text.WordWrap          // two windows is a long line
              textFormat: Text.PlainText
              text: root.overlapText
              color: root.overlap.length === 0 ? root.fainter : Color.accent
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              topPadding: Style.space(3)
            }
          }

          // ---- The stage. The list and the globe share it, and one `zoom`
          // value moves between them: the globe grows out of the little circle
          // in the header while the rows are shoved aside, and the stage itself
          // grows with them so the whole panel opens out rather than swapping
          // one view for another.
          Item {
            id: stage
            width: parent.width
            // Deliberately not clipped: at the start of the flight the globe is
            // still up in the header, above this item, and clipping here would
            // cut it in half exactly when it should look like the little circle.
            height: Math.max(1, listWrap.implicitHeight
                    + (root.globeStageHeight - listWrap.implicitHeight) * root.zoom)

            // The rows do get clipped, so that as they are shoved aside they
            // slide out of the panel rather than piling up past its edge.
            Item {
              anchors.fill: parent
              clip: true

              Column {
                id: listWrap
                width: parent.width
                spacing: Style.space(14)

                // ---- One row per city.
                Column {
                  id: rowsColumn
                  visible: root.zoom < 1
                  width: parent.width
                  spacing: Style.space(6)

                  Repeater {
                    // Modelled on the zone list, not on clockRows. clockRows is a
                    // binding on the (scrubbable, ticking) clock, so using it as the
                    // model rebuilt every delegate on every tick - and destroyed the
                    // MouseArea mid-drag the instant scrubbing began, which turned
                    // every drag into a click. The zone list only changes when a city
                    // is added or removed.
                    model: root.zones

                    Rectangle {
                      id: row
                      required property var modelData
                      required property int index

                      readonly property var rowData: root.clockRows[index]
                        || ({ ready: false, label: modelData.label, id: modelData.id })

                      // What is said out loud there at this hour. Cheap enough to
                      // recompute every tick - it is a table lookup - and it has to
                      // be, because the hour it depends on is what ticks.
                      readonly property var greeting:
                        Greet.greeting(rowData.id, rowData.ready ? rowData.hour : 0)

                      // Purely visual: a transform does not disturb the Column's
                      // layout, so the model stays still while the pointer moves.
                      // Two transforms: the drag offset the row already had, and
                      // the shove that clears it out of the globe's way.
                      transform: [
                        Translate {
                          x: root.knockX(row.index)
                          y: root.knockY(row.index)
                        },
                        Rotation {
                          origin.x: row.width / 2
                          origin.y: row.height / 2
                          angle: root.knockTilt(row.index)
                        },
                        Scale {
                          origin.x: row.width / 2
                          origin.y: row.height / 2
                          xScale: root.knockShrink(row.index)
                          yScale: root.knockShrink(row.index)
                        },
                        Translate {
                          y: root.rowShift(row.index)
                          // The rows making room ease into place. The dragged row is
                          // excluded: it must follow the pointer one-to-one or it
                          // feels like it is lagging behind the cursor.
                          Behavior on y {
                            enabled: root.dragIndex !== row.index
                            NumberAnimation { duration: 130; easing.type: Easing.OutCubic }
                          }
                        }
                      ]
                      z: root.dragIndex === row.index ? 2 : 0
                      opacity: (root.dragIndex === row.index ? 0.9 : 1)
                               * root.knockFade(row.index)

                      Behavior on opacity { NumberAnimation { duration: 120 } }

                      // The last city stays put; removing it would leave an empty
                      // panel with no way back.
                      readonly property bool removable: root.clockRows.length > 1

                      // Anything you click on this row that is not an arrow or the
                      // moon puts the chip away. A tooltip that can only be
                      // dismissed by hitting the same few pixels that opened it is a
                      // trap: clicking elsewhere is what everyone tries first, and
                      // until now it did nothing.
                      //
                      // Called from each of the row's own handlers rather than from
                      // a transparent sheet over the row. A sheet would have to sit
                      // above the drag grab and the scrub strip to see the press,
                      // and would then be in the way of both.
                      function dismissChips() { sunArrows.shown = Model.NO_CHIP }

                      // The two big surfaces - the reorder grab and the scrub strip
                      // - lie under the arrows, so a click on an arrow reaches them
                      // as well. Both therefore dismiss only if nothing opened or
                      // closed a chip during the same press.
                      //
                      // Written so that either delivery order is correct, because
                      // the order is Qt's business and not worth depending on. Tap
                      // first: the chip has changed by the time release runs, so
                      // release leaves it alone. Release first: it dismisses, and
                      // the tap that follows sets the chip from what it read at
                      // *press* time rather than from what the dismissal just did -
                      // which is why every one of these decisions is made against a
                      // value captured on press.
                      function dismissUnlessChanged(atPress) {
                        sunArrows.shown = Model.chipAfterRelease(sunArrows.shown, atPress)
                      }

                      // This city's own sunrise and sunset, for the strip below.
                      //
                      // Null until the fetcher's geocode lands, and null forever
                      // for a city it cannot place. The strip falls back to the
                      // fixed civil band in that case, which is what it always
                      // drew - a row with no coordinates should look like the old
                      // honest convention rather than like a broken new feature.
                      //
                      // Keyed to the local day, not to the clock.
                      //
                      // The panel's timer reassigns nowMs every second, and this
                      // used to read effectiveMs directly - so `sun` returned a new
                      // object every second, `sunMarks` a new array, and the three
                      // Repeaters below destroyed and rebuilt every delegate once a
                      // second. CLAUDE.md already lists that trap from the drag
                      // work; this walked back into it. The cost was not only waste:
                      // a press on an arrow could outlive the arrow.
                      //
                      // Sunrise does not change during a day, so the whole thing
                      // hangs off local midnight, which changes once a day and when
                      // the scrubber crosses into another one - which is exactly
                      // when the band should be redrawn, so the scrubber still
                      // sweeps it.
                      //
                      // The three properties below are the barrier. clockRows is
                      // rebuilt every tick, so anything reading `rowData` directly
                      // re-evaluates every tick however little has changed; reading
                      // it once into a bool, an int and a double stops that there,
                      // because a property whose value has not changed emits no
                      // change signal. factsKey is taken from modelData - the zone
                      // itself - for the same reason.
                      readonly property bool sunReady: row.rowData.ready
                      readonly property int sunOffset:
                        row.rowData.ready ? row.rowData.offsetMinutes : 0
                      readonly property double sunDayMs:
                        row.sunReady ? Sun.localMidnightMs(root.effectiveMs, row.sunOffset) : 0

                      readonly property var sun: {
                        if (!row.sunReady) return null
                        var f = root.facts[Model.factsKey(row.modelData)]
                        if (!f || f.lat === undefined || f.lon === undefined) return null
                        // Noon of that local day: any instant inside it gives the
                        // same answer, and noon is the furthest from either edge.
                        return Sun.sunTimes(f.lat, f.lon, row.sunDayMs + 43200000,
                                            row.sunOffset)
                      }

                      // Where the sun crosses the horizon on this bar, as
                      // {x, minutes} in bar fractions. Empty above the Arctic
                      // circle in the weeks when it does not cross at all.
                      readonly property var sunMarks: {
                        if (!row.sun || row.sun.kind !== "normal") return []
                        var out = []
                        var up = Sun.eventMark(row.sun.riseMinutes)
                        var down = Sun.eventMark(row.sun.setMinutes)
                        if (up !== null) out.push({ x: up, minutes: row.sun.riseMinutes,
                                                    rising: true, name: "Sunrise" })
                        if (down !== null) out.push({ x: down, minutes: row.sun.setMinutes,
                                                      rising: false, name: "Sunset" })
                        return out
                      }

                      // Read from the band the strip actually draws, so the sun can
                      // never be painted sitting in the dark half of its own bar.
                      readonly property bool litNow:
                        row.sun ? Sun.litAt(row.sun, row.rowData.ready ? row.rowData.progress * 1440 : 0)
                                : (row.rowData.ready && row.rowData.lit)

                      // Rows read lightest at midday and darkest at night, so the
                      // list dims as your eye travels into the small hours.
                      readonly property real phaseFill: {
                        var p = row.rowData.ready ? row.rowData.phase : "day"
                        if (p === "day") return 0.10
                        if (p === "night") return 0.035
                        return 0.07
                      }

                      width: parent.width
                      // Padding is stated once and used on both ends, so the space
                      // above the name always matches the space below the strip.
                      readonly property int pad: Style.space(15)
                      readonly property int stripGap: Style.space(9)

                      implicitHeight: (pad - root.capGap) + rowLabels.implicitHeight
                                    + stripGap + strip.height + pad
                      radius: Style.cornerRadius
                      color: root.solid(rowHover.hovered ? phaseFill + 0.05 : phaseFill)
                      border.width: 0

                      // ---- Daylight strip: this city's own 24 hours, midnight to
                      // midnight, with the civil-daylight window lit and a marker at
                      // now. Read down the column and you can see who is awake —
                      // markers sitting in the lit band are in daylight, markers out
                      // in the dark ends are not.
                      //
                      // The band is this city's real day, from its own sunrise to
                      // its own sunset, computed from the coordinates the fetcher
                      // already geocoded for the weather. Reykjavik in December and
                      // Auckland in January are different shapes, and that
                      // difference is most of what a daylight bar is worth looking
                      // at. A city with no coordinates yet keeps the old fixed
                      // civil band rather than showing nothing.
                      Rectangle {
                        id: strip
                        visible: row.rowData.ready
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: Style.space(12)
                        anchors.rightMargin: Style.space(12)
                        // The same pad the top uses, so the two ends stay in step
                        // whatever it is set to.
                        anchors.bottomMargin: row.pad
                        height: Math.max(2, Style.space(3))
                        radius: height / 2
                        color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.10)

                        // A Repeater over spans rather than one Rectangle, because
                        // the count is not always one: polar night draws no band at
                        // all, and drawing it as a zero-width one would leave a seam
                        // where the day is supposed to be missing.
                        Repeater {
                          model: row.sun ? Sun.litSpans(row.sun)
                                         : [{ x0: Model.daylightStart(), x1: Model.daylightEnd() }]

                          Rectangle {
                            required property var modelData
                            x: parent.width * modelData.x0
                            width: Math.max(1, parent.width * (modelData.x1 - modelData.x0))
                            height: parent.height
                            radius: parent.radius
                            color: Qt.rgba(root.foreground.r, root.foreground.g,
                                           root.foreground.b, 0.28)
                          }
                        }

                        // The shared working window, drawn in this city's own local
                        // hours. The same real interval lands at a different place on
                        // every row - which is the point: one instant, many clocks.
                        Repeater {
                          model: root.showOverlap
                            ? Model.localSegments(root.overlap, row.rowData.offsetMinutes)
                            : []

                          Rectangle {
                            required property var modelData
                            x: parent.width * modelData.x0
                            width: Math.max(1, parent.width * (modelData.x1 - modelData.x0))
                            height: parent.height
                            radius: parent.radius
                            color: Color.accent
                            opacity: 0.75
                          }
                        }

                        Rectangle {
                          id: nowMarker
                          // Sun and moon are the same size. They are the same
                          // marker in the same place meaning the same thing -
                          // "now" - so only their content should differ.
                          width: Math.max(8, Style.space(10))
                          height: width
                          radius: width / 2
                          x: Math.round(parent.width * (row.rowData.ready ? row.rowData.progress : 0) - width / 2)
                          y: (parent.height - height) / 2
                          color: row.litNow ? root.daylightMarker : "transparent"

                          // By night the same marker becomes the moon, showing
                          // tonight's phase. One element, two facts.
                          MoonDot {
                            anchors.fill: parent
                            visible: !row.litNow
                            phase: root.moonPhase
                            color: root.foreground
                          }

                          Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                        }
                      }

                      HoverHandler { id: rowHover }

                      // Grab anywhere on the body of the row to reorder. Stops above
                      // the strip so it never competes with the time scrubber, and is
                      // declared first so the briefcase and remove buttons - later
                      // siblings - keep their taps.
                      MouseArea {
                        id: grab
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: strip.top
                        preventStealing: true
                        cursorShape: root.dragIndex === row.index ? Qt.ClosedHandCursor
                                                                  : Qt.OpenHandCursor

                        property real pressY: 0
                        property bool armed: false

                        // The pointer measured in the Column, which never moves.
                        // Reading mouse.y directly is a feedback loop: this MouseArea
                        // sits inside the row, the row is translated by dragOffset, so
                        // the local frame slides out from under a stationary pointer
                        // and the offset chases itself. That was the stutter.
                        function pointerY(mouse) {
                          return grab.mapToItem(rowsColumn, 0, mouse.y).y
                        }

                        property int chipAtPress: -1

                        onPressed: function(mouse) {
                          pressY = pointerY(mouse)
                          armed = false
                          chipAtPress = sunArrows.shown
                        }

                        onPositionChanged: function(mouse) {
                          var dy = pointerY(mouse) - pressY
                          // A few pixels of slack, so a click is never a reorder.
                          if (!armed) {
                            if (Math.abs(dy) < Style.space(4)) return
                            armed = true
                            dropAnimation.stop()
                            root.dragIndex = row.index
                            root.dragTarget = row.index
                            root.rowPitch = row.height + rowsColumn.spacing
                          }
                          root.dragOffset = dy
                          root.updateDragTarget()
                        }

                        onReleased: {
                          // A drag reorders; a click without one turns the globe.
                          if (armed) root.releaseRowDrag()
                          else root.focusOn(row.index)
                          armed = false
                          row.dismissUnlessChanged(chipAtPress)
                        }
                        onCanceled: {
                          root.cancelRowDrag()
                          armed = false
                          row.dismissUnlessChanged(chipAtPress)
                        }
                      }

                      Column {
                        id: rowLabels
                        anchors.left: parent.left
                        anchors.leftMargin: Style.space(12)
                        anchors.right: timeBlock.left
                        anchors.rightMargin: Style.space(10)
                        anchors.top: parent.top
                        anchors.topMargin: row.pad - root.capGap
                        spacing: Style.space(2)

                        // City name with its temperature alongside it, and the value
                        // of its currency pushed over to sit against the time. A
                        // RowLayout rather than a Row so the name is the part that
                        // gives way when the line is tight - the facts are short and
                        // fixed, the name is not.
                        RowLayout {
                          width: parent.width
                          spacing: Style.space(7)

                          // Sizing the name is fiddlier than it looks. QtQuick
                          // Layouts never resize an item with fillWidth false, so
                          // without it a long name overruns the row and collides with
                          // the time instead of eliding. But fillWidth alone would let
                          // the name grow and shove the temperature to the right, so it
                          // needs a cap at its natural width.
                          //
                          // The cap cannot come from the Text's own implicitWidth -
                          // that is circular once elide is on, since eliding shrinks
                          // implicitWidth, which tightens the cap, which elides more.
                          // TextMetrics measures the unelided text outside the layout.
                          // Ceil plus a pixel of slack: matching the advance width
                          // exactly left some names a sub-pixel short and elided them
                          // with the row half empty.
                          TextMetrics {
                            id: nameMetrics
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.subtitle
                            font.weight: Font.DemiBold
                            text: row.rowData.label
                          }

                          Text {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Math.ceil(nameMetrics.advanceWidth) + 2
                            Layout.minimumWidth: 0
                            Layout.alignment: Qt.AlignBaseline
                            text: row.rowData.label
                            // A label is whatever was typed or sent over
                            // IPC; drawn as text, never parsed as markup.
                            textFormat: Text.PlainText
                            color: root.skyColorFor(row.modelData)
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.subtitle
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                          }

                          // Click to swap every row between C and F. The same
                          // gesture as the offset below it: one setting for the
                          // whole list, changed where you are already looking
                          // rather than in a settings pane. The reading is the
                          // control - there is nowhere else a unit could
                          // sensibly live.
                          Text {
                            Layout.alignment: Qt.AlignBaseline
                            textFormat: Text.PlainText
                            text: Model.tempLabel(root.facts[Model.factsKey(row.rowData)], root.units)
                            visible: text !== ""
                            color: tempHover.hovered ? root.foreground : root.dim
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.caption

                            HoverHandler {
                              id: tempHover
                              cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler { onTapped: { root.toggleUnits(); row.dismissChips() } }
                          }

                          // What it is doing there, in one glyph. Sits with the
                          // temperature rather than anywhere else on the row,
                          // because the two are the same fact about outside.
                          Text {
                            Layout.alignment: Qt.AlignBaseline
                            textFormat: Text.PlainText
                            text: root.weatherGlyph(row.rowData)
                            visible: text !== ""
                            color: root.dim
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.bodySmall
                          }

                          Item {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                          }

                          Text {
                            Layout.alignment: Qt.AlignBaseline
                            textFormat: Text.PlainText
                            text: Model.currencyLabel(root.facts[Model.factsKey(row.rowData)])
                            visible: root.showCurrency && text !== ""
                            color: root.fainter
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.caption
                          }
                        }

                        // The date line, and the greeting that stands in its place
                        // while the pointer is on the row.
                        //
                        // Stacked in one slot rather than added beside it: the row
                        // cannot change size as the pointer crosses it, or the list
                        // shifts under the mouse and the row you were reaching for
                        // moves. Both children keep their space whichever is showing.
                        Item {
                          width: parent.width
                          implicitHeight: dateLine.implicitHeight

                          // Nothing to greet before the probe has landed: the hour
                          // would be a guess, and a wrong greeting is worse than none.
                          readonly property bool greeting: row.rowData.ready && rowHover.hovered

                          // Date and day-offset as separate items rather than one
                          // joined string: the separator was padded with monospace
                          // spaces, which set the gap to two character widths on each
                          // side. As a Row it is a pixel value that scales with the font.
                          Row {
                            id: dateLine
                            spacing: Style.space(4)
                            opacity: parent.greeting ? 0 : 1
                            visible: opacity > 0
                            Behavior on opacity { NumberAnimation { duration: 110 } }

                            Text {
                              textFormat: Text.PlainText
                              text: row.rowData.ready ? row.rowData.date : "…"
                              color: row.rowData.ready && row.rowData.dayLabel !== "" ? root.dim : root.fainter
                              font.family: root.fontFamily
                              font.pixelSize: Style.font.caption
                            }

                            Text {
                              text: "·"
                              visible: row.rowData.ready && row.rowData.dayLabel !== ""
                              color: root.fainter
                              font.family: root.fontFamily
                              font.pixelSize: Style.font.caption
                            }

                            Text {
                              textFormat: Text.PlainText
                              text: row.rowData.ready ? row.rowData.dayLabel : ""
                              visible: text !== ""
                              color: root.dim
                              font.family: root.fontFamily
                              font.pixelSize: Style.font.caption
                            }
                          }

                          // What you would hear said there, right now. Brighter than
                          // the date it replaces, because it is the answer to the
                          // question the row was pointed at rather than a label.
                          Row {
                            spacing: Style.space(5)
                            opacity: parent.greeting ? 1 : 0
                            visible: opacity > 0
                            Behavior on opacity { NumberAnimation { duration: 110 } }

                            Text {
                              // The panel's own family carries none of these scripts;
                              // fontconfig substitutes per character, so the line is
                              // set in whatever the system has for Japanese or Thai
                              // and only the Latin greetings stay monospaced.
                              textFormat: Text.PlainText
                              text: row.greeting.text
                              color: root.foreground
                              font.family: root.fontFamily
                              font.pixelSize: Style.font.caption
                            }

                            // A pronunciation, not a translation - the point is to be
                            // able to say it. Absent for the Latin-script languages,
                            // where the greeting is already its own pronunciation.
                            Text {
                              textFormat: Text.PlainText
                              text: row.greeting.roman
                              visible: text !== ""
                              color: root.fainter
                              font.family: root.fontFamily
                              font.pixelSize: Style.font.caption
                            }
                          }
                        }
                      }

                      // Drag the strip to move every clock at once. Declared before
                      // removeSlot so the remove button keeps the corner they share.
                      MouseArea {
                        anchors.left: strip.left
                        anchors.right: strip.right
                        anchors.verticalCenter: strip.verticalCenter
                        height: Style.space(18)
                        cursorShape: Qt.SizeHorCursor
                        preventStealing: true
                        enabled: row.rowData.ready

                        // Shift-clicking the moon itself runs the phase demo
                        // rather than scrubbing. Handled here rather than with
                        // a MouseArea on the marker, because this one sits over
                        // the strip and would swallow it anyway.
                        property bool showing: false

                        function onMoon(mouse) {
                          if (row.litNow) return false              // it is the sun
                          var dx = Math.abs(mouse.x - (nowMarker.x + nowMarker.width / 2))
                          return dx <= nowMarker.width
                        }

                        // A plain click on the marker used to name the moon's
                        // phase. It came out again the day after it went in: the
                        // marker is also the scrub handle, so aiming at a ten-pixel
                        // dot to read a label meant nudging the whole list two
                        // minutes off the hour on every miss. The label was worth
                        // less than the accident cost, and the scrub cursor over the
                        // marker is a promise about what a press there does.
                        //
                        // Shift-click still runs the phase animation, which is a
                        // deliberate gesture rather than one you land on by aiming
                        // badly. Solar.moonPhaseName stays too, tested and unused -
                        // the naming was never the part that was wrong.
                        property real pressX: 0
                        property bool moved: false
                        property int chipAtPress: -1

                        // No guard here against the arrows drawn on top of this
                        // area, though it looked as if there had to be one. A
                        // TapHandler takes only a passive grab, which reads like the
                        // MouseArea underneath must see the press too and start
                        // scrubbing the clock to wherever the arrow points.
                        //
                        // It does not. Measured with synthetic mouse events - see
                        // tests/qml/tst_arrows.qml - a click on the item in front
                        // reaches its TapHandler and this MouseArea records no press
                        // at all. A guard would have been dead code defending
                        // against a bug that is not there.
                        onPressed: function(mouse) {
                          showing = (mouse.modifiers & Qt.ShiftModifier) !== 0
                                    && onMoon(mouse)
                          pressX = mouse.x
                          moved = false
                          chipAtPress = sunArrows.shown
                          if (showing) root.startMoonShow()
                          else root.beginScrub(row.rowData, mouse.x / width)
                        }
                        onPositionChanged: function(mouse) {
                          if (Math.abs(mouse.x - pressX) > Style.space(2)) moved = true
                          if (!showing) root.scrubTo(row.rowData, mouse.x / width)
                        }
                        onReleased: {
                          if (!showing) root.endScrub()
                          row.dismissUnlessChanged(chipAtPress)
                          showing = false
                        }
                        onCanceled: {
                          if (!showing) root.endScrub()
                          row.dismissUnlessChanged(chipAtPress)
                          showing = false
                        }
                      }

                      // ---- Sunrise and sunset, as a pair of arrows flanking the
                      // lit band: one pointing up just before the day starts, one
                      // pointing down just after it ends. The band already says how
                      // long the day is; the arrows say which end is which, which is
                      // the one thing a bare band cannot.
                      //
                      // Declared after the scrub MouseArea on purpose. That one
                      // covers the whole strip to drag time, and an earlier sibling
                      // would never see a press - the same later-sibling rule the
                      // remove button and the briefcase rely on.
                      //
                      // Outside the band rather than on its edge. A mark sitting on
                      // the boundary reads as part of the band and gets lost in it,
                      // and the arrow's job is to point *at* that boundary.
                      Item {
                        id: sunArrows
                        anchors.left: strip.left
                        anchors.right: strip.right
                        anchors.verticalCenter: strip.verticalCenter
                        height: Style.space(16)

                        // Above everything else on the row. Declaration order puts
                        // this before the time block, so the zone line was painting
                        // straight through the chip - it looked like a transparency
                        // bug and was a stacking one, which is the same picture from
                        // the reader's side. Later siblings still win the *tap*;
                        // only the paint order moves.
                        z: 1

                        // The arrows' geometry, named here because three things
                        // need to agree on it: the arrow places itself with it, the
                        // marker hides it with it, and the scrub area underneath
                        // uses it to tell a press on an arrow from a press on the
                        // bar. See Model.arrowBox and Model.arrowCovered.
                        readonly property real boxWidth: Style.space(14)
                        readonly property real tuck: Style.space(3)
                        readonly property real coverSlack: Style.space(4)

                        // Which chip is showing, if any: 0 for sunrise, 1 for
                        // sunset, -1 for none. One at a time - two chips on a row is
                        // the table this was meant to avoid - and they close when the
                        // pointer leaves the row, so a click never leaves anything
                        // behind to tidy up.
                        property int shown: Model.NO_CHIP
                        Connections {
                          target: rowHover
                          function onHoveredChanged() {
                            if (!rowHover.hovered) sunArrows.shown = Model.NO_CHIP
                          }
                        }

                        Repeater {
                          model: row.sunMarks

                          Item {
                            id: arrow
                            required property var modelData
                            required property int index
                            readonly property bool rising: modelData.rising

                            // A target you can hit, around a glyph you can barely
                            // see. The arrow is caption-sized because it sits beside
                            // a three-pixel bar; the box around it is finger-sized
                            // because the arrow is a button.
                            width: sunArrows.boxWidth
                            height: parent.height
                            // Tucked in towards the band. The box is finger-sized
                            // and the glyph sits in the middle of it, so placing the
                            // box flush against the crossing left the arrow itself
                            // half a box away - pointing at the boundary from across
                            // a gap. The nudge closes most of that without letting
                            // the glyph touch the band, which is the thing it must
                            // not do: a mark on the edge reads as part of the band.
                            x: Model.arrowBox(modelData.x, parent.width, width,
                                              sunArrows.tuck, arrow.rising)

                            // The marker wins the space it stands on. An arrow
                            // showing through the sun read as a printing fault
                            // rather than as two things at the same place, and the
                            // arrow is the one that can be spared: it marks a
                            // boundary that is not going anywhere, while the marker
                            // is the only thing on the bar that says when now is.
                            //
                            // nowMarker.x rather than the row's progress, so this
                            // follows the marker's own eased motion and the arrow
                            // comes back exactly as it clears - reading progress
                            // would uncover the arrow while the sun was still
                            // sliding over it. Passed in as an argument so the
                            // binding registers the dependency on a value that
                            // animates.
                            readonly property bool covered: {
                              // Read first, so the binding registers a dependency on
                              // a value that animates.
                              var markerX = nowMarker.x
                              if (!row.sunReady) return false
                              return Model.arrowCovered(arrow.x, arrow.width,
                                                        markerX + nowMarker.width / 2,
                                                        nowMarker.width,
                                                        sunArrows.coverSlack)
                            }

                            // Only while the pointer is on the row. Five rows each
                            // carrying two arrows all the time is a lot of furniture
                            // for something looked up rarely; at rest the bar should
                            // be the shape of the day and nothing else.
                            //
                            // Gone rather than faded: invisible is also untappable,
                            // so a click on the sun scrubs time the way it does
                            // everywhere else on the bar instead of popping a time
                            // from an arrow nobody can see.
                            opacity: rowHover.hovered && !arrow.covered ? 1 : 0
                            visible: opacity > 0
                            Behavior on opacity { NumberAnimation { duration: 160 } }

                            // Sunrise sits a little high, sunset a little low.
                            //
                            // The two glyphs are the same height and the same shape
                            // reversed, which is the pair the eye is worst at telling
                            // apart at this size - it has to stop and read the
                            // arrowhead. Two pixels of offset gives a second, coarser
                            // cue that needs no reading: the one above the line is
                            // the one going up. The asymmetry is the information.
                            transform: Translate {
                              y: arrow.rising ? -Style.space(2) : Style.space(2)
                            }

                            // If the marker slides over an arrow whose time is open,
                            // the time goes with it. A chip pointing at nothing is
                            // worse than no chip.
                            onCoveredChanged: {
                              if (arrow.covered && sunArrows.shown === arrow.index)
                                sunArrows.shown = Model.NO_CHIP
                            }

                            Text {
                              anchors.centerIn: parent
                              textFormat: Text.PlainText
                              text: arrow.rising ? "\u2191" : "\u2193"
                              color: arrowHover.hovered || sunArrows.shown === arrow.index
                                     ? root.foreground : root.fainter
                              font.family: root.fontFamily
                              font.pixelSize: Style.font.caption
                            }

                            HoverHandler {
                              id: arrowHover
                              cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler {
                              // What was showing when this press began. Read here
                              // and not in onTapped, so a dismissal that has already
                              // run underneath cannot make an open chip look shut.
                              property int atPress: -1
                              onPressedChanged: if (pressed) atPress = sunArrows.shown
                              onTapped: sunArrows.shown =
                                Model.chipAfterTap(atPress, arrow.index)
                            }
                          }
                        }

                        // The time itself, popped above the arrow that asked for it.
                        //
                        // Above and not below, because below is where the pointer
                        // is: the hand cursor that has just clicked the arrow sits
                        // squarely on top of the answer. The one place on a row
                        // guaranteed to be clear is the side the pointer came from.
                        //
                        // In its own dark box rather than as bare text. It floats
                        // over the date line, and text on text is unreadable
                        // whatever the two colours are; the box gives it a ground of
                        // its own, and reads as an overlay rather than as one more
                        // field on an already busy row.
                        //
                        // The two colours are literal, not theme roles. This is a
                        // tooltip and tooltips are inverted everywhere - a dark chip
                        // with light text is the same shape in a light theme as in a
                        // dark one, while the theme's own foreground would be dark
                        // text on a dark chip half the time.
                        Repeater {
                          model: row.sunMarks

                          Chip {
                            required property var modelData
                            required property int index
                            // Named, not just numbered. A bare "6:16 AM" over a row
                            // that already has a clock on it has to be worked out
                            // from which arrow was clicked; the word costs one
                            // chip's width and removes the question.
                            label: modelData.name + " "
                                   + Model.formatMinuteOfDay(modelData.minutes, root.hour24)
                            fontFamily: root.fontFamily
                            shown: sunArrows.shown === index
                            centreX: parent.width * modelData.x
                            // Clear of the bar, in the space the strip already keeps
                            // above it, overlapping the line above when it needs the
                            // room.
                            y: parent.height / 2 - Style.space(4) - height
                          }
                        }
                      }

                      // Reserved whether or not the button is showing, so hovering a
                      // row never nudges the time.
                      //
                      // It has been three places. Centred across both label lines it
                      // floated between them, level with nothing. Level with the name
                      // line it read as part of the name. In the corner it reads as
                      // belonging to the row as a whole, which is what it removes.
                      Item {
                        id: removeSlot
                        // The corner itself, not a box floating near it. The
                        // slot is anchored flush into the row's top-right and
                        // the glyph is inset within it, so the target covers
                        // the corner - the easiest place on a row to hit -
                        // while the mark sits tucked in close to it.
                        anchors.right: parent.right
                        anchors.top: parent.top
                        width: Style.space(24)
                        height: Style.space(24)

                        Text {
                          id: removeGlyph
                          // Placed from the corner rather than centred in the
                          // slot, so how close it reads does not depend on how
                          // big the target happens to be.
                          anchors.right: parent.right
                          anchors.top: parent.top
                          anchors.rightMargin: Style.space(5)
                          anchors.topMargin: Style.space(3)
                          text: "\u00d7"
                          color: removeHover.hovered ? root.foreground : root.fainter
                          font.family: root.fontFamily
                          font.pixelSize: Style.font.bodySmall
                          opacity: row.removable && (rowHover.hovered || removeHover.hovered) ? 1 : 0
                          visible: opacity > 0
                          Behavior on opacity { NumberAnimation { duration: 120 } }
                        }

                        // The pointer, not the reorder grab's open hand: the whole
                        // row body is a drag handle, so without this the button
                        // that deletes a city looks like one more piece of it.
                        // Matches the briefcase beside it.
                        HoverHandler {
                          id: removeHover
                          enabled: row.removable
                          cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                          enabled: row.removable
                          onTapped: root.removeCityAt(row.index)
                        }
                      }

                      // Briefcase: marks a city as one of the working group the
                      // overlap band is computed from. Faint when off so it stays out
                      // of the way, accent when on.
                      Item {
                        id: workSlot
                        visible: root.showOverlap
                        width: root.showOverlap ? Style.space(20) : 0
                        anchors.right: removeSlot.left
                        anchors.top: rowLabels.top
                        anchors.bottom: rowLabels.bottom

                        Text {
                          anchors.centerIn: parent
                          text: ""
                          color: row.modelData.work ? Color.accent
                               : (workHover.hovered ? root.dim
                                  : Qt.rgba(root.foreground.r, root.foreground.g,
                                            root.foreground.b, 0.22))
                          font.family: root.fontFamily
                          font.pixelSize: Style.font.bodySmall
                        }

                        HoverHandler { id: workHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: { root.toggleWork(row.index); row.dismissChips() } }
                      }

                      Column {
                        id: timeBlock
                        // Flush with the row's own edge rather than tucked in
                        // behind the remove button's corner. The corner is a
                        // hit target that is only ever drawn on hover, and
                        // reserving column width for it all the time set every
                        // city in from the right-hand edge - which was invisible
                        // until the Earth row arrived without a remove button
                        // and stood a clear 16px further out than the rest.
                        // Nothing overlaps: the cross sits above the meridiem,
                        // not beside it.
                        //
                        // The briefcase is the exception. It is a real item in
                        // the line when the shelved overlap band is switched on,
                        // so with that on the old inset stands.
                        anchors.right: parent.right
                        anchors.rightMargin: root.showOverlap ? Style.space(48)
                                                              : Style.space(12)
                        anchors.verticalCenter: rowLabels.verticalCenter
                        spacing: Style.space(1)

                        // Click the time to swap the whole list between 12-
                        // and 24-hour. Every clock here is read against the
                        // others, so one row on a different notation would be
                        // the one thing on screen that could not be compared -
                        // the same reason the offsets move together.
                        //
                        // The hour is already the brightest thing in the row,
                        // so hover cannot brighten it further; the meridiem
                        // beside it lifts instead, which is also the part that
                        // is about to disappear.
                        Row {
                          anchors.right: parent.right
                          spacing: Style.space(3)

                          Text {
                            id: bigTime
                            textFormat: Text.PlainText
                            text: row.rowData.ready ? row.rowData.time : "--:--"
                            color: root.foreground
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.heading
                            font.weight: Font.DemiBold
                          }

                          Text {
                            anchors.baseline: bigTime.baseline
                            textFormat: Text.PlainText
                            text: row.rowData.meridiem || ""
                            visible: text !== ""
                            color: timeHover.hovered ? root.foreground : root.dim
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.caption
                          }

                          HoverHandler {
                            id: timeHover
                            cursorShape: Qt.PointingHandCursor
                          }
                          TapHandler { onTapped: { root.toggleHour24(); row.dismissChips() } }
                        }

                        // Zone abbreviation and offset as two items in a Row, so the
                        // gap between them is a pixel value rather than the width of
                        // however many monospace spaces were in a joined string.
                        // Tap to swap every row between "how far from me" and
                        // "where it actually is". Both are the same fact and
                        // neither is the useful one twice running, so the line
                        // holds one and hands over the other on a click rather
                        // than printing both and doubling the width.
                        //
                        // Declared after the drag handle, which covers the body
                        // of the row: later siblings win the tap, the same way
                        // the remove button and the briefcase do.
                        Row {
                          id: offsetLine
                          anchors.right: parent.right
                          spacing: Style.space(5)
                          visible: row.rowData.ready

                          Text {
                            textFormat: Text.PlainText
                            text: row.rowData.ready ? row.rowData.abbr : ""
                            color: offsetHover.hovered ? root.dim : root.fainter
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.caption
                          }

                          Text {
                            textFormat: Text.PlainText
                            text: root.offsetTextFor(row.rowData)
                            visible: text !== ""
                            color: offsetHover.hovered ? root.foreground : root.fainter
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.caption
                          }

                          HoverHandler {
                            id: offsetHover
                            cursorShape: Qt.PointingHandCursor
                          }
                          TapHandler { onTapped: { root.toggleOffsetMode(); row.dismissChips() } }
                        }
                      }
                    }
                  }
                }

                // ---- The Earth, last in the list and not one of the cities.
                // Outside the Repeater rather than appended to the model: that
                // is what makes it unremovable and permanently last without a
                // special case in the drag, the remove button or the settings.
                EarthRow {
                  id: earthRow
                  visible: root.showEarth && root.zoom < 1
                  width: parent.width
                  fontFamily: root.fontFamily
                  foreground: root.foreground
                  dim: root.dim
                  fainter: root.fainter
                  hour24: root.hour24
                  capGap: root.capGap
                  moonPhase: root.moonPhase
                  // A city at a minute to midnight is the darkest row on the
                  // list, and this row is at a minute to midnight. It earns its
                  // shade by the same rule as everyone else.
                  fill: root.solid(0.035)
                  fillHover: root.solid(0.085)

                  // Shoved aside after the cities and before the adder.
                  readonly property int knockSlot: root.zones.length
                  // Qualified by id: a Translate is a child object with its own
                  // scope, so a bare `knockSlot` resolves to nothing there.
                  transform: Translate {
                    x: root.knockX(earthRow.knockSlot)
                    y: root.knockY(earthRow.knockSlot)
                  }
                }

                // ---- Add a city. Rendered inline rather than in a dropdown
                // popup: this panel hangs off a vertical bar low on the screen, and
                // the shared dropdown only ever opens downward, so its list ran off
                // the bottom edge. Inline, the list grows the panel instead, and
                // KeyboardPanel already keeps the panel itself on screen.
                Column {
                  id: adderColumn
                  visible: root.zoom < 1
                  width: parent.width
                  spacing: Style.space(6)

                  // Shoved aside last, after every row above it - including
                  // the Earth, which sits between it and the cities.
                  readonly property int knockSlot: root.zones.length + (root.showEarth ? 1 : 0)
                  transform: Translate {
                    x: root.knockX(adderColumn.knockSlot)
                    y: root.knockY(adderColumn.knockSlot)
                  }
                  opacity: root.knockFade(adderColumn.knockSlot)

                  Rectangle {
                    width: parent.width
                    visible: !root.adding
                    implicitHeight: Style.spacing.controlHeight
                    radius: Style.cornerRadius
                    color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b,
                                   addHover.hovered ? 0.10 : 0.05)

                    Text {
                      anchors.centerIn: parent
                      text: "+  Add a city"
                      color: addHover.hovered ? root.foreground : root.dim
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.bodySmall
                    }

                    HoverHandler { id: addHover }
                    TapHandler { onTapped: root.startAdding() }
                  }

                  TextField {
                    id: searchField
                    visible: root.adding
                    width: parent.width
                    placeholderText: "Search cities\u2026"
                    foreground: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                    onTextChanged: root.addQuery = text
                    Keys.onEscapePressed: root.stopAdding()
                    Keys.onReturnPressed: root.commitSelectedMatch()
                    Keys.onEnterPressed: root.commitSelectedMatch()
                    // A single-line field does not use the vertical arrows, so
                    // they are free to drive the list underneath it - which is
                    // where the eye is anyway once the typing has started.
                    Keys.onUpPressed: root.moveAddSelection(-1)
                    Keys.onDownPressed: root.moveAddSelection(1)
                  }

                  Column {
                    width: parent.width
                    visible: root.adding
                    spacing: Style.space(2)

                    Repeater {
                      model: root.addMatches

                      Rectangle {
                        id: match
                        required property var modelData
                        required property int index

                        // Where the keyboard is. Drawn distinctly from hover
                        // rather than sharing one highlight with it: the mouse
                        // resting over the list while someone types must not
                        // drag the selection out from under the arrow keys, and
                        // two marks that mean two different things are clearer
                        // than one that changes hands.
                        readonly property bool selected: root.addIndex === match.index

                        width: parent.width
                        implicitHeight: Style.spacing.popupRowHeight
                        radius: Style.cornerRadius
                        color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b,
                                       match.selected ? 0.20 : (matchHover.hovered ? 0.10 : 0.0))

                        Text {
                          anchors.left: parent.left
                          anchors.leftMargin: Style.space(10)
                          anchors.right: matchZone.left
                          anchors.rightMargin: Style.space(8)
                          anchors.verticalCenter: parent.verticalCenter
                          textFormat: Text.PlainText
                          text: match.modelData.label
                          color: root.foreground
                          font.family: root.fontFamily
                          font.pixelSize: Style.font.bodySmall
                          elide: Text.ElideRight
                        }

                        // The zone and where it is, together: two cities in one
                        // zone are told apart by name, and two zones with the
                        // same name by their offset. A Row so the gap is a
                        // pixel value, and the offset arrives a moment after
                        // the list does - it costs a process to find out.
                        Row {
                          id: matchZone
                          anchors.right: parent.right
                          anchors.rightMargin: Style.space(10)
                          anchors.verticalCenter: parent.verticalCenter
                          spacing: Style.space(6)

                          Text {
                            textFormat: Text.PlainText
                            text: match.modelData.value
                            color: root.fainter
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.caption
                          }

                          Text {
                            textFormat: Text.PlainText
                            text: root.utcLabelFor(match.modelData.value)
                            visible: text !== ""
                            color: root.dim
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.caption
                          }
                        }

                        HoverHandler { id: matchHover }
                        TapHandler {
                          onTapped: root.commitMatch(match.modelData.value,
                                                     match.modelData.label)
                        }
                      }
                    }

                    Text {
                      visible: root.addMatches.length === 0
                      width: parent.width
                      horizontalAlignment: Text.AlignHCenter
                      topPadding: Style.space(6)
                      textFormat: Text.PlainText
                      text: root.zoneCatalogText === "" ? "Loading zones\u2026" : "No matches"
                      color: root.fainter
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.caption
                    }
                  }

                }
              }
            }

            // ---- Globe mode. Loaded only while it is on screen, so the panel
            // pays nothing for it the rest of the time.
            Loader {
              id: globeLoader
              // Kept alive for the whole flight, and loaded early on hover, so
              // reading two data files never lands in the middle of the
              // animation.
              active: root.globeEnabled
                      && (root.globeMode || root.zoom > 0 || heroHover.hovered)
              visible: root.zoom > 0
              opacity: root.bigGlobeOpacity
              width: parent.width
              height: root.globeStageHeight
              source: "Globe.qml"

              // Where the disc sits inside this item: horizontally centred, and
              // vertically centred in the canvas above the footer and jump bar.
              readonly property real discCX: width / 2
              readonly property real discCY:
                item ? (height - item.footerHeight - item.jumpHeight) / 2 : height / 2
              readonly property real discR: item && item.radius > 0 ? item.radius : 1

              // Scaled about the disc's own centre rather than the item's, so
              // the globe grows from where it is drawn and not from the corner
              // of the box it happens to live in. The translation then carries
              // that centre from the little circle to its resting place.
              readonly property real startScale: root.heroDiscRadius / discR
              readonly property real zoomScale:
                startScale + (1 - startScale) * root.zoom

              transform: [
                Scale {
                  origin.x: globeLoader.discCX
                  origin.y: globeLoader.discCY
                  xScale: globeLoader.zoomScale
                  yScale: globeLoader.zoomScale
                },
                Translate {
                  x: (root.heroCentreX - globeLoader.discCX) * (1 - root.zoom)
                  y: (root.heroCentreY - globeLoader.discCY) * (1 - root.zoom)
                }
              ]

              onLoaded: {
                item.bar = Qt.binding(function() { return root.bar })
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
                  return root.homeKnown
                    ? [root.homeCity, root.localZone, root.homeLat, root.homeLon, 0]
                    : []
                })
                item.skyTint = Qt.binding(function() { return root.skyTint })
                item.offsetMode = Qt.binding(function() { return root.offsetMode })
                item.homeOffsetMinutes = Qt.binding(function() { return root.localOffsetMinutes })
                item.offsetModeToggleRequested.connect(function() { root.toggleOffsetMode() })
              item.smoothMotion = Qt.binding(function() { return root.smoothMotion })
              // Anything but a settled list or a settled globe is a
              // transition, in either direction.
              item.transitioning = Qt.binding(function() { return !root.zoomIdle })
              item.zoomLevel = Qt.binding(function() { return root.zoom })
                // The footer and the jump bar would be unreadable specks for
                // most of the flight; they arrive once the globe has landed.
                item.chromeOpacity = Qt.binding(function() {
                  return Math.max(0, Math.min(1, (root.zoom - 0.74) / 0.26))
                })
                item.jumpOptions = Qt.binding(function() { return root.allZoneOptions })
                item.jumpRequested.connect(function(label, zone) {
                  root.addSessionCity(label, zone)
                })
                item.exitRequested.connect(function() { root.setGlobeMode(false, false) })
                // The globe's search hands the keyboard back the same way the
                // panel's own does - otherwise the hidden field keeps it and
                // the next Escape goes nowhere.
                item.jumpDismissed.connect(function() {
                  Qt.callLater(function() { keyCatcher.forceActiveFocus() })
                })
                item.citySelected.connect(function(label, zone) {
                  root.focusFromGlobe(label, zone)
                })
                // Covers the case where the globe finishes loading after the
                // mode was already switched on - a cold start, where the two
                // data files land late.
                if (root.globeMode) root.showFocusOnGlobe()
              }
            }
          }
        }
      }
    }
  }
}
