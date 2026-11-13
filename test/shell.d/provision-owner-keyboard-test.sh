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
LOG_FILE=$tmp/log
OMARCHY_PATH=$ROOT
OMARCHY_FORM_DEFAULTS=$tmp/no-defaults
source "$ROOT/install/provisioning/setup-form.sh"
source "$tmp/keyboard.sh"
language=en
clear_logo() { echo "prompt" >>"$tmp/screen"; }
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
sed -n '/^run_setup() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner" | grep -qE '^ +keyboard_form \|\| return 1$' ||
  fail "a failed keyboard step fails the setup attempt, which offers retry or a console"
pass "a machine that can't set any layout fails the attempt after three tries, reaching setup's retry-or-console screen"

fresh_root
answers 'Danish|dk'
touch "$tmp/no-tty"
form || fail "off a console the layout is only persisted" "$(cat "$tmp/screen" "$tmp/log")"
! grep -q '^loadkeys' "$tmp/calls" || fail "loadkeys runs only on a virtual console" "$(cat "$tmp/calls")"
assert_layout dk "off a console"
pass "off a virtual console the layout is persisted and checked without loadkeys"

# First-boot setup's progress screen, which the ISO install dashboard draws too:
# install/provisioning/progress-icon.sh. It runs in a subshell so its globals and
# stubs stay out of the keyboard tests.
(
  # shellcheck disable=SC1091
  source "$ROOT/install/provisioning/progress-icon.sh"

  # The Linux VT draws a bright background (SGR 100-107) as the normal one
  # (40-47), so a frame must never ask for one: the grey half of a cell under
  # the green tip would vanish. Trace every step at every size the screen draws.
  for scale in 1 2 3; do
    progress_icon_build "$scale"
    for ((pm = 1; pm <= 1000; pm++)); do
      progress_icon_render "$pm"
    done >"$tmp/trace"
    ! grep -qaE $'\033\\[[0-9]+;10[0-7]m' "$tmp/trace" ||
      fail "the icon at scale $scale never asks for a bright background" "$(grep -aoE $'\033\\[[0-9]+;10[0-7]m.' "$tmp/trace" | sort -u | cat -v)"
  done
  pass "the traced icon never asks the VT for a bright background"

  # The icon is sized to the console font's real cell, which first boot can set
  # to sun12x22. Every grid column must still get the same whole number of
  # screen columns, or the icon loses its right edge or draws some strokes half
  # as wide. Its second grid row is three strokes one grid column wide.
  for cell in "8 16" "12 22" "9 19" "16 32"; do
    read -r CELL_WIDTH CELL_HEIGHT <<<"$cell"
    for scale in 1 2 3; do
      progress_icon_build "$scale"
      row=""
      for ((x = 0; x < ICON_WIDTH; x++)); do
        row+=${ICON_FILL[scale * ICON_WIDTH + x]}
      done
      read -ra strokes <<<"${row//0/ }"
      (( ${#strokes[@]} == 3 )) && [[ ${strokes[0]} == "${strokes[1]}" && ${strokes[1]} == "${strokes[2]}" ]] ||
        fail "a ${cell/ /x} font at scale $scale draws all three strokes of the icon's second row, equally wide" "$row"
    done
  done
  pass "every console font draws the whole icon with equally wide strokes"

  # Setup draws ten frames a second while it works the disk, so a frame must not
  # start processes: only every fifth reads the console size, and none runs sed.
  stty() { echo stty >>"$tmp/started"; echo "40 120"; }
  sed() { echo sed >>"$tmp/started"; command sed "$@"; }
  progress_icon_cell_size() { echo "8 16"; }
  progress_icon_layout /dev/null 78
  : >"$tmp/started"
  for ((frame = 1; frame <= 10; frame++)); do
    progress_icon_frame "$((frame * 50))" "Setting up your machine" "Tip: one of the tips"
  done >/dev/null
  ! grep -q '^sed$' "$tmp/started" && (( $(grep -c '^stty$' "$tmp/started") <= 2 )) ||
    fail "ten frames read the console size at most twice and run no sed" "$(sort "$tmp/started" | uniq -c)"
  pass "a frame starts no process except the console size check on every fifth"
)

# The steps around the keyboard: the language first boot opens in and applies,
# the order of the account questions, and the console font that decides what
# can be read. Functions as omarchy-provision-owner defines them, unrewritten.
lang=$tmp/language
mkdir -p "$lang"
export OMARCHY_FORM_DEFAULTS=$lang/no-defaults
source "$ROOT/install/provisioning/setup-form.sh"
source <(sed -n '/^fit_console_font() {/,/^}/p; /^initial_language() {/,/^}/p; /^configure_language() {/,/^}/p; /^keyboard_form() {/,/^}/p; /^user_form() {/,/^}/p; /^run_setup() {/,/^}/p' \
  "$ROOT/bin/omarchy-provision-owner")

LANGUAGE_FILE=$lang/attempt-language
LANGUAGE_MARKER=$lang/etc/omarchy/language
mkdir -p "${LANGUAGE_MARKER%/*}"
initial_language
[[ $language == "en" ]] || fail "no earlier choice or media marker means English"
printf 'ja\n' >"$LANGUAGE_MARKER"
initial_language
[[ $language == "ja" && $OMARCHY_FORM_LANGUAGE == "en" ]] || fail "the install media supplies the initial language"
printf 'de\n' >"$LANGUAGE_FILE"
initial_language
[[ $language == "de" && $OMARCHY_FORM_LANGUAGE == "de" ]] || fail "an earlier attempt wins over the media marker"
printf 'unknown\n' >"$LANGUAGE_FILE"
initial_language
[[ $language == "en" ]] || fail "an unknown earlier choice falls back to English"
rm "$LANGUAGE_FILE"
printf '../de\n' >"$LANGUAGE_MARKER"
initial_language
[[ $language == "en" ]] || fail "an unknown media choice falls back to English"
pass "initial language prefers the earlier attempt, then media, then English, validating both files"

mkdir -p "$lang/runtime/bin" "$lang/home/.config/omarchy" "$lang/home/.config/uwsm/env.d"
cat >"$lang/runtime/bin/omarchy-locale-generate" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$LOCALE_CALLS"
[[ ! -e $LOCALE_CALLS.fail ]]
EOF
chmod +x "$lang/runtime/bin/omarchy-locale-generate"
export LOCALE_CALLS=$lang/locale-calls
(
  OMARCHY_PATH=$lang/runtime
  username=owner
  getent() { echo "owner:x:1000:1000::$lang/home:/bin/bash"; }
  log_step() { echo "$1" >>"$lang/language-log"; }
  language=de
  configure_language
  [[ $(<"$LANGUAGE_MARKER") == "de" && $(<"$LOCALE_CALLS") == "de" ]] || fail "a non-English choice generates its locale and writes its marker"

  # An attempt that got as far as seeding German, then a retry that picks English.
  echo de >"$lang/home/.config/omarchy/language"
  echo 'export LANG=de_DE.UTF-8' >"$lang/home/.config/uwsm/env.d/50-omarchy-language"
  : >"$LOCALE_CALLS"
  language=en
  configure_language
  [[ ! -e $LANGUAGE_MARKER && ! -s $LOCALE_CALLS ]] || fail "English removes the marker without generating a locale"
  [[ ! -e $lang/home/.config/omarchy/language && ! -e $lang/home/.config/uwsm/env.d/50-omarchy-language ]] ||
    fail "a retry in another language forgets what the earlier attempt seeded for the account"

  # A locale that cannot be generated must not be named as anyone's language.
  # Called bare, as run_provisioning calls it: an `||` here would switch
  # errexit off inside the function and hide a failure it let through.
  touch "$LOCALE_CALLS.fail"
  language=fr
  set +e
  (set -e; configure_language)
  status=$?
  set -e
  ((status == 0)) || fail "a locale that cannot be generated does not fail setup"
  [[ ! -e $LANGUAGE_MARKER ]] || fail "a locale that cannot be generated leaves no marker"
  grep -q "could not generate the locale for fr" "$lang/language-log" || fail "the log says why the desktop stays English"
)
pass "language configuration generates before it persists, forgets an earlier attempt's seed, and survives a locale that cannot be generated"

(
  clear_logo() { :; }
  say() { printf '%s\n' "$*" >>"$lang/screen"; }
  log_step() { :; }
  notice() { fail "keyboard prompt unexpectedly failed" "$*"; }
  confirm_reboot() { fail "keyboard Esc must return to language selection"; }
  omarchy_persist_input_selection() { :; }
  apply_keyboard() { printf 'apply %s\n' "$1" >>"$lang/order"; }
  language_form() { echo language >>"$lang/order"; omarchy_form_use_language ja; }
  omarchy_prompt_keyboard() {
    echo keyboard >>"$lang/order"
    if [[ ! -f $lang/escaped ]]; then
      touch "$lang/escaped"
      return "$OMARCHY_FORM_BACK"
    fi
    keyboard=jp106
  }
  omarchy_form_use_language de
  keyboard_form >"$lang/output"
  [[ $(<"$lang/order") == $'keyboard\nlanguage\nkeyboard\napply jp106' ]] || fail "Esc visits the language picker before asking for the keyboard again" "$(cat "$lang/order")"
  [[ $(<"$lang/screen") == '--foreground 8 Setup stays in English. Omarchy will be in Japanese once set up.' ]] || fail "only the undrawn language gets the English notice" "$(cat "$lang/screen")"
  : >"$lang/screen"
  omarchy_form_use_language de
  keyboard_form >"$lang/output"
  [[ ! -s $lang/screen ]] || fail "a drawn language has no English notice"
)
pass "keyboard Esc returns to the language picker and only undrawn languages get the English notice"

(
  PROVISIONING_DIR=$lang/provisioning
  mkdir -p "$PROVISIONING_DIR"
  step() { :; }
  say() { printf '%s\n' "$*" >"$lang/continuing"; }
  omarchy_prompt_timezone() { echo timezone >>"$lang/questions"; }
  omarchy_prompt_username() { echo username >>"$lang/questions"; username=chosen; }
  omarchy_prompt_password() { echo password >>"$lang/questions"; }
  omarchy_prompt_hostname() { echo hostname >>"$lang/questions"; }
  user_form >"$lang/output"
  [[ $(<"$lang/questions") == $'timezone\nusername\npassword\nhostname' ]] || fail "account questions follow the installer's order" "$(cat "$lang/questions")"
  : >"$lang/questions"
  printf 'pinned-owner\n' >"$PROVISIONING_DIR/setup-user"
  user_form >"$lang/output"
  [[ $username == "pinned-owner" && $(<"$lang/questions") == $'timezone\npassword\nhostname' ]] || fail "a pinned username bypasses only its own question"
  grep -qF pinned-owner "$lang/continuing" || fail "the owner is told which account is being continued"
)
pass "account questions ask timezone, username, password, hostname and preserve a pinned username"

# Translated prompts are only readable in the font that draws them. Each case
# is a console (tty's answer) and whether Terminus could be set on it.
drawn_languages() {
  local console=$1 terminus=$2
  (
    tty() { echo "$console"; }
    omarchy_console_font() { return "$terminus"; }
    fit_console_font
    echo "$OMARCHY_FORM_CONSOLE_LANGUAGES"
  )
}
[[ $(drawn_languages /dev/tty1 0) == *" de "* ]] || fail "Terminus on the console keeps every language it draws"
[[ $(drawn_languages /dev/tty1 1) == "en" ]] || fail "a console left in the kernel's font reads English only"
[[ $(drawn_languages /dev/pts/3 1) == *" de "* ]] || fail "a terminal that is not the console is not limited by the console font"
(
  tty() { echo /dev/tty1; }
  omarchy_console_font() { return 1; }
  fit_console_font
  omarchy_form_use_language ru
  [[ $language == "ru" && $OMARCHY_FORM_LANGUAGE == "en" && $(omarchy_form_language_label ru) == "Russian" ]] ||
    fail "without Terminus a language is still chosen, but listed and asked in English"
)
pass "setup is translated only on a console set in the font that draws the translation"

(
  platform_ready() { :; }
  fit_console_font() { echo font >>"$lang/setup-order"; }
  initial_language() { echo initial >>"$lang/setup-order"; }
  language_form() { echo language >>"$lang/setup-order"; }
  keyboard_form() { echo keyboard >>"$lang/setup-order"; }
  user_form() { echo account >>"$lang/setup-order"; }
  confirm_form() {
    echo review >>"$lang/setup-order"
    [[ -e $lang/reviewed ]] && return 0
    touch "$lang/reviewed"
    return 1
  }
  rekey_accepts_password() { return 0; }
  load_tips() { exit 0; }
  run_setup
)
[[ $(<"$lang/setup-order") == $'font\ninitial\nlanguage\nkeyboard\naccount\nreview\nkeyboard\naccount\nreview' ]] || fail "declining review returns to the keyboard and account steps" "$(cat "$lang/setup-order")"
(
  platform_ready() { :; }
  fit_console_font() { :; }
  initial_language() { :; }
  language_form() { :; }
  keyboard_form() { return 1; }
  user_form() { fail "a failed keyboard step must stop setup before account questions"; }
  status=0
  run_setup || status=$?
  (( status == 1 )) || fail "a failed keyboard step fails the setup attempt"
)
pass "setup asks language, keyboard, account, review and preserves its keyboard failure gate"

source "$ROOT/install/provisioning/console-font.sh"
status=0
omarchy_console_font /dev/pts/3 || status=$?
(( status == 1 )) || fail "a pseudoterminal cannot have its console font changed"
pass "console font rejects non-VT paths"

# Opening a readable VT supplies only the redirect; every console command is fake.
font_tty=""
for candidate in /dev/tty[0-9]*; do
  if [[ -r $candidate ]] && ( : <"$candidate" ) 2>/dev/null; then
    font_tty=$candidate
    break
  fi
done
if [[ -z $font_tty ]]; then
  skip "no readable VT without root; skipping console font sizing and build failure"
  exit 0
fi

mkdir -p "$lang/bin"
cat >"$lang/bin/stty" <<'EOF'
#!/bin/bash
printf '%s\n' "$FONT_ROWS $FONT_COLS"
EOF
cat >"$lang/bin/showconsolefont" <<'EOF'
#!/bin/bash
printf '%sx%s\n' "$FONT_WIDTH" "$FONT_HEIGHT"
EOF
cat >"$lang/bin/python3" <<'EOF'
#!/bin/bash
printf 'build %s\n' "$2" >>"$FONT_CALLS"
[[ ${FONT_BUILD_FAIL:-0} == 0 ]] || exit 1
printf 'built font\n' >"$3"
EOF
cat >"$lang/bin/setfont" <<'EOF'
#!/bin/bash
printf 'set %s\n' "$*" >>"$FONT_CALLS"
EOF
chmod +x "$lang/bin/"*
export PATH="$lang/bin:$PATH" FONT_CALLS=$lang/font-calls OMARCHY_CONSOLE_FONT_DIR=$lang/fonts
# The last two are one 2560x1104 display in either font: the answer must not depend on which.
for geometry in '50 160 8 16 ter-v16b' '100 320 8 16 ter-v32b' '50 160 16 32 ter-v32b' '69 320 8 16 ter-v16b' '34 160 16 32 ter-v16b'; do
  read -r FONT_ROWS FONT_COLS FONT_WIDTH FONT_HEIGHT expected <<<"$geometry"
  export FONT_ROWS FONT_COLS FONT_WIDTH FONT_HEIGHT
  rm -rf "$OMARCHY_CONSOLE_FONT_DIR"
  : >"$FONT_CALLS"
  omarchy_console_font "$font_tty" || fail "console font can be built for $geometry"
  [[ $(<"$FONT_CALLS") == "build /usr/share/kbd/consolefonts/$expected.psf.gz"$'\n'"set -C $font_tty $OMARCHY_CONSOLE_FONT_DIR/$expected.psf" ]] ||
    fail "console font sizes from pixels for $geometry" "$(cat "$FONT_CALLS")"
done
pass "console font uses 16px for 160x50 and 32px for large displays, and one display gets one size from either font"

rm -rf "$OMARCHY_CONSOLE_FONT_DIR"
: >"$FONT_CALLS"
status=0
FONT_BUILD_FAIL=1 omarchy_console_font "$font_tty" || status=$?
(( status == 1 )) && ! grep -q '^set ' "$FONT_CALLS" || fail "a font that cannot be built fails without applying it"
pass "console font reports a failed build without calling setfont"
