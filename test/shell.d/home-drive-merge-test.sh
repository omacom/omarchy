#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# home_drive_merge brings Omarchy's defaults into a home that already has a
# life: the user's files win, Omarchy's include lines are joined into the few
# files that layer on top of Omarchy's defaults, and a record says what
# happened. The skel here is built from this checkout's own config/ and
# default/bashrc, so the joined lines are the ones Omarchy actually ships.

source "$ROOT/install/provisioning/home-drive.sh"

tmp=$(mktemp -d)
trap 'chmod -R u+w "$tmp" 2>/dev/null; rm -rf "$tmp"' EXIT

skel=$tmp/skel
home=$tmp/home
mkdir -p "$skel/.config" "$skel/.local/state/omarchy/migrations"
cp -a "$ROOT/config/." "$skel/.config/"
cp "$ROOT/default/bashrc" "$skel/.bashrc"
: >"$skel/.local/state/omarchy/migrations/1.sh"

mkdir -p "$home/.config/kitty" "$home/.config/ghostty" "$tmp/elsewhere"
printf "alias ll='ls -l'\n" >"$home/.bashrc"
cp "$home/.bashrc" "$tmp/bashrc.original"
printf 'add_newline = false\n' >"$home/.config/starship.toml"
printf 'font_size 14\n' >"$home/.config/kitty/kitty.conf"
printf 'font-size = 12\n' >"$tmp/elsewhere/ghostty-config"
chmod a-w "$tmp/elsewhere/ghostty-config" "$tmp/elsewhere"
ln -s "$tmp/elsewhere/ghostty-config" "$home/.config/ghostty/config"

home_drive_merge "$skel" "$home"

# Exactly the environment line and an interactive-only source of Omarchy's
# rc: Omarchy's "return when not interactive" guard would also cut off the
# user's own lines for scripts and ssh commands that rely on them.
bootstrap=$(grep -m1 'env-bootstrap' "$skel/.bashrc")
expected=$(printf '%s\n%s\n\n%s' "$bootstrap" '[[ $- == *i* ]] && source "$OMARCHY_PATH/default/bash/rc"' "alias ll='ls -l'")
[[ $(cat "$home/.bashrc") == "$expected" ]] || fail "the adopted .bashrc gets Omarchy's environment and rc on top of the user's lines" "$(cat "$home/.bashrc")"
cmp -s "$home/.bashrc.before-omarchy" "$tmp/bashrc.original" || fail "the original .bashrc is kept beside it"
pass ".bashrc gets Omarchy's lines on top and keeps the user's below"

[[ $(head -n1 "$home/.config/kitty/kitty.conf") == include*current/theme/kitty.conf ]] || fail "kitty includes the Omarchy theme first" "$(cat "$home/.config/kitty/kitty.conf")"
grep -qx 'font_size 14' "$home/.config/kitty/kitty.conf" || fail "kitty keeps the user's setting"
pass "kitty.conf gets the theme include and keeps the user's settings"

[[ $(cat "$home/.config/starship.toml") == "add_newline = false" ]] || fail "a config Omarchy also ships is left as the user had it"
[[ -f $home/.config/hypr/hyprland.lua ]] || fail "a config the user did not have is copied in"
pass "the user's files win and Omarchy's missing files are added"

[[ -L $home/.config/ghostty/config ]] || fail "a symlinked config stays a symlink"
[[ $(cat "$tmp/elsewhere/ghostty-config") == "font-size = 12" ]] || fail "a symlink target the user cannot write is left alone"
record=$home/.local/state/omarchy/adopted-home
grep -q '^skipped-join .config/ghostty/config ' "$record" || fail "the record says why ghostty was not joined" "$(cat "$record")"
pass "a symlinked config the user cannot write is skipped and recorded"

grep -qx 'joined .bashrc backup .bashrc.before-omarchy' "$record" || fail "the record lists the joined .bashrc" "$(cat "$record")"
grep -qx 'kept .config/starship.toml' "$record" || fail "the record lists kept files" "$(cat "$record")"
grep -qx 'markers copied' "$record" || fail "the record says the migration markers were copied"
[[ $(tail -n1 "$record") == "omarchy-defaults /etc/skel \$OMARCHY_PATH/config" ]] || fail "the record says where Omarchy's own versions live"
[[ -f $home/.local/state/omarchy/migrations/1.sh ]] || fail "a home new to Omarchy gets the migration markers"
pass "the record lists what was kept, joined and copied"

