// Unicode cell-art model. QML imports this; Node tests load it as CommonJS.

var QUAD_UL = 1
var QUAD_UR = 2
var QUAD_LL = 4
var QUAD_LR = 8
var QUAD_BITS = [QUAD_UL, QUAD_UR, QUAD_LL, QUAD_LR]

var LINE_N = 1
var LINE_E = 2
var LINE_S = 4
var LINE_W = 8

var BLOCK_GLYPHS = [
  " ",
  "\u2598",
  "\u259d",
  "\u2580",
  "\u2596",
  "\u258c",
  "\u259e",
  "\u259b",
  "\u2597",
  "\u259a",
  "\u2590",
  "\u259c",
  "\u2584",
  "\u2599",
  "\u259f",
  "\u2588"
]

var SHADE_GLYPHS = [" ", "\u2591", "\u2592", "\u2593", "\u2588"]

// Index is N=1 E=2 S=4 W=8. A set bit is a stroke from the cell centre to that edge.
var SINGLE_LINE_GLYPHS = [
  " ",
  "\u2502",
  "\u2500",
  "\u2514",
  "\u2502",
  "\u2502",
  "\u250c",
  "\u251c",
  "\u2500",
  "\u2518",
  "\u2500",
  "\u2534",
  "\u2510",
  "\u2524",
  "\u252c",
  "\u253c"
]

var DOUBLE_LINE_GLYPHS = [
  " ",
  "\u2551",
  "\u2550",
  "\u255a",
  "\u2551",
  "\u2551",
  "\u2554",
  "\u2560",
  "\u2550",
  "\u255d",
  "\u2550",
  "\u2569",
  "\u2557",
  "\u2563",
  "\u2566",
  "\u256c"
]

var BLOCK_BY_GLYPH = invertGlyphs(BLOCK_GLYPHS)
var SHADE_BY_GLYPH = {
  "\u2591": 1,
  "\u2592": 2,
  "\u2593": 3
}
var LINE_BY_GLYPH = invertLineGlyphs()

function invertGlyphs(list) {
  var map = {}
  for (var i = 1; i < list.length; i++) map[list[i]] = i
  return map
}

function invertLineGlyphs() {
  var map = {}
  var i
  for (i = 1; i < SINGLE_LINE_GLYPHS.length; i++) {
    map[SINGLE_LINE_GLYPHS[i]] = { bits: i, style: "single" }
  }
  for (i = 1; i < DOUBLE_LINE_GLYPHS.length; i++) {
    map[DOUBLE_LINE_GLYPHS[i]] = { bits: i, style: "double" }
  }
  return map
}

function emptyCell() {
  return { kind: "empty" }
}

function cloneCell(cell) {
  if (!cell) return emptyCell()
  var copy = {}
  for (var key in cell) copy[key] = cell[key]
  return copy
}

function createCanvas(cols, rows) {
  var width = Math.max(1, Math.floor(Number(cols) || 1))
  var height = Math.max(1, Math.floor(Number(rows) || 1))
  var cells = []
  var r
  var c
  for (r = 0; r < height; r++) {
    cells[r] = []
    for (c = 0; c < width; c++) cells[r][c] = emptyCell()
  }
  return { cols: width, rows: height, cells: cells }
}

function cloneCanvas(canvas) {
  var copy = createCanvas(canvas.cols, canvas.rows)
  var r
  var c
  for (r = 0; r < canvas.rows; r++) {
    for (c = 0; c < canvas.cols; c++) copy.cells[r][c] = cloneCell(canvas.cells[r][c])
  }
  return copy
}

function inBounds(canvas, col, row) {
  return col >= 0 && row >= 0 && col < canvas.cols && row < canvas.rows
}

function cellAt(canvas, col, row) {
  if (!inBounds(canvas, col, row)) return emptyCell()
  return canvas.cells[row][col] || emptyCell()
}

function writeCell(canvas, col, row, cell) {
  if (!inBounds(canvas, col, row)) return
  canvas.cells[row][col] = cell && cell.kind ? cell : emptyCell()
}

function lineBits(cell) {
  if (!cell || cell.kind !== "line") return 0
  return (cell.n ? LINE_N : 0) | (cell.e ? LINE_E : 0) | (cell.s ? LINE_S : 0) | (cell.w ? LINE_W : 0)
}

function lineFromBits(bits, style) {
  return {
    kind: "line",
    n: !!(bits & LINE_N),
    e: !!(bits & LINE_E),
    s: !!(bits & LINE_S),
    w: !!(bits & LINE_W),
    style: style === "double" ? "double" : "single"
  }
}

