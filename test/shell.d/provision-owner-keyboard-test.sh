#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# First-boot setup's keyboard step. The owner types the disk password at boot in
# the layout /etc/vconsole.conf names, so a layout that did not load, did not
# persist, or does not read back must be asked for again before the password
# form. keyboard_form and apply_keyboard run as omarchy-provision-owner defines
# them, against a fixture root, with loadkeys, localectl and systemd-firstboot
# faked.

tmp=$(cd -- "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$tmp"' EXIT

root=$tmp/root
stub_bin=$tmp/bin
conf=$root/etc/vconsole.conf
mkdir -p "$stub_bin"

# Each fake takes its next behaviour from a queue file, and behaves normally
# once the queue is empty.
cat >"$stub_bin/next-mode" <<'SH'
#!/bin/bash
queue=$1
[[ -s $queue ]] || { echo normal; exit 0; }
head -n1 "$queue"
sed -i 1d "$queue"
SH
cat >"$stub_bin/tty" <<SH
#!/bin/bash
[[ -e "$tmp/no-tty" ]] && { echo "not a tty"; exit 1; }
echo /dev/tty1
SH
cat >"$stub_bin/loadkeys" <<SH
#!/bin/bash
echo "loadkeys \$*" >>"$tmp/calls"
[[ \$("$stub_bin/next-mode" "$tmp/loadkeys-modes") == normal ]] || { echo "cannot open file \$1" >&2; exit 1; }
SH
cat >"$stub_bin/localectl" <<SH
#!/bin/bash
args=("\$@")
[[ \${args[0]} == --no-pager ]] && args=("\${args[@]:1}")
case \${args[0]} in
  list-keymaps)
    [[ \$("$stub_bin/next-mode" "$tmp/list-modes") == normal ]] || { echo "Failed to connect to bus" >&2; exit 1; }
    printf '%s\n' bg-cp1251 colemak cz de-latin1 dk fr pl ua us
    ;;
  set-keymap)
    echo "localectl set-keymap \${args[1]}" >>"$tmp/calls"
    [[ \$("$stub_bin/next-mode" "$tmp/localectl-modes") == normal ]] || exit 1
    printf 'KEYMAP=%s\nXKBLAYOUT=%s\n' "\${args[1]}" "\${args[1]}" >"$conf"
    ;;
  *) exit 1 ;;
esac
SH
cat >"$stub_bin/systemd-firstboot" <<SH
#!/bin/bash
keymap=\${1#--keymap=}
echo "systemd-firstboot \$*" >>"$tmp/calls"
case \$("$stub_bin/next-mode" "$tmp/firstboot-modes") in
  normal) printf 'KEYMAP=%s\nXKBLAYOUT=%s\nXKBMODEL=pc105\n' "\$keymap" "\$keymap" >"$conf" ;;
  nothing) ;;
  mismatch) printf 'KEYMAP=us\nXKBLAYOUT=us\n' >"$conf" ;;
  no-xkb) printf 'KEYMAP=%s\n' "\$keymap" >"$conf" ;;
  fail) echo "Failed to write vconsole.conf" >&2; exit 1 ;;
