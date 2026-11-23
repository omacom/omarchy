#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

files="$ROOT/bin/omarchy-snapshot-files"

test_tmp=$(mktemp -d)
# Read-only folders are restored below, so their copies need writing to go.
trap 'chmod -R u+w "$test_tmp"; rm -rf "$test_tmp"' EXIT

export OMARCHY_SNAPSHOTS_SUBVOLUME="$test_tmp/home"
export OMARCHY_SNAPSHOTS_DIR="$test_tmp/home/.snapshots"
export HOME="$test_tmp/home/me"
mkdir -p "$OMARCHY_SNAPSHOTS_DIR"

# A hard-linked copy keeps every file's inode number, as a btrfs snapshot does,
# so a move still reads as a move. Only ever delete or move after one.
snapshot() {
  local number="$1" hours_ago="$2"

  mkdir -p "$OMARCHY_SNAPSHOTS_DIR/$number/snapshot"
  cp -al "$HOME" "$OMARCHY_SNAPSHOTS_DIR/$number/snapshot/me"
  printf '<snapshot>\n  <num>%s</num>\n  <date>%s</date>\n</snapshot>\n' "$number" "$(date -u -d "-$hours_ago hours" '+%Y-%m-%d %H:%M:%S')" \
    >"$OMARCHY_SNAPSHOTS_DIR/$number/info.xml"
}

deleted() {
  "$files" deleted --json "$@" | jq -r '.files[] | (.path | sub("^" + env.HOME + "/"; "")) + (if .folder then "/" else "" end)'
}

mkdir -p "$HOME"/{Documents,Pictures/trip,Music,.cache,project/node_modules,project/target}
echo report >"$HOME/Documents/report.pdf"
echo notes >"$HOME/Documents/notes.txt"
echo draft >"$HOME/Documents/draft.txt~"
echo a >"$HOME/Pictures/trip/a.jpg"
echo b >"$HOME/Pictures/trip/b.jpg"
echo song >"$HOME/Music/song.mp3"
echo junk >"$HOME/.cache/junk"
echo dep >"$HOME/project/node_modules/x.js"
echo 'Signature: 8a477f597d28d172789f06886806bc55' >"$HOME/project/target/CACHEDIR.TAG"
echo out >"$HOME/project/target/out.o"
touch -d '2026-01-02 03:04:05' "$HOME/Documents/notes.txt"
snapshot 1 3

rm "$HOME/Documents/notes.txt"
mv "$HOME/Music/song.mp3" "$HOME/Documents/song.mp3"
snapshot 2 2

rm -r "$HOME/Pictures/trip" "$HOME/.cache/junk" "$HOME/project/node_modules/x.js" "$HOME/project/target/out.o" "$HOME/Documents/draft.txt~"
snapshot 3 1

rm "$HOME/Documents/report.pdf"

expected=$'Documents/report.pdf\nPictures/trip/\nDocuments/notes.txt'
[[ $(deleted) == "$expected" ]] || fail "deleted lists what a snapshot holds and is gone now, latest first" "$(deleted)"
pass "deleted lists what a snapshot holds and is gone now, latest first"

# Each was seen last in the snapshot just before it went.
[[ $("$files" deleted --json | jq -r '[.files[].snapshot] | join(" ")') == "3 2 1" ]] ||
  fail "deleted names the last snapshot that held each file"
pass "deleted names the last snapshot that held each file"

# Moved is not deleted, and caches, dependencies, build output and editor
# backups are churn rather than anything someone lost.
! deleted | grep -qE 'song|junk|x\.js|out\.o|draft' || fail "deleted leaves out moves and churn" "$(deleted)"
pass "deleted leaves out moved files, hidden folders, dependencies, build output and backups"

[[ $(deleted ~/Documents) == $'Documents/report.pdf\nDocuments/notes.txt' ]] ||
  fail "deleted narrows to a folder" "$(deleted ~/Documents)"
pass "deleted narrows to a folder"

compgen -G "$HOME/.cache/omarchy/snapshot-files/1.*-2.*.json" >/dev/null && compgen -G "$HOME/.cache/omarchy/snapshot-files/2.*-3.*.json" >/dev/null ||
  fail "deleted caches comparisons between snapshots, which never change"
