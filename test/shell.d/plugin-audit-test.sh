#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

plugin="$test_tmp/plugin"
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

clean="$test_tmp/clean"
mkdir -p "$clean"
cp "$plugin/manifest.json" "$clean/manifest.json"
printf 'import QtQuick\nQtObject {}\n' >"$clean/Service.qml"
output=$(OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" omarchy-plugin-audit "$clean")
grep -qF '[INFO] No heuristic findings' <<<"$output" || fail "audit distinguishes a clean heuristic result" "$output"
pass "plugin audit makes its limits clear when no patterns match"

# Valid entry points remain loadable even when hidden or listed in ignore files.
for source in ignored hidden; do
  fixture="$test_tmp/$source"
  cp -a "$clean" "$fixture"
  if [[ $source == "hidden" ]]; then
    mv "$fixture/Service.qml" "$fixture/.Service.qml"
    jq '.entryPoints.service = ".Service.qml"' "$clean/manifest.json" >"$fixture/manifest.json"
    entry=.Service.qml
  else
    printf 'Service.qml\n' >"$fixture/.rgignore"
    entry=Service.qml
  fi
  printf 'Process { command: ["curl", "https://example.test"] }\n' >"$fixture/$entry"
  OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" omarchy-plugin-validate "$fixture" ||
    fail "$source fixture has a valid loadable entry point"
  output=$(OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" omarchy-plugin-audit "$fixture")
  grep -qF '[MEDIUM] Network access' <<<"$output" || fail "audit scans $source source" "$output"
done
pass "plugin audit checks hidden and ignored entry points"

mkdir -p "$clean/.git" "$clean/docs"
printf 'sudo curl password\n' | tee "$clean/.git/config" "$clean/docs/example" >"$clean/README.md"
output=$(RIPGREP_CONFIG_PATH=/nonexistent/audit-config OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  omarchy-plugin-audit "$clean")
grep -qF '[INFO] No heuristic findings' <<<"$output" || fail "audit preserves explicit exclusions and ignores user rg configuration" "$output"
pass "plugin audit keeps explicit exclusions without relying on rg configuration"

# A real read failure must abort instead of producing a clean report.
if (( EUID != 0 )); then
  chmod 000 "$clean/Service.qml"
  status=0
  output=$(OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" omarchy-plugin-audit "$clean" 2>&1) || status=$?
  chmod 644 "$clean/Service.qml"
  (( status != 0 )) || fail "audit fails when source cannot be read" "$output"
  grep -qF 'Service.qml' <<<"$output" || fail "audit shows the search diagnostic" "$output"
  grep -qF 'audit incomplete' <<<"$output" || fail "audit explains the incomplete scan" "$output"
  ! grep -qF 'No heuristic findings' <<<"$output" || fail "incomplete audit never reports no findings" "$output"
  pass "plugin audit fails visibly on unreadable source"
else
  skip "root can read mode-000 files; skipping unreadable-source audit"
fi

# A Git URL uses the same staged, audited install flow as `plugin add`; it is
# deliberately a convenience entry point, not a separate installer.
stub_dir="$test_tmp/stubs"
mkdir -p "$stub_dir"
cat >"$stub_dir/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$stub_dir/omarchy-shell"
repo="$test_tmp/repo"
mkdir -p "$repo"
cp "$clean/manifest.json" "$repo/manifest.json"
cp "$clean/Service.qml" "$repo/Service.qml"
git -C "$repo" init -q
git -C "$repo" add .
git -C "$repo" -c user.name=Test -c user.email=test@example.com commit -qm "Initial"
test_home="$test_tmp/home"
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
  raw=$(TEST_PLUGIN_SOURCE="$repo" HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
    script -qec "omarchy-plugin-audit https://example.test/acme/audit-test.git" /dev/null) || status=$?
  output=$(tr -d '\r' <<<"$raw")
  (( status == 0 )) || fail "audit installs after accepting the staged review" "$output"
  grep -qF "4/4 Review plugin" <<<"$output" || fail "audit displays the staged report" "$output"
  [[ -d $test_home/.config/omarchy/plugins/acme.audit-test ]] ||
    fail "audit installs only after the staged review" "$output"
  pass "plugin audit routes Git repositories through the staged install flow"
else
  skip "script -qec unavailable; skipping Git repository audit flow"
fi
