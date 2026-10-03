#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
export TEST_STATE="$tmpdir" OMARCHY_PATH="$tmpdir/omarchy" CALL_LOG="$tmpdir/calls"
export PATH="$tmpdir/bin:$PATH"
unit=omarchy-docked-lid-inhibit.service
vendor_unit="$tmpdir/usr/lib/systemd/system/$unit"
local_unit="$tmpdir/etc/systemd/system/$unit"
marker="$tmpdir/var/lib/omarchy/docked-lid-inhibit.initialized"
mkdir -p "$tmpdir/bin" "${vendor_unit%/*}" "${local_unit%/*}" "$OMARCHY_PATH/install/config"

# Change only system paths: run the real setup logic with temporary files and
# an inert systemctl. No host service, package, or power policy is touched.
sed -e "s|/usr/lib/systemd/system/|$tmpdir/usr/lib/systemd/system/|g" \
  -e "s|/etc/systemd/system/|$tmpdir/etc/systemd/system/|g" \
  -e "s|state_dir=/var/lib/omarchy|state_dir=$tmpdir/var/lib/omarchy|" \
  "$ROOT/install/config/docked-lid-inhibit.sh" >"$OMARCHY_PATH/install/config/docked-lid-inhibit.sh"
cat >"$tmpdir/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
cat >"$tmpdir/bin/systemctl" <<'SH'
#!/bin/bash
set -euo pipefail
unit=omarchy-docked-lid-inhibit.service
if [[ $1 == "is-enabled" ]]; then
  state=$(<"$TEST_STATE/enabled-state")
  echo "$state"
  [[ $state == enabled* ]]
  exit
fi
[[ $* == *"$unit"* || $1 == "daemon-reload" ]] || exit 0
echo "$*" >>"$CALL_LOG"
case $1 in
  enable | reenable)
    echo enabled >"$TEST_STATE/enabled-state"
    mkdir -p "$TEST_STATE/etc/systemd/system/graphical.target.wants"
    ln -sf "$TEST_STATE/usr/lib/systemd/system/$unit" "$TEST_STATE/etc/systemd/system/graphical.target.wants/$unit"
    ;;
  --runtime) echo enabled-runtime >"$TEST_STATE/enabled-state" ;;
  start) [[ ${START_FAIL:-0} == 0 ]] || exit 29 ;;
esac
SH
chmod +x "$tmpdir/bin/"*

reset_setup() {
  rm -rf "$tmpdir/var" "$tmpdir/etc/systemd/system"
  mkdir -p "${local_unit%/*}"
  cp "$ROOT/default/systemd/system/$unit" "$vendor_unit"
  echo disabled >"$TEST_STATE/enabled-state"
  : >"$CALL_LOG"
  export START_FAIL=0
}

run_migration() {
  bash -euo pipefail "$ROOT/migrations/1790703856.sh" >"$tmpdir/output" 2>&1
}

reset_setup
rm "$vendor_unit"
if run_migration; then fail "setup must refuse a missing vendor unit"; fi
[[ ! -e $marker && ! -s $CALL_LOG ]] || fail "missing matching package leaves setup retryable"
pass "setup requires the matching settings package before changing enablement"

reset_setup
run_migration
[[ $(<"$CALL_LOG") == $'daemon-reload\nenable omarchy-docked-lid-inhibit.service\nstart omarchy-docked-lid-inhibit.service' ]] ||
  fail "first migration activates the vendor service"
[[ -f $marker && $(stat -c %a "$marker") == "644" ]] || fail "machine setup completion is durable"
: >"$CALL_LOG"
for state in disabled masked enabled; do
  echo "$state" >"$TEST_STATE/enabled-state"
  run_migration
done
[[ ! -s $CALL_LOG ]] || fail "later users must preserve existing enablement decisions"
pass "first migration activates once; later users preserve disable and mask decisions"

reset_setup
bash -euo pipefail "$ROOT/install/config/enable-services.sh"
[[ $(<"$CALL_LOG") == 'enable omarchy-docked-lid-inhibit.service' && -f $marker ]] ||
  fail "fresh installation enables without starting or reloading services"
: >"$CALL_LOG"
echo disabled >"$TEST_STATE/enabled-state"
run_migration
[[ ! -s $CALL_LOG ]] || fail "install marker must preserve a later opt-out during migration"
pass "fresh installation enables for reboot and seeds the machine-wide marker"

reset_setup
ln -s /dev/null "$local_unit"
echo masked >"$TEST_STATE/enabled-state"
run_migration
[[ -L $local_unit && $(readlink "$local_unit") == "/dev/null" && -f $marker ]] || fail "pre-existing mask survives setup"
[[ $(<"$CALL_LOG") == daemon-reload ]] || fail "masked service must not be enabled or started"
pass "a mask applied before the first migration remains effective"

for definition in copied original; do
  reset_setup
  cp "$SHELL_TEST_DIR/fixtures/docked-lid-copied.service" "$local_unit"
  [[ $definition != "original" ]] || sed -i '/^# Both Omarchy helpers/d' "$local_unit"
  echo enabled >"$TEST_STATE/enabled-state"
  mkdir -p "${local_unit%/*}/graphical.target.wants"
  ln -s "$local_unit" "${local_unit%/*}/graphical.target.wants/$unit"
  run_migration
  [[ ! -e $local_unit && $(readlink "${local_unit%/*}/graphical.target.wants/$unit") == "$vendor_unit" ]] ||
    fail "old enabled copy must yield to vendor updates and relink enablement"
  [[ $(<"$CALL_LOG") == $'daemon-reload\nreenable omarchy-docked-lid-inhibit.service\nstart omarchy-docked-lid-inhibit.service' ]] ||
    fail "old enabled copy must retain activation"
done
pass "both earlier enabled definitions are retired and their enablement links repaired"

reset_setup
cp "$SHELL_TEST_DIR/fixtures/docked-lid-copied.service" "$local_unit"
run_migration
[[ ! -e $local_unit && -f $marker && $(<"$CALL_LOG") == daemon-reload ]] ||
  fail "old disabled copy must be retired without re-enabling protection"
pass "an earlier disabled copy remains opted out after adopting vendor updates"

reset_setup
echo 'administrator-authored unit' >"$local_unit"
run_migration
[[ $(<"$local_unit") == 'administrator-authored unit' && $(<"$CALL_LOG") == daemon-reload ]] ||
  fail "custom units and their disable decisions must be preserved"
pass "administrator-authored definitions are preserved"

reset_setup
export START_FAIL=1
if run_migration; then fail "failed activation must fail the migration"; fi
[[ ! -e $marker ]] || fail "failed activation must remain retryable"
export START_FAIL=0
run_migration
[[ -f $marker ]] || fail "successful retry publishes completion"
pass "activation failures leave setup retryable"

reset_setup
run_migration &
first_pid=$!
run_migration &
second_pid=$!
wait "$first_pid" "$second_pid"
[[ $(grep -c '^enable ' "$CALL_LOG") == 1 && $(grep -c '^start ' "$CALL_LOG") == 1 ]] ||
  fail "concurrent users must serialize machine setup"
pass "concurrent per-user migrations activate the service only once"
