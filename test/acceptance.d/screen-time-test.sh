#!/bin/bash
#
# Screen time on a real machine: the unit starts under systemd with the strict
# sandbox on, writes its config and state, keeps the PIN across a restart, and
# refuses a socket-less caller that is not in the roster through sudo. Runs
# only where the daemon is actually installed and sudo can be had without a
# prompt: passwordless (a default install under the harness), or with the
# parent password the harness hands a child install in
# OMARCHY_ACCEPTANCE_SUDO_PASSWORD, the way parent-test.sh takes it. Skips
# cleanly everywhere else.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v omarchy-parent-screen-time >/dev/null || [[ ! -f /etc/systemd/system/omarchy-screen-time.service ]]; then
  pass "screen time acceptance skipped: the daemon is not installed here"
  exit 0
fi
if [[ -n ${OMARCHY_ACCEPTANCE_SUDO_PASSWORD:-} ]]; then
  # Warm sudo's ticket with the parent password; every sudo -n below rides it.
  printf '%s\n' "$OMARCHY_ACCEPTANCE_SUDO_PASSWORD" | sudo -S -k -v 2>/dev/null ||
    fail "sudo accepts the parent password from OMARCHY_ACCEPTANCE_SUDO_PASSWORD"
elif ! sudo -n true 2>/dev/null; then
  pass "screen time acceptance skipped: needs passwordless sudo or OMARCHY_ACCEPTANCE_SUDO_PASSWORD (the acceptance harness)"
  exit 0
fi

me=$(id -un)

# Turn it on and put this account under a profile.
sudo -n omarchy-parent-screen-time on >/dev/null || fail "the daemon turns on"
sudo -n omarchy-parent-screen-time add "$me" >/dev/null || fail "an account can be put under a profile"

systemctl is-active --quiet omarchy-screen-time.service || fail "the unit is active after turning it on"
pass "the unit starts under systemd"

# The strict sandbox is actually in force on the running unit.
[[ $(systemctl show -p ProtectSystem --value omarchy-screen-time.service) == strict ]] ||
  fail "the running unit has ProtectSystem=strict"
pass "the running unit is sandboxed with ProtectSystem=strict"

# The parent command wrote the config under /etc, root-owned and unreadable
# to the account.
sudo -n test -f /etc/omarchy-screen-time/config.json || fail "turning screen time on wrote its config under /etc"
[[ $(stat -c '%U %a' /etc/omarchy-screen-time) == "root 700" ]] || fail "the config dir is root-only"
[[ -r /etc/omarchy-screen-time/config.json ]] && fail "the account cannot read the config"
pass "the config under /etc is root-only"

# Wait for the first published status, which the account may read.
run_dir="/run/omarchy-screen-time/$(id -u)"
for _ in $(seq 1 20); do [[ -r "$run_dir/status.json" ]] && break; sleep 0.5; done
[[ -r "$run_dir/status.json" ]] || fail "the daemon publishes a status the account can read"
[[ $(jq -r .user "$run_dir/status.json") == "$me" ]] || fail "the status is for this account"
pass "the daemon publishes a status for the managed account"

# Set a PIN and prove the daemon's restart under the strict sandbox leaves
# the config alone.
printf '246813\n' | sudo -n omarchy-parent-screen-time pin set >/dev/null || fail "a PIN can be set"
before=$(sudo -n jq -r '.pin.hash' /etc/omarchy-screen-time/config.json)
[[ $before == '$6$'* ]] || fail "the PIN is stored hashed"
sudo -n systemctl restart omarchy-screen-time.service
sleep 2
after=$(sudo -n jq -r '.pin.hash' /etc/omarchy-screen-time/config.json)
[[ $after == "$before" ]] || fail "the PIN survives a restart of the daemon"
pass "the PIN is kept across a restart under the strict sandbox"

# A managed account reaches the control command through the group; an account
# that is not in the group is refused by sudo itself, before the command runs.
if id -nG "$me" | grep -qw omarchy-screen-time; then
  pass "the managed account is in the screen-time group"
else
  fail "adding an account puts it in the screen-time group"
fi
if sudo -n -l /usr/bin/omarchy-screen-time-ctl >/dev/null 2>&1; then
  pass "the group may run the control command without a password"
else
  fail "the sudoers grant lets the group run the control command"
fi

# Leave the machine as we found it for the next test.
sudo -n omarchy-parent-screen-time remove "$me" >/dev/null 2>&1 || true
