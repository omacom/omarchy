#!/bin/bash

# Issue #15661: the Telegram focus-steal opt-out shipped
# `focus_on_activate = false`, which is a misc: config option, not a window
# rule, so the rule parsed cleanly and did nothing. The rule must use
# `suppress_event` (the window-rule key Hyprland honours) and a class pattern
# that still full-matches when Telegram Desktop appends its install-path hash
# to the app-id (org.telegram.desktop._<hash>).

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua
require_command node

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Load the app rule against a stub o and report every window call as
# "pattern<TAB>suppress_event<TAB>focus_on_activate", then a "count" line.
cat >"$tmpdir/dump.lua" <<'LUA'
local calls = {}
o = {
  window = function(pattern, opts)
    calls[#calls + 1] = { pattern = pattern, opts = opts or {} }
  end,
}
dofile(os.getenv("TELEGRAM_LUA"))
for _, call in ipairs(calls) do
  print(call.pattern .. "\t" .. tostring(call.opts.suppress_event) .. "\t" .. tostring(call.opts.focus_on_activate))
end
print("count\t" .. #calls)
LUA

dump=$(TELEGRAM_LUA="$ROOT/default/hypr/apps/telegram.lua" lua "$tmpdir/dump.lua")

# Hyprland full-matches the class regex with ECMAScript semantics, so the
# checks run the pattern through a JavaScript RegExp.
cat >"$tmpdir/check.js" <<'JS'
const lines = process.env.TELEGRAM_PATTERN_LINE.trim().split('\n')
const countLine = lines.find((l) => l.startsWith('count\t'))
const count = Number(countLine.split('\t')[1])
if (count !== 1) fail(`expected exactly one window rule, found ${count}`)

const [pattern, suppressEvent, focusOnActivate] = lines[0].split('\t')

if (focusOnActivate !== 'nil') {
  fail('focus_on_activate is not a window rule; it silently does nothing', `options: ${JSON.stringify(lines[0])}`)
}

const fullMatch = new RegExp(`^(?:${pattern})$`)
// The plain, system-wide app-id.
if (!fullMatch.test('org.telegram.desktop')) {
  fail('rule pattern does not match the org.telegram.desktop class', pattern)
}
// Telegram Desktop appends its install-path hash when not installed
// system-wide, and Hyprland full-matches, so a bare class never matches those.
if (!fullMatch.test('org.telegram.desktop_def0123')) {
  fail('rule pattern does not match the app-id with an install-path hash', pattern)
}

const events = (suppressEvent || '').split(/\s+/)
for (const event of ['maximize', 'activate', 'activatefocus']) {
  if (!events.includes(event)) {
    fail(`suppress_event is missing "${event}"`, `suppress_event: ${suppressEvent}`)
  }
}

console.log(`ok - rule suppresses ${suppressEvent} for ${pattern}`)

function fail(description, detail) {
  if (detail) console.error(detail)
  console.error(`not ok - ${description}`)
  process.exit(1)
}
JS

rule_report=$(TELEGRAM_PATTERN_LINE="$dump" node "$tmpdir/check.js")

grep -q '^ok - ' <<<"$rule_report" || fail "the Telegram window rule is broken"
pass "the Telegram window rule suppresses focus stealing for every app-id spelling"
