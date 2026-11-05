import QtQuick
import Quickshell.Io
import "Currency.js" as Currency
import "../../Commons/Numbers.js" as Numbers

// Turns the search line into a currency conversion. status is "" when the text
// is not one, otherwise "loading", "ready" or "failed". One fetch runs at a time;
// when it lands, the query is looked at again, so typing never queues requests.
Item {
  id: root

  property string query: ""
  property string status: ""
  // The answer as plain digits, and what it answers.
  property string value: ""
  property string amount: ""
  property string from: ""
  property string to: ""
  property string date: ""

  // Rates publish daily, so an open session only needs to look a few times.
  property int ratesLifetimeMs: 6 * 60 * 60 * 1000
  property int retryAfterMs: 60 * 1000

  property var currencies: null
  property var rates: ({})
  property var failedAt: ({})
  property string fetching: ""

  signal answerChanged()

  onQueryChanged: root.refresh()

  function apiPath(key) {
    return key === "currencies" ? "/v1/currencies.min.json" : "/v1/currencies/" + key + ".min.json"
  }

  function fetch(key) {
    root.fetching = key
    // The API asks clients to fall back from jsDelivr to its Cloudflare copy.
    // Only a finished response is printed, so bytes from an attempt that died
    // partway cannot end up in front of the fallback's.
    fetchProc.command = ["bash", "-c", 'body=$(curl -fsS --max-time 5 "$1") || body=$(curl -fsS --max-time 5 "$2") && printf "%s" "$body"', "bash",
      "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest" + root.apiPath(key),
      "https://latest.currency-api.pages.dev" + root.apiPath(key)]
    fetchProc.running = true
  }

  function failedRecently(key) {
    return root.failedAt[key] !== undefined && Date.now() - root.failedAt[key] < root.retryAfterMs
  }

  function publish(status, answer) {
    var next = answer || {}
    var value = next.value || ""
    var amount = next.amount || ""
    var from = next.from || ""
    var to = next.to || ""
    var date = next.date || ""
    if (root.status === status && root.value === value && root.amount === amount
        && root.from === from && root.to === to && root.date === date) return
    root.status = status
    root.value = value
    root.amount = amount
    root.from = from
    root.to = to
    root.date = date
    root.answerChanged()
  }

  function refresh() {
    var request = Currency.parse(root.query)
    if (!request) {
      root.publish("")
      return
    }

    if (!root.currencies) {
      // Text naming no currency we know, like "5 cats to dogs", stays off the
      // network. The list settles the rest, and only text that names two known
      // currencies has earned a row before it arrives.
      var listFailed = root.failedRecently("currencies")
      root.publish(request.known < 2 ? "" : (listFailed ? "failed" : "loading"))
      if (request.known > 0 && !listFailed && !fetchProc.running) root.fetch("currencies")
      return
    }

    if (root.currencies[request.from] === undefined || root.currencies[request.to] === undefined) {
      root.publish("")
      return
    }

    // Old rates still answer when a refresh fails, with their date on show.
    var known = root.rates[request.from]
    var stale = !known || Date.now() - known.fetchedAt >= root.ratesLifetimeMs
    if (stale && !root.failedRecently(request.from) && !fetchProc.running) root.fetch(request.from)

    if (known && known.rates[request.to] !== undefined) {
      // A rate that isn't a number, or an answer too big for one, has nothing
      // worth showing or copying.
      var converted = request.amount * known.rates[request.to]
      if (typeof known.rates[request.to] !== "number" || !isFinite(converted)) {
        root.publish("")
        return
      }
      root.publish("ready", {
        value: Numbers.plain(Currency.round(converted)),
        amount: Numbers.plain(request.amount),
        from: request.from.toUpperCase(),
        to: request.to.toUpperCase(),
        date: known.date
      })
    } else if (known) {
      root.publish("")
    } else {
      root.publish(root.failedRecently(request.from) ? "failed" : "loading")
    }
  }

  function isTable(value) {
    return !!value && typeof value === "object" && !Array.isArray(value)
  }

  function finishFetch() {
    var key = root.fetching
    var body = null
    try { body = JSON.parse(collector.text) } catch (e) { body = null }

    if (key === "currencies" && root.isTable(body) && Object.keys(body).length > 0) {
      root.currencies = body
    } else if (key !== "currencies" && root.isTable(body) && root.isTable(body[key])) {
      var next = ({})
      for (var code in root.rates) next[code] = root.rates[code]
      next[key] = { rates: body[key], date: String(body.date || ""), fetchedAt: Date.now() }
      root.rates = next
    } else {
      var failed = ({})
      for (var id in root.failedAt) failed[id] = root.failedAt[id]
      failed[key] = Date.now()
      root.failedAt = failed
    }

    root.fetching = ""
    root.refresh()
  }

  Process {
    id: fetchProc
    stdout: StdioCollector {
      id: collector
      waitForEnd: true
      onStreamFinished: Qt.callLater(root.finishFetch)
    }
  }
}
