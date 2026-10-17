#!/bin/bash

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  echo "source test/shell.d/base-test.sh from a shell test; do not run it directly" >&2
  exit 1
fi

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
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
