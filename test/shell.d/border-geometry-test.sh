#!/bin/bash
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

const source = fs.readFileSync(path.join(root, 'shell/Commons/BorderGeometry.js'), 'utf8').replace(/^\.pragma library\n/, '')
const geometry = {}
vm.createContext(geometry)
vm.runInContext(source, geometry)

assertDeepEqual(
  geometry.parseWidthSpec('2 4 6 8', 1),
  { top: 2, right: 4, bottom: 6, left: 8 },
  'border geometry parses four-sided widths'
)

assertDeepEqual(
  geometry.parseWidthSpec('2 4', 1),
  { top: 2, right: 4, bottom: 2, left: 4 },
  'border geometry parses CSS two-value widths'
)

const gradient = geometry.parseGradientSpec('rgba(010203ee) rgba(040506ee) 45deg', '#336699', 1)
assertEqual(gradient.colors[0], '#010203ee', 'border geometry parses first rgba gradient stop')
assertEqual(gradient.colors[1], '#040506ee', 'border geometry parses second rgba gradient stop')
assertEqual(gradient.angle, 45, 'border geometry parses gradient angle')
assert(gradient.enabled, 'border geometry marks multi-stop gradients enabled')

assertEqual(
  geometry.canonicalColor('0xee33ccff', 1),
  '#33ccffee',
  'border geometry converts legacy ARGB color to QML RGBA hex'
)

function pathsFor(widths, radius = 10, w = 100, h = 50) {
  return geometry.borderPaths(w, h, radius, widths)
}

function assertValidPaths(paths, description) {
  const data = paths.join(' ')
  assert(!/(NaN|Infinity|0\.001)/.test(data), `${description} has finite exact geometry`)
  assert(!/\bA\s+0(?:\.0+)?\s/.test(data), `${description} has no zero-width arcs`)
  assert(!/\bA\s+\S+\s+0(?:\.0+)?\s/.test(data), `${description} has no zero-height arcs`)
  for (const borderPath of paths) {
    assert(/^M\s/.test(borderPath) && /\sZ$/.test(borderPath), `${description} emits closed contours`)
  }
}

function vectorAngle(ux, uy, vx, vy) {
  const dot = ux * vx + uy * vy
  const length = Math.sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy))
  const angle = Math.acos(Math.max(-1, Math.min(1, dot / length)))
  return ux * vy - uy * vx < 0 ? -angle : angle
}

function flattenArc(from, rx, ry, largeArc, sweep, to) {
  const dx = (from.x - to.x) / 2
  const dy = (from.y - to.y) / 2
  let scale = dx * dx / (rx * rx) + dy * dy / (ry * ry)
  if (scale > 1) {
    scale = Math.sqrt(scale)
    rx *= scale
    ry *= scale
  }

  const numerator = Math.max(0, rx * rx * ry * ry - rx * rx * dy * dy - ry * ry * dx * dx)
  const denominator = rx * rx * dy * dy + ry * ry * dx * dx
  const factor = (largeArc === sweep ? -1 : 1) * Math.sqrt(numerator / denominator)
  const centerXPrime = factor * rx * dy / ry
  const centerYPrime = factor * -ry * dx / rx
  const centerX = centerXPrime + (from.x + to.x) / 2
  const centerY = centerYPrime + (from.y + to.y) / 2
  const startX = (dx - centerXPrime) / rx
  const startY = (dy - centerYPrime) / ry
  const endX = (-dx - centerXPrime) / rx
  const endY = (-dy - centerYPrime) / ry
  const startAngle = vectorAngle(1, 0, startX, startY)
  let deltaAngle = vectorAngle(startX, startY, endX, endY)
  if (!sweep && deltaAngle > 0) deltaAngle -= 2 * Math.PI
  if (sweep && deltaAngle < 0) deltaAngle += 2 * Math.PI

  const points = []
  const steps = 16
  for (let step = 1; step <= steps; step++) {
    const angle = startAngle + deltaAngle * step / steps
    points.push({ x: centerX + rx * Math.cos(angle), y: centerY + ry * Math.sin(angle) })
  }
  return points
}

