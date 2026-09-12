#!/bin/bash
#
# Who may change what, before and after a PIN exists. The parent's setup is
# root's: setting the first PIN, the roster, a reset. The panel's grants are
# the PIN's, with a lockout that climbs. The control command acts only on the
# account sudo says is calling, never on one in an argument.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command openssl

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

export OMARCHY_SCREEN_TIME_ETC="$tmp_dir/etc"
export OMARCHY_SCREEN_TIME_STATE="$tmp_dir/state"
export OMARCHY_SCREEN_TIME_RUN="$tmp_dir/run"
mkdir -p "$OMARCHY_SCREEN_TIME_ETC" "$OMARCHY_SCREEN_TIME_STATE" "$OMARCHY_SCREEN_TIME_RUN"

PATH="$ROOT/bin:$PATH"
source omarchy-screen-time-lib

me=$(id -un)
my_uid=$(id -u)

# A config with this account under a profile, so ctl will act for it. Written
# through the library so it is shaped exactly as the daemon expects.
st_jq -n --arg me "$me" '
  default_config | .active_profile = "kids" |
  .profiles = {kids: (default_profile | .name = "Kids")} |
  .users = {($me): {profile: "kids"}}' | st_save_config

# ctl acts as the caller sudo names. The test sets it directly; sudo sets it
# from SUDO_UID in real use.
ctl() { OMARCHY_SCREEN_TIME_CALLER="$my_uid" bash "$ROOT/bin/omarchy-screen-time-ctl" "$@" || true; }

# --- the control command's own guards ---------------------------------------

grep -Fq '%omarchy-screen-time ALL=(root) NOPASSWD:' "$ROOT/etc/sudoers.d/omarchy-screen-time" ||
  fail "the sudoers grant is for the screen-time group and the ctl command only"
pass "the sudoers grant lets the group reach the control command without a password"

# A caller outside the roster gets nowhere, whatever it asks.
if OMARCHY_SCREEN_TIME_CALLER=0 bash "$ROOT/bin/omarchy-screen-time-ctl" status >/dev/null 2>&1; then
  # root is not in the roster here, so even status is not_managed.
  reply=$(OMARCHY_SCREEN_TIME_CALLER=0 bash "$ROOT/bin/omarchy-screen-time-ctl" grant 15 2>/dev/null || true)
  [[ $(jq -r .error <<<"$reply") == not_managed ]] || fail "an account outside the roster is refused"
fi
pass "the control command refuses an account that is not in the roster"

# --- no PIN yet -------------------------------------------------------------

# With no PIN stored, a grant is refused rather than waved through: the panel
# lock is not decoration.
reply=$(printf '\n' | ctl grant 15)
[[ $(jq -r .error <<<"$reply") == no_pin_set ]] || fail "a grant with no PIN set is refused, not waved through" "got: $reply"
pass "a grant is refused while no PIN is set"

# Setting the first PIN is root's, through the parent command, not the panel.
# The control command's pin change refuses while there is nothing to change,
# so it has no path to claim a first PIN.
reply=$(printf '\n1234\n' | ctl pin change)
[[ $(jq -r .error <<<"$reply") == no_pin_set ]] || fail "pin change refuses while there is no PIN to change" "got: $reply"
pass "the panel cannot claim the first PIN"

# The parent sets it: root writes a fresh hash into the config, which is what
# `sudo omarchy-parent screen-time pin set` does (the acceptance test drives
# that command end to end; here we are not root, so drive its one effect).
first_hash=$(printf '2468' | st_pin_hash)
st_jq --arg h "$first_hash" '.pin = {algo: "sha512crypt", hash: $h}' <"$OMARCHY_SCREEN_TIME_ETC/config.json" | st_save_config
[[ $(st_config | jq -r '.pin.hash') == '$6$'* ]] || fail "a PIN is now stored"
pass "the parent sets the first PIN"

# --- with a PIN -------------------------------------------------------------

# The right PIN hands out minutes; the day records it.
reply=$(printf '2468\n' | ctl grant 15)
[[ $(jq -r .ok <<<"$reply") == true ]] || fail "the right PIN hands out minutes" "got: $reply"
[[ $(jq -r .granted_seconds <<<"$reply") == 900 ]] || fail "fifteen minutes is nine hundred seconds"
pass "the right PIN hands out minutes"

# A wrong PIN is refused, and the cost climbs: the lockout backs off per
# failure (0, 0, 1, 5, ... seconds), so after the third wrong one the reply
# says to wait rather than bad_pin.
printf '0000\n' | ctl grant 5 >/dev/null   # failure 1, no wait
printf '0000\n' | ctl grant 5 >/dev/null   # failure 2, no wait
locked=$(printf '0000\n' | ctl grant 5)    # failure 3, now blocked
[[ $(jq -r .error <<<"$locked") == pin_locked_out ]] || fail "the PIN locks out after repeated failures" "got: $locked"
[[ $(jq -r .retry_in_seconds <<<"$locked") -ge 1 ]] || fail "the lockout says how long to wait"
pass "a wrong PIN backs off and then locks out"

# --- a reset clears it -------------------------------------------------------

# A reset is root's and takes no old PIN: the daemon's config is root's to
# edit anyway. Drive the reset path the parent command uses.
st_jq '.pin = null' <"$OMARCHY_SCREEN_TIME_ETC/config.json" | st_save_config
rm -f "$OMARCHY_SCREEN_TIME_STATE"/users/*/pin.json 2>/dev/null || true
[[ $(st_config | jq -r '.pin') == null ]] || fail "the reset removes the PIN"
reply=$(printf '\n' | ctl grant 15)
[[ $(jq -r .error <<<"$reply") == no_pin_set ]] || fail "after a reset the panel is back to no PIN"
pass "a reset returns the machine to no PIN"