[[ $(deleted) == "$expected" ]] || fail "deleted answers the same from its cache"
pass "deleted caches comparisons between snapshots"

[[ $("$files" deleted --json --budget 0 ~/Documents | jq -r '.complete') == "true" ]] ||
  fail "a cached run is complete within any budget"
rm -rf "$HOME/.cache/omarchy"
budgeted=$("$files" deleted --json --budget 0)
[[ $(jq -r '.complete' <<<"$budgeted") == "false" ]] || fail "deleted says when its budget left snapshots uncompared"
[[ $(jq -r '.files[0].path' <<<"$budgeted") == "$HOME/Documents/report.pdf" ]] ||
  fail "deleted still compares the newest snapshot with the live home within a budget" "$budgeted"
pass "deleted stays within a time budget and says so"

"$files" restore ~/Documents/notes.txt >/dev/null
[[ $(cat "$HOME/Documents/notes.txt") == "notes" ]] || fail "restore puts a file back"
[[ $(stat -c %Y "$HOME/Documents/notes.txt") == $(date -d '2026-01-02 03:04:05' +%s) ]] || fail "restore keeps the file's times"
"$files" restore "$HOME/Pictures/trip" >/dev/null
[[ $(cat "$HOME/Pictures/trip/a.jpg" "$HOME/Pictures/trip/b.jpg") == $'a\nb' ]] || fail "restore puts a whole folder back"
restored=$("$files" restore --json ~/Documents/report.pdf)
[[ $(jq -r '.snapshot' <<<"$restored") == "3" && -f $HOME/Documents/report.pdf ]] || fail "restore takes the latest copy" "$restored"
[[ -z $(deleted) ]] || fail "deleted no longer lists what was restored" "$(deleted)"
! compgen -G "$HOME/*/.*restoring*" >/dev/null || fail "restore leaves no partial copy behind"
pass "restore puts files and folders back as they were"

# Moved into a folder that's gone since, it comes back with its folder.
mv "$HOME/Documents/song.mp3" "$HOME/Pictures/trip/song.mp3"
snapshot 4 0
rm -r "$HOME/Pictures"
"$files" restore ~/Pictures/trip/song.mp3 >/dev/null
[[ $(cat "$HOME/Pictures/trip/song.mp3") == "song" ]] || fail "restore makes the folders a file was in"
pass "restore makes the folders a file was in"

expect_refusal() {
  local description="$1" message="$2"
  shift 2
  local output status=0
  output=$("$files" "$@" 2>&1) || status=$?
  (( status == 1 )) && grep -qF "$message" <<<"$output" || fail "$description" "$output"
  pass "$description"
}

expect_refusal "restore never overwrites" "is already there" restore ~/Documents/notes.txt
expect_refusal "restore stays inside the home folder" "is not in your home folder" restore "$test_tmp/elsewhere"
expect_refusal "restore stays inside the home folder through .." "is not in your home folder" restore ~/../other/file
expect_refusal "restore says when no snapshot holds a file" "No snapshot holds" restore ~/never-existed
expect_refusal "deleted stays inside the home folder" "is not in your home folder" deleted /etc

rm -rf "$OMARCHY_SNAPSHOTS_DIR"
[[ $("$files" deleted --json | jq -c '[.snapshots, .files]') == '[0,[]]' ]] || fail "deleted reports no snapshots instead of failing"
"$files" deleted | grep -qF "No snapshots of your home folder" || fail "deleted says plainly that there are no snapshots yet"
pass "deleted reports a machine without snapshots of /home"

# A fresh home and snapshots, for each case below.
reset() {
  chmod -R u+w "$OMARCHY_SNAPSHOTS_DIR" "$HOME" 2>/dev/null || true
  rm -rf "$OMARCHY_SNAPSHOTS_DIR" "$HOME"
  mkdir -p "$OMARCHY_SNAPSHOTS_DIR" "$HOME"
}

