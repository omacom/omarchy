import QtQuick

// The keyboard layouts a password can be typed in, as default/splash/layouts
// lists them for the compositor (XKBLAYOUT and XKBVARIANT): the one it starts
// in first. `index` is the one typed in; its shell switches the compositor to
// it. Each reads as its layout, and its variant where another entry shares
// the layout (Colemak is a variant of US).
QtObject {
  property string layout
  property string variant
  property int index: 0

  readonly property var names: (layout || "us").split(",")
  readonly property var labels: {
    const variants = variant.split(",")
    return names.map((name, i) => {
      const shared = names.some((other, j) => j !== i && other === name)
      return (shared && variants[i] ? `${name} ${variants[i]}` : name).toUpperCase()
    })
  }
  readonly property int count: names.length
  readonly property string label: labels[index]

  function next() {
    index = (index + 1) % count
  }
}
