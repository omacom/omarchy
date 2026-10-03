#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

git_quiet() {
  git -C "$1" -c user.name=Test -c user.email=test@example.com "${@:2}"
}

write_plugin() {
  local dir="$1"
  local name="$2"

  mkdir -p "$dir"
  cat >"$dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "acme.updatable",
  "name": "$name",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": {
    "displayName": "$name",
    "category": "Test",
    "allowMultiple": false
  }
}
JSON
  printf 'import QtQuick\nItem {}\n' >"$dir/Widget.qml"
}

stub_dir="$TMPDIR/stubs"
mkdir -p "$stub_dir"
cat >"$stub_dir/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$stub_dir/omarchy-shell"

# A remote whose default branch and dev branch move independently, so an
# update that follows the wrong one is visible in the manifest on disk.
remote="$TMPDIR/remote"
write_plugin "$remote" "Default v1"
git -C "$remote" init -q
git_quiet "$remote" add .
git_quiet "$remote" commit -qm "Default v1"
git -C "$remote" checkout -q -b dev
write_plugin "$remote" "Dev v1"
git_quiet "$remote" add .
git_quiet "$remote" commit -qm "Dev v1"
git -C "$remote" checkout -q -

test_home="$TMPDIR/home"
mkdir -p "$test_home/.config/omarchy/plugins"
installed="$test_home/.config/omarchy/plugins/acme.updatable"

run_update() {
  HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
    omarchy-plugin-update acme.updatable --yes 2>&1
}

# --- a plugin installed from a branch updates from that branch --------------

git clone -q -b dev "$remote" "$installed"

git -C "$remote" checkout -q dev
write_plugin "$remote" "Dev v2"
git_quiet "$remote" add .
git_quiet "$remote" commit -qm "Dev v2"
git -C "$remote" checkout -q -

output=$(run_update) || fail "plugin update failed for a branch checkout" "$output"
[[ $(jq -r .name "$installed/manifest.json") == "Dev v2" ]] ||
  fail "plugin update did not follow the installed branch" "$output"
pass "plugin update follows the branch the plugin was installed from"

# --- the default-branch case is unchanged -----------------------------------

rm -rf "$installed"
git clone -q "$remote" "$installed"

write_plugin "$remote" "Default v2"
git_quiet "$remote" add .
git_quiet "$remote" commit -qm "Default v2"

output=$(run_update) || fail "plugin update failed for a default checkout" "$output"
[[ $(jq -r .name "$installed/manifest.json") == "Default v2" ]] ||
  fail "plugin update stopped following the default branch" "$output"
pass "plugin update still follows the default branch when no branch was named"
