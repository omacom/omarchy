// Basic arithmetic for the search line: + - * / with parentheses, unary signs
// and decimals. A small parser rather than eval, because the input is whatever
// is being typed into the launcher.
var TOKEN = /\s*(\d+\.?\d*|\.\d+|[-+*\/()x×÷])/y

function tokenize(text) {
  var tokens = []
  var source = String(text || "").trim()
  TOKEN.lastIndex = 0
  while (TOKEN.lastIndex < source.length) {
    var match = TOKEN.exec(source)
    if (!match) return null
    tokens.push(match[1])
  }
  return tokens
}

// Returns the result as a string, or "" for anything that is not a complete
// calculation. A lone number needs no calculating, and an unfinished "2+" or a
// division by zero has no answer to show.
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
    return Number(token)
  }

  function term() {
    var value = factor()
    while (["*", "x", "×", "/", "÷"].indexOf(tokens[position]) !== -1) {
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
    // Trim binary float noise, so 0.1+0.2 reads 0.3.
    return String(Number(value.toPrecision(12)))
  } catch (e) {
    return ""
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    evaluate: evaluate
  }
}
