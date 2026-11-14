#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

hook="$ROOT/default/systemd/system-sleep/apple-thunderbolt-detach"
setup="$ROOT/install/hardware/apple/fix-suspend-thunderbolt.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -rl 'Detach the Thunderbolt controller around sleep on the MacBookPro14,1' "$ROOT/migrations" | head -n 1 || true)

bash -n "$hook" || fail "Thunderbolt sleep hook has valid syntax"
bash -n "$setup" || fail "Thunderbolt sleep setup has valid syntax"
[[ -x $hook ]] || fail "Thunderbolt sleep hook is executable"
grep -q 'run_logged .*hardware/apple/fix-suspend-thunderbolt.sh' "$all" ||
  fail "the Thunderbolt sleep hook is installed during hardware setup"
[[ -n $migration ]] || fail "a migration installs the Thunderbolt sleep hook on existing installs"
[[ $(stat -c '%a' "$migration") == "644" ]] || fail "the migration is not executable"
pass "the Thunderbolt sleep hook ships with a setup leaf and a migration"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# A fake PCI tree: the 8086:1578 bridge, a child Thunderbolt bridge and an
# unrelated device. Each "remove" file records whether the hook wrote to it.
pci_tree() {
  local devices="$TMPDIR/pci/devices"
  rm -rf "$TMPDIR/pci"
  mkdir -p "$devices"
  device() {
    mkdir -p "$devices/$1"
    printf '%s\n' "$2" >"$devices/$1/vendor"
    printf '%s\n' "$3" >"$devices/$1/device"
    : >"$devices/$1/remove"
  }
  device 0000:01:00.0 0x106b 0x2003
  device 0000:04:00.0 0x8086 0x1578
  device 0000:05:00.0 0x8086 0x15d3
  : >"$TMPDIR/pci/rescan"
}

run_hook() {
  OMARCHY_PCI_DEVICES="$TMPDIR/pci/devices" OMARCHY_PCI_RESCAN="$TMPDIR/pci/rescan" \
    bash "$hook" "$@"
}

pci_tree
run_hook pre suspend || fail "hook pre exits clean"
[[ $(<"$TMPDIR/pci/devices/0000:04:00.0/remove") == 1 ]] || fail "hook removes the Alpine Ridge bridge before sleep"
[[ ! -s $TMPDIR/pci/devices/0000:05:00.0/remove ]] || fail "hook leaves other Thunderbolt devices to the bridge removal"
[[ ! -s $TMPDIR/pci/devices/0000:01:00.0/remove ]] || fail "hook leaves unrelated devices alone"
[[ ! -s $TMPDIR/pci/rescan ]] || fail "hook does not rescan before sleep"
pass "hook removes only the Alpine Ridge bridge before sleep"

run_hook post suspend || fail "hook post exits clean"
[[ $(<"$TMPDIR/pci/rescan") == 1 ]] || fail "hook rescans the PCI bus after sleep"
pass "hook rescans the PCI bus after sleep"

# Children vanish when their bridge is removed; the hook must not trip over them.
pci_tree
rm -rf "$TMPDIR/pci/devices/0000:05:00.0"/*
run_hook pre suspend 2>"$TMPDIR/stderr" || fail "hook pre exits clean when a device disappears"
[[ ! -s $TMPDIR/stderr ]] || fail "hook is quiet about devices that are already gone" "stderr: $(<"$TMPDIR/stderr")"
pass "hook skips devices that are already gone"

stub_bin="$TMPDIR/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
[[ ${REFUSE_SUDO:-0} != 1 ]] || exit 1
exec "$@"
STUB
cat >"$stub_bin/omarchy-hw-match" <<'STUB'
#!/bin/bash
[[ ${TEST_MODEL:-} == "$1" ]]
STUB
chmod +x "$stub_bin"/*

dst="$TMPDIR/system-sleep/apple-thunderbolt-detach"

run_setup() {
  PATH="$stub_bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_APPLE_TB_HOOK_DST="$dst" \
    bash -euo pipefail -c 'source "$1"' _ "$setup"
}

run_migration() {
  PATH="$stub_bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_APPLE_TB_HOOK_DST="$dst" \
    bash -euo pipefail "$migration" >/dev/null
}

rm -rf "$TMPDIR/system-sleep"
TEST_MODEL="MacBookPro14,1" run_setup || fail "setup exits clean on the MacBookPro14,1"
cmp -s "$dst" "$hook" || fail "setup installs the shipped hook on the MacBookPro14,1"
[[ -x $dst ]] || fail "setup installs the hook executable"
pass "setup installs the hook on the MacBookPro14,1"

rm -rf "$TMPDIR/system-sleep"
TEST_MODEL="MacBookPro14,3" run_setup || fail "setup exits clean on other models"
[[ ! -e $dst ]] || fail "setup leaves other models alone"
pass "setup leaves other models alone"

rm -rf "$TMPDIR/system-sleep"
TEST_MODEL="MacBookPro14,1" run_migration || fail "migration exits clean on the MacBookPro14,1"
cmp -s "$dst" "$hook" || fail "migration installs the shipped hook from its default source"
[[ -x $dst ]] || fail "migration installs the hook executable"
pass "migration installs the hook on the MacBookPro14,1"

printf '# sentinel\n' >>"$dst"
TEST_MODEL="MacBookPro14,1" REFUSE_SUDO=1 run_migration || fail "migration finishes without sudo once the hook exists"
grep -q sentinel "$dst" || fail "migration leaves an existing hook alone"
pass "migration leaves an existing hook alone and needs no sudo"

rm -rf "$TMPDIR/system-sleep"
TEST_MODEL="MacBookPro14,3" REFUSE_SUDO=1 run_migration || fail "migration exits clean on other models"
[[ ! -e $dst ]] || fail "migration leaves other models alone"
pass "migration leaves other models alone"