function flattenPaths(paths) {
  const contours = []
  for (const pathData of paths) {
    const tokens = pathData.trim().split(/\s+/)
    let index = 0
    let current = null
    let contour = null
    while (index < tokens.length) {
      const command = tokens[index++]
      if (command === 'M') {
        current = { x: Number(tokens[index++]), y: Number(tokens[index++]) }
        contour = [current]
        contours.push(contour)
      } else if (command === 'L') {
        current = { x: Number(tokens[index++]), y: Number(tokens[index++]) }
        contour.push(current)
      } else if (command === 'H') {
        current = { x: Number(tokens[index++]), y: current.y }
        contour.push(current)
      } else if (command === 'V') {
        current = { x: current.x, y: Number(tokens[index++]) }
        contour.push(current)
      } else if (command === 'A') {
        const rx = Number(tokens[index++])
        const ry = Number(tokens[index++])
        const rotation = Number(tokens[index++])
        const largeArc = Number(tokens[index++])
        const sweep = Number(tokens[index++])
        const end = { x: Number(tokens[index++]), y: Number(tokens[index++]) }
        if (rotation !== 0) throw new Error('test path flattener only supports unrotated border arcs')
        contour.push(...flattenArc(current, rx, ry, largeArc, sweep, end))
        current = end
      } else if (command === 'Z') {
        contour.push(contour[0])
        current = contour[0]
      } else {
        throw new Error(`unsupported path command ${command}`)
      }
    }
  }
  return contours
}

function pathContains(paths, x, y) {
  let winding = 0
  for (const contour of flattenPaths(paths)) {
    for (let index = 0; index < contour.length - 1; index++) {
      const from = contour[index]
      const to = contour[index + 1]
      const cross = (to.x - from.x) * (y - from.y) - (x - from.x) * (to.y - from.y)
      if (from.y <= y && to.y > y && cross > 0) winding++
      if (from.y > y && to.y <= y && cross < 0) winding--
    }
  }
  return winding !== 0
}

function flattenedBounds(paths) {
  const points = flattenPaths(paths).flat()
  return {
    minX: Math.min(...points.map(point => point.x)),
    maxX: Math.max(...points.map(point => point.x)),
    minY: Math.min(...points.map(point => point.y)),
    maxY: Math.max(...points.map(point => point.y)),
  }
}

const selectedPaths = pathsFor({ top: 0, right: 0, bottom: 1, left: 3 })
assertEqual(selectedPaths.length, 1, 'adjacent left and bottom borders share one contour')
assert(
  selectedPaths[0].includes('A 10 10 0 0 1 90 50')
    && selectedPaths[0].includes('A 10 10 0 0 1 0 40')
    && selectedPaths[0].includes('A 10 10 0 0 1 10 0'),
  'selected border retains bottom, bottom-left, and left geometry'
)
assert(!pathContains(selectedPaths, 95, 5), 'selected border leaves the upper-right region empty')
assert(!pathContains(selectedPaths, 50, 25), 'selected border leaves the row center empty')
assert(pathContains(selectedPaths, 1, 25), 'selected border paints the left edge')
assert(pathContains(selectedPaths, 50, 49.5), 'selected border paints the bottom edge')
assertValidPaths(selectedPaths, 'selected border')

const leftRounded = pathsFor({ top: 0, right: 0, bottom: 0, left: 4 })
assertEqual(leftRounded.length, 1, 'rounded left-only border emits one contour')
assert(
  leftRounded[0].includes('A 10 10 0 0 1 0 40')
    && leftRounded[0].includes('A 10 10 0 0 1 10 0')
    && !leftRounded[0].includes('A 10 10 0 0 1 100 10')
    && !leftRounded[0].includes('A 10 10 0 0 1 90 50'),
  'rounded left-only border contains only its adjoining outer corners'
)
assert(flattenedBounds(leftRounded).maxX <= 10, 'rounded left-only geometry stays localized to the left corner radius')
assert(pathContains(leftRounded, 1, 25), 'rounded left-only border paints the left edge')
assert(!pathContains(leftRounded, 50, 25), 'rounded left-only border leaves the center empty')
assert(!pathContains(leftRounded, 50, 1), 'rounded left-only border leaves the top edge empty')
assert(!pathContains(leftRounded, 99, 25), 'rounded left-only border leaves the right edge empty')
assert(!pathContains(leftRounded, 50, 49), 'rounded left-only border leaves the bottom edge empty')
assertValidPaths(leftRounded, 'rounded left-only border')

