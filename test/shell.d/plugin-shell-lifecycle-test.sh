#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""

cleanup() {
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  [[ -n $TMPDIR && -d $TMPDIR ]] && rm -rf "$TMPDIR"
  return 0
}
trap cleanup EXIT

require_compositor "plugin shell lifecycle test"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping plugin shell lifecycle test"
  exit 0
fi

require_command jq

shell_ipc() {
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" "$@"
}

shell_ipc_quiet() {
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" -q "$@"
}

fail_with_log() {
  local description=$1
  sed -n '1,240p' "$log" >&2
  fail "$description"
}

TMPDIR=$(mktemp -d)
test_root="$TMPDIR/omarchy"
test_home="$TMPDIR/home"
log="$TMPDIR/quickshell.log"
mkdir -p "$test_root" "$test_home"
cp -a "$ROOT/shell" "$test_root/shell"
ln -s "$ROOT/config" "$test_root/config"
ln -s "$ROOT/bin" "$test_root/bin"

probe_id="acme.probe-bar"
probe_dir="$test_home/.config/omarchy/plugins/$probe_id"
mkdir -p "$probe_dir"
cat >"$probe_dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$probe_id",
  "name": "Probe Bar",
  "version": "1.0.0",
  "kinds": ["bar", "panel"],
  "keepLoaded": true,
  "entryPoints": {"bar": "Bar.qml", "panel": "Panel.qml"}
}
JSON

# Reports, separately, what survives each hop a real third-party plugin uses:
# the bar property injection (barConfig), the scoped shell API's barConfig
# snapshot, mutation, and persistence to shell.json on disk.
cat >"$probe_dir/Bar.qml" <<'QML'
import QtQuick
import Quickshell.Io

Item {
  id: root

  property var shell: null
  property var barConfig: null
  property var manifest: null

  function layoutArrays(value) {
    return value && value.layout !== undefined
      && Array.isArray(value.layout.left)
      && Array.isArray(value.layout.center)
      && Array.isArray(value.layout.right)
  }

  IpcHandler {
    target: "acme-probe-bar"

    function state(): string {
      var apiConfig = root.shell && root.shell.barConfig !== undefined
        ? root.shell.barConfig : null
      return JSON.stringify({
        shellAlive: root.shell !== null && root.shell !== undefined,
        propLayoutArrays: root.layoutArrays(root.barConfig),
        apiLayoutArrays: root.layoutArrays(apiConfig),
        manifestKinds: root.manifest && Array.isArray(root.manifest.kinds)
      })
    }

    function mutate(mark: string): string {
      if (!root.shell || typeof root.shell.mutateShellConfig !== "function")
        return "no-api"
      return root.shell.mutateShellConfig(function(config) {
        if (!config.bar) config.bar = {}
        config.bar.probeMark = mark
      }) ? "ok" : "refused"
    }
  }
}
QML

# A keepLoaded panel: receives the same injections and must keep a working
# shell reference across plugin rescans, since it is never re-created.
cat >"$probe_dir/Panel.qml" <<'QML'
import QtQuick
import Quickshell.Io

Item {
  id: root

  property var shell: null
  property var manifest: null

  function layoutArrays(value) {
    return value && value.layout !== undefined
      && Array.isArray(value.layout.left)
      && Array.isArray(value.layout.center)
      && Array.isArray(value.layout.right)
  }

  function open(payloadJson) {}
  function close() {}

  IpcHandler {
    target: "acme-probe-panel"

    function state(): string {
      var apiConfig = root.shell && root.shell.barConfig !== undefined
        ? root.shell.barConfig : null
      return JSON.stringify({
        shellAlive: root.shell !== null && root.shell !== undefined,
        apiLayoutArrays: root.layoutArrays(apiConfig),
        manifestKinds: root.manifest && Array.isArray(root.manifest.kinds)
      })
    }

    function mutate(mark: string): string {
      if (!root.shell || typeof root.shell.mutateShellConfig !== "function")
        return "no-api"
      return root.shell.mutateShellConfig(function(config) {
        if (!config.bar) config.bar = {}
        config.bar.probeMark = mark
      }) ? "ok" : "refused"
    }
  }
}
QML

