#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

helper="$ROOT/bin/omarchy-install-chromium-h264ify"
extension="$ROOT/default/chromium/hardware-extensions/enhanced-h264ify"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# The GPU check answers from a file, so each case picks the hardware.
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/omarchy-hw-intel-no-av1-decode" <<'STUB'
#!/bin/bash
[[ -e $OMARCHY_TEST_NO_AV1 ]]
STUB
chmod +x "$test_tmp/bin/omarchy-hw-intel-no-av1-decode"
export OMARCHY_TEST_NO_AV1="$test_tmp/no-av1"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

new_home() {
  local home="$test_tmp/home-$1"
  mkdir -p "$home/.config"
  echo "$home"
}

run_helper() {
  HOME="$1" bash "$helper"
}

shipped="$ROOT/config/chromium-flags.conf"
loaded=$(grep -- '^--load-extension=' "$shipped")

[[ -f $extension/manifest.json && -f $extension/LICENSE ]] || fail "the extension ships its manifest and license"
jq -e '.manifest_version == 3' "$extension/manifest.json" >/dev/null || fail "the extension is a Manifest V3 extension"
while read -r file; do
  [[ -f $extension/$file ]] || fail "the extension ships $file, which its manifest loads"
done < <(jq -r '[(.content_scripts[]? | .js[]?), (.web_accessible_resources[]? | .resources[]?), (.icons // {} | .[])] | .[]' "$extension/manifest.json")
pass "the extension ships the files its manifest loads"

touch "$OMARCHY_TEST_NO_AV1"
home=$(new_home shipped)
cp "$shipped" "$home/.config/chromium-flags.conf"
run_helper "$home"
run_helper "$home"
conf="$home/.config/chromium-flags.conf"
grep -Fxq -- "$loaded,$extension" "$conf" || fail "the extension joins the shipped extensions" "$(cat "$conf")"
(( $(grep -c -- '^--load-extension=' "$conf") == 1 )) || fail "one --load-extension line stays" "$(cat "$conf")"
(( $(grep -oF -- "$extension" "$conf" | wc -l) == 1 )) || fail "the extension is added once, even when the helper runs twice" "$(cat "$conf")"
diff <(grep -v -- '^--load-extension=' "$shipped") <(grep -v -- '^--load-extension=' "$conf") >/dev/null || fail "the other flags stay as they are" "$(cat "$conf")"
pass "an Intel GPU without AV1 decoding gets the extension once, even when the helper runs twice"

home=$(new_home no-trailing-newline)
printf '%s\n%s' '--ozone-platform=wayland' '--no-first-run' >"$home/.config/chromium-flags.conf"
run_helper "$home"
[[ $(cat "$home/.config/chromium-flags.conf") == $'--ozone-platform=wayland\n--no-first-run\n'"--load-extension=$extension" ]] ||
  fail "a flags file without a load line and a final newline gets its own line" "$(cat "$home/.config/chromium-flags.conf")"
pass "a flags file without a load line gets one"

home=$(new_home comment)
printf '%s\n' '--load-extension=/a,/b # mine' '--no-first-run' >"$home/.config/chromium-flags.conf"
run_helper "$home"
[[ $(cat "$home/.config/chromium-flags.conf") == $'--load-extension=/a,/b,'"$extension"$' # mine\n--no-first-run' ]] ||
  fail "the extension joins the list ahead of a trailing comment" "$(cat "$home/.config/chromium-flags.conf")"
pass "the extension joins the list ahead of a trailing comment"

home=$(new_home empty-list)
printf '%s\n' '--load-extension=' >"$home/.config/chromium-flags.conf"
run_helper "$home"
[[ $(cat "$home/.config/chromium-flags.conf") == "--load-extension=$extension" ]] ||
  fail "an empty list gains no leading comma" "$(cat "$home/.config/chromium-flags.conf")"
pass "an empty list gains no leading comma"

home=$(new_home commented-out)
printf '%s\n' "# --load-extension=$extension" >"$home/.config/chromium-flags.conf"
run_helper "$home"
grep -Fxq -- "--load-extension=$extension" "$home/.config/chromium-flags.conf" || fail "a commented-out extension doesn't count as loaded" "$(cat "$home/.config/chromium-flags.conf")"
pass "a commented-out extension doesn't count as loaded"

home=$(new_home earlier-line)
printf '%s\n' "--load-extension=/a,$extension" '--no-first-run' '--load-extension=/b' >"$home/.config/chromium-flags.conf"
run_helper "$home"
run_helper "$home"
[[ $(cat "$home/.config/chromium-flags.conf") == "--load-extension=/a,$extension"$'\n--no-first-run\n'"--load-extension=/b,$extension" ]] ||
  fail "an extension only on an earlier --load-extension line is added to the last one, which Chromium uses" "$(cat "$home/.config/chromium-flags.conf")"
pass "an extension only on an earlier --load-extension line is added to the last one"

home=$(new_home last-line)
printf '%s\n' '--load-extension=/a' "--load-extension=/b,$extension # mine" >"$home/.config/chromium-flags.conf"
run_helper "$home"
[[ $(cat "$home/.config/chromium-flags.conf") == $'--load-extension=/a\n'"--load-extension=/b,$extension # mine" ]] ||
  fail "an extension already on the last --load-extension line stays as it is" "$(cat "$home/.config/chromium-flags.conf")"
pass "an extension already on the last --load-extension line stays as it is"

home=$(new_home similar-path)
printf '%s\n' "--load-extension=/a,$extension-old" >"$home/.config/chromium-flags.conf"
run_helper "$home"
[[ $(cat "$home/.config/chromium-flags.conf") == "--load-extension=/a,$extension-old,$extension" ]] ||
  fail "a longer path that starts with the extension's doesn't count as loaded" "$(cat "$home/.config/chromium-flags.conf")"
pass "a longer path that starts with the extension's doesn't count as loaded"

home=$(new_home no-file)
run_helper "$home"
[[ ! -e $home/.config/chromium-flags.conf ]] || fail "no flags file is created for a browser that isn't installed"
pass "no flags file is created for a browser that isn't installed"

home=$(new_home chrome)
cp "$shipped" "$home/.config/chrome-flags.conf"
run_helper "$home"
cmp -s "$shipped" "$home/.config/chrome-flags.conf" || fail "Chrome's flags stay as they are, since it ignores --load-extension" "$(cat "$home/.config/chrome-flags.conf")"
pass "Chrome's flags stay as they are"

rm "$OMARCHY_TEST_NO_AV1"
home=$(new_home other)
cp "$shipped" "$home/.config/chromium-flags.conf"
run_helper "$home"
cmp -s "$shipped" "$home/.config/chromium-flags.conf" || fail "other machines keep Chromium's flags" "$(cat "$home/.config/chromium-flags.conf")"
pass "other machines keep Chromium's flags"
