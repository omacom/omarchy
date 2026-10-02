#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
mkdir -p "$HOME/.grok/bin" "$test_tmp/bin" "$test_tmp/installs/npm-xai-official-grok/1.0.44"

# mise reports the installed release by its directory; running grok under it
# stands in for the npm launcher unpacking that release.
cat >"$test_tmp/bin/mise" <<SH
#!/bin/bash
case "\$1" in
  up) exit "\${OMARCHY_TEST_MISE_UP_STATUS:-0}" ;;
  where) echo "$test_tmp/installs/npm-xai-official-grok/1.0.44" ;;
  x) echo "\$GROK_HOME" >"$test_tmp/grok-ran"; touch "\$HOME/.grok/bin/grok-1.0.44"; ln -sfn grok-1.0.44 "\$HOME/.grok/bin/grok" ;;
esac
SH
chmod +x "$test_tmp/bin/mise"

echo old >"$HOME/.grok/bin/grok-1.0.30"
ln -s grok-1.0.30 "$HOME/.grok/bin/grok"

GROK_HOME="$test_tmp/elsewhere" PATH="$test_tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-update-mise" >/dev/null
[[ $(cat "$test_tmp/grok-ran") == "$HOME/.grok" ]] || fail "the new release is unpacked into ~/.grok whatever GROK_HOME says" "$(cat "$test_tmp/grok-ran")"
[[ $(readlink "$HOME/.grok/bin/grok") == "grok-1.0.44" && ! -e $HOME/.grok/bin/grok-1.0.30 ]] ||
  fail "an update points Grok at the installed release and drops the old one" "$(ls -la "$HOME/.grok/bin")"
pass "an update points Grok at the installed release and drops the old one"

rm -f "$test_tmp/grok-ran"
PATH="$test_tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-update-mise" >/dev/null
[[ ! -e $test_tmp/grok-ran ]] || fail "a current Grok is left alone"
pass "a current Grok is left alone"

# An unpack that never arrives leaves the old release running.
rm -f "$HOME/.grok/bin/grok" "$HOME/.grok/bin/grok-1.0.44"
echo old >"$HOME/.grok/bin/grok-1.0.30"
ln -s grok-1.0.30 "$HOME/.grok/bin/grok"
sed -i 's/^  x) .*/  x) exit 1 ;;/' "$test_tmp/bin/mise"
PATH="$test_tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-update-mise" >/dev/null
[[ $(readlink "$HOME/.grok/bin/grok") == "grok-1.0.30" && -e $HOME/.grok/bin/grok-1.0.30 ]] ||
  fail "a failed unpack keeps the old Grok release" "$(ls -la "$HOME/.grok/bin")"
pass "a failed unpack keeps the old Grok release"

# A failed tool update still reads as one, whatever the Grok upkeep did.
if OMARCHY_TEST_MISE_UP_STATUS=1 PATH="$test_tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-update-mise" >/dev/null 2>&1; then
  fail "a failed mise update is reported as failed"
fi
pass "a failed mise update is reported as failed"