cat >"$test_home/.config/omarchy/shell.json" <<JSON
{
  "version": 1,
  "bar": {
    "id": "$probe_id",
    "layout": {"left": [], "center": [], "right": []}
  },
  "plugins": []
}
JSON

OMARCHY_PATH="$test_root" \
HOME="$test_home" \
XDG_CONFIG_HOME="$test_home/.config" \
XDG_CACHE_HOME="$test_home/.cache" \
XDG_STATE_HOME="$test_home/.local/state" \
PATH="$ROOT/bin:$PATH" \
  quickshell -p "$test_root/shell" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..80}; do
  if shell_ipc_quiet shell ping >/dev/null 2>&1; then
    break
  fi
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    fail_with_log "test shell exited before IPC became available"
  fi
  sleep 0.1
done

wait_for() {
  local description=$1
  local probe_target=$2
  local filter=$3
  local outcome=""
  for _ in {1..80}; do
    outcome=$(shell_ipc "$probe_target" state 2>/dev/null || true)
    if jq -e "$filter" <<<"$outcome" >/dev/null 2>&1; then
      printf '%s' "$outcome"
      return 0
    fi
    if ! kill -0 "$QS_PID" 2>/dev/null; then
      fail_with_log "test shell exited while waiting for: $description"
    fi
    sleep 0.1
  done
  printf 'Probe output: %s\n' "$outcome" >&2
  fail_with_log "$description"
}

bar_state=$(wait_for "replacement bar probe responded" acme-probe-bar '.shellAlive == true')
jq -e '.propLayoutArrays == true' <<<"$bar_state" >/dev/null ||
  fail_with_log "bar receives its barConfig property with layout arrays intact"
jq -e '.apiLayoutArrays == true' <<<"$bar_state" >/dev/null ||
  fail_with_log "bar's scoped shell API keeps layout arrays in its barConfig snapshot"
jq -e '.manifestKinds == true' <<<"$bar_state" >/dev/null ||
  fail_with_log "bar manifest injection keeps kinds an array"
pass "bar injections keep arrays and manifest shape"

panel_state=$(wait_for "keepLoaded panel probe responded" acme-probe-panel '.shellAlive == true')
jq -e '.apiLayoutArrays == true' <<<"$panel_state" >/dev/null ||
  fail_with_log "panel's scoped shell API keeps layout arrays in its barConfig snapshot"
jq -e '.manifestKinds == true' <<<"$panel_state" >/dev/null ||
  fail_with_log "panel manifest injection keeps kinds an array"
pass "panel injections keep arrays and manifest shape"

[[ $(shell_ipc acme-probe-bar mutate "bar-round-1") == "ok" ]] ||
  fail_with_log "bar's scoped shell API accepts a bar-config mutation"
[[ $(shell_ipc acme-probe-panel mutate "panel-round-1") == "ok" ]] ||
  fail_with_log "panel's scoped shell API accepts a bar-config mutation"
grep -q '"probeMark": "panel-round-1"' "$test_home/.config/omarchy/shell.json" ||
  fail_with_log "accepted mutations persist to shell.json on disk"
pass "scoped API mutations apply and persist"

# A plugin rescan with an unchanged manifest must not kill the panel's
# injected shell reference: the panel is keepLoaded, so nothing recreates it.
shell_ipc_quiet shell rescanPlugins >/dev/null
sleep 1
panel_state_after=$(wait_for "keepLoaded panel still responds after rescan" acme-probe-panel '.shellAlive == true')
jq -e '.apiLayoutArrays == true' <<<"$panel_state_after" >/dev/null ||
  fail_with_log "panel's shell API keeps layout arrays after a plugin rescan"
[[ $(shell_ipc acme-probe-panel mutate "panel-round-2") == "ok" ]] ||
  fail_with_log "panel's shell API still accepts mutations after a plugin rescan"
grep -q '"probeMark": "panel-round-2"' "$test_home/.config/omarchy/shell.json" ||
  fail_with_log "post-rescan mutation persists to shell.json on disk"
pass "keepLoaded panel keeps a working shell API across plugin rescans"

pass "plugin shell lifecycle contracts hold"
