import QtQuick
import QtQuick.Shapes
import "Animation.js" as AnimationModel

// One screen's worth of weather drawn over the wallpaper.
//
// Precipitation is drawn as three sliding sheets rather than as hundreds of
// independently animated drops. Each sheet is rotated so that the direction
// of fall is its own vertical axis, holds its drops at fixed positions, and
// carries a second copy of them one sheet-height down; sliding it by exactly
// that height and looping is therefore seamless. Animating one property per
// sheet instead of two per drop is the difference between a desktop
// decoration and a busy core: the per-drop version measured around +26% CPU
// on a two-monitor session, the sheets are a rounding error.
//
// Drops within a sheet share a speed, which is also how rain actually looks:
// what sells depth is three planes at different speeds, not variation inside
// one of them.
//
// Restraint is the rest of the design. Peak opacity comes from Animation.js
// and tops out around a fifth for rain; conditions cross-fade over a second
// rather than cutting; and thunder is the only element allowed to change
// brightness abruptly, at roughly one soft flash a minute.
Item {
  id: root

  // Resolved by Animation.js; null means draw nothing.
  property var profile: null

  // False whenever nothing can see this: covered, locked, or switched off.
  property bool running: false

  readonly property string condition: profile ? String(profile.condition) : ""
  readonly property real intensity: profile ? Number(profile.intensity) : 0
  readonly property real slant: profile ? Number(profile.slant) : 0
  readonly property real fieldOpacity: profile ? Number(profile.opacity) : 0
  readonly property bool night: profile ? profile.night === true : false

  // Number of depth planes precipitation is split across.
  readonly property int planes: 3

  // Conditions cross-fade. The fade also gates the animations: children run
  // while the layer is still visible, so stopping is never a visible cut.
  opacity: running && profile ? 1 : 0
  visible: opacity > 0.001
  readonly property bool animating: visible

  Behavior on opacity {
    NumberAnimation { duration: 1200; easing.type: Easing.InOutQuad }
  }

  // Rain, drizzle, and the rain inside a thunderstorm are one renderer; only
  // the count, length, and speed that Animation.js resolved differ.
  readonly property bool precipitating: condition === "rain"
    || condition === "drizzle" || condition === "storm"

  Loader {
    anchors.fill: parent
    active: root.precipitating
    sourceComponent: Precipitation { }
  }

  Loader {
    anchors.fill: parent
    active: root.condition === "snow"
    sourceComponent: Snowfall { }
  }

  // Fog, overcast, and clear all draw the same drifting soft bands; they
  // differ in tint and in how much of the screen they cover.
  Loader {
    anchors.fill: parent
    active: root.condition === "fog" || root.condition === "cloudy"
      || root.condition === "clear"
    sourceComponent: Haze { }
  }

  // Sunlit dust on a clear day, and the faintest drift of it at night.
  Loader {
    anchors.fill: parent
    active: root.condition === "clear"
    sourceComponent: Motes { }
  }

  Loader {
    anchors.fill: parent
    active: root.profile ? root.profile.lightning === true : false
    sourceComponent: Lightning { }
  }

  // ---------------------------------------------------------------- rain

  component Precipitation: Item {
    id: field

    readonly property bool drizzling: root.condition === "drizzle"

    opacity: root.fieldOpacity

    Repeater {
      model: root.planes

      delegate: FallingSheet {
        required property int index

        depth: root.planes > 1 ? index / (root.planes - 1) : 0
        // Drizzle is shorter, thinner, and slower than rain at the same count.
        dropLength: (field.drizzling ? 12 : 26)
          + (field.drizzling ? 16 : 44) * depth
        dropThickness: 1 + depth
        cycleDuration: ((field.drizzling ? 3200 : 2400)
          - (field.drizzling ? 1100 : 1000) * depth) * (1.15 - 0.3 * root.intensity)
      }
    }
  }

  // ---------------------------------------------------------------- snow

  component Snowfall: Item {
    id: field

    opacity: root.fieldOpacity

    Repeater {
      model: root.planes

      delegate: FallingSheet {
        required property int index

        flakes: true
        depth: root.planes > 1 ? index / (root.planes - 1) : 0
        dropLength: 2 + 3.5 * depth
        dropThickness: dropLength
        // Snow takes fifteen to thirty seconds to cross. Anything quicker
        // reads as static rather than snowfall.
        cycleDuration: (30000 - 13000 * depth) * (1.2 - 0.4 * root.intensity)
        // Whole-plane drift, which reads as gusts. Per-flake sway would mean
        // one animation per flake again, and this is the part of the cost
        // the sheets exist to avoid.
        swayReach: 10 + 26 * depth
        swayDuration: 7000 + index * 2600
      }
    }
  }

  // One depth plane of falling precipitation.
  //
  // The plane is rotated by the wind slant and oversized to the exact
  // bounding box that rotation needs, so it still covers the screen at every
  // angle. Inside it the sheet holds each drop twice, one sheet-height apart,
  // and slides by exactly that height on a loop — which is why the wrap is
  // invisible without any per-drop bookkeeping.
  component FallingSheet: Item {
    id: plane

    // 0 is the farthest plane, 1 the nearest.
    property real depth: 0
    property real dropLength: 10
    property real dropThickness: 1
    property real cycleDuration: 2000
    // Round flakes rather than streaks, and no gradient.
    property bool flakes: false
    property real swayReach: 0
    property real swayDuration: 6000

    readonly property real tiltRadians: Math.abs(root.slant) * Math.PI / 180
    readonly property real coverWidth: parent.width * Math.cos(tiltRadians)
      + parent.height * Math.sin(tiltRadians)
    readonly property real coverHeight: parent.width * Math.sin(tiltRadians)
      + parent.height * Math.cos(tiltRadians)

    // Counted against the rotated plane's own area, so tilting the field does
    // not thin it out, and split across the planes.
    readonly property int drops: Math.round(
      AnimationModel.particleCount(root.profile, coverWidth, coverHeight) / root.planes)

    anchors.centerIn: parent
    width: coverWidth
    height: coverHeight
    rotation: root.slant

    Item {
      id: sheet

      width: plane.width
      // Two stacked copies of the same pattern: the loop below slides exactly
      // one copy, so the seam never lands inside the visible window.
      height: plane.height * 2

      Repeater {
        model: plane.drops

        delegate: Item {
          id: drop

          required property int index

          // Bindings with no property dependencies are evaluated once, so
          // each drop keeps the position it was given for the layer's life.
          readonly property real unitX: Math.random()
          readonly property real unitY: Math.random()

          x: drop.unitX * plane.width
          y: drop.unitY * plane.height

          Repeater {
            model: 2

            delegate: Rectangle {
              required property int index

              y: index * plane.height
              width: plane.dropThickness
              height: plane.dropLength
              radius: plane.flakes ? plane.dropLength / 2 : width / 2
              antialiasing: true
              // Flakes are flat; streaks fade in from the head so they read
              // as falling rather than as a row of dashes.
              color: plane.flakes
                ? Qt.rgba(1, 1, 1, 0.45 + 0.55 * plane.depth)
                : "transparent"
              gradient: plane.flakes ? null : streak
            }
          }

          Gradient {
            id: streak

            GradientStop { position: 0.0; color: "transparent" }
            GradientStop {
              position: 1.0
              color: Qt.rgba(1, 1, 1, 0.35 + 0.65 * plane.depth)
            }
          }
        }
      }

      NumberAnimation on y {
        running: root.animating
        from: -plane.height
        to: 0
        duration: plane.cycleDuration
        loops: Animation.Infinite
      }

      SequentialAnimation on x {
        running: root.animating && plane.swayReach > 0
        loops: Animation.Infinite

        NumberAnimation {
          from: -plane.swayReach
          to: plane.swayReach
          duration: plane.swayDuration
          easing.type: Easing.InOutSine
        }

        NumberAnimation {
          from: plane.swayReach
          to: -plane.swayReach
          duration: plane.swayDuration
          easing.type: Easing.InOutSine
        }
      }
    }
  }

  // ------------------------------------------------- fog, overcast, clear

  component Haze: Item {
    id: field

    // Fog sits low and pale; overcast is a dark wash that reads as cloud
    // shadow; clear is one barely-there warm patch by day, cool by night.
    readonly property color tint: {
      if (root.condition === "cloudy") return Qt.rgba(0, 0, 0, 1)
      if (root.condition === "clear")
        return root.night ? Qt.rgba(0.72, 0.80, 1, 1) : Qt.rgba(1, 0.93, 0.78, 1)
      return Qt.rgba(1, 1, 1, 1)
    }

    readonly property int patches: root.condition === "clear" ? 2 : 4

    opacity: root.fieldOpacity

    Repeater {
      model: field.patches

      delegate: SoftPatch {
        required property int index

        tint: field.tint
        // Fog gathers toward the bottom of the frame; the others spread out.
        centreY: root.condition === "fog"
          ? 0.52 + 0.16 * index
          : 0.18 + 0.24 * index
        spanX: field.width * (0.9 + 0.35 * (index % 3))
        spanY: field.height * (root.condition === "clear" ? 0.8 : 0.5 + 0.12 * (index % 2))
        // Each patch crosses at its own pace, so they slide past one another
        // instead of moving as one sheet. One to two and a half minutes for a
        // full crossing: movement you notice only if you look for it.
        driftDuration: 74000 + index * 21000
        // Spread around the loop, or every patch would enter from the same
        // edge at the same moment and leave the middle of the sky empty.
        phase: field.patches > 0 ? index / field.patches : 0
      }
    }
  }

  // A soft patch of haze that drifts across and wraps.
  //
  // Radial rather than a banded rectangle for a specific reason: a band with
  // a vertical gradient is uniform along x, so sliding it sideways changes no
  // pixel at all and the drift is invisible. Fading in every direction is what
  // makes the movement read.
  component SoftPatch: Item {
    id: patch

    property color tint: "white"
    // Fraction of the field height the patch is centred on.
    property real centreY: 0.5
    property real spanX: 600
    property real spanY: 300
    property real driftDuration: 90000
    // Where in the crossing this patch starts, 0..1.
    property real phase: 0

    readonly property real entryX: -patch.spanX
    readonly property real exitX: patch.parent ? patch.parent.width : 0
    readonly property real startX: entryX + (exitX - entryX) * patch.phase

    width: patch.spanX
    height: patch.spanY
    y: (patch.parent ? patch.parent.height : 0) * patch.centreY - patch.spanY / 2

    // Drawn as a circle and then squashed, rather than as an ellipse with a
    // circular gradient. A radial gradient is round whatever shape it fills,
    // so on a wide ellipse the fill would still be near-opaque where the
    // outline cuts it off top and bottom — a visible hard edge. Squashing
    // the whole thing keeps the falloff and the outline in step.
    Shape {
      anchors.centerIn: parent
      width: patch.spanX
      height: patch.spanX
      preferredRendererType: Shape.CurveRenderer
      antialiasing: true

      transform: Scale {
        origin.x: patch.spanX / 2
        origin.y: patch.spanX / 2
        yScale: patch.spanX > 0 ? patch.spanY / patch.spanX : 1
      }

      ShapePath {
        strokeColor: "transparent"
        fillGradient: RadialGradient {
          centerX: patch.spanX / 2
          centerY: patch.spanX / 2
          centerRadius: patch.spanX / 2
          focalX: centerX
          focalY: centerY

          GradientStop {
            position: 0.0
            color: Qt.rgba(patch.tint.r, patch.tint.g, patch.tint.b, 1.0)
          }
          GradientStop {
            position: 0.5
            color: Qt.rgba(patch.tint.r, patch.tint.g, patch.tint.b, 0.5)
          }
          GradientStop {
            position: 1.0
            color: Qt.rgba(patch.tint.r, patch.tint.g, patch.tint.b, 0.0)
          }
        }

        PathAngleArc {
          centerX: patch.spanX / 2
          centerY: patch.spanX / 2
          radiusX: patch.spanX / 2
          radiusY: patch.spanX / 2
          startAngle: 0
          sweepAngle: 360
        }
      }
    }

    // Straight through and around again. The patch is fully transparent at
    // its rim, so the wrap has nothing to give away. The first pass is the
    // tail of a crossing already in progress, which is what puts the patches
    // at different points of the sky from the first frame.
    SequentialAnimation {
      running: root.animating

      NumberAnimation {
        target: patch
        property: "x"
        from: patch.startX
        to: patch.exitX
        duration: patch.driftDuration * (1 - patch.phase)
      }

      NumberAnimation {
        target: patch
        property: "x"
        from: patch.entryX
        to: patch.exitX
        duration: patch.driftDuration
        loops: Animation.Infinite
      }
    }
  }

  // --------------------------------------------------------------- motes

  component Motes: Item {
    id: field

    // A dozen or so specks of dust catching the light. Few enough that they
    // can afford an animation each, unlike precipitation.
    readonly property int count: AnimationModel.particleCount(root.profile, width, height)

    opacity: root.fieldOpacity * 0.9

    Repeater {
      model: field.count

      delegate: Rectangle {
        id: mote

        required property int index

        readonly property real depth: (mote.index % 3) / 2
        readonly property real size: 2 + 2.5 * mote.depth
        // Motes hang rather than fall: a slow rise across most of a minute.
        readonly property real duration: 42000 - 14000 * mote.depth
        readonly property real startDelay: Math.random() * duration
        readonly property real driftX: (Math.random() - 0.35) * field.width * 0.35
        readonly property real originX: Math.random() * field.width
        readonly property real originY: field.height * (0.35 + Math.random() * 0.65)

        property real t: 0

        width: mote.size
        height: mote.size
        radius: mote.size / 2
        antialiasing: true
        color: root.night ? Qt.rgba(0.85, 0.9, 1, 0.7) : Qt.rgba(1, 0.97, 0.88, 0.8)

        x: mote.originX + mote.t * mote.driftX
        y: mote.originY - mote.t * field.height * 0.5
        // Fades in and out over its own drift, so none of them pop.
        opacity: Math.sin(mote.t * Math.PI)

        SequentialAnimation {
          running: root.animating

          PauseAnimation { duration: mote.startDelay }

          NumberAnimation {
            target: mote
            property: "t"
            from: 0
            to: 1
            duration: mote.duration
            loops: Animation.Infinite
          }
        }
      }
    }
  }

  // ----------------------------------------------------------- lightning

  component Lightning: Item {
    id: field

    // Nowhere near a real lightning flash. Enough to register at the edge of
    // vision, capped so it can never strobe a dark room.
    readonly property real peak: 0.09

    function schedule() {
      strikeTimer.interval = 22000 + Math.random() * 38000
    }

    Rectangle {
      id: flash

      anchors.fill: parent
      color: "white"
      opacity: 0
    }

    // Two beats: a small leader, then the main flash, then a slow decay.
    SequentialAnimation {
      id: strike

      NumberAnimation {
        target: flash; property: "opacity"
        to: field.peak * 0.45; duration: 70; easing.type: Easing.OutQuad
      }
      NumberAnimation {
        target: flash; property: "opacity"
        to: field.peak * 0.1; duration: 90; easing.type: Easing.InQuad
      }
      NumberAnimation {
        target: flash; property: "opacity"
        to: field.peak; duration: 60; easing.type: Easing.OutQuad
      }
      NumberAnimation {
        target: flash; property: "opacity"
        to: 0; duration: 900; easing.type: Easing.InOutQuad
      }
    }

    Timer {
      id: strikeTimer

      interval: 22000
      running: root.animating
      repeat: true
      onTriggered: {
        strike.restart()
        field.schedule()
      }
    }

    Component.onCompleted: schedule()
  }
}