function cellGlyph(cell) {
  if (!cell || cell.kind === "empty") return " "
  if (cell.kind === "block") return BLOCK_GLYPHS[cell.bits & 15] || " "
  if (cell.kind === "braille") {
    if (!cell.bits) return " "
    return String.fromCharCode(0x2800 + (cell.bits & 255))
  }
  if (cell.kind === "shade") return SHADE_GLYPHS[cell.level] || " "
  if (cell.kind === "line") {
    var bits = lineBits(cell)
    var table = cell.style === "double" ? DOUBLE_LINE_GLYPHS : SINGLE_LINE_GLYPHS
    return table[bits] || " "
  }
  if (cell.kind === "literal") return cell.ch || " "
  return " "
}

function glyphAt(canvas, col, row) {
  return cellGlyph(cellAt(canvas, col, row))
}

function setBlockBits(canvas, col, row, bits) {
  var value = bits & 15
  if (value === 0) writeCell(canvas, col, row, emptyCell())
  else writeCell(canvas, col, row, { kind: "block", bits: value })
}

function setQuadrant(canvas, col, row, quadrant, filled) {
  var bit = QUAD_BITS[quadrant]
  if (!bit) return
  var cell = cellAt(canvas, col, row)
  var current = cell.kind === "block" ? cell.bits : 0
  if (filled) current |= bit
  else current &= ~bit
  setBlockBits(canvas, col, row, current)
}

function brailleBit(dx, dy) {
  if (dy < 3) return 1 << (dy + dx * 3)
  return 1 << (6 + dx)
}

function setBrailleDot(canvas, col, row, dx, dy, filled) {
  if (dx !== 0 && dx !== 1) return
  if (dy < 0 || dy > 3) return
  var cell = cellAt(canvas, col, row)
  var current = cell.kind === "braille" ? cell.bits : 0
  var bit = brailleBit(dx, dy)
  if (filled) current |= bit
  else current &= ~bit
  if (current === 0) writeCell(canvas, col, row, emptyCell())
  else writeCell(canvas, col, row, { kind: "braille", bits: current & 255 })
}

function setShade(canvas, col, row, level) {
  var value = Math.max(0, Math.min(4, Math.floor(Number(level) || 0)))
  if (value === 0) writeCell(canvas, col, row, emptyCell())
  else writeCell(canvas, col, row, { kind: "shade", level: value })
}

function setLiteral(canvas, col, row, ch) {
  var s = String(ch || "")
  if (!s || s === " ") writeCell(canvas, col, row, emptyCell())
  else writeCell(canvas, col, row, { kind: "literal", ch: s.charAt(0) })
}

function writeText(canvas, col, row, text) {
  var s = String(text || "")
  var i
  for (i = 0; i < s.length; i++) {
    if (!inBounds(canvas, col + i, row)) break
    setLiteral(canvas, col + i, row, s.charAt(i))
  }
  return i
}

function clamp01(value, size) {
  if (size <= 0) return 0
  var n = Number(value)
  if (n < 0) n = 0
  if (n >= size) n = size - 1e-9
  return n / size
}

function quadrantAt(localX, localY, cellW, cellH) {
  var x = clamp01(localX, cellW)
  var y = clamp01(localY, cellH)
  return (y < 0.5 ? 0 : 2) + (x < 0.5 ? 0 : 1)
}

function brailleDotAt(localX, localY, cellW, cellH) {
  var x = clamp01(localX, cellW)
  var y = clamp01(localY, cellH)
  return {
    dx: x < 0.5 ? 0 : 1,
    dy: Math.min(3, Math.floor(y * 4))
  }
}

function bresenham(c0, r0, c1, r1) {
  var points = []
  var dc = Math.abs(c1 - c0)
  var dr = Math.abs(r1 - r0)
  var sc = c0 < c1 ? 1 : -1
  var sr = r0 < r1 ? 1 : -1
  var err = dc - dr
  var c = c0
  var r = r0
  while (true) {
    points.push({ c: c, r: r })
    if (c === c1 && r === r1) break
    var e2 = 2 * err
    if (e2 > -dr) {
      err -= dr
      c += sc
    }
    if (e2 < dc) {
      err += dc
      r += sr
    }
  }
  return points
}

function neighbor(canvas, col, row, dc, dr) {
  return cellAt(canvas, col + dc, row + dr)
}

function ensureLineCell(canvas, col, row, style) {
  var cell = cellAt(canvas, col, row)
  if (cell.kind === "line") {
    cell.style = style === "double" ? "double" : "single"
    writeCell(canvas, col, row, cell)
    return cell
  }
  cell = lineFromBits(0, style)
  writeCell(canvas, col, row, cell)
  return cell
}

