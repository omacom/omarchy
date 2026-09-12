#!/bin/bash

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  echo "source test/shell.d/base-test.sh from a shell test; do not run it directly" >&2
  exit 1
fi

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
SHELL_TEST_DIR="$ROOT/test/shell.d"

export ROOT

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  local description="$1"
  local detail="${2:-}"

  [[ -n $detail ]] && printf '%s\n' "$detail" >&2
  printf 'not ok - %s\n' "$description" >&2
  exit 1
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

  pass "no Wayland compositor; skipping $description"
  exit 0
}

# Build a /sys/bus/pci/devices fixture tree at $1 so scripts that read cached
# sysfs PCI IDs (instead of lspci) can be tested. Remaining arguments are PCI
# devices as "vendor:device:class", in sysfs's own 0x-prefixed format.
write_pci_devices() {
  local dir="$1"
  shift
  rm -rf "$dir"
  mkdir -p "$dir"

  local index=0
  local spec
  for spec in "$@"; do
    local slot
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$dir/$slot"
    printf '%s\n' "${spec%%:*}" >"$dir/$slot/vendor"
    printf '%s\n' "$(cut -d: -f2 <<<"$spec")" >"$dir/$slot/device"
    printf '%s\n' "${spec##*:}" >"$dir/$slot/class"
    index=$((index + 1))
  done
}

# Bind the device at the given slot to a driver, creating the driver symlink a
# sysfs driver check reads. $1 is the fixture devices dir, $2 the slot, $3 the
# driver name.
bind_pci_driver() {
  local dir="$1" slot="$2" driver="$3"
  mkdir -p "$dir/$slot"
  ln -s "/sys/bus/pci/drivers/$driver" "$dir/$slot/driver"
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
