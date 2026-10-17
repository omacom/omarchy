#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
eval_out="$test_tmp/hyprctl-eval"
reload_out="$test_tmp/hyprctl-reload"
notify_out="$test_tmp/notifications"
home_dir="$test_tmp/home"
monitor_lua="$home_dir/.config/hypr/monitors.lua"
rate_log="$home_dir/.local/state/omarchy/monitor-refresh-rate.log"
pending_file="$home_dir/.local/state/omarchy/monitor-refresh-rate-pending.json"

mkdir -p "$stub_bin" "$home_dir/.config/hypr"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

# Name and description arrive already JSON-escaped, so a case can hand the
# command the hostile strings a display is free to report.
monitor_json() {
  printf '[{"name":"%s","description":"%s","focused":true,"scale":1,"width":%s,"height":%s,"refreshRate":%s,"availableModes":["2560x1440@59.95Hz","2560x1440@99.95Hz","2560x1440@120.00Hz","2560x1440@144.00Hz","1920x1080@60.00Hz","3840x2160@30.00Hz"]}]' \
    "${OMARCHY_TEST_MONITOR_NAME:-DP-1}" "${OMARCHY_TEST_MONITOR_DESCRIPTION:-Acme Displays A1 SERIAL42}" \
    "${OMARCHY_TEST_MONITOR_WIDTH:-2560}" "${OMARCHY_TEST_MONITOR_HEIGHT:-1440}" "${OMARCHY_TEST_MONITOR_RATE:-120}"
}

if [[ $1 == "monitors" && $2 == "-j" ]]; then
  monitor_json
elif [[ $1 == "monitors" && $2 == "all" && $3 == "-j" ]]; then
  monitor_json
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
elif [[ $1 == "reload" ]]; then
  printf 'reloaded\n' >>"$OMARCHY_TEST_HYPRCTL_RELOAD_OUT"
else
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"

# Keep the auto-revert countdown from being spawned; the timer is exercised
# directly through the await-revert subcommand instead.
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/setsid"
chmod +x "$stub_bin/setsid"

printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"$OMARCHY_TEST_NOTIFY_OUT"\n' >"$stub_bin/omarchy-notification-send"
chmod +x "$stub_bin/omarchy-notification-send"

write_stock_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })
LUA
}

write_user_configured() {
  write_stock_config
  cat >>"$monitor_lua" <<'LUA'

hl.monitor({ output = "DP-1", mode = "2560x1440@120", position = "auto", scale = 1, bitdepth = 10 })
LUA
}

run_rate() {
  HOME="$home_dir" \
    XDG_STATE_HOME="$home_dir/.local/state" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    OMARCHY_TEST_HYPRCTL_RELOAD_OUT="$reload_out" \
    OMARCHY_TEST_NOTIFY_OUT="$notify_out" \
    "$ROOT/bin/omarchy-hyprland-monitor-refresh-rate" "$@"
}

reset_state() {
  rm -f "$eval_out" "$reload_out" "$notify_out" "$pending_file"
}

# --- Reporting -------------------------------------------------------------

reset_state
write_stock_config
rate=$(OMARCHY_TEST_MONITOR_RATE=143.99899 run_rate)
[[ $rate == "144" ]] || fail "monitor refresh rate normalizes the reported rate" "actual: $rate"
pass "monitor refresh rate normalizes the reported rate"

rates=$(run_rate list | tr '\n' ' ')
[[ $rates == "59.95 99.95 120 144 " ]] ||
  fail "monitor refresh rate lists current-resolution rates low to high" "actual: $rates"
pass "monitor refresh rate lists current-resolution rates low to high"

rates=$(OMARCHY_TEST_MONITOR_WIDTH=1920 OMARCHY_TEST_MONITOR_HEIGHT=1080 run_rate list | tr '\n' ' ')
[[ $rates == "60 " ]] || fail "monitor refresh rate filters rates to the active resolution" "actual: $rates"
pass "monitor refresh rate filters rates to the active resolution"

# --- Applying is live only -------------------------------------------------