const leftSquare = pathsFor({ top: 0, right: 0, bottom: 0, left: 4 }, 0)
assertEqual(leftSquare.length, 1, 'square left-only border emits one rectangle contour')
assert(!leftSquare[0].includes('A ') && !leftSquare[0].includes('100'), 'square left-only border never becomes a full-row fill')
assert(leftSquare[0].includes('L 4 0') && leftSquare[0].includes('L 4 50'), 'square left-only border is bounded by its requested width')
assertValidPaths(leftSquare, 'square left-only border')

const outerCorners = [
  'A 10 10 0 0 1 100 10',
  'A 10 10 0 0 1 90 50',
  'A 10 10 0 0 1 0 40',
  'A 10 10 0 0 1 10 0',
]
const isolated = [
  { name: 'top', widths: { top: 4, right: 0, bottom: 0, left: 0 }, corners: [0, 3] },
  { name: 'right', widths: { top: 0, right: 4, bottom: 0, left: 0 }, corners: [0, 1] },
  { name: 'bottom', widths: { top: 0, right: 0, bottom: 4, left: 0 }, corners: [1, 2] },
  { name: 'left', widths: { top: 0, right: 0, bottom: 0, left: 4 }, corners: [2, 3] },
]
for (const testCase of isolated) {
  const paths = pathsFor(testCase.widths)
  assertEqual(paths.length, 1, `${testCase.name}-only border emits one contour`)
  for (let corner = 0; corner < 4; corner++) {
    assertEqual(
      paths[0].includes(outerCorners[corner]),
      testCase.corners.includes(corner),
      `${testCase.name}-only border ${testCase.corners.includes(corner) ? 'includes' : 'omits'} outer corner ${corner}`
    )
  }
  assertValidPaths(paths, `${testCase.name}-only border`)
}

for (let mask = 0; mask < 16; mask++) {
  const widths = {
    top: mask & 1 ? 3 : 0,
    right: mask & 2 ? 3 : 0,
    bottom: mask & 4 ? 3 : 0,
    left: mask & 8 ? 3 : 0,
  }
  const paths = pathsFor(widths)
  const expectedRuns = mask === 0 ? 0 : (mask === 5 || mask === 10 ? 2 : 1)
  assertEqual(paths.length, expectedRuns, `enabled-side mask ${mask.toString(2).padStart(4, '0')} has minimal connected contours`)
  assertEqual(geometry.ringPath(100, 50, 10, widths), paths.join(' '), `enabled-side mask ${mask.toString(2).padStart(4, '0')} joins without changing callers`)
  assertValidPaths(paths, `enabled-side mask ${mask.toString(2).padStart(4, '0')}`)
}

const horizontalOpposites = pathsFor({ top: 3, right: 0, bottom: 5, left: 0 })
const verticalOpposites = pathsFor({ top: 0, right: 3, bottom: 0, left: 5 })
assertEqual(horizontalOpposites.length, 2, 'opposite top and bottom borders emit disconnected contours')
assertEqual(verticalOpposites.length, 2, 'opposite left and right borders emit disconnected contours')
assertEqual(
  geometry.ringPath(100, 50, 10, { top: 3, right: 0, bottom: 5, left: 0 }),
  horizontalOpposites.join(' '),
  'joined opposite contours retain one global ShapePath and gradient space'
)
assertValidPaths(horizontalOpposites, 'horizontal opposite borders')
assertValidPaths(verticalOpposites, 'vertical opposite borders')

assertEqual(pathsFor({ top: 0, right: 0, bottom: 0, left: 0 }).length, 0, 'all-zero widths emit no geometry')
assertEqual(pathsFor({ top: -4, right: 0, bottom: 0, left: 0 }).length, 0, 'negative widths clamp to zero')

for (const width of [10, 14]) {
  const paths = pathsFor({ top: 0, right: 0, bottom: 0, left: width })
  assertEqual(paths.length, 1, `left width ${width} remains a one-sided contour`)
  assertValidPaths(paths, `left width ${width}`)
}

