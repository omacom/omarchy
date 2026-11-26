import QtQuick
import qs.Commons

// Native strings use the shell catalog. Standalone packaging supplies the
// same interface over its bundled plugin catalogs.
QtObject {
  readonly property string language: I18n.language
  function t(key, fallback) { return I18n.t(key, fallback) }
}
