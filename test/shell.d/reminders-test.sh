#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const reminders = requireFromRoot('shell/plugins/reminders/ReminderFlowModel.js')

assertEqual(reminders.validMinutes('15'), '15', 'reminders accepts positive integer minutes')
assertEqual(reminders.validMinutes('  5  '), '5', 'reminders trims minute input')
assertEqual(reminders.validMinutes('0'), '', 'reminders rejects zero minutes')
assertEqual(reminders.validMinutes('-5'), '', 'reminders rejects negative minutes')
assertEqual(reminders.validMinutes('1.5'), '', 'reminders rejects fractional minutes')
assertEqual(reminders.validMinutes('soon'), '', 'reminders rejects non-numeric minutes')
assertEqual(reminders.validMinutes('17:00'), '', 'clock times are not raw minutes')

assertDeepEqual(
  reminders.parseClock('17:00'),
  { hour: 17, minute: 0, second: 0 },
  'reminders parse 24-hour clock times'
)
assertDeepEqual(
  reminders.parseClock('9:05'),
  { hour: 9, minute: 5, second: 0 },
  'reminders parse unpadded 24-hour clock times'
)
assertDeepEqual(
  reminders.parseClock('5pm'),
  { hour: 17, minute: 0, second: 0 },
  'reminders parse 12-hour clock times'
)
assertDeepEqual(
  reminders.parseClock('5:30 PM'),
  { hour: 17, minute: 30, second: 0 },
  'reminders parse spaced 12-hour clock times'
)
assertEqual(reminders.parseClock('24:00'), null, 'reminders reject 24:00')
assertEqual(reminders.parseClock('7:60'), null, 'reminders reject invalid minutes')

const sixteen = new Date(2026, 8, 10, 16, 0, 0)
const atFive = reminders.parseWhen('17:00', sixteen)
assertEqual(atFive.kind, 'time', 'clock input is a time reminder')
assertEqual(atFive.minutes, '60', '17:00 from 16:00 is 60 minutes')
assertEqual(atFive.displayTime, '17:00', 'clock reminders keep a display time')
assertEqual(reminders.parseWhen('5pm', sixteen).minutes, '60', '5pm from 16:00 is 60 minutes')
assertEqual(reminders.parseWhen('15', sixteen).kind, 'minutes', 'plain integers stay minute delays')
assertEqual(reminders.parseWhen('17.00', sixteen).minutes, '60', 'numpad decimal is a time separator')

const KEY_8 = 0x38
const KEY_UP = 0x01000013
const KEYPAD = 0x20000000
const CTRL = 0x04000000
assertEqual(reminders.typedChar(KEY_8, KEYPAD, 80, '8'), '8', 'synced numpad digit types 8')
assertEqual(reminders.typedChar(KEY_UP, 0, 80, ''), '8', 'unsynced numpad 8 types via scan code')
assertEqual(reminders.typedChar(KEY_UP, KEYPAD, 0, ''), '8', 'unsynced numpad 8 types via keypad modifier')
assertEqual(reminders.typedChar(KEY_UP, 0, 111, ''), '', 'dedicated Up arrow does not type a digit')
assertEqual(reminders.typedChar(65, 0, 38, 'a'), 'a', 'ordinary characters still type')
assertEqual(reminders.typedChar(KEY_8, CTRL, 80, '8'), '', 'ctrl+digit is ignored')

const listed = reminders.parseList(JSON.stringify({
  count: 1,
  reminders: [{ unit: 'omarchy-reminder-15m-1', label: 'Pickup Jack', remaining: '12m', atTime: '17:00' }]
}))
assertEqual(listed.length, 1, 'reminder json lists reminders')
assertEqual(reminders.rowTitle(listed[0]), 'Pickup Jack', 'reminder rows use the label')
assertEqual(reminders.rowMeta(listed[0]), '12m  (17:00)', 'reminder rows show remaining time')
assertEqual(reminders.validUnit('omarchy-reminder-15m-1710000000'), true, 'valid reminder units match the systemd name')
assertEqual(reminders.validUnit('omarchy-reminder-15m-1710000000.timer'), false, 'timer suffix is not a unit id')
assertEqual(reminders.validUnit('../evil'), false, 'paths are not valid reminder units')
assertEqual(reminders.parseList('nope').length, 0, 'invalid reminder json is empty')

assertDeepEqual(
  reminders.reminderArgs('10', 'Check the oven'),
  ['10', 'Check the oven'],
  'reminders builds command args with message'
)

assertDeepEqual(
  reminders.reminderArgs('10', ''),
  ['10'],
  'reminders omits empty message arg'
)

assertDeepEqual(
  reminders.reminderArgs('60', '', '17:00'),
  ['60', "It's 17:00"],
  'clock reminders default to a time label'
)

assertDeepEqual(
  reminders.reminderArgs('0', 'ignored'),
  [],
  'reminders command args are empty for invalid minutes'
)
JS
