#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home/.config/omarchy/themes/custom"
printf 'palette\n' >"$test_tmp/home/.config/omarchy/themes/custom/colors.toml"
cat >"$test_tmp/bin/rm" <<'SH'
#!/bin/bash
if [[ ${FAIL_REMOVE:-no} == "yes" ]]; then
  echo 'rm: Permission denied' >&2
  exit 1
fi
exec /usr/bin/rm "$@"
SH
cat >"$test_tmp/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFICATION_LOG"
SH
chmod +x "$test_tmp/bin/"*
export HOME="$test_tmp/home" PATH="$test_tmp/bin:$PATH" NOTIFICATION_LOG="$test_tmp/notifications"

if FAIL_REMOVE=yes bash "$ROOT/bin/omarchy-theme-remove" custom >"$test_tmp/output" 2>"$test_tmp/errors"; then
  fail "failed deletion returns a failure status"
fi
[[ -f $HOME/.config/omarchy/themes/custom/colors.toml ]] || fail "failed deletion leaves the theme intact"
[[ ! -s $NOTIFICATION_LOG ]] || fail "failed deletion sends no success notification"
if grep -q 'Removed custom' "$test_tmp/output"; then
  fail "failed deletion prints no success message"
fi
pass "failed theme deletion reports failure without claiming success"

bash "$ROOT/bin/omarchy-theme-remove" custom >"$test_tmp/output"
[[ ! -e $HOME/.config/omarchy/themes/custom ]] || fail "successful deletion removes the theme"
grep -q 'Removed custom' "$test_tmp/output" || fail "successful deletion is reported"
grep -q 'Theme removed custom' "$NOTIFICATION_LOG" || fail "successful deletion sends its notification"
pass "successful theme removal still reports success"
