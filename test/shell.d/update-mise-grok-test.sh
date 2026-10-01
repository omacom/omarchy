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
  up) ;;
  where) echo "$test_tmp/installs/npm-xai-official-grok/1.0.44" ;;
  x) echo ran >"$test_tmp/grok-ran"; touch "\$HOME/.grok/bin/grok-1.0.44"; ln -sfn grok-1.0.44 "\$HOME/.grok/bin/grok" ;;
esac
SH
chmod +x "$test_tmp/bin/mise"

echo old >"$HOME/.grok/bin/grok-1.0.30"
ln -s grok-1.0.30 "$HOME/.grok/bin/grok"

PATH="$test_tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-update-mise" >/dev/null
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