function connectLine(canvas, col, row, dc, dr, fromBit, toBit) {
  var here = cellAt(canvas, col, row)
  var there = neighbor(canvas, col, row, dc, dr)
  if (here.kind !== "line" || there.kind !== "line") return
  here = cloneCell(here)
  there = cloneCell(there)
  if (fromBit === LINE_N) here.n = true
  if (fromBit === LINE_E) here.e = true
  if (fromBit === LINE_S) here.s = true
  if (fromBit === LINE_W) here.w = true
  if (toBit === LINE_N) there.n = true
  if (toBit === LINE_E) there.e = true
  if (toBit === LINE_S) there.s = true
  if (toBit === LINE_W) there.w = true
  writeCell(canvas, col, row, here)
  writeCell(canvas, col + dc, row + dr, there)
}

function lineStroke(canvas, c0, r0, c1, r1, style) {
  var points = bresenham(c0, r0, c1, r1)
  var i
  var p
  var lineStyle = style === "double" ? "double" : "single"

  if (points.length === 1) {
    if (inBounds(canvas, points[0].c, points[0].r)) {
      writeCell(canvas, points[0].c, points[0].r, lineFromBits(15, lineStyle))
    }
    return
  }

  for (i = 0; i < points.length; i++) {
    p = points[i]
    if (inBounds(canvas, p.c, p.r)) ensureLineCell(canvas, p.c, p.r, lineStyle)
  }

  for (i = 0; i < points.length; i++) {
    p = points[i]
    if (!inBounds(canvas, p.c, p.r)) continue
    connectLine(canvas, p.c, p.r, 0, -1, LINE_N, LINE_S)
    connectLine(canvas, p.c, p.r, 1, 0, LINE_E, LINE_W)
    connectLine(canvas, p.c, p.r, 0, 1, LINE_S, LINE_N)
    connectLine(canvas, p.c, p.r, -1, 0, LINE_W, LINE_E)
  }
}

function rectangle(canvas, c0, r0, c1, r1, style) {
  var left = Math.min(c0, c1)
  var right = Math.max(c0, c1)
  var top = Math.min(r0, r1)
  var bottom = Math.max(r0, r1)
  lineStroke(canvas, left, top, right, top, style)
  lineStroke(canvas, right, top, right, bottom, style)
  lineStroke(canvas, right, bottom, left, bottom, style)
  lineStroke(canvas, left, bottom, left, top, style)
}

function cellsEqual(a, b) {
  if (!a || !b) return false
  if (a.kind !== b.kind) return false
  if (a.kind === "empty") return true
  if (a.kind === "block") return a.bits === b.bits
  if (a.kind === "braille") return a.bits === b.bits
  if (a.kind === "shade") return a.level === b.level
  if (a.kind === "line") return lineBits(a) === lineBits(b) && a.style === b.style
  if (a.kind === "literal") return a.ch === b.ch
  return false
}

function floodFill(canvas, col, row, replacement) {
  if (!inBounds(canvas, col, row)) return
  var target = cloneCell(cellAt(canvas, col, row))
  var fill = replacement && replacement.kind ? cloneCell(replacement) : emptyCell()
  if (cellsEqual(target, fill)) return
  var queue = [{ c: col, r: row }]
  var seen = {}
  var key
  var next
  var cell
  while (queue.length) {
    next = queue.shift()
    key = next.c + "," + next.r
    if (seen[key]) continue
    seen[key] = true
    if (!inBounds(canvas, next.c, next.r)) continue
    cell = cellAt(canvas, next.c, next.r)
    if (!cellsEqual(cell, target)) continue
    writeCell(canvas, next.c, next.r, cloneCell(fill))
    queue.push({ c: next.c + 1, r: next.r })
    queue.push({ c: next.c - 1, r: next.r })
    queue.push({ c: next.c, r: next.r + 1 })
    queue.push({ c: next.c, r: next.r - 1 })
  }
}

function createHistory() {
  return { past: [], future: [], max: 100 }
}

function canUndo(history) {
  return !!(history && history.past && history.past.length >= 2)
}

function canRedo(history) {
  return !!(history && history.future && history.future.length > 0)
}

function checkpoint(history, canvas) {
  history.past.push(cloneCanvas(canvas))
  if (history.past.length > history.max) history.past.shift()
  history.future = []
}

function undo(history) {
  if (history.past.length < 2) return cloneCanvas(history.past[0] || createCanvas(1, 1))
  history.future.push(history.past.pop())
  return cloneCanvas(history.past[history.past.length - 1])
}

