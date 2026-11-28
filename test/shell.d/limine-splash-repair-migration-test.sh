#!/bin/bash
#
# The migration that puts splash back into a drifted omarchy-defaults.conf:
# Omarchy's own quiet line gets the token back while the rest of the file and
# any command line a user wrote stay as they are, and the boot image is rebuilt
# once per machine, only where the booted command line lacks the token.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1792673722.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

# sudo just drops the prefix, and can be denied: the repair goes through it.
printf '#!/bin/bash\n[[ ${SUDO_DENY:-} == 1 ]] && exit 1\nexec "$@"\n' >"$stub_bin/sudo"
# limine-mkinitcpio records that it ran, reports a kernel it could not build
# the way the real one does (exiting 0), or fails outright.
cat >"$stub_bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash
echo rebuilt >>"${REBUILDS:?}"
[[ -z ${REBUILD_SLOW:-} ]] || sleep 0.3
[[ -z ${REBUILD_ERRORS:-} ]] || exit 1
[[ -z ${REBUILD_REPORTS_FAILURE:-} ]] || echo "mkinitcpio failed for kernel 7.2.8-9-omarchy (exit code 1)"
exit 0
STUB
chmod +x "$stub_bin"/*

conf="$test_dir/omarchy-defaults.conf"
defaults_file="$test_dir/default-limine"

# The drift the issue reports: a backed-up copy of Omarchy's own line that lost
# splash while keeping every parameter the older guards look for.
write_drifted() {
  cat >"$conf" <<'EOF'
TARGET_OS_NAME="Omarchy"

KERNEL_CMDLINE[default]+=" quiet loglevel=0 systemd.show_status=false rd.udev.log_level=0 vt.global_cursor_default=0"

KERNEL_CMDLINE[default]+=" systemd.tty.term.console=dumb"
EOF
}

run() { # booted cmdline; further KEY=VALUE arguments go to env
  : >"$test_dir/rebuilds"
  : >"$test_dir/out"
  printf '%s\n' "$1" >"$test_dir/cmdline"
  env PATH="$stub_bin:$ROOT/bin:$PATH" REBUILDS="$test_dir/rebuilds" \
    OMARCHY_RUNNING_CMDLINE="$test_dir/cmdline" OMARCHY_LIMINE_DEFAULTS_CONF="$conf" \
    OMARCHY_LIMINE_DEFAULT_CONF="$defaults_file" OMARCHY_LIMINE_REBUILD_LOCK="$test_dir/rebuild.lock" \
    OMARCHY_LIMINE_REBUILD_MARKER="$test_dir/marker" "${@:2}" \
    bash -euo pipefail "$migration" >"$test_dir/out"
}
rebuilds() { wc -l <"$test_dir/rebuilds"; }
reset() { rm -f "$test_dir/marker"; }

# The reported machine: a booted command line without splash.
write_drifted
run 'root=PARTUUID=1 rw quiet loglevel=0'
grep -Fxq 'KERNEL_CMDLINE[default]+=" quiet loglevel=0 systemd.show_status=false rd.udev.log_level=0 vt.global_cursor_default=0 splash"' "$conf" ||
  fail "the drifted Omarchy line did not get splash back" "content: $(grep quiet "$conf")"
grep -Fxq 'KERNEL_CMDLINE[default]+=" systemd.tty.term.console=dumb"' "$conf" ||
  fail "the repair changed another line of the same file"
grep -Fxq 'TARGET_OS_NAME="Omarchy"' "$conf" || fail "the repair dropped a line from the file"
[[ $(find "$test_dir" -name 'omarchy-defaults.conf.*' -print -quit) == "" ]] ||
  fail "the staged rewrite was left behind"
grep -Fq "Restored splash in $conf" "$test_dir/out" || fail "the repair was not reported"
[[ $(rebuilds) == 1 && -e $test_dir/marker ]] ||
  fail "the repaired file was not rebuilt once into the boot image"
pass "a drifted Omarchy line gets splash back, the rest of the file stays, and the boot image is rebuilt once"

before=$(cat "$conf")
run 'root=PARTUUID=1 rw quiet loglevel=0'
[[ $(cat "$conf") == "$before" ]] || fail "a second run changed the repaired file"
[[ $(rebuilds) == 0 && -e $test_dir/marker ]] ||
  fail "another user's run rebuilt the boot image before the first reboot"
pass "another user before the reboot repairs nothing and rebuilds nothing"

# The file is right and the machine already booted with it: nothing to do.
reset
cp "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" "$conf"
run 'root=PARTUUID=1 rw quiet splash loglevel=0'
[[ $(rebuilds) == 0 && ! -e $test_dir/marker ]] ||
  fail "a machine that already boots with splash was rebuilt"
pass "a machine that already boots with splash is left alone"

# The guard the issue asks for: the file is right, the boot image predates it.
cp "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" "$conf"
run 'root=PARTUUID=1 rw quiet loglevel=0'
cmp -s "$conf" "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" ||
  fail "the packaged defaults were rewritten"
[[ $(rebuilds) == 1 && -e $test_dir/marker ]] ||
  fail "a boot image that predates splash was not rebuilt"
pass "packaged defaults on a machine booted without splash get one rebuild and no file change"

# A command line the user wrote, with none of the tokens Omarchy ships beside
# splash: not ours to edit.
reset
printf 'KERNEL_CMDLINE[default]=" root=PARTUUID=1 rw quiet splash"\n' >"$conf"
before=$(cat "$conf")
run 'root=PARTUUID=1 rw quiet splash'
[[ $(cat "$conf") == "$before" && $(rebuilds) == 0 && ! -e $test_dir/marker ]] ||
  fail "a command line the user wrote was edited or rebuilt"
pass "a user-written command line is left alone"

# The word quiet inside another parameter's value is not the token, so the line
# is not Omarchy's and is left alone too.
reset
printf 'KERNEL_CMDLINE[default]+=" foo=quiet loglevel=0 vt.global_cursor_default=0"\n' >"$conf"
before=$(cat "$conf")
run 'root=PARTUUID=1 rw quiet loglevel=0'
[[ $(cat "$conf") == "$before" && $(rebuilds) == 0 ]] ||
  fail "the word quiet inside another value was taken for the token"
pass "quiet inside another parameter's value is not Omarchy's line"

# A drifted line that also carries a setting of the user's own keeps it.
reset
printf 'KERNEL_CMDLINE[default]+=" quiet loglevel=0 vt.global_cursor_default=0 nvidia_drm.fbdev=1"\n' >"$conf"
run 'root=PARTUUID=1 rw quiet loglevel=0'
grep -Fxq 'KERNEL_CMDLINE[default]+=" quiet loglevel=0 vt.global_cursor_default=0 nvidia_drm.fbdev=1 splash"' "$conf" ||
  fail "a setting beside splash on the same line was dropped" "content: $(cat "$conf")"
pass "the tokens a user added to Omarchy's line survive the repair"

# A copy that reordered the tokens still gets the token back.
reset
printf 'KERNEL_CMDLINE[default]+=" loglevel=0 vt.global_cursor_default=0 quiet"\n' >"$conf"
run 'root=PARTUUID=1 rw quiet loglevel=0'
grep -Fxq 'KERNEL_CMDLINE[default]+=" loglevel=0 vt.global_cursor_default=0 quiet splash"' "$conf" ||
  fail "a line that puts quiet last was left unrepaired" "content: $(cat "$conf")"
pass "the token goes back wherever quiet sits on the line"

# A backup= file an editor saved without a last newline keeps its last line.
reset
printf 'KERNEL_CMDLINE[default]+=" quiet loglevel=0 vt.global_cursor_default=0"\nSNAPSHOT_FORMAT_CHOICE=5' >"$conf"
run 'root=PARTUUID=1 rw quiet loglevel=0'
grep -Fxq 'SNAPSHOT_FORMAT_CHOICE=5' "$conf" ||
  fail "the repair dropped a last line with no trailing newline" "content: $(cat "$conf")"
pass "a last line without a trailing newline survives the rewrite"

# The rebuild failed: the migration stays pending, so the next update retries.
reset
write_drifted
if run 'root=PARTUUID=1 rw quiet loglevel=0' REBUILD_ERRORS=1; then
  fail "a rebuild that failed was reported as a success"
fi
grep -Fq 'vt.global_cursor_default=0 splash' "$conf" || fail "the failed run lost the repaired file"
[[ ! -e $test_dir/marker ]] || fail "a failed rebuild was marked as done"
pass "a rebuild that fails leaves the migration pending and the repair in place"

# limine-mkinitcpio exits 0 past a kernel it could not rebuild, which is the
# case a UKI menu cannot show.
reset
write_drifted
if run 'root=PARTUUID=1 rw quiet loglevel=0' REBUILD_REPORTS_FAILURE=1; then
  fail "a rebuild that reported a kernel failure was marked as done"
fi
[[ ! -e $test_dir/marker ]] || fail "a kernel it could not rebuild was marked as done"
pass "a kernel the rebuild could not build leaves the migration pending"

# A plain KERNEL_CMDLINE[default]= in /etc/default/limine replaces Omarchy's
# defaults, so no rebuild can add splash. That line is the administrator's: the
# migration completes and says how to keep Omarchy's defaults.
reset
write_drifted
printf 'KERNEL_CMDLINE[default]=" root=PARTUUID=1 rw quiet loglevel=0"\n' >"$defaults_file"
if ! run 'root=PARTUUID=1 rw quiet loglevel=0'; then
  fail "a command line the administrator owns stopped the migration"
fi
[[ -e $test_dir/marker ]] || fail "a command line the administrator owns left the migration pending"
grep -Fq 'use += rather than =' "$test_dir/out" ||
  fail "a command line the administrator owns got no advice"
pass "a command line the administrator owns is reported, and does not stop the queue"

# The same file that keeps splash is not worth a warning.
reset
write_drifted
printf 'KERNEL_CMDLINE[default]=" root=PARTUUID=1 rw quiet splash"\n' >"$defaults_file"
run 'root=PARTUUID=1 rw quiet loglevel=0'
grep -Fq 'use += rather than =' "$test_dir/out" &&
  fail "a command line that keeps splash still got the += advice"
rm -f "$defaults_file"
pass "a command line that keeps splash gets no advice"

# Two users running the migration at the same moment must rebuild once: the
# lock is what makes the marker check mean anything, since checking a marker and
# rebuilding are not one step.
reset
write_drifted
printf 'root=PARTUUID=1 rw quiet loglevel=0\n' >"$test_dir/cmdline"
: >"$test_dir/rebuilds"
run_alongside() {
  env PATH="$stub_bin:$ROOT/bin:$PATH" REBUILDS="$test_dir/rebuilds" REBUILD_SLOW=1 \
    OMARCHY_RUNNING_CMDLINE="$test_dir/cmdline" OMARCHY_LIMINE_DEFAULTS_CONF="$conf" \
    OMARCHY_LIMINE_DEFAULT_CONF="$defaults_file" OMARCHY_LIMINE_REBUILD_LOCK="$test_dir/rebuild.lock" \
    OMARCHY_LIMINE_REBUILD_MARKER="$test_dir/marker" \
    bash -euo pipefail "$migration" >/dev/null 2>&1
}
run_alongside & first=$!
run_alongside & second=$!
first_status=0
second_status=0
wait "$first" || first_status=$?
wait "$second" || second_status=$?
[[ $(rebuilds) == 1 ]] || fail "two runs at once rebuilt the boot image twice"
[[ $first_status == 0 && $second_status == 0 ]] || fail "a run of two at once failed"
pass "two runs at once rebuild the boot image once"

# A user whose umask is 077 must not leave a lock no other user can open, or
# every later update on the machine stops at it.
reset
write_drifted
rm -f "$test_dir/rebuild.lock"
chmod 700 "$test_dir"
( umask 077; run 'root=PARTUUID=1 rw quiet loglevel=0' )
[[ $(stat -c %a "$test_dir/rebuild.lock") == 644 ]] ||
  fail "the lock was created unreadable for other users"
[[ $(stat -c %a "$test_dir") == 755 ]] || fail "the lock's directory is not traversable"
pass "the lock is readable whatever the umask"

# The repair itself needs sudo; a denied prompt must not be recorded as done.
reset
write_drifted
before=$(cat "$conf")
if run 'root=PARTUUID=1 rw quiet loglevel=0' SUDO_DENY=1; then
  fail "a denied sudo prompt was reported as a successful migration"
fi
[[ $(cat "$conf") == "$before" ]] || fail "a denied sudo prompt changed the file"
pass "a denied sudo prompt leaves the file and the migration pending"
