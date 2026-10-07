pragma Singleton
import QtQuick
import "ShadowGeometry.js" as Geometry

// Read the merged dictionary in the binding, so both theme IPC and watched
// machine overrides update shadows without restarting the shell.
QtObject {
  function surfaceSpec(section) {
    var spec = Geometry.spec(Color.shellValues, section)
    var raw = Color.shellValues[section + ".shadow-color"] || "#000000"
    // Reuse border color syntax and its cycle-safe role-reference resolver.
    var token = Border.resolveValueRef(raw)
    var resolved = token === "muted" ? Color.muted : Border.cssColor(token, 1)
    spec.color = Qt.rgba(0, 0, 0, spec.alpha)
    try {
      var color = typeof resolved === "string" ? Qt.color(resolved) : resolved
      if (color.valid !== false && color.r !== undefined)
        spec.color = Qt.rgba(color.r, color.g, color.b, color.a * spec.alpha)
    } catch (error) {
      // Invalid theme colors fall back to black, never a broken QML binding.
    }
    spec.enabled = spec.enabled && spec.color.a > 0
    if (!spec.enabled) spec.left = spec.right = spec.top = spec.bottom = 0
    return spec
  }
}
