// A number in plain digits. String() switches to exponents below 1e-6 and from
// 1e21 up, which nobody reads as an amount and few programs accept when pasted.
function plain(value) {
  var text = String(Number(value))
  var match = /^(-?)(\d)(?:\.(\d+))?e([+-]\d+)$/.exec(text)
  if (!match) return text
  var fraction = match[3] || ""
  var exponent = Number(match[4])
  if (exponent < 0) return match[1] + "0." + "0".repeat(-exponent - 1) + match[2] + fraction
  return match[1] + match[2] + fraction + "0".repeat(exponent - fraction.length)
}

// A number written with a language's decimal separator and digits from the
// registry, ungrouped: format(13.14, 1, ",", "0") is "13,1". Without
// decimals the value is written as it is. default/i18n/plural.jq's
// localize_number does the same for omarchy-i18n.
function format(value, decimals, decimal, zeroDigit) {
  var number = Number(value)
  if (!isFinite(number)) return String(value)
  var text = decimals === undefined ? plain(number) : number.toFixed(decimals)
  if (decimal && decimal !== ".") text = text.replace(".", decimal)
  if (zeroDigit && zeroDigit !== "0") {
    var zero = zeroDigit.charCodeAt(0)
    text = text.replace(/[0-9]/g, function(digit) { return String.fromCharCode(zero + digit.charCodeAt(0) - 48) })
  }
  return text
}

if (typeof module !== "undefined") {
  module.exports = { format: format, plain: plain }
}
