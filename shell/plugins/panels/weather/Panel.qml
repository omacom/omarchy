import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "omarchy.weather"
  ipcTarget: "omarchy.weather"
  manageIpc: false

  property var anchorItem: null
  property bool openedFromHotkey: false

  // The bar tracks the widget mounted in its slot — BarWidget.qml — not this
  // nested panel. Everything the bar identifies a panel by has to be that
  // widget: the popout coordinator (and with it the open-panel dot under the
  // pill) compares against `slot.activeItem`, and switchPanelFrom looks the
  // slot up the same way.
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  function open() {
    openedFromHotkey = false
    setCenterHoverRevealSuppressed(false)
    root.controller.show()
    locationFile.reload()
    root.refresh()
  }

  function openFromHotkey() {
    openedFromHotkey = true
    root.controller.show()
    locationFile.reload()
    root.refresh()
    // Set after showing, not before: showing hands the popout coordinator
    // over, which closes whichever panel was open, and that close clears the
    // shared flag. Deferring means the panel taking over always wins, while
    // a handoff to a panel that does not manage the flag still leaves it
    // cleared rather than stuck on.
    Qt.callLater(function() {
      if (root.opened) setCenterHoverRevealSuppressed(true)
    })
  }

  function close() {
    setCenterHoverRevealSuppressed(false)
    if (root.editingLocation) root.cancelEditingLocation()
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.openFromHotkey()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function setCenterHoverRevealSuppressed(value) {
    if (root.bar && typeof root.bar.setCenterHoverRevealSuppressed === "function")
      root.bar.setCenterHoverRevealSuppressed(value)
    else if (root.bar && "centerHoverRevealSuppressed" in root.bar)
      root.bar.centerHoverRevealSuppressed = value
  }

  // Parsed wttr.in j1 response. Kept on failure so stale data stays visible.
  property var report: null
  property var dailyForecastReport: null
  property string wttrLocation: ""

  // Configured location, read from the weather.json state file (owned by
  // omarchy-weather-location). The query is the wttr.in path segment
  // (coordinates when stored, else the encoded name); empty means IP
  // auto-detect. The watch makes hand edits take effect live.
  property var configuredLocationState: ({ name: "", latitude: null, longitude: null })
  readonly property string configuredLocation: configuredLocationState.name
  readonly property string locationQuery: Model.wttrLocationQuery(configuredLocationState.name, configuredLocationState.latitude, configuredLocationState.longitude)

  // Keep the previous report visible while the new location loads. The
  // editor remains open with a spinner, so stale data is never presented
  // under the newly configured location label.
  onLocationQueryChanged: {
    if (savingLocation) savingLocationQueryStarted = true
    forecastRetries = 0
    dailyForecastRetries = 0
    forecastProc.running = false
    dailyForecastProc.running = false
    Qt.callLater(refresh)
  }

  property FileView locationFile: FileView {
    path: Quickshell.env("HOME") + "/.local/state/omarchy/settings/weather.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.configuredLocationState = Model.parseLocationFile(text())
    onLoadFailed: root.configuredLocationState = Model.parseLocationFile("")
  }

  // The first read can race shell startup (observed sporadically), leaving a
  // stored location unhonored until the next file write. One delayed reload
  // self-corrects; if the first read was fine it's a no-op, since identical
  // state doesn't change locationQuery and so triggers no refetch.
  Timer {
    interval: 1500
    running: true
    onTriggered: locationFile.reload()
  }

  property int forecastRetries: 0
  property int dailyForecastRetries: 0

  // Click-to-edit state for the location label.
  property bool editingLocation: false
  property bool savingLocation: false
  property bool savingLocationQueryStarted: false
  property var locationSuggestions: []
  property int suggestionIndex: 0
  property string geocodePendingQuery: ""
  property string geocodeActiveQuery: ""

  // Shared hero/bar icon state, updated with each successful weather response.
  property string label: ""

  // wttr's current conditions when available; open-meteo's (bundled with the
  // much faster daily forecast fetch) fill the hero while wttr is in flight.
  readonly property bool hasConfiguredCoordinates: !isNaN(parseFloat(String(configuredLocationState.latitude))) && !isNaN(parseFloat(String(configuredLocationState.longitude)))
  readonly property var openMeteoCurrent: Model.openMeteoCurrentCondition(dailyForecastReport)
  readonly property var current: (hasConfiguredCoordinates && openMeteoCurrent) ? openMeteoCurrent : ((report && report.current_condition && report.current_condition[0]) ? report.current_condition[0] : openMeteoCurrent)
  readonly property var areaInfo: report && report.nearest_area && report.nearest_area[0] ? report.nearest_area[0] : null
  readonly property var forecastDays: buildForecastDays()
  readonly property string reportCountry: areaInfo && areaInfo.country && areaInfo.country[0] ? areaInfo.country[0].value : ""

  readonly property bool useImperial: Model.shouldUseImperial(setting("unit", ""), Qt.locale().name, reportCountry)

  // Auto-refresh interval in minutes; clamped to a sane minimum.
  readonly property int refreshMinutes: Math.max(1, parseInt(setting("refreshMinutes", 15), 10) || 15)

  readonly property string reportLocation:  configuredLocation || wttrLocation || (areaInfo && areaInfo.areaName && areaInfo.areaName[0] ? areaInfo.areaName[0].value : "")
  readonly property string reportTempNum:   current ? String(useImperial ? current.temp_F : current.temp_C) : ""
  readonly property string tempUnit:        "°" + (useImperial ? "F" : "C")
  readonly property string reportFeels:     current ? formatTemp(useImperial ? current.FeelsLikeF : current.FeelsLikeC) : ""
  readonly property string reportWind:      current ? (useImperial ? (current.windspeedMiles + " mph") : (current.windspeedKmph + " km/h")) : ""
  readonly property string reportHumidity:  current ? (current.humidity + "%") : ""

  // ---- Sky scene drawn behind the panel content (see the skyFx item below).
  //      It follows the Open-Meteo weather code and day flag when they are
  //      present, else the bar glyph. The "fx" widget setting turns it off.
  readonly property bool fxEnabled: setting("fx", true) !== false
  readonly property var fxResolved: Model.resolveSkyScene(openMeteoCurrent || current, label)
  readonly property bool fxNight: fxResolved.night
  readonly property int fxLevel: fxResolved.level
  readonly property bool fxHail: fxResolved.hail
  readonly property bool fxWindy: fxResolved.windy
  readonly property string fxMode: fxEnabled ? Model.skyMode(fxResolved.scene, fxNight) : "off"
  onOpenedChanged: if (opened) skyFx.replay()

  function refresh() {
    // Each full refresh cycle gets a fresh retry budget, so an earlier
    // exhausted round (e.g. waking with the network still down) doesn't
    // starve retries for the rest of the session.
    forecastRetries = 0
    dailyForecastRetries = 0
    if (!forecastProc.running) forecastProc.running = true
    if (root.locationQuery === "" && !locationProc.running) locationProc.running = true
    // With stored coordinates this fetches open-meteo right away — no need
    // to wait for the slow wttr response. Without them it's a no-op until
    // wttr reports the detected area.
    refreshDailyForecast(null)
  }

  function refreshDailyForecast(sourceReport) {
    if (dailyForecastProc.running) return

    var lat = parseFloat(String(root.configuredLocationState.latitude))
    var lon = parseFloat(String(root.configuredLocationState.longitude))
    if (isNaN(lat) || isNaN(lon)) {
      var area = sourceReport && sourceReport.nearest_area && sourceReport.nearest_area[0] ? sourceReport.nearest_area[0] : root.areaInfo
      if (!area) return
      lat = parseFloat(String(area.latitude || ""))
      lon = parseFloat(String(area.longitude || ""))
    }
    if (isNaN(lat) || isNaN(lon)) return

    var url = "https://api.open-meteo.com/v1/forecast"
      + "?latitude=" + encodeURIComponent(String(lat))
      + "&longitude=" + encodeURIComponent(String(lon))
      + "&daily=weather_code,temperature_2m_max,temperature_2m_min"
      + "&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day"
      + "&forecast_days=4"
      + "&timezone=auto"
    dailyForecastProc.command = ["curl", "-fsS", "--max-time", "5", url]
    dailyForecastProc.running = true
  }

  // ---- Location editing. Clicking the location label swaps it for a search
  //      field; picking a geocoded suggestion persists name + coordinates to
  //      the module's shell.json entry. An empty commit returns to auto.
  function startEditingLocation() {
    editingLocation = true
    savingLocation = false
    savingLocationQueryStarted = false
    locationSuggestions = []
    suggestionIndex = 0
    Qt.callLater(function() {
      locationField.text = root.configuredLocation
      locationField.selectAll()
      locationField.forceActiveFocus()
    })
  }

  function cancelEditingLocation() {
    editingLocation = false
    savingLocation = false
    savingLocationQueryStarted = false
    locationSuggestions = []
    geocodeDebounce.stop()
    Qt.callLater(function() { if (keyCatcher) keyCatcher.forceActiveFocus() })
  }

  function commitLocation() {
    var location = Model.locationCommit(locationField.text, locationSuggestions, suggestionIndex)
    if (location.name === "") {
      clearLocation()
      return
    }
    savingLocation = true
    savingLocationQueryStarted = false
    configuredLocationState = {
      name: location.name,
      latitude: location.latitude,
      longitude: location.longitude
    }
    persistLocation(location.name, location.latitude, location.longitude)
  }

  function clearLocation() {
    persistLocation("", null, null)
    wttrLocation = ""
    cancelEditingLocation()
  }

  function pickSuggestion(suggestion) {
    if (!suggestion) return
    savingLocation = true
    savingLocationQueryStarted = false
    configuredLocationState = {
      name: suggestion.name,
      latitude: suggestion.latitude,
      longitude: suggestion.longitude
    }
    persistLocation(suggestion.name, suggestion.latitude, suggestion.longitude)
  }

  function finishSavingLocation() {
    if (savingLocation && savingLocationQueryStarted) cancelEditingLocation()
  }

  function persistLocation(name, latitude, longitude) {
    if (name && latitude !== null && longitude !== null)
      locationSaveProc.command = ["omarchy-weather-location", "--set", name, latitude + "," + longitude]
    else if (name)
      locationSaveProc.command = ["omarchy-weather-location", "--set", name]
    else
      locationSaveProc.command = ["omarchy-weather-location", "--clear"]
    locationSaveProc.running = true
  }

  // Debounced geocoding. Only one curl runs at a time; if the query moved on
  // while a fetch was in flight, the latest query is fetched right after.
  function requestGeocode() {
    var query = locationField.text.trim()
    if (query.length < 2) {
      locationSuggestions = []
      return
    }
    geocodePendingQuery = query
    if (!geocodeProc.running) startGeocode()
  }

  function startGeocode() {
    geocodeActiveQuery = geocodePendingQuery
    geocodeProc.command = ["curl", "-fsS", "--max-time", "5",
      "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(geocodeActiveQuery) + "&count=5&language=en&format=json"]
    geocodeProc.running = true
  }

  function buildForecastDays() {
    return Model.buildForecastDays(report, dailyForecastReport, Qt.formatDate(new Date(), "yyyy-MM-dd"))
  }

  function openMeteoForecastDays() {
    return Model.openMeteoForecastDays(dailyForecastReport, Qt.formatDate(new Date(), "yyyy-MM-dd"))
  }

  function wttrNextForecastDays() {
    return Model.wttrNextForecastDays(report, Qt.formatDate(new Date(), "yyyy-MM-dd"))
  }

  function isFutureForecastDate(dateString) {
    return Model.isFutureForecastDate(dateString, Qt.formatDate(new Date(), "yyyy-MM-dd"))
  }

  function roundedTemp(value) {
    return Model.roundedTemp(value)
  }

  function celsiusToFahrenheit(value) {
    return Model.celsiusToFahrenheit(value)
  }

  function formatTemp(value) {
    return Model.formatTemp(value, useImperial)
  }

  function dayName(dateString) {
    return Model.dayName(dateString, function(date) { return Qt.formatDate(date, "dddd") })
  }

  // Bare degree value (no unit letter), used in the forecast row.
  function bareTempForDay(day, kind) {
    return Model.bareTempForDay(day, kind, useImperial)
  }

  // Representative icon for a forecast day: the hourly entry nearest noon.
  function dayIcon(day) {
    return Model.dayIcon(day)
  }

  function iconForOpenMeteoCode(code) {
    return Model.iconForOpenMeteoCode(code)
  }

  // Mirrors omarchy-weather-icon's wttr.in code → nerd-font glyph mapping.
  function iconForCode(code, night) {
    return Model.iconForCode(code, night)
  }

  Process {
    id: forecastProc
    command: ["curl", "-fsS", "--max-time", "10", "https://wttr.in/" + root.locationQuery + "?format=j1"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var raw = String(text || "").trim()
        if (!raw) {
          root.scheduleForecastRetry()
          return
        }
        try {
          var parsed = JSON.parse(raw)
          root.report = parsed
          if (!root.hasConfiguredCoordinates)
            root.label = Model.provisionalCurrentIcon(parsed.current_condition && parsed.current_condition[0], root.label)
          root.forecastRetries = 0
          if (Model.weatherResponseCompletesSave(root.hasConfiguredCoordinates, "wttr"))
            root.finishSavingLocation()
          // Stored coordinates already drove the fast open-meteo fetch from
          // refresh(); only auto-detect needs the area wttr reported.
          if (isNaN(parseFloat(String(root.configuredLocationState.latitude))))
            root.refreshDailyForecast(parsed)
        } catch (e) {
          // Keep last-good report visible, but try again shortly.
          root.scheduleForecastRetry()
        }
      }
    }
  }

  // wttr.in can be slow or flaky, especially for a location it hasn't
  // cached yet. Retry a few times before leaving it to the refresh timer.
  function scheduleForecastRetry() {
    if (forecastRetries >= 3) return
    forecastRetries++
    forecastRetryTimer.restart()
  }

  Timer {
    id: forecastRetryTimer
    interval: 2500
    onTriggered: if (!forecastProc.running) forecastProc.running = true
  }

  // With configured coordinates this fetch is the only thing that updates the
  // bar icon, so a dropped response (e.g. waking before the network is back)
  // must retry rather than wait out the refresh timer with a stale icon.
  function scheduleDailyForecastRetry() {
    if (dailyForecastRetries >= 3) return
    dailyForecastRetries++
    dailyForecastRetryTimer.restart()
  }

  Timer {
    id: dailyForecastRetryTimer
    interval: 2500
    onTriggered: root.refreshDailyForecast(null)
  }

  Process {
    id: dailyForecastProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var raw = String(text || "").trim()
        if (!raw) {
          root.scheduleDailyForecastRetry()
          return
        }
        try {
          var parsed = JSON.parse(raw)
          var parsedCurrent = Model.openMeteoCurrentCondition(parsed)
          root.dailyForecastReport = parsed
          root.label = Model.currentIcon(parsedCurrent, root.label)
          root.dailyForecastRetries = 0
          if (Model.weatherResponseCompletesSave(root.hasConfiguredCoordinates, "open-meteo"))
            root.finishSavingLocation()
        } catch (e) {
          // Keep last-good daily forecast visible, but try again shortly.
          root.scheduleDailyForecastRetry()
        }
      }
    }
  }

  Process {
    id: geocodeProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.locationSuggestions = root.editingLocation ? Model.parseGeocodingResults(text) : []
        root.suggestionIndex = 0
        if (root.geocodePendingQuery !== root.geocodeActiveQuery) Qt.callLater(root.startGeocode)
      }
    }
  }

  Timer {
    id: geocodeDebounce
    interval: 300
    onTriggered: root.requestGeocode()
  }

  Process {
    id: locationSaveProc
    onExited: function(exitCode) {
      if (exitCode !== 0 || !root.savingLocation) return

      // FileView handles changed locations. Explicitly refresh here too so
      // saving the already-active location cannot strand the spinner.
      locationFile.reload()
      if (!root.savingLocationQueryStarted) {
        root.savingLocationQueryStarted = true
        root.forecastRetries = 0
        root.dailyForecastRetries = 0
        forecastProc.running = false
        dailyForecastProc.running = false
        Qt.callLater(root.refresh)
      }
    }
  }

  Process {
    id: locationProc
    command: ["curl", "-fsS", "--max-time", "4", "https://wttr.in/?format=%l"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var raw = String(text || "").trim()
        if (!raw) return
        root.wttrLocation = raw.split(",")[0]
      }
    }
  }

  Timer {
    id: refreshTimer
    interval: root.refreshMinutes * 60 * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  IpcHandler {
    target: root.ipcTarget

    function open(): void { root.openFromHotkey() }
    function close(): void { root.close() }
    function show(): void { root.openFromHotkey() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function edit(): void { root.openFromHotkey(); root.startEditingLocation() }
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    centerOnBar: true
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(480))
    contentHeight: panel.fittedContentHeight(weatherColumn.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: root.editingLocation
      onReturnRequested: root.startEditingLocation()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      // ---- Pixel-art sky. Two canvases on a 2px cell grid behind the content:
      //      `stat` holds what only changes on open (glow, sun/moon body, haze),
      //      `dyn` holds motion (rays, bokeh, clouds, drops, flakes, wind, bolts)
      //      and repaints at 30 Hz while the popup is open. All geometry below
      //      is in cells. Palette is theme accent, theme background and ink
      //      (white on dark themes, the theme foreground on light ones).
      Item {
        id: skyFx
        anchors.fill: parent
        anchors.margins: -panel.padding
        clip: true
        visible: root.fxMode !== "off"
        z: 0

        property real t: 0        // 0 → 1 while the panel opens
        property int tick: 0      // 30 Hz clock since the panel opened; drives all motion
        readonly property int cell: 2
        // Overall strength of the effect; the hero text has to stay readable.
        // Dark ink on a pale card needs more coverage for the same contrast.
        readonly property real strength: lightTheme ? 0.7 : 0.45

        // `c` blended over `base` by `k`.
        function blend(base, c, k) { return Qt.tint(base, Qt.rgba(c.r, c.g, c.b, k)) }
        // Everything is drawn in "ink": ink on dark themes, the theme's own
        // foreground on light ones, where ink would vanish into the card.
        readonly property color surfaceBackground: Color.popups.background
        readonly property bool lightTheme: surfaceBackground.hslLightness > 0.5
        readonly property color inkColor: lightTheme ? Color.popups.text : "#ffffff"
        readonly property string sunCore:     blend(Color.accent, inkColor, 0.30).toString()
        readonly property string sunMid:      Color.accent.toString()
        readonly property string sunRim:      blend(Color.accent, surfaceBackground, 0.35).toString()
        readonly property string ink:         inkColor.toString()
        readonly property string inkSoft:     blend(inkColor, surfaceBackground, 0.25).toString()
        readonly property string bgTint:      blend(surfaceBackground, inkColor, 0.55).toString()
        readonly property string cloudDark:   blend(surfaceBackground, Color.accent, 0.25).toString()
        readonly property string cloudShade:  blend(inkSoft, surfaceBackground, 0.45).toString()
        readonly property string cloudDarker: blend(cloudDark, surfaceBackground, 0.45).toString()
        readonly property string paletteKey: [sunCore, sunMid, sunRim, ink, inkSoft, bgTint, cloudDark, cloudShade, cloudDarker].join("|")
        // 4x4 ordered-dither thresholds, flattened.
        readonly property var ditherThresholds: [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5].map(function(b) { return (b + 0.5) / 16 })

        // 64x64 lattice of random values for value noise.
        property var noiseTable: []
        onNoiseTableChanged: layerCache = []
        Component.onCompleted: { var tbl = []; for (var n = 0; n < 4096; n++) tbl.push(Math.random()); noiseTable = tbl }

        function replay() { tick = 0; openAnim.restart() }

        NumberAnimation {
          id: openAnim
          target: skyFx
          property: "t"
          from: 0; to: 1
          duration: 900
          easing.type: Easing.OutCubic
        }
        // The dynamic canvas repaints on every tick and the scrolling layers
        // only move, so only the static canvas needs nudging: when the open
        // animation, the scene or the theme changes.
        onTChanged: stat.requestPaint()
        onPaletteKeyChanged: stat.requestPaint()
        Connections {
          target: root
          function onFxModeChanged() { stat.requestPaint() }
        }

        Timer {
          interval: 33; repeat: true
          running: skyFx.visible && root.opened
          onTriggered: { skyFx.tick++; dyn.requestPaint() }
        }

        // Value noise that repeats every `period` lattice cells horizontally
        // (period <= 16, so the finest octave still fits the 64-wide lattice).
        function hashT(ix, iy) { return noiseTable[((ix & 63) << 6) | (iy & 63)] }
        function vnoise(x, y, period) {
          var ix = Math.floor(x), iy = Math.floor(y), fx = x - ix, fy = y - iy
          fx = fx * fx * (3 - 2 * fx); fy = fy * fy * (3 - 2 * fy)
          var x0 = ((ix % period) + period) % period, x1 = x0 + 1 === period ? 0 : x0 + 1
          var a = hashT(x0, iy), b = hashT(x1, iy), c = hashT(x0, iy + 1), d = hashT(x1, iy + 1)
          return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy
        }
        function fbm(x, y, period) {
          return 0.55 * vnoise(x, y, period) + 0.30 * vnoise(x * 2 + 7.3, y * 2 + 3.1, period * 2) + 0.15 * vnoise(x * 4 + 11.7, y * 4 + 5.9, period * 4)
        }

        // Clouds and fog only drift sideways. Cache their geometry outside
        // Canvas: closing the layer-shell window discards its painted image.
        // Reopening only redraws the cached runs, then slides the strip.
        function layerSpec(kind, speed, nsx, nsy, extra) {
          var spec = { kind: kind, speed: speed, nsx: nsx, nsy: nsy }
          for (var key in extra) spec[key] = extra[key]
          return spec
        }
        // colors = [lit top, body, shaded underside]. With dark ink the "lit"
        // colour is the darkest, so light themes swap the ends to keep tops
        // lighter than undersides.
        function cloudSpec(speed, topOnly, colors, alpha, dens) {
          var lit = lightTheme ? colors[2] : colors[0], shade = lightTheme ? colors[0] : colors[2]
          return layerSpec("cloud", speed, 51, 30, { topOnly: topOnly, lit: lit, body: colors[1], shade: shade, alpha: alpha, dens: dens })
        }
        // Lightning: a short flash at the end of each period, faster when heavier.
        readonly property real flashPeriod: [4.0, 2.6, 1.6][root.fxLevel]
        readonly property bool flashing: root.fxMode === "storm" && (tick / 30) % flashPeriod > flashPeriod - 0.14
        // The storm band repainted in its lit palette, shown in place of the
        // normal band while a flash lasts, so the clouds light up themselves.
        function stormSpec(colors) { return cloudSpec(4.2 * (root.fxWindy ? 2.2 : 1), true, colors, 0.50, 0.05 + root.fxLevel * 0.02) }
        readonly property var flashLayer: root.fxMode === "storm" ? stormSpec([ink, inkSoft, cloudDarker]) : null
        readonly property var layers: {
          var mode = root.fxMode, night = root.fxNight, lvl = root.fxLevel, wind = root.fxWindy ? 2.2 : 1
          var nightAlpha = night ? 0.8 : 1, precipDens = 0.04 + lvl * 0.02
          var bright = night ? [inkSoft, bgTint, cloudDarker] : [ink, inkSoft, cloudShade]
          var dim = night ? [bgTint, cloudDark, cloudDarker] : [inkSoft, bgTint, cloudDarker]
          switch (mode) {
            case "partly":       return [cloudSpec(1.95 * wind, true, bright, 0.30, -0.02)]
            case "partly-night": return [cloudSpec(1.5 * wind, true, bright, 0.28, -0.02)]
            case "clouds":       return [cloudSpec(3.3 * wind, false, bright, 0.38 * nightAlpha, 0.03)]
            case "rain":         return [cloudSpec(2.1 * wind, true, dim, 0.34 * nightAlpha, precipDens)]
            case "storm":        return [stormSpec([inkSoft, cloudDark, cloudDarker])]
            case "snow":         return [cloudSpec(1.35 * wind, true, bright, 0.26 * nightAlpha, precipDens)]
            case "sleet":        return [cloudSpec(2.4 * wind, true, dim, 0.34 * nightAlpha, precipDens)]
            case "fog":          return [layerSpec("fog", 2.4, 66, 24, { seed: 0 }), layerSpec("fog", -1.35, 42, 16.5, { seed: 3.7 })]
          }
          return []
        }

        // At most two recent geometries (the two fog strips). Storm and flash
        // share an entry. Colours, alpha and scrolling speed don't shape runs.
        property var layerCache: []
        function layerRuns(spec, cols, rows, period) {
          var key = JSON.stringify([cols, rows, period, spec.kind, spec.nsx, spec.nsy, spec.topOnly, spec.dens, spec.seed])
          for (var n = 0; n < layerCache.length; n++) {
            if (layerCache[n].key === key) {
              var hit = layerCache.splice(n, 1)[0]
              layerCache.push(hit)
              return hit.runs
            }
          }
          var result = buildLayerRuns(spec, cols, rows, period)
          layerCache.push({ key: key, runs: result })
          if (layerCache.length > 2) layerCache.shift()
          return result
        }

        function buildLayerRuns(spec, cols, rows, period) {
          var result = [], thr = ditherThresholds
          // One row of cells as runs: level(i) returns a key (falsy = empty)
          // kept with the geometry so palettes can change without new noise.
          function runs(j, level) {
            var runKey = null, runStart = 0
            for (var i = 0; i <= cols; i++) {
              var key = i < cols ? level(i) : null
              if (key === runKey) continue
              if (runKey) result.push([runStart, j, i - runStart, runKey])
              runKey = key; runStart = i
            }
          }
          if (spec.kind === "cloud") {
            // Thresholded into a lit top, a body and a shaded underside, with a
            // dithered rim; topOnly fades the band out toward mid-card.
            var up = 5, th = 0.52 - spec.dens
            var H = spec.topOnly ? Math.round(rows * 0.70) : rows, FH = H + up
            var fld = new Array(cols * FH)
            for (var j = 0; j < FH; j++) {
              var env = spec.topOnly ? Math.max(0, Math.min(1, 1.7 - j / (rows * 0.40))) : (1 - 0.2 * j / rows)
              for (var i = 0; i < cols; i++) fld[j * cols + i] = fbm(i / spec.nsx, j / spec.nsy, period) * env
            }
            for (var row = 0; row < H; row++) {
              runs(row, function(i) {
                var v = fld[row * cols + i]
                if (v >= th + 0.05) {
                  var above = row >= up ? fld[(row - up) * cols + i] : v, below = fld[(row + up) * cols + i]
                  return below < v - 0.03 ? "shade" : (above < v - 0.03 ? "lit" : "body")
                }
                return v >= th && (v - th) / 0.05 >= thr[((row & 3) << 2) | (i & 3)] ? "rim" : null
              })
            }
          } else {
            // Fog: density quantised to three alpha levels, thicker near the bottom.
            for (var fj = 0; fj < rows; fj++) {
              var fenv = (0.25 + 0.75 * fj / rows) * 1.6
              runs(fj, function(i) {
                var d = (fbm(i / spec.nsx + spec.seed, fj / spec.nsy + spec.seed, period) - 0.3) * fenv
                return d <= 0.15 ? 0 : (d <= 0.4 ? 1 : (d <= 0.7 ? 2 : 3))
              })
            }
          }
          return result
        }

        function paintLayer(ctx, spec, cols, rows, period, width, height) {
          ctx.clearRect(0, 0, width, height)
          if (!spec || noiseTable.length === 0) return
          var runs = layerRuns(spec, cols, rows, period), c = cell
          var styles = spec.kind === "cloud"
            ? { lit: [spec.lit, spec.alpha], body: [spec.body, spec.alpha], shade: [spec.shade, spec.alpha], rim: [spec.body, spec.alpha * 0.7] }
            : { 1: [inkSoft, 0.07], 2: [inkSoft, 0.14], 3: [inkSoft, 0.07 * 3] }
          for (var n = 0; n < runs.length; n++) {
            var run = runs[n], style = styles[run[3]]
            ctx.fillStyle = style[0]; ctx.globalAlpha = style[1]
            ctx.fillRect(run[0] * c, run[1] * c, run[2] * c, c)
          }
        }

        component ScrollLayer: Canvas {
          id: strip
          property var spec: null
          readonly property int cardCols: Math.ceil(skyFx.width / skyFx.cell)
          // Noise period in lattice cells, and the strip's repeat length in cells.
          readonly property int period: spec ? Math.max(2, Math.min(16, Math.round(2 * cardCols / spec.nsx))) : 1
          readonly property int repeatCols: spec ? period * spec.nsx : 0
          visible: spec !== null
          height: parent.height
          width: (repeatCols + cardCols) * skyFx.cell
          x: spec ? -Math.round((((skyFx.tick / 30 * spec.speed) % repeatCols) + repeatCols) % repeatCols * skyFx.cell) : 0
          opacity: skyFx.strength * skyFx.t
          renderStrategy: Canvas.Cooperative
          onSpecChanged: requestPaint()
          onWidthChanged: requestPaint()
          onHeightChanged: requestPaint()
          Connections {
            target: skyFx
            function onPaletteKeyChanged() { strip.requestPaint() }
            function onNoiseTableChanged() { strip.requestPaint() }
          }
          onPaint: skyFx.paintLayer(getContext("2d"), spec, repeatCols + cardCols, Math.ceil(height / skyFx.cell), period, width, height)
        }

        component SkyCanvas: Canvas {
          property bool dynamic: false
          anchors.fill: parent
          renderStrategy: Canvas.Cooperative
          opacity: skyFx.strength
          onWidthChanged: requestPaint()
          onHeightChanged: requestPaint()
          onPaint: skyFx.paint(getContext("2d"), width, height, dynamic)
        }
        SkyCanvas { id: stat }
        ScrollLayer { spec: skyFx.layers[0] || null; visible: spec !== null && !skyFx.flashing }
        ScrollLayer { spec: skyFx.flashLayer; visible: skyFx.flashing }
        ScrollLayer { spec: skyFx.layers[1] || null }
        SkyCanvas { id: dyn; dynamic: true }

        function paint(ctx, width, height, dynamic) {
          ctx.clearRect(0, 0, width, height)
          var c = cell, t = skyFx.t, mode = root.fxMode
          if (t <= 0) return
          var cols = Math.ceil(width / c), rows = Math.ceil(height / c)
          var time = skyFx.tick / 30          // seconds since the panel opened
          var frame = Math.floor(time * 2.4) % 4
          var lvl = root.fxLevel, windy = root.fxWindy
          var thr = ditherThresholds

          // The one drawing primitive: a w×h block of cells. The canvas clips.
          function rect(i, j, w, h, color, a) {
            ctx.fillStyle = color
            ctx.globalAlpha = a < 0 ? 0 : (a > 1 ? 1 : a)
            ctx.fillRect(i * c, j * c, w * c, h * c)
          }
          function wash(color, a) { rect(0, 0, cols, rows, color, a) }
          function dither(i, j) { return thr[((j & 3) << 2) | (i & 3)] }
          function rnd(n) { var x = Math.sin(n * 12.9898 + 78.233) * 43758.5453; return x - Math.floor(x) }
          // Dithered radial falloff: the pixel-art stand-in for a soft gradient.
          function glow(cx, cy, radius, color, gain, a) {
            var G = Math.round(radius)
            for (var j = Math.max(0, cy - G); j < Math.min(rows, cy + G); j++)
              for (var i = Math.max(0, cx - G); i < Math.min(cols, cx + G); i++) {
                var dx = i - cx, dy = j - cy
                var g = Math.max(0, 1 - Math.sqrt(dx * dx + dy * dy) / G) * gain * t
                if (g > 0.03 && g > dither(i, j)) rect(i, j, 1, 1, color, a)
              }
          }

          // Streaks falling at varied speeds; the last cell is the bright tip.
          function rain(count, color, a, speed, slant) {
            for (var n = 0; n < count; n++) {
              var y = Math.round(((rnd(n) + time * speed * (0.7 + rnd(n + 100) * 0.6)) % 1) * (rows + 5) - 5)
              var x = Math.round(rnd(n + 300) * (cols + 45) - 22 - y * slant)
              rect(x, y, 1, 4, color, a * 0.7)
              rect(x, y + 4, 1, 1, color, a)
            }
          }
          function snow(count, color, a, speed, drift) {
            for (var n = 0; n < count; n++) {
              var y = Math.round(((rnd(n + 500) + time * speed * (0.6 + rnd(n + 700) * 0.8)) % 1) * (rows + 4) - 2)
              var x = Math.round(rnd(n + 900) * cols + Math.sin(time * 0.9 + n) * 4.5 * drift + time * 18 * (drift - 1))
              x = ((x % cols) + cols) % cols
              var size = rnd(n + 1100) > 0.6 ? 2 : 1
              rect(x, y, size, size, color, a)
            }
          }
          function hailfall(count, color, a, speed) {
            for (var n = 0; n < count; n++) {
              var y = Math.round(((rnd(n + 1500) + time * speed * (0.8 + rnd(n + 1300) * 0.5)) % 1) * (rows + 4) - 2)
              rect(Math.round(rnd(n + 1700) * cols - y * 0.05), y, 2, 2, color, a)
            }
          }
          // Horizontal streaks racing left to right, fading in toward the head.
          function wind(count, color, a) {
            var span = cols + 30
            for (var n = 0; n < count; n++) {
              var len = Math.round(7.5 + rnd(n + 2100) * 7.5), half = Math.round(len / 2)
              var x = Math.round(((rnd(n + 2500) * span + time * (45 + rnd(n + 2300) * 45)) % span) - 15)
              var y = Math.round(rnd(n + 2700) * rows + Math.sin(time * 3 + n) * 1.5)
              rect(x, y, half, 1, color, a * 0.55)
              rect(x + half, y, len - half, 1, color, a)
            }
          }
          function bolt(index, x, y) {
            for (var seg = 0; seg < 5; seg++) {
              var dx = (rnd(index * 10 + seg) - 0.5) * 12
              var dy = 4.5 + rnd(index * 10 + seg + 50) * 6
              var steps = Math.ceil(Math.max(Math.abs(dx), dy))
              for (var k = 0; k <= steps; k++) {
                var px = Math.round(x + dx * k / steps), py = Math.round(y + dy * k / steps)
                rect(px, py, 1, 1, ink, 0.95)
                rect(px + 1, py, 1, 1, ink, 0.5)
              }
              x += dx; y += dy
            }
          }

          // The sun or moon sits in the top-right corner; its light path runs
          // to the bottom-left corner.
          var sx = cols - 22, sy = 14
          var ldx = 12 - sx, ldy = rows - 12 - sy, llen = Math.sqrt(ldx * ldx + ldy * ldy)
          var sunR = 15 * (0.6 + 0.4 * t)

          function sunStatic() {
            glow(sx, sy, 99, sunMid, 0.55, 0.30)
            // Light beam: a soft band along the light path, fading with distance.
            var bw = 24
            for (var j = Math.max(0, sy); j < rows; j++) {
              var along = (j - sy) / ldy
              if (along > 1) break
              var cxl = sx + ldx * along
              for (var i = Math.max(0, Math.floor(cxl - bw)); i < Math.min(cols, Math.ceil(cxl + bw)); i++) {
                var d = Math.abs(((i - sx) * ldy - (j - sy) * ldx) / llen)
                var g = Math.max(0, 1 - d / bw) * (1 - along) * 0.45 * t
                if (g > dither(i, j)) rect(i, j, 1, 1, sunCore, 0.16)
              }
            }
            var box = Math.ceil(sunR) + 1
            for (var jj = -box; jj <= box; jj++) for (var ii = -box; ii <= box; ii++) {
              var dd = Math.sqrt(ii * ii + jj * jj)
              if (dd <= sunR) rect(sx + ii, sy + jj, 1, 1, dd <= sunR * 0.5 ? sunCore : (dd <= sunR * 0.82 ? sunMid : sunRim), t)
            }
          }
          function sunDynamic() {
            for (var k = 0; k < 8; k++) {
              var ang = k * Math.PI / 4, len = 9 + ((k + frame) % 3) * 4.5
              for (var s = sunR + 4; s <= sunR + 4 + len; s++)
                rect(Math.round(sx + Math.cos(ang) * s), Math.round(sy + Math.sin(ang) * s), 1, 1, sunMid, 0.75 * t)
            }
            // Bokeh: three soft discs along the light path, breathing slowly.
            var bok = [[0.34, 13.5, ink, 0.22], [0.56, 7.5, sunCore, 0.30], [0.80, 19.5, sunMid, 0.16]]
            for (var n = 0; n < bok.length; n++) {
              var p = bok[n][0] * t
              var fade = Math.max(0, Math.min(1, (t - bok[n][0] * 0.5) / 0.5))
              glow(Math.round(sx + ldx * p), Math.round(sy + ldy * p), bok[n][1] * (1 + 0.12 * Math.sin(time * 0.8 + n * 2.1)), bok[n][2], 1.2, bok[n][3] * fade)
            }
          }
          // Night: an accent-tinted sky fading down from the top, a crescent
          // with a halo, earthshine on its dark side and a few craters.
          function moonStatic() {
            for (var j = 0; j < rows; j++) {
              var sky = Math.max(0, 1 - j / (rows * 0.85)) * 0.5 * t
              for (var i = 0; i < cols; i++) if (sky > dither(i, j)) rect(i, j, 1, 1, cloudDark, 0.35)
            }
            var mr = 13.5 * (0.6 + 0.4 * t), mb = Math.ceil(mr) + 1
            glow(sx, sy, 90, inkSoft, 1.0, 0.34)
            var craters = [[0.35, -0.35, 0.16], [0.55, 0.25, 0.12], [0.15, 0.55, 0.10]]
            for (var mj = -mb; mj <= mb; mj++) for (var mi = -mb; mi <= mb; mi++) {
              var d = Math.sqrt(mi * mi + mj * mj)
              if (d > mr) continue
              var bx = mi + mr * 0.45, by = mj - mr * 0.2          // the bite: an offset disc
              if (Math.sqrt(bx * bx + by * by) <= mr * 0.85) { rect(sx + mi, sy + mj, 1, 1, bgTint, 0.22 * t); continue }
              var crater = false
              for (var k = 0; k < craters.length; k++) {
                var cx = mi - craters[k][0] * mr, cy = mj - craters[k][1] * mr
                if (Math.sqrt(cx * cx + cy * cy) <= craters[k][2] * mr) crater = true
              }
              rect(sx + mi, sy + mj, 1, 1, crater ? inkSoft : (d < mr * 0.8 ? ink : inkSoft), t)
            }
          }
          // Stars twinkling smoothly at their own rates, and a shooting star
          // crossing toward the bottom-left every few seconds.
          function moonDynamic() {
            for (var st = 0; st < 60; st++) {
              var x = Math.round(rnd(st) * cols), y = Math.round(rnd(st + 40) * rows * 0.75)
              if (Math.abs(x - sx) < 22 && Math.abs(y - sy) < 22) continue
              var a = (0.6 + rnd(st + 80) * 0.4) * t * (0.6 + 0.4 * Math.sin(time * (1.2 + rnd(st + 160) * 2) + st * 7))
              var color = st % 5 === 0 ? sunMid : ink
              rect(x, y, 1, 1, color, a)
              if (rnd(st + 120) > 0.65) { rect(x - 1, y, 3, 1, color, a * 0.6); rect(x, y - 1, 1, 3, color, a * 0.6) }
            }
            var shootEvery = 7, shootFor = 0.9, phase = time % shootEvery
            if (time > shootEvery * 0.5 && phase < shootFor) {
              var n = Math.floor(time / shootEvery), p = phase / shootFor
              var x0 = cols * (0.35 + rnd(n + 3000) * 0.45), y0 = rows * (0.05 + rnd(n + 3100) * 0.25)
              var hx = x0 - 70 * p, hy = y0 + 28 * p
              rect(Math.round(hx) - 1, Math.round(hy), 2, 2, ink, t)
              for (var k = 1; k < 22; k++)
                rect(Math.round(hx + k * 2.5), Math.round(hy - k), 1, 1, ink, (1 - k / 22) * t * (1 - p * 0.5))
            }
          }

          var rainN = [40, 75, 120][lvl], rainSp = [0.45, 0.6, 0.85][lvl], rainSl = [0.08, 0.14, 0.24][lvl], rainA = [0.35, 0.45, 0.55][lvl]
          var snowN = [30, 60, 110][lvl], snowSp = [0.12, 0.17, 0.26][lvl], snowDrift = windy ? 2.5 : 1

          if (!dynamic) {
            if (mode === "sun" || mode === "partly") sunStatic()
            else if (mode === "moon" || mode === "partly-night") moonStatic()
            else if (mode === "fog") wash(inkSoft, 0.07 * t)
          } else {
            if (mode === "sun" || mode === "partly") sunDynamic()
            else if (mode === "moon" || mode === "partly-night") moonDynamic()
            else if (mode === "rain") rain(rainN, inkSoft, rainA * t, rainSp, rainSl + (windy ? 0.2 : 0))
            else if (mode === "storm") {
              var inFlash = skyFx.flashing
              if (inFlash) wash(ink, 0.07)
              rain(Math.round(rainN * 1.2), inkSoft, 0.5 * t, Math.max(0.7, rainSp), 0.22 + (windy ? 0.15 : 0))
              if (root.fxHail) hailfall(35, bgTint, 0.7 * t, 0.9)
              var flashIdx = Math.floor(time / skyFx.flashPeriod)
              if (inFlash) bolt(flashIdx, Math.round((0.2 + rnd(flashIdx) * 0.6) * cols), sy)
            }
            else if (mode === "snow") snow(snowN, ink, 0.55 * t, snowSp, snowDrift)
            else if (mode === "sleet") {
              rain(Math.round(rainN * 0.55), inkSoft, 0.4 * t, rainSp * 0.9, rainSl)
              snow(Math.round(snowN * 0.5), ink, 0.5 * t, snowSp * 1.3, snowDrift)
            }
            if (windy) wind(24, inkSoft, 0.28 * t)
          }
        }
      }

      Flickable {
        id: weatherScroll
        anchors.fill: parent
        contentWidth: width
        contentHeight: weatherColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        Column {
          id: weatherColumn
          width: weatherScroll.width
          spacing: Style.space(14)

      // ---- Hero row: big icon + temp on the left; location and stats stacked on the right.
      Item {
        width: parent.width
        height: Math.max(heroLeft.height, heroRight.height)

        Row {
          id: heroLeft
          anchors.left: parent.left
          anchors.leftMargin: Style.space(16)
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(16)

          Text {
            id: heroIcon
            textFormat: Text.PlainText
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 5
            text: root.label || "—"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            // Decorative condition emoji; intentionally larger than the
            // Style.font.* scale's displayLarge (28).
            font.pixelSize: 64
          }

          Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              id: tempBig
              textFormat: Text.PlainText
              text: root.reportTempNum || "—"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              // Hero temperature read-out; deliberately oversized, outside
              // the Style.font.* scale.
              font.pixelSize: 56
              font.bold: true
            }
            Text {
              textFormat: Text.PlainText
              text: root.current ? root.tempUnit : ""
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.display
              anchors.top: tempBig.top
              anchors.topMargin: Style.space(10)
            }
          }
        }

        Column {
          id: heroRight
          width: weatherStats.implicitWidth
          anchors.right: parent.right
          anchors.rightMargin: Style.space(20)
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(12)

          Row {
            visible: !root.editingLocation && root.reportLocation !== ""
            spacing: Style.space(6)

            TapHandler {
              onTapped: root.startEditingLocation()
            }
            HoverHandler {
              cursorShape: Qt.PointingHandCursor
            }

            Text {
              text: ""  // nf-fa-map_marker
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.body
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              textFormat: Text.PlainText
              text: (root.reportLocation || "").toUpperCase()
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.body
              font.letterSpacing: 1
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Row {
            visible: root.editingLocation
            spacing: Style.space(6)

            TextField {
              id: locationField
              width: Style.space(190)
              enabled: !root.savingLocation
              placeholderText: "Search city"
              foreground: root.bar.foreground
              font.family: root.bar.fontFamily

              onTextChanged: if (root.editingLocation && !root.savingLocation) geocodeDebounce.restart()

              Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                  root.cancelEditingLocation()
                  event.accepted = true
                } else if (event.key === Qt.Key_Down) {
                  if (root.suggestionIndex < root.locationSuggestions.length - 1) root.suggestionIndex++
                  event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                  if (root.suggestionIndex > 0) root.suggestionIndex--
                  event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                  root.commitLocation()
                  event.accepted = true
                }
              }
            }

            // Clear back to IP auto-detect. While a committed location is
            // loading, this same compact affordance becomes a spinner.
            Rectangle {
              width: Style.space(18)
              height: Style.space(18)
              anchors.verticalCenter: parent.verticalCenter
              radius: Math.min(4, Style.cornerRadius)
              color: !root.savingLocation && clearLocationArea.containsMouse ? Style.hoverFillFor(root.bar.foreground, Color.accent) : "transparent"

              Text {
                textFormat: Text.PlainText
                anchors.centerIn: parent
                text: root.savingLocation ? "󰦖" : "✕"
                font.family: root.bar.fontFamily
                color: Qt.darker(root.bar.foreground, 1.4)
                font.pixelSize: Style.font.bodySmall

                RotationAnimator on rotation {
                  running: root.savingLocation
                  from: 0; to: 360
                  duration: 800
                  loops: Animation.Infinite
                }
              }

              MouseArea {
                id: clearLocationArea
                anchors.fill: parent
                enabled: !root.savingLocation
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.clearLocation()
              }
            }
          }

          Row {
            id: weatherStats
            visible: !!root.current
            spacing: Style.space(36)

            Column {
              spacing: Style.space(5)
              Text {
                text: "FEELS"
                color: Qt.darker(root.bar.foreground, 1.5)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.bodySmall
                font.letterSpacing: 1
              }
              Text {
                textFormat: Text.PlainText
                text: root.reportFeels
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.title
              }
            }

            Column {
              spacing: Style.space(5)
              Text {
                text: "WIND"
                color: Qt.darker(root.bar.foreground, 1.5)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.bodySmall
                font.letterSpacing: 1
              }
              Text {
                textFormat: Text.PlainText
                text: root.reportWind
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.title
              }
            }

            Column {
              spacing: Style.space(5)
              Text {
                text: "HUMID"
                color: Qt.darker(root.bar.foreground, 1.5)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.bodySmall
                font.letterSpacing: 1
              }
              Text {
                textFormat: Text.PlainText
                text: root.reportHumidity
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.title
              }
            }
          }
        }
      }

      // ---- Geocoding suggestions while the location is being edited.
      Column {
        visible: root.editingLocation && !root.savingLocation && root.locationSuggestions.length > 0
        width: parent.width
        spacing: 0

        Repeater {
          model: root.locationSuggestions

          Rectangle {
            required property var modelData
            required property int index
            width: parent.width
            height: suggestionRow.implicitHeight + Style.space(12)
            radius: Style.cornerRadius
            color: index === root.suggestionIndex ? Style.hoverFillFor(root.bar.foreground, Color.accent) : "transparent"

            Row {
              id: suggestionRow
              anchors.left: parent.left
              anchors.leftMargin: Style.space(16)
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(8)

              Text {
                textFormat: Text.PlainText
                text: modelData.name
                color: index === root.suggestionIndex ? Style.hoverStateColor(root.bar.foreground, Color.accent) : root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.body
              }
              Text {
                textFormat: Text.PlainText
                visible: text !== ""
                text: modelData.description
                color: Qt.darker(root.bar.foreground, 1.5)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.bodySmall
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onPositionChanged: root.suggestionIndex = index
              onClicked: root.pickSuggestion(modelData)
            }
          }
        }
      }

      Text {
        visible: !root.current
        text: "Fetching forecast…"
        color: Qt.darker(root.bar.foreground, 1.5)
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.bodySmall
        font.italic: true
      }

      // ---- Divider between current conditions and forecast.
      Rectangle {
        visible: root.forecastDays.length > 0
        width: parent.width
        height: Style.spacing.hairline
        color: root.bar.foreground
        opacity: 0.12
      }

      // ---- Forecast row: each cell has the day icon left of a day-name + hi/lo column.
      //      Wrapped in an Item so the block of cells can be centered within the popup.
      Item {
        visible: root.forecastDays.length > 0
        width: parent.width
        height: forecastRow.height

        Row {
          id: forecastRow
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Style.space(44)

          Repeater {
            model: root.forecastDays

            Row {
              required property var modelData
              required property int index
              spacing: Style.space(10)

              Text {
                textFormat: Text.PlainText
                anchors.verticalCenter: parent.verticalCenter
                text: root.dayIcon(modelData)
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.display
              }

              Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(2)

                Text {
                  textFormat: Text.PlainText
                  text: root.dayName(modelData.date).toUpperCase()
                  color: Qt.darker(root.bar.foreground, 1.4)
                  font.family: root.bar.fontFamily
                  font.pixelSize: Style.font.caption
                  font.letterSpacing: 1
                }

                Row {
                  spacing: Style.space(6)

                  Text {
                    textFormat: Text.PlainText
                    text: root.bareTempForDay(modelData, "max")
                    color: root.bar.foreground
                    font.family: root.bar.fontFamily
                    font.pixelSize: Style.font.body
                  }
                  Text {
                    textFormat: Text.PlainText
                    text: root.bareTempForDay(modelData, "min")
                    color: Qt.darker(root.bar.foreground, 1.5)
                    font.family: root.bar.fontFamily
                    font.pixelSize: Style.font.body
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  }
  }

}
