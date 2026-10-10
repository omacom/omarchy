#!/bin/bash
#
# The migration that rebuilds the boot image once omarchy_vconsole.conf refuses
# vconsole.conf for a non-Latin layout: since 26.134.222-3, Arch's plymouth
# hook has copied the file into every image it built (#14246). It rebuilds once
# per machine, and only where the installed drop-ins now leave the file out and
# the plymouth hook can have put it there.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791621765.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

# sudo just drops the prefix; limine-mkinitcpio records that it ran, and fails,
# or skips a kernel and still exits 0, when told to.
printf '#!/bin/bash\nexec "$@"\n' >"$stub_bin/sudo"
cat >"$stub_bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash
echo rebuilt >>"${REBUILDS:?}"
[[ -z ${REBUILD_FAILS:-} ]] || exit 1
[[ -z ${REBUILD_SKIPS:-} ]] || echo "==> ERROR: mkinitcpio failed for kernel 7.2.5-3-omarchy, skipping."
STUB
chmod +x "$stub_bin"/*

# The drop-ins read the machine's own /etc/vconsole.conf; copies read a fixture.
vconsole="$test_dir/vconsole.conf"
new_conf_dir() {
  rm -rf "$test_dir/conf.d"
  mkdir -p "$test_dir/conf.d"
  for conf in omarchy_hooks.conf omarchy_vconsole.conf; do
    sed "s|/etc/vconsole.conf|$vconsole|g" "$ROOT/etc/mkinitcpio.conf.d/$conf" >"$test_dir/conf.d/$conf"
  done
}

# The plymouth hook as 26.134.222-3 ships it, as -2 did, and with the copy
# moved into its map list.
printf 'build() {\n  if [[ -s /etc/vconsole.conf ]]; then\n    add_file /etc/vconsole.conf\n  fi\n}\n' >"$test_dir/plymouth-new"
printf 'build() {\n  add_file /etc/plymouth/plymouthd.conf\n}\n' >"$test_dir/plymouth-old"
printf "build() {\n  map add_file \\\\\n    '/etc/plymouth/plymouthd.conf' \\\\\n    '/etc/vconsole.conf'\n}\n" >"$test_dir/plymouth-map"

run() { # vconsole.conf content, plymouth hook
  : >"$test_dir/rebuilds"
  if [[ -n $1 ]]; then
    printf '%s\n' "$1" >"$vconsole"
  else
    rm -f "$vconsole"
  fi
  PATH="$stub_bin:$ROOT/bin:$PATH" REBUILDS="$test_dir/rebuilds" \
    OMARCHY_MKINITCPIO_CONF_DIR="$test_dir/conf.d" OMARCHY_VCONSOLE_CONF="$vconsole" \
    OMARCHY_PLYMOUTH_INSTALL_HOOK="$2" OMARCHY_VCONSOLE_REBUILD_MARKER="$test_dir/marker" \
    bash -euo pipefail "$migration" >/dev/null 2>&1
}
rebuilds() { wc -l <"$test_dir/rebuilds"; }

russian=$'KEYMAP=ru\nXKBLAYOUT=ru,us'
new_conf_dir

# omarchy-migrate runs a migration with bash -euo pipefail, and so does run:
# that is what stops a failed rebuild before the marker is written.
if REBUILD_FAILS=1 run "$russian" "$test_dir/plymouth-new"; then
  fail "a rebuild that failed was reported as a success"
fi
(( $(rebuilds) == 1 )) && [[ ! -e $test_dir/marker ]] || fail "a failed rebuild was marked as done"
pass "a rebuild that fails stops the migration and leaves no marker"

# limine-mkinitcpio exits 0 past a kernel it could not build.
if REBUILD_SKIPS=1 run "$russian" "$test_dir/plymouth-new"; then
  fail "a rebuild that skipped a kernel was reported as a success"
fi
[[ ! -e $test_dir/marker ]] || fail "a rebuild that skipped a kernel was marked as done"
pass "a rebuild that skips a kernel and exits 0 leaves the migration pending"

run "$russian" "$test_dir/plymouth-new"
(( $(rebuilds) == 1 )) && [[ -e $test_dir/marker ]] ||
  fail "a Cyrillic layout under the new plymouth hook did not get its boot image rebuilt"
pass "a Cyrillic layout under the new plymouth hook gets its boot image rebuilt, and marked"

run "$russian" "$test_dir/plymouth-new"
(( $(rebuilds) == 0 )) || fail "the rebuild ran a second time on the same machine"
pass "the rebuild runs once per machine, not once per user"

rm -f "$test_dir/marker"
run $'KEYMAP=de\nXKBLAYOUT=de' "$test_dir/plymouth-new"
(( $(rebuilds) == 0 )) && [[ ! -e $test_dir/marker ]] || fail "a Latin layout was rebuilt"
pass "a Latin layout, which the image should hold, is left alone"

run "$russian" "$test_dir/plymouth-old"
(( $(rebuilds) == 0 )) || fail "an image the older plymouth hook built was rebuilt"
pass "an image built by a plymouth hook that does not copy the file is left alone"

run "$russian" "$test_dir/plymouth-map"
(( $(rebuilds) == 1 )) || fail "a plymouth hook that copies the file from its map list was missed"
pass "a plymouth hook that copies the file from its map list is recognised"

# An omarchy_hooks.conf from before the package, which pacman keeps over the
# packaged one, never mentions vconsole.conf: the guard drop-in still covers it.
rm -f "$test_dir/marker"
printf 'HOOKS=(base udev plymouth keyboard autodetect modconf kms keymap block encrypt filesystems fsck)\n' >"$test_dir/conf.d/omarchy_hooks.conf"
run "$russian" "$test_dir/plymouth-new"
(( $(rebuilds) == 1 )) && [[ -e $test_dir/marker ]] ||
  fail "a machine with an omarchy_hooks.conf from before the package was not rebuilt"
pass "a machine with an omarchy_hooks.conf from before the package is rebuilt too"

# A drop-in edited to bundle the file on purpose keeps it, so nothing changes.
rm -f "$test_dir/marker"
printf 'FILES+=(%s)\n' "$vconsole" >"$test_dir/conf.d/omarchy_hooks.conf"
run "$russian" "$test_dir/plymouth-new"
(( $(rebuilds) == 0 )) || fail "a drop-in that bundles the file on purpose was rebuilt"
pass "a drop-in that bundles the file on purpose is left alone"
new_conf_dir

run "" "$test_dir/plymouth-new"
(( $(rebuilds) == 0 )) || fail "a machine without vconsole.conf was rebuilt"
pass "a machine without vconsole.conf is left alone"

XKBLAYOUT=ru run "KEYMAP=us" "$test_dir/plymouth-new"
(( $(rebuilds) == 0 )) || fail "an exported XKBLAYOUT answered for a vconsole.conf that sets none"
pass "only vconsole.conf's own XKBLAYOUT counts"

# No Limine: the stand-in goes, and the PATH holds only what the migration
# needs, so a limine-mkinitcpio installed on the machine running this test is
# not found either.
rm "$stub_bin/limine-mkinitcpio"
mkdir -p "$test_dir/tools"
for tool in bash grep install cat mktemp tee rm; do ln -s "$(command -v "$tool")" "$test_dir/tools/$tool"; done
printf '%s\n' "$russian" >"$vconsole"
: >"$test_dir/rebuilds"
PATH="$stub_bin:$ROOT/bin:$test_dir/tools" REBUILDS="$test_dir/rebuilds" \
  OMARCHY_MKINITCPIO_CONF_DIR="$test_dir/conf.d" OMARCHY_VCONSOLE_CONF="$vconsole" \
  OMARCHY_PLYMOUTH_INSTALL_HOOK="$test_dir/plymouth-new" OMARCHY_VCONSOLE_REBUILD_MARKER="$test_dir/marker" \
  "$test_dir/tools/bash" -euo pipefail "$migration" >/dev/null
(( $(rebuilds) == 0 )) && [[ ! -e $test_dir/marker ]] || fail "a machine without Limine was rebuilt"
pass "a machine without Limine is left alone"
