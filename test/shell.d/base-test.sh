#!/bin/bash

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  echo "source test/shell.d/base-test.sh from a shell test; do not run it directly" >&2
  exit 1
fi

# Physical, so a checkout reached through a symlink still passes commands that
# refuse a non-canonical source root.
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)
SHELL_TEST_DIR="$ROOT/test/shell.d"

export ROOT

# Commands under test belong to this checkout, never to the one the running
# session points OMARCHY_PATH at; the agent usage collectors load their
# shared module from it.
export OMARCHY_PATH=$ROOT

# Commands print user-facing text in the language picked under Setup >
# Language, so pin tests to English (a missing file means English) rather than
# whatever the machine running them is set to. Tests of other languages point
# this at a file of their own.
export OMARCHY_LANGUAGE_FILE=$ROOT/test/.no-language

# Tests point HOME at a scratch directory, but a desktop session also exports
# the XDG base directories, which would keep pointing at the real home: a
# migration under test would then edit or delete the user's own files. Unset,
# they follow HOME. A test that wants one sets it itself.
unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

# Run from inside an agent session, the agent's own account home would leak
# into tests of agent accounts the same way.
unset CLAUDE_CONFIG_DIR CODEX_HOME GROK_HOME OMARCHY_AGENT_CLAUDE_HOME OMARCHY_AGENT_CODEX_HOME OMARCHY_AGENT_GROK_HOME

pass() {
  printf 'ok - %s\n' "$1"
}

skip() {
  printf 'ok - %s # SKIP\n' "$1"
}

fail() {
  local description="$1"
  local detail="${2:-}"

  [[ -n $detail ]] && printf '%s\n' "$detail" >&2
  printf 'not ok - %s\n' "$description" >&2
  exit 1
}

# The IPC socket a shell running an OMARCHY_PATH's config on this display
# serves, derived as omarchy-shell derives it. A test that starts the real
# shell removes it afterwards: killing the shell leaves the file behind.
shell_ipc_socket() {
  local id
  id=$(printf '%s\n%s' "$1/shell" "${WAYLAND_DISPLAY:-}" | md5sum)
  printf '%s/omarchy-shell-%s.sock\n' "${XDG_RUNTIME_DIR:-/run/user/$UID}" "${id:0:16}"
}

require_command() {
  local command="$1"

  command -v "$command" >/dev/null || fail "required command is available: $command"
}

