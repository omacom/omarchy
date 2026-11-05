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
  reminders.reminderArgs('0', 'ignored'),
  [],
  'reminders command args are empty for invalid minutes'
)
JS

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/home"
for command in omarchy-i18n omarchy-notification-send omarchy-shell systemd-run systemctl jq; do
  printf '#!/bin/bash\nexit 0\n' >"$work/bin/$command"
done
cat >"$work/bin/date" <<'SH'
#!/bin/bash
if [[ ${1:-} == "-d" ]]; then
  printf '12:00\n'
  exit 0
fi
exec /bin/date "$@"
SH
chmod +x "$work/bin"/*

env -u XDG_RUNTIME_DIR HOME="$work/home" XDG_STATE_HOME="$work/state" \
  PATH="$work/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-reminder" 5 "oven check" >/dev/null
message=$(find "$work/state/omarchy/omarchy-reminders" -name '*.message' -print -quit)
[[ -n $message && ! -L $message && $(cat "$message") == "oven check" ]] ||
  fail "reminder text is stored in the private state dir"
[[ $(stat -f %Lp "$message") == "600" || $(stat -c %a "$message" 2>/dev/null) == "600" ]] ||
  fail "reminder text is not readable by other accounts"
[[ ! -e /tmp/omarchy-reminders && ! -L /tmp/omarchy-reminders ]] ||
  fail "reminder text is not stored in /tmp"
pass "reminder text stays out of /tmp"
