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
# limine-entry-tool answers with the command line a test chose for that kernel,
# or for the default when it chose none.
cat >"$stub_bin/limine-entry-tool" <<'STUB'
#!/bin/bash
[[ $1 == "--get-cmdline" ]] || exit 2
[[ -z ${ENTRY_TOOL_FAILS:-} ]] || exit 1
[[ -z ${ENTRY_TOOL_WARNS:-} ]] || echo "warning: systemd.tty.term.console=dumb is deprecated"
if [[ -f ${KERNEL_CMDLINES:?}/$2 ]]; then
  cat "$KERNEL_CMDLINES/$2"
else
  cat "$KERNEL_CMDLINES/default"
fi
STUB
# Limine's config loader, reporting whichever fallbacks a test builds.
cat >"$test_dir/limine-common-functions" <<'STUB'
load_config() {
  [[ -z ${LOADER_FAILS:-} ]] || return 1
  MKINITCPIO_FALLBACK=${FALLBACKS:-}
}
STUB
# pacman names the package that owns a kernel's modules.builtin, if one does.
cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash
[[ $1 == "-Qqo" && -f ${2%/*}/owner ]] || exit 1
cat "${2%/*}/owner"
STUB
chmod +x "$stub_bin"/*

# Two installed kernels; a directory a removed kernel left behind, which still
# has its modules but no package; and one with no modules at all.
modules_dir="$test_dir/modules"
for kernel in linux linux-omarchy stale nothing; do mkdir -p "$modules_dir/$kernel-dir"; done
for kernel in linux linux-omarchy stale; do touch "$modules_dir/$kernel-dir/modules.builtin"; done
echo linux >"$modules_dir/linux-dir/owner"
echo linux-omarchy >"$modules_dir/linux-omarchy-dir/owner"
kernel_cmdlines="$test_dir/kernel-cmdlines"
mkdir -p "$kernel_cmdlines"
configured() { # default command line, then kernel=command line overrides
  rm -f "$kernel_cmdlines"/*
  printf '%s\n' "$1" >"$kernel_cmdlines/default"
  shift
  for override in "$@"; do printf '%s\n' "${override#*=}" >"$kernel_cmdlines/${override%%=*}"; done
}

old_cmdline="root=PARTUUID=1 rw quiet splash initramfs_async=0"
new_cmdline="$old_cmdline systemd.tty.term.console=dumb"
defaults="$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf"
configured "$new_cmdline"
built="$new_cmdline"

run() { # booted cmdline, defaults conf
  : >"$test_dir/rebuilds"
  printf '%s\n' "$1" >"$test_dir/cmdline"
  printf '  cmdline: %s\n' "$1" >"$test_dir/limine.conf"
  PATH="$stub_bin:$ROOT/bin:$PATH" REBUILDS="$test_dir/rebuilds" \
    LIMINE_CONF="$test_dir/limine.conf" NEW_CMDLINE="$built" OMARCHY_LIMINE_CONF="$test_dir/limine.conf" \
    OMARCHY_RUNNING_CMDLINE="$test_dir/cmdline" OMARCHY_LIMINE_DEFAULTS_CONF="$2" \
    OMARCHY_KERNEL_MODULES_DIR="$modules_dir" KERNEL_CMDLINES="$kernel_cmdlines" \
    OMARCHY_LIMINE_FUNCTIONS="$test_dir/limine-common-functions" \
    OMARCHY_LIMINE_REBUILD_MARKER="$test_dir/marker" bash -euo pipefail "$migration" >/dev/null
}
rebuilds() { wc -l <"$test_dir/rebuilds"; }

# omarchy-migrate runs a migration with bash -euo pipefail, and so does run:
# that is what stops a failed rebuild before the marker is written.
if REBUILD_FAILS=1 run "$old_cmdline" "$defaults"; then
  fail "a rebuild that failed was reported as a success"
fi
[[ $(rebuilds) == 1 && ! -e $test_dir/marker ]] || fail "a failed rebuild was marked as done"
pass "a rebuild that fails stops the migration and leaves no marker"

# limine-mkinitcpio exits 0 past a kernel it could not build.
if REBUILD_BUILDS_NOTHING=1 run "$old_cmdline" "$defaults"; then
  fail "a rebuild that changed nothing was reported as a success"
fi
[[ ! -e $test_dir/marker ]] || fail "a rebuild that changed nothing was marked as done"
pass "a rebuild that exits 0 without changing the boot menu leaves the migration pending"

run "$old_cmdline" "$defaults"
[[ $(rebuilds) == 1 && -e $test_dir/marker ]] ||
  fail "a machine booted without the parameter did not get its boot image rebuilt"
pass "the next run rebuilds the boot image, with the packaged defaults, and marks it"

run "$old_cmdline" "$defaults"
[[ $(rebuilds) == 0 ]] || fail "the rebuild ran a second time before a reboot"
pass "the rebuild runs once per machine, not once per user"

rm -f "$test_dir/marker"
run "$new_cmdline" "$defaults"
[[ $(rebuilds) == 0 && ! -e $test_dir/marker ]] || fail "a machine that already boots with the parameter was rebuilt"
pass "a machine that already boots with the parameter is left alone"

run 'root=PARTUUID=1 acpi_osi="Windows systemd.tty.term.console=dumb"' "$defaults"
[[ $(rebuilds) == 1 && -e $test_dir/marker ]] ||
  fail "a booted command line with the parameter's text inside another value was not rebuilt"
pass "the parameter's text inside another booted parameter's value is not the parameter"

rm -f "$test_dir/marker"
run "$new_cmdline systemd.tty.term.console=linux" "$defaults"
[[ $(rebuilds) == 1 && -e $test_dir/marker ]] || fail "a booted command line that overrides the parameter later was not rebuilt"
rm -f "$test_dir/marker"
run "$new_cmdline systemd.tty.term.console=\"linux" "$defaults"
[[ $(rebuilds) == 1 && -e $test_dir/marker ]] || fail "a booted override inside an unclosed quote was not rebuilt"
rm -f "$test_dir/marker"
run "root=PARTUUID=1 systemd.tty.term.console=dumb$(printf '\f')foo=bar" "$defaults"
[[ $(rebuilds) == 1 && -e $test_dir/marker ]] || fail "a form feed was taken for a separator systemd does not split on"
pass "a later assignment of the key overrides the parameter, as systemd reads it"
rm -f "$test_dir/marker"

grep -v "tty.term.console" "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" >"$test_dir/edited.conf"
run "$old_cmdline" "$test_dir/edited.conf"
[[ $(rebuilds) == 0 ]] || fail "a machine whose defaults leave the parameter out was rebuilt anyway"
pass "a machine whose defaults were edited to leave the parameter out is left alone"

# A plain = in /etc/default/limine replaces everything the drop-ins appended, so
# the rebuild builds entries without the parameter, and the update must go on.
expect_done() { # what failed
  rm -f "$test_dir/marker"
  run "$old_cmdline" "$defaults" 2>/dev/null || fail "$1 failed the migration"
  [[ $(rebuilds) == 1 && -e $test_dir/marker ]] || fail "$1 was not rebuilt and marked"
}
expect_pending() { # what failed
  rm -f "$test_dir/marker"
  if run "$old_cmdline" "$defaults" 2>/dev/null; then
    fail "$1 was reported as a success"
  fi
  [[ ! -e $test_dir/marker ]] || fail "$1 was marked as done"
}
built="$old_cmdline"

configured "$old_cmdline"
expect_done "a machine whose Limine config drops the parameter"
pass "a machine whose Limine config drops the parameter for every kernel finishes the migration"

configured "$new_cmdline" "linux=$old_cmdline" "linux-omarchy=$old_cmdline"
expect_done "a machine whose per-kernel command lines drop the parameter"
pass "per-kernel command lines that drop the parameter override a default that has it"

configured "$old_cmdline" "stale=$new_cmdline"
expect_done "a machine where only a removed kernel would carry the parameter"
pass "a kernel directory no package owns is not one the rebuild builds"

# A kernel the rebuild builds is configured with it, so the rebuild went wrong.
configured "$old_cmdline" "linux-omarchy=$new_cmdline"
expect_pending "a rebuild that left out a configured parameter"
pass "one kernel configured with the parameter keeps a rebuild without it pending"

configured "$(printf 'root=PARTUUID=1\tsystemd.tty.term.console=dumb')"
expect_pending "a rebuild that left out a tab-separated parameter"
configured 'root=PARTUUID=1 "systemd.tty.term.console=dumb"'
expect_pending "a rebuild that left out a quoted parameter"
configured 'root=PARTUUID=1 systemd.tty.term.console="dumb"'
expect_pending "a rebuild that left out a parameter with a quoted value"
configured "root=PARTUUID=1 systemd.tty.term.console='dumb'"
expect_pending "a rebuild that left out a parameter with a single-quoted value"
pass "the parameter is recognised however the kernel would split and unquote it"

configured 'root=PARTUUID=1 acpi_osi="Windows systemd.tty.term.console=dumb"'
expect_done "a machine whose parameter text sits inside another parameter's quoted value"
pass "text inside another parameter's quoted value is not the parameter"

# A fallback entry has a command line of its own, but only counts when built.
configured "$old_cmdline" "linux-fallback=$new_cmdline"
expect_done "a machine where only a fallback that is not built would carry the parameter"
FALLBACKS=yes expect_pending "a rebuild that left out a parameter its fallback entry is configured with"
FALLBACKS=linux expect_pending "a rebuild that left out a parameter the one fallback built is configured with"
FALLBACKS=linux-omarchy expect_done "a machine where only another kernel's fallback is built"
pass "fallback entries count exactly when limine-mkinitcpio builds them"

# A rebuild that wrote the parameter quoted did its job.
configured 'root=PARTUUID=1 systemd.tty.term.console="dumb"'
built='root=PARTUUID=1 systemd.tty.term.console="dumb"'
expect_done "a rebuild that wrote the parameter with a quoted value"
pass "a boot entry with the parameter's value quoted counts as rebuilt"

configured "$new_cmdline systemd.tty.term.console=linux"
built="$new_cmdline systemd.tty.term.console=linux"
expect_done "a machine whose Limine config overrides the parameter later on the same line"
pass "a boot entry that overrides the parameter later does not carry it"

configured "$old_cmdline systemd.tty.term.console=\"dumb"
expect_pending "a rebuild that left out a parameter whose quote is never closed"
pass "a parameter inside a quote that is never closed still counts"
built="$old_cmdline"

# limine-mkinitcpio reads the last line of the answer, and so does the migration.
configured "$old_cmdline"
ENTRY_TOOL_WARNS=1 expect_done "a machine whose limine-entry-tool prints a warning first"
pass "only the last line limine-entry-tool prints is the command line"

ENTRY_TOOL_FAILS=1 expect_pending "a limine-entry-tool that cannot answer"
LOADER_FAILS=1 expect_pending "a Limine config that cannot be loaded"
pass "a limine-entry-tool or config that cannot answer keeps the migration pending"
built="$new_cmdline"
configured "$new_cmdline"

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
