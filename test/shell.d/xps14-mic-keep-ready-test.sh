#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

leaf="$ROOT/install/user/hardware/dell/xps14-mic-keep-ready.sh"
rule="$ROOT/default/wireplumber/wireplumber.conf.d/xps14-mic-keep-ready.conf"
target="$test_tmp/home/.config/wireplumber/wireplumber.conf.d/xps14-mic-keep-ready.conf"

mkdir -p "$test_tmp/bin" "$test_tmp/home"
cat >"$test_tmp/bin/omarchy-hw-match" <<'STUB'
#!/bin/bash
[[ $1 == "$FAKE_PRODUCT" ]]
STUB
chmod +x "$test_tmp/bin/omarchy-hw-match"

run_leaf() {
  FAKE_PRODUCT="$1" HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" PATH="$test_tmp/bin:$PATH" \
    bash -euo pipefail -c 'source "$1"' _ "$leaf"
}

grep -q 'run_logged "$OMARCHY_INSTALL/user/hardware/dell/xps14-mic-keep-ready.sh"' "$ROOT/install/user/all.sh" ||
  fail "user setup runs the XPS 14 microphone leaf"
grep -rq 'install/user/hardware/dell/xps14-mic-keep-ready.sh' "$ROOT/migrations" ||
  fail "a migration applies the XPS 14 microphone leaf to existing installs"
grep -q 'node.name = "alsa_input.pci-0000_00_1f.3-platform-sof_sdw.HiFi__Mic__source"' "$rule" ||
  fail "rule matches only the built-in microphone"
grep -q 'session.suspend-timeout-seconds = 0' "$rule" || fail "rule disables idle suspension"

run_leaf "DX13260"
[[ ! -e $target ]] || fail "other hardware gets no microphone rule"

run_leaf "DA14260"
cmp -s "$rule" "$target" || fail "XPS 14 receives the microphone rule"

printf '%s\n' 'user override' >"$target"
run_leaf "DA14260"
[[ $(cat "$target") == "user override" ]] || fail "existing user rule is preserved"

pass "XPS 14 microphone rule installs only on that model and preserves user copies"
