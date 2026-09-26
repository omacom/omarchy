import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.Commons
import "ImagePickerModel.js" as ImagePickerModel

Item {
  id: root

  // Injected by omarchy-shell; defaults to the session OMARCHY_PATH.
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property string stateHome: Quickshell.env("HOME") + "/.local/state"
  property string imageDirs: Quickshell.env("OMARCHY_IMAGE_SELECTOR_DIRS") || Quickshell.env("OMARCHY_IMAGE_SELECTOR_DIR") || Quickshell.env("OMARCHY_STOCK_BACKGROUNDS_DIR") || (stateHome + "/omarchy/current/theme/backgrounds")
  property string imageRows: ""
  property string loadedImageRows: ""
  property string selectionFile: Quickshell.env("OMARCHY_IMAGE_SELECTOR_SELECTION_FILE") || Quickshell.env("OMARCHY_BACKGROUND_SELECTION_FILE")
  property string selectedImage: Quickshell.env("OMARCHY_IMAGE_SELECTOR_SELECTED")
  property int selectedIndex: 0
  property bool imagesLoaded: false
  property bool opened: false
  property bool showLabels: false
  property bool filterable: false
  property bool layoutSettled: false
  property bool requestActive: false
  property int requestSerial: 0
  property int applySerial: 0
  property string doneFile: ""
  property string filterText: ""
  property var doneFilesToRelease: []
  // Bound to the central [image-picker] section in shell.toml via Color.qml.
  // `dimColor` tints unselected slices and text outlines on top of the scrim;
  // it intentionally tracks the foundational background, not a surface role.
  property color dimColor: Color.background
  property color foreground: Color.imagePicker.text
  property color scrim: Color.imagePicker.scrim
  property color selectedBorder: Color.imagePicker.selectedBorder
  property color unselectedBorder: Color.imagePicker.unselectedBorder
  property int expandedWidth: 768
  property int expandedHeight: 475
  property int sliceWidth: 108
  property int sliceHeight: 432
  property int sliceSpacing: -30
  property int skewOffset: 28
  readonly property string configDir: Quickshell.env("HOME") + "/.config/omarchy"
  readonly property string alignmentsPath: configDir + "/background-alignments.json"
  property var alignments: ({})
  readonly property var alignmentSteps: [
    { val: "left", ratio: 0.0, label: "Left", sub: "0%", icon: "⇤" },
    { val: "25%", ratio: 0.25, label: "25%", sub: "Mid-L", icon: "↼" },
    { val: "center", ratio: 0.5, label: "Center", sub: "50%", icon: "↔" },
    { val: "75%", ratio: 0.75, label: "75%", sub: "Mid-R", icon: "⇁" },
    { val: "right", ratio: 1.0, label: "Right", sub: "100%", icon: "⇥" }
  ]
  property int currentStepIndex: 2
  readonly property real currentPositionRatio: (currentStepIndex >= 0 && currentStepIndex < alignmentSteps.length) ? alignmentSteps[currentStepIndex].ratio : 0.5
  readonly property string currentAlignmentValue: (currentStepIndex >= 0 && currentStepIndex < alignmentSteps.length) ? alignmentSteps[currentStepIndex].val : "center"

  property string activeMenuTab: "align" // "align" or "transition"

  readonly property var intervalSteps: [
    { val: "off", seconds: 0, label: "Off", sub: "Disabled", icon: "󰅖" },
    { val: "1m", seconds: 60, label: "1m", sub: "Test", icon: "󱎫" },
    { val: "5m", seconds: 300, label: "5m", sub: "Fast", icon: "󱎫" },
    { val: "15m", seconds: 900, label: "15m", sub: "Default", icon: "󱎫" },
    { val: "30m", seconds: 1800, label: "30m", sub: "Steady", icon: "󱎫" },
    { val: "1h", seconds: 3600, label: "1h", sub: "Slow", icon: "󱎫" }
  ]
  readonly property string slideshowPath: configDir + "/background-slideshow.json"
  property bool slideshowEnabled: false
  property int slideshowInterval: 900
  property int currentIntervalIndex: 0
  property bool slideshowDirty: false

  FileView {
    id: slideshowFile
    path: root.slideshowPath
    watchChanges: true
    printErrors: false
    onLoaded: root.loadSlideshowConfig()
    onLoadFailed: function(error) { root.slideshowEnabled = false; root.currentIntervalIndex = 0 }
    onFileChanged: reload()
  }

  Process {
    id: saveSlideshowProc
  }

  property bool alignable: true
  property bool alignMenuExpanded: false
  readonly property bool isCurrentVideo: (imageArray.length > 0 && selectedIndex >= 0 && selectedIndex < imageArray.length)
    ? root.isVideo(imageArray[selectedIndex].filePath) : false
  readonly property bool showAlignment: alignable && !showLabels && !filterable && imagesLoaded && imageArray.length > 0 && !isCurrentVideo
  property int alignmentMenuHeight: 112
  property int bottomChromeHeight: (showLabels ? (filterable ? 104 : 74) : (filterable ? 60 : 30)) + (showAlignment ? alignmentMenuHeight : 0)

  FileView {
    id: alignmentsFile
    path: root.alignmentsPath
    watchChanges: true
    printErrors: false
    onLoaded: root.loadAlignments()
    onLoadFailed: function(error) { root.alignments = ({}) }
    onFileChanged: reload()
  }

  function parsePositionRatio(val) {
    if (val === undefined || val === null || val === "") return 0.5
    var s = String(val).toLowerCase().trim()
    if (s === "left") return 0.0
    if (s === "center") return 0.5
    if (s === "right") return 1.0
    var num = parseFloat(s)
    if (isNaN(num)) return 0.5
    if (s.indexOf("%") !== -1 || num > 1.0) num = num / 100.0
    return Math.max(0.0, Math.min(1.0, num))
  }

  function closestStepIndex(ratio) {
    var closest = 2
    var minDiff = 999
    for (var i = 0; i < alignmentSteps.length; i++) {
      var diff = Math.abs(alignmentSteps[i].ratio - ratio)
      if (diff < minDiff) {
        minDiff = diff
        closest = i
      }
    }
    return closest
  }

  function isVideo(path) {
    if (typeof Util !== "undefined" && typeof Util.isVideoPath === "function") {
      return Util.isVideoPath(path)
    }
    return /\.(mp4|m4v|mov|webm|mkv|avi)$/i.test(String(path || ""))
  }

  function positionRatioFor(filePath, fileName) {
    if (root.isVideo(filePath) || root.isVideo(fileName)) return 0.5
    var val = (alignments && (alignments[filePath] !== undefined ? alignments[filePath] : alignments[fileName]))
    return parsePositionRatio(val)
  }

  function loadAlignments() {
    var raw = alignmentsFile.text() || ""
    if (!raw.trim()) {
      alignments = ({})
      return
    }
    try {
      var parsed = JSON.parse(raw)
      alignments = (parsed && typeof parsed === "object") ? parsed : ({})
    } catch (e) {
      alignments = ({})
    }
    updateCurrentAlignment()
  }

  function updateCurrentAlignment() {
    var path = currentPath()
    if (!path) {
      currentStepIndex = 2
      return
    }
    var filename = path.split("/").pop()
    var val = (alignments && (alignments[path] !== undefined ? alignments[path] : alignments[filename]))
    var ratio = parsePositionRatio(val)
    currentStepIndex = closestStepIndex(ratio)
  }

  function setStepIndex(idx) {
    if (idx < 0 || idx >= alignmentSteps.length) return
    currentStepIndex = idx
    var path = currentPath()
    if (path) {
      var filename = path.split("/").pop()
      var val = alignmentSteps[idx].val
      var next = Object.assign({}, alignments)
      next[filename] = val
      next[path] = val
      alignments = next
    }
  }

  function cycleStep(direction) {
    var count = alignmentSteps.length
    var nextIdx = (currentStepIndex + direction + count) % count
    setStepIndex(nextIdx)
  }

  function formatInterval(seconds) {
    if (!seconds || seconds <= 0) return "Off"
    if (seconds >= 3600 && seconds % 3600 === 0) return (seconds / 3600) + "h"
    if (seconds >= 60 && seconds % 60 === 0) return (seconds / 60) + "m"
    return seconds + "s"
  }

  function closestIntervalIndex(enabled, seconds) {
    if (!enabled || seconds <= 0) return 0
    var closest = 3
    var minDiff = 999999
    for (var i = 1; i < intervalSteps.length; i++) {
      var diff = Math.abs(intervalSteps[i].seconds - seconds)
      if (diff < minDiff) {
        minDiff = diff
        closest = i
      }
    }
    return closest
  }

  function loadSlideshowConfig() {
    var raw = slideshowFile.text() || ""
    if (!raw.trim()) {
      slideshowEnabled = false
      currentIntervalIndex = 0
      return
    }
    try {
      var parsed = JSON.parse(raw)
      slideshowEnabled = !!(parsed && parsed.enabled)
      if (parsed && typeof parsed.interval === "number" && parsed.interval > 0) {
        slideshowInterval = Math.max(10, parsed.interval)
      }
      currentIntervalIndex = closestIntervalIndex(slideshowEnabled, slideshowInterval)
    } catch (e) {
      slideshowEnabled = false
      currentIntervalIndex = 0
    }
  }

  function setIntervalIndex(idx) {
    if (idx < 0 || idx >= intervalSteps.length) return
    currentIntervalIndex = idx
    var item = intervalSteps[idx]
    if (item.seconds <= 0) {
      slideshowEnabled = false
    } else {
      slideshowEnabled = true
      slideshowInterval = item.seconds
    }
    slideshowDirty = true
    saveSlideshowConfig()
  }

  function cycleInterval(direction) {
    var count = intervalSteps.length
    var nextIdx = (currentIntervalIndex + direction + count) % count
    setIntervalIndex(nextIdx)
  }

  function saveSlideshowConfig() {
    var enabledStr = slideshowEnabled ? "true" : "false"
    var cmd = "mkdir -p " + Util.shellQuote(root.configDir) + "; " +
      "printf '{\\n  \"enabled\": %s,\\n  \"interval\": %d\\n}\\n' " + enabledStr + " " + root.slideshowInterval + " > " + Util.shellQuote(root.slideshowPath)
    if (saveSlideshowProc.running) {
      saveSlideshowProc.running = false
    }
    saveSlideshowProc.command = ["bash", "-c", cmd]
    saveSlideshowProc.running = true
  }

  onSelectedIndexChanged: updateCurrentAlignment()

  onOpenedChanged: {
    if (!opened) {
      layoutSettled = false
      alignMenuExpanded = false
    } else {
      alignMenuExpanded = false
      alignmentsFile.reload()
      slideshowFile.reload()
      updateCurrentAlignment()
      loadSlideshowConfig()
    }
  }

  function scriptPath(name) {
    return omarchyPath + "/shell/plugins/image-picker/" + name
  }

  function focusPicker() {
    if (root.opened && root.imagesLoaded && root.layoutSettled)
      carousel.forceActiveFocus()
  }

  function revealWhenSettled(serial) {
    Qt.callLater(function() {
      if (serial === root.requestSerial && root.opened && root.imagesLoaded && root.imageArray.length > 0) {
        root.layoutSettled = true
        root.focusPicker()
      }
    })
  }

  function currentPath() {
    if (imageArray.length === 0 || !itemMatches(selectedIndex)) return ""
    return imageArray[selectedIndex].filePath
  }

  function nameForPath(path) {
    return ImagePickerModel.nameForPath(path)
  }

  function labelForPath(path) {
    return ImagePickerModel.labelForPath(path)
  }

  function currentLabel() {
    var path = currentPath()
    if (!path) return filterText ? "No matches" : ""

    return labelForPath(path)
  }

  function itemMatches(index) {
    return ImagePickerModel.itemMatches(imageArray, index, filterText)
  }

  function firstMatchingIndex() {
    return ImagePickerModel.firstMatchingIndex(imageArray, filterText)
  }

  function filteredPosition(index) {
    return ImagePickerModel.filteredPosition(imageArray, index, filterText)
  }

  function selectedFilteredPosition() {
    return ImagePickerModel.selectedFilteredPosition(imageArray, selectedIndex, filterText)
  }

  function select(index, immediate) {
    if (imageArray.length === 0) return
    if (index < 0) index = 0
    else if (index >= imageArray.length) index = imageArray.length - 1
    if (!itemMatches(index)) return
    if (index === selectedIndex && immediate !== true) return

    selectedIndex = index
  }

  function selectAdjacent(direction) {
    var count = imageArray.length
    if (count === 0) return

    var index = selectedIndex
    for (var i = 0; i < count; i++) {
      index = (index + direction + count) % count
      if (itemMatches(index)) {
        select(index)
        return
      }
    }
  }

  function updateFilter(nextFilterText) {
    filterText = nextFilterText

    if (!itemMatches(selectedIndex)) {
      var first = ImagePickerModel.nextSelectedIndexForFilter(imageArray, selectedIndex, filterText)
      if (first >= 0) selectedIndex = first
    }
  }

  function releaseNextDoneFile() {
    if (releaseProc.running || doneFilesToRelease.length === 0) return

    var path = doneFilesToRelease.shift()
    releaseProc.command = ["bash", "-c", ": > " + Util.shellQuote(path)]
    releaseProc.running = true
  }

  function finishDoneFile(path) {
    if (!path) return
    doneFilesToRelease.push(path)
    releaseNextDoneFile()
  }

  function applySelected() {
    var path = currentPath()
    if (!path || !selectionFile) {
      cancel()
      return
    }

    var activeSelectionFile = selectionFile
    var activeDoneFile = doneFile
    applySerial = requestSerial
    requestActive = false
    selectionFile = ""
    doneFile = ""

    var saveAlignCmd = ""
    if (root.showAlignment) {
      var filename = path.split("/").pop()
      var align = root.currentAlignmentValue || "center"
      var cfg = root.alignmentsPath
      saveAlignCmd = "mkdir -p " + Util.shellQuote(root.configDir) + "; " +
        "[[ -f " + Util.shellQuote(cfg) + " ]] || echo '{}' > " + Util.shellQuote(cfg) + "; " +
        "tmp=$(mktemp) && jq --arg f " + Util.shellQuote(filename) + " --arg p " + Util.shellQuote(path) + " --arg a " + Util.shellQuote(align) + " '.[$f] = $a | .[$p] = $a' " + Util.shellQuote(cfg) + " > \"$tmp\" && mv \"$tmp\" " + Util.shellQuote(cfg) + "; "
    }

    applyProc.command = ["bash", "-c", saveAlignCmd + "printf '%s\\n' " + Util.shellQuote(path) + " > " + Util.shellQuote(activeSelectionFile) + "; : > " + Util.shellQuote(activeDoneFile)]
    applyProc.running = true
  }

  function cancel() {
    if (requestActive)
      finishDoneFile(doneFile)

    requestActive = false
    selectionFile = ""
    doneFile = ""
    root.opened = false
  }

  function closeSelector(nextDoneFile) {
    requestSerial += 1

    if (requestActive)
      finishDoneFile(doneFile)

    if (nextDoneFile && nextDoneFile !== doneFile)
      finishDoneFile(nextDoneFile)

    requestActive = false
    selectionFile = ""
    doneFile = ""
    filterText = ""
    root.opened = false
  }

  function loadRows(rows, reveal) {
    var newImages = ImagePickerModel.loadRows(rows)

    root.loadedImageRows = rows
    root.selectedIndex = root.indexForSelectedImage(newImages)
    root.imageArray = newImages
    root.imagesLoaded = true

    if (reveal !== false) {
      root.opened = true
      root.revealWhenSettled(root.requestSerial)
    }
  }

  function openSelector(nextImageDirs, nextImageRows, nextSelectedImage, nextSelectionFile, nextDoneFile, nextShowLabels, nextFilterable) {
    if (requestActive && doneFile && doneFile !== nextDoneFile)
      finishDoneFile(doneFile)

    requestSerial += 1

    imageDirs = nextImageDirs
    imageRows = nextImageRows
    selectedImage = nextSelectedImage
    selectionFile = nextSelectionFile
    doneFile = nextDoneFile
    requestActive = !!doneFile
    showLabels = nextShowLabels === true || nextShowLabels === "true"
    filterable = nextFilterable === true || nextFilterable === "true"
    filterText = ""
    layoutSettled = false

    if (imageRows && imageRows === loadedImageRows && imageArray.length > 0) {
      root.select(root.selectedImageIndex(), true)
      imagesLoaded = true
      opened = true
      root.revealWhenSettled(requestSerial)
      return
    }

    if (imageRows) {
      var rowsToLoad = imageRows
      var rowsSerial = requestSerial
      imageArray = []
      selectedIndex = 0
      imagesLoaded = true
      opened = true
      Qt.callLater(function() {
        if (rowsSerial === root.requestSerial)
          root.loadRows(rowsToLoad, true)
      })
      return
    }

    imageArray = []
    selectedIndex = 0
    imagesLoaded = false
    opened = false
    startImageScan(requestSerial, imageDirs)
  }

  property var imageArray: []

  function startImageScan(serial, dirs) {
    if (loadImagesProc.running) {
      loadImagesProc.queuedSerial = serial
      loadImagesProc.queuedDirs = dirs
      return
    }

    loadImagesProc.activeSerial = serial
    loadImagesProc.queuedSerial = 0
    loadImagesProc.queuedDirs = ""
    loadImagesProc.command = [root.scriptPath("list.sh"), dirs]
    loadImagesProc.running = true
  }

  function indexForSelectedImage(images) {
    return ImagePickerModel.indexForSelectedImage(images, selectedImage)
  }

  function selectedImageIndex() {
    return indexForSelectedImage(imageArray)
  }

  Process {
    id: loadImagesProc
    property int activeSerial: 0
    property int queuedSerial: 0
    property string queuedDirs: ""
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (loadImagesProc.activeSerial === root.requestSerial)
          root.loadRows(String(text || ""), true)
      }
    }
    onExited: {
      var serial = queuedSerial
      var dirs = queuedDirs
      activeSerial = 0
      queuedSerial = 0
      queuedDirs = ""
      if (serial > 0 && serial === root.requestSerial)
        root.startImageScan(serial, dirs)
    }
  }

  // Lifecycle hooks invoked by omarchy-shell summon/hide. shell.summon(id,
  // payloadJson) hands the JSON to open() here; shell.hide(id) calls close().
  // The shell host owns the stable `image-selector` IPC target and forwards
  // those lower-level positional calls here.
  function open(payload) {
    var args = {}
    if (payload) {
      try { args = JSON.parse(payload) || {} } catch (e) { args = {} }
    }
    var dirs = String(args.imageDirs || imageDirs)
    var rows = String(args.imageRows || "")
    var sel = String(args.selectedImage || selectedImage)
    var selFile = String(args.selectionFile || "")
    var doneF = String(args.doneFile || "")
    var labels = args.showLabels === true || args.showLabels === "true"
    var filter = args.filterable === true || args.filterable === "true"
    var align = (args.alignable !== undefined) ? (args.alignable === true || args.alignable === "true") : true
    alignable = align
    openSelector(dirs, rows, sel, selFile, doneF, labels, filter)
  }

  function close() {
    cancel()
  }

  function preloadRows(nextImageRows, nextSelectedImage, nextShowLabels, nextFilterable) {
    // Theme/background set hooks can warm selector rows after a picker was
    // dismissed. Ignore those preloads while a user-visible request is open;
    // otherwise the preload resets layoutSettled without revealing again,
    // leaving only the fullscreen scrim.
    if (opened || requestActive) return

    requestSerial += 1
    imageRows = nextImageRows
    selectedImage = nextSelectedImage
    showLabels = nextShowLabels === true || nextShowLabels === "true"
    filterable = nextFilterable === true || nextFilterable === "true"
    filterText = ""
    layoutSettled = false

    if (imageRows && imageRows === loadedImageRows && imageArray.length > 0) {
      selectedIndex = selectedImageIndex()
      imagesLoaded = true
    } else if (imageRows) {
      loadRows(imageRows, false)
    }
  }

  Process {
    id: applyProc
    onExited: {
      if (root.applySerial === root.requestSerial)
        root.opened = false
    }
  }

  Process {
    id: releaseProc
    onExited: root.releaseNextDoneFile()
  }

  PanelWindow {
    id: panel

    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-image-selector"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.opened && root.imagesLoaded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      visible: root.opened && root.imagesLoaded
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      enabled: root.opened && root.imagesLoaded
      onClicked: root.cancel()
    }

    Item {
      id: card
      visible: root.opened && root.imagesLoaded && root.layoutSettled && root.imageArray.length > 0
      width: Math.min(parent.width - 80, root.expandedWidth + 13 * (root.sliceWidth + root.sliceSpacing) + 40)
      height: root.expandedHeight + Style.space(30) + root.bottomChromeHeight
      anchors.centerIn: parent

        MouseArea { anchors.fill: parent; onClicked: {} }

        Item {
          id: carousel
          anchors.top: parent.top
          anchors.topMargin: Style.space(30)
          anchors.bottom: parent.bottom
          anchors.bottomMargin: root.bottomChromeHeight
          anchors.horizontalCenter: parent.horizontalCenter
          width: root.expandedWidth + 13 * (root.sliceWidth + root.sliceSpacing)
          clip: false
          focus: true

          readonly property real itemStep: root.sliceWidth + root.sliceSpacing
          readonly property real previewX: (width - root.expandedWidth) / 2

          Keys.priority: Keys.BeforeItem
          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
              if (root.filterText) {
                root.updateFilter("")
              } else {
                root.cancel()
              }
              event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.applySelected()
              event.accepted = true
            } else if (root.filterable && Util.editsFilter(event, root.filterText)) {
              root.updateFilter(Util.editedFilter(event, root.filterText))
              event.accepted = true
            } else if (root.showAlignment && (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) && root.alignMenuExpanded) {
              root.activeMenuTab = (root.activeMenuTab === "align" ? "transition" : "align")
              event.accepted = true
            } else if (event.key === Qt.Key_Left || (event.key === Qt.Key_Tab && event.modifiers & Qt.ShiftModifier) || event.key === Qt.Key_Backtab) {
              root.selectAdjacent(-1)
              event.accepted = true
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
              root.selectAdjacent(1)
              event.accepted = true
            } else if (event.key === Qt.Key_A) {
              if (root.showAlignment) {
                if (!root.alignMenuExpanded) {
                  root.activeMenuTab = "align"
                  root.alignMenuExpanded = true
                } else if (root.activeMenuTab === "align") {
                  root.alignMenuExpanded = false
                } else {
                  root.activeMenuTab = "align"
                }
                event.accepted = true
              }
            } else if (event.key === Qt.Key_T) {
              if (root.showAlignment) {
                if (!root.alignMenuExpanded) {
                  root.activeMenuTab = "transition"
                  root.alignMenuExpanded = true
                } else if (root.activeMenuTab === "transition") {
                  root.alignMenuExpanded = false
                } else {
                  root.activeMenuTab = "transition"
                }
                event.accepted = true
              }
            } else if (root.showAlignment && event.key === Qt.Key_Up) {
              if (!root.alignMenuExpanded) {
                root.alignMenuExpanded = true
              } else if (root.activeMenuTab === "align") {
                root.cycleStep(-1)
              } else if (root.activeMenuTab === "transition") {
                root.cycleInterval(-1)
              }
              event.accepted = true
            } else if (root.showAlignment && event.key === Qt.Key_Down) {
              if (!root.alignMenuExpanded) {
                root.alignMenuExpanded = true
              } else if (root.activeMenuTab === "align") {
                root.cycleStep(1)
              } else if (root.activeMenuTab === "transition") {
                root.cycleInterval(1)
              }
              event.accepted = true
            } else if (root.filterable && event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127 && (event.modifiers === Qt.NoModifier || event.modifiers === Qt.ShiftModifier)) {
              root.updateFilter(root.filterText + event.text)
              event.accepted = true
            }
          }

          Component.onCompleted: forceActiveFocus()

          Repeater {
            model: root.imageArray.length

            delegate: Item {
              id: item
              required property int index

              readonly property var imageData: root.imageArray[index]
              readonly property string filePath: imageData ? imageData.filePath : ""
              readonly property string fileName: imageData ? imageData.fileName : ""
              readonly property string thumbnailPath: imageData ? imageData.thumbnailPath : ""

              readonly property bool matched: root.itemMatches(index)
              readonly property int relativeIndex: root.filteredPosition(index) - root.selectedFilteredPosition()
              readonly property bool selected: matched && index === root.selectedIndex
              readonly property bool nearby: matched && Math.abs(relativeIndex) <= 16
              property bool sourceActivated: nearby
              onNearbyChanged: if (nearby) sourceActivated = true

              visible: nearby
              x: selected ? carousel.previewX : (relativeIndex < 0 ? carousel.previewX + relativeIndex * carousel.itemStep : carousel.previewX + root.expandedWidth + root.sliceSpacing + (relativeIndex - 1) * carousel.itemStep)
              width: selected ? root.expandedWidth : root.sliceWidth
              height: selected ? root.expandedHeight : root.sliceHeight
              y: selected ? 0 : (root.expandedHeight - root.sliceHeight) / 2
              z: selected ? 100 : 50 - Math.min(Math.abs(relativeIndex), 40)

              readonly property real skAbs: Math.abs(root.skewOffset)
              readonly property real topLeft: root.skewOffset >= 0 ? skAbs : 0
              readonly property real topRight: root.skewOffset >= 0 ? width : width - skAbs
              readonly property real bottomRight: root.skewOffset >= 0 ? width - skAbs : width
              readonly property real bottomLeft: root.skewOffset >= 0 ? 0 : skAbs

              Item {
                id: maskShape
                anchors.fill: parent
                visible: false
                layer.enabled: true

                Shape {
                  anchors.fill: parent
                  antialiasing: true
                  preferredRendererType: Shape.CurveRenderer
                  ShapePath {
                    fillColor: "white"
                    strokeColor: "transparent"
                    startX: item.topLeft; startY: 0
                    PathLine { x: item.topRight; y: 0 }
                    PathLine { x: item.bottomRight; y: item.height }
                    PathLine { x: item.bottomLeft; y: item.height }
                    PathLine { x: item.topLeft; y: 0 }
                  }
                }
              }

              Item {
                anchors.fill: parent
                layer.enabled: true
                layer.smooth: true
                layer.effect: MultiEffect {
                  maskEnabled: true
                  maskSource: maskShape
                  maskThresholdMin: 0.3
                  maskSpreadAtMin: 0.3
                }

                Image {
                  id: thumbnailImage
                  anchors.fill: parent
                  visible: !item.selected
                  // Load only the initial/visited nearby images, but keep the
                  // source once activated so Qt does not tear textures down as
                  // selection moves through the carousel.
                  source: item.sourceActivated && item.thumbnailPath ? Util.fileUrl(item.thumbnailPath) : ""
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: false
                  cache: true
                  smooth: true
                }

                Image {
                  id: fullImage
                  visible: item.selected
                  source: (item.selected && item.filePath)
                    ? ((typeof Util.isVideoPath === "function" ? Util.isVideoPath(item.filePath) : root.isVideo(item.filePath))
                        ? (item.thumbnailPath ? Util.fileUrl(item.thumbnailPath) : "")
                        : Util.fileUrl(item.filePath))
                    : ""
                  asynchronous: false
                  cache: true
                  smooth: true

                  readonly property real scaleFactor: (implicitWidth > 0 && implicitHeight > 0)
                    ? Math.max(parent.width / implicitWidth, parent.height / implicitHeight) : 1.0
                  width: Math.ceil(implicitWidth * scaleFactor)
                  height: Math.ceil(implicitHeight * scaleFactor)

                  readonly property real alignRatio: root.showAlignment ? root.currentPositionRatio : 0.5
                  x: Math.round(-alignRatio * Math.max(0, width - parent.width))
                  y: Math.round(-0.5 * Math.max(0, height - parent.height))
                }

                Rectangle {
                  anchors.fill: parent
                  color: Util.alpha(root.dimColor, item.selected ? 0 : 0.42)
                }
              }

              Shape {
                anchors.fill: parent
                antialiasing: true
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                  fillColor: "transparent"
                  strokeColor: item.selected ? root.selectedBorder : root.unselectedBorder
                  strokeWidth: item.selected ? 3 : 1
                  startX: item.topLeft; startY: 0
                  PathLine { x: item.topRight; y: 0 }
                  PathLine { x: item.bottomRight; y: item.height }
                  PathLine { x: item.bottomLeft; y: item.height }
                  PathLine { x: item.topLeft; y: 0 }
                }
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: item.selected ? root.applySelected() : root.select(index)
              }
            }
          }
        }

        Text {
          id: selectedLabel
          textFormat: Text.PlainText
          visible: root.showLabels
          anchors.top: carousel.bottom
          anchors.topMargin: Style.space(16)
          anchors.horizontalCenter: carousel.horizontalCenter
          width: root.expandedWidth
          text: root.currentLabel()
          color: root.foreground
          style: Text.Outline
          styleColor: Util.alpha(root.dimColor, 0.7)
          font.pixelSize: Style.font.display
          font.weight: Font.DemiBold
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
        }

        Text {
          id: filterLabel
          textFormat: Text.PlainText
          visible: root.filterable && root.filterText
          anchors.top: selectedLabel.bottom
          anchors.topMargin: Style.space(8)
          anchors.horizontalCenter: carousel.horizontalCenter
          width: root.expandedWidth
          text: root.filterText
          color: root.foreground
          opacity: 0.85
          style: Text.Outline
          styleColor: Util.alpha(root.dimColor, 0.7)
          font.pixelSize: Style.font.title
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
        }

        Item {
          id: alignmentBar
          visible: root.showAlignment
          anchors.top: carousel.top
          anchors.topMargin: root.expandedHeight
          x: Math.round(carousel.x + carousel.previewX - alignmentBar.originX)
          width: alignmentBar.topWidth + alignmentBar.originX + 10
          height: alignTab.height + (root.alignMenuExpanded ? drawerContainer.height : 0)
          z: 200

          readonly property real skAbs: Math.abs(root.skewOffset)
          readonly property real skewSlope: skAbs / root.expandedHeight
          readonly property real tabHeight: 28
          readonly property real drawerHeight: 80
          readonly property real tabSkew: skewSlope * tabHeight
          readonly property real drawerSkew: skewSlope * drawerHeight
          readonly property real totalSkew: skewSlope * (tabHeight + drawerHeight)
          readonly property real originX: Math.ceil(totalSkew) + 2
          readonly property real topWidth: root.expandedWidth - skAbs

          // Tab header docked at the bottom of the preview card, flush with the left edge
          Item {
            id: alignTab
            width: alignTab.tabWidth + alignmentBar.originX
            height: alignmentBar.tabHeight
            readonly property real tabWidth: 132
            readonly property bool hovered: alignTabMouse.containsMouse
            readonly property bool isOpen: root.alignMenuExpanded && root.activeMenuTab === "align"
            z: isOpen ? 12 : (hovered ? 11 : 10)

            Shape {
              anchors.fill: parent
              antialiasing: true
              preferredRendererType: Shape.CurveRenderer

              ShapePath {
                fillColor: alignTab.isOpen ? root.selectedBorder : (alignTab.hovered ? Util.alpha(root.selectedBorder, 0.22) : Util.alpha(root.dimColor, 0.80))
                strokeColor: root.selectedBorder
                strokeWidth: 3
                startX: alignmentBar.originX; startY: 0
                PathLine { x: alignmentBar.originX + alignTab.tabWidth; y: 0 }
                PathLine { x: alignmentBar.originX + alignTab.tabWidth - alignmentBar.tabSkew; y: alignTab.height }
                PathLine { x: alignmentBar.originX - alignmentBar.tabSkew; y: alignTab.height }
                PathLine { x: alignmentBar.originX; y: 0 }
              }
            }

            Row {
              anchors.verticalCenter: parent.verticalCenter
              x: Math.round(alignmentBar.originX + (alignTab.tabWidth - width) / 2 - (alignmentBar.tabSkew * 0.5))
              spacing: 6

              // Retro terminal brackets hotkey callout
              Text {
                textFormat: Text.PlainText
                text: "[A]"
                color: alignTab.isOpen
                  ? root.dimColor
                  : (alignTab.hovered ? root.selectedBorder : root.selectedBorder)
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                textFormat: Text.PlainText
                text: "Align"
                color: alignTab.isOpen ? root.dimColor : (alignTab.hovered ? root.selectedBorder : root.foreground)
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                textFormat: Text.PlainText
                text: alignTab.isOpen ? "▴" : "▾"
                color: alignTab.isOpen ? root.dimColor : (alignTab.hovered ? root.selectedBorder : root.foreground)
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            MouseArea {
              id: alignTabMouse
              x: alignmentBar.originX - alignmentBar.tabSkew
              y: 0
              width: alignTab.tabWidth + alignmentBar.tabSkew
              height: alignTab.height
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (!root.alignMenuExpanded) {
                  root.activeMenuTab = "align"
                  root.alignMenuExpanded = true
                } else if (root.activeMenuTab === "align") {
                  root.alignMenuExpanded = false
                } else {
                  root.activeMenuTab = "align"
                }
              }
            }
          }

          // Tab 2: Transition docked at the bottom of the preview card, flush against Align sharing the same border
          Item {
            id: transitionTab
            x: alignmentBar.originX + alignTab.tabWidth
            y: 0
            width: transitionTab.tabWidth
            height: alignmentBar.tabHeight
            readonly property real tabWidth: 160
            readonly property bool hovered: transitionTabMouse.containsMouse
            readonly property bool isOpen: root.alignMenuExpanded && root.activeMenuTab === "transition"
            z: isOpen ? 12 : (hovered ? 11 : 10)

            Shape {
              anchors.fill: parent
              antialiasing: true
              preferredRendererType: Shape.CurveRenderer

              ShapePath {
                fillColor: transitionTab.isOpen ? root.selectedBorder : (transitionTab.hovered ? Util.alpha(root.selectedBorder, 0.22) : Util.alpha(root.dimColor, 0.80))
                strokeColor: root.selectedBorder
                strokeWidth: 3
                startX: 0; startY: 0
                PathLine { x: transitionTab.tabWidth; y: 0 }
                PathLine { x: transitionTab.tabWidth - alignmentBar.tabSkew; y: transitionTab.height }
                PathLine { x: -alignmentBar.tabSkew; y: transitionTab.height }
                PathLine { x: 0; y: 0 }
              }
            }

            Row {
              anchors.verticalCenter: parent.verticalCenter
              x: Math.round((transitionTab.tabWidth - width) / 2 - (alignmentBar.tabSkew * 0.5))
              spacing: 6

              // Retro terminal brackets hotkey callout
              Text {
                textFormat: Text.PlainText
                text: "[T]"
                color: transitionTab.isOpen
                  ? root.dimColor
                  : (transitionTab.hovered ? root.selectedBorder : root.selectedBorder)
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                textFormat: Text.PlainText
                text: "Transition"
                color: transitionTab.isOpen ? root.dimColor : (transitionTab.hovered ? root.selectedBorder : root.foreground)
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                textFormat: Text.PlainText
                text: transitionTab.isOpen ? "▴" : "▾"
                color: transitionTab.isOpen ? root.dimColor : (transitionTab.hovered ? root.selectedBorder : root.foreground)
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            MouseArea {
              id: transitionTabMouse
              x: 0
              y: 0
              width: transitionTab.tabWidth
              height: transitionTab.height
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (!root.alignMenuExpanded) {
                  root.activeMenuTab = "transition"
                  root.alignMenuExpanded = true
                } else if (root.activeMenuTab === "transition") {
                  root.alignMenuExpanded = false
                } else {
                  root.activeMenuTab = "transition"
                }
              }
            }
          }

          // Status shelf showing background file name, alignment setting, and set transition time
          Item {
            id: statusShelf
            x: alignmentBar.originX + alignTab.tabWidth + transitionTab.tabWidth
            y: 0
            width: Math.max(0, alignmentBar.topWidth - (alignTab.tabWidth + transitionTab.tabWidth))
            height: alignmentBar.tabHeight
            z: 10

            Shape {
              anchors.fill: parent
              antialiasing: true
              preferredRendererType: Shape.CurveRenderer

              ShapePath {
                fillColor: Util.alpha(root.dimColor, 0.80)
                strokeColor: root.selectedBorder
                strokeWidth: 3
                startX: 0; startY: 0
                PathLine { x: statusShelf.width; y: 0 }
                PathLine { x: statusShelf.width - alignmentBar.tabSkew; y: statusShelf.height }
                PathLine { x: -alignmentBar.tabSkew; y: statusShelf.height }
                PathLine { x: 0; y: 0 }
              }
            }

            // Wallpaper name and settings callouts
            Row {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: 16
              anchors.right: parent.right
              anchors.rightMargin: 16 + Math.ceil(alignmentBar.tabSkew)
              spacing: 10

              // Wallpaper index counter
              Text {
                textFormat: Text.PlainText
                text: "[" + (root.selectedIndex + 1) + "/" + root.imageArray.length + "]"
                color: root.selectedBorder
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
              }

              // Wallpaper name
              Text {
                textFormat: Text.PlainText
                text: root.currentLabel()
                color: root.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.weight: Font.Bold
                elide: Text.ElideRight
                width: Math.min(implicitWidth, Math.max(80, statusShelf.width - 240))
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                textFormat: Text.PlainText
                text: "•"
                color: Util.alpha(root.foreground, 0.4)
                font.pixelSize: Style.font.bodySmall
                anchors.verticalCenter: parent.verticalCenter
              }

              // Alignment setting callout
              Row {
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter

                Text {
                  textFormat: Text.PlainText
                  text: "Align:"
                  color: Util.alpha(root.foreground, 0.7)
                  font.family: Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  font.weight: Font.Medium
                  anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                  textFormat: Text.PlainText
                  text: (root.currentStepIndex >= 0 && root.currentStepIndex < root.alignmentSteps.length) ? root.alignmentSteps[root.currentStepIndex].label : "Center"
                  color: root.selectedBorder
                  font.family: Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  font.weight: Font.Bold
                  anchors.verticalCenter: parent.verticalCenter
                }
              }

              Text {
                textFormat: Text.PlainText
                text: "•"
                color: Util.alpha(root.foreground, 0.4)
                font.pixelSize: Style.font.bodySmall
                anchors.verticalCenter: parent.verticalCenter
              }

              // Set transition time callout
              Row {
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter

                Text {
                  textFormat: Text.PlainText
                  text: "Transition:"
                  color: Util.alpha(root.foreground, 0.7)
                  font.family: Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  font.weight: Font.Medium
                  anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                  textFormat: Text.PlainText
                  text: root.slideshowEnabled ? root.formatInterval(root.slideshowInterval) : "Off"
                  color: root.selectedBorder
                  font.family: Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  font.weight: Font.Bold
                  anchors.verticalCenter: parent.verticalCenter
                }
              }
            }
          }

          // Slide-down drawer containing alignment and transition options
          Item {
            id: drawerContainer
            anchors.top: alignTab.bottom
            anchors.topMargin: -1.5
            x: 0
            width: alignmentBar.width
            height: root.alignMenuExpanded ? alignmentBar.drawerHeight : 0
            clip: true
            z: 5

            Behavior on height {
              NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }

            Item {
              id: drawerContent
              width: drawerContainer.width
              height: alignmentBar.drawerHeight
              y: drawerContainer.height - height

              MouseArea {
                anchors.fill: parent
                onClicked: {}
              }

              Shape {
                anchors.fill: parent
                antialiasing: true
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                  fillColor: Util.alpha(root.dimColor, 0.80)
                  strokeColor: root.selectedBorder
                  strokeWidth: 3
                  startX: alignmentBar.originX - alignmentBar.tabSkew - (1.5 * alignmentBar.skewSlope); startY: 1.5
                  PathLine { x: alignmentBar.originX + alignmentBar.topWidth - alignmentBar.tabSkew - (1.5 * alignmentBar.skewSlope); y: 1.5 }
                  PathLine { x: alignmentBar.originX + alignmentBar.topWidth - alignmentBar.totalSkew + (1.5 * alignmentBar.skewSlope); y: drawerContent.height - 1.5 }
                  PathLine { x: alignmentBar.originX - alignmentBar.totalSkew + (1.5 * alignmentBar.skewSlope); y: drawerContent.height - 1.5 }
                  PathLine { x: alignmentBar.originX - alignmentBar.tabSkew - (1.5 * alignmentBar.skewSlope); y: 1.5 }
                }
              }

              Row {
                id: buttonsRow
                visible: root.activeMenuTab === "align"
                anchors.top: parent.top
                anchors.topMargin: 12
                x: Math.round(alignmentBar.originX + (alignmentBar.topWidth - width) / 2 - alignmentBar.tabSkew - (alignmentBar.drawerSkew * 0.5))
                spacing: 8

                Repeater {
                  model: root.alignmentSteps

                  delegate: Item {
                    id: btnItem
                    required property int index
                    required property var modelData
                    readonly property bool active: root.currentStepIndex === index
                    readonly property bool hovered: mouseArea.containsMouse

                    width: 130
                    height: 34
                    readonly property real btnSkew: 7

                    Shape {
                      anchors.fill: parent
                      antialiasing: true
                      preferredRendererType: Shape.GeometryRenderer

                      ShapePath {
                        fillColor: btnItem.active ? root.selectedBorder : (btnItem.hovered ? Util.alpha(root.selectedBorder, 0.22) : Util.alpha(root.dimColor, 0.72))
                        strokeColor: btnItem.active ? root.selectedBorder : (btnItem.hovered ? Util.alpha(root.selectedBorder, 0.7) : Util.alpha(root.unselectedBorder, 0.5))
                        strokeWidth: btnItem.active ? 2 : (btnItem.hovered ? 1.5 : 1)
                        startX: btnItem.btnSkew; startY: 0
                        PathLine { x: btnItem.width; y: 0 }
                        PathLine { x: btnItem.width - btnItem.btnSkew; y: btnItem.height }
                        PathLine { x: 0; y: btnItem.height }
                        PathLine { x: btnItem.btnSkew; y: 0 }
                      }
                    }

                    Row {
                      anchors.centerIn: parent
                      spacing: 4

                      Text {
                        textFormat: Text.PlainText
                        text: modelData.icon
                        font.family: "Symbols Nerd Font Mono"
                        color: btnItem.active ? root.dimColor : (btnItem.hovered ? root.selectedBorder : root.foreground)
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                      }

                      Text {
                        textFormat: Text.PlainText
                        text: modelData.label
                        color: btnItem.active ? root.dimColor : (btnItem.hovered ? root.selectedBorder : root.foreground)
                        font.pixelSize: 11
                        font.weight: (btnItem.active || btnItem.hovered) ? Font.Bold : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                      }

                      Text {
                        textFormat: Text.PlainText
                        text: "(" + modelData.sub + ")"
                        color: btnItem.active ? root.dimColor : (btnItem.hovered ? root.selectedBorder : root.foreground)
                        opacity: btnItem.active ? 0.9 : (btnItem.hovered ? 0.85 : 0.65)
                        font.pixelSize: 9
                        anchors.verticalCenter: parent.verticalCenter
                      }
                    }

                    MouseArea {
                      id: mouseArea
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: root.setStepIndex(index)
                    }
                  }
                }
              }

              Row {
                id: intervalRow
                visible: root.activeMenuTab === "transition"
                anchors.top: parent.top
                anchors.topMargin: 12
                x: Math.round(alignmentBar.originX + (alignmentBar.topWidth - width) / 2 - alignmentBar.tabSkew - (alignmentBar.drawerSkew * 0.5))
                spacing: 8

                Repeater {
                  model: root.intervalSteps

                  delegate: Item {
                    id: intervalItem
                    required property int index
                    required property var modelData
                    readonly property bool active: root.currentIntervalIndex === index
                    readonly property bool hovered: intervalMouse.containsMouse

                    width: 110
                    height: 34
                    readonly property real btnSkew: 7

                    Shape {
                      anchors.fill: parent
                      antialiasing: true
                      preferredRendererType: Shape.GeometryRenderer

                      ShapePath {
                        fillColor: intervalItem.active ? root.selectedBorder : (intervalItem.hovered ? Util.alpha(root.selectedBorder, 0.22) : Util.alpha(root.dimColor, 0.72))
                        strokeColor: intervalItem.active ? root.selectedBorder : (intervalItem.hovered ? Util.alpha(root.selectedBorder, 0.7) : Util.alpha(root.unselectedBorder, 0.5))
                        strokeWidth: intervalItem.active ? 2 : (intervalItem.hovered ? 1.5 : 1)
                        startX: intervalItem.btnSkew; startY: 0
                        PathLine { x: intervalItem.width; y: 0 }
                        PathLine { x: intervalItem.width - intervalItem.btnSkew; y: intervalItem.height }
                        PathLine { x: 0; y: intervalItem.height }
                        PathLine { x: intervalItem.btnSkew; y: 0 }
                      }
                    }

                    Row {
                      anchors.centerIn: parent
                      spacing: 4

                      Text {
                        textFormat: Text.PlainText
                        text: modelData.icon
                        font.family: "Symbols Nerd Font Mono"
                        color: intervalItem.active ? root.dimColor : (intervalItem.hovered ? root.selectedBorder : root.foreground)
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                      }

                      Text {
                        textFormat: Text.PlainText
                        text: modelData.label
                        color: intervalItem.active ? root.dimColor : (intervalItem.hovered ? root.selectedBorder : root.foreground)
                        font.pixelSize: 11
                        font.weight: (intervalItem.active || intervalItem.hovered) ? Font.Bold : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                      }

                      Text {
                        textFormat: Text.PlainText
                        text: "(" + modelData.sub + ")"
                        color: intervalItem.active ? root.dimColor : (intervalItem.hovered ? root.selectedBorder : root.foreground)
                        opacity: intervalItem.active ? 0.9 : (intervalItem.hovered ? 0.85 : 0.65)
                        font.pixelSize: 9
                        anchors.verticalCenter: parent.verticalCenter
                      }
                    }

                    MouseArea {
                      id: intervalMouse
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: root.setIntervalIndex(index)
                    }
                  }
                }
              }

              Text {
                textFormat: Text.PlainText
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                x: Math.round(alignmentBar.originX + (alignmentBar.topWidth - width) / 2 - alignmentBar.tabSkew - alignmentBar.drawerSkew)
                text: root.activeMenuTab === "align"
                  ? "Use ↑ / ↓ to step position • Enter to apply"
                  : "Use ↑ / ↓ to change interval • Enter to apply"
                color: root.foreground
                opacity: 0.75
                font.pixelSize: 11
                font.weight: Font.Medium
              }
            }
          }
        }
    }
  }
}
