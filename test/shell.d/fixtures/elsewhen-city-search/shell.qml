import QtQuick
import Quickshell
import qs.Commons

// A Return in the city search that beats the geocoder: the places are fed in
// by hand, the way the panel's cache hands them over once curl answers.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []

  // Query -> places, undefined while the geocoder is still answering.
  property var cache: ({})
  property var picks: []
  property var search: null
  property var field: null
  property int step: 0

  readonly property var caledonia: ({ label: "Caledonia", value: "America/Toronto", lat: 43.07, lon: -79.95, region: "Ontario, Canada" })

  function fail(message) {
    failures.push(String(message))
  }

  function assertEqual(actual, expected, message) {
    if (actual !== expected) fail(message + ": expected " + expected + ", got " + actual)
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  function answer(query, places) {
    var next = Object.assign({}, cache)
    next[query] = places
    cache = next
  }

  // Opens the search on a query the geocoder has not answered yet.
  function type(query) {
    search.active = true
    field.text = query
  }

  function load() {
    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/panels/elsewhen/CitySearch.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      fail("CitySearch failed to load: " + component.errorString())
      return false
    }
    search = component.createObject(host, {
      width: 300,
      placesFor: function(text) { return root.cache[text] || [] },
      placesPending: function(text) { return text !== "" && root.cache[text] === undefined }
    })
    if (!search) {
      fail("CitySearch failed to instantiate: " + component.errorString())
      return false
    }
    search.picked.connect(function(label, id, place) { root.picks.push(label + "|" + id + "|" + (place ? place.region : "")) })
    for (var i = 0; i < search.children.length; i++) {
      if (search.children[i].placeholderText !== undefined) field = search.children[i]
    }
    if (!field) {
      fail("CitySearch has no text field")
      return false
    }
    return true
  }

  // Each step runs on its own tick, so the deferred work between them settles.
  readonly property var steps: [
    function() {
      type("caledonia")
      assertEqual(search.searching, true, "an unanswered query is still searching")
      search.pickSelected()
      assertEqual(picks.length, 0, "Return before the places land picks nothing yet")
      answer("caledonia", [caledonia])
    },
    function() {
      assertEqual(picks.join(), "Caledonia|America/Toronto|Ontario, Canada", "the place is picked as soon as it lands")
      assertEqual(search.active, false, "and the search closes")

      picks = []
      type("nowhere")
      search.pickSelected()
      answer("nowhere", [])
    },
    function() {
      assertEqual(picks.length, 0, "an answer with no matches picks nothing")
      assertEqual(search.active, true, "and leaves the search open")
      // The same query finding a match later, without another Return.
      answer("nowhere", [caledonia])
    },
    function() {
      assertEqual(picks.length, 0, "a Return that found no matches is not held for later")
      search.stop()

      type("cale")
      search.pickSelected()
      field.text = "caledonia"
    },
    function() {
      assertEqual(picks.length, 0, "typing on after Return drops the pick")
      search.stop()

      type("caled")
      search.pickSelected()
      search.stop()
      answer("caled", [caledonia])
      search.active = true
      field.text = "caled"
    },
    function() {
      assertEqual(picks.length, 0, "closing the search drops the pick")
    }
  ]

  Item { id: host; width: 300; height: 400 }

  Timer {
    interval: 20
    running: true
    repeat: true
    onTriggered: {
      try {
        if (root.step === 0 && !root.load()) root.step = root.steps.length
        if (root.step < root.steps.length) root.steps[root.step]()
      } catch (error) {
        root.fail("city search fixture threw at step " + root.step + ": " + error)
        root.step = root.steps.length
      }
      root.step++
      if (root.step >= root.steps.length) {
        running = false
        root.writeResult()
      }
    }
  }
}
