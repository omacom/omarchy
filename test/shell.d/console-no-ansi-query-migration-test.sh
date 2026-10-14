#!/bin/bash
#
# The migration that puts systemd.tty.term.console=dumb into effect on an
# existing install: the package has already written the parameter into
# omarchy-defaults.conf, so what is left is rebuilding the boot image, once per
# machine, and only where it is needed.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1791581004.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

# sudo just drops the prefix; limine-mkinitcpio records that it ran, and fails
# when told to.
printf '#!/bin/bash\nexec "$@"\n' >"$stub_bin/sudo"
# A rebuild writes the new command line into the boot menu, unless it is the
# kind that builds nothing and still exits 0.
cat >"$stub_bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash
echo rebuilt >>"${REBUILDS:?}"
[[ -z ${REBUILD_FAILS:-} ]] || exit 1
[[ -n ${REBUILD_BUILDS_NOTHING:-} ]] || printf '  cmdline: %s\n' "${NEW_CMDLINE:?}" >"${LIMINE_CONF:?}"
STUB
chmod +x "$stub_bin"/*

old_cmdline="root=PARTUUID=1 rw quiet splash initramfs_async=0"
new_cmdline="$old_cmdline systemd.tty.term.console=dumb"

run() { # booted cmdline, defaults conf
  : >"$test_dir/rebuilds"
  printf '%s\n' "$1" >"$test_dir/cmdline"
  printf '  cmdline: %s\n' "$1" >"$test_dir/limine.conf"
  PATH="$stub_bin:$ROOT/bin:$PATH" REBUILDS="$test_dir/rebuilds" \
    LIMINE_CONF="$test_dir/limine.conf" NEW_CMDLINE="$new_cmdline" OMARCHY_LIMINE_CONF="$test_dir/limine.conf" \
    OMARCHY_RUNNING_CMDLINE="$test_dir/cmdline" OMARCHY_LIMINE_DEFAULTS_CONF="$2" \
    OMARCHY_LIMINE_REBUILD_MARKER="$test_dir/marker" bash -euo pipefail "$migration" >/dev/null
}
rebuilds() { wc -l <"$test_dir/rebuilds"; }

# omarchy-migrate runs a migration with bash -euo pipefail, and so does run:
# that is what stops a failed rebuild before the marker is written.
if REBUILD_FAILS=1 run "$old_cmdline" "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf"; then
  fail "a rebuild that failed was reported as a success"
fi
[[ $(rebuilds) == 1 && ! -e $test_dir/marker ]] || fail "a failed rebuild was marked as done"
pass "a rebuild that fails stops the migration and leaves no marker"

# limine-mkinitcpio exits 0 past a kernel it could not build.
if REBUILD_BUILDS_NOTHING=1 run "$old_cmdline" "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf"; then
  fail "a rebuild that changed nothing was reported as a success"
fi
[[ ! -e $test_dir/marker ]] || fail "a rebuild that changed nothing was marked as done"
pass "a rebuild that exits 0 without changing the boot menu leaves the migration pending"

run "$old_cmdline" "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf"
[[ $(rebuilds) == 1 && -e $test_dir/marker ]] ||
  fail "a machine booted without the parameter did not get its boot image rebuilt"
pass "the next run rebuilds the boot image, with the packaged defaults, and marks it"

run "$old_cmdline" "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf"
[[ $(rebuilds) == 0 ]] || fail "the rebuild ran a second time before a reboot"
pass "the rebuild runs once per machine, not once per user"

rm -f "$test_dir/marker"
run "$new_cmdline" "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf"
[[ $(rebuilds) == 0 && ! -e $test_dir/marker ]] || fail "a machine that already boots with the parameter was rebuilt"
pass "a machine that already boots with the parameter is left alone"

grep -v "tty.term.console" "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" >"$test_dir/edited.conf"
run "$old_cmdline" "$test_dir/edited.conf"
[[ $(rebuilds) == 0 ]] || fail "a machine whose defaults leave the parameter out was rebuilt anyway"
pass "a machine whose defaults were edited to leave the parameter out is left alone"

# No Limine: the stand-in goes, and the PATH holds only what the migration
# needs, so a limine-mkinitcpio installed on the machine running this test is
# not found either.
rm "$stub_bin/limine-mkinitcpio"
mkdir -p "$test_dir/tools"
for tool in bash grep install cat sed tail; do ln -s "$(command -v "$tool")" "$test_dir/tools/$tool"; done
: >"$test_dir/rebuilds"
printf '%s\n' "$old_cmdline" >"$test_dir/cmdline"
PATH="$stub_bin:$ROOT/bin:$test_dir/tools" REBUILDS="$test_dir/rebuilds" \
  OMARCHY_RUNNING_CMDLINE="$test_dir/cmdline" OMARCHY_LIMINE_DEFAULTS_CONF="$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" \
  OMARCHY_LIMINE_REBUILD_MARKER="$test_dir/marker" "$test_dir/tools/bash" -euo pipefail "$migration" >/dev/null
[[ ! -e $test_dir/marker ]] || fail "a machine without Limine was marked as rebuilt"
pass "a machine without Limine is left alone"
