#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-refresh-pacman
copy_boundary_file bin/omarchy-apply-pacman
for file in default/pacman/pacman-rc.conf default/pacman/mirrorlist-rc \
  default/regions/cn/pacman/pacman.conf.append default/regions/cn/pacman/mirrorlist-rc.prepend; do
  copy_boundary_file "$file"
done

# A sandboxed China machine: the render reads this region marker, never the
# host's /etc/omarchy/region.
mkdir -p "$SUDO_TEST_TARGET/etc/omarchy"
printf 'cn\n' >"$SUDO_TEST_TARGET/etc/omarchy/region"

# cp still logs its step, but now really copies, so the rendered files exist.
# Root's copies into /etc land in a capture directory instead of the host.
export SUDO_TEST_CAPTURE="$boundary_tmp/capture"
rm "$SUDO_TEST_ROOT/bin/cp"
cat >"$SUDO_TEST_ROOT/bin/cp" <<'STUB'
#!/bin/bash
set -euo pipefail
printf 'step:cp %s\n' "$*" >>"$SUDO_TEST_LOG"
destination=${!#}
if [[ $destination == /etc/* ]]; then
  source=${*: -2:1}
  [[ $source == /etc/* ]] && exit 0
  /usr/bin/mkdir -p "$SUDO_TEST_CAPTURE${destination%/*}"
  exec /usr/bin/cp "$source" "$SUDO_TEST_CAPTURE$destination"
fi
exec /usr/bin/cp "$@"
STUB
chmod +x "$SUDO_TEST_ROOT/bin/cp"

# Regional rendering must stay unprivileged: root only copies finished files,
# exactly as the channel refresh did before regions existed.
reset_boundary
"$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" rc >"$boundary_tmp/output" 2>&1 || fail "refresh failed" "$(<"$boundary_tmp/output")"
assert_boundary_cold "regional refresh"
python3 - "$SUDO_TEST_LOG" "$SUDO_TEST_ROOT" <<'PY'
import re
import sys
events = open(sys.argv[1]).read().splitlines()
root = sys.argv[2]
render = [i for i, e in enumerate(events) if e.startswith('step:cp ' + root + '/default/pacman/pacman-rc.conf ')]
assert len(render) == 1, events
rendered = events[render[0]].split()[-1].rsplit('/', 1)[0]
copies = [i for i, e in enumerate(events) if e.startswith('sudo -N cp ')]
assert [events[i] for i in copies[2:]] == [
    f'sudo -N cp -f {rendered}/pacman.conf /etc/pacman.conf',
    f'sudo -N cp -f {rendered}/mirrorlist /etc/pacman.d/mirrorlist',
], events
assert not any(e.startswith('sudo ') and 'omarchy-apply-pacman' in e for e in events), events
assert render[0] < copies[0], events
transaction = next(i for i, e in enumerate(events) if e.startswith('step:pacman '))
assert max(copies) < transaction, events
PY
{
  cat "$ROOT/default/pacman/pacman-rc.conf"
  printf '\n'
  cat "$ROOT/default/regions/cn/pacman/pacman.conf.append"
} >"$boundary_tmp/expected-pacman.conf"
cat "$ROOT/default/regions/cn/pacman/mirrorlist-rc.prepend" "$ROOT/default/pacman/mirrorlist-rc" >"$boundary_tmp/expected-mirrorlist"
cmp -s "$boundary_tmp/expected-pacman.conf" "$SUDO_TEST_CAPTURE/etc/pacman.conf" ||
  fail "root installs the rendered China pacman.conf" "$(diff "$boundary_tmp/expected-pacman.conf" "$SUDO_TEST_CAPTURE/etc/pacman.conf" 2>&1)"
cmp -s "$boundary_tmp/expected-mirrorlist" "$SUDO_TEST_CAPTURE/etc/pacman.d/mirrorlist" ||
  fail "root installs the rendered China mirrorlist" "$(diff "$boundary_tmp/expected-mirrorlist" "$SUDO_TEST_CAPTURE/etc/pacman.d/mirrorlist" 2>&1)"
pass "refresh renders regional config unprivileged and gives root only plain copies"

reset_boundary
if "$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" dev >"$boundary_tmp/output" 2>&1; then
  fail "refresh accepts an invalid channel"
fi
if grep -Eq '^(sudo -N cp |step:pacman )' "$SUDO_TEST_LOG"; then
  fail "invalid channel reached privileged work" "$(<"$SUDO_TEST_LOG")"
fi
pass "failed refresh does not proceed to privileged copies or a package update"

# A failed render still removes its scratch directory and exits cold.
reset_boundary
mv "$SUDO_TEST_ROOT/bin/omarchy-apply-pacman" "$boundary_tmp/omarchy-apply-pacman"
cat >"$SUDO_TEST_ROOT/bin/omarchy-apply-pacman" <<'STUB'
#!/bin/bash
: >"$3/pacman.conf"
exit 1
STUB
chmod +x "$SUDO_TEST_ROOT/bin/omarchy-apply-pacman"
mkdir -p "$boundary_tmp/scratch"
if TMPDIR="$boundary_tmp/scratch" "$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" rc >"$boundary_tmp/output" 2>&1; then
  fail "refresh succeeds after a failed render"
fi
mv "$boundary_tmp/omarchy-apply-pacman" "$SUDO_TEST_ROOT/bin/omarchy-apply-pacman"
[[ -z $(ls -A "$boundary_tmp/scratch") ]] || fail "failed render leaves its scratch directory" "$(ls -AR "$boundary_tmp/scratch")"
if grep -Eq '^(sudo -N cp |step:pacman )' "$SUDO_TEST_LOG"; then
  fail "failed render reached privileged work" "$(<"$SUDO_TEST_LOG")"
fi
assert_boundary_cold "failed render"
pass "failed render removes its scratch directory and exits cold"
