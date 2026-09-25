#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=""
QS_PID=""

stop_shell() {
  if [[ -n $QS_PID ]]; then
    kill -TERM -- "-$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
    kill -KILL -- "-$QS_PID" 2>/dev/null || true
    QS_PID=""
  fi
}

cleanup() {
  stop_shell
  if [[ -n $test_tmp && -d $test_tmp ]]; then
    rm -rf "$test_tmp"
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping shell config startup race test"
  exit 0
fi

if ! command -v cc >/dev/null 2>&1; then
  skip "C compiler not installed; skipping delayed config startup race test"
  exit 0
fi

require_command jq
require_command setsid
require_command timeout

test_tmp=$(mktemp -d)
slow_config_so="$test_tmp/slow-config.so"

cc -shared -fPIC -O2 -Wall -Wextra -Werror \
  "$SHELL_TEST_DIR/fixtures/shell-config-startup/slow-config.c" \
  -o "$slow_config_so" -ldl

run_case() {
  local case_name="$1"
  local delayed_source="$2"
  local case_dir="$test_tmp/$case_name"
  local stage="$case_dir/omarchy"
  local test_home="$case_dir/home"
  local runtime_dir="$case_dir/runtime"
  local log="$case_dir/quickshell.log"
  local plugins_json="$case_dir/plugins.json"
  local user_config="$test_home/.config/omarchy/shell.json"
  local delayed_path

  mkdir -p "$stage/shell/plugins/bar" "$stage/config/omarchy" \
    "$test_home/.config/omarchy" "$test_home/.local/state/omarchy/current" \
    "$runtime_dir"
  chmod 700 "$runtime_dir"

  # Run the production shell host and registry. Only the bar is inert so this
  # test does not need to construct unrelated layer-shell widgets or services.
  cp "$ROOT/shell/shell.qml" "$stage/shell/shell.qml"
  cp -a "$ROOT/shell/services" "$stage/shell/services"
  cp -a "$ROOT/shell/Commons" "$stage/shell/Commons"
  cp "$ROOT/config/omarchy/shell.json" "$stage/config/omarchy/shell.json"
  cp "$SHELL_TEST_DIR/fixtures/shell-config-startup/Bar.qml" \
    "$stage/shell/plugins/bar/Bar.qml"
  ln -s "$ROOT/bin" "$stage/bin"
  ln -s "$ROOT/default" "$stage/default"
  ln -s "$ROOT/themes/tokyo-night" "$test_home/.local/state/omarchy/current/theme"

  mkdir -p "$stage/shell/plugins/services/startup-probe-disabled" \
    "$stage/shell/plugins/services/startup-probe-enabled"
  cp "$SHELL_TEST_DIR/fixtures/shell-config-startup/DisabledService.qml" \
    "$stage/shell/plugins/services/startup-probe-disabled/Service.qml"
  cp "$SHELL_TEST_DIR/fixtures/shell-config-startup/EnabledService.qml" \
    "$stage/shell/plugins/services/startup-probe-enabled/Service.qml"
  cat >"$stage/shell/plugins/services/startup-probe-disabled/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "omarchy.startup-probe-disabled",
  "name": "Startup probe disabled",
  "version": "1.0.0",
  "description": "Test-only disabled startup probe",
  "kinds": ["service"],
  "entryPoints": {"service": "Service.qml"}
}
JSON
  cat >"$stage/shell/plugins/services/startup-probe-enabled/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "omarchy.startup-probe-enabled",
  "name": "Startup probe enabled",
  "version": "1.0.0",
  "description": "Test-only enabled startup probe",
  "kinds": ["service"],
  "entryPoints": {"service": "Service.qml"}
}
JSON

  if [[ $delayed_source == "user" ]]; then
    jq '. + {disabledPlugins: ["omarchy.startup-probe-disabled"]}' \
      "$stage/config/omarchy/shell.json" >"$user_config"
    delayed_path="$user_config"
  else
    local defaults_tmp="$case_dir/defaults.json"
    jq '. + {disabledPlugins: ["omarchy.startup-probe-disabled"]}' \
      "$stage/config/omarchy/shell.json" >"$defaults_tmp"
    mv "$defaults_tmp" "$stage/config/omarchy/shell.json"
    delayed_path="$stage/config/omarchy/shell.json"
  fi

  # Keep the fixture away from a running desktop, including its compositor,
  # session bus and IPC sockets. The inert bar does not need a display.
  local -a run_env=(
    env -u WAYLAND_DISPLAY -u DISPLAY -u HYPRLAND_INSTANCE_SIGNATURE -u DBUS_SESSION_BUS_ADDRESS
    "OMARCHY_PATH=$stage" "HOME=$test_home"
    "XDG_CONFIG_HOME=$test_home/.config" "XDG_CACHE_HOME=$test_home/.cache"
    "XDG_STATE_HOME=$test_home/.local/state" "XDG_RUNTIME_DIR=$runtime_dir"
    "QML2_IMPORT_PATH=$stage/shell" "QML_IMPORT_PATH=$stage/shell" "PATH=$stage/bin:$PATH"
    QT_QPA_PLATFORM=offscreen QSG_RHI_BACKEND=software
  )
  "${run_env[@]}" "LD_PRELOAD=$slow_config_so" "OMARCHY_TEST_SLOW_CONFIG=$delayed_path" \
    setsid timeout --kill-after=2s 20s quickshell -p "$stage/shell" --no-color >"$log" 2>&1 &
  QS_PID=$!

  for _ in {1..150}; do
    if ! kill -0 "$QS_PID" 2>/dev/null; then
      sed -n '1,260p' "$log" >&2
      fail "$case_name shell startup exits before probe services start"
    fi
    grep -qF 'STARTUP_PROBE enabled started' "$log" && break
    sleep 0.1
  done

  grep -qF 'STARTUP_PROBE enabled started' "$log" || {
    sed -n '1,260p' "$log" >&2
    fail "$case_name enabled probe service starts during shell discovery"
  }
  grep -qF 'TEST: delayed configuration read' "$log" || {
    sed -n '1,260p' "$log" >&2
    fail "$case_name delays the intended configuration read"
  }

  local resolved=false
  for _ in {1..100}; do
    kill -0 "$QS_PID" 2>/dev/null || break
    if "${run_env[@]}" timeout 2s quickshell ipc -p "$stage/shell" call shell listPlugins \
      >"$plugins_json" 2>/dev/null && jq -e '
        any(.[]; .id == "omarchy.startup-probe-enabled" and .enabled == true)
        and any(.[]; .id == "omarchy.startup-probe-disabled" and .enabled == false)
      ' "$plugins_json" >/dev/null; then
      resolved=true
      break
    fi
    sleep 0.1
  done
  if [[ $resolved != "true" ]]; then
    cat "$plugins_json" >&2
    sed -n '1,260p' "$log" >&2
    fail "$case_name loaded shell config keeps the disabled probe disabled"
  fi

  local enabled_starts
  local disabled_starts
  enabled_starts=$(grep -cF 'STARTUP_PROBE enabled started' "$log" || true)
  disabled_starts=$(grep -cF 'STARTUP_PROBE disabled started' "$log" || true)
  [[ $enabled_starts == 1 ]] || fail "$case_name enabled probe starts exactly once" "count=$enabled_starts"
  [[ $disabled_starts == 0 ]] || {
    printf 'Shell config startup log (%s):\n' "$case_name" >&2
    sed -n '1,260p' "$log" >&2
    fail "$case_name disabled probe never starts before delayed config arrives" "count=$disabled_starts"
  }

  pass "real shell discovery keeps a service disabled by delayed $delayed_source shell.json"
  stop_shell
}

run_case user-config user
run_case default-config defaults