# Filing things away in a new folder, or emptying a folder into another and
# removing it, deletes nothing.
reset
mkdir -p ~/Docs ~/Old
echo a >~/Docs/a.pdf
echo b >~/Old/b.pdf
snapshot 1 2
mkdir ~/Docs/2025 ~/Archive
mv ~/Docs/a.pdf ~/Docs/2025/
mv ~/Old/b.pdf ~/Archive/
rmdir ~/Old
[[ -z $(deleted) ]] || fail "moving files into a new folder, or out of a removed one, deletes nothing" "$(deleted)"
pass "moving files into a new folder, or out of a removed one, deletes nothing"

# Hidden files can matter (.env); hidden folders, swap and lock files, and
# folders marked as caches are churn.
reset
mkdir -p ~/app/.git ~/build
echo secret >~/app/.env
echo swap >~/app/.notes.md.swp
echo lock >"$HOME/app/.~lock.budget.ods#"
echo object >~/app/.git/object
echo 'Signature: 8a477f597d28d172789f06886806bc55' >~/build/CACHEDIR.TAG
echo out >~/build/out.o
snapshot 1 1
rm -r ~/app/.env ~/app/.notes.md.swp "$HOME/app/.~lock.budget.ods#" ~/app/.git/object ~/build
[[ $(deleted) == "app/.env" ]] || fail "deleted lists hidden files but not hidden folders, swap, lock or cache folders" "$(deleted)"
pass "deleted lists hidden files but not hidden folders, swap, lock or cache folders"

# One file restored out of a deleted folder leaves the rest of it listed.
reset
mkdir -p ~/Pictures/trip
chmod 0750 ~/Pictures
echo a >~/Pictures/trip/a.jpg
echo b >~/Pictures/trip/b.jpg
snapshot 1 1
rm -r ~/Pictures
"$files" restore ~/Pictures/trip/a.jpg >/dev/null
[[ $(stat -c %a ~/Pictures) == "750" ]] || fail "restore makes the folders a file was in as they were" "$(stat -c %a ~/Pictures)"
[[ $(deleted) == "Pictures/trip/b.jpg" ]] || fail "deleted lists what's still missing from a folder that's back" "$(deleted)"
pass "a folder partly restored still lists what's missing from it"

# A symbolic link on the way would take the restore, or what it copies,
# somewhere else than it says.
reset
mkdir -p ~/Work "$test_tmp/elsewhere"
echo x >~/Work/x.txt
snapshot 1 1
rm -r ~/Work
ln -s "$test_tmp/elsewhere" ~/Work
expect_refusal "restore refuses a path through a symbolic link" "through a symbolic link" restore ~/Work/x.txt
[[ ! -e $test_tmp/elsewhere/x.txt ]] || fail "restore writes nothing through a symbolic link"
pass "restore writes nothing through a symbolic link"

# Nor does it copy out through one a snapshot holds, which would read the live disk.
reset
mkdir -p "$test_tmp/live-elsewhere"
echo live >"$test_tmp/live-elsewhere/y.txt"
ln -s "$test_tmp/live-elsewhere" ~/Link
snapshot 1 1
rm ~/Link
expect_refusal "restore copies nothing out through a link a snapshot holds" "No snapshot holds" restore ~/Link/y.txt

# Snapper gives a deleted newest snapshot's number to the next one, which must
# not be answered from the first one's cache.
reset
echo one >~/one.txt
echo two >~/two.txt
snapshot 1 3
snapshot 2 2
rm ~/one.txt
snapshot 3 1
rm ~/two.txt
[[ $(deleted) == $'two.txt\none.txt' ]] || fail "deleted lists both before the snapshot is replaced" "$(deleted)"
rm -rf "$OMARCHY_SNAPSHOTS_DIR/2" "$OMARCHY_SNAPSHOTS_DIR/3"
echo one >~/one.txt
snapshot 2 0
rm ~/one.txt
[[ $(deleted) == $'one.txt\ntwo.txt' ]] || fail "a reused snapshot number isn't answered from the old cache" "$(deleted)"
pass "a reused snapshot number isn't answered from the old cache"