esac
SH
chmod +x "$stub_bin"/*
export PATH="$stub_bin:$PATH"

{
  sed -n '/^keyboard_form() {/,/^}/p; /^keyboard_xkb_settings() {/,/^}/p; /^apply_keyboard() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner"
  sed -n '/^omarchy_persist_input_selection() {/,/^}/p' "$ROOT/install/provisioning/setup-form.sh"
} | sed "s|/etc/|$root/etc/|g" >"$tmp/keyboard.sh"
grep -q '^keyboard_form() {' "$tmp/keyboard.sh" && grep -q '^apply_keyboard() {' "$tmp/keyboard.sh" ||
  fail "omarchy-provision-owner defines the keyboard step"

# The owner's answers, one "label|keymap" per prompt. Running out means the step
# asked once more than the test answered.
cat >"$tmp/form.sh" <<SH
set -euo pipefail
source "$tmp/keyboard.sh"
LOG_FILE=$tmp/log
OMARCHY_FORM_BACK=2
step() { echo "prompt" >>"$tmp/screen"; }
notice() { echo "notice: \$1" >>"$tmp/screen"; }
log_step() { echo "\$1" >>"\$LOG_FILE"; }
confirm_reboot() { exit 5; }
omarchy_prompt_keyboard() {
  local answer
  answer=\$("$stub_bin/next-mode" "$tmp/answers")
  [[ \$answer != normal ]] || { echo "asked again" >>"$tmp/screen"; exit 9; }
  keyboard_label=\${answer%%|*}
  keyboard=\${answer#*|}
}
keyboard_form
echo "password form" >>"$tmp/screen"
SH

# A fresh deferred install: the placeholder US layout from the image build.
fresh_root() {
  rm -rf "$root" "$tmp"/*-modes "$tmp/answers" "$tmp/calls" "$tmp/screen" "$tmp/log" "$tmp/no-tty"
  mkdir -p "$root/etc"
  printf 'KEYMAP=us\nXKBLAYOUT=us\n' >"$conf"
  : >"$tmp/calls"
  : >"$tmp/log"
}

answers() {
  printf '%s\n' "$@" >"$tmp/answers"
}

form() {
  local status=0
  bash "$tmp/form.sh" || status=$?
  return "$status"
}

prompts() {
  grep -cx prompt "$tmp/screen" || true
}

assert_layout() {
  grep -qx "KEYMAP=$1" "$conf" && grep -q '^XKBLAYOUT=.' "$conf" || fail "$2: vconsole.conf holds $1" "$(cat "$conf")"
}

# Asked once more after the failure, with the reason on the screen and in the
# log, and only the second answer reaches the password form.
assert_asked_again() {
  local context=$1 log_line=$2
  [[ $(prompts) == 2 ]] || fail "$context: the keyboard is asked for again" "$(cat "$tmp/screen")"
  [[ $(sed -n 2p "$tmp/screen") == "notice: Could not set the Danish keyboard layout. Choose it again." ]] ||
    fail "$context: the owner is told the layout did not take" "$(cat "$tmp/screen")"
  [[ $(tail -n1 "$tmp/screen") == "password form" && $(grep -c 'password form' "$tmp/screen") == 1 ]] ||
    fail "$context: the password form comes only after a layout took" "$(cat "$tmp/screen")"
  grep -q "$log_line" "$tmp/log" || fail "$context: the log records the failure" "$(cat "$tmp/log")"
}

fresh_root
answers 'Danish|dk'
form || fail "a known layout is set" "$(cat "$tmp/screen" "$tmp/log")"
[[ $(prompts) == 1 ]] && ! grep -q '^notice' "$tmp/screen" || fail "a layout that takes is asked for once" "$(cat "$tmp/screen")"
grep -qx 'loadkeys dk' "$tmp/calls" && grep -qx 'systemd-firstboot --keymap=dk --force' "$tmp/calls" ||
  fail "the layout is loaded on the console and persisted" "$(cat "$tmp/calls")"
assert_layout dk "a known layout"
[[ $(<"$root/etc/omarchy/input-method") == $'INPUT_METHOD=none\nXKB_LAYOUT=' ]] ||
  fail "a known layout records no input method" "$(cat "$root/etc/omarchy/input-method" 2>&1)"
pass "a layout that loads, persists and reads back goes straight to the password form"

# systemd-firstboot writes only KEYMAP= for a keymap kbd-model-map lacks, as it
# does for Polish, Ukrainian and Colemak. Setup supplies the XKB layout.
fresh_root
answers 'Polish|pl'
echo no-xkb >"$tmp/firstboot-modes"
form || fail "a keymap firstboot has no XKB layout for is set" "$(cat "$tmp/screen" "$tmp/log")"
[[ $(prompts) == 1 ]] && ! grep -q '^notice' "$tmp/screen" || fail "Polish is asked for once" "$(cat "$tmp/screen")"
grep -qx 'XKBLAYOUT=pl' "$conf" || fail "Polish gets the pl XKB layout" "$(cat "$conf")"

fresh_root
answers 'Ukrainian|ua'
echo no-xkb >"$tmp/firstboot-modes"
form || fail "Ukrainian is set" "$(cat "$tmp/screen" "$tmp/log")"
grep -qx 'KEYMAP=ua' "$conf" && grep -qx 'XKBLAYOUT=ua,us' "$conf" &&
  grep -qx 'XKBOPTIONS=terminate:ctrl_alt_bksp,grp:shifts_toggle,grp_led:scroll' "$conf" ||
  fail "a non-Latin layout keeps a US layout to switch to" "$(cat "$conf")"

fresh_root
answers 'English (US, Colemak)|colemak'
echo no-xkb >"$tmp/firstboot-modes"
form || fail "Colemak is set" "$(cat "$tmp/screen" "$tmp/log")"
grep -qx 'XKBLAYOUT=us' "$conf" && grep -qx 'XKBVARIANT=colemak' "$conf" ||
  fail "Colemak is the us layout's colemak variant" "$(cat "$conf")"
# The desktop must type what the console does, or the shared password differs:
# kbd's cz is QWERTY and bg-cp1251 phonetic, unlike XKB's defaults.
fresh_root
answers 'Czech|cz'
echo no-xkb >"$tmp/firstboot-modes"
form || fail "Czech is set" "$(cat "$tmp/screen" "$tmp/log")"
grep -qx 'XKBLAYOUT=cz,us' "$conf" && grep -qx 'XKBVARIANT=qwerty,' "$conf" ||
  fail "Czech is QWERTY on the desktop as on the console" "$(cat "$conf")"

fresh_root
answers 'Bulgarian|bg-cp1251'
echo no-xkb >"$tmp/firstboot-modes"
form || fail "Bulgarian is set" "$(cat "$tmp/screen" "$tmp/log")"
grep -qx 'XKBLAYOUT=bg,us' "$conf" && grep -qx 'XKBVARIANT=phonetic,' "$conf" ||
  fail "Bulgarian is phonetic on the desktop as on the console" "$(cat "$conf")"
pass "a keymap systemd-firstboot has no XKB layout for gets one from setup"

# Every layout the form offers must end with an XKB layout: kbd-model-map's, or
# setup's own. A keymap in neither could never finish the keyboard step.
model_map=/usr/share/systemd/kbd-model-map
if [[ -r $model_map ]]; then
  source "$ROOT/install/provisioning/setup-form.sh"
  source "$tmp/keyboard.sh"
  while IFS='|' read -r label keymap _; do
    awk -v k="$keymap" '$1 == k { found = 1 } END { exit !found }' "$model_map" ||
      { declare -F keyboard_xkb_settings >/dev/null && keyboard_xkb_settings "$keymap" >/dev/null; } ||
      fail "the $label layout ($keymap) gets an XKB layout"
  done <<<"$OMARCHY_KEYBOARD_LAYOUTS"
  pass "every layout the form offers gets an XKB layout"
else
  echo "ok - # SKIP no $model_map to check the form's layouts against"
fi

fresh_root
answers 'Danish|dk' 'Danish|dk'
echo fail >"$tmp/loadkeys-modes"
form || fail "loadkeys failing once, then the retry" "$(cat "$tmp/screen" "$tmp/log")"
assert_asked_again "loadkeys fails" "loadkeys could not load keymap dk"
[[ $(grep -c '^systemd-firstboot' "$tmp/calls") == 1 ]] || fail "a layout the console refused is not persisted" "$(cat "$tmp/calls")"
assert_layout dk "after loadkeys failed once"
pass "a layout loadkeys refuses is asked for again"

fresh_root
answers 'Danish|dk' 'Danish|dk'
echo nothing >"$tmp/firstboot-modes"
form || fail "firstboot writing nothing, then the retry" "$(cat "$tmp/screen" "$tmp/log")"
assert_asked_again "firstboot writes nothing" "does not read back as keymap dk"
assert_layout dk "after firstboot wrote nothing once"
pass "a systemd-firstboot that writes nothing is asked for again"

for mode in mismatch no-xkb; do
  fresh_root
  answers 'Danish|dk' 'Danish|dk'
  echo "$mode" >"$tmp/firstboot-modes"
  form || fail "readback $mode, then the retry" "$(cat "$tmp/screen" "$tmp/log")"
  assert_asked_again "readback $mode" "does not read back as keymap dk"
  assert_layout dk "after readback $mode"
done
pass "a vconsole.conf that reads back another keymap, or no XKB layout, is asked for again"

# The readback runs in a clean shell: values this process exports never stand
# in for the file.
fresh_root
answers 'Danish|dk' 'Danish|dk'
echo nothing >"$tmp/firstboot-modes"
: >"$conf"
KEYMAP=dk XKBLAYOUT=dk form || fail "an exported layout, then the retry" "$(cat "$tmp/screen" "$tmp/log")"
assert_asked_again "exported KEYMAP" "does not read back as keymap dk"
pass "the readback ignores KEYMAP and XKBLAYOUT in the environment"

fresh_root
answers 'Danish|xx' 'Danish|dk'
form || fail "an unknown keymap, then the retry" "$(cat "$tmp/screen" "$tmp/log")"
assert_asked_again "unknown keymap" "keymap xx unknown to localectl"
! grep -q 'keymap=xx\|set-keymap xx' "$tmp/calls" || fail "an unknown keymap is never persisted" "$(cat "$tmp/calls")"
assert_layout dk "after an unknown keymap"
pass "a keymap localectl does not know is asked for again rather than keeping the default"

fresh_root
answers 'Danish|DK' 'Danish|dk'
form || fail "a keymap in the wrong case, then the retry" "$(cat "$tmp/screen" "$tmp/log")"
assert_asked_again "keymap case" "keymap DK unknown to localectl"
assert_layout dk "after a keymap in the wrong case"
pass "a keymap matches localectl's list exactly, case included"

fresh_root
answers 'Danish|dk' 'Danish|dk'
echo fail >"$tmp/list-modes"
form || fail "localectl failing to list keymaps, then the retry" "$(cat "$tmp/screen" "$tmp/log")"
assert_asked_again "localectl list fails" "localectl could not list keymaps to check dk"
[[ $(grep -c '^systemd-firstboot' "$tmp/calls") == 1 ]] || fail "a keymap that could not be checked is not persisted" "$(cat "$tmp/calls")"
pass "a keymap list localectl cannot produce is a failure, logged apart from an unknown keymap"

fresh_root
answers 'Danish|dk'
echo fail >"$tmp/firstboot-modes"
form || fail "localectl persists when firstboot fails" "$(cat "$tmp/screen" "$tmp/log")"
[[ $(prompts) == 1 ]] && grep -qx 'localectl set-keymap dk' "$tmp/calls" || fail "the localectl fallback persists the layout" "$(cat "$tmp/calls")"
assert_layout dk "the localectl fallback"
pass "a failed systemd-firstboot falls back to localectl, checked the same way"

fresh_root
answers 'Danish|dk' 'Danish|dk'
echo fail >"$tmp/firstboot-modes"
echo fail >"$tmp/localectl-modes"
form || fail "both persisting paths failing, then the retry" "$(cat "$tmp/screen" "$tmp/log")"
assert_asked_again "firstboot and localectl fail" "could not persist keymap dk"
pass "a layout neither systemd-firstboot nor localectl persists is asked for again"

# A layout that never takes keeps the owner at the keyboard step.
fresh_root
answers 'Danish|dk' 'Danish|dk'
printf 'fail\nfail\n' >"$tmp/loadkeys-modes"
if form; then fail "a layout that never loads does not end the keyboard step"; fi
[[ $(tail -n1 "$tmp/screen") == "asked again" ]] && ! grep -q 'password form' "$tmp/screen" ||
  fail "the password form is never reached while the layout fails" "$(cat "$tmp/screen")"
grep -qx 'KEYMAP=us' "$conf" || fail "the install's layout is left alone" "$(cat "$conf")"
pass "while the layout fails the owner never reaches the password form"

# A machine that can't set any layout (localectl gone for good) must not keep the
# owner at the keyboard step: after three failures in a row the attempt fails,
# and setup's own retry-or-console screen takes over.
fresh_root
answers 'Danish|dk' 'German|de-latin1' 'Danish|dk' 'Danish|dk'
printf 'fail\nfail\nfail\nfail\n' >"$tmp/list-modes"
status=0
form || status=$?
(( status == 1 )) || fail "a layout that can never be set fails the attempt" "status $status: $(cat "$tmp/screen")"
[[ $(prompts) == 3 ]] && [[ $(tail -n1 "$tmp/screen") == "notice: Setup could not set a keyboard layout on this machine." ]] ||
  fail "the keyboard step gives up after three failures, and says so" "$(cat "$tmp/screen")"
! grep -q 'password form' "$tmp/screen" || fail "a layout that can never be set never reaches the password form" "$(cat "$tmp/screen")"
grep -q 'no keyboard layout could be set after 3 attempts' "$tmp/log" || fail "the log records giving up" "$(cat "$tmp/log")"
sed -n '/^run_setup() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner" | grep -qx '    keyboard_form || return 1' ||
  fail "a failed keyboard step fails the setup attempt, which offers retry or a console"
pass "a machine that can't set any layout fails the attempt after three tries, reaching setup's retry-or-console screen"

fresh_root
answers 'Danish|dk'
touch "$tmp/no-tty"
form || fail "off a console the layout is only persisted" "$(cat "$tmp/screen" "$tmp/log")"
! grep -q '^loadkeys' "$tmp/calls" || fail "loadkeys runs only on a virtual console" "$(cat "$tmp/calls")"
assert_layout dk "off a console"
pass "off a virtual console the layout is persisted and checked without loadkeys"