function redo(history) {
  if (history.future.length === 0) return cloneCanvas(history.past[history.past.length - 1] || createCanvas(1, 1))
  var canvas = history.future.pop()
  history.past.push(canvas)
  return cloneCanvas(canvas)
}

function decodeChar(ch) {
  if (!ch || ch === " ") return emptyCell()
  if (BLOCK_BY_GLYPH[ch] !== undefined) return { kind: "block", bits: BLOCK_BY_GLYPH[ch] }
  if (SHADE_BY_GLYPH[ch] !== undefined) return { kind: "shade", level: SHADE_BY_GLYPH[ch] }
  var code = ch.charCodeAt(0)
  if (code >= 0x2800 && code <= 0x28ff) {
    var bits = code - 0x2800
    if (bits === 0) return emptyCell()
    return { kind: "braille", bits: bits }
  }
  if (LINE_BY_GLYPH[ch]) return lineFromBits(LINE_BY_GLYPH[ch].bits, LINE_BY_GLYPH[ch].style)
  return { kind: "literal", ch: ch }
}

function parse(text) {
  var raw = String(text || "").replace(/\r\n/g, "\n").replace(/\r/g, "\n")
  var lines = raw.split("\n")
  if (lines.length && lines[lines.length - 1] === "") lines.pop()
  if (lines.length === 0) return createCanvas(1, 1)
  var cols = 1
  var r
  var c
  var chars
  for (r = 0; r < lines.length; r++) {
    chars = Array.from(lines[r])
    if (chars.length > cols) cols = chars.length
  }
  var canvas = createCanvas(cols, lines.length)
  for (r = 0; r < lines.length; r++) {
    chars = Array.from(lines[r])
    for (c = 0; c < chars.length; c++) writeCell(canvas, c, r, decodeChar(chars[c]))
  }
  return canvas
}

function serialize(canvas) {
  var lines = []
  var r
  var c
  var line
  for (r = 0; r < canvas.rows; r++) {
    line = ""
    for (c = 0; c < canvas.cols; c++) line += glyphAt(canvas, c, r)
    lines.push(line.replace(/[ ]+$/, ""))
  }
  return lines.join("\n") + "\n"
}

function render(canvas) {
  var lines = []
  var r
  var c
  var line
  for (r = 0; r < canvas.rows; r++) {
    line = ""
    for (c = 0; c < canvas.cols; c++) line += glyphAt(canvas, c, r)
    lines.push(line)
  }
  return lines.join("\n")
}

function resize(canvas, cols, rows) {
  var next = createCanvas(cols, rows)
  var r
  var c
  var height = Math.min(canvas.rows, next.rows)
  var width = Math.min(canvas.cols, next.cols)
  for (r = 0; r < height; r++) {
    for (c = 0; c < width; c++) next.cells[r][c] = cloneCell(canvas.cells[r][c])
  }
  return next
}

function pad(canvas, top, right, bottom, left) {
  var t = Math.max(0, Math.floor(Number(top) || 0))
  var rgt = Math.max(0, Math.floor(Number(right) || 0))
  var b = Math.max(0, Math.floor(Number(bottom) || 0))
  var l = Math.max(0, Math.floor(Number(left) || 0))
  var next = createCanvas(canvas.cols + l + rgt, canvas.rows + t + b)
  var r
  var c
  for (r = 0; r < canvas.rows; r++) {
    for (c = 0; c < canvas.cols; c++) next.cells[r + t][c + l] = cloneCell(canvas.cells[r][c])
  }
  return next
}

function crop(canvas, top, right, bottom, left) {
  var t = Math.max(0, Math.floor(Number(top) || 0))
  var rgt = Math.max(0, Math.floor(Number(right) || 0))
  var b = Math.max(0, Math.floor(Number(bottom) || 0))
  var l = Math.max(0, Math.floor(Number(left) || 0))
  if (t > canvas.rows - 1) t = canvas.rows - 1
  if (b > canvas.rows - 1 - t) b = canvas.rows - 1 - t
  if (l > canvas.cols - 1) l = canvas.cols - 1
  if (rgt > canvas.cols - 1 - l) rgt = canvas.cols - 1 - l
  var next = createCanvas(canvas.cols - l - rgt, canvas.rows - t - b)
  var r
  var c
  for (r = 0; r < next.rows; r++) {
    for (c = 0; c < next.cols; c++) next.cells[r][c] = cloneCell(canvas.cells[r + t][c + l])
  }
  return next
}

function eraseCell(canvas, col, row) {
  writeCell(canvas, col, row, emptyCell())
}

