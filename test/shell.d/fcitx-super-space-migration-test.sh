#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1790924851.sh"
shipped="$ROOT/config/fcitx5/config"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"
export GDBUS_CALLS="$test_dir/gdbus-calls"
export FCITX_ACTIVE=1
export GDBUS_STATUS=0

cat >"$test_dir/bin/systemctl" <<'STUB'
#!/bin/bash

[[ $* == *is-active*omarchy-fcitx5.service* ]] || exit 1
# systemctl is-active exits 0 when the unit is running.
if [[ ${FCITX_ACTIVE:-0} == 1 ]]; then
  exit 0
fi
exit 1
STUB

cat >"$test_dir/bin/gdbus" <<'STUB'
#!/bin/bash

printf '%s\n' "$*" >>"$GDBUS_CALLS"
exit "${GDBUS_STATUS:-0}"
STUB

chmod +x "$test_dir/bin/"*

home="$test_dir/home"
config="$home/.config/fcitx5/config"

run_migration() {
  : >"$GDBUS_CALLS"
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$PATH" \
    bash -euo pipefail "$migration" >/dev/null
}

reset_home() {
  rm -rf "$home"
  mkdir -p "$home"
}

grep -F '[Hotkey/EnumerateGroupForwardKeys]' "$shipped" >/dev/null ||
  fail "shipped fcitx config clears the forward group hotkey"
grep -F '[Hotkey/EnumerateGroupBackwardKeys]' "$shipped" >/dev/null ||
  fail "shipped fcitx config clears the backward group hotkey"
grep -F 'Super+space' "$shipped" >/dev/null &&
  fail "shipped fcitx config still binds Super+space"
grep -F 'Super+Shift+space' "$shipped" >/dev/null &&
  fail "shipped fcitx config still binds Super+Shift+space"
pass "shipped fcitx config leaves Super+Space and Super+Shift+Space to Hyprland"

reset_home
FCITX_ACTIVE=1 run_migration
cmp -s "$shipped" "$config" || fail "a missing fcitx config is filled from the shipped file"
grep -F 'org.fcitx.Fcitx.Controller1.ReloadConfig' "$GDBUS_CALLS" >/dev/null ||
  fail "a running fcitx5 is not told to drop the old hotkeys"
pass "a missing fcitx config is installed and a running fcitx5 reloads it"

FCITX_ACTIVE=0 run_migration
[[ ! -s $GDBUS_CALLS ]] || fail "fcitx is reloaded when it is not running"
pass "an inactive fcitx5 is left for its next start to read the file"

reset_home
mkdir -p "$(dirname "$config")"
printf 'custom=1\n' >"$config"
FCITX_ACTIVE=1 run_migration
[[ $(cat "$config") == "custom=1" ]] || fail "an existing fcitx config is replaced"
[[ ! -s $GDBUS_CALLS ]] || fail "a custom fcitx config still triggers a reload"
pass "an existing fcitx config is left alone"

reset_home
GDBUS_STATUS=1
if FCITX_ACTIVE=1 run_migration; then
  fail "a failed fcitx reload marks the migration complete"
fi
cmp -s "$shipped" "$config" || fail "a failed reload rolls back the installed config"
GDBUS_STATUS=0
FCITX_ACTIVE=1 run_migration
grep -F 'org.fcitx.Fcitx.Controller1.ReloadConfig' "$GDBUS_CALLS" >/dev/null ||
  fail "a retry after a failed reload does not reload fcitx"
pass "a failed fcitx reload stays pending and the retry reloads"