const consumedWidth = pathsFor({ top: 0, right: 60, bottom: 0, left: 40 })
const consumedHeight = pathsFor({ top: 30, right: 0, bottom: 20, left: 0 })
const nearConsumedRounded = pathsFor({ top: 1, right: 1, bottom: 1, left: 98 })
assertEqual(consumedWidth.length, 1, 'consumed inner width emits one outer fill')
assertEqual(consumedHeight.length, 1, 'consumed inner height emits one outer fill')
assertEqual(nearConsumedRounded.length, 1, 'near-consumed rounded interior emits one conservative outer fill')
assertEqual(consumedWidth[0], geometry.roundedRectPath(0, 0, 100, 50, {
  tlrx: 10, tlry: 10, trrx: 10, trry: 10,
  brrx: 10, brry: 10, blrx: 10, blry: 10,
}), 'consumed inner width returns the outer rounded shape')
assertEqual(consumedHeight[0], consumedWidth[0], 'consumed inner height returns the same outer rounded shape')
assertEqual(nearConsumedRounded[0], consumedWidth[0], 'unfittable desired inner radii return the outer rounded shape before normalization')

const allPositive = pathsFor({ top: 4, right: 2, bottom: 8, left: 6 })
assertEqual(allPositive.length, 1, 'all-positive asymmetric border emits one winding contour')
assertEqual((allPositive[0].match(/\bM\b/g) || []).length, 2, 'all-positive contour contains outer and reversed inner loops')
assertValidPaths(allPositive, 'all-positive asymmetric border')

const flatUniform = { widths: { top: 2, right: 2, bottom: 2, left: 2 }, gradient: { enabled: false } }
const flatAsymmetric = { widths: { top: 0, right: 0, bottom: 1, left: 3 }, gradient: { enabled: false } }
const gradientUniform = { widths: { top: 2, right: 2, bottom: 2, left: 2 }, gradient: { enabled: true } }
assert(geometry.canUseNative(flatUniform), 'flat uniform borders retain native Rectangle routing')
assert(!geometry.needsOverlay(flatUniform), 'flat uniform borders do not need the overlay')
assert(geometry.needsOverlay(flatAsymmetric), 'flat asymmetric borders use the overlay')
assert(geometry.needsOverlay(gradientUniform), 'uniform gradient borders use the overlay')

const endpoints = geometry.gradientEndpoints(100, 50, 0)
assertEqual(Math.round(endpoints.x1), 0, 'border geometry 0deg starts at left edge')
assertEqual(Math.round(endpoints.x2), 100, 'border geometry 0deg ends at right edge')

// Triangular corners (Hyprland rounding_power <= 1) swap arcs for 45° cuts.
assertEqual(
  geometry.surfacePath(100, 50, 10, true),
  'M 10 0 H 90 L 100 10 V 40 L 90 50 H 10 L 0 40 V 10 L 10 0 Z',
  'chamfered surface outline cuts each corner with a straight line'
)
assertEqual(
  geometry.surfacePath(100, 50, 10, false),
  geometry.roundedRectPath(0, 0, 100, 50, {
    tlrx: 10, tlry: 10, trrx: 10, trry: 10,
    brrx: 10, brry: 10, blrx: 10, blry: 10,
  }),
  'rounded surface outline matches the rounded rect path'
)

for (let mask = 1; mask < 16; mask++) {
  const widths = {
    top: mask & 1 ? 3 : 0,
    right: mask & 2 ? 3 : 0,
    bottom: mask & 4 ? 3 : 0,
    left: mask & 8 ? 3 : 0,
  }
  const label = `chamfered mask ${mask.toString(2).padStart(4, '0')}`
  const paths = geometry.borderPaths(100, 50, 10, widths, true)
  assertValidPaths(paths, label)
  assert(!/\bA\b/.test(paths.join(' ')), `${label} emits no arcs`)
}

