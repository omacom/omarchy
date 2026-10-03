#!/bin/bash
#
# The USB autosuspend migration must rebuild the boot image once per machine
# when Limine's effective command line carries usbcore.autosuspend=-1 but the
# booted kernel doesn't, record that with a marker, ask for a reboot, and retry
# a failed rebuild. Where omarchy-defaults.conf was edited and the update went
# to a .pacnew, it adds the line itself unless something already sets
# usbcore.autosuspend. It follows the value Limine puts last, as every later
# rebuild will, and says why when it doesn't rebuild.
#
# Only the command check, the state helper, Limine's tools and sudo are stubbed.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1790963359.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
calls="$test_dir/calls"
dropins="$test_dir/limine-entry-tool.d"
defaults_conf="$dropins/omarchy-defaults.conf"
default_limine="$test_dir/default-limine"
running_cmdline="$test_dir/cmdline"
marker="$test_dir/state/1790963359"
output="$test_dir/output"
mkdir -p "$stub_bin" "$dropins" "$test_dir/state"

# limine-mkinitcpio is present unless STUB_NO_LIMINE is set, and exits with
# STUB_REBUILD_STATUS. limine-entry-tool prints the effective default command
# line in the order the real tool builds it: /etc/default/limine first (alone
# when it resets the line with =), then the drop-ins' += values in reverse
# file order, each file's lines reversed, so earlier-sorting drop-ins come
# last and win. sudo and omarchy-state record their calls.
cat >"$stub_bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
[[ -z ${STUB_NO_LIMINE:-} ]]
STUB
cat >"$stub_bin/omarchy-state" <<'STUB'
#!/bin/bash
echo "omarchy-state $*" >>"${CALLS:?}"
STUB
cat >"$stub_bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash
exit "${STUB_REBUILD_STATUS:-0}"
STUB
cat >"$stub_bin/limine-entry-tool" <<'STUB'
#!/bin/bash
values() {
  sed -n 's/^KERNEL_CMDLINE\[default\]+=" *\(.*\)"$/\1/p' "$1" | tac | tr '\n' ' '
}
reset=$(sed -n 's/^KERNEL_CMDLINE\[default\] *= *"\(.*\)"$/\1/p' "$OMARCHY_DEFAULT_LIMINE" 2>/dev/null)
if [[ -n $reset ]]; then
  echo "$reset"
  exit 0
