import QtQuick

// Averages the colour of the strip a bar covers, from a wallpaper image the
// background has already decoded. Decoding the file again in ImageMagick took
// 0.3-1.2s for large wallpapers; this reads back only the strip.
Item {
  id: root

  // The request in flight: its callback, strip and grab url. Each step checks
  // it is still the current one, so a replaced request cannot answer.
  property var request: null

  // The grab renders on the GPU. The software renderer returns empty strips,
  // so callers fall back to decoding the file instead.
  readonly property bool available: GraphicsInfo.api !== GraphicsInfo.Software

  function barRect(position, barSize, width, height) {
    var size = Math.min(barSize, position === "top" || position === "bottom" ? height : width)
    if (position === "top") return Qt.rect(0, 0, width, size)
    if (position === "bottom") return Qt.rect(0, height - size, width, size)
    if (position === "left") return Qt.rect(0, 0, size, height)
    return Qt.rect(width - size, 0, size, height)
  }

  // Calls back with "#rrggbb", or "" when the strip could not be read.
  function sample(image, position, barSize, callback) {
    var rect = barRect(position, barSize, image.width, image.height)
    if (!available || rect.width < 1 || rect.height < 1) {
      callback("")
      return
    }
    // A newer request replaces one still in flight; its caller has moved on.
    // Its grab is dropped too, or its late image load would answer this one.
    if (request && request.url) canvas.unloadImage(request.url)
    var current = { callback: callback, rect: rect, url: "" }
    request = current
    strip.sourceItem = image
    strip.sourceRect = rect
    strip.width = rect.width
    strip.height = rect.height
    strip.scheduleUpdate()
    var ok = strip.grabToImage(function(result) {
      if (root.request !== current) return
      current.url = result.url
      canvas.width = rect.width
      canvas.height = rect.height
      canvas.loadImage(result.url)
      if (canvas.isImageLoaded(result.url)) canvas.requestPaint()
    })
    if (!ok) finish(current, "")
  }

  // Runs from the canvas's paint, the first point where a resized canvas has a
  // buffer of its new size; reading straight after a resize returned black.
  function average() {
    var current = request
    if (!current || !current.url || !canvas.isImageLoaded(current.url)) return
    var w = current.rect.width, h = current.rect.height
    var ctx = canvas.getContext("2d")
    ctx.clearRect(0, 0, w, h)
    // The grab arrives in physical pixels (strip size x device pixel ratio),
    // so draw it scaled to the strip's own size before reading it back.
    ctx.drawImage(current.url, 0, 0, w, h)
    var data = ctx.getImageData(0, 0, w, h).data
    // A still covers the canvas, but a video wallpaper would show it.
    ctx.clearRect(0, 0, w, h)
    // Transparent pixels count as white, as when omarchy-bar-text-color
    // flattens the wallpaper in ImageMagick, so both paths choose alike.
    var red = 0, green = 0, blue = 0
    for (var i = 0; i < data.length; i += 4) {
      var alpha = data[i + 3] / 255
      var white = 255 * (1 - alpha)
      red += data[i] * alpha + white
      green += data[i + 1] * alpha + white
      blue += data[i + 2] * alpha + white
    }
    canvas.unloadImage(current.url)
    var count = w * h
    function channel(sum) {
      var hex = Math.floor(sum / count).toString(16)
      return hex.length < 2 ? "0" + hex : hex
    }
    finish(current, "#" + channel(red) + channel(green) + channel(blue))
  }

  function finish(current, value) {
    if (request !== current) return
    request = null
    strip.sourceItem = null
    strip.width = 0
    strip.height = 0
    current.callback(value)
  }

  ShaderEffectSource {
    id: strip
    live: false
    hideSource: false
  }

  Canvas {
    id: canvas
    width: 1
    height: 1
    renderTarget: Canvas.Image
    renderStrategy: Canvas.Immediate
    onImageLoaded: requestPaint()
    onPaint: root.average()
  }
}
