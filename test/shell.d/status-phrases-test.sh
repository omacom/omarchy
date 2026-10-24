#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The command drives omarchy-bar against stubs: three widgets, state in a file.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir "$tmp/bin"
cat >"$tmp/bin/omarchy-bar" <<'STUB'
#!/bin/bash
state="$STUB_DIR/$2.$3"
case $1 in
get) [[ -f $state ]] && cat "$state" || exit 1 ;;
set) [[ $2 == "omarchy.network" && -n ${STUB_NO_NETWORK:-} ]] && exit 1; echo "$4" >"$state" ;;
esac
STUB
printf '#!/bin/bash\necho "$*" >>"$STUB_DIR/notifications"\n' >"$tmp/bin/omarchy-notification-send"
printf '#!/bin/bash\necho "$1"\n' >"$tmp/bin/omarchy-i18n"
cat >"$tmp/bin/omarchy-shell" <<'STUB'
#!/bin/bash
echo '[{"id":"alex.power","clonedFrom":"omarchy.power"},{"id":"alex.other","clonedFrom":"omarchy.weather"},{"id":"omarchy.clock","clonedFrom":""}]'
STUB
chmod +x "$tmp/bin/"*

status() { PATH="$tmp/bin:$PATH" STUB_DIR=$tmp "$ROOT/bin/omarchy-toggle-status-phrases" --status; }
run() { PATH="$tmp/bin:$PATH" STUB_DIR=$tmp "$ROOT/bin/omarchy-toggle-status-phrases" "$@"; }

[[ $(status) == "on" ]] || fail "status phrases default to on"
run toggle
[[ $(status) == "off" ]] || fail "toggle turns status phrases off"
for widget in power bluetooth network; do
  [[ $(<"$tmp/omarchy.$widget.statusPhrases") == "false" ]] || fail "toggle off sets $widget"
done
run toggle
[[ $(status) == "on" ]] || fail "toggle turns status phrases back on"
run off
[[ $(status) == "off" ]] || fail "off turns status phrases off"
run on
[[ $(status) == "on" ]] || fail "on turns status phrases on"
pass "omarchy-toggle-status-phrases sets every panel and reports the state"

# A clone sits on the bar under its own id, so it gets the option too.
run off
[[ $(<"$tmp/alex.power.statusPhrases") == "false" ]] || fail "off reaches a clone of a panel"
[[ ! -e $tmp/alex.other.statusPhrases && ! -e $tmp/omarchy.clock.statusPhrases ]] || fail "other widgets are left alone"
run on
[[ $(<"$tmp/alex.power.statusPhrases") == "true" ]] || fail "on reaches a clone of a panel"
pass "omarchy-toggle-status-phrases reaches clones of the panels"

STUB_NO_NETWORK=1 run off
[[ $(status) == "off" ]] || fail "a widget missing from the bar does not block the toggle"
pass "omarchy-toggle-status-phrases tolerates widgets that are not on the bar"

if run sideways 2>/dev/null; then
  fail "omarchy-toggle-status-phrases rejects unknown arguments"
fi
pass "omarchy-toggle-status-phrases rejects unknown arguments"
