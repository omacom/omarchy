#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home" OMARCHY_PATH="$ROOT"
export SYSTEMCTL_CALLS="$test_tmp/systemctl-calls"
mkdir -p "$test_tmp/bin" "$HOME/.config/autostart"
cat >"$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
[[ $* == '--user daemon-reload' ]] || exit 90
printf '%s\n' "$*" >>"$SYSTEMCTL_CALLS"
exit "${TEST_SYSTEMCTL_STATUS:-0}"
SH
cat >"$test_tmp/bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == 1password ]] || exit 90
exit "${TEST_PACKAGE_STATUS:-0}"
SH
cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
[[ $* == '1password 1password-cli' ]] || exit 90
SH
cat >"$test_tmp/bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ $1 == chromium ]]
SH
cat >"$test_tmp/bin/setsid" <<'SH'
#!/bin/bash
[[ $* == 'uwsm-app -- 1password' ]] || exit 90
SH
chmod +x "$test_tmp/bin/"*
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"
helper="$ROOT/bin/omarchy-refresh-1password-autostart"
current="$HOME/.config/systemd/user/app-com.onepassword.OnePassword@autostart.service.d/90-omarchy-scale.conf"
legacy="$HOME/.config/systemd/user/app-1password@autostart.service.d/90-omarchy-scale.conf"

# Preseed overrides before Start at Login creates either desktop filename.
"$helper"
for dropin in "$current" "$legacy"; do
  [[ -f $dropin ]] || fail "autostart override is installed for both filenames"
  grep -Fx 'ExecStart=' "$dropin" >/dev/null || fail "override clears the generated launch command"
  grep -Fx 'ExecStart=:/opt/1Password/1password --silent --force-device-scale-factor=1' "$dropin" >/dev/null ||
    fail "override pins scale without systemd argument expansion"
  [[ $(stat -c %a "$dropin") == 644 ]] || fail "drop-in uses normal permissions"
done
[[ $(wc -l <"$SYSTEMCTL_CALLS") == 1 ]] || fail "changed overrides reload the user manager once"
pass "overrides cover current and legacy names before autostart is enabled"

cp "$current" "$test_tmp/expected"
inode=$(stat -c %i "$current")
"$helper"
[[ $(stat -c %i "$current") == "$inode" && $(wc -l <"$SYSTEMCTL_CALLS") == 1 ]] || fail "unchanged refresh must not replace files or reload"
pass "refresh is idempotent"

entry="$HOME/.config/autostart/com.onepassword.OnePassword.desktop"
for revision in first second third; do
  printf '[Desktop Entry]\nType=Application\nName=1Password\nExec=/opt/1Password/1password --silent\nX-Test=%s\n' "$revision" >"$entry"
  cp "$entry" "$test_tmp/desktop-before"
  "$helper"
  cmp -s "$entry" "$test_tmp/desktop-before" || fail "refresh must leave 1Password desktop rewrites untouched"
  cmp -s "$current" "$test_tmp/expected" || fail "drop-in survives desktop file rewrites"
done
pass "desktop file rewrites leave the scale override intact"

rm "$entry"
printf 'do not change\n' >"$test_tmp/desktop-target"
ln -s "$test_tmp/desktop-target" "$entry"
"$helper"
[[ -L $entry && $(cat "$test_tmp/desktop-target") == 'do not change' ]] || fail "desktop symlink target stays untouched"
pass "desktop symlinks remain untouched"

rm "$current" "$legacy"
TEST_SYSTEMCTL_STATUS=1 "$helper"
[[ -f $current && -f $legacy ]] || fail "no user manager must not lose the persistent overrides"
pass "setup works without a running user manager"

rm "$current" "$legacy"
TEST_PACKAGE_STATUS=1 bash -euo pipefail "$ROOT/migrations/1790807551.sh"
[[ ! -e $current && ! -e $legacy ]] || fail "migration must skip machines without 1Password"
bash -euo pipefail "$ROOT/migrations/1790807551.sh"
[[ -f $current && -f $legacy ]] || fail "migration configures installed 1Password"
cp "$current" "$test_tmp/expected"
bash -euo pipefail "$ROOT/migrations/1790807551.sh"
cmp -s "$current" "$test_tmp/expected" || fail "migration is idempotent"
pass "migration skips missing packages and is idempotent for installed packages"

rm "$current" "$legacy"
bash "$ROOT/bin/omarchy-install-service-1password" >"$test_tmp/install-out"
[[ -f $current && -f $legacy ]] || fail "installer must preseed persistent autostart overrides"
pass "installer configures overrides without polling desktop file creation"
[[ -z $(find "$HOME/.config/systemd/user" -name '.scale.*' -print) ]] || fail "temporary files must be removed"
pass "temporary files are cleaned up"
