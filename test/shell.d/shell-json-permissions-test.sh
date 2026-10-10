#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
omarchy_path="$tmpdir/omarchy"
mkdir -p "$home/.config/omarchy" "$omarchy_path/config/omarchy" "$omarchy_path/bin"

# 1. Test migration tightening existing 0644 shell.json to 0600
echo '{"version":1,"plugins":[]}' >"$home/.config/omarchy/shell.json"
chmod 644 "$home/.config/omarchy/shell.json"
[[ $(stat -c '%a' "$home/.config/omarchy/shell.json") == "644" ]] || fail "fixture shell.json is 644"

HOME="$home" bash -euo pipefail "$ROOT/migrations/1791573437.sh"
migrated_mode=$(stat -c '%a' "$home/.config/omarchy/shell.json")
[[ $migrated_mode == "600" ]] || fail "migration enforces mode 0600 on shell.json" "got: $migrated_mode"
pass "migration enforces mode 0600 on existing shell.json"

# 2. Test omarchy-shell-config commit() ensures mode 0600
mock_bin="$tmpdir/mock-bin"
mkdir -p "$mock_bin"
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin/omarchy-shell"

echo '{"version":1,"bar":{"layout":{"left":[],"center":[],"right":[]}},"plugins":[]}' >"$omarchy_path/config/omarchy/shell.json"
chmod 644 "$home/.config/omarchy/shell.json"

(
  export HOME="$home"
  export OMARCHY_PATH="$omarchy_path"
  export PATH="$mock_bin:$PATH"
  source "$ROOT/bin/omarchy-shell-config"
  commit '.plugins += ["test.plugin"]'
)

commit_mode=$(stat -c '%a' "$home/.config/omarchy/shell.json")
[[ $commit_mode == "600" ]] || fail "omarchy-shell-config commit enforces mode 0600" "got: $commit_mode"
pass "omarchy-shell-config commit enforces mode 0600 on shell.json"

# 3. Test refresh-config creates mode 0600 under umask 022
rm -f "$home/.config/omarchy/shell.json"
(
  umask 022
  HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" omarchy/shell.json >/dev/null
)
refresh_mode=$(stat -c '%a' "$home/.config/omarchy/shell.json")
[[ $refresh_mode == "600" ]] || fail "omarchy-refresh-config creates shell.json with mode 0600" "got: $refresh_mode"
pass "omarchy-refresh-config creates shell.json with mode 0600 under umask 022"

# 4. Static checks in shell.qml for userConfigFile security wiring
shell_qml="$ROOT/shell/shell.qml"
grep -q "function secureUserConfigFile" "$shell_qml" || fail "shell.qml defines secureUserConfigFile"
grep -A 10 "id: userConfigFile" "$shell_qml" | grep -q "secureUserConfigFile" || fail "userConfigFile invokes secureUserConfigFile"
grep -A 10 "function persistShellConfig" "$shell_qml" | grep -q "secureUserConfigFile" || fail "persistShellConfig invokes secureUserConfigFile"
pass "shell.qml wires secureUserConfigFile across lifecycle and persistence"

# 5. Quickshell runtime test (if quickshell is installed)
if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping runtime shell.json permission test"
  exit 0
fi

require_compositor "shell.json permission test"

qs_home="$tmpdir/qs-home"
qs_config="$tmpdir/qs-config"
qs_result="$tmpdir/qs-result.json"
qs_log="$tmpdir/quickshell.log"
mkdir -p "$qs_home/.config/omarchy" "$qs_config"
cp "$SHELL_TEST_DIR/fixtures/shell-json-permissions/shell.qml" "$qs_config/shell.qml"

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$qs_result" \
HOME="$qs_home" \
XDG_CONFIG_HOME="$qs_home/.config" \
  quickshell -p "$qs_config" --no-color >"$qs_log" 2>&1 &
qs_pid=$!

for _ in {1..50}; do
  [[ -s $qs_result ]] && break
  if ! kill -0 "$qs_pid" 2>/dev/null; then
    sed -n '1,120p' "$qs_log" >&2
    fail "shell-json-permissions quickshell exited prematurely"
  fi
  sleep 0.1
done

kill "$qs_pid" 2>/dev/null || true
wait "$qs_pid" 2>/dev/null || true

[[ -s $qs_result ]] || fail "shell-json-permissions quickshell runtime test timed out"
if ! jq -e '.ok == true' "$qs_result" >/dev/null; then
  cat "$qs_result" >&2
  fail "shell-json-permissions quickshell runtime test failed"
fi
pass "quickshell runtime verifies shell.json permissions enforcement"
