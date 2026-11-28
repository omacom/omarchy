#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

SCRIPT="$ROOT/bin/omarchy-setup-security-passwordless-login"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

FAKE_ROOT="$test_tmp/root"
STUBS="$test_tmp/stubs"
LOG_DIR="$test_tmp/logs"
SLOTS_DIR="$test_tmp/luks-slots"
mkdir -p "$FAKE_ROOT/etc/mkinitcpio.conf.d" "$FAKE_ROOT/etc/systemd/system" \
  "$FAKE_ROOT/var/lib/omarchy" "$FAKE_ROOT/run/lock" "$FAKE_ROOT/proc" \
  "$STUBS" "$LOG_DIR" "$SLOTS_DIR"

# Simulate a LUKS2 root device with user passphrase in slot 0.
reset_fixture() {
  rm -rf "$FAKE_ROOT" "$LOG_DIR" "$SLOTS_DIR"
  mkdir -p "$FAKE_ROOT/etc/mkinitcpio.conf.d" "$FAKE_ROOT/etc/systemd/system" \
    "$FAKE_ROOT/var/lib/omarchy" "$FAKE_ROOT/run/lock" "$FAKE_ROOT/proc" \
    "$LOG_DIR" "$SLOTS_DIR"
  printf 'user-passphrase' >"$SLOTS_DIR/0"
  printf 'cryptdevice=UUID=11111111-2222-3333-4444-555555555555:root root=/dev/mapper/root\n' >"$FAKE_ROOT/proc/cmdline"
  : >"$LOG_DIR/rebuild.log"
  : >"$LOG_DIR/cmdline.log"
  : >"$LOG_DIR/gum.log"
  : >"$LOG_DIR/refresh.log"
}

cat >"$STUBS/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB

cat >"$STUBS/findmnt" <<'STUB'
#!/bin/bash
echo "${TEST_ROOT_SOURCE:-/dev/mapper/root}[/@]"
STUB

cat >"$STUBS/lsblk" <<'STUB'
#!/bin/bash
if [[ $1 == "-dno" && $2 == "UUID" ]]; then
  echo "11111111-2222-3333-4444-555555555555"
  exit 0
fi
if [[ ${TEST_UNENCRYPTED:-0} == "1" ]]; then
  printf '/dev/nvme0n1p2 part btrfs\n'
else
  printf '/dev/mapper/root crypt btrfs\n/dev/nvme0n1p2 part crypto_LUKS\n'
fi
STUB

