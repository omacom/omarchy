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

  # The ISO draws this screen in Chinese inside kmscon, where a CJK character
  # takes two columns: lines center and cut by columns, not characters.
  ICON_COLS=40 ICON_TEXT_WIDTH=12
  line=$(LC_ALL=C.UTF-8 progress_icon_line "提示：中文")
  [[ $line == *$'\e[2K'"$(printf '%15s' '')"'提示：中文'* ]] ||
    fail "a ten-column Chinese line centers fifteen columns in" "$(cat -v <<<"$line")"
  # An icon-font glyph from the private use area stays one column.
  glyph=$(LC_ALL=C.UTF-8 printf '\ue900')
  line=$(LC_ALL=C.UTF-8 progress_icon_line "${glyph}abc")
  [[ $line == *$'\e[2K'"$(printf '%18s' '')$glyph"* ]] ||
    fail "a four-column icon line centers eighteen columns in" "$(cat -v <<<"$line")"
  LC_ALL=C.UTF-8 progress_icon_truncate cut "提示：中文宽度测试"
  [[ $cut == "提示：中文…" ]] || fail "Chinese text is cut to twelve columns" "$cut"
  ICON_TEXT_WIDTH=0
  LC_ALL=C.UTF-8 progress_icon_truncate cut "提示"
  [[ $cut == "…" ]] || fail "a console with no room for text shows only the ellipsis" "$cut"
  pass "Chinese lines center and cut by the columns they take"
)

# The steps around the keyboard: the language first boot opens in and applies,
# the order of the account questions, and the console font that decides what
# can be read. Functions as omarchy-provision-owner defines them, unrewritten.
lang=$tmp/language
mkdir -p "$lang"
export OMARCHY_FORM_DEFAULTS=$lang/no-defaults
source "$ROOT/install/provisioning/setup-form.sh"
source <(sed -n '/^fit_console_font() {/,/^}/p; /^initial_language() {/,/^}/p; /^configure_language() {/,/^}/p; /^keyboard_form() {/,/^}/p; /^user_form() {/,/^}/p; /^clear_logo() {/,/^}/p; /^brand_logo() {/,/^}/p; /^brand_console_font() {/,/^}/p; /^confirm_shutdown() {/,/^}/p; /^eula_form() {/,/^}/p; /^run_setup() {/,/^}/p' \
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
  # Esc on the agreement the first time it is shown.
  eula_form() {
    echo agreement >>"$lang/setup-order"
    [[ -e $lang/agreed ]] && return 0
    touch "$lang/agreed"
    return "$OMARCHY_FORM_BACK"
  }
  load_tips() { exit 0; }
  run_setup
)
[[ $(<"$lang/setup-order") == $'font\ninitial\nlanguage\nkeyboard\naccount\nreview\nkeyboard\naccount\nreview\nagreement\nkeyboard\naccount\nreview\nagreement' ]] ||
  fail "declining review, or Esc on the agreement that follows it, returns to the keyboard and account steps" "$(cat "$lang/setup-order")"
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
pass "setup asks language, keyboard, account, review, then the agreement, and preserves its keyboard failure gate"

