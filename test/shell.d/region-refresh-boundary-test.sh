#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-refresh-pacman
copy_boundary_file bin/omarchy-apply-pacman
for file in default/pacman/pacman-rc.conf default/pacman/mirrorlist-rc \
  default/regions/cn/pacman/omarchy-rc.prepend default/regions/cn/pacman/mirrorlist-rc.prepend; do
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

# Regional rendering runs in a root-owned staging directory: root creates the
# directory, renders into it, and copies only files the desktop user cannot
# swap between those steps.
reset_boundary
"$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" rc >"$boundary_tmp/output" 2>&1 || fail "refresh failed" "$(<"$boundary_tmp/output")"
python3 - "$SUDO_TEST_LOG" "$SUDO_TEST_ROOT" <<'PY'
import re
import sys
events = open(sys.argv[1]).read().splitlines()
root = sys.argv[2]
copies = [i for i, e in enumerate(events) if e.startswith('sudo cp ')]
# The China render writes pacman.conf itself, so the rendered directory is the
# one root copies from, and it is a scratch directory, never the templates.
rendered = events[copies[2]].split()[-2].rsplit('/', 1)[0]
# The fixture maps the production /run/omarchy-render.XXXXXX into its own run
# directory; the point is that root created it, not that it is outside root.
assert rendered.startswith(f'{root}/run/omarchy-render.'), events
assert [events[i] for i in copies[2:]] == [
    f'sudo cp -f {rendered}/pacman.conf /etc/pacman.conf',
    f'sudo cp -f {rendered}/mirrorlist /etc/pacman.d/mirrorlist',
], events
stage = [i for i, e in enumerate(events) if e.startswith('sudo mktemp -d ')]
assert len(stage) == 1, events
stage_template = events[stage[0]].split()[-1]
assert stage_template.endswith('/omarchy-render.XXXXXX'), events
assert stage_template.rsplit('/', 1)[0] == rendered.rsplit('/', 1)[0], events
apply = [i for i, e in enumerate(events) if 'omarchy-apply-pacman --render' in e]
assert len(apply) == 1, events
assert events[apply[0]].startswith('sudo env OMARCHY_PATH='), events
assert events[apply[0]].split()[-1] == rendered, events
assert stage[0] < apply[0] < min(copies), events
transaction = next(i for i, e in enumerate(events) if e.startswith('step:pacman '))
assert max(copies) < transaction, events
PY
sed "/^\[omarchy\]\$/r $ROOT/default/regions/cn/pacman/omarchy-rc.prepend" \
  "$ROOT/default/pacman/pacman-rc.conf" >"$boundary_tmp/expected-pacman.conf"
cat "$ROOT/default/regions/cn/pacman/mirrorlist-rc.prepend" "$ROOT/default/pacman/mirrorlist-rc" >"$boundary_tmp/expected-mirrorlist"
cmp -s "$boundary_tmp/expected-pacman.conf" "$SUDO_TEST_CAPTURE/etc/pacman.conf" ||
  fail "root installs the rendered China pacman.conf" "$(diff "$boundary_tmp/expected-pacman.conf" "$SUDO_TEST_CAPTURE/etc/pacman.conf" 2>&1)"
cmp -s "$boundary_tmp/expected-mirrorlist" "$SUDO_TEST_CAPTURE/etc/pacman.d/mirrorlist" ||
  fail "root installs the rendered China mirrorlist" "$(diff "$boundary_tmp/expected-mirrorlist" "$SUDO_TEST_CAPTURE/etc/pacman.d/mirrorlist" 2>&1)"
pass "refresh renders regional config in a root-owned staging directory"

reset_boundary
if "$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" dev >"$boundary_tmp/output" 2>&1; then
  fail "refresh accepts an invalid channel"
fi
if grep -Eq '^(sudo cp |step:pacman )' "$SUDO_TEST_LOG"; then
  fail "invalid channel reached privileged work" "$(<"$SUDO_TEST_LOG")"
fi
pass "failed refresh does not proceed to privileged copies or a package update"

# A failed render still removes its root-owned staging directory.
reset_boundary
mv "$SUDO_TEST_ROOT/bin/omarchy-apply-pacman" "$boundary_tmp/omarchy-apply-pacman"
cat >"$SUDO_TEST_ROOT/bin/omarchy-apply-pacman" <<'STUB'
#!/bin/bash
: >"$3/pacman.conf"
exit 1
STUB
chmod +x "$SUDO_TEST_ROOT/bin/omarchy-apply-pacman"
if "$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" rc >"$boundary_tmp/output" 2>&1; then
  fail "refresh succeeds after a failed render"
fi
mv "$boundary_tmp/omarchy-apply-pacman" "$SUDO_TEST_ROOT/bin/omarchy-apply-pacman"
[[ -z $(ls -A "$SUDO_TEST_ROOT/run") ]] || fail "failed render leaves its staging directory" "$(ls -AR "$SUDO_TEST_ROOT/run")"
if grep -Eq '^(sudo cp |step:pacman )' "$SUDO_TEST_LOG"; then
  fail "failed render reached privileged work" "$(<"$SUDO_TEST_LOG")"
fi
pass "failed render removes its staging directory"
