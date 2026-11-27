import QtQuick
import qs.Commons
import qs.Commons as Commons

// Dictation: while Right Alt is held, organic multi-harmonic speech flows
// through the on-device chip or cloud engine into the focused window with a
// live typing caret. Even before a backend is picked, the diagram rests whole.
Desk {
  id: root

  // Where the backend listens: "device", "cloud", or "" for neutral idle.
  property string place: ""
  property bool listening: true

  property real turn: Style.reduceMotion ? 0.42 : 0

  // Smooth speech gate (0.04..0.68) modulated by a natural 3-phrase syllable
  // cadence so the waveform swells, breathes between words, and settles cleanly.
  readonly property real speechGate: listening
    ? Util.clamp((turn - 0.04) / 0.06, 0, 1) * Util.clamp((0.68 - turn) / 0.08, 0, 1)
    : 0
  readonly property real phraseCadence: 0.42 + 0.58 * (0.5 + 0.5 * Math.sin(turn * Math.PI * 8.0 - 0.6))
    * (0.65 + 0.35 * Math.cos(turn * Math.PI * 14.0 + 0.9))
  readonly property real voice: speechGate * phraseCadence
  readonly property int written: listening ? Math.floor(Util.clamp((turn - 0.1) / 0.56, 0, 1) * words.length) : 0
  readonly property real presence: listening ? 1 - Util.clamp((turn - 0.91) / 0.09, 0, 1) : 1
  readonly property var words: [0.22, 0.3, 0.16, 0.24, 0.32, 0.18, 0.28, 0.15, 0.3, 0.22, 0.26, 0.18]
  readonly property string altKey: "Alt"

  NumberAnimation on turn {
    from: 0
    to: 1
    duration: Style.duration(4800)
    loops: Animation.Infinite
    running: root.visible && root.listening && !Style.reduceMotion
  }

  Item {
    id: speaker
    width: parent.width * 0.41
    height: parent.height
    anchors.left: parent.left

    Text {
      id: microphone
      textFormat: Text.PlainText
      text: "\u{f130}"
      color: root.speechGate > 0.05 ? root.accent : Util.alpha(root.foreground, 0.58)
      font.family: Style.font.menuFamily
      font.pixelSize: Math.min(Style.space(26), parent.height * 0.19)
      horizontalAlignment: Text.AlignHCenter
      width: Style.space(36)
      x: (parent.width - width - waveCanvas.waveWidth - Style.space(6)) / 2
      y: parent.height * 0.4 - height / 2

      Behavior on color { ColorAnimation { duration: Style.duration(160) } }
    }

    // Organic anti-aliased multi-harmonic capsule waveform with an elliptical
    // ambient aura strictly contained inside the canvas so it never clips.
    Canvas {
      id: waveCanvas
      readonly property real waveWidth: Style.space(134)
      readonly property real padX: Style.space(14)

      x: microphone.x + microphone.width + Style.space(6) - padX
      anchors.verticalCenter: microphone.verticalCenter
      width: waveWidth + padX * 2
      height: Math.min(Style.space(120), speaker.height * 0.72)

      readonly property real t: root.turn
      readonly property real v: root.voice
      readonly property real gate: root.speechGate
      readonly property bool active: root.listening

      onTChanged: requestPaint()
      onActiveChanged: requestPaint()
      onWidthChanged: requestPaint()
      onHeightChanged: requestPaint()

      Connections {
        target: root
        function onAccentChanged() { waveCanvas.requestPaint() }
        function onForegroundChanged() { waveCanvas.requestPaint() }
      }

      onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        if (width <= 0 || height <= 0) return

        var count = 21
        var step = waveWidth / count
        var barW = Math.max(2.5, Math.min(3.5, step * 0.46))
        var midY = height / 2
        var maxH = Math.min(Style.space(62), speaker.height * 0.36)

        // Elliptical ambient glow scaled strictly inside the canvas bounds
        // (46% radii) so alpha reaches 0 before any edge.
        if (active && gate > 0.02) {
          var rx = width * 0.46
          var ry = height * 0.46
          ctx.save()
          ctx.translate(width / 2, midY)
          ctx.scale(1, ry / rx)
          var glow = ctx.createRadialGradient(0, 0, 2, 0, 0, rx)
          glow.addColorStop(0.0, Util.alpha(root.accent, 0.14 * v).toString())
          glow.addColorStop(0.55, Util.alpha(root.accent, 0.04 * v).toString())
          glow.addColorStop(1.0, Util.alpha(root.accent, 0).toString())
          ctx.fillStyle = glow
          ctx.beginPath()
          ctx.arc(0, 0, rx, 0, Math.PI * 2)
          ctx.fill()
          ctx.restore()
        }

        // Quiet center reference line connecting mic to wire.
        ctx.fillStyle = Util.alpha(active && gate > 0.05 ? root.accent : root.foreground, active && gate > 0.05 ? 0.2 : 0.1).toString()
        ctx.fillRect(padX, Math.round(midY) - 0.5, waveWidth, 1)

        var brightCore = Qt.rgba(
          root.accent.r + (root.foreground.r - root.accent.r) * 0.48,
          root.accent.g + (root.foreground.g - root.accent.g) * 0.48,
          root.accent.b + (root.foreground.b - root.accent.b) * 0.48,
          1
        )

        for (var i = 0; i < count; i++) {
          var u = (i + 0.5) / count
          // Smooth raised-cosine bell envelope tapers naturally at both ends.
          var bell = Math.pow(Math.sin(Math.PI * u), 1.45)

          var barH
          var intensity
          if (active) {
            // Three layered smooth waves (no sharp abs() cusps) traveling organically.
            var w1 = 0.5 + 0.5 * Math.sin(t * Math.PI * 6.0 - u * 5.6)
            var w2 = 0.5 + 0.5 * Math.sin(t * Math.PI * 10.0 + u * 8.4 + 1.3)
            var w3 = 0.5 + 0.5 * Math.cos(t * Math.PI * 4.0 - u * 11.5 + 0.5)
            var harmonic = 0.52 * w1 + 0.32 * w2 + 0.16 * w3
            var idleH = 4 + bell * 9
            barH = idleH + v * bell * (0.28 + 0.72 * harmonic) * (maxH - idleH)
            intensity = 0.32 + 0.68 * Math.min(1, v * bell * (0.55 + 0.65 * harmonic))
          } else {
            barH = 4 + bell * 12
            intensity = 0.26 + 0.16 * bell
          }

          var cx = padX + (i + 0.5) * step
          var x = cx - barW / 2
          var y = midY - barH / 2
          var r = barW / 2

          if (active) {
            var grad = ctx.createLinearGradient(0, y, 0, y + barH)
            grad.addColorStop(0.0, Util.alpha(root.accent, intensity * 0.85).toString())
            grad.addColorStop(0.5, Util.alpha(brightCore, intensity).toString())
            grad.addColorStop(1.0, Util.alpha(root.accent, intensity * 0.85).toString())
            ctx.fillStyle = grad
          } else {
            ctx.fillStyle = Util.alpha(root.foreground, intensity).toString()
          }

          // Capsule rounded bar
          ctx.beginPath()
          ctx.moveTo(x + r, y)
          ctx.lineTo(x + barW - r, y)
          ctx.arcTo(x + barW, y, x + barW, y + r, r)
          ctx.lineTo(x + barW, y + barH - r)
          ctx.arcTo(x + barW, y + barH, x + barW - r, y + barH, r)
          ctx.lineTo(x + r, y + barH)
          ctx.arcTo(x, y + barH, x, y + barH - r, r)
          ctx.lineTo(x, y + r)
          ctx.arcTo(x, y, x + r, y, r)
          ctx.closePath()
          ctx.fill()
        }
      }
    }

    // Bottom keyboard cue: Right Alt lights while speaking.
    Row {
      visible: speaker.height > Style.space(116)
      anchors.horizontalCenter: parent.horizontalCenter
      y: parent.height * 0.77 - height / 2
      spacing: Style.space(4)

      Keycap {
        legend: root.altKey
        foreground: root.foreground
        accent: root.accent
      }

      Keycap {
        width: Style.space(84)
        legend: "Space"
        foreground: root.foreground
        accent: root.accent
      }

      Keycap {
        legend: root.altKey
        held: root.speechGate > 0.08
        foreground: root.foreground
        accent: root.accent
      }
    }
  }

  // Signal path from mic to engine and into the document.
  Way {
    x: speaker.width - Style.space(6)
    y: parent.height * 0.4 - height / 2
    width: engineTile.x - x - Style.space(4)
    along: root.speechGate > 0.08 && !Style.reduceMotion ? (root.turn * 7) % 1 : 0
    active: root.speechGate > 0.08
    foreground: root.foreground
    accent: root.accent
  }

  Way {
    x: engineTile.x + engineTile.width + Style.space(4)
    y: parent.height * 0.4 - height / 2
    width: page.x - x - Style.space(4)
    along: root.speechGate > 0.08 && !Style.reduceMotion ? ((root.turn * 7) + 0.45) % 1 : 0
    active: root.speechGate > 0.08
    foreground: root.foreground
    accent: root.accent
  }

  // Processing node: always present so the diagram stays complete even before
  // a choice is picked.
  Tile {
    id: engineTile
    width: Style.space(44)
    height: Style.space(38)
    x: parent.width * 0.48 - width / 2
    y: parent.height * 0.4 - height / 2
    glyph: root.place === "cloud" ? "\u{f0c2}"
      : root.place === "device" ? "\u{f035b}"
      : "\u{f02cb}"
    lit: root.speechGate > 0.08
    foreground: root.foreground
    accent: root.accent
  }

  Win {
    id: page
    anchors.left: parent.left
    anchors.leftMargin: parent.width * 0.56
    anchors.right: parent.right
    anchors.rightMargin: root.gap
    y: parent.height * 0.5 - height * 0.5
    height: parent.height * 0.8
    active: root.listening
    lines: false
    foreground: root.foreground
    accent: root.accent

    // Subtle document title strip inside the editor window.
    Rectangle {
      id: docHeader
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.topMargin: Style.space(12)
      anchors.leftMargin: Style.space(12)
      height: Style.space(4)
      width: parent.width * 0.34
      color: Util.alpha(root.listening ? root.accent : root.foreground, root.listening ? 0.48 : 0.16)
    }

    Flow {
      opacity: root.presence
      anchors.top: docHeader.bottom
      anchors.topMargin: Style.space(10)
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.leftMargin: Style.space(12)
      anchors.rightMargin: Style.space(12)
      anchors.bottomMargin: Style.space(12)
      spacing: Style.space(6)

      Repeater {
        model: root.words

        Row {
          required property int index
          required property real modelData
          readonly property bool shown: root.listening ? index < root.written : index < 7
          readonly property bool isLast: root.listening && index === root.written - 1
          spacing: Style.space(3)
          opacity: shown ? 1 : 0

          Behavior on opacity { NumberAnimation { duration: Style.duration(110); easing.type: Easing.OutCubic } }

          Rectangle {
            width: Math.max(Style.space(14), (page.width - Style.space(36)) * modelData)
            height: Style.space(5)
            radius: Style.cornerRadius > 0 ? height / 2 : 0
            anchors.verticalCenter: parent.verticalCenter
            color: root.listening
              ? Util.alpha(root.foreground, index === root.written - 1 ? 0.62 : 0.34)
              : Util.alpha(root.foreground, 0.14)
          }

          // Live accent typing caret at the leading edge of dictated text.
          Rectangle {
            visible: isLast
            width: Style.space(2)
            height: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            color: root.accent
          }
        }
      }
    }
  }
}