fi
[[ -f $OMARCHY_DEFAULT_LIMINE ]] && values "$OMARCHY_DEFAULT_LIMINE"
for conf in $(ls -r "${OMARCHY_LIMINE_DEFAULTS_CONF%/*}"/*.conf); do
  values "$conf"
done
echo
STUB
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
echo "sudo $*" >>"${CALLS:?}"
"$@"
STUB
chmod +x "$stub_bin"/*

run_migration() {
  rm -f "$calls"
  PATH="$stub_bin:$PATH" CALLS="$calls" OMARCHY_LIMINE_DEFAULTS_CONF="$defaults_conf" \
    OMARCHY_DEFAULT_LIMINE="$default_limine" OMARCHY_RUNNING_CMDLINE="$running_cmdline" \
    OMARCHY_LIMINE_REBUILD_MARKER="$marker" bash -euo pipefail "$migration" >"$output" 2>&1
}
rebuilt() {
  [[ -e $calls ]] && grep -Fxq "sudo limine-mkinitcpio" "$calls"
}
reboot_flagged() {
  [[ -e $calls ]] && grep -Fxq "omarchy-state set reboot-required" "$calls"
}
usbcore_lines() {
  grep -c "usbcore.autosuspend" "$defaults_conf" || true
}

cp "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" "$defaults_conf"
echo "root=UUID=x rw quiet splash" >"$running_cmdline"

STUB_REBUILD_STATUS=1 run_migration && fail "migration reports a failed rebuild"
[[ ! -e $marker ]] || fail "a failed rebuild leaves no marker, so the next run retries"
! reboot_flagged || fail "a failed rebuild doesn't ask for a reboot"
pass "a failed rebuild is retried"

run_migration || fail "migration completes when the booted kernel lacks the parameter" "$(<"$output")"
rebuilt || fail "migration rebuilds the boot image" "$(<"$calls")"
[[ -e $marker ]] || fail "migration records the machine-wide rebuild"
reboot_flagged || fail "migration asks for a reboot" "$(<"$calls")"
[[ $(grep -n "" "$calls" | grep -E "reboot-required|install -Dm644" | cut -d: -f2 | tr '\n' ' ') == "omarchy-state set reboot-required sudo install"* ]] ||
  fail "migration asks for the reboot before recording the rebuild" "$(<"$calls")"
[[ $(usbcore_lines) == 1 ]] || fail "migration leaves a packaged defaults file that has the line as it is"
pass "migration rebuilds the boot image once and asks for a reboot when the booted kernel lacks usbcore.autosuspend=-1"

run_migration || fail "migration completes after the rebuild"
[[ ! -e $calls ]] || fail "another run before reboot doesn't rebuild again" "$(<"$calls")"
pass "migration doesn't rebuild again before the reboot"

rm -f "$marker"
echo "root=UUID=x rw quiet splash usbcore.autosuspend=-1" >"$running_cmdline"
run_migration || fail "migration completes when the parameter is already booted"
[[ ! -e $calls && ! -e $marker ]] || fail "migration leaves a machine that already boots with the parameter alone"
pass "migration leaves a machine that already boots with the parameter alone"

# Without a .pacnew the defaults file wasn't diverted (say a dev checkout ahead
# of its package): leave the pacman-tracked file alone.
echo "root=UUID=x rw" >"$running_cmdline"
grep -v "usbcore" "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" >"$defaults_conf"
run_migration || fail "migration completes on defaults without the line and no .pacnew"
[[ $(usbcore_lines) == 0 ]] && ! rebuilt || fail "migration doesn't edit a defaults file that has no .pacnew"
pass "migration leaves a defaults file without a .pacnew alone"

# An edited omarchy-defaults.conf kept the user's copy and put the update in a
# .pacnew beside it, which Limine doesn't read: the migration adds the line to
# the live file, once, on its own line even when the file lacks a final newline,
# and rebuilds.
echo "root=UUID=x rw" >"$running_cmdline"
cp "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" "$defaults_conf.pacnew"
grep -v "usbcore" "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" | head -c -1 >"$defaults_conf"
run_migration || fail "migration completes on an edited defaults file" "$(<"$output")"
[[ $(usbcore_lines) == 1 ]] || fail "migration adds the line to an edited defaults file once"
grep -Fxq 'KERNEL_CMDLINE[default]+=" usbcore.autosuspend=-1"' "$defaults_conf" || fail "migration adds the line on its own line" "$(tail -3 "$defaults_conf")"
rebuilt && [[ -e $marker ]] || fail "migration rebuilds once it has added the line" "$(<"$calls")"
cmp -s "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" "$defaults_conf.pacnew" || fail "migration leaves the .pacnew alone"
rm -f "$marker"
run_migration || fail "migration completes on a second run over the edited file"
[[ $(usbcore_lines) == 1 ]] || fail "migration doesn't add the line twice"
rm -f "$marker" "$defaults_conf.pacnew"
pass "migration adds the line to an edited defaults file beside its .pacnew and rebuilds"

# limine-entry-tool's order decides which usbcore.autosuspend the kernel uses,
# and every later rebuild follows it. A drop-in that sorts before
# omarchy-defaults.conf comes last and wins: leave it, and say so.
cp "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" "$defaults_conf"
echo 'KERNEL_CMDLINE[default]+=" usbcore.autosuspend=2"' >"$dropins/00-local.conf"
run_migration || fail "migration completes when an administrator's value wins"
! rebuilt && [[ ! -e $marker ]] && ! reboot_flagged || fail "migration doesn't rebuild when an administrator's value wins"
grep -q "Limine sets usbcore.autosuspend=2" "$output" || fail "migration says it left the administrator's value" "$(<"$output")"
grep -v "usbcore" "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" >"$defaults_conf"
cp "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" "$defaults_conf.pacnew"
run_migration || fail "migration completes when only an administrator sets usbcore.autosuspend"
[[ $(usbcore_lines) == 0 ]] || fail "migration doesn't add Omarchy's line where an administrator set the value"
! rebuilt && [[ ! -e $marker ]] || fail "migration doesn't rebuild over an administrator's value"
rm -f "$dropins/00-local.conf" "$defaults_conf.pacnew"
pass "migration leaves an administrator's usbcore.autosuspend that wins alone and says so"

# One that sorts after it comes first, so Omarchy's -1 wins on the next rebuild
# anyway; the migration applies that now.
cp "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" "$defaults_conf"
echo 'KERNEL_CMDLINE[default]+=" usbcore.autosuspend=2"' >"$dropins/zz-local.conf"
run_migration || fail "migration completes when Omarchy's value wins"
rebuilt && [[ -e $marker ]] || fail "migration rebuilds when Omarchy's value comes last" "$(<"$output")"
rm -f "$dropins/zz-local.conf" "$marker"
pass "migration applies Omarchy's value when Limine puts it last"

# /etc/default/limine resets the command line, so no drop-in reaches it: an
# edited defaults file isn't touched for nothing, and the migration says why.
grep -v "usbcore" "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" >"$defaults_conf"
cp "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" "$defaults_conf.pacnew"
echo 'KERNEL_CMDLINE[default] = "root=UUID=x rw"' >"$default_limine"
run_migration || fail "migration completes when /etc/default/limine resets the command line"
[[ $(usbcore_lines) == 0 ]] || fail "migration doesn't add a line that can't take effect"
! rebuilt && [[ ! -e $marker ]] || fail "migration doesn't rebuild when the parameter can't reach the command line"
grep -q "check /etc/default/limine" "$output" || fail "migration says where to look" "$(<"$output")"
rm -f "$default_limine" "$defaults_conf.pacnew"
pass "migration explains a reset command line instead of rebuilding"

STUB_NO_LIMINE=1 run_migration || fail "migration completes without limine-mkinitcpio"
[[ ! -e $calls ]] || fail "migration does nothing without limine-mkinitcpio"
pass "migration does nothing without Limine"