function eraseHalf(canvas, col, row, localX, localY, cellW, cellH) {
  var cell = cellAt(canvas, col, row)
  if (cell.kind === "block") {
    var x = clamp01(localX, cellW)
    var y = clamp01(localY, cellH)
    var bits = cell.bits
    if (Math.abs(y - 0.5) >= Math.abs(x - 0.5)) {
      bits &= y < 0.5 ? ~(QUAD_UL | QUAD_UR) : ~(QUAD_LL | QUAD_LR)
    } else {
      bits &= x < 0.5 ? ~(QUAD_UL | QUAD_LL) : ~(QUAD_UR | QUAD_LR)
    }
    setBlockBits(canvas, col, row, bits)
    return
  }
  if (cell.kind === "braille") {
    var dot = brailleDotAt(localX, localY, cellW, cellH)
    setBrailleDot(canvas, col, row, dot.dx, dot.dy, false)
    return
  }
  eraseCell(canvas, col, row)
}

function withStroke(canvas, kind, c0, r0, c1, r1, style) {
  var next = cloneCanvas(canvas)
  if (kind === "rect") rectangle(next, c0, r0, c1, r1, style)
  else lineStroke(next, c0, r0, c1, r1, style)
  return next
}

function backupPath(path) {
  return String(path || "") + ".bak"
}

// Qt.LeftButton is 1, Qt.RightButton is 2. Keep the numbers here so QML
// pointer handling cannot treat an unset button as "right" / erase.
var LEFT_BUTTON = 1
var RIGHT_BUTTON = 2

function pointerIntent(button, buttons, tool) {
  var b = Number(button)
  var bs = Number(buttons)
  if (!isFinite(b)) b = 0
  if (!isFinite(bs)) bs = 0
  var left = b === LEFT_BUTTON || (bs & LEFT_BUTTON) !== 0
  var right = b === RIGHT_BUTTON || (bs & RIGHT_BUTTON) !== 0
  if (left) return tool === "eraser" ? "erase" : "paint"
  if (right) return "erase"
  return "ignore"
}

function applyStamp(canvas, spec) {
  if (!canvas || !spec) return
  var tool = spec.tool
  var intent = spec.intent
  var col = spec.col
  var row = spec.row
  var lx = spec.lx
  var ly = spec.ly
  var cellW = spec.cellW > 0 ? spec.cellW : 10
  var cellH = spec.cellH > 0 ? spec.cellH : 20
  if (intent === "erase" || tool === "eraser") {
    if (tool === "fill") floodFill(canvas, col, row, { kind: "empty" })
    else eraseHalf(canvas, col, row, lx, ly, cellW, cellH)
    return
  }
  if (intent !== "paint") return
  if (tool === "block") {
    setQuadrant(canvas, col, row, quadrantAt(lx, ly, cellW, cellH), true)
  } else if (tool === "braille") {
    var dot = brailleDotAt(lx, ly, cellW, cellH)
    setBrailleDot(canvas, col, row, dot.dx, dot.dy, true)
  } else if (tool === "shade") {
    setShade(canvas, col, row, spec.shadeLevel)
  } else if (tool === "fill") {
    floodFill(canvas, col, row, { kind: "shade", level: spec.shadeLevel })
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    createCanvas: createCanvas,
    cloneCanvas: cloneCanvas,
    parse: parse,
    serialize: serialize,
    render: render,
    resize: resize,
    pad: pad,
    crop: crop,
    glyphAt: glyphAt,
    cellAt: cellAt,
    cellGlyph: cellGlyph,
    setBlockBits: setBlockBits,
    setQuadrant: setQuadrant,
    setBrailleDot: setBrailleDot,
    setShade: setShade,
    setLiteral: setLiteral,
    writeText: writeText,
    quadrantAt: quadrantAt,
    brailleDotAt: brailleDotAt,
    lineStroke: lineStroke,
    rectangle: rectangle,
    floodFill: floodFill,
    eraseCell: eraseCell,
    eraseHalf: eraseHalf,
    withStroke: withStroke,
    backupPath: backupPath,
    LEFT_BUTTON: LEFT_BUTTON,
    RIGHT_BUTTON: RIGHT_BUTTON,
    pointerIntent: pointerIntent,
    applyStamp: applyStamp,
    createHistory: createHistory,
    canUndo: canUndo,
    canRedo: canRedo,
    checkpoint: checkpoint,
    undo: undo,
    redo: redo,
    QUAD_UL: QUAD_UL,
    QUAD_UR: QUAD_UR,
    QUAD_LL: QUAD_LL,
    QUAD_LR: QUAD_LR
  }
}