reset_state
write_stock_config
before=$(cat "$monitor_lua")
run_rate 144 >/dev/null
grep -F 'mode = "2560x1440@144"' "$eval_out" >/dev/null || fail "monitor refresh rate applies the requested rate"
[[ $(cat "$monitor_lua") == "$before" ]] ||
  fail "monitor refresh rate does not persist before confirmation" "monitors.lua changed while pending"
[[ -f $pending_file ]] || fail "monitor refresh rate records a pending change"
pass "monitor refresh rate applies live without persisting"

pending=$(run_rate pending)
[[ $(jq -r '.pending' <<<"$pending") == "true" ]] || fail "monitor refresh rate reports a pending change"
[[ $(jq -r '.rate' <<<"$pending") == "144" ]] || fail "monitor refresh rate reports the pending rate"
pass "monitor refresh rate reports a pending change"

# --- Confirming persists ---------------------------------------------------

run_rate confirm
grep -F 'hl.monitor({ output = "desc:Acme Displays A1 SERIAL42", mode = "2560x1440@144", position = "auto", scale = omarchy_monitor_scale })' \
  "$monitor_lua" >/dev/null || fail "monitor refresh rate persists a desc-keyed rule" "$(cat "$monitor_lua")"
grep -F 'event=confirmed' "$rate_log" >/dev/null || fail "monitor refresh rate writes an audit entry"
[[ ! -f $pending_file ]] || fail "monitor refresh rate clears the pending change on confirm"
[[ ! -f $notify_out ]] || fail "monitor refresh rate says nothing about a rate it saved" "$(cat "$notify_out")"
pass "monitor refresh rate persists a desc-keyed rule on confirm"

# A second change updates the managed rule instead of stacking another one.
reset_state
OMARCHY_TEST_MONITOR_RATE=144 run_rate 120 >/dev/null
run_rate confirm
(($(grep -c 'Managed by omarchy hyprland monitor refresh rate' "$monitor_lua") == 1)) ||
  fail "monitor refresh rate keeps a single managed rule" "$(cat "$monitor_lua")"
grep -F 'mode = "2560x1440@120"' "$monitor_lua" >/dev/null ||
  fail "monitor refresh rate updates the managed rule in place" "$(cat "$monitor_lua")"
pass "monitor refresh rate updates its managed rule in place"

# Every managed monitor has a marker of its own, so changing one monitor's rate
# a second time must leave alone the rule another monitor was given.
other_monitor() {
  OMARCHY_TEST_MONITOR_NAME=DP-2 OMARCHY_TEST_MONITOR_DESCRIPTION="Other Displays B2 SERIAL7" run_rate "$@"
}

reset_state
write_stock_config
run_rate 144 >/dev/null
run_rate confirm
other_monitor 99.95 >/dev/null
other_monitor confirm
other_monitor 144 >/dev/null
other_monitor confirm
grep -F 'output = "desc:Acme Displays A1 SERIAL42", mode = "2560x1440@144"' "$monitor_lua" >/dev/null ||
  fail "monitor refresh rate leaves another monitor's managed rule alone" "$(cat "$monitor_lua")"
(($(grep -c 'desc:Other Displays B2 SERIAL7", mode = "2560x1440@144"' "$monitor_lua") == 1)) ||
  fail "monitor refresh rate updates only the rule of the monitor it changed" "$(cat "$monitor_lua")"
(($(grep -c 'Managed by omarchy hyprland monitor refresh rate' "$monitor_lua") == 2)) ||
  fail "monitor refresh rate keeps one managed rule per monitor" "$(cat "$monitor_lua")"
pass "monitor refresh rate keeps each monitor's managed rule its own"

# --- Hand-written rules are left alone -------------------------------------

reset_state
write_user_configured
before=$(cat "$monitor_lua")
run_rate 144 >/dev/null
message=$(run_rate confirm 2>&1 >/dev/null || true)
[[ $(cat "$monitor_lua") == "$before" ]] ||
  fail "monitor refresh rate leaves a user-configured monitor rule untouched" "$(diff <(printf '%s' "$before") "$monitor_lua")"
[[ $message == *"already configures"* ]] ||
  fail "monitor refresh rate explains why it did not persist" "actual: $message"