before=$(cd "$home" && find . -type f ! -path ./.local/state/omarchy/adopted-home -print0 | sort -z | xargs -0 sha256sum)
home_drive_merge "$skel" "$home"
after=$(cd "$home" && find . -type f ! -path ./.local/state/omarchy/adopted-home -print0 | sort -z | xargs -0 sha256sum)
[[ $before == "$after" ]] || fail "merging a second time changes none of the user's files"
pass "merging again changes none of the user's files"

# The cycle this exists for: a home adopted before, now under a newer Omarchy
# (a reinstall from a newer ISO). It has Omarchy state of its own, so its
# migrations must run rather than be marked done, and defaults that are new
# since then must arrive.
mkdir -p "$skel/.config/hypr"
printf 'new\n' >"$skel/.config/hypr/new-in-v2.lua"
home_drive_merge "$skel" "$home"
[[ -f $home/.config/hypr/new-in-v2.lua ]] || fail "a re-adopted home gets defaults that are new since"
grep -qx 'markers kept' "$record" || fail "a re-adopted home keeps its migration history so migrations run" "$(cat "$record")"
[[ $(grep -c 'env-bootstrap' "$home/.bashrc") == 1 ]] || fail "joining twice does not add Omarchy's lines twice"
pass "re-adopting a home brings new defaults and lets its migrations run"

old=$tmp/old-omarchy-home
mkdir -p "$old/.local/state/omarchy"
home_drive_merge "$skel" "$old"
[[ ! -e $old/.local/state/omarchy/migrations/1.sh ]] || fail "a previous Omarchy home keeps its own migration history"
grep -qx 'markers kept' "$old/.local/state/omarchy/adopted-home" || fail "the record says the markers were kept"
pass "a previous Omarchy home's migration state is left to Omarchy's migrations"

# A dotfiles setup: ~/.bashrc is a link into a repository the user owns.
# The link stays, and the file it points at gets Omarchy's lines.
linked=$tmp/linked
mkdir -p "$linked/dotfiles"
printf "alias gs='git status'\n" >"$linked/dotfiles/bashrc"
ln -s dotfiles/bashrc "$linked/.bashrc"
home_drive_merge "$skel" "$linked"
[[ -L $linked/.bashrc ]] || fail "the dotfiles symlink stays a symlink"
grep -q 'default/bash/rc' "$linked/dotfiles/bashrc" || fail "the linked file the user owns is joined" "$(cat "$linked/.local/state/omarchy/adopted-home")"
pass "a symlinked dotfile is joined in the file it points at"

# A previous Omarchy home on a new machine: that machine's first-login steps
# (audio tuning, user units, platform setup) still have to run.
moved=$tmp/moved
mkdir -p "$moved/.local/state/omarchy/done"
: >"$moved/.local/state/omarchy/done/first-run-user"
home_drive_merge "$skel" "$moved"
[[ ! -e $moved/.local/state/omarchy/done/first-run-user ]] || fail "this machine's first-login steps run for a moved home"
pass "a moved Omarchy home runs this machine's first-login steps"

# A config the user can write in a folder they cannot: no backup or joined
# copy can be made there, so the file is left exactly as it was, not emptied.
locked=$tmp/locked
mkdir -p "$locked/.config/kitty"
printf 'font_size 15\n' >"$locked/.config/kitty/kitty.conf"
chmod a-w "$locked/.config/kitty"
home_drive_merge "$skel" "$locked"
chmod u+w "$locked/.config/kitty"
[[ $(cat "$locked/.config/kitty/kitty.conf") == "font_size 15" ]] || fail "a config that cannot be backed up is left untouched" "$(cat "$locked/.config/kitty/kitty.conf")"
grep -q '^skipped-join .config/kitty/kitty.conf ' "$locked/.local/state/omarchy/adopted-home" ||
  fail "the record says why it was not joined" "$(cat "$locked/.local/state/omarchy/adopted-home")"
pass "a config that cannot be backed up is never touched"

# A default that cannot be copied (a folder the user cannot write, a full
# drive) fails the merge, so setup stops or retries instead of finishing with
# a home missing the desktop's files.
blocked=$tmp/blocked
mkdir -p "$blocked/.config/hypr"
chmod a-w "$blocked/.config/hypr"
if home_drive_merge "$skel" "$blocked" 2>/dev/null; then
  chmod u+w "$blocked/.config/hypr"
  fail "a default that cannot be copied fails the merge"
fi
chmod u+w "$blocked/.config/hypr"
grep -q '^failed-copy .config/hypr/' "$blocked/.local/state/omarchy/adopted-home" ||
  fail "the record names what could not be copied" "$(cat "$blocked/.local/state/omarchy/adopted-home")"
