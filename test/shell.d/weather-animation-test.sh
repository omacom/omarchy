#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const animation = requireFromRoot('shell/plugins/panels/weather/Animation.js')
const manifest = JSON.parse(fs.readFileSync(root + '/shell/plugins/panels/weather/manifest.json', 'utf8'))
const serviceSource = fs.readFileSync(root + '/shell/plugins/panels/weather/Service.qml', 'utf8')
const layerSource = fs.readFileSync(root + '/shell/plugins/panels/weather/WeatherAnimation.qml', 'utf8')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/weather/Panel.qml', 'utf8')

// ---- Weather codes. Open-Meteo answers in WMO codes and wttr.in in its own;
//      both have to land on the same renderer or the desktop would contradict
//      the icon in the bar.
assertEqual(animation.conditionForCode(0), 'clear', 'animation maps WMO clear sky')
assertEqual(animation.conditionForCode(3), 'cloudy', 'animation maps WMO overcast')
assertEqual(animation.conditionForCode(48), 'fog', 'animation maps WMO fog')
assertEqual(animation.conditionForCode(53), 'drizzle', 'animation maps WMO drizzle')
assertEqual(animation.conditionForCode(65), 'rain', 'animation maps WMO heavy rain')
assertEqual(animation.conditionForCode(82), 'rain', 'animation maps WMO rain showers')
assertEqual(animation.conditionForCode(75), 'snow', 'animation maps WMO snowfall')
assertEqual(animation.conditionForCode(86), 'snow', 'animation maps WMO snow showers')
assertEqual(animation.conditionForCode(95), 'storm', 'animation maps WMO thunderstorm')

assertEqual(animation.conditionForCode(113), 'clear', 'animation maps the wttr sunny code')
assertEqual(animation.conditionForCode(122), 'cloudy', 'animation maps the wttr overcast code')
assertEqual(animation.conditionForCode(248), 'fog', 'animation maps the wttr fog code')
assertEqual(animation.conditionForCode(266), 'drizzle', 'animation maps the wttr light drizzle code')
assertEqual(animation.conditionForCode(308), 'rain', 'animation maps the wttr heavy rain code')
assertEqual(animation.conditionForCode(338), 'snow', 'animation maps the wttr heavy snow code')
assertEqual(animation.conditionForCode(389), 'storm', 'animation maps the wttr thunder code')
// Frozen mixes follow the split WMO already makes: freezing drizzle and
// freezing rain stay liquid, sleet and ice pellets draw as snow.
assertEqual(animation.conditionForCode(281), 'drizzle', 'animation draws wttr freezing drizzle as drizzle')
assertEqual(animation.conditionForCode(314), 'rain', 'animation draws wttr freezing rain as rain')
assertEqual(animation.conditionForCode(320), 'snow', 'animation draws wttr sleet as snow')
assertEqual(animation.conditionForCode(350), 'snow', 'animation draws wttr ice pellets as snow')

assertEqual(animation.conditionForCode(7), '', 'animation ignores an unmapped WMO code')
assertEqual(animation.conditionForCode(999), '', 'animation ignores an unmapped wttr code')
assertEqual(animation.conditionForCode(null), '', 'animation ignores a missing code')
assertEqual(animation.conditionForCode('nope'), '', 'animation ignores an unparseable code')

// Heavier codes have to read as heavier, or intensity is decoration.
assert(animation.intensityForCode(65) > animation.intensityForCode(61), 'animation scales rain intensity with the code')
assert(animation.intensityForCode(75) > animation.intensityForCode(71), 'animation scales snow intensity with the code')
assert(animation.intensityForCode(308) > animation.intensityForCode(296), 'animation scales wttr rain intensity with the code')
assertEqual(animation.intensityForCode(999), 0, 'animation gives an unmapped code no intensity')

