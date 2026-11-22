#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# First-boot setup is drawn in kmscon (install/provisioning/kmscon.sh), which
# takes its keyboard layout and font once, at its start. The password is typed
# at boot in the layout /etc/vconsole.conf names, so setup must have kmscon
# started again when the keyboard step changes that layout, and must fall back
# to the console when kmscon never shows it.

tmp=$(cd -- "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$tmp"' EXIT

root=$tmp/root
stub_bin=$tmp/bin
conf=$root/etc/vconsole.conf
state=$tmp/state
mkdir -p "$stub_bin" "$root/etc" "$root/dri"

sed -e "s|/etc/|$root/etc/|g" -e "s|/proc/cmdline|$root/cmdline|g" -e "s|/dev/dri|$root/dri|g" -e "s|sleep 15|sleep 1|" \
  "$ROOT/install/provisioning/kmscon.sh" >"$tmp/kmscon.sh"
source "$tmp/kmscon.sh"

stub() {
  printf '#!/bin/bash\n%s\n' "$2" >"$stub_bin/$1"
  chmod +x "$stub_bin/$1"
}
export PATH="$stub_bin:$PATH"

# ── Where kmscon is tried ────────────────────────────────────────────────────

stub tty "echo /dev/tty1"
stub kmscon "exit 0"
echo "quiet splash" >"$root/cmdline"
touch "$root/dri/card0"
omarchy_kmscon_wanted || fail "kmscon is tried on a VT of a machine with a display device"
echo "quiet omarchy.kmscon=0" >"$root/cmdline"
omarchy_kmscon_wanted && fail "omarchy.kmscon=0 turns kmscon off"
echo "quiet" >"$root/cmdline"
stub tty "echo /dev/pts/3"
omarchy_kmscon_wanted && fail "kmscon is not started from inside a terminal"
stub tty "echo /dev/tty1"
rm "$root/dri/card0"
omarchy_kmscon_wanted && fail "kmscon is not tried with no DRM device to draw on"
touch "$root/dri/card0"
pass "kmscon is tried on a VT with a display device unless the kernel command line turns it off"

# ── The layout and the font it starts with ───────────────────────────────────

printf 'KEYMAP=us\nXKBLAYOUT=us\n' >"$conf"
[[ $(omarchy_kmscon_xkb) == "us - - -" ]] || fail "a US machine types US in kmscon" "$(omarchy_kmscon_xkb)"
printf 'KEYMAP=ua\nXKBLAYOUT=ua,us\nXKBMODEL=pc105\nXKBOPTIONS=terminate:ctrl_alt_bksp,grp:shifts_toggle\n' >"$conf"
[[ $(omarchy_kmscon_xkb) == "ua,us pc105 - terminate:ctrl_alt_bksp,grp:shifts_toggle" ]] ||
  fail "kmscon types the XKB layout vconsole.conf names" "$(omarchy_kmscon_xkb)"
[[ $(omarchy_kmscon_face ja) == "Noto Sans Mono CJK JP" && $(omarchy_kmscon_face ko) == "Noto Sans Mono CJK KR" &&
  $(omarchy_kmscon_face zh-TW) == "Noto Sans Mono CJK TC" && $(omarchy_kmscon_face da) == "Noto Sans Mono CJK SC" ]] ||
  fail "Han characters are drawn in the language's forms"
pass "kmscon starts with the machine's XKB layout and the language's Han forms"

# ── Shown, or not ────────────────────────────────────────────────────────────

printf 'KEYMAP=de-latin1\nXKBLAYOUT=de\nXKBVARIANT=nodeadkeys\n' >"$conf"
stub kmscon "printf '%s\n' \"\$@\" >'$tmp/args'; env >'$tmp/env'; touch '$state/started'"
omarchy_kmscon_show "$state" ja "#00ff80" /usr/bin/setup || fail "a setup that ran in kmscon is reported as shown"
grep -qx -- '--xkb-layout=de' "$tmp/args" && grep -qx -- '--xkb-variant=nodeadkeys' "$tmp/args" && ! grep -q -- '--xkb-model' "$tmp/args" ||
  fail "kmscon is started with the machine's layout" "$(cat "$tmp/args")"
grep -qx -- '--font-name=Adwaita Mono,Noto Sans Mono CJK JP,monospace' "$tmp/args" || fail "kmscon is started with the language's font" "$(cat "$tmp/args")"
grep -qx -- '--palette-light-red=0, 255, 128' "$tmp/args" || fail "an OEM's colour is the palette's bright red" "$(cat "$tmp/args")"
[[ $(tail -n1 "$tmp/args") == /usr/bin/setup ]] || fail "kmscon runs the command it was given" "$(cat "$tmp/args")"
grep -qx 'OMARCHY_KMSCON=1' "$tmp/env" && grep -qx 'OMARCHY_KMSCON_XKB=de - nodeadkeys -' "$tmp/env" ||
  fail "the command learns it is in kmscon and under which layout" "$(grep KMSCON "$tmp/env")"

omarchy_kmscon_show "$state" en "" /usr/bin/setup >/dev/null
grep -qx -- '--palette-light-red=247, 118, 142' "$tmp/args" || fail "without an OEM colour bright red is Tokyo Night's" "$(cat "$tmp/args")"

stub kmscon "exit 1"
omarchy_kmscon_show "$state" en "" /usr/bin/setup && fail "a kmscon that failed to start is not reported as showing setup"

stub kmscon "exec sleep 60"
SECONDS=0
omarchy_kmscon_show "$state" en "" /usr/bin/setup && fail "a kmscon that never ran setup is not reported as showing it"
((SECONDS < 10)) || fail "a kmscon that never ran setup is stopped" "waited ${SECONDS}s"
pass "setup is shown in kmscon under the machine's layout, and a kmscon that never runs it is stopped"

# ── Started again when the keyboard step changes the layout ──────────────────

{
  sed -n '/^keyboard_form() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner"
} >"$tmp/keyboard.sh"
grep -q 'exit \$KMSCON_RELAUNCH' "$tmp/keyboard.sh" || fail "the keyboard step asks for kmscon to be started again"

cat >"$tmp/form.sh" <<SH
set -euo pipefail
source "$tmp/kmscon.sh"
source "$tmp/keyboard.sh"
KMSCON_RESUME=$tmp/resume
KMSCON_RELAUNCH=75
language=\$1 chosen=\$2 keyboard_label=German keyboard_input_method=none keyboard_xkb_layout=""
clear_logo() { :; }
omarchy_form_language_drawn() { :; }
omarchy_persist_input_selection() { :; }
omarchy_prompt_keyboard() { keyboard=\$chosen; }
apply_keyboard() { printf 'KEYMAP=%s\nXKBLAYOUT=%s\n' "\$1" "\$1" >"$conf"; }
keyboard_form
echo "password form"
SH

form() {
  local status=0
  rm -f "$tmp/resume"
  printf 'KEYMAP=us\nXKBLAYOUT=us\n' >"$conf"
  out=$(OMARCHY_KMSCON=${3-1} OMARCHY_KMSCON_XKB="us - - -" OMARCHY_KMSCON_FACE="Noto Sans Mono CJK SC" bash "$tmp/form.sh" "$1" "$2") || status=$?
  return "$status"
}

form en us || fail "the layout kmscon started with needs no relaunch"
[[ $out == *"password form" && ! -e $tmp/resume ]] || fail "an unchanged layout goes straight to the password form" "$out"

status=0
form en de || status=$?
[[ $status == 75 && $out != *"password form"* ]] || fail "another layout stops the attempt before the password form" "status $status: $out"
(source "$tmp/resume" && [[ $language == en && $keyboard == de && $keyboard_label == German ]]) ||
  fail "the answers so far are saved for the relaunch" "$(cat "$tmp/resume" 2>&1)"
[[ $(stat -c %a "$tmp/resume") == 600 ]] || fail "the saved answers are root's alone"

status=0
form ja us || status=$?
[[ $status == 75 ]] || fail "a language with other Han forms has kmscon started again" "status $status"

form en de "" || fail "on the console a new layout needs no relaunch"
[[ $out == *"password form" && ! -e $tmp/resume ]] || fail "the console carries on to the password form" "$out"
pass "the keyboard step has kmscon started again for a new layout or other Han forms, with the answers saved"
