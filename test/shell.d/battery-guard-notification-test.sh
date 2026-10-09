#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_TEST_NOTIFICATION_DIR="$tmp_dir"

# Run the real session notification function and wrapper against a recording
# D-Bus transport. Never start the guard or touch a running notification server.
cat >"$tmp_dir/busctl" <<'SH'
#!/bin/bash
count_file="$OMARCHY_TEST_NOTIFICATION_DIR/count-$OMARCHY_TEST_SESSION_UID"
count=0
[[ ! -f $count_file ]] || count=$(<"$count_file")
(( count += 1 ))
printf '%s\n' "$count" >"$count_file"
printf '%s\0' "$@" >"$OMARCHY_TEST_NOTIFICATION_DIR/call-$OMARCHY_TEST_SESSION_UID-$count"
printf 'u %s\n' "$((OMARCHY_TEST_SESSION_UID + 100))"
SH
chmod +x "$tmp_dir/busctl"
export PATH="$tmp_dir:$ROOT/bin:$PATH"

sed -n '/^notify_critical() {$/,/^}$/p' "$ROOT/bin/omarchy-battery-guard" >"$tmp_dir/notify.sh"
source "$tmp_dir/notify.sh"
declare -A notification_ids=()
session_users() { printf '1000 alice\n1001 bob\n'; }
as_session_user() {
  local uid="$1"
  shift 2
  OMARCHY_TEST_SESSION_UID="$uid" "$@"
}

notify_critical "Save your work and connect your charger. Shutdown in 60s."
notify_critical "Save your work and connect your charger. Shutdown in 30s."
notify_critical "Finish any save dialogs. Shutdown in 10s."
notify_critical "Shutting down…"
notify_critical "Charging resumed. Shutdown cancelled." 5000

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const notifications = requireFromRoot('shell/plugins/notifications/NotificationLogic.js')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/notifications/Service.qml'), 'utf8')
const shown = []
const silenced = []
const context = {
  NotificationLogic: notifications,
  NotificationUrgency: { Critical: 2 },
  service: { doNotDisturb: true, liveRefs: {}, refreshPopup() {} },
  liveRefs: {},
  snapshotOf: n => notifications.snapshotOf(n, Date.now()),
  isEphemeral: n => notifications.isEphemeralApp(n.appName),
  writeSilenced: n => silenced.push(n),
  persistPopupFile() {},
  watchForUpdates() {},
  removePopupsByOriginalId() {},
  removeDuplicatePopups() {},
  popupModel: { insert: (index, snapshot) => shown.push(snapshot) },
  Qt: { callLater: fn => fn() }
}
context.service.liveRefs = context.liveRefs
context.service.currentContent = n => n
vm.createContext(context)
for (const name of ['shouldBypassDnd', 'handleNotification']) {
  const match = serviceQml.match(new RegExp('^  function ' + name + '\\([^\\n]*\\) \\{[\\s\\S]*?^  \\}', 'm'))
  assert(match, `the notification service exposes ${name} for the DND fixture`)
  vm.runInContext(match[0], context)
}

for (const uid of [1000, 1001]) {
  for (let call = 1; call <= 5; call++) {
    const args = fs.readFileSync(path.join(process.env.OMARCHY_TEST_NOTIFICATION_DIR, `call-${uid}-${call}`), 'utf8').split('\0').slice(0, -1)
    assertEqual(args[6], 'Notify', `session ${uid} call ${call} uses the notification transport`)
    assertEqual(args[9], String(call === 1 ? 0 : uid + 100), `session ${uid} call ${call} replaces its own countdown`)
    const hints = {}
    for (let i = 15; i < 15 + 3 * Number(args[14]); i += 3) hints[args[i]] = args[i + 2]
    const notification = {
      id: uid + 100, appName: args[8], appIcon: args[10], summary: args[11], body: args[12],
      urgency: Number(hints.urgency), expireTimeout: Number(args.at(-1)), hints,
      closed: { connect() {} }
    }
    const previous = shown.length
    context.handleNotification(notification)
    assertEqual(shown.length, previous + 1, `session ${uid} countdown/recovery call ${call} shows with DND enabled`)
    assertEqual(shown.at(-1).body, args[12], `session ${uid} call ${call} displays the guard message`)
    assertEqual(notification.expireTimeout, call === 5 ? 5000 : 0, `session ${uid} call ${call} preserves its requested lifetime`)
  }
}
assertEqual(silenced.length, 0, 'DND never sends the emergency countdown to silent history')
assert(context.service.doNotDisturb, 'showing battery protection leaves DND enabled')

for (const [appName, urgency] of [['omarchy-battery-guard', 1], ['Slack', 2]]) {
  const previous = shown.length
  context.handleNotification({ id: 9000, appName, urgency, closed: { connect() {} } })
  assertEqual(shown.length, previous, `${appName} urgency ${urgency} remains silenced by DND`)
}
assertEqual(silenced.length, 2, 'non-emergency guard alerts and critical chat alerts still go to silent history')
JS
