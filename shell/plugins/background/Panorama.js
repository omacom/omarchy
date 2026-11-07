// 360 panorama backgrounds: reading a photo's GPano XMP, and turning the view
// with the workspace.

// A panorama turns this far for each workspace, so ten workspaces go once
// around the scene and the last one sits beside the first.
var degreesPerWorkspace = 36

function clampNumber(value, fallback, min, max) {
  var parsed = parseFloat(value)
  return isFinite(parsed) ? Math.max(min, Math.min(max, parsed)) : fallback
}

// The view of a 360 photo, from the GPano lines the background's size probe
// prints (`GPano:Field="value` or `GPano:Field>value`), or null for an image
// that is not one. Only a whole sphere, twice as wide as it is tall, counts;
// the Initial* fields set where workspace 1 looks and how wide the view is.
function parse(lines, width, height) {
  var fields = {}
  for (var i = 0; i < lines.length; i++) {
    var match = /^GPano:(\w+)(?:="|>)(.*)$/.exec(String(lines[i] || ""))
    if (match && fields[match[1]] === undefined) fields[match[1]] = match[2]
  }
  if (fields.ProjectionType !== "equirectangular") return null
  if (!(width > 0) || !(height > 0) || Math.abs(width / height - 2) > 0.02) return null
  return {
    heading: clampNumber(fields.InitialViewHeadingDegrees, 0, -360, 360),
    pitch: clampNumber(fields.InitialViewPitchDegrees, 0, -60, 60),
    fov: clampNumber(fields.InitialHorizontalFOVDegrees, 90, 40, 120)
  }
}

function workspaceAngle(id) {
  return Math.max(0, id - 1) * degreesPerWorkspace
}

// The turn from a view at yaw degrees to workspace id's angle, the short way
// round: 10 to 1 is one step forward, not nine back. Half a turn goes back.
function turnTo(yaw, id) {
  var current = ((yaw % 360) + 360) % 360
  return ((workspaceAngle(id) - current + 540) % 360) - 180
}

if (typeof module !== "undefined") {
  module.exports = {
    degreesPerWorkspace: degreesPerWorkspace,
    parse: parse,
    workspaceAngle: workspaceAngle,
    turnTo: turnTo
  }
}
