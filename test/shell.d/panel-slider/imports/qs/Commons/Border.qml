pragma Singleton
import QtQuick

QtObject {
  function flat(color, width) {
    return ({ color: color, width: width, widths: ({ top: width, right: width, bottom: width, left: width }), gradient: ({ enabled: false, colors: [], angle: 0 }) })
  }

  function none() {
    return flat("transparent", 0)
  }

  function top(spec) { return spec.widths.top }
  function right(spec) { return spec.widths.right }
  function bottom(spec) { return spec.widths.bottom }
  function left(spec) { return spec.widths.left }
  function needsOverlay(spec) { return false }
  function canUseNative(spec) { return true }
  function color(spec) { return spec.color }
  function uniformWidth(spec) { return spec.width }
}
