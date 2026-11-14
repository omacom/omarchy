// WorkerScript that cuts a large text into display rows for the virtualized
// view: a row ends at a line break or after MAX_ROW characters, so one very
// long line (minified JSON, say) does not become one enormous text item.
//
// Request: { id, text }
// Reply:   { id, starts, lines } where row i covers [starts[i], starts[i + 1])
//          (the last row runs to the end), lines[i] is its 1-based line number,
//          or 0 when the row continues the line above.

var MAX_ROW = 2000

WorkerScript.onMessage = function(request) {
  var text = request.text
  var starts = [0]
  var lines = [1]
  var line = 1
  var rowStart = 0
  var n = text.length
  for (;;) {
    var next = text.indexOf("\n", rowStart)
    var end = next < 0 ? n : next
    // Long lines are cut into pieces, never inside a surrogate pair.
    while (end - rowStart > MAX_ROW) {
      var cut = rowStart + MAX_ROW
      var code = text.charCodeAt(cut)
      if (code >= 0xdc00 && code <= 0xdfff) cut--
      starts.push(cut)
      lines.push(0)
      rowStart = cut
    }
    if (next < 0) break
    rowStart = next + 1
    line++
    starts.push(rowStart)
    lines.push(line)
  }
  WorkerScript.sendMessage({ id: request.id, starts: starts, lines: lines })
}