# The panel shows neither stderr nor an exit status, so it needs telling too.
grep -F 'Keeping 144Hz for this session' "$notify_out" 2>/dev/null | grep -F 'already configures' >/dev/null ||
  fail "monitor refresh rate notifies why it did not persist" "actual: $(cat "$notify_out" 2>/dev/null)"
pass "monitor refresh rate leaves user-configured rules untouched"

# --- Stepping and snapping -------------------------------------------------

reset_state
write_stock_config
OMARCHY_TEST_MONITOR_RATE=120 run_rate up >/dev/null
grep -F 'mode = "2560x1440@144"' "$eval_out" >/dev/null || fail "monitor refresh rate steps up to the next rate"
pass "monitor refresh rate steps up to the next rate"

reset_state
OMARCHY_TEST_MONITOR_RATE=120 run_rate down >/dev/null
grep -F 'mode = "2560x1440@99.95"' "$eval_out" >/dev/null || fail "monitor refresh rate steps down to the previous rate"
pass "monitor refresh rate steps down to the previous rate"

reset_state
rate=$(OMARCHY_TEST_MONITOR_RATE=144 run_rate up)
[[ $rate == "144" ]] || fail "monitor refresh rate clamps at the highest rate" "actual: $rate"
[[ ! -f $eval_out && ! -f $pending_file ]] ||
  fail "monitor refresh rate starts nothing when already at the highest rate"
pass "monitor refresh rate clamps at the highest rate"

reset_state
run_rate 165 >/dev/null
grep -F 'mode = "2560x1440@144"' "$eval_out" >/dev/null ||
  fail "monitor refresh rate snaps an unsupported rate onto an advertised mode"
pass "monitor refresh rate snaps an unsupported rate onto an advertised mode"

# --- Asking for nothing new ------------------------------------------------

# The rate already on screen is nothing to try out, so no countdown is armed
# for a change that a revert could not undo.
reset_state
write_stock_config
rate=$(run_rate 120)
[[ $rate == "120" ]] || fail "monitor refresh rate answers with the rate already in use" "actual: $rate"
[[ ! -f $eval_out && ! -f $pending_file ]] ||
  fail "monitor refresh rate starts nothing for the rate already in use"
pass "monitor refresh rate starts nothing for the rate already in use"

# Nor does asking for the rate on trial disturb the trial.
reset_state
run_rate 144 >/dev/null
deadline=$(jq -r '.deadline' "$pending_file")
OMARCHY_TEST_MONITOR_RATE=144 run_rate 144 >/dev/null
[[ -f $pending_file && $(jq -r '.deadline' "$pending_file") == "$deadline" && ! -f $reload_out ]] ||
  fail "monitor refresh rate leaves a trial alone when asked for the rate on trial"
pass "monitor refresh rate leaves a trial alone when asked for the rate on trial"

# Asking for the rate a trial started from is a revert, not a second trial.
reset_state
rm -f "$rate_log"
run_rate 144 >/dev/null
rm -f "$eval_out"
OMARCHY_TEST_MONITOR_RATE=144 run_rate 120 >/dev/null
[[ -f $reload_out ]] || fail "monitor refresh rate reloads Hyprland to return to where a trial started"
[[ ! -f $eval_out && ! -f $pending_file ]] ||
  fail "monitor refresh rate starts no second trial for the rate the first one started from"
grep -F 'event=reverted' "$rate_log" >/dev/null || fail "monitor refresh rate audits that as a revert"
pass "monitor refresh rate treats the rate a trial started from as a revert"

# A change that replaces a trial starts where the trial did, because that is
# the rate the reload returns to and so the one a revert would restore.
reset_state
run_rate 144 >/dev/null
OMARCHY_TEST_MONITOR_RATE=144 run_rate 99.95 >/dev/null
[[ $(jq -r '.previous' "$pending_file") == "120" ]] ||
  fail "monitor refresh rate records where a replaced trial started" "actual: $(jq -r '.previous' "$pending_file")"
pass "monitor refresh rate records where a replaced trial started"

# --- Reverting -------------------------------------------------------------

