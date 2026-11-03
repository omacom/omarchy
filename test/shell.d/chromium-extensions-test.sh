#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command inotifywait

test_tmp=$(mktemp -d)
host_pid=""
cleanup() {
  [[ -n $host_pid ]] && kill "$host_pid" 2>/dev/null
  rm -rf "$test_tmp"
}
trap cleanup EXIT

# Chromium derives an extension's id from its public key: the first 128 bits of
# its SHA-256, each hex digit spelled a-p.
extension_id() {
  jq -r .key "$1" | base64 -d | sha256sum | cut -c1-32 | tr '0-9a-f' 'a-p'
}

# --- Bundled extensions ---

# A keyless unpacked extension gets a path-derived id, so its settings, shortcut
# registrations and native host grants would go stale whenever its load path
# changed. The pinned key keeps the id stable everywhere, and a regenerated key
# would orphan the same things, so the ids that shipped stay pinned here.
declare -A shipped_id=(
  [copy-url]=bgpiichlckmfanooecilcjemknkcpngb
  [google-calendar-theme]=ngmigealgnjchimflafdoemlhcgbojac
  [whatsapp-slim]=amhpgjbcfakkmkeojmoaoiochhifohdi
  [yt-dlp]=dedjgknigfeelejglamclffonmophnfl
)
declare -A extension_manifest
for manifest in "$ROOT"/default/chromium/extensions/*/manifest.json; do
  extension_dir=${manifest%/manifest.json}
  name=${extension_dir##*/}
  jq -e '.key | type == "string"' "$manifest" >/dev/null || fail "the $name extension pins its id with a manifest key"
  id=$(extension_id "$manifest")
  [[ $id =~ ^[a-p]{32}$ ]] || fail "the $name extension's key decodes to an extension id" "got: $id"
  [[ -z ${shipped_id[$name]:-} || $id == "${shipped_id[$name]}" ]] ||
    fail "the $name extension keeps the id it shipped with" "got: $id"
  extension_manifest[$id]=$manifest

  while read -r file; do
    [[ -f $extension_dir/$file ]] || fail "the $name extension ships $file, which its manifest loads"
  done < <(jq -r '[.background.service_worker, (.content_scripts[]? | .js[]?, .css[]?), (.icons // {} | .[])] | .[] | strings' "$manifest")
done
pass "each bundled Chromium extension pins its id and ships the files its manifest loads"

# --- Native messaging hosts ---

