#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-update-health against stubs for every command it probes. The runtime
# directory is a scratch one holding only the sockets a case asks for, so the
# real session's compositor, shell, PipeWire and user bus never answer a probe.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
tools_bin="$test_tmp/tools"
runtime_dir="$test_tmp/run"
export CALL_LOG="$test_tmp/calls"
mkdir -p "$stub_bin" "$tools_bin" "$test_tmp/home" "$test_tmp/tmp"

# Just the tools the report itself uses, for a PATH on which a probed command
# can be truly missing.
for tool in awk bash cat cut env find grep mktemp rm sed sleep sort tail timeout; do
  ln -s "$(command -v "$tool")" "$tools_bin/$tool"
done
health_path="$stub_bin:$ROOT/bin:/usr/bin:/bin"

# Each stub records how it was called, then runs its body.
write_stub() {
  local name="$1" body="$2"

  cat >"$stub_bin/$name" <<SH
#!/bin/bash
printf '%s %s\n' "\${0##*/}" "\$*" >>"\$CALL_LOG"
$body
SH
  chmod +x "$stub_bin/$name"
}

# The user manager: is-active answers with the words of $1 for PipeWire and
# WirePlumber, --failed lists the words of $2 for system units and of $3 for
# user units (a backslash keeps a unit's line together), and the session
# environment holds the words of $4. is-active exits as systemctl does, 0 when
# either unit is active.
systemctl_stub() {
  write_stub systemctl "case \"\$*\" in
  *is-active*) printf '%s\n' $1; [[ \" $1 \" == *' active '* ]] ;;
  *show-environment*) printf '%s\n' ${4:-} ;;
  '--user --failed'*) printf '%s\n' ${3:-} ;;
  *) printf '%s\n' ${2:-} ;;
esac"
}

healthy_stubs() {
  write_stub hyprctl 'echo "$HYPRLAND_INSTANCE_SIGNATURE" >"$CALL_LOG.hypr"; echo "Hyprland 0.0.0"'
  write_stub omarchy-shell 'echo "$OMARCHY_PATH" >"$CALL_LOG.shell-path"; echo pong'
  write_stub busctl 'echo "(ssss) \"omarchy\" \"omarchy\" \"1\" \"1.2\""'
  write_stub wpctl 'printf "PipeWire '\''pipewire-0'\''\n └─ Clients:\n        32. WirePlumber\n"'
  write_stub nmcli '[[ $LC_ALL == "C" ]] || exit 3; echo connected'
  systemctl_stub "active active"
  write_stub pacman '[[ $1 == "-Dkq" ]] || exit 3'
  write_stub omarchy-version 'echo 4.0.0'
  # The report never asks for a password or an answer.
  write_stub sudo 'exit 99'
  write_stub gum 'exit 99'
}

