// Quick math for menu search: typing "=25*3" offers "= 75". The leading "="
// keeps searches that merely contain numbers from turning into sums.
//
// A small recursive-descent parser, never eval(), so typed text can't run
// code. Supports + - * / ^ and **, x or × for times, ÷ for divide,
// parentheses, unary minus, digit grouping ("1,250"), percentages
// ("15% of 340", "200 + 10%"); "=2024" answers a bare number too.
//
// `decimal` is the language's decimal separator; the other of "." and ","
// is read as digit grouping and dropped. Digits may be typed the way the menu
// shows them (Persian ۱۲۳, Bengali ১২৩), and Persian's "٫" works as the
// decimal separator.

// The zero of each digit set a language in the registry may use, beyond ASCII.
var nativeZeros = ["\u0660", "\u06F0", "\u0966", "\u09E6"]

// Native digits become ASCII, "٫" becomes the decimal separator, and "٬"
// (Arabic digit grouping) is dropped.
function normalize(text, decimal) {
  var s = String(text)
  for (var z = 0; z < nativeZeros.length; z++) {
    var zero = nativeZeros[z].charCodeAt(0)
    s = s.replace(new RegExp("[" + nativeZeros[z] + "-" + String.fromCharCode(zero + 9) + "]", "g"), function(digit) {
      return String(digit.charCodeAt(0) - zero)
    })
  }
  return s.replace(/\u066B/g, decimal).replace(/\u066C/g, "")
}

function tokenize(text, decimal) {
  var group = decimal === "," ? "." : ","
  var s = String(text).toLowerCase().replace(/\*\*/g, "^").replace(/[×x]/g, "*").replace(/÷/g, "/")
  var tokens = []
  var i = 0
  while (i < s.length) {
    var c = s[i]
    if (c === " " || c === "\t") {
      i++
    } else if (/[0-9.,]/.test(c)) {
      var j = i
      while (j < s.length && /[0-9.,]/.test(s[j])) j++
      var raw = s.slice(i, j).split(group).join("").replace(decimal, ".")
      if (!/^(\d+\.?\d*|\.\d+)$/.test(raw)) return null
      tokens.push({ type: "num", value: parseFloat(raw) })
      i = j
    } else if (s.slice(i, i + 2) === "of") {
      tokens.push({ type: "of" })
      i += 2
    } else if ("+-*/^%()".indexOf(c) !== -1) {
      tokens.push({ type: c })
      i++
    } else {
      return null
    }
  }
  return tokens
}

function parse(tokens) {
  var pos = 0

  function peek() { return tokens[pos] }
  function accept(type) {
    if (tokens[pos] && tokens[pos].type === type) {
      pos++
      return true
    }
    return false
  }

  // expr := term (('+' | '-') term)*
  // A trailing percentage is of the left side, like a desk calculator:
  // "200 + 10%" is 220.
  function expr() {
    var left = term()
    while (peek() && (peek().type === "+" || peek().type === "-")) {
      var op = tokens[pos++].type
      var right = term()
      var amount = right.percent ? left.value * right.value : right.value
      left = { value: op === "+" ? left.value + amount : left.value - amount }
    }
    return left
  }

  // term := unary (('*' | '/' | 'of') unary)*
  function term() {
    var left = unary()
    while (peek() && (peek().type === "*" || peek().type === "/" || peek().type === "of")) {
      var op = tokens[pos++].type
      var right = unary()
      left = { value: op === "/" ? left.value / right.value : left.value * right.value }
    }
    return left
  }

  // A sign applies after the power, as in math: -2^2 is -4.
  // unary := ('-' | '+') unary | power
  function unary() {
    if (accept("-")) {
      var negated = unary()
      return { value: -negated.value, percent: negated.percent }
    }
    if (accept("+")) return unary()
    return power()
  }

  // power := percent ('^' unary)?, right-associative, and 2^-2 still works
  function power() {
    var base = percent()
    if (accept("^")) return { value: Math.pow(base.value, unary().value) }
    return base
  }

  // percent := primary '%'?
  function percent() {
    var value = primary()
    if (accept("%")) return { value: value.value / 100, percent: true }
    return value
  }

  // primary := number | '(' expr ')'
  function primary() {
    var token = tokens[pos++]
    if (!token) throw new Error("unexpected end")
    if (token.type === "num") return { value: token.value }
    if (token.type === "(") {
      var inner = expr()
      if (!accept(")")) throw new Error("missing )")
      return { value: inner.value, percent: inner.percent }
    }
    throw new Error("unexpected " + token.type)
  }

  var result = expr()
  if (pos !== tokens.length) throw new Error("trailing input")
  return result.value
}

// The answer as a number, or null unless the text is "=" then arithmetic.
function evaluate(text, decimal) {
  decimal = decimal === "," ? "," : "."
  var s = normalize(String(text || "").trim(), decimal)
  if (s.charAt(0) !== "=") return null
  s = s.slice(1)
  if (!/\d/.test(s)) return null

  var tokens = tokenize(s, decimal)
  if (!tokens || tokens.length === 0) return null

  try {
    var value = parse(tokens)
    if (!isFinite(value)) return null
    // Twelve significant digits hides float noise: 0.1 + 0.2 is 0.3.
    value = Number(value.toPrecision(12))
    return value === 0 ? 0 : value
  } catch (e) {
    return null
  }
}

if (typeof module !== "undefined") {
  module.exports = { evaluate: evaluate }
}
