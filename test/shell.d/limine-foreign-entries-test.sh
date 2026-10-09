#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Owner provisioning's boot-entry refresh on an ESP fixture. A menu that holds
# this machine's entry next to another machine-id's drops the other one with
# limine-entry-tool and rebuilds nothing; a menu without this machine's entry
# (a factory reset's fresh identity) still starts over and rebuilds.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
owner=$ROOT/bin/omarchy-provision-owner
sed -n '/^esp_path() {/,/^}/p; /^limine_entries_stale() {/,/^}/p; /^reset_limine_config() {/,/^}/p
  /^drop_foreign_limine_entries() {/,/^}/p' "$owner" | sed "s|/etc/|$tmp/etc/|g" >"$tmp/functions.sh"
grep -q '^drop_foreign_limine_entries() {' "$tmp/functions.sh" || fail "omarchy-provision-owner defines drop_foreign_limine_entries"
# The refresh as run_provisioning runs it.
{
  echo 'refresh() {'
  sed -n '/^  if limine_entries_stale; then$/,/^  fi$/p' "$owner"
  echo '}'
} >>"$tmp/functions.sh"
grep -q 'drop_foreign_limine_entries' "$tmp/functions.sh" || fail "run_provisioning's refresh tries the entry tool first"
source "$tmp/functions.sh"

esp=$tmp/esp
own=0123456789abcdef0123456789abcdef
foreign=fedcba9876543210fedcba9876543210
STATE_FILE=$tmp/state
OMARCHY_PATH=$tmp/omarchy
log_step() { printf '%s\n' "$*" >>"$tmp/log"; }
limine-update() { echo update >>"$tmp/ran"; }
# Removes the top-level OS entry whose comment names the machine-id, as the
# entry tool's --remove-entry <machine-ID> does.
limine-entry-tool() {
  echo "entry-tool $*" >>"$tmp/ran"
  [[ ! -e $tmp/tool-fail ]] || return 1
  [[ $1 == --remove-entry ]] || return 1
  awk -v id="$2" '
    /^\// { if (block != "" && !drop) printf "%s", block; block = ""; drop = 0 }
    { block = block $0 "\n" }
    $0 ~ "machine-id=" id { drop = 1 }
    END { if (!drop) printf "%s", block }' "$esp/limine.conf" >"$esp/limine.conf.new"
  mv "$esp/limine.conf.new" "$esp/limine.conf"
}

entry() {
  printf '/+Omarchy\ncomment: machine-id=%s order-priority=50\n  //linux\n  protocol: efi\n  path: boot():/EFI/Linux/omarchy_linux.efi#%s\n' "$1" "$2"
}

fixture() {
  rm -rf "${tmp:?}/etc" "$esp" "$OMARCHY_PATH" "$tmp/ran" "$tmp/log" "$tmp/tool-fail"
  mkdir -p "$tmp/etc/default" "$esp/$own" "$esp/$foreign" "$OMARCHY_PATH/default/limine"
  printf 'ESP_PATH="%s"\n' "$esp" >"$tmp/etc/default/limine"
  echo "$own" >"$tmp/etc/machine-id"
  printf 'timeout: 3\n' >"$OMARCHY_PATH/default/limine/limine.conf"
  : >"$tmp/ran"
}

# This machine's entry, just written by the re-key's UKI build, and one left
# from another machine-id.
fixture
{ printf 'timeout: 3\n'; entry "$own" aaaa; entry "$foreign" bbbb; } >"$esp/limine.conf"
own_entry=$(entry "$own" aaaa)
refresh || fail "the refresh succeeds" "$(cat "$tmp/log")"
[[ $(cat "$tmp/ran") == "entry-tool --remove-entry $foreign --quiet" ]] ||
  fail "only the entry tool runs: no menu reset, no UKI rebuild" "$(cat "$tmp/ran")"
! grep -q "machine-id=$foreign" "$esp/limine.conf" || fail "the other machine-id's entry is gone" "$(cat "$esp/limine.conf")"
[[ $(cat "$esp/limine.conf") == $'timeout: 3\n'"$own_entry" ]] || fail "this machine's entry is kept as written" "$(cat "$esp/limine.conf")"
[[ ! -e $esp/$foreign && -d $esp/$own ]] || fail "only the other machine-id's ESP directory is removed"
! limine_entries_stale || fail "nothing is stale afterwards"
pass "a menu holding this machine's entry drops another machine-id's without a rebuild"

# A factory reset's fresh identity: no entry for this machine yet.
fixture
{ printf 'timeout: 3\n'; entry "$foreign" bbbb; } >"$esp/limine.conf"
refresh || fail "the refresh succeeds" "$(cat "$tmp/log")"
[[ $(cat "$tmp/ran") == update ]] || fail "the menu starts over and limine-update rebuilds" "$(cat "$tmp/ran")"
[[ $(cat "$esp/limine.conf") == "timeout: 3" && ! -e $esp/$foreign ]] || fail "the template replaces the menu"
pass "a menu without this machine's entry starts over and rebuilds"

# The entry tool fails: start over as before.
fixture
{ printf 'timeout: 3\n'; entry "$own" aaaa; entry "$foreign" bbbb; } >"$esp/limine.conf"
touch "$tmp/tool-fail"
refresh || fail "the refresh succeeds" "$(cat "$tmp/log")"
[[ $(tail -n 1 "$tmp/ran") == update ]] || fail "a failed entry tool falls back to the rebuild" "$(cat "$tmp/ran")"
pass "a failed entry tool falls back to starting the menu over"

# The ESP refuses to delete the other machine-id's directory: the entry tool does not run, so the entry stays in the
# menu and the fallback still names that id (a menu that already looked clean would hide the leftover directory).
fixture
{ printf 'timeout: 3\n'; entry "$own" aaaa; entry "$foreign" bbbb; } >"$esp/limine.conf"
rm() { [[ ${*: -1} == "$esp/$foreign" ]] && return 1; command rm "$@"; }
refresh || fail "the refresh finishes through the fallback" "$(cat "$tmp/log")"
unset -f rm
! grep -q '^entry-tool' "$tmp/ran" || fail "the entry tool does not run after a refused delete" "$(cat "$tmp/ran")"
grep -q "could not delete $esp/$foreign" "$tmp/log" || fail "the refused delete is logged" "$(cat "$tmp/log")"
[[ $(tail -n 1 "$tmp/ran") == update ]] || fail "a refused delete falls back to the rebuild" "$(cat "$tmp/ran")"
pass "a refused ESP delete is not reported as a clean refresh"

# Nothing stale: nothing runs.
fixture
{ printf 'timeout: 3\n'; entry "$own" aaaa; } >"$esp/limine.conf"
refresh || fail "the refresh succeeds"
[[ ! -s $tmp/ran ]] || fail "a current menu is left alone" "$(cat "$tmp/ran")"
pass "a current menu is left alone"