home_drive_merge "$skel" "$blocked" || fail "once the folder is writable the merge completes"
[[ -f $blocked/.config/hypr/hyprland.lua ]] || fail "the retry copies what was missing"
pass "a failed copy fails the merge, and a retry completes it"

# A copy that failed is a partial merge (3), not a broken one: setup can
# warn and go on. A folder of Omarchy's that the user made a link (dangling
# too) or a file is their own layout, not a failure.
partial=$tmp/partial
mkdir -p "$partial/.config/hypr"
chmod a-w "$partial/.config/hypr"
status=0
home_drive_merge "$skel" "$partial" 2>/dev/null || status=$?
chmod u+w "$partial/.config/hypr"
((status == 3)) || fail "a merge that could not copy every default returns 3" "$status"
own=$tmp/own-layout
mkdir -p "$own/.config"
ln -s "$tmp/nowhere" "$own/.config/hypr"
printf 'not a folder\n' >"$own/.config/kitty"
status=0
home_drive_merge "$skel" "$own" 2>/dev/null || status=$?
((status == 0)) || fail "a link or a file where Omarchy has a folder does not fail the merge" "$status $(cat "$own/.local/state/omarchy/adopted-home")"
grep -q '^kept-parent .config/hypr/' "$own/.local/state/omarchy/adopted-home" || fail "a default under a linked folder is recorded as kept-parent" "$(cat "$own/.local/state/omarchy/adopted-home")"
grep -q '^kept-parent .config/kitty/' "$own/.local/state/omarchy/adopted-home" || fail "a default under a file is recorded as kept-parent"
[[ -L $own/.config/hypr && ! -e $tmp/nowhere ]] || fail "the user's link is left as it was"
pass "a partial merge returns 3, and the user's own layout is kept, not failed"

# A join that was interrupted after its backup was made: the .bashrc may be
# cut short. The join is rebuilt from the backup, which is never overwritten.
cut=$tmp/cut
mkdir -p "$cut"
printf "alias gs='git status'\n" >"$cut/.bashrc.before-omarchy"
printf '%s\n' "$bootstrap" >"$cut/.bashrc"
home_drive_merge "$skel" "$cut"
[[ $(cat "$cut/.bashrc.before-omarchy") == "alias gs='git status'" ]] || fail "an existing backup is never overwritten" "$(cat "$cut/.bashrc.before-omarchy")"
[[ $(tail -n1 "$cut/.bashrc") == "alias gs='git status'" && $(grep -c 'env-bootstrap' "$cut/.bashrc") == 1 ]] ||
  fail "an interrupted join is finished from the backup" "$(cat "$cut/.bashrc")"
# Cut short further on, with Omarchy's lines all there and the user's own only
# in part: Omarchy's lines do not make it a finished join.
late=$tmp/late
mkdir -p "$late"
printf "alias gs='git status'\nalias gd='git diff'\n" >"$late/.bashrc.before-omarchy"
{ _hd_join_lines "$skel/.bashrc" .bashrc; printf "\nalias gs='git status'\n"; } >"$late/.bashrc"
home_drive_merge "$skel" "$late"
[[ $(tail -n1 "$late/.bashrc") == "alias gd='git diff'" && $(grep -c 'env-bootstrap' "$late/.bashrc") == 1 && ! -e $late/.bashrc.before-omarchy.1 ]] ||
  fail "a join cut short among the user's own lines is finished from the backup" "$(cat "$late/.bashrc")"
pass "an interrupted join is finished from its backup"

# A backup from an earlier adoption, and a .bashrc the user has rewritten
# since without Omarchy's lines: their current file is what gets joined, and
# it gets a backup of its own beside the old one.
since=$tmp/since
mkdir -p "$since"
printf "alias old='x'\n" >"$since/.bashrc.before-omarchy"
printf "alias new='y'\n" >"$since/.bashrc"
home_drive_merge "$skel" "$since"
[[ $(tail -n1 "$since/.bashrc") == "alias new='y'" ]] || fail "the user's current .bashrc is joined, not an old backup" "$(cat "$since/.bashrc")"
[[ $(cat "$since/.bashrc.before-omarchy") == "alias old='x'" && $(cat "$since/.bashrc.before-omarchy.1") == "alias new='y'" ]] ||
  fail "both versions are kept" "$(ls -a "$since")"
pass "a .bashrc rewritten since an earlier backup is joined as it is now"