reset_state
write_stock_config
run_rate 144 >/dev/null
run_rate revert
[[ -f $reload_out ]] || fail "monitor refresh rate reloads Hyprland to revert"
[[ ! -f $pending_file ]] || fail "monitor refresh rate clears the pending change on revert"
pass "monitor refresh rate reverts a pending change"

# The countdown reverts a change that is never confirmed.
reset_state
write_stock_config
before=$(cat "$monitor_lua")
run_rate 144 >/dev/null
deadline=$(jq -r '.deadline' "$pending_file")
run_rate await-revert "$deadline"
[[ ! -f $pending_file ]] || fail "monitor refresh rate auto-reverts an unconfirmed change"
[[ -f $reload_out ]] || fail "monitor refresh rate reloads Hyprland when auto-reverting"
[[ $(cat "$monitor_lua") == "$before" ]] || fail "monitor refresh rate persists nothing when auto-reverting"
grep -F 'event=auto-reverted' "$rate_log" >/dev/null || fail "monitor refresh rate audits the auto-revert"
pass "monitor refresh rate auto-reverts an unconfirmed change"

# A timer armed for a superseded change must not revert the newer one.
reset_state
write_stock_config
run_rate 99.95 >/dev/null
stale_deadline=$(jq -r '.deadline' "$pending_file")
run_rate 144 >/dev/null
rm -f "$reload_out"
run_rate await-revert "$((stale_deadline - 1))"
[[ -f $pending_file ]] || fail "monitor refresh rate keeps a newer pending change"
[[ ! -f $reload_out ]] || fail "monitor refresh rate ignores a superseded countdown"
pass "monitor refresh rate ignores a superseded countdown"

# --- Hostile names ---------------------------------------------------------

# A display chooses its own EDID description, and the persisted rule is Lua that
# Hyprland runs again on every reload, so a description able to end the string
# early must never reach monitors.lua. The rate still holds for the session.
for hostile in \
  'Acme\" }) os.execute(\"id\") hl.monitor({ output = \"' \
  'Acme \\' \
  'Acme\nos.execute(\"id\")'; do
  reset_state
  write_stock_config
  before=$(cat "$monitor_lua")
  OMARCHY_TEST_MONITOR_DESCRIPTION=$hostile run_rate 144 >/dev/null
  # Without this the case would pass just as well on a stub that dropped the payload.
  [[ $(jq -r '.description' "$pending_file") == Acme?* ]] ||
    fail "monitor refresh rate is handed the hostile description" "actual: $(jq -c '.description' "$pending_file")"
  message=$(OMARCHY_TEST_MONITOR_DESCRIPTION=$hostile run_rate confirm 2>&1)
  [[ $(cat "$monitor_lua") == "$before" ]] ||
    fail "monitor refresh rate never writes a hostile description as Lua" "$(cat "$monitor_lua")"
  [[ $message == *"cannot be written"* ]] ||
    fail "monitor refresh rate explains a description it will not write" "actual: $message"
  grep -F 'cannot be written' "$notify_out" >/dev/null 2>&1 ||
    fail "monitor refresh rate notifies about a description it will not write"
  grep -F 'detail=unsafe-description' "$rate_log" >/dev/null ||
    fail "monitor refresh rate audits a description it will not write"
  rm -f "$rate_log"
done
pass "monitor refresh rate never writes a hostile description as Lua"

# The connector name goes straight into the Lua handed to hyprctl eval.
reset_state
write_stock_config
OMARCHY_TEST_MONITOR_NAME='DP-1\" }) os.execute(\"id\") --' run_rate 144 >/dev/null 2>&1 &&
  fail "monitor refresh rate refuses a hostile connector name"
[[ ! -f $eval_out ]] || fail "monitor refresh rate evals nothing for a hostile connector name" "$(cat "$eval_out")"
[[ ! -f $pending_file ]] || fail "monitor refresh rate leaves nothing pending for a hostile connector name"
pass "monitor refresh rate refuses a hostile connector name"

# --- Confirming nothing ----------------------------------------------------

reset_state
run_rate confirm 2>/dev/null && fail "monitor refresh rate rejects confirming with nothing pending"
pass "monitor refresh rate rejects confirming with nothing pending"
