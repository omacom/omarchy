#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

REX="$ROOT/shell/plugins/rex"

# ---- plugin and launcher ----------------------------------------------------

[[ $(jq -r '.id + " " + .entryPoints.panel' "$REX/manifest.json") == "omarchy.rex Rex.qml" ]] ||
  fail "the Rex manifest declares its id and panel entry point"
[[ -f $REX/Rex.qml ]] || fail "the Rex panel entry point exists"
pass "the Rex manifest declares its id and panel entry point"

grep -qx 'Exec=omarchy-launch-rex' "$ROOT/applications/Rex.desktop" &&
  grep -qx 'Icon=rex' "$ROOT/applications/Rex.desktop" &&
  [[ -f $ROOT/applications/icons/Rex.png ]] ||
  fail "Rex is listed under Apps with its own icon"
pass "Rex is listed under Apps with its own icon"

stubs="$tmpdir/bin"
mkdir -p "$stubs"
cat >"$stubs/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALLS"
SH
cat >"$stubs/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "clients" ]]; then
  printf '%s\n' "${CLIENTS:-[]}"
else
  printf 'hyprctl %s\n' "$*" >>"$CALLS"
fi
SH
cat >"$stubs/update-desktop-database" <<'SH'
#!/bin/bash
SH
chmod +x "$stubs"/*

launch() {
  : >"$tmpdir/calls"
  PATH="$stubs:$PATH" CALLS="$tmpdir/calls" "$ROOT/bin/omarchy-launch-rex" "$@"
}

launch
[[ $(<"$tmpdir/calls") == "shell summon omarchy.rex {}" ]] ||
  fail "launching Rex summons the plugin" "$(<"$tmpdir/calls")"
pass "launching Rex summons the plugin"

launch 'a "quoted" \d+'
[[ $(<"$tmpdir/calls") == 'shell summon omarchy.rex {"pattern":"a \"quoted\" \\d+"}' ]] ||
  fail "a pattern argument reaches Rex as JSON" "$(<"$tmpdir/calls")"
pass "a pattern argument reaches Rex as JSON"

CLIENTS='[{"class":"org.quickshell","title":"Rex","address":"0xabc"}]' launch
grep -q 'address:0xabc' "$tmpdir/calls" && ! grep -q summon "$tmpdir/calls" ||
  fail "launching Rex again focuses the open window" "$(<"$tmpdir/calls")"
pass "launching Rex again focuses the open window"

# ---- migration --------------------------------------------------------------

migration_home="$tmpdir/home"
mkdir -p "$migration_home"
for _ in 1 2; do
  HOME="$migration_home" OMARCHY_PATH="$ROOT" PATH="$stubs:$PATH" bash -euo pipefail "$ROOT/migrations/1791578053.sh" >/dev/null
done
cmp -s "$migration_home/.local/share/applications/Rex.desktop" "$ROOT/applications/Rex.desktop" ||
  fail "the migration adds Rex to Apps on existing installs"
pass "the migration adds Rex to Apps on existing installs"