# WAYLAND_DISPLAY proves the variable was inherited, not that the compositor
# answers. Sandboxes pass the environment through while blocking
# $XDG_RUNTIME_DIR, so Quickshell clears a bare variable check and then aborts
# inside QGuiApplication, before any QML loads: a core dump per launch where a
# skip belonged. Probe the socket, then Hyprland itself, since a compositor that
# died mid-session can leave its socket behind.
compositor_reachable() {
  local socket=${WAYLAND_DISPLAY:-}

  [[ -n $socket ]] || return 1
  [[ $socket == /* ]] || socket=${XDG_RUNTIME_DIR:-}/$socket
  [[ -S $socket ]] || return 1

  # A compositor that died can leave its socket behind, so ask Hyprland whether
  # it is still answering. Only when it can be asked: hyprctl needs
  # HYPRLAND_INSTANCE_SIGNATURE, and treating a missing signature as a dead
  # compositor would skip tests that would have run fine.
  [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] || return 0

  # Hyprland can miss a query while it reconfigures outputs, and one miss is not
  # a dead compositor; retry the way omarchy-launch-shell does rather than
  # discard a whole file's runtime coverage. Only a leftover socket gets this
  # far, so the waiting is rare.
  local attempt
  for attempt in 1 2 3; do
    hyprctl -j monitors >/dev/null 2>&1 && return 0
    (( attempt < 3 )) && sleep 0.5
  done

  return 1
}

require_compositor() {
  local description="$1"

  if compositor_reachable; then
    # No probe outruns a compositor that dies mid-run, and Quickshell leaves
    # through qFatal() when its connection drops. Keep that abort from writing a
    # core; the test still fails, just without the debris.
    ulimit -c 0 2>/dev/null || true
    return 0
  fi

  skip "no Wayland compositor; skipping $description"
  exit 0
}

# For a test that starts Quickshell: a reachable compositor, quickshell itself
# and jq to read what it reports. Skips the rest of the file without the first
# two.
require_quickshell() {
  local description="$1"

  require_compositor "$description"
  if ! command -v quickshell >/dev/null 2>&1; then
    skip "quickshell not installed; skipping $description"
    exit 0
  fi
  require_command jq
}

QML_FIXTURE_TMP=""
QML_FIXTURE_PID=""
QML_FIXTURE_LOG=""

qml_fixture_cleanup() {
  if [[ -n $QML_FIXTURE_PID ]] && kill -0 "$QML_FIXTURE_PID" 2>/dev/null; then
    kill "$QML_FIXTURE_PID" 2>/dev/null || true
    wait "$QML_FIXTURE_PID" 2>/dev/null || true
  fi
  QML_FIXTURE_PID=""
  [[ -n $QML_FIXTURE_TMP && -d $QML_FIXTURE_TMP ]] && rm -rf "$QML_FIXTURE_TMP"
  return 0
}

# The scratch directory a QML fixture runs in: home/ is its HOME, and bin/ goes
# ahead of PATH for stubs. Created on first call, and removed along with the
# fixture's Quickshell on exit. A test that needs more cleanup sets its own EXIT
# trap after this and calls qml_fixture_cleanup from it.
qml_fixture_scratch() {
  [[ -n $QML_FIXTURE_TMP ]] && return 0
  QML_FIXTURE_TMP=$(mktemp -d)
  mkdir -p "$QML_FIXTURE_TMP/home" "$QML_FIXTURE_TMP/bin"
  trap qml_fixture_cleanup EXIT
}

# Runs test/shell.d/fixtures/<fixture>/*.qml as a Quickshell config, with each
# further argument (Ui, Commons, services) linked in from $ROOT/shell, and
# passes when the fixture writes {"ok": true} to $OMARCHY_QML_TEST_RESULT.
# Fails with the fixture's result and log otherwise. Extra environment for the
# fixture goes before the call (FOO=bar run_qml_fixture ...). Quickshell keeps
# running until exit, and its log stays at $QML_FIXTURE_LOG for later checks.
run_qml_fixture() {
  local fixture="$1" description="$2"
  shift 2
  local config_dir result link

  qml_fixture_scratch
  # A second fixture in the same file must not read the first one's result.
  if [[ -n $QML_FIXTURE_PID ]] && kill -0 "$QML_FIXTURE_PID" 2>/dev/null; then
    kill "$QML_FIXTURE_PID" 2>/dev/null || true
    wait "$QML_FIXTURE_PID" 2>/dev/null || true
  fi
  config_dir="$QML_FIXTURE_TMP/$fixture"
  result="$QML_FIXTURE_TMP/result.json"
  QML_FIXTURE_LOG="$QML_FIXTURE_TMP/quickshell.log"
  rm -f "$result"
  mkdir -p "$config_dir"
  cp "$SHELL_TEST_DIR/fixtures/$fixture/"*.qml "$config_dir/"
  for link in "$@"; do
    ln -s "$ROOT/shell/$link" "$config_dir/$link"
  done

  OMARCHY_PATH="$ROOT" \
  OMARCHY_QML_TEST_RESULT="$result" \
  HOME="$QML_FIXTURE_TMP/home" \
  XDG_CONFIG_HOME="$QML_FIXTURE_TMP/home/.config" \
  XDG_CACHE_HOME="$QML_FIXTURE_TMP/home/.cache" \
  XDG_STATE_HOME="$QML_FIXTURE_TMP/home/.local/state" \
  QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  PATH="$QML_FIXTURE_TMP/bin:$ROOT/bin:$PATH" \
    quickshell -p "$config_dir" --no-color >"$QML_FIXTURE_LOG" 2>&1 &
  QML_FIXTURE_PID=$!

  for _ in {1..150}; do
    [[ -s $result ]] && break
    if ! kill -0 "$QML_FIXTURE_PID" 2>/dev/null; then
      sed -n '1,220p' "$QML_FIXTURE_LOG" >&2
      fail "$description" "The $fixture fixture exited before writing a result."
    fi
    sleep 0.1
  done

  if [[ ! -s $result ]]; then
    sed -n '1,220p' "$QML_FIXTURE_LOG" >&2
    fail "$description" "The $fixture fixture timed out."
  fi

  if ! jq -e '.ok == true' "$result" >/dev/null; then
    printf '%s result:\n' "$fixture" >&2
    jq . "$result" >&2
    printf '%s log:\n' "$fixture" >&2
    sed -n '1,220p' "$QML_FIXTURE_LOG" >&2
    fail "$description"
  fi

  pass "$description"
}

# A second Omarchy shell on a scratch copy of this checkout's shell/, with a
# scratch HOME, for tests that drive or time the real shell. setup_scratch_shell
# builds it and sets SCRATCH_ROOT (its OMARCHY_PATH), SCRATCH_HOME, SCRATCH_BIN
# (stubs, ahead of PATH) and SCRATCH_LOG; start_scratch_shell launches it and
# sets SCRATCH_PID; scratch_ipc talks to it. It is stopped and removed on exit.
SCRATCH_DIR=""
SCRATCH_ROOT=""
SCRATCH_HOME=""
SCRATCH_BIN=""
SCRATCH_LOG=""
SCRATCH_PID=""

setup_scratch_shell() {
  SCRATCH_DIR=$(mktemp -d)
  SCRATCH_ROOT="$SCRATCH_DIR/omarchy"
  SCRATCH_HOME="$SCRATCH_DIR/home"
  SCRATCH_BIN="$SCRATCH_DIR/bin"
  SCRATCH_LOG="$SCRATCH_DIR/quickshell.log"
  trap scratch_shell_cleanup EXIT

  mkdir -p "$SCRATCH_ROOT" "$SCRATCH_BIN"
  cp -a "$ROOT/shell" "$SCRATCH_ROOT/shell"
  ln -s "$ROOT/config" "$SCRATCH_ROOT/config"
  ln -s "$ROOT/bin" "$SCRATCH_ROOT/bin"
  ln -s "$ROOT/default" "$SCRATCH_ROOT/default"
  reset_scratch_home

  # The scratch shell must not reach the real session: the clipboard plugin
  # cleans up stale watchers at startup with a pkill whose pattern also
  # matches the session shell's watchers (the idle-spawn test stubs the
  # same commands for the same reason).
  local name
  for name in pkill killall; do
    printf '#!/bin/bash\nexit 1\n' >"$SCRATCH_BIN/$name"
    chmod +x "$SCRATCH_BIN/$name"
  done
  # Nor may it change system state over D-Bus: the battery service applies a
  # power profile when UPower reports one.
  for name in omarchy-powerprofiles-set powerprofilesctl; do
    printf '#!/bin/bash\nexit 0\n' >"$SCRATCH_BIN/$name"
    chmod +x "$SCRATCH_BIN/$name"
  done
  # The shell runs some commands under `bash -lc`, and a login shell resets
  # PATH and OMARCHY_PATH from /etc/omarchy.conf, which would put the
  # session's checkout and its real commands back ahead of these stubs.
  printf '#!/bin/bash\n[[ ${1:-} == "-lc" ]] && shift && set -- -c "$@"\nexec /bin/bash "$@"\n' >"$SCRATCH_BIN/bash"
  chmod +x "$SCRATCH_BIN/bash"
}

# An empty scratch HOME, for a cold start: a launch writes session state (the
# background-intro marker, caches) that later launches read and skip
# first-login work for. Nobody touches the seat during a run, so without
# stay-awake the scratch shell's idle service would eventually screensave or
# lock the real desktop.
reset_scratch_home() {
  rm -rf "$SCRATCH_HOME"
  mkdir -p "$SCRATCH_HOME/.local/state/omarchy/indicators"
  touch "$SCRATCH_HOME/.local/state/omarchy/indicators/stay-awake"
}

# Replaces the current (sub)shell with a command in the scratch shell's
# environment, so a backgrounded (scratch_exec ...) & leaves $! naming the
# command itself.
scratch_exec() {
  export OMARCHY_PATH="$SCRATCH_ROOT"
  export HOME="$SCRATCH_HOME"
  export XDG_CONFIG_HOME="$SCRATCH_HOME/.config"
  export XDG_CACHE_HOME="$SCRATCH_HOME/.cache"
  export XDG_STATE_HOME="$SCRATCH_HOME/.local/state"
  export PATH="$SCRATCH_BIN:$ROOT/bin:$PATH"
  exec "$@"
}

start_scratch_shell() {
  (scratch_exec quickshell -p "$SCRATCH_ROOT/shell" --no-color) >"$SCRATCH_LOG" 2>&1 &
  SCRATCH_PID=$!
}

scratch_ipc() {
  OMARCHY_PATH="$SCRATCH_ROOT" "$ROOT/bin/omarchy-shell" "$@"
}

scratch_ipc_quiet() {
  OMARCHY_PATH="$SCRATCH_ROOT" "$ROOT/bin/omarchy-shell" -q "$@"
}

# Waits until the scratch shell answers IPC, failing with its log when it
# exits or never answers.
wait_scratch_shell() {
  for _ in {1..80}; do
    # Not the quiet form: -q succeeds even when no shell answers.
    [[ $(scratch_ipc shell ping 2>/dev/null || true) == "ok" ]] && return 0
    kill -0 "$SCRATCH_PID" 2>/dev/null || break
    sleep 0.1
  done
  sed -n '1,120p' "$SCRATCH_LOG" >&2
  fail "scratch shell answers IPC"
}

# mapped|absent|unknown for the scratch shell's layer surface <namespace>:
# mapped only at a real size, and a failed compositor query proves nothing, so
# an absent verdict only comes from a query that answered.
scratch_layer_state() {
  local namespace="$1" layers

  layers=$(hyprctl -j layers 2>/dev/null) || { echo unknown; return; }
  [[ -n $layers ]] || { echo unknown; return; }
  if jq -e --arg namespace "$namespace" --argjson pid "$SCRATCH_PID" '
    [.. | objects | select(.namespace? == $namespace and .pid == $pid and .w > 0 and .h > 0)] | length > 0
  ' <<<"$layers" >/dev/null 2>&1; then
    echo mapped
  else
    echo absent
  fi
}

# Polls every 10ms, up to 3s, until <namespace> is <mapped|absent>.
wait_scratch_layer() {
  local namespace="$1" want="$2"

  for _ in {1..300}; do
    [[ $(scratch_layer_state "$namespace") == "$want" ]] && return 0
    kill -0 "$SCRATCH_PID" 2>/dev/null || return 1
    sleep 0.01
  done
  return 1
}

# Quickshell leaves some of its children running when it is stopped, among them
# the inotifywait watching the plugin directory, which then holds whatever it
# inherited open (a flock around the run, say) indefinitely. Once the shell is
# stopped, stop whatever still runs with the scratch OMARCHY_PATH: every child
# inherits it, and it finds the ones a shell that already died left
# reparented. The environment is read afresh before every signal, so a pid
# that has since been reused by something else is never sent one.
scratch_leftover_pids() {
  local environ pid

  [[ -n $SCRATCH_ROOT ]] || return 0
  while IFS= read -r environ; do
    pid=${environ#/proc/}
    echo "${pid%/environ}"
  done < <(grep -lzxF -- "OMARCHY_PATH=$SCRATCH_ROOT" /proc/[0-9]*/environ 2>/dev/null || true)
}

signal_scratch_leftovers() {
  local leftovers=()

  mapfile -t leftovers < <(scratch_leftover_pids)
  (( ${#leftovers[@]} > 0 )) || return 1
  kill "$1" "${leftovers[@]}" 2>/dev/null || true
}

# TERM, a few seconds' grace, then KILL, so nothing that ignores TERM can hang
# the run. Bash can reap the shell, and free its pid, before it is waited for,
# so the shell gets KILL only while it was still seen running.
stop_scratch_shell() {
  local alive

  if [[ -n $SCRATCH_PID ]] && kill -0 "$SCRATCH_PID" 2>/dev/null; then
    kill "$SCRATCH_PID" 2>/dev/null || true
    alive=1
    for _ in {1..30}; do
      if ! kill -0 "$SCRATCH_PID" 2>/dev/null; then
        alive=0
        break
      fi
      sleep 0.1
    done
    (( alive == 0 )) || kill -KILL "$SCRATCH_PID" 2>/dev/null || true
    wait "$SCRATCH_PID" 2>/dev/null || true
  fi
  SCRATCH_PID=""
  if signal_scratch_leftovers -TERM; then
    for _ in {1..30}; do
      [[ -n $(scratch_leftover_pids) ]] || break
      sleep 0.1
    done
    signal_scratch_leftovers -KILL || true
  fi
  [[ -n $SCRATCH_ROOT ]] && rm -f "$(shell_ipc_socket "$SCRATCH_ROOT")"
  return 0
}

scratch_shell_cleanup() {
  stop_scratch_shell
  [[ -n $SCRATCH_DIR && -d $SCRATCH_DIR ]] && rm -rf "$SCRATCH_DIR"
  return 0
}

# Finds the pkgbuilds/ directory of the omarchy-pkgs checkout, which some tests
# hold Omarchy's scripts against, and sets OMARCHY_PKGS_ROOT to it. The checkout
# lives in its own repository, wherever this machine keeps it.
#
# OMARCHY_PKGS_PATH names it outright (the checkout or its pkgbuilds/), and then
# nothing else is tried: an override that doesn't resolve fails the test, so a
# typo can't quietly turn the package checks into skips. Without the override,
# the usual places beside this checkout are tried, and finding none returns 1 so
# the test can skip what needs one.
find_omarchy_pkgs() {
  local candidate
  local -a candidates pkgbuilds

  if [[ -n ${OMARCHY_PKGS_PATH:-} ]]; then
    candidates=("$OMARCHY_PKGS_PATH/pkgbuilds" "$OMARCHY_PKGS_PATH")
  else
    candidates=(
      "$ROOT/../omarchy-pkgs/pkgbuilds"
      "$ROOT/../omarchy/omarchy-pkgs/pkgbuilds"
      "$ROOT/../../omarchy-pkgs/pkgbuilds"
      "$ROOT/../omacom/omarchy-pkgs/pkgbuilds"
      "$ROOT/../../omacom/omarchy-pkgs/pkgbuilds"
      "$HOME/Work/omacom/omarchy-pkgs/pkgbuilds"
    )
  fi

  for candidate in "${candidates[@]}"; do
    # Only */PKGBUILD is a pattern; the checkout's own path stays literal.
    pkgbuilds=("$candidate"/*/PKGBUILD)
    if [[ -f ${pkgbuilds[0]:-} ]]; then
      OMARCHY_PKGS_ROOT=$(CDPATH= cd -- "$candidate" && pwd)
      return 0
    fi
  done

  [[ -z ${OMARCHY_PKGS_PATH:-} ]] ||
    fail "OMARCHY_PKGS_PATH names an omarchy-pkgs checkout" "no */PKGBUILD under $OMARCHY_PKGS_PATH or its pkgbuilds/"
  return 1
}

# Fake the hardware identity omarchy-hw-platform reads: a device tree under
# $1/proc and a uname in $1/bin reporting the platform's CPU. Run the code under
# test with OMARCHY_PROC_ROOT="$1/proc" and PATH="$1/bin:$ROOT/bin:...", so the
# real detector and its wrappers answer from the fixture.
fake_platform() {
  local dir="$1" platform="$2" machine=aarch64
  local -a compatible=()

  case $platform in
    aarch64-apple) compatible=(apple,j416c apple,t6021 apple,arm-platform) ;;
    aarch64-qualcomm) compatible=(lenovo,yoga-slim7x qcom,x1e80100) ;;
    aarch64) compatible=(raspberrypi,5-model-b brcm,bcm2712) ;;
    x86) machine=x86_64 ;;
    *) fail "fake_platform knows the platform $platform" ;;
  esac

  rm -rf "$dir/proc"
  mkdir -p "$dir/proc" "$dir/bin"
  if (( ${#compatible[@]} > 0 )); then
    mkdir -p "$dir/proc/device-tree"
    printf '%s\0' "${compatible[@]}" >"$dir/proc/device-tree/compatible"
  fi

  cat >"$dir/bin/uname" <<SH
#!/bin/bash
[[ \${1:-} == -m ]] && { printf '%s\\n' $machine; exit 0; }
exec /usr/bin/uname "\$@"
SH
  chmod +x "$dir/bin/uname"
}

# omarchy-hw-platform ignores fixture roots when it runs as root, so a root run
# cannot fake a platform. Skip the rest of the file there.
require_platform_fixtures() {
  (( EUID != 0 )) && return 0
  skip "running as root, where omarchy-hw-platform ignores fixtures; skipping $1"
  exit 0
}

# A script reads the installed platform package's files from the fixed
# /usr/share/omarchy-platform, which nothing in its environment moves. Copies
# script $1 to $2 reading fixture root $3 instead (a directory that doesn't
# exist stands for no platform package), the way the security tests rewrite
# other fixed paths.
platform_root_copy() {
  local script="$1" copy="$2" fixture="$3"

  sed -e "s|/usr/share/omarchy-platform|$fixture|g" "$script" >"$copy" &&
    chmod +x "$copy" || fail "copy $script for a fixture platform root"
  grep -qF -- "$fixture" "$copy" && ! grep -qF /usr/share/omarchy-platform "$copy" ||
    fail "$(basename -- "$script") reads the platform root from the fixture"
}

# How long this machine takes to start processes, as a percentage of the
# laptop the timing budgets were measured on (100 there, never less): the
# fastest of three runs of 100 fork/execs of true, against the 25ms they take
# on that laptop. A test timing process-heavy work multiplies its budget by
# this, so a Raspberry Pi or an ARM VM gets the room its slower process starts
# need, and only what is still several times over fails.
process_speed_percent() {
  local best="" start end elapsed

  for _ in 1 2 3; do
    start=$EPOCHREALTIME
    for _ in {1..100}; do /usr/bin/true; done
    end=$EPOCHREALTIME
    elapsed=$(( ${end/[.,]/} - ${start/[.,]/} ))
    if [[ -z $best ]] || (( elapsed < best )); then
      best=$elapsed
    fi
  done
  echo $(( best > 25000 ? best * 100 / 25000 : 100 ))
}

# Sets SPEED_PERCENT for a timing test, skipping the rest of the file when the
# machine is so much slower than the reference that a budget scaled to it
# could no longer tell a regression from the machine.
require_comparable_speed() {
  SPEED_PERCENT=$(process_speed_percent)
  (( SPEED_PERCENT <= 800 )) && return 0
  skip "processes start $(( SPEED_PERCENT / 100 ))x slower than on the reference laptop; skipping $1"
  exit 0
}

run_node_test() {
  require_command node

  {
    cat <<'JS_PRELUDE'
const path = require('path')
const root = process.env.ROOT

function fail(description, detail) {
  if (detail) console.error(detail)
  console.error(`not ok - ${description}`)
  process.exit(1)
}

function pass(description) {
  console.log(`ok - ${description}`)
}

function assert(condition, description, detail) {
  if (!condition) fail(description, detail)
  pass(description)
}

function assertEqual(actual, expected, description) {
  assert(
    actual === expected,
    description,
    `expected: ${expected}\nactual:   ${actual}`
  )
}

function assertDeepEqual(actual, expected, description) {
  const actualJson = JSON.stringify(actual)
  const expectedJson = JSON.stringify(expected)
  assert(
    actualJson === expectedJson,
    description,
    `expected: ${expectedJson}\nactual:   ${actualJson}`
  )
}

function requireFromRoot(relativePath) {
  return require(path.join(root, relativePath))
}

JS_PRELUDE
    cat
  } | node
}