// ---- Opacity. The whole effect lives or dies on staying faint, so the caps
//      are asserted rather than left to review.
assert(animation.opacityFor('rain', 1) <= 0.25, 'animation keeps rain under a quarter opaque at its heaviest')
assert(animation.opacityFor('storm', 1) <= 0.25, 'animation keeps a thunderstorm under a quarter opaque')
assert(animation.opacityFor('cloudy', 1) <= 0.2, 'animation keeps cloud shadow light')
assert(animation.opacityFor('snow', 1) <= 0.45, 'animation keeps snow from whiting out the wallpaper')
assert(animation.opacityFor('rain', 1) > animation.opacityFor('rain', 0), 'animation scales opacity with intensity')
assertEqual(animation.opacityFor('nonsense', 1), 0, 'animation gives an unknown condition no opacity')

// ---- Wind. Still air still leans, because a dead-vertical streak reads as a
//      screen artifact; the lean grows with wind and stops at the ceiling.
assert(animation.slantForWind(0, 18) > 0, 'animation leans precipitation even in still air')
assert(animation.slantForWind(30, 18) > animation.slantForWind(5, 18), 'animation leans further as the wind picks up')
assert(animation.slantForWind(200, 18) <= 18, 'animation caps the lean at the ceiling it was given')
assert(animation.slantForWind(0, 10) < animation.slantForWind(0, 18), 'animation honours a gentler ceiling for snow')
assert(animation.slantForWind(20, 18, 270) > 0, 'animation sends a westerly to the right')
assert(animation.slantForWind(20, 18, 90) < 0, 'animation sends an easterly to the left')
assert(animation.slantForWind(20, 18) > 0, 'animation leans right when no bearing is reported')
assertEqual(animation.slantForWind('nonsense', 18), animation.slantForWind(0, 18), 'animation treats an unparseable wind as still')

// ---- Particle budget. Scaled by area so a larger screen is not sparser, and
//      capped so a very wide one cannot run away with it.
const rainProfile = animation.profileFor(63, false, 12)
const wide = animation.particleCount(rainProfile, 3840, 2160)
const normal = animation.particleCount(rainProfile, 1920, 1080)
assert(normal > 0, 'animation draws drops for rain')
assert(wide > normal, 'animation scales the drop count with screen area')
assert(wide <= animation.MAX_PARTICLES, 'animation caps the drop count')
assertEqual(animation.particleCount(animation.profileFor(48, false, 0), 1920, 1080), 0, 'animation draws fog as haze rather than particles')
assertEqual(animation.particleCount(animation.profileFor(3, false, 0), 1920, 1080), 0, 'animation draws overcast as haze rather than particles')
assertEqual(animation.particleCount(null, 1920, 1080), 0, 'animation draws nothing without a profile')
assertEqual(animation.particleCount(rainProfile, 0, 0), 0, 'animation draws nothing into a zero-sized screen')

// ---- Profiles.
assertEqual(animation.profileFor(999, false, 0), null, 'animation has no profile for an unmapped code')
assert(animation.profileFor(95, false, 10).lightning === true, 'animation flashes only in a thunderstorm')
assert(animation.profileFor(63, false, 10).lightning === false, 'animation does not flash in plain rain')
assert(animation.profileFor(0, true, 0).night === true, 'animation carries the night flag through')
assert(
  Math.abs(animation.profileFor(73, false, 60).slant) < Math.abs(animation.profileFor(63, false, 60).slant),
  'animation drifts snow more gently than it slants rain'
)

