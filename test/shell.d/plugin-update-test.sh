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

commit_plugin() {
  write_plugin "$remote" "$1"
  git_quiet "$remote" add .
  git_quiet "$remote" commit -qm "$1"
}

# A remote whose default branch and dev branch move independently, so an
# update that follows the wrong one is visible in the manifest on disk.
remote="$TMPDIR/remote"
mkdir -p "$remote"
git -C "$remote" init -q -b master
commit_plugin "Default v1"
git_quiet "$remote" tag -a v1 -m v1
git -C "$remote" checkout -q -b dev
commit_plugin "Dev v1"
git -C "$remote" checkout -q master

test_home="$TMPDIR/home"
mkdir -p "$test_home/.config/omarchy/plugins"
installed="$test_home/.config/omarchy/plugins/acme.updatable"

plugin() {
  HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
    "omarchy-plugin-$1" "${@:2}" --yes 2>&1
}

installed_name() {
  jq -r .name "$installed/manifest.json"
}

# --- a plugin installed from a branch updates from that branch --------------

plugin add "$remote" --branch dev >/dev/null || fail "plugin add --branch dev failed"

git -C "$remote" checkout -q dev
commit_plugin "Dev v2"
git -C "$remote" checkout -q master
commit_plugin "Default v2"

output=$(plugin update acme.updatable) || fail "plugin update failed for a branch install" "$output"
[[ $(installed_name) == "Dev v2" ]] ||
  fail "plugin update did not follow the installed branch" "$output"
pass "plugin update follows the branch the plugin was installed from"

# --- a plugin installed from a tag stays on that tag ------------------------

rm -rf "$installed"
plugin add "$remote" --branch v1 >/dev/null || fail "plugin add --branch v1 failed"

output=$(plugin update acme.updatable) || fail "plugin update failed for a tag install" "$output"
grep -qF "is up to date" <<<"$output" ||
  fail "plugin update did not report a tag install as up to date" "$output"
[[ $(installed_name) == "Default v1" ]] ||
  fail "plugin update moved a tag install off its tag" "$output"
pass "plugin update leaves a tag install on its tag"

# --- a default install follows the remote default, even renamed -------------

rm -rf "$installed"
plugin add "$remote" >/dev/null || fail "plugin add without --branch failed"

commit_plugin "Default v3"
output=$(plugin update acme.updatable) || fail "plugin update failed for a default install" "$output"
[[ $(installed_name) == "Default v3" ]] ||
  fail "plugin update stopped following the default branch" "$output"
pass "plugin update follows the default branch when no branch was named"

git -C "$remote" branch -m master main
commit_plugin "Default v4"
output=$(plugin update acme.updatable) || fail "plugin update failed after the default branch was renamed" "$output"
[[ $(installed_name) == "Default v4" ]] ||
  fail "plugin update did not follow a renamed default branch" "$output"
pass "plugin update follows the default branch after it is renamed"
