#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-region
copy_boundary_file bin/omarchy-region-current
copy_boundary_file bin/omarchy-apply-pacman
mkdir -p "$SUDO_TEST_ROOT/default/regions"
cp -r "$ROOT/default/regions/cn" "$SUDO_TEST_ROOT/default/regions/"

# Root's writes under /etc land in a capture tree; the marker the reader sees
# is the capture's, so the switch reads back what it wrote.
export SUDO_TEST_CAPTURE="$boundary_tmp/capture"
export OMARCHY_REGION_FILE="$SUDO_TEST_CAPTURE/etc/omarchy/region"
mkdir -p "$SUDO_TEST_CAPTURE/etc/pacman.d"
for command in cp install rm mv; do
  /usr/bin/rm -f "$SUDO_TEST_ROOT/bin/$command"
  cat >"$SUDO_TEST_ROOT/bin/$command" <<STUB
#!/bin/bash
set -euo pipefail
printf 'step:$command %s\n' "\$*" >>"\$SUDO_TEST_LOG"
if [[ \${REGION_TEST_FAIL:-} == "$command \${!#}" && ! -e \$SUDO_TEST_CAPTURE/failed ]]; then : >"\$SUDO_TEST_CAPTURE/failed"; exit 1; fi
args=()
for arg in "\$@"; do
  [[ \$arg == /etc/* ]] && arg=\$SUDO_TEST_CAPTURE\$arg
  args+=("\$arg")
done
status=0
/usr/bin/$command "\${args[@]}" || status=\$?
# Model a closed terminal right after this step: the switch gets a hangup, and
# with REGION_TEST_DEAD_SUDO root can no longer authenticate for the rollback.
if [[ \${REGION_TEST_HUP_AFTER:-} == "$command \${!#}" && ! -e \$SUDO_TEST_CAPTURE/failed ]]; then
  : >"\$SUDO_TEST_CAPTURE/failed"
  [[ \${REGION_TEST_DEAD_SUDO:-0} != 1 ]] || : >"\$SUDO_TEST_CAPTURE/terminal-closed"
  pkill -HUP -f "\$SUDO_TEST_ROOT/bin/omarchy-region (world|china)"
fi
exit \$status
STUB
  chmod +x "$SUDO_TEST_ROOT/bin/$command"
done
for name in omarchy-channel-current omarchy-region-user curl; do
  cat >"$SUDO_TEST_ROOT/bin/$name" <<STUB
#!/bin/bash
printf 'step:$name %s\n' "\$*" >>"\$SUDO_TEST_LOG"
if [[ \${REGION_TEST_FAIL:-} == "$name" && ! -e \$SUDO_TEST_CAPTURE/failed ]]; then : >"\$SUDO_TEST_CAPTURE/failed"; exit 1; fi
if [[ \${REGION_TEST_SIGNAL:-} == "$name" && ! -e \$SUDO_TEST_CAPTURE/failed ]]; then : >"\$SUDO_TEST_CAPTURE/failed"; kill -TERM "\$PPID"; fi
[[ $name != omarchy-channel-current ]] || echo stable
STUB
  chmod +x "$SUDO_TEST_ROOT/bin/$name"
done

# A closed terminal leaves sudo unable to ask for a password.
/usr/bin/mv "$SUDO_TEST_ROOT/mock/sudo" "$SUDO_TEST_ROOT/mock/sudo.real"
cat >"$SUDO_TEST_ROOT/mock/sudo" <<'STUB'
#!/bin/bash
case "${1:-}" in -k|-K|-h) ;; *) [[ ! -e $SUDO_TEST_CAPTURE/terminal-closed ]] || { printf 'sudo-refused %s\n' "$*" >>"$SUDO_TEST_LOG"; exit 1; } ;; esac
exec "$SUDO_TEST_ROOT/mock/sudo.real" "$@"
STUB
chmod +x "$SUDO_TEST_ROOT/mock/sudo"

start_global() {
  reset_boundary
  unset REGION_TEST_FAIL REGION_TEST_SIGNAL REGION_TEST_HUP_AFTER REGION_TEST_DEAD_SUDO
  /usr/bin/rm -f "$SUDO_TEST_CAPTURE/etc/omarchy/region" "$SUDO_TEST_CAPTURE/failed" "$SUDO_TEST_CAPTURE/terminal-closed"
  /usr/bin/cp "$ROOT/default/pacman/pacman-stable.conf" "$SUDO_TEST_CAPTURE/etc/pacman.conf"
  /usr/bin/cp "$ROOT/default/pacman/mirrorlist-stable" "$SUDO_TEST_CAPTURE/etc/pacman.d/mirrorlist"
}
switch() { "$SUDO_TEST_ROOT/bin/omarchy-region" "$1" >"$boundary_tmp/output" 2>&1; }

start_global
switch china || fail "switching to China failed" "$(<"$boundary_tmp/output")"
[[ $(<"$SUDO_TEST_CAPTURE/etc/omarchy/region") == cn ]] || fail "China writes the marker"
grep -qxF 'Server = https://pkgs.omarchy.cn/stable/$arch' "$SUDO_TEST_CAPTURE/etc/pacman.conf" || fail "China puts pkgs.omarchy.cn in pacman.conf"
[[ $(head -1 "$SUDO_TEST_CAPTURE/etc/pacman.d/mirrorlist") == 'Server = https://stable-mirror.omarchy.cn/$repo/os/$arch' ]] || fail "China puts its Arch mirror first"
python3 - "$SUDO_TEST_LOG" <<'PY'
import sys
events = open(sys.argv[1]).read().splitlines()
index = lambda prefix: next(i for i, e in enumerate(events) if e.startswith(prefix))
checks = [i for i, e in enumerate(events) if e.startswith('step:curl ')]
assert len(checks) == 2, events
assert max(checks) < index('sudo -N cp -f /etc/pacman.conf /etc/pacman.conf.bak'), events
assert index('step:omarchy-region-user cn') < index('sudo -N install '), events
# The marker is renamed into place, and that is root's last step.
assert events[max(i for i, e in enumerate(events) if e.startswith('sudo -N '))] == 'sudo -N mv -f /etc/omarchy/region.new /etc/omarchy/region', events
assert not any(e.startswith('sudo ') and ('bash' in e or 'omarchy-' in e) for e in events), events
PY
assert_boundary_cold "switch to China"
pass "China checks its mirrors, switches pacman and tools, and records the region last, as plain root copies"

reset_boundary
switch world || fail "switching to World failed" "$(<"$boundary_tmp/output")"
[[ ! -e $SUDO_TEST_CAPTURE/etc/omarchy/region ]] || fail "World removes the marker"
cmp "$ROOT/default/pacman/pacman-stable.conf" "$SUDO_TEST_CAPTURE/etc/pacman.conf" || fail "World restores pacman.conf byte for byte"
cmp "$ROOT/default/pacman/mirrorlist-stable" "$SUDO_TEST_CAPTURE/etc/pacman.d/mirrorlist" || fail "World restores the mirrorlist byte for byte"
grep -q '^step:omarchy-region-user global' "$SUDO_TEST_LOG" || fail "World reverts the developer tools"
! grep -q '^step:curl' "$SUDO_TEST_LOG" || fail "World needs no regional server"
assert_boundary_cold "switch to World"
pass "World restores today's pacman files byte for byte and removes the marker"

for failure in curl "cp /etc/pacman.d/mirrorlist" omarchy-region-user "install /etc/omarchy/region.new" "mv /etc/omarchy/region"; do
  start_global
  export REGION_TEST_FAIL=$failure
  if switch china; then
    fail "switching succeeds although $failure failed"
  fi
  [[ ! -e $SUDO_TEST_CAPTURE/etc/omarchy/region ]] || fail "a failed $failure leaves a China marker"
  cmp "$ROOT/default/pacman/pacman-stable.conf" "$SUDO_TEST_CAPTURE/etc/pacman.conf" || fail "a failed $failure leaves pacman.conf switched"
  cmp "$ROOT/default/pacman/mirrorlist-stable" "$SUDO_TEST_CAPTURE/etc/pacman.d/mirrorlist" || fail "a failed $failure leaves the mirrorlist switched"
  assert_boundary_cold "failed $failure"
done
pass "any failure leaves the machine on its previous region"

# From China: snapshot a China machine, then fail or interrupt every way out.
start_global
switch china || fail "switching to China failed" "$(<"$boundary_tmp/output")"
/usr/bin/cp "$SUDO_TEST_CAPTURE/etc/pacman.conf" "$boundary_tmp/china.conf"
/usr/bin/cp "$SUDO_TEST_CAPTURE/etc/pacman.d/mirrorlist" "$boundary_tmp/china.mirrors"
from_china() {
  reset_boundary
  unset REGION_TEST_FAIL REGION_TEST_SIGNAL REGION_TEST_HUP_AFTER REGION_TEST_DEAD_SUDO
  /usr/bin/rm -f "$SUDO_TEST_CAPTURE/failed" "$SUDO_TEST_CAPTURE/terminal-closed"
  printf 'cn\n' >"$SUDO_TEST_CAPTURE/etc/omarchy/region"
  /usr/bin/cp "$boundary_tmp/china.conf" "$SUDO_TEST_CAPTURE/etc/pacman.conf"
  /usr/bin/cp "$boundary_tmp/china.mirrors" "$SUDO_TEST_CAPTURE/etc/pacman.d/mirrorlist"
}
still_china() {
  [[ $(<"$SUDO_TEST_CAPTURE/etc/omarchy/region") == cn ]] || fail "$1 keeps the China marker"
  [[ ! -e $SUDO_TEST_CAPTURE/etc/omarchy/region.new ]] || fail "$1 leaves no half-written marker"
  cmp "$boundary_tmp/china.conf" "$SUDO_TEST_CAPTURE/etc/pacman.conf" || fail "$1 keeps China's pacman.conf"
  cmp "$boundary_tmp/china.mirrors" "$SUDO_TEST_CAPTURE/etc/pacman.d/mirrorlist" || fail "$1 keeps China's mirrorlist"
  grep -q '^step:omarchy-region-user cn' "$SUDO_TEST_LOG" || fail "$1 puts China's developer tools back" "$(<"$SUDO_TEST_LOG")"
  assert_boundary_cold "$1"
}
for target in world china; do
  from_china
  export REGION_TEST_FAIL=omarchy-region-user
  if switch "$target"; then fail "a failed switch to $target from China succeeds"; fi
  still_china "a failed switch to $target"
done
from_china
export REGION_TEST_FAIL="mv /etc/omarchy/region"
if switch china; then fail "reapplying China succeeds although the marker could not be replaced"; fi
still_china "a failed marker replacement"
from_china
export REGION_TEST_SIGNAL=omarchy-region-user
if switch world; then fail "an interrupted switch reports success"; fi
still_china "an interrupted switch"
pass "a failed, interrupted or half-written switch from China leaves China whole"

start_global
if switch moon; then fail "an unknown region is accepted"; fi
! grep -q '^sudo -N' "$SUDO_TEST_LOG" || fail "an unknown region reached privileged work"
pass "an unknown region is refused before any privileged work"

# A hangup after the marker moved means the switch happened: it is finished,
# not half undone.
start_global
export REGION_TEST_HUP_AFTER="mv /etc/omarchy/region"
switch china || true
[[ $(<"$SUDO_TEST_CAPTURE/etc/omarchy/region") == cn ]] || fail "a hangup after the marker keeps China"
cmp "$boundary_tmp/china.conf" "$SUDO_TEST_CAPTURE/etc/pacman.conf" || fail "a hangup after the marker keeps China's pacman.conf"
! grep -q '^step:omarchy-region-user global' "$SUDO_TEST_LOG" || fail "a hangup after the marker undoes the developer tools"
pass "a hangup after the marker moved leaves the new region complete"

# A closed terminal before the marker, with no way to authenticate the
# rollback, says so instead of claiming nothing changed.
from_china
export REGION_TEST_HUP_AFTER="cp /etc/pacman.conf" REGION_TEST_DEAD_SUDO=1
if switch world; then fail "a switch cut off by a closed terminal reports success"; fi
[[ $(<"$SUDO_TEST_CAPTURE/etc/omarchy/region") == cn ]] || fail "a closed terminal keeps the China marker"
grep -q "Run 'omarchy-region china' to finish" "$boundary_tmp/output" || fail "a rollback that cannot authenticate says how to finish" "$(<"$boundary_tmp/output")"
! grep -q 'Nothing changed' "$boundary_tmp/output" || fail "a rollback that cannot authenticate does not claim nothing changed"
grep -q '^step:omarchy-region-user cn' "$SUDO_TEST_LOG" || fail "a closed terminal still puts China's developer tools back"
pass "a closed terminal that blocks the rollback says how to finish"
