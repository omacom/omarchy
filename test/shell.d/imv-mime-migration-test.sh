#!/bin/bash
#
# The imv MIME migration must register AVIF, HEIF, HEIC, and JXL on an existing
# install's user-level imv.desktop without discarding the user's edits to it,
# and must rebuild mimeinfo.cache so GIO lists imv for the new types.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1789706522.sh"
new_launcher="$ROOT/applications/imv.desktop"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

# update-desktop-database ships in desktop-file-utils, which a development host
# may lack. Only the cache-contents check needs the real one, so a stub that
# creates an empty cache stands in for the rest and that check is skipped.
cache_rebuild=real
if ! command -v update-desktop-database >/dev/null; then
  cache_rebuild=stub
  mkdir "$test_dir/bin"
  cat >"$test_dir/bin/update-desktop-database" <<'SCRIPT'
#!/bin/bash
touch "$1/mimeinfo.cache"
SCRIPT
  chmod +x "$test_dir/bin/update-desktop-database"
  PATH="$test_dir/bin:$PATH"
fi

[[ $(stat -c %a "$migration") == "644" ]] || fail "migration is a plain 0644 file"

# The launcher every earlier install received: the shipped one minus the new types.
old_launcher() {
  sed 's#image/avif;image/heif;image/heic;image/jxl;##' "$new_launcher"
}

new_home() {
  home="$test_dir/$1"
  apps="$home/.local/share/applications"
  launcher="$apps/imv.desktop"
  mkdir -p "$apps"
}

run_migration() {
  HOME="$home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null ||
    fail "migration runs in $home"
}

new_home stock
old_launcher >"$launcher"
cmp -s "$launcher" "$new_launcher" && fail "the old launcher fixture differs from the shipped one"
run_migration
cmp -s "$launcher" "$new_launcher" || fail "a stock launcher becomes the shipped launcher" "$(cat "$launcher")"
[[ -f $apps/mimeinfo.cache ]] || fail "a stock launcher triggers a cache rebuild"
before=$(sha256sum "$apps"/*)
run_migration
[[ $(sha256sum "$apps"/*) == "$before" ]] || fail "a second run changes nothing"
pass "a stock launcher gains the new types, idempotently"
if [[ $cache_rebuild == "real" ]]; then
  for type in avif heif heic jxl; do
    grep -Eq "^image/$type=.*imv\.desktop" "$apps/mimeinfo.cache" ||
      fail "mimeinfo.cache registers imv for image/$type" "$(cat "$apps/mimeinfo.cache")"
  done
  pass "mimeinfo.cache registers imv for the new types"
else
  skip "update-desktop-database not installed; skipping the mimeinfo.cache contents check"
fi

new_home interrupted
old_launcher >"$launcher"
mkdir -p "$test_dir/failing-bin"
printf '#!/bin/bash\nexit 1\n' >"$test_dir/failing-bin/update-desktop-database"
chmod +x "$test_dir/failing-bin/update-desktop-database"
PATH="$test_dir/failing-bin:$PATH" HOME="$home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null &&
  fail "a failed cache rebuild fails the migration"
[[ ! -e $apps/mimeinfo.cache ]] || fail "a failed cache rebuild leaves no cache"
run_migration
[[ -f $apps/mimeinfo.cache ]] || fail "a retry rebuilds the cache the failed run left stale"
cmp -s "$launcher" "$new_launcher" || fail "a retry leaves the launcher as the shipped one" "$(cat "$launcher")"
pass "a retry after a failed cache rebuild completes it"

new_home edited
old_launcher | sed 's#^Exec=imv %F$#Exec=imv-dir %F#' >"$launcher"
echo 'NoDisplay=true' >>"$launcher"
run_migration
grep -qxF 'Exec=imv-dir %F' "$launcher" || fail "an edited Exec line survives" "$(cat "$launcher")"
grep -qxF 'NoDisplay=true' "$launcher" || fail "an added NoDisplay line survives" "$(cat "$launcher")"
grep -qxF "$(grep '^MimeType=' "$new_launcher")" "$launcher" || fail "an edited launcher still gains the new types" "$(cat "$launcher")"
pass "edits outside the MimeType line are kept"

new_home custom
old_launcher | sed 's#^MimeType=.*#MimeType=image/png;#' >"$launcher"
cp "$launcher" "$test_dir/custom-before"
run_migration
cmp -s "$launcher" "$test_dir/custom-before" || fail "a custom MimeType line is left alone" "$(cat "$launcher")"
[[ ! -e $apps/mimeinfo.cache ]] || fail "an untouched launcher does not trigger a cache rebuild"
pass "a custom MimeType line is left alone"

new_home symlinked
mkdir -p "$home/dotfiles"
old_launcher >"$home/dotfiles/imv.desktop"
ln -s "$home/dotfiles/imv.desktop" "$launcher"
run_migration
[[ -L $launcher ]] || fail "a symlinked launcher stays a symlink"
cmp -s "$home/dotfiles/imv.desktop" "$new_launcher" || fail "the symlink target gains the new types" "$(cat "$home/dotfiles/imv.desktop")"
pass "a symlinked launcher is updated through the link"

new_home missing
run_migration
[[ -z $(ls -A "$apps") ]] || fail "a missing launcher is not created" "$(ls -A "$apps")"
pass "a missing launcher is not created"
