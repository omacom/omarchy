import QtQuick
import qs.Commons
import qs.Ui
import "Model.js" as Model

// A button that opens into a city search: a field, then the matching cities
// with their zone and offset. Arrows move the selection, Return picks it,
// Escape backs out. Inline rather than a dropdown so the results grow the
// panel instead of running off the bottom of the screen.
Column {
  id: search

  // [{ label, value }] from Model.zoneOptions.
  property var options: []
  property int limit: 6
  // Zone id -> offset text; read inside a binding, so its dependencies track.
  property var offsetLabel: function(zoneId) { return "" }
  property bool loading: false
  property string buttonText: "+  Add a city"
  property string placeholderText: "Search cities\u2026"
  property string loadingText: "Loading zones\u2026"
  property real fontSize: Style.font.bodySmall
  property color foreground: Color.foreground
  property color dim: Qt.darker(foreground, 1.55)
  property color fainter: Qt.darker(foreground, 2.1)
  property string fontFamily: Style.font.family

  // False when the host shows CityMatches elsewhere.
  property bool inlineResults: true
  // The host's keyboard cursor is on the button.
  property bool hasCursor: false

  property bool active: false
  readonly property string query: field.text
  readonly property var matches: active ? Model.searchZones(options, query, limit) : []
  // An index, not the match itself: the list is rebuilt on every keystroke.
  property int selectedIndex: 0

  signal picked(string label, string id)
  signal dismissed()

  onQueryChanged: selectedIndex = 0
  onMatchesChanged: if (selectedIndex >= matches.length) selectedIndex = 0

  function start() {
    selectedIndex = 0
    active = true
    Qt.callLater(function() { field.text = ""; field.forceActiveFocus() })
  }

  // The hidden field would keep the keyboard, so the host takes it back on dismissed.
  function stop() {
    active = false
    field.text = ""
    dismissed()
  }

  function pick(match) {
    picked(match.label, match.value)
    stop()
  }

  function pickSelected() {
    if (matches.length > 0) pick(matches[Util.clamp(selectedIndex, 0, matches.length - 1)])
  }

  spacing: Style.spacing.md

  Button {
    width: parent.width
    // Matches the field, so opening the search does not shift the layout.
    height: field.implicitHeight
    visible: !search.active
    text: search.buttonText
    fontSize: search.fontSize
    foreground: search.foreground
    fontFamily: search.fontFamily
    bordered: true
    hasCursor: search.hasCursor
    onClicked: search.start()
  }

  TextField {
    id: field
    visible: search.active
    width: parent.width
    placeholderText: search.placeholderText
    foreground: search.foreground
    Keys.onEscapePressed: search.stop()
    Keys.onReturnPressed: search.pickSelected()
    Keys.onEnterPressed: search.pickSelected()
    Keys.onUpPressed: search.selectedIndex = Model.moveSelection(search.selectedIndex, -1, search.matches.length)
    Keys.onDownPressed: search.selectedIndex = Model.moveSelection(search.selectedIndex, 1, search.matches.length)
  }

  CityMatches {
    width: parent.width
    visible: search.active && search.inlineResults
    citySearch: search
  }
}
