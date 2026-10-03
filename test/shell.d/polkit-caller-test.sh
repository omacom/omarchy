#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export OMARCHY_PROC_PATH="$test_tmp/proc"
export PATH="$ROOT/bin:$PATH"

# fake_process <pid> <ppid> <comm> <euid> <exe or ""> <argv...>
# Every fake process was started by this user, so its real uid is ours.
fake_process() {
  local pid=$1 ppid=$2 comm=$3 euid=$4 exe=$5
  shift 5
  local dir="$OMARCHY_PROC_PATH/$pid"
  mkdir -p "$dir"
  printf '%s\n' "$comm" >"$dir/comm"
  printf '%s (%s) S %s %s %s 0 -1\n' "$pid" "$comm" "$ppid" "$ppid" "$ppid" >"$dir/stat"
  printf 'Name:\t%s\nUid:\t%s\t%s\t%s\t%s\n' "$comm" "$UID" "$euid" "$euid" "$euid" >"$dir/status"
  if [[ -n $exe ]]; then
    ln -s "$exe" "$dir/exe"
  fi
  printf '%s\0' "$@" >"$dir/cmdline"
}

# caller <shown command>: the program is the shown command's first word, as the
# prompt splits it.
caller() {
  timeout 5 omarchy-polkit-caller "${1%% *}" "$1"
}

# expect_chain <shown command> <chain> <description>
expect_chain() {
  local output actual
  output=$(caller "$1") || fail "$3" "no match for $1"
  actual=$(jq -r .requestedBy <<<"$output")
  [[ $actual == "$2" ]] || fail "$3" "expected: $2"$'\n'"actual:   $actual"
  pass "$3"
}

# expect_json <shown command> <expected json> <description>
expect_json() {
  local actual
  actual=$(caller "$1") || fail "$3" "no match for $1"
  [[ $actual == "$2" ]] || fail "$3" "expected: $2"$'\n'"actual:   $actual"
  pass "$3"
}

# expect_no_match <shown command> <description>
expect_no_match() {
  if caller "$1" >/dev/null; then
    fail "$2"
  fi
  pass "$2"
}

