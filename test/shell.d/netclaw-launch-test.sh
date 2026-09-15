#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/home"
export HOME="$scratch/home" OMARCHY_PATH="$ROOT"
export NETCLAW_TEST_ARGS="$scratch/args"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

cat >"$scratch/bin/omarchy-launch-terminal" <<'SH'
#!/bin/bash
[[ $1 == "-e" ]] || exit 90
shift
exec "$@"
SH
cat >"$scratch/bin/omarchy-netclaw-chat" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$NETCLAW_TEST_ARGS"
echo "chat result"
exit "${NETCLAW_TEST_RESULT:-0}"
SH
cat >"$scratch/bin/omarchy-netclaw-setup" <<'SH'
#!/bin/bash
echo "NetClaw setup is still running."
exit 24
SH
chmod +x "$scratch/bin/"*

output=$(omarchy-launch-netclaw --message 'interface "test" with spaces')
[[ $output == "chat result" ]] || fail 'successful chat has no failure prompt'
printf '%s\n' --message 'interface "test" with spaces' >"$scratch/expected"
[[ $(cat "$scratch/expected") == "$(cat "$NETCLAW_TEST_ARGS")" ]] || fail 'chat preserves message arguments'
pass 'desktop chat preserves arguments without pausing on success'

result=0
output=$(NETCLAW_TEST_RESULT=23 omarchy-launch-netclaw <<<"" 2>&1) || result=$?
(( result == 23 )) || fail 'chat preserves the failure exit code'
[[ $output == *"chat result"* && $output == *"See the error above"* ]] || fail 'chat leaves a visible failure explanation'
pass 'desktop chat keeps failures visible'

result=0
output=$(omarchy-netclaw-dashboard <<<"" 2>&1) || result=$?
(( result == 24 )) || fail 'dashboard preserves the setup failure exit code'
[[ $output == *"setup is still running"* && $output == *"Dashboard could not open"* ]] || fail 'dashboard explains incomplete setup'
pass 'dashboard exposes setup failures instead of reporting completion'
