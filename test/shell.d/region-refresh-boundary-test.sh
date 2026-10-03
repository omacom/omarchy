#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-refresh-pacman
copy_boundary_file bin/omarchy-apply-pacman

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
pass "refresh renders regional config unprivileged and gives root only plain copies"

reset_boundary
if "$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" dev >"$boundary_tmp/output" 2>&1; then
  fail "refresh accepts an invalid channel"
fi
if grep -Eq '^(sudo -N cp |step:pacman )' "$SUDO_TEST_LOG"; then
  fail "invalid channel reached privileged work" "$(<"$SUDO_TEST_LOG")"
fi
pass "failed refresh does not proceed to privileged copies or a package update"
