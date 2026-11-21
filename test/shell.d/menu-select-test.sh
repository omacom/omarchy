#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Stands in for the running shell: keeps the payload the menu is summoned
# with, then closes the menu without a pick.
mkdir -p "$TMPDIR/stub"
cat >"$TMPDIR/stub/omarchy-shell" <<'STUB'
#!/bin/bash
printf '%s' "$4" >"$FAKE_PAYLOAD"
: >"$(jq -r .doneFile <<<"$4")"
STUB
chmod +x "$TMPDIR/stub/omarchy-shell"

export FAKE_PAYLOAD="$TMPDIR/payload.json"

# Rows and selections are data, so one that looks like a flag must reach the
# menu unchanged rather than be parsed as an option of the payload builder.
PATH="$TMPDIR/stub:$PATH" "$ROOT/bin/omarchy-menu-select" Pick -first --help -- --multiple --selected -first >/dev/null 2>&1 || true
[[ -s $FAKE_PAYLOAD ]] || fail "dash-prefixed rows still summon the menu"
actual=$(jq -c '{options, selected}' "$FAKE_PAYLOAD")
[[ $actual == '{"options":["-first","--help"],"selected":["-first"]}' ]] || fail "dash-prefixed rows and selections stay data" "actual: $actual"
pass "dash-prefixed rows and selections stay data"