# The OEM's part of first boot: what its bundle names for setup's screens, and
# its agreement, read and answered with keys the test queues.
oem=$tmp/oem
mkdir -p "$oem/bundle" "$oem/state"
source "$ROOT/install/provisioning/oem.sh"
source <(sed -n '/^record_eula() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner" | sed "s|/var/lib/omarchy/oem|$oem/state|g")
export OMARCHY_OEM_DIR=$oem/bundle
omarchy_oem_tty=/dev/null

omarchy_oem_load
[[ -z $OMARCHY_OEM_NAME$OMARCHY_OEM_COLOR$OMARCHY_OEM_LOGO$OMARCHY_OEM_EULA ]] || fail "a machine no OEM prepared has no branding and no agreement"
printf '{"name":"Acme","tagline":"Built by Acme","color":"#ff6a00","eula_title":"Acme Agreement"}\n' >"$oem/bundle/oem.json"
printf 'ACME\n' >"$oem/bundle/logo.txt"
{
  printf 'Line %d\n' {1..39}
  printf 'wrapped %.0s' {1..40}
  printf '\nLine 40\n'
} >"$oem/bundle/eula.txt"
omarchy_oem_load
[[ $OMARCHY_OEM_NAME == "Acme" && $OMARCHY_OEM_TAGLINE == "Built by Acme" && $OMARCHY_OEM_COLOR == "#ff6a00" && $OMARCHY_OEM_EULA_TITLE == "Acme Agreement" ]] ||
  fail "the bundle names the OEM, its tagline, its colour and its agreement's title"
[[ $OMARCHY_OEM_LOGO == "$oem/bundle/logo.txt" && $OMARCHY_OEM_EULA == "$oem/bundle/eula.txt" ]] || fail "the bundle's logo and agreement are found beside it"
# The colour is written into a console escape, so only a colour may pass.
printf '{"name":"Acme","color":"#ff6a00]P0000000","eula_title":"Acme Agreement"}\n' >"$oem/bundle/oem.json"
omarchy_oem_load
[[ -z $OMARCHY_OEM_COLOR ]] || fail "a colour that is not #RRGGBB is not used"
pass "the OEM bundle supplies setup's branding and agreement, and only a real colour"

# A 24-row console: the logo gives way, leaving 13 rows of the agreement, whose
# 45 wrapped lines end "Line 40".
agreement() {
  local status=0
  (
    LINES=24 LOGO_WIDTH=81 LOGO_HEIGHT=10 PADDING_LEFT=0
    measure_terminal() { :; }
    clear_logo() { fail "a 24-row console has no room for the logo above the agreement"; }
    keys=("$@")
    omarchy_oem_read_key() {
      ((${#keys[@]})) || fail "the agreement waited for a key the test did not send"
      OMARCHY_OEM_KEY=${keys[0]}
      keys=("${keys[@]:1}")
    }
    omarchy_oem_eula >"$oem/screen"
  ) || status=$?
  return "$status"
}
shown() { grep -oF -- "$1" "$oem/screen" | wc -l; }

agreement enter || fail "Return on the agreement accepts it, the answer in focus"
(($(shown "Line 13") == 1 && $(shown "Line 14") == 0)) || fail "the agreement opens on its first rows"
grep -qF "Acme Agreement" "$oem/screen" || fail "the agreement is shown under the OEM's title"
OMARCHY_OEM_EULA_TITLE="" agreement enter
grep -qF "Acme License Agreement" "$oem/screen" || fail "an agreement without a title is named for the OEM"
agreement up pagedown enter || fail "paging keeps the agreement accepted on Return"
(($(shown "Line 25") == 1 && $(shown "Line 26") == 0)) || fail "a page down keeps one row of the page before, and up stops at the top"
agreement end pagedown down enter || fail "reading to the end and past it still accepts on Return"
(($(shown "Line 40") == 3 && $(shown "Line 33") == 3)) || fail "the end shows the last rows and stops there" "$(shown "Line 40") $(shown "Line 33")"
! grep -qE '(wrapped ){11}' "$oem/screen" || fail "a long paragraph is wrapped to the column"

status=0; agreement tab enter || status=$?
((status == OMARCHY_OEM_DECLINED)) || fail "Tab then Return declines" "$status"
agreement right left enter || fail "moving to Decline and back accepts"
status=0; agreement down escape || status=$?
((status == OMARCHY_FORM_BACK)) || fail "Esc goes back, as on every other step"
status=0; agreement interrupt || status=$?
((status == OMARCHY_FORM_SIGNAL)) || fail "Ctrl+C is the form's signal, not the end of setup"
pass "the agreement scrolls within its text, wraps it, and reports accept, decline, Esc and Ctrl+C"

# The keys as the Linux console sends them, through the reader itself: the
# arrows and paging keys, Tab, Space and Return, a function key it has no use
# for, and Esc with nothing after it.
(
  read_keys() {
    local names=() count=$1
    exec 9< <(printf "$2")
    omarchy_oem_tty=/dev/fd/9
    while ((count-- > 0)); do
      omarchy_oem_read_key
      names+=("${OMARCHY_OEM_KEY:-none}")
    done
    exec 9<&-
    echo "${names[*]}"
  }
  [[ $(read_keys 12 '\033[A\033[B\033[5~\033[6~\033[1~\033[4~\033[C\033[D\t \n\033[[A') == "up down pageup pagedown home end right left tab pagedown enter other" ]] ||
    fail "the console's keys are read by name"
  [[ $(read_keys 2 '\033') == "escape none" ]] || fail "Esc with nothing after it is Esc, and no key is none"
)
# Ctrl+C reaches the agreement as SIGINT, since bash's read keeps the
# console's signals on: it is the form's signal, and the caller's own trap is
# back afterwards.
(
  LINES=24 LOGO_WIDTH=81 LOGO_HEIGHT=10 PADDING_LEFT=0
  measure_terminal() { :; }
  eval "typed_$(declare -f omarchy_oem_read_key)"
  omarchy_oem_read_key() {
    kill -INT "$BASHPID"
    typed_omarchy_oem_read_key
  }
  trap : INT
  status=0
  omarchy_oem_eula >/dev/null || status=$?
  [[ $status == "$OMARCHY_FORM_SIGNAL" && $(trap -p INT) == "trap -- ':' SIGINT" ]] ||
    fail "Ctrl+C on the agreement is its signal status, and leaves the caller's trap in place" "$status $(trap -p INT)"
)
pass "the agreement reads the console's own key sequences, and takes Ctrl+C as a signal"

# A logo is art, and art can open with dashes: it is drawn, not read as an option.
if command -v gum >/dev/null; then
  (
    measure_terminal() { PADDING_LEFT=0; }
    LOGO_COLOR=2 LOGO_PATH=$oem/dashes.txt
    printf -- '--ACME--\n' >"$LOGO_PATH"
    clear_logo | grep -qF -- '--ACME--' || fail "a logo that opens with dashes is drawn"
  )
  pass "a logo that opens with dashes is drawn"
else
  skip "gum is not installed; a logo that opens with dashes is drawn"
fi

# Declining is not a dead end and not an accident: the owner goes back to the
# agreement unless they choose to shut down, and only accepting moves on.
cat >"$stub_bin/systemctl" <<SH
#!/bin/bash
echo "systemctl \$*" >>"$oem/calls"
SH
chmod +x "$stub_bin/systemctl"
# eula_form as setup runs it, with the console's font left alone.
agreement_form() {
  PADDING_LEFT=0 LOGO_WIDTH=81 LOGO_PATH=$oem/omarchy-logo.txt LOGO_HEIGHT=10 LOGO_COLOR=2 EULA_ACCEPTED_AT=""
  BRAND_LOGO_PATH=$OMARCHY_OEM_LOGO BRAND_LOGO_HEIGHT=1 BRAND_LOGO_COLOR=9
  brand_console_font() { :; }
  fit_console_font() { echo form-font >>"$oem/calls"; }
}
(
  agreement_form
  fit_console_font() { :; }
  clear_logo() { :; }
  say() { :; }
  answers=("$OMARCHY_OEM_DECLINED" "$OMARCHY_OEM_DECLINED" 0)
  omarchy_oem_eula() {
    local answer=${answers[0]}
    answers=("${answers[@]:1}")
    return "$answer"
  }
  # Ctrl+C while the screen after the agreement is being drawn.
  say() { kill -INT "$BASHPID"; }
  gum() {
    [[ " $* " == *" --default=false "* ]] || fail "shutting down must not be the answer in focus"
    echo ask >>"$oem/calls"
    return 1
  }
  eula_form >/dev/null
  [[ -z $(trap -p INT) ]] || fail "the agreement's Ctrl+C handling ends with it"
  [[ -n $EULA_ACCEPTED_AT && $(<"$oem/calls") == $'ask\nask' ]] || fail "a declined agreement is shown again until it is accepted" "$(cat "$oem/calls")"

  username=owner
  record_eula
  [[ $(jq -r '.accepted_by, .oem, .sha256' "$oem/state/eula-accepted.json") == $'owner\nAcme\n'"$(sha256sum <"$OMARCHY_OEM_EULA" | cut -d' ' -f1)" ]] ||
    fail "accepting records who accepted whose agreement"
)
: >"$oem/calls"
(
  agreement_form
  fit_console_font() { :; }
  clear_logo() { :; }
  say() { :; }
  omarchy_oem_eula() { return "$OMARCHY_OEM_DECLINED"; }
  gum() { return 0; }
  eula_form >/dev/null
  fail "choosing to shut down ends setup"
)
[[ $(<"$oem/calls") == "systemctl poweroff" ]] || fail "declining and choosing to shut down powers the machine off" "$(cat "$oem/calls")"
(
  # Ctrl+C offers the reboot every step offers; turned down, the agreement is
  # back, and Esc from it is the form's step back with nothing accepted.
  agreement_form
  fit_console_font() { :; }
  answers=("$OMARCHY_FORM_SIGNAL" "$OMARCHY_FORM_BACK")
  omarchy_oem_eula() {
    local answer=${answers[0]}
    answers=("${answers[@]:1}")
    return "$answer"
  }
  confirm_reboot() { echo reboot-offered >>"$oem/calls"; return 1; }
  status=0
  eula_form >/dev/null || status=$?
  [[ $status == "$OMARCHY_FORM_BACK" && -z $EULA_ACCEPTED_AT && $(<"$oem/calls") == $'systemctl poweroff\nreboot-offered' ]] ||
    fail "Ctrl+C on the agreement offers a reboot and Esc goes back, accepting nothing" "$status $(cat "$oem/calls")"
)
(
  agreement_form
  OMARCHY_OEM_EULA=""
  omarchy_oem_eula() { fail "a machine without an agreement is not asked to accept one"; }
  eula_form
  rm -f "$oem/state/eula-accepted.json"
  record_eula
  [[ ! -e $oem/state/eula-accepted.json ]] || fail "nothing is recorded where nothing was accepted"
)
pass "a declined agreement comes back until it is accepted or the machine is shut down, and acceptance is recorded"

# The brand is on the screens setup opens and ends on. The steps between are
# under Omarchy's logo, and the form's own font is back once the agreement is
# answered.
printf 'OMARCHY\n' >"$oem/omarchy-logo.txt"
printf '⣿⣷⣄ ⢀⣴⣿\n' >"$oem/bundle/logo.txt"
(
  agreement_form
  : >"$oem/calls"
  gum() { printf '%s\n' "${*: -1}" >>"$oem/drawn"; }
  measure_terminal() { :; }
  omarchy_oem_eula() { clear_logo >/dev/null; }

  clear_logo >/dev/null
  eula_form >/dev/null
  clear_logo >/dev/null
  [[ $(<"$oem/drawn") == $'OMARCHY\n⣿⣷⣄ ⢀⣴⣿\nOMARCHY' ]] || fail "only the agreement is under the OEM's logo" "$(cat "$oem/drawn")"
  [[ $(<"$oem/calls") == "form-font" ]] || fail "the form's font is back after the agreement" "$(cat "$oem/calls")"
)
# A logo in braille dots needs them added to the console font, beside the text
# that screen shows. A console that cannot take them shows Omarchy's logo.
(
  agreement_form
  source <(sed -n '/^brand_console_font() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner")
  OMARCHY_PATH=$ROOT OMARCHY_FORM_LANGUAGE=de
  tty() { echo /dev/tty1; }
  omarchy_console_font() { printf '%s\n' "$@" >"$oem/font-asked"; return "$font_status"; }

  font_status=0
  brand_logo "$OMARCHY_OEM_LOGO"
  brand_console_font
  [[ $BRAND_LOGO_PATH == "$OMARCHY_OEM_LOGO" && $BRAND_LOGO_WIDTH == 7 ]] || fail "a console given the dots draws the OEM's logo"
  [[ $(<"$oem/font-asked") == "/dev/tty1"$'\n'"$OMARCHY_OEM_LOGO"$'\n'"$OMARCHY_OEM_DIR/oem.json"$'\n'"$OMARCHY_OEM_EULA"$'\n'"$ROOT/default/i18n/en/cli.json"$'\n'"$ROOT/default/i18n/de/cli.json" ]] ||
    fail "the font keeps what the branded screens say: the bundle's text and setup's own in this language" "$(cat "$oem/font-asked")"

  font_status=1
  brand_console_font
  [[ $BRAND_LOGO_PATH == "$LOGO_PATH" && $BRAND_LOGO_WIDTH == 7 ]] || fail "a console that cannot draw the dots shows Omarchy's logo"

  printf '█▀█\n' >"$oem/bundle/logo.txt"
  rm "$oem/font-asked"
  brand_logo "$OMARCHY_OEM_LOGO"
  brand_console_font
  [[ ! -e $oem/font-asked && $BRAND_LOGO_PATH == "$OMARCHY_OEM_LOGO" ]] || fail "a logo the font already draws needs nothing added to it"
)
pass "the OEM's logo heads the greeter and the agreement only, with its dots added to the console font for them"

# The font itself: the dot patterns a logo uses are drawn in glyphs that
# neither the logo nor the text beside it needs, and a font with no room says so.
python3 - "$ROOT/install/provisioning/console-font.py" "$oem" <<'PYTHON' || fail "console-font.py adds a logo's braille dots to the font"
import importlib.util, subprocess, sys
from pathlib import Path

tool, work = sys.argv[1], Path(sys.argv[2])
spec = importlib.util.spec_from_file_location("console_font", tool)
font = importlib.util.module_from_spec(spec)
spec.loader.exec_module(font)

def build(codepoints, width=8, height=16):
    # Each glyph is its own code point's low byte, so a redrawn one shows.
    glyphs = [bytes([codepoint & 0xFF]) * ((width + 7) // 8 * height) for codepoint in codepoints]
    path = work / "source.psf"
    path.write_bytes(font.write_psf2(width, height, glyphs, [[codepoint] for codepoint in codepoints]))
    return path

def run(source, *files):
    return subprocess.run([sys.executable, tool, str(source), str(work / "out.psf"), *map(str, files)], capture_output=True)

(work / "art.txt").write_text("⣿⠁ ⠈⡀\n")
(work / "text.txt").write_text("Жюль ΩΨ")
text = [ord(char) for char in "Жюль ΩΨ" if char != " "]
spare = [0x0429, 0x042E, 0x042F, 0x0401]
# The text's glyphs come last, where a tool that forgot the text would take them first.
source = build([0xFFFD, *range(0x20, 0x7F), 0x0149, 0x20A7, 0x2588, *spare, *text])
assert run(source, work / "art.txt", work / "text.txt").returncode == 0
width, height, glyphs, table = font.read_font((work / "out.psf").read_bytes())
owner = {codepoint: index for index, codepoints in enumerate(table) for codepoint in codepoints}
assert all(ord(char) in owner for char in "⣿⠁⠈⡀"), "the art's patterns are drawn"
assert not any(codepoint in owner for codepoint in spare), "they take the glyphs nothing needs"
assert all(glyphs[owner[codepoint]] == bytes([codepoint & 0xFF]) * 16 for codepoint in [*text, *range(0x20, 0x7F)]), "text beside the art keeps its glyphs"
full, one = glyphs[owner[0x28FF]], glyphs[owner[0x2801]]
# All eight dots: two columns, four rows, two pixels square in an 8x16 cell.
assert [row for row in full] == [0, 0x66, 0x66, 0] * 4, full.hex()
assert [row for row in one] == [0, 0x60, 0x60] + [0] * 13, one.hex()
# Dot 4 heads the right column and dot 7 ends the left, as Unicode numbers them.
assert list(glyphs[owner[0x2808]]) == [0, 0x06, 0x06] + [0] * 13
assert list(glyphs[owner[0x2840]]) == [0] * 13 + [0x60, 0x60, 0]

wide = build([0xFFFD, *range(0x20, 0x7F), 0x0149, 0x20A7, *spare], width=16, height=32)
assert run(wide, work / "art.txt").returncode == 0
_, _, glyphs, table = font.read_font((work / "out.psf").read_bytes())
owner = {codepoint: index for index, codepoints in enumerate(table) for codepoint in codepoints}
assert glyphs[owner[0x28FF]] == (bytes(4) + bytes([0x3C, 0x3C] * 4) + bytes(4)) * 4, "a 16x32 cell has dots four pixels square"

# Four patterns, three glyphs to spare.
assert run(build([0xFFFD, *range(0x20, 0x7F), 0x0149, 0x20A7, *spare[:3]]), work / "art.txt").returncode != 0
PYTHON
pass "the console font draws a logo's dots in glyphs the screen has no other use for"

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
