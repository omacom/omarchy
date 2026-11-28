// Basic arithmetic for the search line: + - * / with parentheses, unary signs
// and decimals. A small parser rather than eval, because the input is whatever
// is being typed into the launcher.
var TOKEN = /\s*(\d+\.?\d*|\.\d+|[-+*\/()xX×÷])/y
// Far longer than any sum typed by hand, and short enough that a pasted wall of
// parentheses can't recurse its way to a stack overflow.
var MAX_LENGTH = 256

function tokenize(text) {
  var tokens = []
  var source = String(text || "").trim()
  if (source.length > MAX_LENGTH) return null
  TOKEN.lastIndex = 0
  while (TOKEN.lastIndex < source.length) {
    var match = TOKEN.exec(source)
    if (!match) return null
    tokens.push(match[1])
  }
  return tokens
}

// Returns the result as a string, or "" for anything that is not a complete
// calculation. A lone number needs no calculating, an unfinished "2+" or a
// division by zero has no answer to show, and past 2^53 a double can't hold every
// digit, so an answer there would look exact and be wrong. Small answers can come
// back as "1e-7"; Numbers.plain writes them out for display and copying.
function evaluate(text) {
  var tokens = tokenize(text)
  if (!tokens || tokens.length === 0) return ""

  var position = 0
  var hasOperator = false

  function isNumber(token) {
    return token !== undefined && /[\d.]/.test(token)
  }

  function factor() {
    var token = tokens[position++]
    if (token === "-") return -factor()
    if (token === "+") return factor()
    if (token === "(") {
      var inner = expression()
      if (tokens[position++] !== ")") throw new Error("unbalanced")
      return inner
    }
    if (!isNumber(token)) throw new Error("expected a number")
    var number = Number(token)
    if (number > Number.MAX_SAFE_INTEGER) throw new Error("too large to be exact")
    return number
  }

  function term() {
    var value = factor()
    while (["*", "x", "X", "×", "/", "÷"].indexOf(tokens[position]) !== -1) {
      var dividing = tokens[position] === "/" || tokens[position] === "÷"
      position++
      hasOperator = true
      value = dividing ? value / factor() : value * factor()
    }
    return value
  }

  function expression() {
    var value = term()
    while (tokens[position] === "+" || tokens[position] === "-") {
      var subtracting = tokens[position] === "-"
      position++
      hasOperator = true
      value = subtracting ? value - term() : value + term()
    }
    return value
  }

  try {
    var value = expression()
    if (position !== tokens.length || !hasOperator || !isFinite(value)) return ""
    if (Math.abs(value) > Number.MAX_SAFE_INTEGER) return ""
    if (Number.isSafeInteger(value)) return String(value)
    // Trim binary float noise, so 0.1+0.2 reads 0.3. Fifteen digits is all a
    // double guarantees, and fewer would round away digits that were typed.
    return String(Number(value.toPrecision(15)))
  } catch (e) {
    return ""
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    evaluate: evaluate
  }
}
