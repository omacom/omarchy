#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

stub_dir="$TMPDIR/stubs"
mkdir -p "$stub_dir"
cat >"$stub_dir/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$stub_dir/omarchy-shell"

test_home="$TMPDIR/home"
plugins_dir="$test_home/.config/omarchy/plugins"

run() {
  HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" "$@" 2>&1
}

git_test() {
  git -c user.name=Test -c user.email=test@example.com "$@"
}

# Each plugin is added from an upstream repo of its own, as `omarchy plugin add`
# would clone it from a forge or a local checkout.
add_plugin() {
  local id="$1"
  local upstream="$TMPDIR/upstream/$id"

  mkdir -p "$upstream"
  cat >"$upstream/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$id",
  "name": "$id",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": {
    "displayName": "$id",
    "category": "Test",
    "allowMultiple": false
  }
}
JSON
  printf 'import QtQuick\nItem {}\n' >"$upstream/Widget.qml"
  git -C "$upstream" init -q
  git -C "$upstream" add .
  git_test -C "$upstream" commit -qm "Initial"

  output=$(run omarchy-plugin-add "$upstream" --yes) || fail "plugin add installs $id" "$output"
}

backup_of() {
  find "$plugins_dir" -mindepth 1 -maxdepth 1 -name ".$1.bak.*" -print -quit
}

remove_plugin() {
  output=$(run omarchy-plugin-remove "$1" --yes) || fail "plugin remove removes $1" "$output"
  [[ ! -e $plugins_dir/$1 ]] || fail "plugin remove leaves $1 installed" "$output"
}

add_plugin acme.clean
remove_plugin acme.clean
[[ -z $(backup_of acme.clean) ]] || fail "plugin remove backs up a checkout with nothing local"
pass "plugin remove deletes a checkout whose commits are all upstream"

# `omarchy plugin update` merges FETCH_HEAD without moving the remote-tracking
# refs, so the commits it brought in are upstream too.
add_plugin acme.updated
printf '// upstream\n' >>"$TMPDIR/upstream/acme.updated/Widget.qml"
git_test -C "$TMPDIR/upstream/acme.updated" commit -qam "Upstream change"
output=$(run omarchy-plugin-update acme.updated --yes) || fail "plugin update fast-forwards acme.updated" "$output"
remove_plugin acme.updated
[[ -z $(backup_of acme.updated) ]] || fail "plugin remove backs up a checkout that only holds updates from upstream"
pass "plugin remove deletes a checkout updated from upstream"

add_plugin acme.edited
printf '// local edit\n' >>"$plugins_dir/acme.edited/Widget.qml"
remove_plugin acme.edited
backup=$(backup_of acme.edited)
[[ -n $backup ]] && grep -qF '// local edit' "$backup/Widget.qml" ||
  fail "plugin remove drops uncommitted changes" "$output"
pass "plugin remove backs up a checkout with uncommitted changes"

add_plugin acme.untracked
printf 'import QtQuick\nItem {}\n' >"$plugins_dir/acme.untracked/Extra.qml"
remove_plugin acme.untracked
backup=$(backup_of acme.untracked)
[[ -n $backup && -f $backup/Extra.qml ]] || fail "plugin remove drops untracked files" "$output"
pass "plugin remove backs up a checkout with untracked files"

add_plugin acme.committed
printf '// local commit\n' >>"$plugins_dir/acme.committed/Widget.qml"
git_test -C "$plugins_dir/acme.committed" commit -qam "Local change"
remove_plugin acme.committed
backup=$(backup_of acme.committed)
[[ -n $backup && $(git -C "$backup" log -1 --format=%s) == "Local change" ]] ||
  fail "plugin remove drops commits that were never pushed" "$output"
pass "plugin remove backs up a checkout with unpushed commits"

add_plugin acme.stashed
printf '// stashed\n' >>"$plugins_dir/acme.stashed/Widget.qml"
git_test -C "$plugins_dir/acme.stashed" stash push -q
remove_plugin acme.stashed
backup=$(backup_of acme.stashed)
[[ -n $backup && -n $(git -C "$backup" stash list) ]] || fail "plugin remove drops stashed changes" "$output"
pass "plugin remove backs up a checkout with stashed changes"
