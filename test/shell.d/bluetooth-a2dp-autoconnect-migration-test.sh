#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1790015500.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin"
export CALL_LOG="$test_dir/calls"
export PATH="$test_dir/bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export HOME="$test_dir/home"
user_conf="$HOME/.config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf"
pending="$HOME/.local/state/omarchy/wireplumber-a2dp-restart-pending"

cat > "$test_dir/bin/systemctl" <<'SH'
#!/bin/bash
case "$*" in
  "--user is-active --quiet wireplumber.service") exit "${SERVICE_ACTIVE_EXIT:-0}" ;;
  "--user restart wireplumber.service" | "--user try-restart wireplumber.service")
    echo restart >> "$CALL_LOG"
    exit "${RESTART_EXIT:-0}"
    ;;
  *) exit 99 ;;
esac
SH
chmod +x "$test_dir/bin/systemctl"

write_stock_config() {
  mkdir -p "$(dirname "$user_conf")"
  sed -e 's/A2DP playback profiles/A2DP playback\/capture profiles/' \
    -e 's/\[ a2dp_sink \]/[ a2dp_sink a2dp_source ]/' \
    "$ROOT/config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf" > "$user_conf"
}

write_stock_config
: > "$CALL_LOG"
bash -euo pipefail "$migration" >/dev/null
cmp -s "$user_conf" "$ROOT/config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf" || fail "stock config is updated"
[[ $(cat "$CALL_LOG") == "restart" ]] || fail "active WirePlumber restarts exactly once"
[[ ! -e $pending ]] || fail "successful restart clears pending state"
pass "stock config updates and active WirePlumber restarts once"

: > "$CALL_LOG"
bash -euo pipefail "$migration" >/dev/null
[[ ! -s $CALL_LOG ]] || fail "completed migration does not restart again"
pass "migration is idempotent"

write_stock_config
sed -i 's/~bluez_card.*/my-speaker"/' "$user_conf"
printf '\n# Keep my custom volume policy\n' >> "$user_conf"
cp "$user_conf" "$test_dir/custom.conf"
: > "$CALL_LOG"
bash -euo pipefail "$migration" >/dev/null
cmp -s "$user_conf" "$test_dir/custom.conf" || fail "custom configuration is preserved byte-for-byte"
[[ ! -s $CALL_LOG ]] || fail "custom configuration does not trigger restart"
pass "custom Bluetooth configuration is preserved"

write_stock_config
: > "$CALL_LOG"
SERVICE_ACTIVE_EXIT=3 bash -euo pipefail "$migration" >/dev/null
[[ ! -s $CALL_LOG && ! -e $pending ]] || fail "inactive WirePlumber stays inactive"
! grep -q a2dp_source "$user_conf" || fail "inactive service config is still updated"
pass "inactive WirePlumber is not started"

write_stock_config
: > "$CALL_LOG"
if RESTART_EXIT=1 bash -euo pipefail "$migration" >/dev/null; then
  fail "restart failure keeps migration pending"
fi
[[ -f $pending ]] || fail "failed restart leaves retry state"
! grep -q a2dp_source "$user_conf" || fail "config was updated before restart"
: > "$CALL_LOG"
SERVICE_ACTIVE_EXIT=3 bash -euo pipefail "$migration" >/dev/null
[[ $(cat "$CALL_LOG") == "restart" && ! -e $pending ]] || fail "retry restarts even when previous failure left service inactive"
pass "failed restart is retried after config was updated"

rm "$user_conf"
: > "$CALL_LOG"
bash -euo pipefail "$migration" >/dev/null
[[ ! -e $user_conf && ! -s $CALL_LOG ]] || fail "missing config is untouched"
pass "missing config is untouched"