cat >"$STUBS/readlink" <<'STUB'
#!/bin/bash
if [[ $1 == "-f" && $2 == /dev/* ]]; then
  printf '%s\n' "$2"
  exit 0
fi
exec /usr/bin/readlink "$@"
STUB

cat >"$STUBS/cryptsetup" <<'STUB'
#!/bin/bash
set -euo pipefail
action=$1
shift
case "$action" in
  luksDump)
    echo "LUKS header information"
    echo "Keyslots:"
    for f in "$SLOTS_DIR"/*; do
      [[ -f $f ]] || continue
      echo "  $(basename "$f"): luks2"
    done
    ;;
  luksAddKey)
    stdin_key=0
    while (($# > 2)); do
      case "$1" in
        --iter-time) shift 2 ;;
        --key-file)
          [[ $2 == "-" ]] && stdin_key=1
          shift 2
          ;;
        *) shift ;;
      esac
    done
    keyfile=$2
    [[ -f $keyfile ]] || exit 1
    if (( stdin_key )); then
      entered=$(cat)
      matched=0
      for f in "$SLOTS_DIR"/*; do
        [[ -f $f ]] || continue
        if [[ $entered == "$(<"$f")" ]]; then
          matched=1
          break
        fi
      done
      if (( matched == 0 )); then
        echo "No key available with this passphrase." >&2
        exit 2
      fi
    fi
    next=1
    while [[ -f "$SLOTS_DIR/$next" ]]; do
      next=$((next + 1))
    done
    cp "$keyfile" "$SLOTS_DIR/$next"
    ;;
  open)
    keyfile=""
    while (($#)); do
      if [[ $1 == "--key-file" ]]; then
        keyfile=$2
        shift 2
      else
        shift
      fi
    done
    for f in "$SLOTS_DIR"/*; do
      [[ -f $f ]] || continue
      if cmp -s "$keyfile" "$f"; then
        echo "Key slot $(basename "$f") unlocked."
        exit 0
      fi
    done
    exit 2
    ;;
  luksRemoveKey)
    keyfile=""
    for arg in "$@"; do
      keyfile=$arg
    done
    for f in "$SLOTS_DIR"/*; do
      [[ -f $f ]] || continue
      if cmp -s "$keyfile" "$f"; then
        rm -f "$f"
        exit 0
      fi
    done
    exit 2
    ;;
  *)
    exit 1
    ;;
esac
STUB

cat >"$STUBS/omarchy-boot-rebuild" <<'STUB'
#!/bin/bash
echo "rebuild" >>"$LOG_DIR/rebuild.log"
[[ ${TEST_REBUILD_FAIL:-0} == "1" ]] && exit 1
exit 0
STUB

cat >"$STUBS/omarchy-boot-cmdline" <<'STUB'
#!/bin/bash
echo "$*" >>"$LOG_DIR/cmdline.log"
exit 0
STUB

cat >"$STUBS/omarchy-shell" <<'STUB'
#!/bin/bash
echo "$*" >>"$LOG_DIR/refresh.log"
exit 0
STUB

cat >"$STUBS/gum" <<'STUB'
#!/bin/bash
sub=$1
shift
case "$sub" in
  choose)
    # Record options (arguments after --header <val>)
    while (($#)); do
      if [[ $1 == "--header" ]]; then
        shift 2
      else
        printf '%s\n' "$1" >>"$LOG_DIR/gum.log"
        shift
      fi
    done
    printf '%s\n' "${TEST_GUM_CHOICE:-Next boot}"
    ;;
  confirm)
    exit "${TEST_GUM_CONFIRM:-0}"
    ;;
  input)
    printf '%s\n' "${TEST_PASSPHRASE:-user-passphrase}"
    ;;
  spin)
    while (($#)); do
      if [[ $1 == "--" ]]; then
        shift
        break
      fi
      shift
    done
    "$@"
    ;;
esac
STUB

chmod +x "$STUBS"/* "$SCRIPT"

run_cmd() {
  env \
    PATH="$STUBS:$PATH" \
    OMARCHY_PASSWORDLESS_LOGIN_TEST_ROOT="$FAKE_ROOT" \
    SLOTS_DIR="$SLOTS_DIR" \
    LOG_DIR="$LOG_DIR" \
    "$SCRIPT" "$@"
}

# 1. Interactive picker offers only "Next boot", "Next 3 boots", "Always"
reset_fixture
TEST_GUM_CHOICE="Next boot" run_cmd >/dev/null
options=$(paste -sd'|' "$LOG_DIR/gum.log")
[[ $options == "Next boot|Next 3 boots|Always" ]] ||
  fail "interactive menu offers exactly Next boot, Next 3 boots, Always" "got: $options"
pass "interactive menu offers exactly Next boot, Next 3 boots, Always"

# Next boot enabled state + single boot expiry
run_cmd --active || fail "Next boot marks passwordless login active"
[[ -f $FAKE_ROOT/crypto_keyfile.bin ]] || fail "Next boot creates keyfile"
[[ -f $FAKE_ROOT/etc/mkinitcpio.conf.d/99-omarchy-passwordless-login.conf ]] || fail "Next boot writes mkinitcpio drop-in"
[[ -f $FAKE_ROOT/etc/systemd/system/omarchy-passwordless-login-expire.service ]] || fail "Next boot installs expiry service"
[[ -L $FAKE_ROOT/etc/systemd/system/multi-user.target.wants/omarchy-passwordless-login-expire.service ]] || fail "Next boot enables expiry service"
[[ -f $SLOTS_DIR/1 ]] || fail "Next boot enrolls LUKS key slot 1"
(( $(wc -l <"$LOG_DIR/rebuild.log") == 1 )) || fail "Next boot rebuilds boot images once"

# Boot 1 ticks 1 -> 0 and immediately revokes everything
run_cmd __boot-tick >/dev/null
if run_cmd --active; then
  fail "Next boot deactivates on its first boot"
fi
[[ ! -e $FAKE_ROOT/crypto_keyfile.bin ]] || fail "Next boot expiry removes keyfile"
[[ ! -e $FAKE_ROOT/etc/mkinitcpio.conf.d/99-omarchy-passwordless-login.conf ]] || fail "Next boot expiry removes mkinitcpio drop-in"
[[ ! -e $FAKE_ROOT/etc/systemd/system/omarchy-passwordless-login-expire.service ]] || fail "Next boot expiry removes systemd unit"
[[ ! -e $FAKE_ROOT/var/lib/omarchy/passwordless-login ]] || fail "Next boot expiry removes state file"
[[ ! -e $SLOTS_DIR/1 && -f $SLOTS_DIR/0 ]] || fail "Next boot expiry revokes only the boot key slot and keeps slot 0"
(( $(wc -l <"$LOG_DIR/rebuild.log") == 2 )) || fail "Next boot expiry rebuilds boot images"
pass "Next boot unlocks one boot and revokes itself cleanly on that boot"

# 2. Next 3 boots counts down 3 -> 2 -> 1 -> revoke
reset_fixture
TEST_GUM_CHOICE="Next 3 boots" run_cmd >/dev/null
run_cmd __boot-tick >/dev/null
run_cmd --active || fail "Next 3 boots stays active after boot 1"
grep -q '^REMAINING=2$' "$FAKE_ROOT/var/lib/omarchy/passwordless-login" || fail "boot 1 decrements remaining to 2"
(( $(wc -l <"$LOG_DIR/rebuild.log") == 1 )) || fail "boot 1 does not rebuild boot images"

run_cmd __boot-tick >/dev/null
run_cmd --active || fail "Next 3 boots stays active after boot 2"
grep -q '^REMAINING=1$' "$FAKE_ROOT/var/lib/omarchy/passwordless-login" || fail "boot 2 decrements remaining to 1"
(( $(wc -l <"$LOG_DIR/rebuild.log") == 1 )) || fail "boot 2 does not rebuild boot images"

run_cmd __boot-tick >/dev/null
if run_cmd --active; then
  fail "Next 3 boots revokes on boot 3"
fi
[[ ! -e $SLOTS_DIR/1 && -f $SLOTS_DIR/0 ]] || fail "boot 3 revokes only slot 1"
(( $(wc -l <"$LOG_DIR/rebuild.log") == 2 )) || fail "boot 3 rebuilds boot images"
pass "Next 3 boots counts down across 3 boots and revokes on the 3rd boot"

# 3. Always stays active without an expiry unit, switching durations works, and re-running disables it
reset_fixture
TEST_GUM_CHOICE="Always" run_cmd >/dev/null
run_cmd --active || fail "Always activates passwordless login"
[[ ! -e $FAKE_ROOT/etc/systemd/system/omarchy-passwordless-login-expire.service ]] || fail "Always installs no expiry unit"
run_cmd __boot-tick >/dev/null
run_cmd --active || fail "Always survives boot ticks"

# Switching Always -> 1 adds the expiry unit without adding a second LUKS slot or rebuilding
run_cmd 1 >/dev/null
[[ -f $FAKE_ROOT/etc/systemd/system/omarchy-passwordless-login-expire.service ]] || fail "switching Always to 1 installs expiry unit"
[[ ! -e $SLOTS_DIR/2 ]] || fail "switching duration reuses existing LUKS key slot"
(( $(wc -l <"$LOG_DIR/rebuild.log") == 1 )) || fail "switching duration does not rebuild initramfs unnecessarily"

# Switching 1 -> Always removes the expiry unit
run_cmd always >/dev/null
[[ ! -e $FAKE_ROOT/etc/systemd/system/omarchy-passwordless-login-expire.service ]] || fail "switching 1 to Always removes expiry unit"

# Re-running with no args disables it
run_cmd >/dev/null
if run_cmd --active; then
  fail "re-running while active disables passwordless login"
fi
[[ ! -e $SLOTS_DIR/1 && -f $SLOTS_DIR/0 ]] || fail "manual disable revokes only slot 1"
pass "Always installs no expiry unit, duration switching reuses slot, and re-running disables cleanly"

# 4. sd-encrypt sets and unsets rd.luks.key cmdline drop-in
reset_fixture
printf 'rd.luks.name=11111111-2222-3333-4444-555555555555=root root=/dev/mapper/root\n' >"$FAKE_ROOT/proc/cmdline"
run_cmd always >/dev/null
grep -q '^set omarchy-passwordless-login rd\.luks\.key=11111111-2222-3333-4444-555555555555=/crypto_keyfile\.bin$' "$LOG_DIR/cmdline.log" ||
  fail "sd-encrypt sets rd.luks.key kernel parameter" "$(<"$LOG_DIR/cmdline.log")"
run_cmd --disable >/dev/null
grep -q '^unset omarchy-passwordless-login$' "$LOG_DIR/cmdline.log" ||
  fail "sd-encrypt unsets rd.luks.key kernel parameter on disable" "$(<"$LOG_DIR/cmdline.log")"
pass "sd-encrypt configures and clears rd.luks.key cmdline drop-ins"

# 5. Rollback when omarchy-boot-rebuild fails during enable
reset_fixture
if TEST_REBUILD_FAIL=1 run_cmd 1 >/dev/null 2>&1; then
  fail "enable fails when omarchy-boot-rebuild fails"
fi
[[ ! -e $FAKE_ROOT/crypto_keyfile.bin ]] || fail "rollback removes keyfile"
[[ ! -e $FAKE_ROOT/etc/mkinitcpio.conf.d/99-omarchy-passwordless-login.conf ]] || fail "rollback removes mkinitcpio drop-in"
[[ ! -e $FAKE_ROOT/var/lib/omarchy/passwordless-login ]] || fail "rollback removes state file"
[[ ! -e $FAKE_ROOT/etc/systemd/system/omarchy-passwordless-login-expire.service ]] || fail "rollback removes expiry unit"
[[ ! -e $SLOTS_DIR/1 && -f $SLOTS_DIR/0 ]] || fail "rollback revokes enrolled key slot and preserves slot 0"
pass "failed boot-image rebuild rolls back LUKS slot and all files"

# 6. Refuses to revoke the last remaining LUKS key slot
reset_fixture
run_cmd always >/dev/null
rm -f "$SLOTS_DIR/0"
if run_cmd --disable >/dev/null 2>&1; then
  fail "disable refuses to remove the last remaining LUKS slot"
fi
[[ -f $SLOTS_DIR/1 ]] || fail "last remaining LUKS slot stays intact"
pass "disable refuses to revoke the last remaining LUKS key slot"

# 7. Rejects non-LUKS root drives and unmanaged /crypto_keyfile.bin
reset_fixture
if TEST_UNENCRYPTED=1 run_cmd 1 >/dev/null 2>&1; then
  fail "non-LUKS root drive is rejected"
fi
[[ ! -e $FAKE_ROOT/crypto_keyfile.bin ]] || fail "non-LUKS rejection writes no keyfile"

reset_fixture
printf 'existing-custom-key' >"$FAKE_ROOT/crypto_keyfile.bin"
if run_cmd 1 >/dev/null 2>&1; then
  fail "existing unmanaged /crypto_keyfile.bin is not overwritten"
fi
[[ $(<"$FAKE_ROOT/crypto_keyfile.bin") == "existing-custom-key" ]] || fail "unmanaged keyfile content stays untouched"
pass "rejects non-LUKS root drives and preserves unmanaged /crypto_keyfile.bin"

# 8. Wrong disk passphrase fails cleanly and rolls back the keyfile
reset_fixture
wrong_err=$(TEST_PASSPHRASE="wrong-password" run_cmd 1 2>&1) && fail "wrong disk passphrase fails" || true
[[ $wrong_err == *"No key available with this passphrase."* ]] || fail "wrong passphrase prints cryptsetup error" "$wrong_err"
[[ ! -e $FAKE_ROOT/crypto_keyfile.bin && ! -e $SLOTS_DIR/1 ]] || fail "wrong passphrase rolls back keyfile and adds no slot"
pass "wrong disk passphrase prints error and rolls back cleanly"

# 9. Enable and disable push indicator refreshes, disable explains what it is
# doing before prompting, and the bar indicator routes active clicks to
# --disable and inactive clicks to setup.
reset_fixture
run_cmd 1 >/dev/null
grep -qxF -- "-q omarchy.indicators refresh" "$LOG_DIR/refresh.log" ||
  fail "enabling refreshes the bar indicator" "$(<"$LOG_DIR/refresh.log")"
: >"$LOG_DIR/refresh.log"
disable_out=$(run_cmd --disable)
[[ $disable_out == "Disabling passwordless login..."$'\n'* ]] ||
  fail "--disable prints a status line before prompting" "$disable_out"
grep -qxF -- "-q omarchy.indicators refresh" "$LOG_DIR/refresh.log" ||
  fail "disabling refreshes the bar indicator" "$(<"$LOG_DIR/refresh.log")"
pass "enable and disable push bar indicator refreshes"

# 10. Missing or replaced keyfile refuses to finish disabling while its LUKS
# slot is still enabled, keeps state intact, and completes once the slot is
# manually killed.
reset_fixture
run_cmd always >/dev/null
rm -f "$FAKE_ROOT/crypto_keyfile.bin"
missing_err=$(run_cmd --disable 2>&1) && fail "disable fails when keyfile is missing and slot is still enabled" || true
[[ $missing_err == *"sudo cryptsetup luksKillSlot /dev/nvme0n1p2 1"* ]] ||
  fail "missing-keyfile error prints manual luksKillSlot recovery command" "$missing_err"
run_cmd --active || fail "state stays active when enrolled slot could not be revoked"
[[ -f $FAKE_ROOT/var/lib/omarchy/passwordless-login ]] || fail "state file is preserved until slot is revoked"

# Same if keyfile was replaced with unrelated bytes while slot 1 is still active.
printf 'wrong-keyfile-bytes' >"$FAKE_ROOT/crypto_keyfile.bin"
mismatch_err=$(run_cmd --disable 2>&1) && fail "disable fails when keyfile does not match still-enabled slot" || true
[[ $mismatch_err == *"sudo cryptsetup luksKillSlot /dev/nvme0n1p2 1"* ]] ||
  fail "mismatched-keyfile error prints manual luksKillSlot recovery command" "$mismatch_err"
run_cmd --active || fail "state stays active when mismatched keyfile left slot enabled"

# Once the user kills slot 1 manually, --disable finishes cleanup cleanly.
rm -f "$SLOTS_DIR/1" "$FAKE_ROOT/crypto_keyfile.bin"
run_cmd --disable >/dev/null
if run_cmd --active; then
  fail "disable succeeds after manual slot revocation"
fi
[[ ! -e $FAKE_ROOT/var/lib/omarchy/passwordless-login ]] || fail "state file is cleared once slot is confirmed gone"
pass "missing or replaced keyfile refuses to clear state until the enrolled LUKS slot is revoked"

run_node_test <<'JS'
const fs = require('fs')
const indicator = fs.readFileSync(path.join(root, 'shell/plugins/bar/indicators/PasswordlessLogin.qml'), 'utf8')
const press = new Function('root', indicator.match(/onPressed: function\(\) \{([\s\S]*?)\n  \}/)[1])
const launched = []
const button = { granted: true, bar: { run: command => launched.push(command) } }
press(button)
assertDeepEqual(
  launched,
  ['omarchy-launch-floating-terminal-with-presentation omarchy-setup-security-passwordless-login --disable'],
  'active indicator click opens disable flow'
)
launched.length = 0
button.granted = false
press(button)
assertDeepEqual(
  launched,
  ['omarchy-launch-floating-terminal-with-presentation omarchy-setup-security-passwordless-login'],
  'inactive indicator click opens interactive setup'
)
JS