# shortened <command>: how pkexec's message shows a command, in bytes.
shortened() {
  local LC_ALL=C text=$1
  if ((${#text} > 80)); then
    text="${text:0:38} ... ${text: -37}"
  fi
  printf '%s' "$text"
}

# remove_process <pid...>: fixtures that could count against later prompts go
# once their own checks are done.
remove_process() {
  local pid
  for pid in "$@"; do
    rm -r "${OMARCHY_PROC_PATH:?}/$pid"
  done
}

# init, not systemd, so only the pid check stops the walk; fusermount3 is an
# unrelated root process for this user that must not get in the way.
fake_process 1 0 init 0 "" /sbin/init
printf 'Name:\tinit\nUid:\t0\t0\t0\t0\n' >"$OMARCHY_PROC_PATH/1/status"
fake_process 900 1 systemd "$UID" /usr/lib/systemd/systemd /usr/lib/systemd/systemd --user
fake_process 950 900 fusermount3 0 "" fusermount3 -o rw,nosuid /run/user/doc
fake_process 1000 900 foot "$UID" /usr/bin/foot foot
fake_process 1001 1000 bash "$UID" /usr/bin/bash -bash
fake_process 1002 1001 omarchy-update "$UID" /usr/bin/bash /bin/bash /usr/share/omarchy/bin/omarchy-update
fake_process 1003 1002 pkexec 0 "" pkexec --user root --disable-internal-agent /usr/bin/pacman -Syu --noconfirm

expect_json "/usr/bin/pacman -Syu --noconfirm" \
  '{"requestedBy":"omarchy-update ← bash ← foot","command":"/usr/bin/pacman -Syu --noconfirm","shortened":false}' \
  "caller names the processes above pkexec, stopping at systemd, and passes on its command"
expect_no_match "/usr/bin/pacman -Syu" "caller finds no match when pkexec runs something other than what polkit shows"

fake_process 1020 1000 pkexec 0 "" pkexec --user nobody /usr/bin/xyz
expect_no_match "/usr/bin/nobody /usr/bin/xyz" "caller never takes a pkexec option value for the program"

fake_process 1010 1000 pkexec 0 "" pkexec -u root /usr/bin/id
expect_chain "/usr/bin/id" "foot" "caller skips -u and its value"

# A process named pkexec that isn't running as root, and a setuid program
# another account started through a symlink named pkexec.
fake_process 2000 1000 pkexec "$UID" "" pkexec /usr/bin/pacman -Syu --noconfirm
fake_process 2001 1000 pkexec 0 "" pkexec -u root /usr/bin/pacman -Syu --noconfirm
printf 'Name:\tpkexec\nUid:\t%s\t0\t0\t0\n' $((UID + 1)) >"$OMARCHY_PROC_PATH/2001/status"
expect_chain "/usr/bin/pacman -Syu --noconfirm" "omarchy-update ← bash ← foot" "caller only counts processes running as root for this user"

fake_process 1100 1000 bash "$UID" /usr/bin/bash bash -c "pkexec --keep-cwd true"
fake_process 1101 1100 pkexec 0 "" pkexec --keep-cwd true
expect_json "/usr/bin/true" '{"requestedBy":"bash ← foot","command":"/usr/bin/true","shortened":false}' \
  "caller matches the program polkit shows against the bare name pkexec was given"

fake_process 1200 1000 pkexec 0 "" pkexec true
expect_no_match "/usr/bin/true" "caller finds no match when two pkexecs run the same program"
remove_process 1101 1200

# A relative program whose shortened message ends the same way still has to be
# the program polkit shows.
tool_arguments="--wipe --no-backup $(printf 'x%.0s' {1..60}) --really"
fake_process 1250 1000 pkexec 0 "" pkexec other $tool_arguments
expect_no_match "$(shortened "/usr/bin/tool $tool_arguments")" "caller only matches the program polkit shows, not another relative one"
remove_process 1250

# Commands whose shortened messages would start or end differently don't block.
tool_shown=$(shortened "/usr/bin/tool $tool_arguments")
fake_process 1260 1000 pkexec 0 "" pkexec /usr/bin/tool $tool_arguments
fake_process 1261 1000 sudo 0 "" sudo /opt/other/tool $tool_arguments
fake_process 1262 1000 sudo 0 "" sudo q "Z${tool_shown: -36}"
expect_chain "$tool_shown" "foot" "caller isn't blocked by commands whose messages would start or end differently"
remove_process 1260 1261 1262

# A pkexec the requesting process renamed or padded with options still counts,
# alone and next to a decoy.
fake_process 1300 1000 x 0 "" x --keep-cwd /usr/bin/fdisk -l
expect_chain "/usr/bin/fdisk -l" "foot" "caller finds a pkexec started under another name"
padding=()
for _ in {1..20}; do
  padding+=(--keep-cwd)
done
fake_process 1400 1000 pkexec 0 "" pkexec "${padding[@]}" /usr/bin/ip link
expect_chain "/usr/bin/ip link" "foot" "caller finds a pkexec padded with options"
fake_process 1450 1000 sudo 0 "" sudo p link
expect_chain "/usr/bin/ip link" "foot" "caller isn't blocked by a relative program whose path would end differently"
remove_process 1450

fake_process 1500 1000 pkexec 0 "" pkexec "${padding[@]}" /usr/bin/ufw allow evil
fake_process 1501 1000 pkexec 0 "" pkexec /usr/bin/ufw allow evil
expect_no_match "/usr/bin/ufw allow evil" "caller finds no match when a decoy sits next to a padded pkexec"
fake_process 1600 1000 y 0 "" y /usr/bin/parted -s /dev/sda mklabel gpt
fake_process 1601 1000 pkexec 0 "" pkexec /usr/bin/parted -s "/dev/sda mklabel" gpt
expect_no_match "/usr/bin/parted -s /dev/sda mklabel gpt" "caller finds no match when a decoy sits next to a renamed pkexec"
fake_process 1700 1000 pkexec 0 "" pkexec /usr/bin/dash -c "rm -rf ~"
fake_process 1701 1000 pkexec 0 "" pkexec /usr/bin/dash -c rm -rf "~"
expect_no_match "/usr/bin/dash -c rm -rf ~" "caller finds no match when a decoy splits the same text differently"
fake_process 1800 1000 pkexec 0 "" pkexec "/home/me/my dir/tool"
fake_process 1801 1000 pkexec 0 "" pkexec /home/me/my dir/tool
expect_no_match "/home/me/my dir/tool" "caller finds no match when a program path with a space could be either"

# Shell-quoting keeps argument boundaries, including empty and space-padded
# arguments polkit's message shows as-is.
fake_process 1900 1000 pkexec 0 "" pkexec /usr/bin/sed -e "s/a b/c/" notes
expect_json "/usr/bin/sed -e s/a b/c/ notes" '{"requestedBy":"foot","command":"/usr/bin/sed -e s/a\\ b/c/ notes","shortened":false}' \
  "caller shell-quotes the command so argument boundaries survive"
fake_process 1910 1000 pkexec 0 "" pkexec /usr/bin/printf "" x
expect_json "/usr/bin/printf  x" '{"requestedBy":"foot","command":"/usr/bin/printf '"''"' x","shortened":false}' \
  "caller matches and keeps an empty argument"
fake_process 1920 1000 pkexec 0 "" pkexec /usr/bin/touch "a "
expect_json "/usr/bin/touch a " '{"requestedBy":"foot","command":"/usr/bin/touch a\\ ","shortened":false}' \
  "caller matches and keeps an argument ending in a space"

# pkexec's message shortens past 80 bytes, counted in bytes.
eighty="/usr/bin/stat $(printf 'e%.0s' {1..66})"
fake_process 2100 1000 pkexec 0 "" pkexec /usr/bin/stat "${eighty#/usr/bin/stat }"
expect_chain "$eighty" "foot" "caller matches an 80-byte command shown whole"
eighty_one="/usr/bin/rmdir $(printf 'f%.0s' {1..66})"
fake_process 2110 1000 pkexec 0 "" pkexec /usr/bin/rmdir "${eighty_one#/usr/bin/rmdir }"
expect_no_match "$eighty_one" "caller doesn't match an 81-byte command shown whole"
expect_chain "$(shortened "$eighty_one")" "foot" "caller matches an 81-byte command shown shortened"

accented=$(printf '\xc3\xa9%.0s' {1..60})
fake_process 2200 1000 pkexec 0 "" pkexec /usr/bin/wc "$accented"
LC_ALL=C.UTF-8 expect_chain "$(shortened "/usr/bin/wc $accented")" "foot" "caller shortens by bytes in a UTF-8 locale"

long_source=/home/me/some/really/long/source/path/
long_target=/mnt/backup/another/long/destination/path/
fake_process 2300 1000 pkexec 0 "" pkexec --keep-cwd rsync -a --delete "$long_source" "$long_target"
joined="/usr/bin/rsync -a --delete $long_source $long_target"
expect_json "$(shortened "$joined")" "{\"requestedBy\":\"foot\",\"command\":\"$joined\",\"shortened\":false}" \
  "caller matches a command pkexec's message shortened, and passes it on whole"
remove_process 2300

# A real pkexec with a relative program the message shows resolved through a
# spaced or overlong directory, next to a decoy rendering the same message.
padding_text="--wipe --no-backup $(printf 'x%.0s' {1..60}) --really"
for resolved in "/tmp/a b/evil" "/tmp/a b/./evil" "/opt/a-rather-long-directory-for-tools/evil"; do
  if [[ $resolved == */./* ]]; then
    typed=./evil
  else
    typed=evil
  fi
  real="$resolved $padding_text"
  decoy="${real:0:38} harmless ${real: -37}"
  read -r -a decoy_words <<<"$decoy"
  fake_process 9600 1000 pkexec 0 "" pkexec "$typed" $padding_text
  fake_process 9601 1000 pkexec 0 "" pkexec "${decoy_words[@]}"
  expect_no_match "$(shortened "$real")" "caller finds no match when a decoy sits next to a pkexec run as $typed via ${resolved%/*}"
  remove_process 9600 9601
done

# pkexec takes an unknown option as the program, so one that looks like an
# option still counts, alone and next to a decoy.
for typed in -evil -uroot --user=root; do
  real="/home/me/bin/$typed $padding_text"
  decoy="${real:0:38} harmless ${real: -37}"
  read -r -a decoy_words <<<"$decoy"
  fake_process 9650 1000 pkexec 0 "" pkexec "$typed" $padding_text
  expect_chain "$(shortened "$real")" "foot" "caller finds a pkexec running $typed"
  fake_process 9651 1000 pkexec 0 "" pkexec "${decoy_words[@]}"
  expect_no_match "$(shortened "$real")" "caller finds no match when a decoy sits next to a pkexec running $typed"
  remove_process 9650 9651
done

# A replaced executable, a parent whose executable can't be read, and a comm
# with ") " in it.
fake_process 3001 900 foot "$UID" /usr/bin/foot foot
fake_process 3002 3001 "odd) name" "$UID" /usr/bin/odd odd
fake_process 3003 3002 sudo 0 "" sudo /usr/share/omarchy/bin/omarchy-update
fake_process 3004 3003 omarchy-update "$UID" "/usr/bin/bash (deleted)" /bin/bash /usr/share/omarchy/bin/omarchy-update
fake_process 3005 3004 pkexec 0 "" pkexec /usr/bin/journalctl
expect_chain "/usr/bin/journalctl" "omarchy-update ← sudo ← odd ← foot" "caller names replaced and unreadable executables and parses odd comms"

fake_process 4001 900 p1 "$UID" /usr/bin/p1 p1
for level in 2 3 4 5 6 7; do
  fake_process $((4000 + level)) $((3999 + level)) "p$level" "$UID" "/usr/bin/p$level" "p$level"
done
fake_process 4008 4007 pkexec 0 "" pkexec /usr/bin/lsblk
expect_chain "/usr/bin/lsblk" "p7 ← p6 ← p5 ← p4 ← p3" "caller walks at most five parents"

fake_process 5000 900 pkexec 0 "" pkexec /usr/bin/uptime
expect_chain "/usr/bin/uptime" "" "caller names nobody for a pkexec started by systemd"

fake_process 7100 1 pkexec 0 "" pkexec /usr/bin/whoami
expect_chain "/usr/bin/whoami" "" "caller names nobody for a pkexec whose parent is pid 1"

long=$(printf 'x%.0s' {1..60})
fake_process 6001 900 sh "$UID" /usr/bin/bash /bin/sh $'/tmp/evil\n\xe2\x80\xaename'
fake_process 6002 6001 sh "$UID" /usr/bin/bash /bin/sh $'/tmp/evil\n\xe2\x80\xaename'
fake_process 6003 6002 sh "$UID" /usr/bin/bash /bin/sh "/tmp/$long"
fake_process 6004 6003 pkexec 0 "" pkexec /usr/bin/systemctl restart sshd
expect_chain "/usr/bin/systemctl restart sshd" "${long:0:40}… ← evilname" "caller strips control and bidi characters, cuts long names and collapses repeats"

fake_process 7200 900 sh "$UID" /usr/bin/bash /bin/sh $'/opt/p\xe2\x80\x8fq\xe2\x80\xaa\xe2\x80\xadr\xe2\x81\xa0\xe2\x81\xa9\x7fs'
fake_process 7201 7200 pkexec 0 "" pkexec /usr/bin/loginctl
expect_chain "/usr/bin/loginctl" "pqrs" "caller strips characters from each hidden range"

forty=$(printf 'z%.0s' {1..40})
forty_one=$(printf 'y%.0s' {1..41})
fake_process 7300 900 sh "$UID" /usr/bin/bash /bin/sh "/opt/$forty"
fake_process 7301 7300 sh "$UID" /usr/bin/bash /bin/sh "/opt/$forty_one"
fake_process 7302 7301 pkexec 0 "" pkexec /usr/bin/timedatectl
expect_chain "/usr/bin/timedatectl" "${forty_one:0:40}… ← $forty" "caller keeps a 40-character name and cuts a 41-character one"

# pkexec's --disable-internal-agent is skipped, a Python script is named after
# the script, and a parent whose name comes out empty is left out.
fake_process 7400 1000 ghost "$UID" / ghost
fake_process 7401 7400 python3 "$UID" /usr/bin/python3.13 /usr/bin/python3 /opt/tool.py
fake_process 7402 7401 pkexec 0 "" pkexec --disable-internal-agent --keep-cwd /usr/bin/busctl
expect_chain "/usr/bin/busctl" "tool.py ← foot" "caller names Python scripts and leaves out empty names"

# Whatever the caller's locale: every hidden kind goes, other multibyte text
# stays, and the cut counts characters.
cjk=$(printf '\xe6\x97\xa5%.0s' {1..45})
fake_process 7001 900 sh "$UID" /usr/bin/bash /bin/sh $'/opt/a\xd8\x9c\xe6\x97\xa5\xe2\x80\x8b\xf0\x9f\x98\x80\xe2\x81\xa6\xc3\xa9\xef\xbb\xbf\xc2\x85\xe2\x80\xa8b'
fake_process 7002 7001 sh "$UID" /usr/bin/bash /bin/sh "/opt/$cjk"
fake_process 7003 7002 pkexec 0 "" pkexec /usr/bin/hostnamectl
LC_ALL=C expect_chain "/usr/bin/hostnamectl" "$(printf '\xe6\x97\xa5%.0s' {1..40})… ← a"$'\xe6\x97\xa5\xf0\x9f\x98\x80\xc3\xa9'"b" \
  "caller keeps other multibyte text and cuts by characters in any locale"

# A process can make its arguments as long as the kernel allows; the lookup must
# still finish quickly.
huge=$(printf 'h%.0s' {1..131000})
fake_process 8000 900 python3 "$UID" /usr/bin/python3.13 python3 "/opt/$huge"
fake_process 8001 8000 python3 "$UID" /usr/bin/python3.13 python3 "/opt/$huge"
fake_process 8002 8001 pkexec 0 "" pkexec /usr/bin/dmesg
expect_chain "/usr/bin/dmesg" "${huge:0:40}…" "caller handles huge process names quickly"

# The command is capped at 4000 characters, whether one argument or many are
# long, and marked shortened.
long_one=$(printf 'c%.0s' {1..3000})
long_two=$(printf 'd%.0s' {1..5000})
fake_process 8300 900 pkexec 0 "" pkexec /usr/bin/cp "$long_one" "$long_two" /tmp
output=$(caller "$(shortened "/usr/bin/cp $long_one $long_two /tmp")") || fail "caller caps a command with long arguments" "no match"
[[ $(jq -r '[(.command | length), .shortened] | @tsv' <<<"$output") == $'4000\ttrue' ]] || fail "caller caps a command with long arguments" "$output"
pass "caller caps a command with long arguments and marks it shortened"

many=()
for _ in {1..2500}; do
  many+=(a)
done
fake_process 8400 900 pkexec 0 "" pkexec /usr/bin/chmod "${many[@]}"
output=$(caller "$(shortened "/usr/bin/chmod ${many[*]}")") || fail "caller caps a command with many arguments" "no match"
[[ $(jq -r '[(.command | length), .shortened] | @tsv' <<<"$output") == $'4000\ttrue' ]] || fail "caller caps a command with many arguments" "$output"
pass "caller caps a command with many short arguments and marks it shortened"

# An unrelated root process with huge, slash-heavy arguments doesn't slow things.
slashes=$(printf 'a/%.0s' {1..65000})
fake_process 9700 900 helper 0 "" helper /x "$slashes" "$slashes" "$slashes"
expect_chain "/usr/bin/lsblk" "p7 ← p6 ← p5 ← p4 ← p3" "caller isn't slowed down by huge arguments in other processes"

# Quoting happens in the C locale, so non-ASCII and invisible characters show as
# escapes.
fake_process 9800 1000 pkexec 0 "" pkexec /usr/bin/echo $'\xc3\xa9\xe2\x80\xae'
output=$(caller $'/usr/bin/echo \xc3\xa9\xe2\x80\xae') || fail "caller quotes non-ASCII arguments" "no match"
quoted=$(jq -r .command <<<"$output")
[[ $quoted == *'\303\251\342\200\256'* ]] && ! LC_ALL=C grep -q $'[\x80-\xff]' <<<"$quoted" ||
  fail "caller quotes non-ASCII and invisible characters as escapes" "$quoted"
pass "caller quotes non-ASCII and invisible characters as escapes"

expect_no_match "/usr/bin/missing" "caller finds no match when no process runs the program"

# Another root process for this user whose command could end the way the message
# does could be the real pkexec, so it blocks matching; others don't.
fake_process 9900 1000 sudo 0 "" sudo nvim /etc/hosts
fake_process 9910 1000 su 0 "" su
expect_chain "/usr/bin/pacman -Syu --noconfirm" "omarchy-update ← bash ← foot" "caller isn't blocked by root processes whose commands end differently"
expect_no_match "/usr/bin/id" "caller finds no match while a root process without a program could be a pkexec running a shell"
fake_process 9920 1000 sudo 0 "" sudo pacman -Syu --noconfirm
expect_no_match "/usr/bin/pacman -Syu --noconfirm" "caller finds no match while another root process's command ends the same way"
