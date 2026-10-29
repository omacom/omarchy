// A number written with a language's decimal separator and digits from the
// registry, ungrouped: format(13.14, 1, ",", "0") is "13,1". Without
// decimals the value is written as it is. default/i18n/plural.jq's
// localize_number does the same for omarchy-i18n.
function format(value, decimals, decimal, zeroDigit) {
  var number = Number(value)
  if (!isFinite(number)) return String(value)
  var text = decimals === undefined ? String(number) : number.toFixed(decimals)
  if (decimal && decimal !== ".") text = text.replace(".", decimal)
  if (zeroDigit && zeroDigit !== "0") {
    var zero = zeroDigit.charCodeAt(0)
    text = text.replace(/[0-9]/g, function(digit) { return String.fromCharCode(zero + digit.charCodeAt(0) - 48) })
  }
  return text
}
