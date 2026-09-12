#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
export GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=test@example.com

remote="$test_tmp/remote"
git init -q -b main "$remote"
printf '%s\n' '{"schemaVersion":1,"id":"test.plugin","name":"Test","version":"1","kinds":["service"],"entryPoints":{"service":"Service.qml"}}' > "$remote/manifest.json"
printf '%s\n' 'import QtQuick' 'QtObject {}' > "$remote/Service.qml"
printf '%s\n' 'original notes' > "$remote/notes.txt"
printf '%s\n' 'ignored-*' > "$remote/.gitignore"
git -C "$remote" add .
git -C "$remote" commit -qm initial
initial=$(git -C "$remote" rev-parse HEAD)

omarchy-plugin-validate() { bash "$ROOT/bin/omarchy-plugin-validate" "$@"; }
omarchy-shell() { printf '%s\n' "$*" >> "$test_tmp/rescans"; }
export -f omarchy-plugin-validate omarchy-shell
export test_tmp

update() {
  HOME="$test_tmp/home" bash "$ROOT/bin/omarchy-plugin-update" --yes "$@"
}
clone() {
  mkdir -p "$test_tmp/home/.config/omarchy/plugins"
  checkout="$test_tmp/home/.config/omarchy/plugins/$1"
  git clone -q "$remote" "$checkout"
}

clone test.plugin
printf '%s\n' 'uncommitted notes' > "$checkout/notes.txt"
printf '%s\n' '{}' > "$remote/manifest.json"
git -C "$remote" commit -qam 'invalid candidate'
if update test.plugin; then fail "invalid update must fail"; fi
[[ $(git -C "$checkout" rev-parse HEAD) == "$initial" ]] || fail "invalid update leaves HEAD unchanged"
[[ $(<"$checkout/notes.txt") == "uncommitted notes" ]] || fail "invalid update preserves local edits"
[[ ! -e $test_tmp/rescans ]] || fail "invalid update does not rescan plugins"
pass "invalid candidates leave the installed revision and local edits untouched"

git -C "$remote" show "$initial:manifest.json" > "$remote/manifest.json"
printf '%s\n' '// updated' >> "$remote/Service.qml"
git -C "$remote" commit -qam 'valid candidate'
if update test.plugin; then fail "local edits must prevent update"; fi
[[ $(<"$checkout/notes.txt") == "uncommitted notes" ]] || fail "valid candidate preserves local edits"
git -C "$remote" show "$initial:notes.txt" > "$checkout/notes.txt"
ln -s notes.txt "$checkout/ignored-link"
if update test.plugin; then fail "ignored local files must not bypass validation"; fi
[[ -L $checkout/ignored-link ]] || fail "ignored local file remains intact"
unlink "$checkout/ignored-link"
pass "ignored local files cannot bypass the clean-checkout requirement"
update test.plugin
[[ $(git -C "$checkout" rev-parse HEAD) == $(git -C "$remote" rev-parse HEAD) ]] || fail "valid update fast-forwards"
[[ $(wc -l < "$test_tmp/rescans") == 1 ]] || fail "successful update rescans once"
pass "valid candidates require a clean checkout before fast-forwarding"

update test.plugin
[[ $(wc -l < "$test_tmp/rescans") == 1 ]] || fail "unchanged update does not rescan"
pass "unchanged plugins do not trigger rescans"

printf '%s\n' '// local edit' >> "$checkout/Service.qml"
printf '%s\n' '// remote edit' >> "$remote/Service.qml"
git -C "$remote" commit -qam 'conflicting candidate'
before=$(git -C "$checkout" rev-parse HEAD)
if update test.plugin; then fail "overlapping edits must prevent update"; fi
[[ $(git -C "$checkout" rev-parse HEAD) == "$before" ]] || fail "conflicting update leaves HEAD unchanged"
grep -q 'local edit' "$checkout/Service.qml" || fail "conflicting local edit survives"
pass "overlapping edits remain intact after a refused fast-forward"

clone test.diverged
printf '%s\n' 'local commit' > "$checkout/notes.txt"
git -C "$checkout" commit -qam 'local history'
before=$(git -C "$checkout" rev-parse HEAD)
printf '%s\n' '// next remote revision' >> "$remote/Service.qml"
git -C "$remote" commit -qam 'remote history'
if update test.diverged; then fail "diverged history must prevent update"; fi
[[ $(git -C "$checkout" rev-parse HEAD) == "$before" ]] || fail "local commit survives"
pass "diverged history is not reset or merged"

clone test.symlink
before=$(git -C "$checkout" rev-parse HEAD)
ln -s notes.txt "$remote/hidden-link"
printf '%s\n' 'hidden-link export-ignore' > "$remote/.gitattributes"
git -C "$remote" add .
git -C "$remote" commit -qm 'invalid symlink hidden from archives'
if update test.symlink; then fail "export-ignore cannot bypass validation"; fi
[[ $(git -C "$checkout" rev-parse HEAD) == "$before" ]] || fail "invalid tree remains uninstalled"
pass "validation includes files marked export-ignore"
