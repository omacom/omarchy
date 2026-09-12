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
    citiesFile.reload()
    root.refresh()
  }

  function openFromHotkey() {
    openedFromHotkey = true
    root.controller.show()
    locationFile.reload()
    citiesFile.reload()
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
    metRetries = 0
    forecastProc.running = false
    dailyForecastProc.running = false
    metFetchProc.running = false
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

  // ---- Multi-city pages. Page 1 is always the current location (the stock
  //      weather.json contract and IP auto-detect above stay untouched);
  //      added cities persist in a separate widget-owned file and take
  //      current conditions from Open-Meteo, never wttr.in.
  property var savedCities: []
  property int currentPageIndex: 0
  property bool addingCity: false
  property real swipeAcc: 0
  property bool swipeLocked: false
  property var cityDailyCache: ({})
  property var cityMetCache: ({})
  property var cityLabelCache: ({})
  property string dailyRequestKey: ""
  property string metBodyKey: ""
  readonly property var pages: Model.buildPages(configuredLocationState, savedCities)
  readonly property var activePage: pages[Math.max(0, Math.min(currentPageIndex, pages.length - 1))]
  readonly property bool activeIsCurrent: activePage ? activePage.isCurrent === true : true
  readonly property string activeKey: activeIsCurrent ? "current" : Model.cityKey(activePage.latitude, activePage.longitude)
  readonly property string citiesPath: Quickshell.env("HOME") + "/.local/state/omarchy/settings/" + Model.CITIES_FILENAME

  // Widget-owned city list, next to the stock weather.json but never in
  // it: omarchy-weather-location owns weather.json; this file is ours.
  property FileView citiesFile: FileView {
    path: root.citiesPath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      root.savedCities = Model.parseCityList(text())
      root.clampPageIndex()
    }
    onLoadFailed: root.savedCities = []
  }

  onPagesChanged: {
    root.clampPageIndex()
    root.applyActiveCaches()
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
  // Added cities take current conditions from Open-Meteo, never wttr.in;
  // the first page keeps the exact stock behaviour (Open-Meteo fast path
  // with coordinates, wttr otherwise).
  readonly property var current: root.activeIsCurrent ? ((hasConfiguredCoordinates && openMeteoCurrent) ? openMeteoCurrent : ((report && report.current_condition && report.current_condition[0]) ? report.current_condition[0] : openMeteoCurrent)) : openMeteoCurrent
  readonly property var areaInfo: report && report.nearest_area && report.nearest_area[0] ? report.nearest_area[0] : null
  // Day rows: today plus up to three following days. Today expands to
  // 2-hour slots for the next 24 hours; later days expand to 6-hour
  // quarters. Rain amounts come from MET Norway, chances from Open-Meteo.
  readonly property var dayRows: Model.openMeteoDayRows(dailyForecastReport, Qt.formatDate(new Date(), "yyyy-MM-dd"))
  property string expandedDate: ""

  // MET Norway state. metTimeseries is the cached Locationforecast
  // timeseries array; the fetcher script owns throttle/Expires/304 logic.
  property var metTimeseries: null
  property string metStatus: ""
  property int metRetries: 0
  readonly property string metCacheDir: Quickshell.env("HOME") + "/.cache/omarchy/" + Model.MET_CACHE_SUBDIR
  // Per-city MET dir: the first page keeps the historic single-location
  // dir; every added city gets its own keyed subdirectory.
  readonly property string activeMetCacheDir: activeIsCurrent ? metCacheDir : metCacheDir + "/" + Model.metCityKey(activePage.latitude, activePage.longitude)
  readonly property var metIndex: Model.indexMetTimeseries(metTimeseries)
  readonly property var rainProbIndex: Model.indexPrecipitationProbability(dailyForecastReport && dailyForecastReport.hourly)
  readonly property string reportCountry: areaInfo && areaInfo.country && areaInfo.country[0] ? areaInfo.country[0].value : ""

  readonly property bool useImperial: Model.shouldUseImperial(setting("unit", ""), Qt.locale().name, reportCountry)

  // Auto-refresh interval in minutes; clamped to a sane minimum.
  readonly property int refreshMinutes: Math.max(1, parseInt(setting("refreshMinutes", 15), 10) || 15)

  readonly property string reportLocation: root.activeIsCurrent ? (configuredLocation || wttrLocation || (areaInfo && areaInfo.areaName && areaInfo.areaName[0] ? areaInfo.areaName[0].value : "")) : (activePage ? activePage.name : "")
  readonly property string reportTempNum:   current ? String(useImperial ? current.temp_F : current.temp_C) : ""
  readonly property string tempUnit:        "°" + (useImperial ? "F" : "C")
  readonly property string reportFeels:     current ? formatTemp(useImperial ? current.FeelsLikeF : current.FeelsLikeC) : ""
  readonly property string reportWind:      current ? (useImperial ? (current.windspeedMiles + " mph") : (current.windspeedKmph + " km/h")) : ""
  readonly property string reportHumidity:  current ? (current.humidity + "%") : ""

  function refresh() {
    // Each full refresh cycle gets a fresh retry budget, so an earlier
    // exhausted round (e.g. waking with the network still down) doesn't
    // starve retries for the rest of the session.
    forecastRetries = 0
    dailyForecastRetries = 0
    metRetries = 0
    if (!forecastProc.running) forecastProc.running = true
    if (root.locationQuery === "" && !locationProc.running) locationProc.running = true
    // With stored coordinates this fetches open-meteo right away — no need
    // to wait for the slow wttr response. Without them it's a no-op until
    // wttr reports the detected area.
    ensureCityData()
  }

  // Coordinates for one page: the current page resolves exactly as the
  // stock widget did (saved coordinates, else the wttr-detected area);
  // added cities carry their own coordinates from geocoding.
  function coordsForPage(page, sourceReport) {
    if (!page) return null
    if (page.isCurrent) return root.forecastCoords(sourceReport)
    var lat = parseFloat(String(page.latitude))
    var lon = parseFloat(String(page.longitude))
    if (isNaN(lat) || isNaN(lon)) return null
    return [lat, lon]
  }

  function keyForPage(page) {
    if (!page) return ""
    if (page.isCurrent) return "current"
    return Model.cityKey(page.latitude, page.longitude)
  }

  function refreshDailyForecastFor(page, sourceReport) {
    if (dailyForecastProc.running) return false

    var coords = root.coordsForPage(page, sourceReport)
    if (!coords) return false
    var lat = coords[0]
    var lon = coords[1]

    dailyRequestKey = root.keyForPage(page)
    var url = "https://api.open-meteo.com/v1/forecast"
      + "?latitude=" + encodeURIComponent(String(lat))
      + "&longitude=" + encodeURIComponent(String(lon))
      + "&daily=weather_code,temperature_2m_max,temperature_2m_min"
      + "&hourly=precipitation_probability"
      + "&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day"
      + "&forecast_days=4"
      + "&timezone=auto"
    dailyForecastProc.command = ["curl", "-fsS", "--max-time", "5", url]
    dailyForecastProc.running = true
    return true
  }

  function refreshDailyForecast(sourceReport) {
    // Legacy single-page entry point (wttr arrival, retry timer): the
    // current page resolves exactly as before.
    if (!root.activeIsCurrent) return
    refreshDailyForecastFor(root.activePage, sourceReport)
  }

  // Fetch the visible page plus its immediate neighbours — never the whole
  // list. Neighbours prefetch Open-Meteo only (day rows plus the current
  // header); MET rain loads when its page becomes visible.
  function ensureCityData() {
    refreshDailyForecastFor(root.activePage, null)
    refreshMetFor(root.activePage)
    neighbourTimer.restart()
  }

  function ensureNeighbours() {
    var window = Model.pageWindow(currentPageIndex, pages.length)
    for (var i = 0; i < window.length; i++) {
      if (window[i] === currentPageIndex) continue
      refreshDailyForecastFor(pages[window[i]], null)
    }
  }

  // Swap the displayed data to the active page: instant when cached, then
  // revalidated by the fetch the switch triggers.
  function applyActiveCaches() {
    var daily = root.cityDailyCache[root.activeKey]
    if (daily) {
      root.dailyForecastReport = daily
      var parsedCurrent = Model.openMeteoCurrentCondition(daily)
      if (parsedCurrent) root.label = Model.currentIcon(parsedCurrent, root.label)
    } else if (root.cityLabelCache[root.activeKey]) {
      root.label = root.cityLabelCache[root.activeKey]
    }
    var series = root.cityMetCache[root.activeKey]
    if (series) root.metTimeseries = series
    root.metBodyKey = root.activeKey
    metBodyFile.reload()
  }

  function clampPageIndex() {
    if (currentPageIndex > pages.length - 1) currentPageIndex = Math.max(0, pages.length - 1)
    if (currentPageIndex < 0) currentPageIndex = 0
  }

  function goToPage(index) {
    var clamped = Math.max(0, Math.min(parseInt(index, 10) || 0, pages.length - 1))
    currentPageIndex = clamped
    expandedDate = ""
    swipeAcc = 0
    applyActiveCaches()
    ensureCityData()
  }

  function stepPage(direction) {
    goToPage(currentPageIndex + (direction > 0 ? 1 : -1))
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
      locationField.text = root.addingCity && root.activePage ? root.activePage.name : root.configuredLocation
      locationField.selectAll()
      locationField.forceActiveFocus()
    })
  }

  // "+" entry point: the same search UI, but a picked suggestion is
  // appended to the widget-owned city list instead of weather.json.
  function startManagingCities() {
    addingCity = true
    startEditingLocation()
  }

  function cancelEditingLocation() {
    editingLocation = false
    addingCity = false
    savingLocation = false
    savingLocationQueryStarted = false
    locationSuggestions = []
    geocodeDebounce.stop()
    Qt.callLater(function() { if (keyCatcher) keyCatcher.forceActiveFocus() })
  }

  function commitLocation() {
    var location = Model.locationCommit(locationField.text, locationSuggestions, suggestionIndex)
    if (root.addingCity) {
      root.addCityFromSuggestion(location)
      return
    }
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

  // A picked suggestion becomes a new page: duplicate adds (same
  // coordinates, or the current location itself) are a silent no-op that
  // stays on the visible page.
  function addCityFromSuggestion(suggestion) {
    if (!suggestion || !Model.validCity(suggestion)
        || Model.isDuplicateCity(root.configuredLocationState, root.savedCities, suggestion)) {
      addingCity = false
      cancelEditingLocation()
      return
    }
    savedCities = Model.addCity(root.savedCities, suggestion)
    persistCities()
    var target = pages.length - 1
    addingCity = false
    cancelEditingLocation()
    goToPage(target)
  }

  function removeCity(key) {
    savedCities = Model.removeCity(root.savedCities, key)
    persistCities()
    clampPageIndex()
    applyActiveCaches()
    ensureCityData()
  }

  // Saves go to the widget-owned cities file only — never weather.json.
  // FileView is read-only, so a one-shot shell command carries the save;
  // its shape is built by Model.citiesSaveScript (mkdir -p, temp file,
  // atomic mv) so tests drive the real string.
  function persistCities() {
    citiesSaveProc.command = ["sh", "-c", Model.citiesSaveScript(Model.serializeCityList(root.savedCities), root.citiesPath)]
    citiesSaveProc.running = true
  }

  function clearLocation() {
    persistLocation("", null, null)
    wttrLocation = ""
    cancelEditingLocation()
  }

  function pickSuggestion(suggestion) {
    if (!suggestion) return
    if (root.addingCity) {
      root.addCityFromSuggestion(suggestion)
      return
    }
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

  // Slots for an expanded day row: 2-hour slots for today (next 24 hours),
  // 6-hour quarters for later days. Re-evaluates when either source updates.
  function slotsForDay(day) {
    if (!day) return []
    if (day.isToday) return Model.buildTwoHourSlots(root.metIndex, root.rainProbIndex, Date.now())
    return Model.buildSixHourSlots(root.metIndex, root.rainProbIndex, day.date)
  }

  function rainTotalForDay(day) {
    return Model.formatDayRain(Model.dayRainTotal(root.slotsForDay(day)))
  }

  function toggleDay(dateString) {
    root.expandedDate = root.expandedDate === dateString ? "" : dateString
  }

  function dayRowName(day) {
    if (!day) return ""
    if (day.isToday) return "Today"
    return root.dayName(day.date)
  }

  function slotTemp(slot) {
    return Model.formatSlotTemp(slot ? slot.tempC : null, root.useImperial)
  }

  function slotRain(slot) {
    return Model.formatRain(slot ? slot.rainMm : null)
  }

  function slotChance(slot) {
    return Model.formatChance(slot ? slot.chance : null)
  }

  function slotIcon(slot) {
    var glyph = slot ? slot.icon : ""
    return glyph || Model.MISSING_VALUE
  }

  // Coordinates shared by the Open-Meteo and MET Norway fetches: saved
  // coordinates when present, else the area wttr.in reported for auto-detect.
  function forecastCoords(sourceReport) {
    return Model.forecastCoords(root.configuredLocationState, sourceReport, root.areaInfo)
  }

  // MET follows the visible page only, each city in its own cache subdir
  // (the first page keeps the historic single-location dir untouched).
  function refreshMetFor(page) {
    if (metFetchProc.running) return false
    if (!page || root.keyForPage(page) !== root.activeKey) return false
    var coords = root.coordsForPage(page, null)
    if (!coords) return false
    var script = String(Qt.resolvedUrl("met-fetch.sh")).replace(/^file:\/\//, "")
    metFetchProc.command = [script, String(coords[0]), String(coords[1]), root.activeMetCacheDir]
    metFetchProc.running = true
    return true
  }

  function refreshMet() {
    refreshMetFor(root.activePage)
  }

  function scheduleMetRetry() {
    if (metRetries >= 3) return
    metRetries++
    metRetryTimer.restart()
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
          // wttr feeds the first page only; the report is still stored so
          // page 1 stays fresh while another city is showing.
          root.report = parsed
          if (!root.hasConfiguredCoordinates && root.activeIsCurrent)
            root.label = Model.provisionalCurrentIcon(parsed.current_condition && parsed.current_condition[0], root.label)
          root.forecastRetries = 0
          if (Model.weatherResponseCompletesSave(root.hasConfiguredCoordinates, "wttr"))
            root.finishSavingLocation()
          // Stored coordinates already drove the fast open-meteo fetch from
          // refresh(); only auto-detect needs the area wttr reported.
          if (isNaN(parseFloat(String(root.configuredLocationState.latitude))) && root.activeIsCurrent) {
            root.refreshDailyForecast(parsed)
            root.refreshMet()
          }
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
          // Attribute the response to the city that requested it: a
          // neighbour's data is cached for its visit, never painted over
          // the visible page.
          if (root.dailyRequestKey) root.cityDailyCache[root.dailyRequestKey] = parsed
          if (root.dailyRequestKey !== root.activeKey) {
            // A neighbour finished while the visible page still needs its
            // own fetch: the process is free now, fire it — but only when
            // the visible page has nothing cached, so neighbour visits do
            // not refetch the visible page every time.
            if (!root.cityDailyCache[root.activeKey])
              Qt.callLater(function() { root.refreshDailyForecastFor(root.activePage, null) })
            return
          }
          var nextLabel = Model.currentIcon(parsedCurrent, root.label)
          root.cityLabelCache[root.activeKey] = nextLabel
          root.dailyForecastReport = parsed
          root.label = nextLabel
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
        root.metRetries = 0
        forecastProc.running = false
        dailyForecastProc.running = false
        metFetchProc.running = false
        Qt.callLater(root.refresh)
      }
    }
  }

  // One-shot save of the widget-owned city list: success re-reads the
  // file; failure warns to the shell log and re-reads too, reverting the
  // popup to disk truth so it never shows an unsaved city.
  Process {
    id: citiesSaveProc
    stdout: StdioCollector {
      id: citiesSaveOut
      waitForEnd: true
    }
    onExited: function(exitCode) {
      if (exitCode === 0) {
        citiesFile.reload()
        return
      }
      console.warn("omarchy.weather: saving cities to " + root.citiesPath + " failed (exit " + exitCode + "): " + String(citiesSaveOut.text || "").trim())
      citiesFile.reload()
    }
  }

  Timer {
    id: neighbourTimer
    interval: 600
    onTriggered: root.ensureNeighbours()
  }

  Timer {
    id: swipeIdleTimer
    interval: 350
    onTriggered: {
      root.swipeAcc = 0
      root.swipeLocked = false
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

  // MET Norway fetch via the caching helper: it throttles to one request
  // per 30 minutes, revalidates with If-Modified-Since, and honours
  // Expires. The body cache is parsed below; a 304 keeps it untouched.
  Process {
    id: metFetchProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var raw = String(text || "").trim()
        if (!raw) {
          root.scheduleMetRetry()
          return
        }
        try {
          var status = JSON.parse(raw)
          root.metStatus = status.status || ""
          if (root.metStatus === "ok" || root.metStatus === "not-modified")
            metBodyFile.reload()
          else if (root.metStatus !== "throttled" && root.metStatus !== "fresh")
            root.scheduleMetRetry()
        } catch (e) {
          root.scheduleMetRetry()
        }
      }
    }
    onExited: function(exitCode) {
      if (exitCode !== 0) root.scheduleMetRetry()
    }
  }

  Timer {
    id: metRetryTimer
    interval: 2500
    onTriggered: root.refreshMet()
  }

  // Cached Locationforecast body for the visible page. Loads once per page
  // visit so cached data paints instantly; reloaded after every fetch.
  // The path follows the active page's own subdir, so cities never share
  // or overwrite a cache; metBodyKey attributes late loads to their page.
  property FileView metBodyFile: FileView {
    path: root.activeMetCacheDir + "/body.json"
    printErrors: false
    onLoaded: {
      try {
        var parsed = JSON.parse(text())
        var series = parsed && parsed.properties ? parsed.properties.timeseries : null
        if (series) {
          root.cityMetCache[root.metBodyKey] = series
          if (root.metBodyKey === root.activeKey) root.metTimeseries = series
        }
      } catch (e) {
        // Keep last-good series visible.
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
    contentHeight: panel.fittedContentHeight(weatherColumn.implicitHeight + cityNav.height + Style.space(12))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: root.editingLocation
      onReturnRequested: root.startEditingLocation()
      onMoveRequested: function(dx, dy) { if (dx !== 0) root.stepPage(dx) }
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Item {
        id: pageContainer
        anchors.fill: parent

      Flickable {
        id: weatherScroll
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: cityNav.top
        anchors.bottomMargin: Style.space(8)
        WheelHandler {
          // Two-finger sideways swipes arrive horizontal (angleDelta.y
          // === 0); vertical wheels fall through to the Flickable
          // untouched. Deltas accumulate to exactly one page step per
          // gesture; the idle timer re-arms for the next gesture.
          onWheel: function(event) {
            if (!Model.isHorizontalWheel(event.angleDelta.x, event.angleDelta.y)) return
            var dx = event.pixelDelta.x !== 0 ? event.pixelDelta.x : event.angleDelta.x
            swipeIdleTimer.restart()
            event.accepted = true
            if (root.swipeLocked) return
            var folded = Model.accumulateSwipe(root.swipeAcc, dx, Model.SWIPE_THRESHOLD)
            root.swipeAcc = folded.acc
            if (folded.step !== 0) {
              root.swipeLocked = true
              root.swipeAcc = 0
              root.stepPage(folded.step)
            }
          }
        }
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
              onTapped: root.activeIsCurrent ? root.startEditingLocation() : root.startManagingCities()
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
              placeholderText: root.addingCity ? "Add city…" : "Search city"
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

      // ---- Added cities, managed from the same place: visible while
      //      adding, each row removable. Removing the visible page falls
      //      back to its neighbour.
      Column {
        visible: root.editingLocation && root.addingCity && !root.savingLocation && root.savedCities.length > 0
        width: parent.width
        spacing: 0

        Repeater {
          model: root.savedCities

          Rectangle {
            required property var modelData
            width: parent.width
            height: managedRow.implicitHeight + Style.space(12)
            radius: Style.cornerRadius
            color: "transparent"

            Row {
              id: managedRow
              anchors.left: parent.left
              anchors.leftMargin: Style.space(16)
              anchors.right: removeCityButton.left
              anchors.rightMargin: Style.space(8)
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(8)

              Text {
                textFormat: Text.PlainText
                text: modelData.name
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.body
              }
            }

            Rectangle {
              id: removeCityButton
              width: Style.space(18)
              height: Style.space(18)
              anchors.right: parent.right
              anchors.rightMargin: Style.space(16)
              anchors.verticalCenter: parent.verticalCenter
              radius: Math.min(4, Style.cornerRadius)
              color: removeCityMouse.containsMouse ? Style.hoverFillFor(root.bar.foreground, Color.accent) : "transparent"

              Text {
                textFormat: Text.PlainText
                anchors.centerIn: parent
                text: "✕"
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.bodySmall
              }

              MouseArea {
                id: removeCityMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.removeCity(Model.cityKey(modelData.latitude, modelData.longitude))
              }
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
        visible: root.dayRows.length > 0
        width: parent.width
        height: Style.spacing.hairline
        color: root.bar.foreground
        opacity: 0.12
      }

      // ---- Day rows: icon, name, hi/lo, and total rain. Clicking a row
      //      expands its slot table (2-hour slots for today, 6-hour
      //      quarters for later days): time, icon, temp, rain mm, chance %.
      Column {
        visible: root.dayRows.length > 0
        width: parent.width
        spacing: Style.space(2)

        Repeater {
          model: root.dayRows

          Column {
            required property var modelData
            width: parent.width
            spacing: 0

            Item {
              width: parent.width
              height: dayHead.height + Style.space(12)

              Row {
                id: dayHead
                anchors.left: parent.left
                anchors.leftMargin: Style.space(16)
                anchors.verticalCenter: parent.verticalCenter
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
                    text: root.dayRowName(modelData).toUpperCase()
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

              Row {
                anchors.right: parent.right
                anchors.rightMargin: Style.space(16)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(8)

                Text {
                  textFormat: Text.PlainText
                  anchors.verticalCenter: parent.verticalCenter
                  text: root.rainTotalForDay(modelData)
                  color: Qt.darker(root.bar.foreground, 1.4)
                  font.family: root.bar.fontFamily
                  font.pixelSize: Style.font.bodySmall
                }
                Text {
                  textFormat: Text.PlainText
                  anchors.verticalCenter: parent.verticalCenter
                  text: root.expandedDate === modelData.date ? "▾" : "▸"
                  color: Qt.darker(root.bar.foreground, 1.5)
                  font.family: root.bar.fontFamily
                  font.pixelSize: Style.font.bodySmall
                }
              }

              Rectangle {
                anchors.fill: parent
                radius: Style.cornerRadius
                color: dayMouse.containsMouse ? Style.hoverFillFor(root.bar.foreground, Color.accent) : "transparent"
              }

              MouseArea {
                id: dayMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleDay(modelData.date)
              }
            }

            Column {
              visible: root.expandedDate === modelData.date
              width: parent.width
              spacing: Style.space(2)

              Row {
                anchors.left: parent.left
                anchors.leftMargin: Style.space(58)
                spacing: 0

                Text { width: Style.space(46); text: "TIME"; color: Qt.darker(root.bar.foreground, 1.5); font.family: root.bar.fontFamily; font.pixelSize: Style.font.caption; font.letterSpacing: 1 }
                Text { width: Style.space(30); text: "" }
                Text { width: Style.space(40); text: "TEMP"; color: Qt.darker(root.bar.foreground, 1.5); font.family: root.bar.fontFamily; font.pixelSize: Style.font.caption; font.letterSpacing: 1 }
                Text { width: Style.space(52); text: "MM"; color: Qt.darker(root.bar.foreground, 1.5); font.family: root.bar.fontFamily; font.pixelSize: Style.font.caption; font.letterSpacing: 1 }
                Text { width: Style.space(44); text: "%"; color: Qt.darker(root.bar.foreground, 1.5); font.family: root.bar.fontFamily; font.pixelSize: Style.font.caption; font.letterSpacing: 1 }
              }

              Repeater {
                model: root.slotsForDay(modelData)

                Row {
                  required property var modelData
                  anchors.left: parent.left
                  anchors.leftMargin: Style.space(58)
                  spacing: 0

                  Text {
                    width: Style.space(46)
                    textFormat: Text.PlainText
                    text: modelData.label
                    color: Qt.darker(root.bar.foreground, 1.4)
                    font.family: root.bar.fontFamily
                    font.pixelSize: Style.font.bodySmall
                  }
                  Text {
                    width: Style.space(30)
                    textFormat: Text.PlainText
                    text: root.slotIcon(modelData)
                    color: root.bar.foreground
                    font.family: root.bar.fontFamily
                    font.pixelSize: Style.font.body
                  }
                  Text {
                    width: Style.space(40)
                    textFormat: Text.PlainText
                    text: root.slotTemp(modelData)
                    color: root.bar.foreground
                    font.family: root.bar.fontFamily
                    font.pixelSize: Style.font.bodySmall
                  }
                  Text {
                    width: Style.space(52)
                    textFormat: Text.PlainText
                    text: root.slotRain(modelData)
                    color: root.bar.foreground
                    font.family: root.bar.fontFamily
                    font.pixelSize: Style.font.bodySmall
                  }
                  Text {
                    width: Style.space(44)
                    textFormat: Text.PlainText
                    text: root.slotChance(modelData)
                    color: Qt.darker(root.bar.foreground, 1.4)
                    font.family: root.bar.fontFamily
                    font.pixelSize: Style.font.bodySmall
                  }
                }
              }

              Item {
                width: parent.width
                height: Style.space(8)
              }
            }
          }
        }
      }

      // MET Norway requires attribution for its data.
      Item {
        visible: root.dayRows.length > 0
        width: parent.width
        height: creditLine.height

        Text {
          id: creditLine
          anchors.horizontalCenter: parent.horizontalCenter
          text: "Data: MET Norway, Open-Meteo"
          color: Qt.darker(root.bar.foreground, 1.6)
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
          font.italic: true
        }
      }
        }
      }

      // ---- City pages nav: dots show how many cities there are and which
      //      one is showing (tap to jump); "+" opens the same search UI to
      //      add a city, where added cities are removed again.
      Row {
        id: cityNav
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.space(4)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.space(8)

        Repeater {
          id: cityDots
          model: root.pages

          Rectangle {
            required property int index
            anchors.verticalCenter: parent.verticalCenter
            width: Style.space(6)
            height: Style.space(6)
            radius: width / 2
            color: root.bar.foreground
            opacity: index === root.currentPageIndex ? 0.9 : 0.3

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.goToPage(index)
            }
          }
        }

        Rectangle {
          id: addCityButton
          anchors.verticalCenter: parent.verticalCenter
          width: Style.space(16)
          height: Style.space(16)
          radius: width / 2
          color: addCityMouse.containsMouse ? Style.hoverFillFor(root.bar.foreground, Color.accent) : "transparent"

          Text {
            anchors.centerIn: parent
            textFormat: Text.PlainText
            text: "+"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.body
          }

          MouseArea {
            id: addCityMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.startManagingCities()
          }
        }
      }
      }
    }
  }

}