# Each host admits exactly the bundled extensions whose scripts message it, and
# each extension that asks for native messaging has a host admitting its id.
declare -A hosted
for template in "$ROOT"/default/chromium/native-messaging-hosts/*.json; do
  host=$(basename "$template" .json)
  [[ $(jq -r .name "$template") == "$host" ]] || fail "native host $host is named after its manifest file"
  senders=$(
    for id in "${!extension_manifest[@]}"; do
      if grep -rqF -e "sendNativeMessage('$host'" -e "sendNativeMessage(\"$host\"" \
        -e "connectNative('$host'" -e "connectNative(\"$host\"" "$(dirname "${extension_manifest[$id]}")"; then
        printf 'chrome-extension://%s/\n' "$id"
      fi
    done | sort
  )
  [[ -n $senders && $(jq -r '.allowed_origins[]' "$template" | sort) == "$senders" ]] ||
    fail "native host $host admits exactly the extensions that message it" "admits: $(jq -c .allowed_origins "$template"), messaged by: ${senders:-none}"
  while read -r origin; do
    id=${origin#chrome-extension://}
    id=${id%/}
    [[ $origin == "chrome-extension://$id/" && -v extension_manifest[$id] ]] ||
      fail "native host $host admits only bundled extensions" "origin: $origin"
    jq -e '.permissions | index("nativeMessaging")' "${extension_manifest[$id]}" >/dev/null ||
      fail "native host $host admits an extension that asks for native messaging" "origin: $origin"
    hosted[$id]=1
  done < <(jq -r '.allowed_origins[]' "$template")
done
for id in "${!extension_manifest[@]}"; do
  if jq -e '.permissions | index("nativeMessaging")' "${extension_manifest[$id]}" >/dev/null; then
    [[ -v hosted[$id] ]] || fail "a native host admits the $(basename "$(dirname "${extension_manifest[$id]}")") extension's id $id"
  fi
done
pass "each native messaging host admits exactly the bundled extension that talks to it"

# Chromium ships in the base packages, so fresh installs do not go through
# omarchy-install-browser and mark every migration as already applied. The user
# install has to register the hosts itself.
home="$test_tmp/home"
HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  bash -euo pipefail -c 'source "$ROOT/install/user/chromium.sh"' ||
  fail "the user install registers the Chromium native messaging hosts"

for template in "$ROOT"/default/chromium/native-messaging-hosts/*.json; do
  host=$(basename "$template" .json)
  for profile in chromium BraveSoftware/Brave-Origin; do
    installed="$home/.config/$profile/NativeMessagingHosts/$host.json"
    [[ -f $installed ]] || fail "a fresh install registers native host $host for $profile"
    path=$(jq -r .path "$installed")
    [[ $path == "$ROOT/bin/"* && -x $path ]] ||
      fail "native host $host for $profile runs an Omarchy host command" "path: $path"
    [[ $(jq -c .allowed_origins "$installed") == "$(jq -c .allowed_origins "$template")" ]] ||
      fail "native host $host for $profile admits the bundled extension"
  done
done
pass "a fresh install registers every native messaging host for Chromium and Brave Origin"

# --- WhatsApp Slim ---

# The content script switches WhatsApp Web to its system theme mode, which it
# only reads at startup, so it reloads once; with the mode already set it must
# not reload again, or the page would never finish loading.
if command -v node >/dev/null; then
  reloads=$(node - "$ROOT/default/chromium/extensions/whatsapp-slim/system-theme.js" <<'JS'
const fs = require("fs")
const source = fs.readFileSync(process.argv[2], "utf8")
const values = new Map()
const reloads = []
global.localStorage = {
  getItem: key => values.get(key),
  setItem: (key, value) => values.set(key, value),
}
for (const run of [1, 2]) {
  global.location = { reload: () => reloads.push(run) }
  eval(source)
}
process.stdout.write(`${values.get("system-theme-mode")}:${reloads.join(",")}`)
JS
  )
  [[ $reloads == "true:1" ]] || fail "WhatsApp selects its system theme mode and reloads only once" "$reloads"
  pass "WhatsApp follows the system theme through its slim extension"
else
  skip "node is not installed; skipping the WhatsApp Slim content script check"
fi

# --- Google Calendar Theme host ---

# A native host inherits the browser's environment, which the session set up:
# OMARCHY_PATH and Omarchy's commands on PATH.
theme_host() {
  exec env -i HOME="$1" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:/usr/bin" "$ROOT/bin/omarchy-chromium-theme-host"
}

# Byte-exact reads: head would buffer past the frame and swallow the next one.
read_frame() {
  local fd=$1 length

  length=$(timeout 5 dd bs=1 count=4 status=none <&"$fd" | od -An -tu4 --endian=little | tr -d ' ')
  [[ -n $length ]] || return 1
  timeout 5 dd bs=1 count="$length" status=none <&"$fd"
}

host_home="$test_tmp/host-home"
state="$host_home/.local/state/omarchy/current"
mkdir -p "$state/theme"
cp "$ROOT/themes/catppuccin/colors.toml" "$state/theme/"
echo "catppuccin" >"$state/theme.name"

mkfifo "$test_tmp/host-stdin"
exec {host_out}< <(theme_host "$host_home" <"$test_tmp/host-stdin")
host_pid=$!
exec {host_in}>"$test_tmp/host-stdin"

palette=$(read_frame "$host_out") || fail "theme host sends the palette when the extension connects"
[[ $(jq -r '.type, .theme, .mode, .colors.background, .colors.red' <<<"$palette" | paste -sd' ') == "palette catppuccin dark #1e1e2e #f38ba8" ]] ||
  fail "theme host sends the current theme's palette when the extension connects" "$palette"
jq -e '.colors.orange and .colors.brown and (.colors | all(test("^#[0-9a-f]{6}$")))' <<<"$palette" >/dev/null ||
  fail "theme host resolves fallback colors and sends only hex colors" "$palette"
jq -e '.accents | index("#7aa2f7") and index("#b59790")' <<<"$palette" >/dev/null ||
  fail "theme host sends the accents of the installed themes" "$palette"
pass "theme host sends the resolved palette when the extension connects"

# Swap the theme the way omarchy-theme-set does: the theme directory first,
# then theme.name. The host only sends its first palette once it is watching.
mkdir "$state/next-theme"
cp "$ROOT/themes/tokyo-night/colors.toml" "$state/next-theme/"
rm -rf "$state/theme"
mv "$state/next-theme" "$state/theme"
echo "tokyo-night" >"$state/theme.name"

palette=$(read_frame "$host_out") || fail "theme host pushes the palette when the theme changes"
[[ $(jq -r '.theme, .colors.background' <<<"$palette" | paste -sd' ') == "tokyo-night #1a1b26" ]] ||
  fail "theme host pushes the new theme's palette when the theme changes" "$palette"
pass "theme host pushes the new palette when the theme changes"

exec {host_in}>&-
timeout 5 tail --pid="$host_pid" -f /dev/null || fail "theme host exits when the extension disconnects"
host_pid=""
pass "theme host exits when the extension disconnects"

# The browser kills a host that is slow to exit, which skips its own cleanup.
exec {host_out}< <(theme_host "$host_home" <"$test_tmp/host-stdin")
host_pid=$!
exec {host_in}>"$test_tmp/host-stdin"
read_frame "$host_out" >/dev/null || fail "theme host sends the palette before it is killed"
watcher=$(pgrep -P "$host_pid" -x inotifywait) || fail "theme host watches the theme state with inotifywait"
kill -KILL "$host_pid"
host_pid=""
timeout 5 tail --pid="$watcher" -f /dev/null || fail "theme host's watcher exits when the host is killed"
exec {host_in}>&-
pass "theme host's watcher exits when the host is killed"

# A theme that doesn't resolve sends nothing, so the extension keeps its last palette.
mkdir -p "$test_tmp/no-theme-home"
bytes=$(theme_host "$test_tmp/no-theme-home" </dev/null | wc -c)
(( bytes == 0 )) || fail "theme host sends nothing when the theme doesn't resolve" "sent $bytes bytes"
pass "theme host sends nothing when the theme doesn't resolve"

# --- Google Calendar Theme ---

# The content script recolors by value, not by Google's class names: Google's
# event colors map onto the theme by hue, colors the user picked from the theme
# stay, and the interface's neutrals and blue follow the theme.
if command -v node >/dev/null; then
  theme_home="$test_tmp/theme-home"
  mkdir -p "$theme_home/.local/state/omarchy/current/theme"
  cp "$ROOT/themes/tokyo-night/colors.toml" "$theme_home/.local/state/omarchy/current/theme/"
  palette=$(theme_host "$theme_home" </dev/null | tail -c +5)

  result=$(node - "$ROOT/default/chromium/extensions/google-calendar-theme/content.js" "$palette" <<'JS'
const fs = require("fs")
const [script, paletteJson] = process.argv.slice(2)
const source = fs.readFileSync(script, "utf8")
const palette = JSON.parse(paletteJson)
const c = palette.colors
// Several themes have a pure white neutral, such as Vantablack's foreground.
c.color15 = "#ffffff"
// Last Horizon's accent, picked as a calendar color on that theme, and the fill
// Google draws for a past event of that calendar in its dark appearance.
palette.accents = ["#b59790"]
const pinkPastDark = "rgb(107, 92, 90)"

const parse = (hex) => [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16))
const rgb = (hex) => `rgb(${parse(hex).join(", ")})`
const mixed = (a, b, t) => `rgb(${parse(a).map((v, i) => Math.round(v + (parse(b)[i] - v) * t)).join(", ")})`

// A CSSStyleDeclaration normalizes hex to rgb() the way Chromium does, which
// the content script relies on to recognize its own writes.
function fakeStyle(init) {
  const props = new Map(Object.entries(init))
  const style = {
    get length() { return props.size },
    getPropertyValue: (prop) => props.get(prop) ?? "",
    getPropertyPriority: () => "",
    setProperty(prop, value) {
      props.set(prop, /^#[0-9a-f]{6}$/i.test(value) ? rgb(value) : value)
    },
  }
  ;[...props.keys()].forEach((prop, i) => (style[i] = prop))
  return style
}

function fakeElement(style) {
  const attributes = new Map()
  return {
    nodeType: 1,
    style: fakeStyle(style),
    hasAttribute: (name) => attributes.has(name),
    getAttribute: (name) => attributes.get(name) ?? null,
    setAttribute: (name, value) => attributes.set(name, value),
    removeAttribute: (name) => attributes.delete(name),
    querySelectorAll: () => [],
  }
}

// Tokyo Night's bright cyan shares a hue range with its cyan, so a picked
// bright cyan only survives when it is recognized as the user's own pick.
const tomato = fakeElement({ "background-color": "rgb(213, 0, 0)", color: "rgb(255, 255, 255)" })
const picked = fakeElement({ "background-color": rgb(c.bright_cyan) })
const pickedPast = fakeElement({ "background-color": mixed(c.bright_cyan, "#ffffff", 0.4) })
const surface = fakeElement({ "background-color": "rgb(255, 255, 255)" })
const pastDark = fakeElement({ "background-color": pinkPastDark })
const otherAccent = fakeElement({ "background-color": "rgb(181, 151, 144)" })
// A calendar colored outside any theme's accents: Google's dark fill for one
// of its past events, met before the calendar's own swatch. Another calendar's
// lavender grey, listed first, also comes within a few levels of explaining it.
const quietPast = fakeElement({ "background-color": "rgb(70, 64, 76)" })
const otherSwatch = fakeElement({ "--checkbox-color": "#A5A0B6" })
const quietSwatch = fakeElement({ "--checkbox-color": "#6B5E73" })
// Google's Peacock and Tomato, and the shades it draws them in when dark.
const builtIns = ["rgb(3, 155, 229)", "rgb(75, 153, 210)", "rgb(213, 0, 0)", "rgb(218, 82, 52)"].map((color) => fakeElement({ "background-color": color }))
const root = fakeElement({})
root.querySelectorAll = () => [tomato, picked, pickedPast, surface, pastDark, otherAccent, quietPast, otherSwatch, quietSwatch, ...builtIns]

class CSSStyleRule {}
const styleRule = (style) => Object.assign(Object.create(CSSStyleRule.prototype), { style: fakeStyle(style) })
const rule = styleRule({
  "background-color": "rgb(255, 255, 255)",
  color: "rgb(31, 31, 31)",
  "--gm3-sys-color-primary": "#0b57d0",
  "--gm3-sys-color-surface-rgb": "255,255,255",
})
const inserted = styleRule({ "background-color": "rgb(255, 255, 255)" })
// Google's light sidebar, a step off its white calendar canvas.
const sidebarRule = styleRule({ "background-color": "#f8fafd" })
// Calendar's dark appearance: Material 3's dark surface and primary.
const darkRule = styleRule({ "background-color": "#131314", "--gm3-sys-color-primary": "#a8c7fa" })
const sheet = { cssRules: [rule, sidebarRule, darkRule] }
const styleNode = { id: "", sheet }
sheet.ownerNode = styleNode

// <body> takes its paper from whichever rule Google's appearance applies.
const body = {}
let bodyRule = rule
const observers = []
const listeners = {}
Object.assign(global, {
  Node: { ELEMENT_NODE: 1 },
  CSSStyleRule,
  CSSKeyframesRule: class {},
  MutationObserver: class {
    constructor(callback) { this.callback = callback; observers.push(this) }
    observe(target) { this.target = target }
    takeRecords() {}
  },
  getComputedStyle: () => ({ backgroundColor: bodyRule.style.getPropertyValue("background-color") }),
  matchMedia: () => ({ addEventListener() {} }),
  document: {
    documentElement: root,
    body,
    head: { append() {} },
    styleSheets: [sheet],
    getElementById: () => null,
    createElement: () => ({}),
    addEventListener: (type, listener) => (listeners[type] = listener),
  },
  chrome: {
    runtime: { id: "test", connect: () => ({ onDisconnect: { addListener() {} } }) },
    storage: { local: { get: async () => ({ palette }) }, onChanged: { addListener() {} } },
  },
})

eval(source)

// Once themed, a rule Google adds with insertRule, as sheet-hook.js reports it.
setTimeout(() => {
  sheet.cssRules.push(inserted)
  listeners["omarchy-calendar-sheet-change"]?.({ target: styleNode })
  setTimeout(check, 0)
}, 0)

function check() {
  const failures = []
  const expect = (what, actual, expected) => actual === expected || failures.push(`${what}: got ${actual}, want ${expected}`)
  const value = (el, prop) => el.style.getPropertyValue(prop)

  expect("Google's Tomato becomes the theme red", value(tomato, "background-color"), rgb(c.red))
  expect("text on a recolored chip picks a theme color", ["bg", "fg"].includes(tomato.getAttribute("data-omarchy-ink")), true)
  expect("a calendar color picked from the theme is kept", value(picked, "background-color"), rgb(c.bright_cyan))
  expect("a faded picked color re-tints against the theme background", value(pickedPast, "background-color"), mixed(c.bright_cyan, c.background, 0.4))
  expect("white surfaces become the theme background", rule.style.getPropertyValue("background-color"), rgb(c.background))
  expect("Google's text becomes the theme foreground, not a fade of it", rule.style.getPropertyValue("color"), rgb(c.foreground))
  expect("Google blue becomes the theme accent", rule.style.getPropertyValue("--gm3-sys-color-primary"), rgb(c.accent))
  expect("GM3 channel variables follow the background", rule.style.getPropertyValue("--gm3-sys-color-surface-rgb"), parse(c.background).join(","))
  expect("a white surface follows the background even when the theme has white", value(surface, "background-color"), rgb(c.background))
  expect("a rule added after load follows the theme", inserted.style.getPropertyValue("background-color"), rgb(c.background))
  expect("a calendar color picked as another theme's accent becomes this theme's accent", value(otherAccent, "background-color"), rgb(c.accent))
  expect("Google's built-in colors land on the same theme color in both its appearances",
    builtIns.map((el) => value(el, "background-color")).join(" "), [c.cyan, c.cyan, c.red, c.red].map(rgb).join(" "))
  // A visible step from the background, in the background's own tint rather
  // than drifting toward the foreground's.
  const step = sidebarRule.style.getPropertyValue("background-color").match(/\d+/g).map((v, i) => v - parse(c.background)[i])
  expect("the sidebar stands apart from the canvas in the background's own tint", `${Math.max(...step) - Math.min(...step) <= 1 && step[0] >= 8}`, "true")

  // Switching Calendar to its dark appearance toggles a class on <body>.
  bodyRule = darkRule
  observers.find((observer) => observer.target === body)?.callback()
  expect("Google's dark paper becomes the theme background", darkRule.style.getPropertyValue("background-color"), rgb(c.background))
  expect("Google's dark primary becomes the theme accent", darkRule.style.getPropertyValue("--gm3-sys-color-primary"), rgb(c.accent))
  // Google fades a past event's fill halfway in its dark appearance, give or take its rounding.
  const closeTo = (actual, expected) => {
    const want = expected.match(/\d+/g).map(Number)
    return actual.match(/\d+/g).map(Number).every((v, i) => Math.abs(v - want[i]) <= 2)
  }
  expect("a past event of that color is a faded accent in Google's dark appearance", closeTo(value(pastDark, "background-color"), mixed(c.accent, c.background, 0.5)), true)

  // The swatch's color is learned once processing reaches it, and the past
  // event met before it is corrected on the next pass.
  setTimeout(() => {
    expect("a past event of any calendar is a fade of what that calendar's color becomes", closeTo(value(quietPast, "background-color"), mixed(c.magenta, c.background, 0.5)), true)
    process.stdout.write(failures.join("\n"))
  }, 0)
}
JS
  )
  [[ -z $result ]] || fail "Google Calendar takes its colors from the theme" "$result"
  pass "Google Calendar takes its colors from the theme"
else
  skip "node is not installed; skipping the Google Calendar Theme content script check"
fi
