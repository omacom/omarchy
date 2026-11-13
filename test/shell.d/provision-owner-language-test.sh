#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export OMARCHY_FORM_DEFAULTS=$tmp/no-defaults
source "${SETUP_FORM_SOURCE:-$ROOT/install/provisioning/setup-form.sh}"
source <(sed -n '/^fit_console_font() {/,/^}/p; /^initial_language() {/,/^}/p; /^configure_language() {/,/^}/p; /^keyboard_form() {/,/^}/p; /^user_form() {/,/^}/p; /^run_setup() {/,/^}/p' \
  "${PROVISION_OWNER_SOURCE:-$ROOT/bin/omarchy-provision-owner}")

LANGUAGE_FILE=$tmp/attempt-language
LANGUAGE_MARKER=$tmp/etc/omarchy/language
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

mkdir -p "$tmp/runtime/bin" "$tmp/home/.config/omarchy" "$tmp/home/.config/uwsm/env.d"
cat >"$tmp/runtime/bin/omarchy-locale-generate" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$LOCALE_CALLS"
[[ ! -e $LOCALE_CALLS.fail ]]
EOF
chmod +x "$tmp/runtime/bin/omarchy-locale-generate"
export LOCALE_CALLS=$tmp/locale-calls
(
  OMARCHY_PATH=$tmp/runtime
  username=owner
  getent() { echo "owner:x:1000:1000::$tmp/home:/bin/bash"; }
  log_step() { echo "$1" >>"$tmp/language-log"; }
  language=de
  configure_language
  [[ $(<"$LANGUAGE_MARKER") == "de" && $(<"$LOCALE_CALLS") == "de" ]] || fail "a non-English choice generates its locale and writes its marker"

  # An attempt that got as far as seeding German, then a retry that picks English.
  echo de >"$tmp/home/.config/omarchy/language"
  echo 'export LANG=de_DE.UTF-8' >"$tmp/home/.config/uwsm/env.d/50-omarchy-language"
  : >"$LOCALE_CALLS"
  language=en
  configure_language
  [[ ! -e $LANGUAGE_MARKER && ! -s $LOCALE_CALLS ]] || fail "English removes the marker without generating a locale"
  [[ ! -e $tmp/home/.config/omarchy/language && ! -e $tmp/home/.config/uwsm/env.d/50-omarchy-language ]] ||
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
  grep -q "could not generate the locale for fr" "$tmp/language-log" || fail "the log says why the desktop stays English"
)
pass "language configuration generates before it persists, forgets an earlier attempt's seed, and survives a locale that cannot be generated"

(
  clear_logo() { :; }
  say() { printf '%s\n' "$*" >>"$tmp/screen"; }
  log_step() { :; }
  notice() { fail "keyboard prompt unexpectedly failed" "$*"; }
  confirm_reboot() { fail "keyboard Esc must return to language selection"; }
  omarchy_persist_input_selection() { :; }
  apply_keyboard() { printf 'apply %s\n' "$1" >>"$tmp/order"; }
  language_form() { echo language >>"$tmp/order"; omarchy_form_use_language ja; }
  omarchy_prompt_keyboard() {
    echo keyboard >>"$tmp/order"
    if [[ ! -f $tmp/escaped ]]; then
      touch "$tmp/escaped"
      return "$OMARCHY_FORM_BACK"
    fi
    keyboard=jp106
  }
  omarchy_form_use_language de
  keyboard_form >"$tmp/output"
  [[ $(<"$tmp/order") == $'keyboard\nlanguage\nkeyboard\napply jp106' ]] || fail "Esc visits the language picker before asking for the keyboard again" "$(cat "$tmp/order")"
  [[ $(<"$tmp/screen") == '--foreground 8 Setup stays in English. Omarchy will be in Japanese once set up.' ]] || fail "only the undrawn language gets the English notice" "$(cat "$tmp/screen")"
  : >"$tmp/screen"
  omarchy_form_use_language de
  keyboard_form >"$tmp/output"
  [[ ! -s $tmp/screen ]] || fail "a drawn language has no English notice"
)
pass "keyboard Esc returns to the language picker and only undrawn languages get the English notice"

(
  PROVISIONING_DIR=$tmp/provisioning
  mkdir -p "$PROVISIONING_DIR"
  step() { :; }
  say() { printf '%s\n' "$*" >"$tmp/continuing"; }
  omarchy_prompt_timezone() { echo timezone >>"$tmp/questions"; }
  omarchy_prompt_username() { echo username >>"$tmp/questions"; username=chosen; }
  omarchy_prompt_password() { echo password >>"$tmp/questions"; }
  omarchy_prompt_hostname() { echo hostname >>"$tmp/questions"; }
  user_form >"$tmp/output"
  [[ $(<"$tmp/questions") == $'timezone\nusername\npassword\nhostname' ]] || fail "account questions follow the installer's order" "$(cat "$tmp/questions")"
  : >"$tmp/questions"
  printf 'pinned-owner\n' >"$PROVISIONING_DIR/setup-user"
  user_form >"$tmp/output"
  [[ $username == "pinned-owner" && $(<"$tmp/questions") == $'timezone\npassword\nhostname' ]] || fail "a pinned username bypasses only its own question"
  grep -qF pinned-owner "$tmp/continuing" || fail "the owner is told which account is being continued"
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
  fit_console_font() { echo font >>"$tmp/setup-order"; }
  initial_language() { echo initial >>"$tmp/setup-order"; }
  language_form() { echo language >>"$tmp/setup-order"; }
  keyboard_form() { echo keyboard >>"$tmp/setup-order"; }
  user_form() { echo account >>"$tmp/setup-order"; }
  confirm_form() {
    echo review >>"$tmp/setup-order"
    [[ -e $tmp/reviewed ]] && return 0
    touch "$tmp/reviewed"
    return 1
  }
  rekey_accepts_password() { return 0; }
  load_tips() { exit 0; }
  run_setup
)
[[ $(<"$tmp/setup-order") == $'font\ninitial\nlanguage\nkeyboard\naccount\nreview\nkeyboard\naccount\nreview' ]] || fail "declining review returns to the keyboard and account steps" "$(cat "$tmp/setup-order")"
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

source "${CONSOLE_FONT_SOURCE:-$ROOT/install/provisioning/console-font.sh}"
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

mkdir -p "$tmp/bin"
cat >"$tmp/bin/stty" <<'EOF'
#!/bin/bash
printf '%s\n' "$FONT_ROWS $FONT_COLS"
EOF
cat >"$tmp/bin/showconsolefont" <<'EOF'
#!/bin/bash
printf '%sx%s\n' "$FONT_WIDTH" "$FONT_HEIGHT"
EOF
cat >"$tmp/bin/python3" <<'EOF'
#!/bin/bash
printf 'build %s\n' "$2" >>"$FONT_CALLS"
[[ ${FONT_BUILD_FAIL:-0} == 0 ]] || exit 1
printf 'built font\n' >"$3"
EOF
cat >"$tmp/bin/setfont" <<'EOF'
#!/bin/bash
printf 'set %s\n' "$*" >>"$FONT_CALLS"
EOF
chmod +x "$tmp/bin/"*
export PATH="$tmp/bin:$PATH" FONT_CALLS=$tmp/font-calls OMARCHY_CONSOLE_FONT_DIR=$tmp/fonts
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
