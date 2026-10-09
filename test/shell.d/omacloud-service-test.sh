#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
export TEST_LOG="$tmp_dir/log"

# Package removal and systemd are stubbed; the script's job is what it asks
# for.
for stub in omarchy-pkg-drop; do
  cat >"$tmp_dir/bin/$stub" <<SCRIPT
#!/bin/bash
printf '%s:%s\n' "$stub" "\$*" >>"\$TEST_LOG"
SCRIPT
  chmod +x "$tmp_dir/bin/$stub"
done
# systemctl answers is-enabled and is-active from SYSTEMCTL_STATE.
cat >"$tmp_dir/bin/systemctl" <<'SCRIPT'
#!/bin/bash
printf 'systemctl:%s\n' "$*" >>"$TEST_LOG"
for arg; do
  case $arg in
    is-enabled) [[ $SYSTEMCTL_STATE == *enabled* ]]; exit ;;
    is-active) [[ $SYSTEMCTL_STATE == *active* ]]; exit ;;
  esac
done
SCRIPT
chmod +x "$tmp_dir/bin/systemctl"
export PATH="$tmp_dir/bin:$PATH"
export SYSTEMCTL_STATE="enabled active"

output=$("$ROOT/bin/omarchy-remove-service-omacloud")
grep -qx 'systemctl:--user disable --now omacloud' "$TEST_LOG" ||
  fail "remove disables the user service" "$(cat "$TEST_LOG")"
grep -qx 'omarchy-pkg-drop:omacloud' "$TEST_LOG" ||
  fail "remove drops the omacloud package" "$(cat "$TEST_LOG")"
[[ $output == *"Your files stay"* ]] ||
  fail "remove says the files stay" "$output"
pass "remove disables the service, drops the package and leaves the user's files where they are"

: >"$TEST_LOG"
cat >"$tmp_dir/bin/omarchy-pkg-drop" <<'SCRIPT'
#!/bin/bash
printf 'omarchy-pkg-drop:%s\n' "$*" >>"$TEST_LOG"
exit 1
SCRIPT
if output=$("$ROOT/bin/omarchy-remove-service-omacloud"); then
  fail "remove fails when the package can't be dropped" "$output"
fi
[[ $output != *"has been removed"* ]] ||
  fail "remove doesn't claim success when the drop fails" "$output"
grep -qx 'systemctl:--user enable omacloud' "$TEST_LOG" &&
  grep -qx 'systemctl:--user start omacloud' "$TEST_LOG" ||
  fail "remove turns sync back on when the drop fails" "$(cat "$TEST_LOG")"
pass "remove fails without claiming success, and turns sync back on, when the package can't be dropped"

: >"$TEST_LOG"
export SYSTEMCTL_STATE=""
if "$ROOT/bin/omarchy-remove-service-omacloud" >/dev/null; then
  fail "remove fails when the package can't be dropped"
fi
! grep -Eq 'systemctl:--user (enable|start) omacloud' "$TEST_LOG" ||
  fail "remove leaves sync off when it was off and the drop fails" "$(cat "$TEST_LOG")"
pass "remove leaves sync off when it was off before a failed drop"

menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
grep -q '"install.service.omacloud".*omarchy-install-and-launch Omacloud omacloud com.ferdousbhai.Omacloud' "$menu" ||
  fail "Install > Service > Omacloud installs the package and opens the app"
grep -q '"remove.service.omacloud".*omarchy-remove-service-omacloud' "$menu" ||
  fail "Remove > Service > Omacloud runs the remover"
pass "the menu offers Omacloud under Install and Remove > Service"
