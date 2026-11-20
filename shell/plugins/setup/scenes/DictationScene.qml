import QtQuick
import qs.Commons
import qs.Commons as Commons

// Dictation: while Right Alt is held, a voice on the left is listened to, on
// this machine or in the cloud, and comes out as words in the window on the
// right. It stops when the speaking does.
Desk {
  id: root

  // Where the backend being shown listens: "device", "cloud", or "" for one
  // that says neither.
  property string place: ""
  // Whether dictation is being set up, or left for later.
  property bool listening: true

  // One sentence: spoken, written down, and held a moment before the next.
  property real turn: Style.reduceMotion ? 0.5 : 0

  // How loud the voice is: up as speaking starts, down as it ends.
  readonly property real voice: listening ? Util.clamp((turn - 0.04) / 0.05, 0, 1) * Util.clamp((0.6 - turn) / 0.05, 0, 1) : 0
  // How many of the words have been written.
  readonly property int written: listening ? Math.floor(Util.clamp((turn - 0.1) / 0.52, 0, 1) * words.length) : 0
  readonly property real presence: 1 - Util.clamp((turn - 0.93) / 0.07, 0, 1)
  // The sentence, as the length of each word across three lines.
  readonly property var words: [0.2, 0.32, 0.14, 0.24, 0.3, 0.18, 0.26, 0.12, 0.28]
  // What both Alt keys say, in every language the catalogs are written in.
  readonly property string altKey: "Alt"

  NumberAnimation on turn {
    from: 0
    to: 1
    duration: Style.duration(4600)
    loops: Animation.Infinite
    running: root.visible && root.listening && !Style.reduceMotion
  }

  Item {
    id: speaker
    width: parent.width * 0.4
    height: parent.height
    anchors.left: parent.left

    Text {
      id: microphone
      textFormat: Text.PlainText
      text: "\u{f130}"
      color: Util.alpha(root.foreground, root.voice > 0 ? 1 : 0.5)
      font.family: Style.font.menuFamily
      font.pixelSize: Math.min(Style.space(30), parent.height * 0.2)
      horizontalAlignment: Text.AlignHCenter
      width: Style.space(46)
      x: (parent.width - width - wave.width) / 2
      y: parent.height * 0.4 - height / 2
    }

    Row {
      id: wave
      anchors.left: microphone.right
      anchors.verticalCenter: microphone.verticalCenter
      spacing: Style.space(3)

      Repeater {
        model: 18

        Rectangle {
          required property int index
          // Taller in the middle of the wave than at its ends, as speech is.
          readonly property real swell: Math.sin(Math.PI * (index + 0.5) / 18)
          readonly property real beat: 0.3 + 0.7 * Math.abs(Math.sin(root.turn * Math.PI * 22 + index * 0.9))

          width: Style.space(3)
          height: Style.space(3) + root.voice * swell * beat * speaker.height * 0.36
          anchors.verticalCenter: parent.verticalCenter
          color: Util.alpha(root.accent, 0.35 + 0.55 * root.voice)
        }
      }
    }

    // The bottom of a keyboard: Right Alt is held for as long as the speaking lasts.
    Row {
      visible: speaker.height > Style.space(120)
      anchors.horizontalCenter: parent.horizontalCenter
      y: parent.height * 0.74 - height / 2
      spacing: Style.space(4)

      Keycap {
        legend: root.altKey
        foreground: root.foreground
        accent: root.accent
      }

      Keycap {
        width: Style.space(96)
        foreground: root.foreground
        accent: root.accent
      }

      Keycap {
        legend: root.altKey
        held: root.voice > 0
        foreground: root.foreground
        accent: root.accent
      }
    }
  }

  // The way the voice goes: to whatever listens, and on to the window.
  Way {
    x: speaker.width - Style.space(18)
    y: parent.height * 0.4 - height / 2
    width: page.x - x - Style.space(8)
    foreground: root.foreground
    accent: root.accent
  }

  // Where the listening is done: a chip in this machine, or the cloud.
  Tile {
    visible: root.place !== ""
    width: Style.space(46)
    height: Style.space(38)
    x: parent.width * 0.47 - width / 2
    y: parent.height * 0.4 - height / 2
    glyph: root.place === "cloud" ? "\u{f0c2}" : "\u{f035b}"
    lit: root.voice > 0
    foreground: root.foreground
    accent: root.accent
  }

  Win {
    id: page
    anchors.left: parent.left
    anchors.leftMargin: parent.width * 0.56
    anchors.right: parent.right
    anchors.rightMargin: root.gap / 2
    y: parent.height * 0.4 - height * 0.4
    height: parent.height * 0.76
    active: root.listening
    lines: false
    foreground: root.foreground
    accent: root.accent

    Flow {
      opacity: root.presence
      anchors.fill: parent
      anchors.margins: Style.space(12)
      spacing: Style.space(6)

      Repeater {
        model: root.words

        Rectangle {
          required property int index
          required property real modelData
          width: parent.width * modelData
          height: Style.space(5)
          color: Util.alpha(root.foreground, 0.34)
          opacity: index < root.written ? 1 : 0
        }
      }
    }
  }
}
