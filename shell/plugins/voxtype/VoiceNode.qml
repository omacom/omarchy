// Adapted from omacom/atreyu's VoiceNode; see LICENSE.atreyu.
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.Commons

// Presentation only. The surface never accepts mouse or keyboard input.
Item {
  id: root

  property string phase: "dormant"
  property real listeningLevel: 0
  property var targetScreen: null
  property color thinkingColor: Color.accent
  readonly property bool motionEnabled: true
  readonly property bool listeningMetered: true
  readonly property bool lit: phase !== "dormant"
  readonly property bool listeningVisualizerActive: phase === "listening"
  readonly property bool thinkingVisualizerActive: phase === "thinking"
  readonly property bool atmosphereActive: lit
  readonly property color lightColor: thinkingVisualizerActive ? thinkingColor : Color.accent
  readonly property real listeningVisualLevel: Math.max(0, Math.min(1, listeningLevel))
  readonly property real visualLevel: listeningVisualizerActive ? listeningVisualLevel : 0.42
  readonly property real level: visualLevel
  readonly property string captionMessage: listeningVisualizerActive ? "Listening…" : "Transcribing…"
  readonly property string captionDetail: ""
  property real presence: lit ? 1 : 0
  property real tide: 0.35
  property real drift: 0
  property real livingPhase: 0
  readonly property real organicLift: atmosphereActive
    ? 0.52 + 0.25 * Math.sin(livingPhase)
      + 0.15 * Math.sin(livingPhase * 1.618 + 1.1)
      + 0.08 * Math.sin(livingPhase * 2.414 + 2.7) : 0.5
  readonly property real organicDrift: drift * 0.76
    + (atmosphereActive ? 0.24 * Math.sin(livingPhase * 0.447 + 0.4) : 0)

  Behavior on presence {
    NumberAnimation { duration: root.lit ? 260 : 420; easing.type: Easing.OutCubic }
  }
  Timer {
    interval: 40
    repeat: true
    running: root.atmosphereActive
    onTriggered: root.livingPhase = (root.livingPhase + (root.thinkingVisualizerActive ? 0.076 : 0.047)) % (Math.PI * 200)
  }
  SequentialAnimation {
    running: root.atmosphereActive
    loops: Animation.Infinite
    NumberAnimation { target: root; property: "tide"; to: 1; duration: 3900; easing.type: Easing.InOutSine }
    NumberAnimation { target: root; property: "tide"; to: 0.18; duration: 4700; easing.type: Easing.InOutSine }
  }
  SequentialAnimation {
    running: root.atmosphereActive
    loops: Animation.Infinite
    NumberAnimation { target: root; property: "drift"; to: 1; duration: 6300; easing.type: Easing.InOutSine }
    NumberAnimation { target: root; property: "drift"; to: -1; duration: 7100; easing.type: Easing.InOutSine }
  }

  PanelWindow {
    id: surface
    screen: root.targetScreen
    color: "transparent"
    anchors { bottom: true; left: true; right: true }
    implicitHeight: Style.space(240)
    // Stay mapped through the fade, then release the surface rather than
    // leaving a permanently mapped overlay on the output.
    visible: root.lit || root.presence > 0.001
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "omarchy-voxtype"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // The shadow half of "shadow glow": a whisper of theme background rising
    // from the edge. It seats the light in something instead of letting it
    // float, and keeps the transcript legible over bright windows. Kept weak on
    // purpose — this must never read as a panel over the user's work.
    Rectangle {
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
      height: Style.space(190)
      opacity: root.presence
      gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.0) }
        GradientStop { position: 0.55; color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.30) }
        GradientStop { position: 1.0; color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.62) }
      }
    }

    // The ember spans the complete output. Its transparent horizontal gradient
    // keeps the corners quiet without leaving the lower screen visibly unlit;
    // the body stays sunk below the edge so only its bloom reaches the desktop.
    Item {
      id: emberSource
      visible: false
      anchors { left: parent.left; right: parent.right }
      height: Style.space(64)
      y: parent.height - Style.space(15) - (root.tide * 2 + root.organicLift * 2.4)
      Rectangle {
        anchors.fill: parent
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0.0; color: Qt.rgba(root.lightColor.r, root.lightColor.g, root.lightColor.b, 0.10) }
          GradientStop { position: 0.18 + root.organicDrift * 0.035; color: Qt.rgba(root.lightColor.r, root.lightColor.g, root.lightColor.b, 0.52) }
          GradientStop { position: 0.50 + root.organicDrift * 0.075; color: root.lightColor }
          GradientStop { position: 0.82 + root.organicDrift * 0.035; color: Qt.rgba(root.lightColor.r, root.lightColor.g, root.lightColor.b, 0.52) }
          GradientStop { position: 1.0; color: Qt.rgba(root.lightColor.r, root.lightColor.g, root.lightColor.b, 0.10) }
        }
      }
    }

    // Two blooms, not one. A single wide blur spreads the energy until the light
    // reads as fog; a wide halo under a tight core reads as an actual source.
    MultiEffect {
      anchors.fill: emberSource
      source: emberSource
      autoPaddingEnabled: true
      blurEnabled: true
      blur: 1
      blurMax: 64
      blurMultiplier: 3.2
      brightness: 0.26
      colorization: 1
      colorizationColor: root.lightColor
      opacity: root.presence * (0.27 + root.visualLevel * 0.24 + root.tide * 0.07 + root.organicLift * 0.06)
      scale: 1 + root.visualLevel * 0.04 + root.tide * 0.02 + root.organicLift * 0.012
      transformOrigin: Item.Bottom
    }

    MultiEffect {
      anchors.fill: emberSource
      source: emberSource
      autoPaddingEnabled: true
      blurEnabled: true
      blur: 1
      blurMax: 44
      blurMultiplier: 1.5
      brightness: 0.42
      colorization: 1
      colorizationColor: root.lightColor
      opacity: root.presence * (0.17 + root.visualLevel * 0.18 + root.tide * 0.05)
      scale: 1 + root.visualLevel * 0.022 + root.tide * 0.012
      transformOrigin: Item.Bottom
    }

    // The filament: the crisp edge that makes the glow read as deliberate
    // rather than as a rendering artifact.
    Item {
      id: filamentSource
      visible: false
      width: parent.width * 0.46
      height: Math.max(2, Style.space(2))
      anchors.horizontalCenter: parent.horizontalCenter
      y: parent.height - height

      Rectangle {
        anchors.fill: parent
        radius: height / 2
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0.0; color: "transparent" }
          GradientStop { position: 0.28; color: root.lightColor }
          GradientStop { position: 0.72; color: root.lightColor }
          GradientStop { position: 1.0; color: "transparent" }
        }
        opacity: root.phase === "thinking" ? 0.22 : 0.85
        Behavior on opacity {
          enabled: root.motionEnabled
          NumberAnimation { duration: 240 }
        }
      }

    }

    MultiEffect {
      anchors.fill: filamentSource
      source: filamentSource
      autoPaddingEnabled: true
      blurEnabled: true
      blur: 1
      blurMax: 28
      blurMultiplier: 0.9
      brightness: 0.5
      colorization: 0.9
      colorizationColor: root.lightColor
      opacity: root.presence * (root.thinkingVisualizerActive ? 0.18 : 1)
    }

    // The filament itself, unblurred, on top: one hairline of real light. It
    // fades at both ends too — a hard-terminated line is the one element that
    // would give the whole edge a visible boundary.
    Rectangle {
      width: filamentSource.width
      height: 1
      anchors.horizontalCenter: parent.horizontalCenter
      y: parent.height - 1
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: "transparent" }
        GradientStop { position: 0.3; color: root.lightColor }
        GradientStop { position: 0.7; color: root.lightColor }
        GradientStop { position: 1.0; color: "transparent" }
      }
      opacity: root.presence * (root.thinkingVisualizerActive ? 0
        : 0.55 + root.visualLevel * 0.3)
    }

    BumperVisualizer {
      id: thinkingBumper
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      width: Math.min(parent.width * 0.52, Style.space(720))
      height: Style.space(64)
      accent: root.lightColor
      level: root.level
      intensity: root.presence
      motionEnabled: root.motionEnabled
      visible: root.thinkingVisualizerActive
    }

    SpectrumVisualizer {
      id: listeningVisualizer
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: Style.space(10)
      width: Math.min(parent.width * 0.72, Style.space(820))
      height: Style.space(104)
      accent: root.lightColor
      level: root.listeningVisualLevel
      levelMetered: true
      motionEnabled: root.motionEnabled
      visible: root.listeningVisualizerActive
      intensity: root.presence
    }

    // ---- caption. Voice mode's only text.
    //
    // Legibility here has to survive both a white browser and a black terminal
    // without introducing a box, which would undo the ambient premise. Real
    // backdrop blur is unavailable: it needs a Hyprland layer rule, and
    // Atreyu does not write the user's compositor config.
    //
    // So the backing is a "plate" — two stacked feathered passes sized to the
    // text. Density accumulates at the centre faster than a rim accumulates at
    // the edge, so it stays legible on white while effectively vanishing on
    // dark. The containment appears only where it is needed, with no theme
    // branch and no mode switch.
    Item {
      id: caption
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: root.phase === "listening" ? Style.space(116) : Style.space(68)
      width: Math.min(parent.width * 0.52, Style.space(660))
      height: captionColumn.implicitHeight + Style.space(26)
      opacity: captionText.text === "" && hintText.text === "" ? 0 : root.presence
      Behavior on opacity {
        enabled: root.motionEnabled
        NumberAnimation { duration: 180 }
      }

      Item {
        id: plateSource
        visible: false
        anchors.centerIn: parent
        width: Math.min(parent.width, Math.max(captionText.implicitWidth, hintText.implicitWidth) + Style.space(72))
        height: captionColumn.implicitHeight + Style.space(20)
        Rectangle {
          anchors.fill: parent
          radius: height / 2
          color: Color.background
        }
      }
      MultiEffect {
        anchors.fill: plateSource
        source: plateSource
        autoPaddingEnabled: true
        blurEnabled: true
        blur: 1
        blurMax: 32
        blurMultiplier: 1.15
        // Translucent on purpose: the desktop should stay faintly present, or
        // the plate stops being ambient and becomes a redaction bar.
        opacity: 0.56
      }
      MultiEffect {
        anchors.fill: plateSource
        source: plateSource
        autoPaddingEnabled: true
        blurEnabled: true
        blur: 1
        blurMax: 22
        blurMultiplier: 0.5
        opacity: 0.46
      }

      // Transcript/status above, how-to-finish below, stacked so the plate
      // backs both. Thinking phrases fade in place instead of hard-cutting.
      Column {
        id: captionColumn
        anchors.centerIn: parent
        width: parent.width
        spacing: Style.spacing.xxs
        // Hidden because the MultiEffect below paints the glyphs plus their
        // halo; drawing both would double the stroke weight.
        visible: false

        Text {
          id: captionText
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          maximumLineCount: 2
          wrapMode: Text.WordWrap
          text: root.captionMessage
          color: Color.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.body
        }

        Text {
          id: hintText
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          text: root.captionDetail
          color: Color.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }
      }

      // A dark halo shaped like the glyphs themselves. This is what buys
      // contrast on bright backgrounds while adding no geometry of its own.
      MultiEffect {
        anchors.fill: captionColumn
        source: captionColumn
        autoPaddingEnabled: true
        shadowEnabled: true
        shadowBlur: 1
        shadowScale: 1
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
        shadowColor: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 1)
        shadowOpacity: 0.72
      }
    }
  }
}
