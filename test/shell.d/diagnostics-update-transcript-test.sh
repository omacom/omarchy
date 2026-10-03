#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-update

# omarchy-update resets PATH to $OMARCHY_PATH/bin before the logging exec, so the
# stand-in for script(1) goes there. It records the transcript path and stops.
script_log="$boundary_tmp/script.log"
cat >"$SUDO_TEST_ROOT/bin/script" <<SH
#!/bin/bash
printf '%s\n' "\$@" >>"$script_log"
SH
chmod +x "$SUDO_TEST_ROOT/bin/script"

run_update() {
  : >"$script_log"
  reset_boundary
  env -u OMARCHY_UPDATE_LOGGED "$@" "$SUDO_TEST_ROOT/bin/omarchy-update" -y
}

state_home="$boundary_tmp/xdg-state"
# An existing 0755 directory is the case mkdir -p leaves alone.
mkdir -p "$state_home/omarchy"
chmod 755 "$state_home/omarchy"
run_update XDG_STATE_HOME="$state_home" >/dev/null 2>&1

grep -qF "$state_home/omarchy/update.log" "$script_log" ||
  fail "omarchy update writes its transcript under XDG_STATE_HOME" \
    "script got: $(cat "$script_log")"
pass "omarchy update writes its transcript under XDG_STATE_HOME"

[[ $(stat -c %a "$state_home/omarchy") == 700 ]] ||
  fail "omarchy update tightens an existing state directory to mode 0700" \
    "mode: $(stat -c %a "$state_home/omarchy")"
[[ $(stat -c %a "$state_home/omarchy/update.log") == 600 ]] ||
  fail "omarchy update creates the transcript mode 0600" \
    "mode: $(stat -c %a "$state_home/omarchy/update.log")"
pass "omarchy update keeps the transcript private"

# script truncates when it opens the file. Until then, an older transcript stays,
# and a 0644 mode left by an earlier run is tightened.
printf 'PREVIOUS\n' >"$state_home/omarchy/update.log"
chmod 644 "$state_home/omarchy/update.log"
run_update XDG_STATE_HOME="$state_home" >/dev/null 2>&1
[[ $(stat -c %a "$state_home/omarchy/update.log") == 600 ]] ||
  fail "omarchy update tightens an existing transcript to mode 0600" \
    "mode: $(stat -c %a "$state_home/omarchy/update.log")"
[[ $(cat "$state_home/omarchy/update.log") == PREVIOUS ]] ||
  fail "omarchy update leaves an existing transcript for script to open" \
    "contents: $(cat "$state_home/omarchy/update.log")"
pass "omarchy update tightens an existing transcript without emptying it"

# The fixture points the copied command's $HOME at SUDO_TEST_HOME.
run_update -u XDG_STATE_HOME >/dev/null 2>&1

grep -qF "$SUDO_TEST_HOME/.local/state/omarchy/update.log" "$script_log" ||
  fail "omarchy update falls back to ~/.local/state without XDG_STATE_HOME" \
    "script got: $(cat "$script_log")"
pass "omarchy update falls back to ~/.local/state without XDG_STATE_HOME"

[[ $(stat -c %a "$SUDO_TEST_HOME/.local/state/omarchy") == 700 ]] ||
  fail "omarchy update creates the fallback state directory mode 0700" \
    "mode: $(stat -c %a "$SUDO_TEST_HOME/.local/state/omarchy")"
[[ $(stat -c %a "$SUDO_TEST_HOME/.local/state/omarchy/update.log") == 600 ]] ||
  fail "omarchy update creates the fallback transcript mode 0600" \
    "mode: $(stat -c %a "$SUDO_TEST_HOME/.local/state/omarchy/update.log")"
pass "omarchy update keeps the fallback transcript private"

# A symlink at the state directory must not be chmodded. chmod follows one.
real_state="$boundary_tmp/real-state"
mkdir -p "$real_state" "$boundary_tmp/state-parent"
chmod 755 "$real_state"
ln -s "$real_state" "$boundary_tmp/state-parent/omarchy"
if run_update XDG_STATE_HOME="$boundary_tmp/state-parent" \
  >"$boundary_tmp/update-dir-link.out" 2>"$boundary_tmp/update-dir-link.err"; then
  fail "omarchy update refuses a symlink state directory"
fi
[[ ! -s $script_log ]] ||
  fail "omarchy update does not start script when the state directory is a symlink" \
    "script got: $(cat "$script_log")"
[[ $(stat -c %a "$real_state") == 755 ]] ||
  fail "omarchy update does not chmod through a symlink state directory" \
    "mode: $(stat -c %a "$real_state")"
grep -q 'is a symlink' "$boundary_tmp/update-dir-link.err" ||
  fail "omarchy update reports a symlink state directory" \
    "stderr: $(cat "$boundary_tmp/update-dir-link.err")"
assert_boundary_cold "omarchy update refusing a symlink state directory"
pass "omarchy update refuses a symlink state directory"

# script would follow a symlink at the log path and write the transcript there.
secret="$boundary_tmp/update-secret"
printf 'SECRET\n' >"$secret"
ln -sfn "$secret" "$state_home/omarchy/update.log"
run_update XDG_STATE_HOME="$state_home" >/dev/null 2>&1
[[ ! -L $state_home/omarchy/update.log && -f $state_home/omarchy/update.log ]] ||
  fail "omarchy update replaces a symlink transcript with a regular file"
[[ $(stat -c %a "$state_home/omarchy/update.log") == 600 ]] ||
  fail "omarchy update recreates the transcript mode 0600 after dropping a symlink" \
    "mode: $(stat -c %a "$state_home/omarchy/update.log")"
[[ $(cat "$secret") == SECRET ]] ||
  fail "omarchy update does not write through a symlink transcript" \
    "target: $(cat "$secret")"
grep -qF "$state_home/omarchy/update.log" "$script_log" ||
  fail "omarchy update still hands script the transcript path" \
    "script got: $(cat "$script_log")"
pass "omarchy update drops a symlink at the transcript path"

rm -f "$state_home/omarchy/update.log"
mkdir "$state_home/omarchy/update.log"
if run_update XDG_STATE_HOME="$state_home" \
  >"$boundary_tmp/update-dir-log.out" 2>"$boundary_tmp/update-dir-log.err"; then
  fail "omarchy update refuses a directory at the transcript path"
fi
[[ -d $state_home/omarchy/update.log ]] ||
  fail "omarchy update leaves a directory at the transcript path"
[[ ! -s $script_log ]] ||
  fail "omarchy update does not start script when the transcript path is a directory" \
    "script got: $(cat "$script_log")"
grep -q 'is a directory' "$boundary_tmp/update-dir-log.err" ||
  fail "omarchy update reports a directory at the transcript path" \
    "stderr: $(cat "$boundary_tmp/update-dir-log.err")"
pass "omarchy update refuses a directory at the transcript path"