// Open-Meteo's reading wins when both are present: it is the only one of the
// two that reports day/night and a wind bearing.
assertEqual(
  animation.profileForCurrent({ openMeteoWeatherCode: 73, weatherCode: 113, windspeedKmph: 8 }).condition,
  'snow',
  'animation prefers the Open-Meteo code over the wttr one'
)
assertEqual(
  animation.profileForCurrent({ weatherCode: 308, windspeedKmph: 8 }).condition,
  'rain',
  'animation falls back to the wttr code'
)
assertEqual(animation.profileForCurrent(null), null, 'animation has no profile without current conditions')
assertEqual(animation.profileForCurrent({ windspeedKmph: 8 }), null, 'animation has no profile without a weather code')
assert(
  animation.profileForCurrent({ openMeteoWeatherCode: 0, isDay: 0 }).night === true,
  'animation reads night from the Open-Meteo day flag'
)
assert(
  animation.profileForCurrent({ weatherCode: 113 }).night === false,
  'animation treats a wttr reading with no day flag as daytime'
)
assert(
  animation.profileForCurrent({ openMeteoWeatherCode: 63, windspeedKmph: 20, windDirection: 90 }).slant < 0,
  'animation turns the rain into the reported wind bearing'
)

// ---- Preview IPC.
assertDeepEqual(
  animation.previewNames(),
  ['clear', 'cloudy', 'drizzle', 'fog', 'rain', 'snow', 'storm'],
  'animation offers every condition for preview'
)
animation.previewNames().forEach(function(name) {
  const profile = animation.previewProfile(name)
  assertEqual(profile && profile.condition, name, 'animation previews ' + name)
})
assertEqual(animation.previewProfile('hurricane'), null, 'animation refuses an unknown preview condition')
assertEqual(animation.previewProfile(''), null, 'animation refuses an empty preview condition')
assertEqual(animation.previewProfile(' RAIN ').condition, 'rain', 'animation accepts a preview condition in any case')

// ---- Manifest. The setting is opt-in because the layer costs real frames.
assert(manifest.kinds.indexOf('service') !== -1, 'weather declares the animation service')
assertEqual(manifest.entryPoints.service, 'Service.qml', 'weather points the service at its entry point')
assertEqual(manifest.barWidget.defaults.animations, false, 'weather leaves wallpaper animations off by default')
const animationSetting = manifest.barWidget.schema.filter(function(entry) { return entry.key === 'animations' })[0]
assert(animationSetting, 'weather exposes an animations setting')
assertEqual(animationSetting.type, 'boolean', 'weather exposes animations as a toggle')
assertEqual(animationSetting.defaultValue, false, 'weather advertises the animations default as off')

// ---- Wiring that the pure functions cannot cover. Each of these is a way the
//      layer could quietly start costing frames nobody can see.
assert(
  serviceSource.includes('WlrLayer.Bottom'),
  'weather animations sit above the wallpaper and below every window'
)
assert(
  serviceSource.includes('mask: Region { }'),
  'weather animations take no pointer input, so the background keeps its double-click'
)
assert(
  /visible:\s*root\.active\s*&&\s*!fullscreenHere/.test(serviceSource),
  'weather animations unmap under a fullscreen window'
)
assert(
  serviceSource.includes('!sessionObscured') && serviceSource.includes('!powerSaverActive'),
  'weather animations stop when locked, screensaved, or saving power'
)
assert(
  serviceSource.includes('lockService') && serviceSource.includes('idleService') && serviceSource.includes('batteryService'),
  'weather animations read the lock, idle, and battery services to decide that'
)
assert(
  serviceSource.includes('sourceTimeout'),
  'weather animations clear themselves when the widget stops reporting'
)
assert(
  panelSource.includes('pushAnimationState'),
  'weather panel hands its resolved conditions to the animation service'
)
assert(
  panelSource.includes('wind_direction_10m'),
  'weather panel asks Open-Meteo for the wind bearing the lean needs'
)

// Per-drop animations measured around +26% CPU on two screens; the sliding
// sheets are what make the layer affordable. Guard the shape of that fix.
assert(
  layerSource.includes('component FallingSheet'),
  'weather animations draw precipitation as sliding sheets'
)
assert(
  !/NumberAnimation[\s\S]{0,400}property:\s*"t"/.test(layerSource.split('component Motes')[0]),
  'weather animations keep per-particle animations out of precipitation'
)
JS
