pragma Singleton
import QtQuick
import "BarSizes.js" as Model

// BarSizes.js for QML. The bar and its facades reach it through qs.Commons, so
// a cloned bar under ~/.config/omarchy/plugins/ finds it too.
QtObject {
  function sizeFor(sizes, screenName, fallback) {
    return Model.sizeFor(sizes, screenName, fallback)
  }

  function detached(sizes) {
    return Model.detached(sizes)
  }
}
