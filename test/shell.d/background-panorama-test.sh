#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const panorama = requireFromRoot('shell/plugins/background/Panorama.js')

// XMP writes a field as an attribute or as an element, depending on the tool.
assertDeepEqual(
  panorama.parse(['GPano:ProjectionType="equirectangular', 'GPano:InitialViewHeadingDegrees="62',
    'GPano:InitialViewPitchDegrees>-15', 'GPano:InitialHorizontalFOVDegrees="100'], 8192, 4096),
  { heading: 62, pitch: -15, fov: 100 },
  'panorama reads the GPano view from attribute and element forms'
)
assertDeepEqual(
  panorama.parse(['GPano:ProjectionType>equirectangular'], 8192, 4096),
  { heading: 0, pitch: 0, fov: 90 },
  'panorama defaults the view a photo does not set'
)
assertDeepEqual(
  panorama.parse(['GPano:ProjectionType="equirectangular', 'GPano:InitialViewPitchDegrees="-90',
    'GPano:InitialHorizontalFOVDegrees="179'], 8192, 4096),
  { heading: 0, pitch: -60, fov: 120 },
  'panorama keeps the view within what a flat screen can show'
)
assertEqual(panorama.parse([], 8192, 4096), null, 'panorama leaves an untagged 2:1 image flat')
assertEqual(panorama.parse(['GPano:ProjectionType="cylindrical'], 8192, 4096), null, 'panorama leaves other projections flat')
// A phone's horizontal sweep carries GPano too, but covers only part of the sphere.
assertEqual(panorama.parse(['GPano:ProjectionType="equirectangular'], 12000, 2000), null, 'panorama leaves a partial sphere flat')
assertEqual(panorama.parse(['GPano:ProjectionType="equirectangular'], 0, 0), null, 'panorama leaves an unreadable size flat')

assertEqual(panorama.turnTo(324, 1), 36, 'panorama turns from the last workspace to the first one step forward')
assertEqual(panorama.turnTo(0, 9), -72, 'panorama turns back to a workspace behind rather than round')
// The view keeps the angle it has turned through, past one full turn.
assertEqual(panorama.turnTo(396, 2), 0, 'panorama does not turn to the workspace it already faces after a lap')
JS
