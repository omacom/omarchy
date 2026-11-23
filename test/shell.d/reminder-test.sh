#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/reminders/ReminderFlowModel.js')

// Bare digits stay minutes; anything with a colon or am/pm is a clock time.
assertEqual(model.validMinutes('15'), '15', 'validMinutes accepts a positive count')
assertEqual(model.validMinutes('0'), '', 'validMinutes rejects zero')
assertEqual(model.validMinutes('14:30'), '', 'validMinutes rejects a clock time')
assertEqual(model.validMinutes(''), '', 'validMinutes rejects an empty value')

assertDeepEqual(model.parseClockTime('14:30'), { hours: 14, minutes: 30, label: '14:30' }, 'parseClockTime reads 24h times')
assertDeepEqual(model.parseClockTime('2:30pm'), { hours: 14, minutes: 30, label: '14:30' }, 'parseClockTime reads pm times')
assertDeepEqual(model.parseClockTime('2pm'), { hours: 14, minutes: 0, label: '14:00' }, 'parseClockTime reads bare pm hours')
assertDeepEqual(model.parseClockTime('12am'), { hours: 0, minutes: 0, label: '00:00' }, 'parseClockTime reads midnight')
assertDeepEqual(model.parseClockTime('12pm'), { hours: 12, minutes: 0, label: '12:00' }, 'parseClockTime reads noon')
assertDeepEqual(model.parseClockTime('at 9'), { hours: 9, minutes: 0, label: '09:00' }, 'parseClockTime reads an explicit at-hour')
assertEqual(model.parseClockTime('25:00'), null, 'parseClockTime rejects an hour past 23')
assertEqual(model.parseClockTime('14:61'), null, 'parseClockTime rejects minutes past 59')
assertEqual(model.parseClockTime('13pm'), null, 'parseClockTime rejects a 12h hour past 12')
assertEqual(model.parseClockTime('15'), null, 'parseClockTime leaves bare digits to minutes')

assertDeepEqual(model.parseFirstStep('15'), { kind: 'minutes', arg: '15' }, 'parseFirstStep keeps bare digits as minutes')
assertDeepEqual(model.parseFirstStep('14:30'), { kind: 'at', arg: '14:30' }, 'parseFirstStep reads a clock time')
assertDeepEqual(model.parseFirstStep('2:30pm'), { kind: 'at', arg: '14:30' }, 'parseFirstStep reads a pm time')
assertEqual(model.parseFirstStep('abc'), null, 'parseFirstStep rejects nonsense')
assertEqual(model.parseFirstStep(''), null, 'parseFirstStep rejects an empty value')

assertDeepEqual(model.reminderArgs('15', 'Tea'), ['15', 'Tea'], 'reminderArgs passes minutes and message through')
assertDeepEqual(model.reminderArgs('14:30', ''), ['14:30'], 'reminderArgs omits an empty message')
assertDeepEqual(model.reminderArgs('bogus', 'Tea'), [], 'reminderArgs rejects an unparseable first step')
JS
pass "reminder flow model parses minutes and clock times"
