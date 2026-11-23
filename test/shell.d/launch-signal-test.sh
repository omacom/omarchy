#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "clients" ]]; then
  printf '%s\n' "$OMARCHY_TEST_CLIENTS_JSON"
elif [[ $1 == "dispatch" ]]; then
  printf '%s\n' "$2" >>"$OMARCHY_TEST_DISPATCH_LOG"
fi
SH
chmod +x "$mock_bin/hyprctl"

# Launching instead of focusing would start Signal or its installer: record it instead.
for command in setsid omarchy-launch-floating-terminal-with-presentation; do
  printf '#!/bin/bash\ntouch "$OMARCHY_TEST_LAUNCHED"\n' >"$mock_bin/$command"
  chmod +x "$mock_bin/$command"
done

dispatch_log="$test_tmp/dispatch"
launched="$test_tmp/launched"
clients_json='[{"address":"0xabc","class":"signal","title":"Signal"}]'
PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" OMARCHY_TEST_LAUNCHED="$launched" \
  bash "$ROOT/bin/omarchy-launch-signal"

[[ ! -e $launched ]] || fail "Signal's launcher leaves a running app alone instead of launching another"
[[ $(sed -n 1p "$dispatch_log") == 'hl.dsp.focus({ window = "address:0xabc" })' ]] || \
  fail "Signal's launcher focuses the running app's window"
[[ $(sed -n 2p "$dispatch_log") == 'hl.dsp.window.alter_zorder({ mode = "top", window = "address:0xabc" })' ]] || \
  fail "Signal's launcher raises the window it focused, after focusing it"

pass "Signal's launcher brings a running app's window to the top, not only into focus"
