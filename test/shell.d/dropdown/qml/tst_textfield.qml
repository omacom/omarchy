import QtQuick
import QtTest
import "qs/Ui"

Item {
  id: scene
  width: 320
  height: 120

  Component {
    id: fieldComponent
    TextField { width: 240 }
  }

  TestCase {
    name: "TextFieldTrailingPadding"
    when: windowShown

    function test_trailing_padding_ltr_and_rtl() {
      var field = createTemporaryObject(fieldComponent, scene)
      verify(field !== null)
      var baseLeft = field.leftPadding
      var baseRight = field.rightPadding

      field.trailingPadding = 34
      compare(field.leftPadding, baseLeft, "LTR keeps normal leftPadding")
      compare(field.rightPadding, baseRight - field.horizontalPadding + 34, "LTR applies trailingPadding to rightPadding")

      field.trailingPadding = 2
      compare(field.leftPadding, baseLeft, "trailingPadding below horizontalPadding keeps leftPadding")
      compare(field.rightPadding, baseRight, "trailingPadding below horizontalPadding never shrinks rightPadding")

      field.trailingPadding = 34
      field.LayoutMirroring.enabled = true
      compare(field.leftPadding, baseLeft - field.horizontalPadding + 34, "RTL mirrors trailingPadding onto leftPadding")
      compare(field.rightPadding, baseRight, "RTL keeps normal rightPadding")
    }
  }
}
