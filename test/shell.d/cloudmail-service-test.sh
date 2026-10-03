#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
export TEST_LOG="$tmp_dir/log"

# Package management and the app launch are stubbed; the scripts' job is what
# they ask for.
for stub in omarchy-pkg-add omarchy-pkg-drop uwsm-app; do
  cat >"$tmp_dir/bin/$stub" <<SCRIPT
#!/bin/bash
printf '%s:%s\n' "$stub" "\$*" >>"\$TEST_LOG"
SCRIPT
  chmod +x "$tmp_dir/bin/$stub"
done
export PATH="$tmp_dir/bin:$PATH"

output=$("$ROOT/bin/omarchy-install-service-cloudmail")
grep -qx 'omarchy-pkg-add:cloudmail npm' "$TEST_LOG" ||
  fail "install adds cloudmail with npm for setup" "$(cat "$TEST_LOG")"
for (( attempt=0; attempt<200; attempt++ )); do
  grep -q '^uwsm-app:' "$TEST_LOG" && break
  sleep 0.01
done
grep -qx 'uwsm-app:-- /usr/bin/cloudmail-gtk' "$TEST_LOG" ||
  fail "install opens the Cloudmail app" "$(cat "$TEST_LOG")"
[[ $output == *"cloudmail setup --mailbox"* ]] ||
  fail "install says how to deploy" "$output"
pass "install adds cloudmail and npm, opens the app, and says how to deploy"

: >"$TEST_LOG"
output=$("$ROOT/bin/omarchy-remove-service-cloudmail")
grep -qx 'omarchy-pkg-drop:cloudmail' "$TEST_LOG" ||
  fail "remove drops the cloudmail package" "$(cat "$TEST_LOG")"
[[ $output == *"stay in your Cloudflare account"* ]] ||
  fail "remove says the mail stays in Cloudflare" "$output"
pass "remove drops the package and leaves the user's mail where it is"

menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
grep -q '"install.service.cloudmail".*omarchy-install-service-cloudmail' "$menu" ||
  fail "Install > Service > Cloudmail runs the installer"
grep -q '"remove.service.cloudmail".*omarchy-remove-service-cloudmail' "$menu" ||
  fail "Remove > Service > Cloudmail runs the remover"
pass "the menu offers Cloudmail under Install and Remove > Service"
