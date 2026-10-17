#!/bin/bash

# Runs the update, or a one-click install, for the update window: in its own
# session and pseudo-terminal, so neither closing the window nor restarting the
# shell can interrupt a pacman transaction. The window follows $dir/out and
# answers questions through the $dir/in FIFO; a window opened later replays out.

dir=${1:?usage: run.sh <state-dir> <command>}
command=${2:?usage: run.sh <state-dir> <command>}
here=$(dirname "$(realpath "$0")")

exec 9>"$dir/running"
flock -n 9 || exit 1

rm -f "$dir/in" "$dir/out" "$dir/hidden"
mkfifo -m 600 "$dir/in"
: >"$dir/out"
printf '%s\n' "$$" >"$dir/active"
# Held open for both ends so script never reads EOF between answers.
exec 3<>"$dir/in"

# sudo and gum announce their questions as OSC sequences the window turns into
# dialogs; everything else runs untouched. omarchy update sets its own PATH, so
# only installs meet the gum stand-in.
export PATH="$here/shims:$PATH" OMARCHY_UPDATE_WINDOW=1 TERM=dumb
export SUDO_PROMPT=$'\e]5150;password\a'

# The lock and the FIFO stay out of whatever the command leaves running.
SHELL=/bin/bash script -qefc "stty cols 110 rows 40 -echo; $command" /dev/null <&3 3>&- 9>&- >>"$dir/out" 2>&1
code=$?
printf '\e]5150;exit;%d\a' "$code" >>"$dir/out"
rm -f "$dir/active"
