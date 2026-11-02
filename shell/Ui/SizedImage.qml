import QtQuick

// An image fitted inside this item, or with `crop` covering it, preserving
// its aspect ratio, and decoded at about the size it is drawn, in physical
// pixels, instead of at the file's own size. A 2560x1440 screenshot shown as
// a 40px thumbnail would otherwise hold a 14 MB bitmap for as long as the
// thumbnail exists.
//
// The inner Image is not PreserveAspectFit or PreserveAspectCrop on purpose.
// With either, Qt scales the decode to cover sourceSize, which upscales an
// image narrower than the box: a 400x10 strip in a 400x400 box would decode at
// 16000x400. Without them, sourceSize is a bound Qt only ever shrinks the
// image to fit, so the bitmap is never larger than the bound or the file.
// This item then places the decoded image the way the fill mode would. A crop
// bounds the decode at twice the box, so images up to 2:1 still cover it at
// full resolution.
//
// That only holds for raster images. Qt renders an SVG at exactly sourceSize
// when the fill mode is not a preserving one, which would stretch it, and with
// a preserving one it covers the box like any other image. An SVG therefore
// keeps Qt's own handling: rendered at its intrinsic size and fitted or
// cropped on draw.
//
// The image waits until the item has been laid out, so nothing is decoded at
// native size first.
Item {
  id: root

  property url url: ""
  property bool crop: false
  property int horizontalAlignment: Image.AlignHCenter
  property int verticalAlignment: Image.AlignVCenter
  // Left and right swap in a mirrored (right-to-left) layout, as they do for
  // a plain Image.
  readonly property int effectiveHorizontalAlignment: !LayoutMirroring.enabled ? horizontalAlignment
    : horizontalAlignment === Image.AlignLeft ? Image.AlignRight
    : horizontalAlignment === Image.AlignRight ? Image.AlignLeft
    : horizontalAlignment
  property bool asynchronous: true
  readonly property alias status: image.status
  readonly property bool sized: width > 0 && height > 0
  // Clipboard captures name the file after the MIME subtype, as in .svg+xml,
  // and Util.fileUrl percent-encodes the plus.
  readonly property bool scalable: /(\.svgz?|\.svg(\+|%2B)xml)([?#].*)?$|^data:image\/svg/i.test(String(url))
  readonly property real reach: crop ? 2 : 1
  // A strip thin enough that fitting it in the bound rounds its short side
  // to nothing decodes empty. It is decoded again covering a single pixel
  // instead: one pixel across and its aspect ratio long, still a sliver of
  // the file however large that is.
  // Remembered by URL rather than as a flag to reset, so switching to another
  // image can't carry the fallback over to it.
  property string thinUrl: ""
  readonly property bool thinDecode: thinUrl !== "" && thinUrl === String(url)
  property string failedUrl: ""
  property string recheckedUrl: ""
  onUrlChanged: {
    failedUrl = ""
    recheckedUrl = ""
  }

  clip: crop

  Image {
    id: image

    readonly property real placedScale: implicitWidth > 0 && implicitHeight > 0
      ? (root.crop ? Math.max(root.width / implicitWidth, root.height / implicitHeight)
                   : Math.min(root.width / implicitWidth, root.height / implicitHeight))
      : 0

    width: root.scalable ? root.width : implicitWidth * placedScale
    height: root.scalable ? root.height : implicitHeight * placedScale
    x: root.scalable || root.effectiveHorizontalAlignment === Image.AlignLeft ? 0
      : root.effectiveHorizontalAlignment === Image.AlignRight ? root.width - width
      : (root.width - width) / 2
    y: root.scalable || root.verticalAlignment === Image.AlignTop ? 0
      : root.verticalAlignment === Image.AlignBottom ? root.height - height
      : (root.height - height) / 2

    source: root.sized ? root.url : ""
    readonly property bool bounded: root.sized && !root.scalable && !root.thinDecode
    sourceSize.width: bounded ? Math.ceil(root.width * root.reach * Screen.devicePixelRatio) : root.thinDecode ? 1 : 0
    sourceSize.height: bounded ? Math.ceil(root.height * root.reach * Screen.devicePixelRatio) : root.thinDecode ? 1 : 0
    onStatusChanged: {
      var loaded = String(source)
      if (root.thinDecode) {
        if (status === Image.Error) {
          root.thinUrl = ""
        } else if (status === Image.Ready && root.recheckedUrl !== loaded) {
          // The fallback's bitmap has the image's aspect ratio. If fitting
          // that in the bound keeps at least a pixel across, the bounded load
          // failed for another reason, such as art that only appeared later,
          // so load it bounded again. Only once per URL, so a disagreement
          // about rounding can't flip back and forth.
          var boundWidth = Math.ceil(root.width * root.reach * Screen.devicePixelRatio)
          var boundHeight = Math.ceil(root.height * root.reach * Screen.devicePixelRatio)
          var across = Math.min(boundWidth / implicitWidth, boundHeight / implicitHeight) * Math.min(implicitWidth, implicitHeight)
          if (across >= 1) {
            root.recheckedUrl = loaded
            root.thinUrl = ""
          }
        }
        return
      }
      if (!bounded) return
      if (status === Image.Ready && (implicitWidth === 0 || implicitHeight === 0)) {
        root.thinUrl = loaded
      } else if (status === Image.Error && root.failedUrl !== loaded) {
        // Some decoders fail outright where a thin PNG comes back empty. Try
        // the fallback once per URL, so a file that is simply missing does
        // not keep reloading.
        root.failedUrl = loaded
        root.thinUrl = loaded
      }
    }
    // A thin decode covers its 1x1 bound, so its short side is one pixel.
    fillMode: root.scalable || root.thinDecode
      ? (root.crop || root.thinDecode ? Image.PreserveAspectCrop : Image.PreserveAspectFit)
      : Image.Stretch
    horizontalAlignment: root.horizontalAlignment
    verticalAlignment: root.verticalAlignment
    asynchronous: root.asynchronous
    smooth: root.smooth
  }
}
