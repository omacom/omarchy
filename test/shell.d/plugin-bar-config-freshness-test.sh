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
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

shell_qml="$ROOT/shell/shell.qml"

# Normalize horizontal and vertical whitespace so the wiring assertions survive
# harmless QML reflow. Same technique as plugin-auth-boundary-test.sh.
qml_matches() {
  local file=$1
  local pattern=$2

  tr '\n\r\t' '   ' < "$file" | grep -Eq "$pattern"
}

# Regression guard for https://github.com/omacom/omarchy/issues/11505:
# publicBarConfig() must derive from shellConfig directly (like
# publicIdleConfigFor does), never from the derived barConfig binding, which
# is still stale inside onShellConfigChanged when syncPluginApis() runs.
qml_matches "$shell_qml" 'function publicBarConfig\(\) *\{[^}]*shell\.shellConfig\.bar' ||
  fail "publicBarConfig derives bar config from shellConfig directly (#11505)"
qml_matches "$shell_qml" 'function publicBarConfig\(\) *\{[^}]*shell\.barConfig' &&
  fail "publicBarConfig reads the stale derived barConfig binding (#11505)"
pass "publicBarConfig derives from shellConfig, not the derived binding"

# Both affected readers flow through publicBarConfig(), so the one fix covers
# them: scoped plugin shell APIs and bar-entry shell APIs in syncPluginApis().
qml_matches "$shell_qml" 'shellApi\.barConfig = shell\.publicBarConfig\(\)' ||
  fail "scoped plugin shell APIs refresh barConfig through publicBarConfig"
qml_matches "$shell_qml" '_pluginBarEntryShellApis\[entryKey\]\.barConfig = shell\.publicBarConfig\(\)' ||
  fail "bar-entry shell APIs refresh barConfig through publicBarConfig"
pass "both plugin API maps refresh barConfig through publicBarConfig"

# barConfigFor() still routes third-party callers through publicBarConfig().
# Its first-party branch returns the shell.barConfig binding, which is only
# read from onBarConfigChanged and Loader onLoaded - both run after bindings
# re-evaluate, so that branch is unaffected by #11505.
qml_matches "$shell_qml" '\? *shell\.barConfig *: *shell\.publicBarConfig\(\)' ||
  fail "barConfigFor routes third-party callers through publicBarConfig"
pass "barConfigFor routes third-party callers through publicBarConfig"

require_compositor "plugin bar config freshness test"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping plugin bar config freshness test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/plugin-bar-config-freshness"
mkdir -p "$config_dir" "$TMPDIR/home"
cp "$SHELL_TEST_DIR/fixtures/plugin-bar-config-freshness/shell.qml" "$config_dir/shell.qml"

# Quickshell aborts through qFatal() when its connection drops; keep that
# abort from writing a core (same rationale as require_compositor).
ulimit -c 0 2>/dev/null || true

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
PATH="$ROOT/bin:$PATH" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..80}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,220p' "$log" >&2
    fail "plugin bar config freshness quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,220p' "$log" >&2
  fail "plugin bar config freshness test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  printf 'Plugin bar config freshness result:\n' >&2
  jq . "$result" >&2
  printf 'Plugin bar config freshness log:\n' >&2
  sed -n '1,220p' "$log" >&2
  fail "plugin services observe fresh bar config inside onShellConfigChanged"
fi

pass "plugin services observe fresh bar config inside onShellConfigChanged"
