#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
upstream="$fixture/upstream"
test_home="$fixture/home"
installed="$test_home/.config/omarchy/plugins/acme.widget"
mkdir -p "$upstream" "$(dirname "$installed")" "$fixture/bin"

cat >"$fixture/bin/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$fixture/bin/omarchy-shell"

commit() {
  git -C "$upstream" add .
  git -C "$upstream" -c user.name=Test -c user.email=test@example.invalid commit -qm "$1"
}

manifest='{"schemaVersion":1,"id":"acme.widget","name":"Test widget","version":"1","kinds":["bar-widget"],"entryPoints":{"barWidget":"Widget.qml"}}'
git -C "$upstream" init -q
printf '%s\n' "$manifest" >"$upstream/manifest.json"
printf 'Item {}\n' >"$upstream/Widget.qml"
printf 'original\n' >"$upstream/notes"
commit initial
git clone -q "$upstream" "$installed"
base=$(git -C "$installed" rev-parse HEAD)
printf 'staged\n' >"$installed/notes"
git -C "$installed" add notes
printf 'unstaged\n' >"$installed/notes"

run_update() {
  HOME="$test_home" PATH="$fixture/bin:$ROOT/bin:$PATH" omarchy-plugin-update acme.widget --yes
}

printf 'broken manifest\n' >"$upstream/manifest.json"
commit invalid
if run_update >"$fixture/invalid.log" 2>&1; then
  fail "plugin update refuses an invalid upstream manifest"
fi
[[ $(git -C "$installed" rev-parse HEAD) == "$base" ]] ||
  fail "an invalid plugin update leaves the installed revision unchanged"
[[ $(git -C "$installed" show :notes) == staged && $(<"$installed/notes") == unstaged ]] ||
  fail "an invalid plugin update preserves staged and unstaged edits"
pass "an invalid plugin update preserves both the working tree and staging area"

printf '%s\n' "$manifest" >"$upstream/manifest.json"
printf 'Item { visible: false }\n' >"$upstream/Widget.qml"
commit valid
run_update >"$fixture/valid.log" 2>&1 || fail "plugin update accepts a valid fast-forward" "$(cat "$fixture/valid.log")"
[[ $(git -C "$installed" rev-parse HEAD) == "$(git -C "$upstream" rev-parse HEAD)" ]] ||
  fail "the valid revision reaches the installed plugin"
[[ $(git -C "$installed" show :notes) == staged && $(<"$installed/notes") == unstaged ]] ||
  fail "a valid plugin update preserves unrelated edits"
[[ $(git -C "$installed" worktree list --porcelain | grep -c '^worktree ') == 1 ]] ||
  fail "the plugin updater cleans up its temporary checkouts"
pass "a valid plugin update fast-forwards and preserves unrelated edits"