// Rounded geometry is pinned to literal paths so chamfer changes cannot
// silently alter it.
const pinnedRounded = [
  [{ top: 3, right: 0, bottom: 0, left: 0 },
    'M 0 10 A 10 10 0 0 1 10 0 L 90 0 A 10 10 0 0 1 100 10 L 100 10 A 10 7 0 0 0 90 3 L 10 3 A 10 7 0 0 0 0 10 Z'],
  [{ top: 0, right: 0, bottom: 1, left: 3 },
    'M 100 40 A 10 10 0 0 1 90 50 L 10 50 A 10 10 0 0 1 0 40 L 0 10 A 10 10 0 0 1 10 0 L 10 0 A 7 10 0 0 0 3 10 L 3 40 A 7 9 0 0 0 10 49 L 90 49 A 10 9 0 0 0 100 40 Z'],
  [{ top: 3, right: 3, bottom: 3, left: 3 },
    'M 10 0 H 90 A 10 10 0 0 1 100 10 V 40 A 10 10 0 0 1 90 50 H 10 A 10 10 0 0 1 0 40 V 10 A 10 10 0 0 1 10 0 Z M 10 3 A 7 7 0 0 0 3 10 L 3 40 A 7 7 0 0 0 10 47 L 90 47 A 7 7 0 0 0 97 40 L 97 10 A 7 7 0 0 0 90 3 L 10 3 Z'],
]
for (const [widths, expected] of pinnedRounded) {
  const label = `rounded ${JSON.stringify(widths)}`
  assertEqual(geometry.ringPath(100, 50, 10, widths), expected, `${label} is unchanged without chamfer`)
  assertEqual(geometry.ringPath(100, 50, 10, widths, false), expected, `${label} is unchanged with chamfer false`)
}

// One-sided chamfered borders taper at the borderless neighbours instead of
// painting strips along them.
const topChamfer = geometry.borderPaths(100, 50, 10, { top: 3, right: 0, bottom: 0, left: 0 }, true)
assert(pathContains(topChamfer, 50, 1.5), 'chamfered top-only border paints the top edge')
assert(!pathContains(topChamfer, 0.5, 11), 'chamfered top-only border leaves the left edge empty')
assert(!pathContains(topChamfer, 99.5, 11), 'chamfered top-only border leaves the right edge empty')
assert(flattenedBounds(topChamfer).maxY <= 10, 'chamfered top-only geometry stays localized to the top corner cuts')

const leftChamfer = geometry.borderPaths(100, 50, 10, { top: 0, right: 0, bottom: 0, left: 4 }, true)
assert(pathContains(leftChamfer, 1, 25), 'chamfered left-only border paints the left edge')
assert(!pathContains(leftChamfer, 12, 0.5), 'chamfered left-only border leaves the top edge empty')
assert(!pathContains(leftChamfer, 12, 49.5), 'chamfered left-only border leaves the bottom edge empty')
assert(flattenedBounds(leftChamfer).maxX <= 10, 'chamfered left-only geometry stays localized to the left corner cuts')

// A uniform chamfered ring keeps its stroke width along the diagonal: the
// inner cut line x + y = c sits exactly `width` from the outer line x + y = 10.
for (const width of [1, 2, 6]) {
  const ring = geometry.ringPath(100, 50, 10, { top: width, right: width, bottom: width, left: width }, true)
  const inner = ring.split(' M ')[1].split(' ').map(Number)
  const innerCut = inner[0] + inner[1]
  assert(Math.abs((innerCut - 10) / Math.SQRT2 - width) < 1e-9, `chamfered ${width}px ring keeps an even diagonal stroke`)
}

const surfaceQml = fs.readFileSync(path.join(root, 'shell/Ui/BorderSurface.qml'), 'utf8')
assert(surfaceQml.includes('Style.cornerChamfer'), 'border surface follows the Hyprland corner shape')
assert(/chamferSize:\s*Math\.min\(radius \* Style\.cornerPower \/ 2,/.test(surfaceQml), 'border surface cuts at Hyprland\'s effective window rounding (rounding * power / 2)')
assert(/Math\.min\(width,\s*height\)\s*\*\s*0\.3\)/.test(surfaceQml), 'border surface caps the cut on short surfaces')
assert(/topLeftRadius:\s*chamfered \? 0 : radius/.test(surfaceQml), 'border surface squares its native fill under the chamfer mask')

const styleQml = fs.readFileSync(path.join(root, 'shell/Commons/Style.qml'), 'utf8')
assert(styleQml.includes('decoration:rounding_power'), 'style mirrors Hyprland rounding_power')
assert(/cornerChamfer:\s*cornerPower <= 1\.0/.test(styleQml), 'style treats rounding_power <= 1 as triangular corners')

const overlayQml = fs.readFileSync(path.join(root, 'shell/Ui/BorderOverlay.qml'), 'utf8')
assert(overlayQml.includes('ShapePath.WindingFill'), 'border overlay uses winding fill for side-run and compound paths')
assert(!overlayQml.includes('ShapePath.OddEvenFill'), 'border overlay no longer uses touching odd-even geometry')
JS
