#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

plugin="$TMPDIR/plugin"
mkdir -p "$plugin"
cat >"$plugin/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "acme.audit-test",
  "name": "Audit Test",
  "version": "1.0.0",
  "kinds": ["service"],
  "entryPoints": { "service": "Service.qml" }
}
JSON
cat >"$plugin/Service.qml" <<'QML'
import QtQuick
import Quickshell.Io
QtObject {
  Process { command: ["curl", "https://example.test/install"] }
}
QML
cat >"$plugin/install.sh" <<'SH'
#!/bin/bash
sudo systemctl --user enable acme.service
SH
chmod +x "$plugin/install.sh"

output=$(OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" omarchy-plugin-audit "$plugin")
grep -qF '[HIGH] Privilege or protected-system access' <<<"$output" || fail "audit reports privilege access" "$output"
grep -qF '[HIGH] Persistence mechanism' <<<"$output" || fail "audit reports persistence" "$output"
grep -qF '[MEDIUM] Network access' <<<"$output" || fail "audit reports network access" "$output"
grep -qF '[MEDIUM] External command execution' <<<"$output" || fail "audit reports command execution" "$output"
grep -qF '[LOW] Executable files' <<<"$output" || fail "audit reports executable files" "$output"
pass "plugin audit reports security-sensitive code without executing it"

clean="$TMPDIR/clean"
mkdir -p "$clean"
cp "$plugin/manifest.json" "$clean/manifest.json"
printf 'import QtQuick\nQtObject {}\n' >"$clean/Service.qml"
output=$(OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" omarchy-plugin-audit "$clean")
grep -qF '[INFO] No heuristic findings' <<<"$output" || fail "audit distinguishes a clean heuristic result" "$output"
pass "plugin audit makes its limits clear when no patterns match"

# A Git URL uses the same staged, audited install flow as `plugin add`; it is
# deliberately a convenience entry point, not a separate installer.
stub_dir="$TMPDIR/stubs"
mkdir -p "$stub_dir"
cat >"$stub_dir/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$stub_dir/omarchy-shell"
repo="$TMPDIR/repo"
mkdir -p "$repo"
cp "$clean/manifest.json" "$repo/manifest.json"
cp "$clean/Service.qml" "$repo/Service.qml"
git -C "$repo" init -q
git -C "$repo" add .
git -C "$repo" -c user.name=Test -c user.email=test@example.com commit -qm "Initial"
home="$TMPDIR/home"
cat >"$stub_dir/gum" <<'STUB'
#!/bin/bash
case "$1" in
style) cat ;;
pager) cat ;;
choose)
  while (( $# )); do
    if [[ $1 == "--header" ]]; then printf '%s\n' "$2" >&2; fi
    shift
  done
  printf 'Install plugin\n'
  ;;
*) exit 1 ;;
esac
STUB
chmod +x "$stub_dir/gum"
cat >"$stub_dir/git" <<'STUB'
#!/bin/bash
if [[ $1 == "clone" ]]; then
  cp -a "$TEST_PLUGIN_SOURCE" "${!#}"
  exit 0
fi
exit 0
STUB
chmod +x "$stub_dir/git"
if script -qec true /dev/null >/dev/null 2>&1; then
  status=0
  raw=$(TEST_PLUGIN_SOURCE="$repo" HOME="$home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
    script -qec "omarchy-plugin-audit https://example.test/acme/audit-test.git" /dev/null) || status=$?
  output=$(tr -d '\r' <<<"$raw")
  (( status == 0 )) || fail "audit installs after accepting the staged review" "$output"
  grep -qF "4/4 Review plugin" <<<"$output" || fail "audit displays the staged report" "$output"
  [[ -d $home/.config/omarchy/plugins/acme.audit-test ]] ||
    fail "audit installs only after the staged review" "$output"
  pass "plugin audit routes Git repositories through the staged install flow"
else
  skip "script -qec unavailable; skipping Git repository audit flow"
fi