# Renamed over an existing name, or a download renamed once it's done, is a
# rename, not a deletion.
reset
mkdir -p ~/Docs ~/Downloads
echo v1 >~/Docs/report.pdf
echo v2 >~/Docs/report-v2.pdf
echo part >~/Downloads/movie.mkv.crdownload
snapshot 1 1
mv ~/Docs/report-v2.pdf ~/Docs/report.pdf
echo more >>~/Downloads/movie.mkv.crdownload
mv ~/Downloads/movie.mkv.crdownload ~/Downloads/movie.mkv
# report.pdf is still there, overwritten rather than deleted, which isn't listed.
[[ -z $(deleted) ]] || fail "neither a file renamed over another nor a finished download is listed as deleted" "$(deleted)"
pass "a file renamed over another, or a finished download, isn't listed as deleted"

# A .DS_Store left behind doesn't make a folder whose files were all moved out
# a deleted one. (Folders moved whole are paired by inode, which only btrfs
# snapshots keep, so that is proved on a real one, not with these hard links.)
reset
mkdir -p ~/Old
echo c >~/Old/c.txt
echo junk >~/Old/.DS_Store
snapshot 1 1
mkdir ~/Archive
mv ~/Old/c.txt ~/Archive/
rm -r ~/Old
[[ -z $(deleted) ]] || fail "a folder emptied but for a hidden file isn't listed as deleted" "$(deleted)"
pass "a folder emptied but for a hidden file isn't listed as deleted"

# Asked about a folder inside one that's back but not whole, it still answers.
reset
mkdir -p ~/Pictures/trip
echo a >~/Pictures/trip/a.jpg
echo b >~/Pictures/trip/b.jpg
snapshot 1 2
rm -r ~/Pictures
# A snapshot after it went, so only the comparison of the two snapshots knows.
snapshot 2 1
[[ $(deleted ~/Pictures/trip) == "Pictures/trip/" ]] || fail "deleted answers for a folder inside one that went whole" "$(deleted ~/Pictures/trip)"
"$files" restore ~/Pictures/trip/a.jpg >/dev/null
[[ $(deleted ~/Pictures/trip) == "Pictures/trip/b.jpg" ]] || fail "deleted narrows to a folder inside one that's partly back" "$(deleted ~/Pictures/trip)"
pass "deleted narrows to a folder inside one that went whole, or is partly back"

# Read-only folders come back, as read-only as they were.
reset
mkdir -p ~/go/pkg/mod/lib
echo code >~/go/pkg/mod/lib/lib.go
chmod 0555 ~/go/pkg/mod/lib ~/go/pkg/mod
snapshot 1 1
chmod -R u+w ~/go && rm -r ~/go
"$files" restore ~/go/pkg/mod/lib >/dev/null
[[ $(cat ~/go/pkg/mod/lib/lib.go) == "code" && $(stat -c %a ~/go/pkg/mod) == "555" && $(stat -c %a ~/go/pkg/mod/lib) == "555" ]] ||
  fail "restore brings back read-only folders as they were" "$(stat -c '%a %n' ~/go/pkg/mod ~/go/pkg/mod/lib)"
! compgen -G "$HOME/go/pkg/mod/.*restoring*" >/dev/null || fail "restore leaves no partial copy beside a read-only folder"
chmod -R u+w ~/go
pass "restore brings back read-only folders as they were"

# A folder of nothing but hidden files was deleted, not emptied by moves.
reset
mkdir -p ~/keys
echo secret >~/keys/.env
snapshot 1 1
rm -r ~/keys
[[ $(deleted) == "keys/" ]] || fail "a deleted folder of only hidden files is listed" "$(deleted)"
pass "a deleted folder of only hidden files is listed"

# A folder whose only file, a hidden one, was moved out was emptied, not deleted.
reset
mkdir -p ~/keys ~/app
echo secret >~/keys/.env
snapshot 1 1
mv ~/keys/.env ~/app/
rmdir ~/keys
"$files" deleted --json | jq -e '.files == []' >/dev/null || fail "a folder emptied of its hidden files by moves isn't listed" "$(deleted)"
pass "a folder emptied of its hidden files by moves isn't listed"

