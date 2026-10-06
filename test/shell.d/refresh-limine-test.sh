#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"

copy_boundary_file bin/omarchy-refresh-limine

# Keep every bootloader operation inside the fixture. The sudo stand-in logs
# each request and runs only commands against these temporary paths.
boot_dir="$boundary_tmp/boot"
mkdir -p "$boot_dir" "$SUDO_TEST_ROOT/default/limine"
printf 'fixture-machine\n' >"$boundary_tmp/machine-id"
printf 'new limine config\n' >"$SUDO_TEST_ROOT/default/limine/limine.conf"
python3 - "$SUDO_TEST_ROOT/bin/omarchy-refresh-limine" "$boot_dir" "$boundary_tmp/machine-id" <<'PY'
import sys
from pathlib import Path

script, boot_dir, machine_id = map(Path, sys.argv[1:])
text = script.read_text().replace('/boot', str(boot_dir)).replace('/etc/machine-id', str(machine_id))
script.write_text(text)
PY
ln -s test-step "$SUDO_TEST_ROOT/bin/limine-update"
ln -s test-step "$SUDO_TEST_ROOT/bin/limine-snapper-sync"
# The shared fixture stubs cp for update tests; this test needs the real copy
# to verify the staged config reaches its temporary boot directory.
rm "$SUDO_TEST_ROOT/bin/cp"

for initial_config in present missing; do
  reset_boundary
  rm -f "$boot_dir/limine.conf" "$boot_dir/limine.conf.bak"
  if [[ $initial_config == "present" ]]; then
    printf 'old limine config\n' >"$boot_dir/limine.conf"
  fi

  PATH="$SUDO_TEST_ROOT/bin:$PATH" "$SUDO_TEST_ROOT/bin/omarchy-refresh-limine" >"$boundary_tmp/output" 2>&1 ||
    fail "refresh failed with $initial_config boot config" "$(<"$boundary_tmp/output")"

  [[ $(<"$boot_dir/limine.conf") == "new limine config" ]] || fail "refresh did not copy the default config"
  if [[ $initial_config == "present" ]]; then
    [[ $(<"$boot_dir/limine.conf.bak") == "old limine config" ]] || fail "refresh did not back up the existing config"
  else
    [[ ! -e $boot_dir/limine.conf.bak ]] || fail "refresh made a backup without an existing config"
  fi

  python3 - "$SUDO_TEST_LOG" "$initial_config" "$boot_dir" "$SUDO_TEST_ROOT" <<'PY'
import sys
from pathlib import Path

log, initial_config, boot_dir, root = sys.argv[1:]
events = Path(log).read_text().splitlines()
expected = [
    'sudo -k',
    'sudo /usr/bin/true',
    'sudo -h',
    f'sudo -N test -f {boot_dir}/EFI/Linux/omarchy_linux.efi',
    f'sudo -N test -f {boot_dir}/limine.conf',
]
if initial_config == 'present':
    expected.append(f'sudo -N mv {boot_dir}/limine.conf {boot_dir}/limine.conf.bak')
expected += [
    f'sudo -N cp {root}/default/limine/limine.conf {boot_dir}/limine.conf',
    'sudo -N limine-update',
    'step:limine-update ',
    'sudo -N limine-snapper-sync',
    'step:limine-snapper-sync ',
    'sudo -k',
]
assert events == expected, (events, expected)
PY
  assert_boundary_cold "refresh with $initial_config boot config"
  pass "refresh with $initial_config boot config copies and rebuilds, then revokes sudo"
done
