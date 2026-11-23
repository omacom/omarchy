#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

files="$ROOT/bin/omarchy-snapshot-files"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

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

[[ -f "$HOME/.cache/omarchy/snapshot-files/1-2.json" && -f "$HOME/.cache/omarchy/snapshot-files/2-3.json" ]] ||
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
