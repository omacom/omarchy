#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

# The speedtest helper needs seconds of warm-up before its first sample, so
# the 5s measurement window must start on the first sample rather than at
# process launch, with a longer guard for wedged runs (#12854).
run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/speedtest/Panel.qml', 'utf8')

const startPhase = panelSource.match(/function startPhase\(nextPhase\) \{[\s\S]*?\n  \}/)
assert(startPhase, 'speedtest starts measurement phases')
assert(/sampleSeen = false/.test(startPhase[0]), 'speedtest rearms the first-sample gate per phase')
assert(/warmupTimer\.restart\(\)/.test(startPhase[0]), 'speedtest arms the wedged-run guard per phase')
assert(!/phaseTimer\.restart\(\)/.test(startPhase[0]), 'speedtest does not start the measurement window at launch')

const sampleHandler = panelSource.match(/function updateSpeedTestLine\(line\) \{[\s\S]*?\n  \}/)
assert(sampleHandler, 'speedtest handles helper output lines')
assert(/if \(!sampleSeen\) \{[\s\S]*?sampleSeen = true[\s\S]*?warmupTimer\.stop\(\)[\s\S]*?phaseTimer\.restart\(\)/.test(sampleHandler[0]),
  'speedtest starts the measurement window on the first valid sample')

const warmupTimer = panelSource.match(/id: warmupTimer[\s\S]*?onTriggered: root\.stopPhase\(\)/)
assert(warmupTimer, 'speedtest gives up on a phaseless run')
assert(/interval: 20000/.test(warmupTimer[0]), 'speedtest outlasts helper warm-up before giving up')

const stops = (panelSource.match(/warmupTimer\.stop\(\)/g) || []).length
assert(stops >= 4, 'speedtest settles the guard timer on every exit path')
JS