# A Unix socket in the scratch runtime directory for each path given, below
# it. A desktop session has the compositor's, the display's and the user bus.
desktop_sockets=(hypr/instance/.socket.sock wayland-1 bus pipewire-0)
make_sockets() {
  rm -rf "$runtime_dir"
  mkdir -p "$runtime_dir"
  (( $# > 0 )) || return 0
  python3 - "$runtime_dir" "$@" <<'PY'
import os, socket, sys
for name in sys.argv[2:]:
    path = os.path.join(sys.argv[1], name)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    socket.socket(socket.AF_UNIX).bind(path)
PY
}

# Runs the report in a desktop session unless told otherwise: $1 is the
# Hyprland instance signature, empty for none. OMARCHY_UPDATE_HEALTH_* in the
# caller's environment are handed on. HEALTH_RUN names a run's own output and
# call log, so runs can go side by side.
run_health() {
  local signature=${1-instance}
  local CALL_LOG="$CALL_LOG${HEALTH_RUN:-}"

  : >"$CALL_LOG"
  rm -f "$CALL_LOG.hypr" "$CALL_LOG.shell-path"
  status=0
  env -i \
    HOME="$test_tmp/home" \
    XDG_CONFIG_HOME="$test_tmp/home/.config" \
    XDG_STATE_HOME="$test_tmp/home/.local/state" \
    XDG_CACHE_HOME="$test_tmp/home/.cache" \
    XDG_RUNTIME_DIR="$runtime_dir" \
    TMPDIR="$test_tmp/tmp" \
    OMARCHY_PATH="$ROOT" \
    CALL_LOG="$CALL_LOG" \
    ${OMARCHY_UPDATE_HEALTH_TIMEOUT+OMARCHY_UPDATE_HEALTH_TIMEOUT=$OMARCHY_UPDATE_HEALTH_TIMEOUT} \
    ${OMARCHY_UPDATE_HEALTH_BASELINE:+OMARCHY_UPDATE_HEALTH_BASELINE=$OMARCHY_UPDATE_HEALTH_BASELINE} \
    ${OMARCHY_UPDATE_HEALTH_SNAPSHOT:+OMARCHY_UPDATE_HEALTH_SNAPSHOT=$OMARCHY_UPDATE_HEALTH_SNAPSHOT} \
    ${signature:+HYPRLAND_INSTANCE_SIGNATURE=$signature} \
    PATH="$health_path" \
    "$ROOT/bin/omarchy-update-health" </dev/null >"$test_tmp/raw${HEALTH_RUN:-}" 2>&1 || status=$?
  sed 's/\x1b\[[0-9;]*m//g' "$test_tmp/raw${HEALTH_RUN:-}" >"$test_tmp/out${HEALTH_RUN:-}"
}

expect_line() {
  local line="$1" description="$2" out="$test_tmp/out${HEALTH_RUN:-}"

  grep -qxF -- "$line" "$out" || fail "$description" "expected: $line"$'\n'"$(cat "$out")"
}

called() {
  grep -q "^$1 " "$CALL_LOG"
}

healthy_stubs
systemctl_stub "active active" "" "" "OMARCHY_PATH=/stale/omarchy OMARCHY_PATH=/session/omarchy"
make_sockets "${desktop_sockets[@]}"
find "$runtime_dir" | sort >"$test_tmp/runtime-before"
run_health
(( status == 0 )) || fail "a healthy system reports success" "status $status"
for line in \
  "  passed   Hyprland" \
  "  passed   Omarchy shell" \
  "  passed   Notifications" \
  "  passed   Audio" \
  "  passed   Network" \
  "  passed   System services" \
  "  passed   User services" \
  "  passed   Package database" \
  "  passed   Omarchy (4.0.0)"; do
  expect_line "$line" "a healthy system passes every probe"
done
! grep -q 'Failed checks' "$test_tmp/out" || fail "a healthy system lists no failed checks" "$(cat "$test_tmp/out")"
grep -q '^systemctl --user --failed ' "$CALL_LOG" && grep -q '^systemctl --failed ' "$CALL_LOG" ||
  fail "a healthy system checks both system and user units" "$(cat "$CALL_LOG")"
grep -q '^omarchy-shell shell ping$' "$CALL_LOG" || fail "the shell probe pings the shell" "$(cat "$CALL_LOG")"
pass "a healthy system passes every probe"

[[ $(cat "$CALL_LOG.shell-path") == "/session/omarchy" ]] ||
  fail "the shell is pinged through the session's OMARCHY_PATH" "$(cat "$CALL_LOG.shell-path")"
pass "the shell is pinged through the checkout the session runs"

grep -q '^busctl --user --auto-start=no call org.freedesktop.Notifications ' "$CALL_LOG" ||
  fail "the notification probe never starts an activatable server" "$(cat "$CALL_LOG")"
pass "the notification probe never starts an activatable server"

! called sudo && ! called gum || fail "the report never asks for a password or an answer" "$(cat "$CALL_LOG")"
[[ -z $(find "$test_tmp/home" "$test_tmp/tmp" -mindepth 1 -print -quit) ]] ||
  fail "the report writes nothing" "$(find "$test_tmp/home" "$test_tmp/tmp")"
diff "$test_tmp/runtime-before" <(find "$runtime_dir" | sort) ||
  fail "the report writes nothing in the runtime directory"
pass "the report never prompts and writes nothing"

# Warnings on stderr, as nmcli prints when NetworkManager was upgraded under
# it, do not fail a probe whose answer is fine.
healthy_stubs
write_stub nmcli 'echo "Warning: nmcli (1.54.0) and NetworkManager (1.52.0) versions don'\''t match." >&2; echo connected'
write_stub systemctl 'case "$*" in *is-active*) printf "active\nactive\n" ;; *--failed*) echo "Warning: The unit file changed on disk." >&2 ;; esac'
make_sockets "${desktop_sockets[@]}"
run_health
expect_line "  passed   Network" "a warning on stderr does not fail the network probe"
expect_line "  passed   System services" "a warning on stderr is not read as a failed unit"
expect_line "  passed   User services" "a warning on stderr is not read as a failed user unit"
pass "only stdout is read as a probe's answer"

healthy_stubs
write_stub omarchy-shell 'echo "omarchy-shell is not running" >&2; exit 1'
write_stub busctl 'echo "Call failed: The name is not activatable" >&2; exit 1'
write_stub wpctl 'echo "PipeWire '\''pipewire-0'\''"'
write_stub nmcli 'echo disconnected'
systemctl_stub "active active" "snapper-cleanup.service\ loaded\ failed\ failed\ Cleanup foo.mount\ loaded\ failed\ failed\ Foo" \
  "waybar.service\ loaded\ failed\ failed\ Bar"
write_stub pacman 'echo "error: missing '\''linux'\'' dependency for '\''mkinitcpio'\''"; exit 1'
write_stub omarchy-version 'exit 1'
make_sockets "${desktop_sockets[@]}"
run_health
(( status == 0 )) || fail "failed probes do not fail the report" "status $status"
expect_line "  passed   Hyprland" "a failing system still passes what works"
expect_line "  failed   Omarchy shell (omarchy-shell is not running)" "a shell that does not answer fails with its reason"
expect_line "  failed   Notifications (Call failed: The name is not activatable)" "a missing notification server fails"
expect_line "  failed   Audio (PipeWire answers, but WirePlumber is not connected)" "PipeWire without WirePlumber fails"
expect_line "  failed   Network (NetworkManager reports disconnected)" "a disconnected network fails with its state"
expect_line "  failed   System services (snapper-cleanup.service foo.mount; these may predate any update)" \
  "without a list from before the update, failed system units fail and may predate it"
expect_line "  failed   User services (waybar.service; these may predate any update)" "failed user units are named"
expect_line "  failed   Package database (error: missing 'linux' dependency for 'mkinitcpio')" "a damaged package database fails with pacman's error"
expect_line "  failed   Omarchy (exited with status 1)" "a missing Omarchy version fails"
expect_line "Failed checks: Omarchy shell, Notifications, Audio, Network, System services, User services, Package database, Omarchy" \
  "the summary names every failed check"
! grep -q 'snapshot' "$test_tmp/out" || fail "without a snapshot from the update, no snapshot is offered" "$(cat "$test_tmp/out")"
pass "failed probes are named with their reasons"

OMARCHY_UPDATE_HEALTH_SNAPSHOT=0 run_health
! grep -q 'snapshot' "$test_tmp/out" || fail "an update that took no snapshot offers none" "$(cat "$test_tmp/out")"
OMARCHY_UPDATE_HEALTH_SNAPSHOT=1 run_health
expect_line "If the update left the system broken, reboot, pick the snapshot from before it in the Limine menu, then run omarchy snapshot restore." \
  "an update that took a snapshot points at restoring it from the Limine menu"
pass "the way back through the snapshot is offered only when the update took one"

# Units that had already failed before the update are noted, not failed.
mkdir -p "$test_tmp/baseline"
printf '%s\n' snapper-cleanup.service >"$test_tmp/baseline/system"
: >"$test_tmp/baseline/user"
OMARCHY_UPDATE_HEALTH_BASELINE="$test_tmp/baseline" run_health
expect_line "  failed   System services (foo.mount)" "a unit that failed during the update fails"
expect_line "  noted    System services (already failed before the update: snapper-cleanup.service)" \
  "a unit that had already failed is noted"
expect_line "  failed   User services (waybar.service)" "a user unit that failed during the update fails"
systemctl_stub "active active" "snapper-cleanup.service\ loaded\ failed\ failed\ Cleanup"
OMARCHY_UPDATE_HEALTH_BASELINE="$test_tmp/baseline" run_health
expect_line "  passed   System services" "only units that had already failed do not fail the check"
expect_line "  noted    System services (already failed before the update: snapper-cleanup.service)" \
  "a unit that had already failed is still shown"
! grep -q 'System services' <(grep '^Failed checks' "$test_tmp/out") ||
  fail "a unit that had already failed is not a failed check" "$(cat "$test_tmp/out")"
pass "units that had failed before the update are noted apart from ones that failed during it"

# Every probe runs whatever Hyprland says: the shell and notifications need
# only the Wayland display and the user bus.
healthy_stubs
write_stub hyprctl 'echo "Couldn'\''t connect to the Hyprland socket" >&2; exit 4'
make_sockets "${desktop_sockets[@]}"
run_health
expect_line "  failed   Hyprland (Couldn't connect to the Hyprland socket)" "a Hyprland that does not answer fails"
expect_line "  passed   Omarchy shell" "the shell is still pinged when Hyprland does not answer"
expect_line "  passed   Notifications" "notifications are still checked when Hyprland does not answer"
pass "a Hyprland that does not answer does not hide the probes after it"

# A signature left over from an earlier session, or none at all, is replaced
# by the newest instance whose socket is still there.
healthy_stubs
make_sockets hypr/older/.socket.sock hypr/live/.socket.sock hypr/stale/.socket2.sock wayland-1 bus pipewire-0
touch -h -d '2 hours ago' "$runtime_dir/hypr/older/.socket.sock"
touch -h -d '1 hour ago' "$runtime_dir/hypr/live/.socket.sock"
for signature in stale ""; do
  run_health "$signature"
  expect_line "  passed   Hyprland" "a ${signature:-missing} signature finds the running instance"
  [[ $(cat "$CALL_LOG.hypr") == "live" ]] ||
    fail "a ${signature:-missing} signature asks the newest instance with a socket" "$(cat "$CALL_LOG.hypr")"
done
pass "a stale or missing signature finds the running Hyprland instance"

# A TTY or SSH login has the socket-activated PipeWire socket and the user bus,
# but no desktop, and PipeWire not running. Nothing that needs those is asked,
# and nothing is started by asking.
healthy_stubs
systemctl_stub "inactive inactive"
make_sockets bus pipewire-0
run_health ""
(( status == 0 )) || fail "an update from a TTY reports success" "status $status"
for line in \
  "  skipped  Hyprland (no Hyprland session)" \
  "  skipped  Omarchy shell (no Wayland session)" \
  "  skipped  Notifications (no Wayland session)" \
  "  skipped  Audio (PipeWire is not running)" \
  "  passed   Network" \
  "  passed   System services" \
  "  passed   User services" \
  "  passed   Package database"; do
  expect_line "$line" "a TTY update skips what needs the desktop and checks the rest"
done
! grep -q 'Failed checks' "$test_tmp/out" || fail "skipped probes are not failures" "$(cat "$test_tmp/out")"
for command in hyprctl omarchy-shell busctl wpctl; do
  ! called "$command" || fail "a TTY update does not run $command" "$(cat "$CALL_LOG")"
done
pass "a TTY login's sockets do not make the report start PipeWire or ask for a desktop"

make_sockets
run_health ""
expect_line "  skipped  Audio (no user bus)" "without a user bus, audio is skipped"
expect_line "  skipped  User services (no user bus)" "without a user bus, user units are skipped"
! grep -q '^systemctl --user ' "$CALL_LOG" || fail "without a user bus the user manager is not asked" "$(cat "$CALL_LOG")"
pass "without a user bus, the probes that need it are skipped"

healthy_stubs
systemctl_stub "failed inactive"
make_sockets "${desktop_sockets[@]}"
run_health
expect_line "  failed   Audio (pipewire.service is failed, wireplumber.service is inactive)" "a failed PipeWire fails"
systemctl_stub "active inactive"
run_health
expect_line "  failed   Audio (PipeWire is running, but WirePlumber is not)" "PipeWire without its session manager fails"
! called wpctl || fail "PipeWire that is not fully running is not asked" "$(cat "$CALL_LOG")"
pass "a failed or half-running audio stack fails without being asked"

# A probed command that is missing fails with the reason and the rest still run.
healthy_stubs
rm "$stub_bin/pacman"
make_sockets "${desktop_sockets[@]}"
health_path="$stub_bin:$tools_bin"
run_health
health_path="$stub_bin:$ROOT/bin:/usr/bin:/bin"
(( status == 0 )) || fail "a missing command does not fail the report" "status $status"
grep -qE '^  failed   Package database \(.*pacman.*\)$' "$test_tmp/out" ||
  fail "a missing command fails its probe and names it" "$(cat "$test_tmp/out")"
expect_line "  passed   Omarchy (4.0.0)" "the probes after a missing command still run"
pass "a missing command fails its probe and the rest still run"

# A wedged service is reported once the probe timeout runs out, not waited on.
# A timeout of 0 would wait forever, and one that is not a number would fail
# every probe; both fall back to the default. Those fallback runs each wait
# the full default out, so all four runs go side by side, each with its own
# output, call log, status and duration.
healthy_stubs
write_stub nmcli 'exec sleep 30'
make_sockets "${desktop_sockets[@]}"
cp -a "$stub_bin" "$test_tmp/bin-fallback"
write_stub pacman 'trap "" TERM; sleep 30'

timed_run() {
  local run="$1" timeout="$2" start=$SECONDS

  HEALTH_RUN="-$run" OMARCHY_UPDATE_HEALTH_TIMEOUT=$timeout run_health
  echo "$status $((SECONDS - start))" >"$test_tmp/result-$run"
}

timed_run hang 1 &
for timeout in 0 abc 1x; do
  health_path="$test_tmp/bin-fallback:$ROOT/bin:/usr/bin:/bin" timed_run "fallback-$timeout" "$timeout" &
done
wait

HEALTH_RUN=-hang
read -r status took <"$test_tmp/result-hang"
(( took < 10 )) || fail "probes that hang are cut off at the timeout" "took ${took}s"
(( status == 0 )) || fail "a probe that times out does not fail the report" "status $status"
expect_line "  failed   Network (no answer within 1s)" "a probe that hangs fails with the timeout"
expect_line "  failed   Package database (no answer within 1s)" "a probe that ignores TERM is still cut off"
expect_line "  passed   System services" "the probes after a timeout still run"
pass "a probe that hangs fails at the timeout and the rest still run"

for timeout in 0 abc 1x; do
  HEALTH_RUN="-fallback-$timeout"
  read -r status took <"$test_tmp/result-fallback-$timeout"
  (( took < 15 )) || fail "a timeout of $timeout still cuts a hanging probe off" "took ${took}s"
  expect_line "  failed   Network (no answer within 5s)" "a timeout of $timeout falls back to 5 seconds"
  expect_line "  passed   Package database" "a timeout of $timeout does not fail the probes that answer"
done
unset HEALTH_RUN
pass "a timeout that is not a positive number falls back to the default"
