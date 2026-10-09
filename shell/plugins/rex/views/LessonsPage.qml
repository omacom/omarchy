import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../components"
import "../lib/Lessons.js" as Lessons
import "../lib/Flavors.js" as Flavors
import "../lib/Parser.js" as Parser
import "../lib/Explain.js" as Explain
import "../lib/Tests.js" as Tests

// The course: lessons down the side, the current one's explanation, an
// example to open on the workbench, and exercises checked on the real
// engine as you type.
Item {
  id: root

  property var app

  readonly property color foreground: app.foreground
  readonly property color accent: app.accent
  readonly property color dim: Qt.darker(foreground, 1.5)

  property string current: Lessons.LESSONS[0].id
  readonly property var lesson: Lessons.byId(current)
  property int exercise: 0
  readonly property var task: lesson.exercises[Math.min(exercise, lesson.exercises.length - 1)]
  readonly property string taskFlavor: task.flavor && app.engine.supports(task.flavor) ? task.flavor : "pcre2"
  readonly property var taskFlags: (task.flags || []).concat(taskFlavor === "pcre2" ? ["u"] : [])
  property string answer: ""
  property var results: []
  property bool showHint: false
  property bool showSolution: false
  readonly property bool solved: results.length > 0 && results.every(function(r) { return r && r.pass })
  readonly property var answerParsed: Parser.parse(answer, taskFlavor, taskFlags)

  // Pick up where the learner left off.
  Component.onCompleted: {
    for (var i = 0; i < Lessons.LESSONS.length; i++) {
      if (!Lessons.complete(app.lessonProgress, Lessons.LESSONS[i])) { current = Lessons.LESSONS[i].id; break }
    }
    Qt.callLater(function() { answerField.focusEditor() })
  }

  function open(id) {
    current = id
    exercise = 0
    reset()
  }

  function reset() {
    checkSerial++
    answer = ""
    results = []
    showHint = false
    showSolution = false
    Qt.callLater(function() { answerField.focusEditor() })
  }

  onVisibleChanged: if (visible) Qt.callLater(function() { answerField.focusEditor() })

  // A check answers for the lesson, exercise, and answer it was started
  // with; one that comes back after any of them changed is dropped.
  property int checkSerial: 0

  function check() {
    var serial = ++checkSerial
    var lessonId = current, exerciseIndex = exercise
    runner.run("lesson", answer, taskFlavor, taskFlags, task.tests, function(r) {
      if (serial !== root.checkSerial) return
      root.results = r
      if (r.length && r.every(function(x) { return x && x.pass })) root.app.markLessonDone(lessonId, exerciseIndex)
    })
  }

  function next() {
    if (exercise + 1 < lesson.exercises.length) {
      exercise++
      reset()
      return
    }
    var at = Lessons.index(current)
    if (at + 1 < Lessons.LESSONS.length) open(Lessons.LESSONS[at + 1].id)
  }

  onAnswerChanged: checkTimer.restart()
  Timer { id: checkTimer; interval: 200; onTriggered: if (root.answer !== "") root.check(); else root.results = [] }

  TestRunner {
    id: runner
    engine: root.app.engine
    channel: "lessons"
  }

  RowLayout {
    anchors.fill: parent
    spacing: 0

    // ---- the course ----
    ListView {
      id: course
      Layout.preferredWidth: Math.min(Style.space(260), root.width * 0.3)
      Layout.fillHeight: true
      Layout.margins: Style.spacing.lg
      clip: true
      model: Lessons.LESSONS
      spacing: Style.spacing.xxs
      boundsBehavior: Flickable.StopAtBounds
      ScrollBar.vertical: ScrollBar {}
      section.property: "level"
      section.delegate: Text {
        required property string section
        topPadding: Style.spacing.lg
        bottomPadding: Style.spacing.xs
        text: Lessons.LEVELS[parseInt(section, 10)]
        textFormat: Text.PlainText
        color: root.accent
        font.family: Style.font.family
        font.pixelSize: Style.font.bodySmall
        font.bold: true
      }

      delegate: Rectangle {
        id: entry
        required property int index
        required property var modelData
        readonly property bool done: Lessons.complete(root.app.lessonProgress, modelData)
        width: course.width - Style.spacing.md
        height: label.implicitHeight + Style.spacing.sm * 2
        radius: Style.cornerRadius
        color: root.current === modelData.id ? Util.alpha(root.accent, 0.15) : (mouse.containsMouse ? Util.alpha(root.foreground, 0.05) : "transparent")

        MouseArea {
          id: mouse
          anchors.fill: parent
          hoverEnabled: true
          onClicked: root.open(entry.modelData.id)
        }

        Text {
          id: label
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.margins: Style.spacing.sm
          text: (entry.done ? "✓ " : "") + (entry.index + 1) + ". " + entry.modelData.title
          textFormat: Text.PlainText
          color: entry.done ? root.accent : root.foreground
          elide: Text.ElideRight
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }
      }
    }

    Rectangle {
      Layout.fillHeight: true
      Layout.preferredWidth: 1
      color: Util.alpha(root.foreground, 0.08)
    }

    // ---- the lesson ----
    Flickable {
      id: page
      Layout.fillWidth: true
      Layout.fillHeight: true
      contentHeight: body.implicitHeight + Style.spacing.panelPadding * 2
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      ScrollBar.vertical: ScrollBar {}

      ColumnLayout {
        id: body
        x: Style.spacing.panelPadding
        y: Style.spacing.panelPadding
        width: page.width - Style.spacing.panelPadding * 2
        spacing: Style.spacing.lg

        Text {
          text: Lessons.LEVELS[root.lesson.level] + " · lesson " + (Lessons.index(root.current) + 1) + " of " + Lessons.LESSONS.length
          textFormat: Text.PlainText
          color: root.dim
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }

        Text {
          Layout.fillWidth: true
          text: root.lesson.title
          textFormat: Text.PlainText
          color: root.foreground
          wrapMode: Text.Wrap
          font.family: Style.font.family
          font.pixelSize: Style.font.display
          font.bold: true
        }

        Text {
          Layout.fillWidth: true
          text: root.lesson.body
          color: root.foreground
          wrapMode: Text.Wrap
          lineHeight: 1.25
          font.family: Style.font.family
          font.pixelSize: Style.font.subtitle
          textFormat: Text.PlainText
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.md

          Rectangle {
            Layout.fillWidth: true
            implicitHeight: exampleText.implicitHeight + Style.spacing.md * 2
            radius: Style.cornerRadius
            color: Util.alpha(root.foreground, 0.05)

            Text {
              id: exampleText
              anchors.fill: parent
              anchors.margins: Style.spacing.md
              text: root.lesson.example.pattern + "   on   " + JSON.stringify(root.lesson.example.text)
              color: root.foreground
              elide: Text.ElideRight
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              textFormat: Text.PlainText
            }
          }

          Button {
            text: "Try it"
            tooltipText: "Open the example on the workbench"
            bordered: true
            onClicked: {
              var ex = root.lesson.example
              root.app.setFlavor(ex.flavor && root.app.engine.supports(ex.flavor) ? ex.flavor : "pcre2")
              root.app.pattern = ex.pattern
              root.app.setTypedText(ex.text)
              root.app.sideTab = "explain"
              root.app.showPage("workbench")
            }
          }
        }

        // ---- the exercise ----
        Rectangle {
          Layout.fillWidth: true
          Layout.topMargin: Style.spacing.lg
          implicitHeight: exerciseBody.implicitHeight + Style.spacing.lg * 2
          radius: Style.cornerRadius
          color: Util.alpha(root.foreground, 0.03)
          border.width: 1
          border.color: root.solved ? Util.alpha(root.accent, 0.6) : Util.alpha(root.foreground, 0.1)

          ColumnLayout {
            id: exerciseBody
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Style.spacing.lg
            spacing: Style.spacing.md

            Text {
              text: "Exercise " + (root.exercise + 1) + " of " + root.lesson.exercises.length + " · " + Flavors.byId(root.taskFlavor).name + (root.task.flags && root.task.flags.length ? " · flags " + root.task.flags.join("") : "")
              textFormat: Text.PlainText
              color: root.dim
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }

            Text {
              Layout.fillWidth: true
              text: root.task.prompt
              color: root.foreground
              wrapMode: Text.Wrap
              font.family: Style.font.family
              font.pixelSize: Style.font.subtitle
              font.bold: true
              textFormat: Text.PlainText
            }

            PatternEditor {
              id: answerField
              Layout.fillWidth: true
              foreground: root.foreground
              accent: root.accent
              placeholder: "Your pattern"
              text: root.answer
              tokens: Explain.tokens(root.answerParsed)
              errors: root.answerParsed.errors
              groupColors: root.app.groupColors
              kindColors: root.app.kindColors
              multiline: (root.task.flags || []).indexOf("x") >= 0
              onEdited: function(value) { root.answer = value }
            }

            Repeater {
              model: root.task.tests

              RowLayout {
                required property int index
                required property var modelData
                readonly property var outcome: root.results[index]
                Layout.fillWidth: true
                spacing: Style.spacing.md

                Text {
                  text: !outcome ? "·" : (outcome.pass ? "✓" : "✗")
                  textFormat: Text.PlainText
                  color: !outcome ? root.dim : (outcome.pass ? root.accent : Commons.Color.urgent)
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  font.bold: true
                }

                Text {
                  Layout.fillWidth: true
                  text: JSON.stringify(modelData.text) + " " + Tests.describe(modelData) + (outcome && !outcome.pass ? " — " + outcome.detail : "")
                  color: root.foreground
                  elide: Text.ElideRight
                  font.family: Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  textFormat: Text.PlainText
                }
              }
            }

            RowLayout {
              Layout.fillWidth: true
              spacing: Style.spacing.md

              Button {
                text: "Hint"
                bordered: true
                selected: root.showHint
                onClicked: root.showHint = !root.showHint
              }

              Button {
                text: "Show a solution"
                bordered: true
                selected: root.showSolution
                onClicked: root.showSolution = !root.showSolution
              }

              Text {
                Layout.fillWidth: true
                visible: root.solved
                text: "Solved!"
                color: root.accent
                horizontalAlignment: Text.AlignRight
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                font.bold: true
              }

              Button {
                text: root.exercise + 1 < root.lesson.exercises.length ? "Next exercise" : "Next lesson"
                bordered: true
                visible: root.solved
                onClicked: root.next()
              }
            }

            Text {
              Layout.fillWidth: true
              visible: root.showHint
              text: root.task.hint
              color: root.dim
              wrapMode: Text.Wrap
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              textFormat: Text.PlainText
            }

            Text {
              Layout.fillWidth: true
              visible: root.showSolution
              text: root.task.solution + "   (one of many)"
              color: root.accent
              wrapMode: Text.Wrap
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              textFormat: Text.PlainText
            }
          }
        }
      }
    }
  }
}
