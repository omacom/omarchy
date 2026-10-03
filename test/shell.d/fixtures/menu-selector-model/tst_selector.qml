import QtQuick
import QtTest

TestCase {
  id: test
  name: "MenuSelectorModel"

  Component {
    id: selectorComponent
    Item {
      id: root
      property string mode: "select"
      readonly property bool dmenuActive: mode === "select" || mode === "input"
      property var dmenuOptions: []
      property string filterText: ""
      property int selectedIndex: 0
      property bool searchDivider: true
      property int layoutSerial: 0
      property bool deleteConfirmOpen: false
      property int requestSerial: 7
      property int applySerial: 0
      property bool opened: true
      property int revealCount: 0
      property var selectedValue: null
      property int finishCount: 0
      property alias model: displayModel
      ListModel { id: displayModel }

      function revealCursor() { revealCount += 1 }
      function finishRequest(value) { selectedValue = value; finishCount += 1 }

      // PRODUCTION_FUNCTIONS
    }
  }

  SignalSpy { id: countSpy; signalName: "countChanged" }
  SignalSpy { id: insertSpy; signalName: "rowsInserted" }
  SignalSpy { id: removeSpy; signalName: "rowsRemoved" }
  SignalSpy { id: layoutSpy; signalName: "layoutSerialChanged" }
  property var selector: null

  function init() {
    selector = createTemporaryObject(selectorComponent, test)
    verify(selector !== null)
    countSpy.target = selector.model
    insertSpy.target = selector.model
    removeSpy.target = selector.model
    layoutSpy.target = selector
    verify(countSpy.valid && insertSpy.valid && removeSpy.valid && layoutSpy.valid)
    clearSpies()
  }

  function clearSpies() {
    countSpy.clear()
    insertSpy.clear()
    removeSpy.clear()
    layoutSpy.clear()
  }

  function expectedRow(index, icon, label, detail) {
    return {
      itemId: "dmenu." + index, disabled: false, kind: "dmenu",
      icon: icon, iconFont: "", appIcon: "", appId: "", label: label,
      target: "", detail: detail, path: "", childCount: 0, action: "",
      provider: "", score: index, section: ""
    }
  }

  function compareRows(expected) {
    compare(selector.model.count, expected.length, "filtered row count")
    for (var i = 0; i < expected.length; i++) {
      var actual = selector.model.get(i)
      compare(Object.keys(actual).sort(), Object.keys(expected[i]).sort(), "all 16 model roles")
      for (var role in expected[i]) {
        compare(actual[role], expected[i][role], "row " + i + " role " + role)
        compare(typeof actual[role], typeof expected[i][role], "role type " + role)
      }
    }
  }

  function test_rows_data() {
    var options = ["Alpha", "glyph\tDuplicate\tfirst", "other\tDuplicate\tsecond\textra",
                   "icon\tCAFÉ 東京\tdetail with \"quotes\" $(literal)", "i\tNo detail\t", ""]
    var all = [expectedRow(0, "", "Alpha", ""), expectedRow(1, "glyph", "Duplicate", "first"),
               expectedRow(2, "other", "Duplicate", "second\textra"),
               expectedRow(3, "icon", "CAFÉ 東京", "detail with \"quotes\" $(literal)"),
               expectedRow(4, "i", "No detail", ""), expectedRow(5, "", "", "")]
    return [
      {tag: "all", options: options, query: "", rows: all},
      {tag: "whitespace", options: options, query: "  \t ", rows: all},
      {tag: "label-case", options: options, query: " aLPHa ", rows: [all[0]]},
      {tag: "duplicate-labels", options: options, query: "duplicate", rows: [all[1], all[2]]},
      {tag: "detail-and-tabs", options: options, query: "SECOND\textra", rows: [all[2]]},
      {tag: "unicode", options: options, query: "café 東京", rows: [all[3]]},
      {tag: "icon-is-not-searchable", options: options, query: "glyph", rows: []},
      {tag: "no-match", options: options, query: "absent", rows: []},
      {tag: "empty-options", options: [], query: "", rows: []}
    ]
  }

  function test_rows(data) {
    selector.dmenuOptions = data.options
    selector.filterText = data.query
    selector.rebuildDmenuDisplay()
    compareRows(data.rows)
    compare(selector.searchDivider, false)
    compare(selector.layoutSerial, 1)
    compare(layoutSpy.count, 1)
    compare(insertSpy.count, data.rows.length ? 1 : 0, "one insertion per nonempty rebuild")
    compare(countSpy.count, data.rows.length ? 1 : 0)
    compare(removeSpy.count, 0)
    if (data.rows.length) {
      compare(insertSpy.signalArguments[0][1], 0)
      compare(insertSpy.signalArguments[0][2], data.rows.length - 1)
      tryCompare(selector, "revealCount", 1)
      // The exact value crosses the production activate/apply boundary.
      for (var i = 0; i < data.rows.length; i++) {
        selector.activateIndex(i, false)
        var row = data.rows[i]
        compare(selector.selectedValue, row.detail ? row.label + "\t" + row.detail : row.label)
        compare(selector.finishCount, i + 1)
        compare(selector.applySerial, selector.requestSerial)
        compare(selector.opened, false)
        compare(selector.filterText, "")
      }
    } else {
      wait(0)
      compare(selector.revealCount, 0)
      selector.activateIndex(0, false)
      compare(selector.finishCount, 0)
    }
    selector.activateIndex(-1, false)
    selector.activateIndex(selector.model.count, false)
    compare(selector.finishCount, data.rows.length, "out of range selection produces no output")
  }

  function test_selectionClamp_data() {
    return [{tag: "negative", initial: -5, expected: 0},
            {tag: "past-end", initial: 99, expected: 2},
            {tag: "in-range", initial: 1, expected: 1}]
  }

  function test_selectionClamp(data) {
    selector.dmenuOptions = ["a", "b", "c"]
    selector.selectedIndex = data.initial
    selector.rebuildDmenuDisplay()
    compare(selector.selectedIndex, data.expected)
    tryCompare(selector, "revealCount", 1)
    selector.filterText = "absent"
    selector.rebuildDmenuDisplay()
    compare(selector.selectedIndex, 0)
    compare(selector.model.count, 0)
  }

  function test_rebuildSignalsAndReplacement() {
    var options = []
    for (var i = 0; i < 236; i++) options.push("row " + i)
    selector.dmenuOptions = options
    selector.rebuildDmenuDisplay()
    compare(selector.model.count, 236)
    compare(insertSpy.count, 1)
    compare(countSpy.count, 1)
    tryCompare(selector, "revealCount", 1)

    clearSpies()
    selector.filterText = "row 235"
    selector.rebuildDmenuDisplay()
    compareRows([expectedRow(235, "", "row 235", "")])
    compare(removeSpy.count, 1)
    compare(removeSpy.signalArguments[0][1], 0)
    compare(removeSpy.signalArguments[0][2], 235)
    compare(insertSpy.count, 1)
    compare(countSpy.count, 2, "clear plus one batched append")
    compare(layoutSpy.count, 1)
    tryCompare(selector, "revealCount", 2)

    clearSpies()
    selector.dmenuOptions = []
    selector.rebuildDmenuDisplay()
    compare(selector.model.count, 0)
    compare(removeSpy.count, 1)
    compare(insertSpy.count, 0)
    compare(countSpy.count, 1)
    wait(0)
    compare(selector.revealCount, 2)

    clearSpies()
    selector.rebuildDmenuDisplay()
    compare(insertSpy.count, 0)
    compare(removeSpy.count, 0)
    compare(countSpy.count, 0, "empty to empty emits no count change")
    compare(layoutSpy.count, 1)
  }

  function test_inputMode() {
    selector.dmenuOptions = ["existing"]
    selector.rebuildDmenuDisplay()
    tryCompare(selector, "revealCount", 1)
    clearSpies()
    selector.mode = "input"
    selector.filterText = "typed café\t$(literal)"
    selector.selectedIndex = 42
    selector.rebuildDmenuDisplay()
    compare(selector.model.count, 0)
    compare(removeSpy.count, 1)
    compare(insertSpy.count, 0)
    compare(countSpy.count, 1)
    compare(layoutSpy.count, 1)
    compare(selector.selectedIndex, 42, "input mode leaves row selection alone")
    wait(0)
    compare(selector.revealCount, 1)
    selector.activateIndex(0, false)
    compare(selector.selectedValue, "typed café\t$(literal)")
    compare(selector.finishCount, 1)
    compare(selector.applySerial, selector.requestSerial)
  }
}
