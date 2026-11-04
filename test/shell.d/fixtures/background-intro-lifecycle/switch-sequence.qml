import QtQuick
import Quickshell
import Quickshell.Io
import "services"

// Drives BackgroundSwitch through a background change into an intro, an
// ordinary one, one made while an intro plays, and a theme switch's handover.
// The fake owe logs every call to SWITCH_LOG for the test to read afterwards.
ShellRoot {
  id: test
  property bool failed: false
  property var services: ({})
  property string snapshotSeen: ""
  readonly property string stage: Quickshell.env("SWITCH_STAGE")
  readonly property string link: Quickshell.env("HOME") + "/.local/state/omarchy/current/background"
  function firstPartyServiceFor(id) { return services[id] || null }
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  QtObject {
    id: background
    property bool suspended: false
    property bool ready: true
    property string currentBackground: test.stage + "/old.png"
    property string displayedBackground: test.stage + "/old.png"
    property var nativeSizes: ({})
    property var sets: []
    // Whether OWE had been asked to play when the shell took the still.
    property bool setAfterIntro: false
    function setBackground(path, instant) {
      logView.reload()
      if (logView.text().indexOf("owe intro --start") !== -1 && sets.length === 0) setAfterIntro = true
      sets = sets.concat([path + (instant ? " instant" : " transition")])
      currentBackground = path
      displayedBackground = path
    }
  }
  FileView { id: logView; path: Quickshell.env("SWITCH_LOG"); blockLoading: true; printErrors: false }

  BackgroundIntro { id: intro; host: test }
  BackgroundSwitch { id: sw; intro: intro }

  Process { id: readLink; command: ["readlink", test.link]; stdout: StdioCollector { id: linkOut } }
  function linkTarget() { return String(linkOut.text || "").trim() }

  // Observe each handoff before issuing the next change: a slow image decode
  // must not accidentally turn an ordinary change into a queued selection.
  readonly property var steps: [
    { delay: 100, run: function() {
      test.services = ({ "omarchy.background": background })
      test.check(sw.switchTo(test.stage + "/new.png", test.stage + "/intros/new.mp4") === "ok", "a background with an intro is accepted")
    } },
    { until: function() { return intro.themeCoverStatus(sw.token) !== "loading" },
      waitFor: "the outgoing still to be presented", run: function() {
      test.check(intro.themeToken !== "" && intro.themeBackground === test.stage + "/old.png",
                 "the displayed still covers the desktop while the intro starts")
    } },
    { until: function() { return intro.themeToken === "" && !intro.revealing },
      waitFor: "the first intro and its reveal to finish", run: function() {
      test.check(background.sets.length === 1 && background.sets[0] === test.stage + "/new.png instant",
                 "the shell takes the new still instantly under the cover: " + background.sets)
      test.check(!background.setAfterIntro, "the new still is in place before the intro plays")
      test.check(intro.themeToken === "", "the cover is released once the intro ends")
      readLink.running = true
    } },
    { until: function() { return test.linkTarget() !== "" },
      waitFor: "the selected background link", run: function() {
      test.check(test.linkTarget() === test.stage + "/new.png", "the link names the background with an intro")
      background.sets = []
      sw.switchTo(test.stage + "/plain.png", "")
    } },
    { until: function() { return background.sets.length > 0 },
      waitFor: "the ordinary still change", run: function() {
      test.check(background.sets.length === 1 && background.sets[0] === test.stage + "/plain.png transition",
                 "a still without an intro takes the ordinary transition: " + background.sets)
      test.check(intro.themeToken === "" && intro.themeBackground === "", "an ordinary change raises no cover")
      // An intro plays: OWE has the shell's background hidden.
      background.sets = []
      background.suspended = true
      sw.switchTo(test.stage + "/other.png", "")
    } },
    { until: function() { return background.sets.length > 0 && intro.themeToken !== "" },
      waitFor: "the snapshot and the still beneath its cover", run: function() {
      test.check(intro.themeToken !== "" && intro.themeBackground.indexOf("/background-transitions/") !== -1,
                 "a change during an intro covers the desktop with the playing frame: " + intro.themeBackground)
      test.check(background.sets.length === 1 && background.sets[0] === test.stage + "/other.png instant",
                 "the still without an intro goes in under the cover: " + background.sets)
      test.check(intro.themeToken !== "", "the cover waits for OWE to hand the desktop back")
      test.snapshotSeen = intro.themeBackground
      // OWE sees the link move, ends the intro and hands the desktop back.
      background.suspended = false
    } },
    { until: function() { return intro.themeCutProgress > 0 },
      waitFor: "the cover cut to start", run: function() {
      test.check(intro.themeCut && intro.themeCutProgress > 0, "the cover opens with the ordinary cut")
    } },
    { until: function() { return intro.themeBackground === "" && !intro.revealing },
      waitFor: "the cover cut to finish", run: function() {
      test.check(intro.themeBackground === "" && !intro.revealing, "the cut has finished")
      // A theme switch hands over the clip it prepared while its templates rendered.
      intro.prepareTheme(test.stage + "/other.png", "theme-1", "", "")
      test.check(sw.play("theme-1", test.stage + "/new.png", test.stage + "/intros/new.mp4", "true") === "ok",
                 "a theme switch hands its intro over")
    } },
    { until: function() { return intro.themeToken === "" && !intro.revealing && !sw.reloadPending },
      waitFor: "the theme intro, reveal and reload", run: function() {
      test.check(intro.themeToken === "" && !sw.reloadPending, "the theme switch has revealed and reloaded")
      console.log("SNAPSHOT " + test.snapshotSeen)
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    } }
  ]
  StepSequence { steps: test.steps }
}
