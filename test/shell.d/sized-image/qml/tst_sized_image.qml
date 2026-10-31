import QtQuick
import QtTest
import "../../../../shell/Ui"

// A SizedImage holds a bitmap no bigger than it is drawn, nor than its file,
// and places it the way PreserveAspectFit would.
Item {
  id: root
  width: 400
  height: 400

  // A 2560x1440 screenshot-sized file.
  readonly property url bigImage: Qt.resolvedUrl("../../../../themes/tokyo-night/preview.png")
  // A 400x10 strip.
  readonly property url narrowImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAAAKCAMAAACt6/hvAAAAA1BMVEX/AAAZ4gk3AAAAG0lEQVRIx+3BMQEAAADCoPVPbQ0PoAAAAIAfAw+qAAHXXPJgAAAAAElFTkSuQmCC"

  function bitmap(sized) {
    var image = sized.children[0]
    return { width: image.implicitWidth, height: image.implicitHeight }
  }

  function painted(sized) {
    var image = sized.children[0]
    return { x: image.x, y: image.y, width: image.width, height: image.height }
  }

  Image {
    id: native
    source: root.bigImage
  }

  SizedImage {
    id: thumbnail
    width: 40
    height: 40
    url: root.bigImage
  }

  SizedImage {
    id: strip
    width: 400
    height: 400
    verticalAlignment: Image.AlignTop
    url: root.narrowImage
  }

  SizedImage {
    id: art
    width: 40
    height: 40
    crop: true
    url: root.bigImage
  }

  SizedImage {
    id: stripArt
    width: 60
    height: 60
    crop: true
    url: root.narrowImage
  }

  // An 8000x4 strip, thin enough that fitting it in the bound rounds its
  // height to nothing at any device pixel ratio below 16.
  SizedImage {
    id: hairline
    width: 60
    height: 60
    crop: true
    url: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAH0AAAAAECAMAAAA0cPmbAAAAA1BMVEUA/wA0XsCoAAAANUlEQVR42u3BMQEAAADCoPVP7WkJoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABufQQAAcZAqtEAAAAASUVORK5CYII="
  }

  // A 4500x10 strip in a tall preview pane, 200x500 physical pixels, where
  // the box's narrow side limits the fit. Fitted, it is 200x0.4: too thin to
  // decode, though shorter than the box's long side.
  SizedImage {
    id: paneStrip
    width: 200 / Screen.devicePixelRatio
    height: 500 / Screen.devicePixelRatio
    url: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAEZQAAAAKCAMAAAAK9pzeAAAAA1BMVEUAAP+KeNJXAAAAQklEQVR42u3BMQEAAADCoPVPbQwfoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgYa/SAAEgwyXOAAAAAElFTkSuQmCC"
  }

  // A 400x10 SVG strip.
  SizedImage {
    id: vector
    width: 100
    height: 100
    url: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0MDAiIGhlaWdodD0iMTAiPjxyZWN0IHdpZHRoPSI0MDAiIGhlaWdodD0iMTAiIGZpbGw9InJlZCIvPjwvc3ZnPg=="
  }

  SizedImage {
    id: unsized
    width: 0
    height: 40
    url: root.bigImage
  }

  TestCase {
    name: "SizedImage"
    when: windowShown

    function test_the_file_is_bigger_than_the_thumbnail() {
      tryCompare(native, "status", Image.Ready)
      compare(native.implicitWidth, 2560, "the fixture is full size")
    }

    function test_it_decodes_at_the_size_it_is_drawn() {
      tryCompare(thumbnail, "status", Image.Ready)
      var box = Math.ceil(40 * Screen.devicePixelRatio)
      var size = bitmap(thumbnail)
      compare(size.width, box, "the long side fits the box")
      verify(size.height < box, "and the short side keeps the aspect ratio: " + size.width + "x" + size.height)
      var rect = painted(thumbnail)
      compare(rect.width, 40, "drawn across the box")
      compare(rect.y, (40 - rect.height) / 2, "and centred in it")
    }

    function test_it_never_decodes_bigger_than_the_file() {
      tryCompare(strip, "status", Image.Ready)
      var size = bitmap(strip)
      compare(size.width, 400, "a strip narrower than the box keeps its width")
      compare(size.height, 10, "and its height")
      var rect = painted(strip)
      compare(rect.width, 400, "it is still drawn to fit the box")
      compare(rect.height, 10)
      compare(rect.y, 0, "at the top it was aligned to")
    }

    // Without a preserving fill mode Qt would render it at exactly sourceSize,
    // a 100x100 square, and PreserveAspectFit would render it at 4000x100.
    function test_an_svg_keeps_its_shape_and_its_own_size() {
      tryCompare(vector, "status", Image.Ready)
      var image = vector.children[0]
      compare(bitmap(vector).width, 400, "rendered at its intrinsic width")
      compare(bitmap(vector).height, 10, "and height")
      compare(image.paintedWidth, 100, "drawn across the box")
      compare(image.paintedHeight, 2.5, "without losing its aspect ratio")
    }

    function test_a_crop_covers_the_box_from_a_small_bitmap() {
      tryCompare(art, "status", Image.Ready)
      var size = bitmap(art)
      var bound = Math.ceil(80 * Screen.devicePixelRatio)
      compare(size.width, bound, "decoded within twice the box")
      verify(size.height >= Math.ceil(40 * Screen.devicePixelRatio), "and still covers it at full resolution: " + size.width + "x" + size.height)
      var rect = painted(art)
      compare(rect.height, 40, "the short side fills the box")
      verify(rect.width > 40, "the long side runs past it")
      compare(rect.x, (40 - rect.width) / 2, "centred")
      verify(art.clip, "and is clipped to the box")
    }

    function test_a_crop_never_decodes_bigger_than_the_file() {
      tryCompare(stripArt, "status", Image.Ready)
      var size = bitmap(stripArt)
      verify(size.width <= 400 && size.height <= 10, "a narrow strip is not enlarged: " + size.width + "x" + size.height)
      compare(painted(stripArt).height, 60, "yet still covers the box when drawn")
    }

    function test_a_strip_too_thin_to_shrink_still_draws() {
      tryVerify(function() { return hairline.status === Image.Ready && bitmap(hairline).height > 0 }, 2000,
        "decoded " + bitmap(hairline).width + "x" + bitmap(hairline).height)
      compare(bitmap(hairline).height, 1, "one pixel across")
      compare(bitmap(hairline).width, 2000, "and its aspect ratio long, not the file's 8000x4")
      compare(painted(hairline).height, 60, "covering the box")
    }

    // The clipboard reuses a preview for the next row's image.
    function test_the_next_image_after_a_thin_strip_decodes_normally() {
      tryVerify(function() { return hairline.status === Image.Ready && bitmap(hairline).height === 1 }, 2000)
      var thin = hairline.url
      hairline.url = root.bigImage
      tryVerify(function() { return hairline.status === Image.Ready && bitmap(hairline).width > 1 }, 2000,
        "decoded " + bitmap(hairline).width + "x" + bitmap(hairline).height)
      compare(bitmap(hairline).width, Math.ceil(120 * Screen.devicePixelRatio), "decoded to the crop bound, not as a sliver")
      hairline.url = thin
      tryVerify(function() { return hairline.status === Image.Ready && bitmap(hairline).height === 1 }, 2000,
        "and the strip falls back again: " + bitmap(hairline).width + "x" + bitmap(hairline).height)
    }

    // A failed load is not taken for a thin strip, and does not keep retrying.
    function test_a_missing_file_is_tried_a_few_times_then_left() {
      var missing = Qt.createQmlObject('import "../../../../shell/Ui"; SizedImage { width: 40; height: 40; url: "file:///nonexistent/omarchy-sized-image.png" }', root)
      var spy = Qt.createQmlObject('import QtTest; SignalSpy { signalName: "statusChanged" }', root)
      spy.target = missing
      tryCompare(missing, "status", Image.Error)
      wait(300)
      verify(!missing.thinDecode, "the URL is not remembered as a thin strip")
      verify(spy.count <= 12, "and it stops retrying: " + spy.count + " status changes")
      var settled = spy.count
      wait(300)
      compare(spy.count, settled, "nothing more happens")
      missing.destroy()
      spy.destroy()
    }

    function test_a_thin_strip_in_a_tall_box_still_draws() {
      tryVerify(function() { return paneStrip.status === Image.Ready && bitmap(paneStrip).height === 1 }, 2000,
        "decoded " + bitmap(paneStrip).width + "x" + bitmap(paneStrip).height)
      compare(bitmap(paneStrip).width, 450, "one pixel across and its aspect ratio long")
      compare(painted(paneStrip).width, paneStrip.width, "drawn across the box's narrow side")
      wait(200)
      compare(bitmap(paneStrip).height, 1, "and it stays that way")
    }

    function test_clipboard_svg_captures_count_as_svgs() {
      var probe = Qt.createQmlObject('import "../../../../shell/Ui"; SizedImage {}', root)
      probe.url = "file:///state/clipboard-images/abc.svg+xml"
      verify(probe.scalable, "a capture named after image/svg+xml")
      probe.url = "file:///state/clipboard-images/abc.svg%2Bxml"
      verify(probe.scalable, "the same capture as Util.fileUrl encodes it")
      probe.url = "file:///state/clipboard-images/abc.svg"
      verify(probe.scalable, "a plain .svg")
      probe.url = "file:///state/clipboard-images/abc.png"
      verify(!probe.scalable, "a raster capture")
      probe.url = "file:///home/me/svg/shot.png"
      verify(!probe.scalable, "a raster file under a directory named svg")
      probe.url = "file:///home/me/drawing.svg.png"
      verify(!probe.scalable, "a PNG exported from an SVG")
      probe.destroy()
    }

    function test_it_waits_for_a_size_before_decoding() {
      wait(50)
      compare(unsized.status, Image.Null, "nothing decodes at native size first")
      unsized.width = 40
      tryCompare(unsized, "status", Image.Ready)
      verify(bitmap(unsized).width <= Math.ceil(40 * Screen.devicePixelRatio), "decoded width " + bitmap(unsized).width)
    }
  }
}
