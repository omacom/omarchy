#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -r "$tmp_dir"' EXIT

# gum reads its scripted answers from GUM_SCRIPT, one "status:output" line per
# invocation, so a test spells out exactly what the human did at each screen:
# "0:dhh" answers, "1:" is Esc, "130:" is Ctrl+C. Only the widgets that take a
# list drain stdin, matching the real ones, so the piped layouts and timezones
# can be asserted.
cat >"$tmp_dir/gum" <<'EOF'
#!/bin/bash
count=$(($(cat "$GUM_COUNT") + 1))
printf '%s' "$count" >"$GUM_COUNT"
printf '%s\n' "$*" >>"$GUM_ARGS"

case $1 in
  choose | filter | table) cat >"$GUM_DIR/stdin.$count" ;;
esac

line=$(sed -n "${count}p" "$GUM_SCRIPT")
printf '%s\n' "${line#*:}"
exit "${line%%:*}"
EOF

# Answers like geo.omarchy.org, or fails like curl -f with no network.
cat >"$tmp_dir/curl" <<'EOF'
#!/bin/bash
printf '%s\n' "${@: -1}" >>"$GUM_DIR/curl-urls"
[[ -n ${TZ_GUESS:-} ]] || exit 22
printf '{"name":"","latitude":null,"longitude":null,"country":"","timezone":"%s"}\n' "$TZ_GUESS"
EOF

cat >"$tmp_dir/timedatectl" <<'EOF'
#!/bin/bash
printf '%s\n' UTC Europe/Copenhagen America/Chicago Asia/Shanghai Europe/Warsaw
EOF

# Calls one prompt bare under `set -euo pipefail` — the shape that makes the
# status capture load-bearing. A cancelled prompt is a failing assignment, so a
# regression to a plain `status=$?` kills the shell before the function can
# return; both cases exit with the same status, and this marker is the only
# thing that tells them apart.
cat >"$tmp_dir/driver" <<'EOF'
#!/bin/bash

set -euo pipefail
set -T

source "${SETUP_FORM_SOURCE:-$ROOT/install/provisioning/setup-form.sh}"

notice() { printf '%s\n' "$1" >>"$NOTICES"; }

if [[ -n ${TAKEN_USERS:-} ]]; then
  omarchy_username_taken() { [[ " $TAKEN_USERS " == *" $1 "* ]]; }
fi

trap 'if [[ ${FUNCNAME[0]:-} == "$PROMPT_FN" ]]; then printf "returned\n" >>"$MARKER"; printf "%s\n" "$language" >"$GUM_DIR/language-returned"; fi' RETURN

language=${INITIAL_LANGUAGE:-en}
if [[ $PROMPT_FN == omarchy_form_review ]]; then
  keyboard_label='English (US, Dvorak)'
  keyboard=dvorak timezone=UTC username=owner password=secret hostname=omarchy
fi
"$PROMPT_FN"

printf 'language=%s\n' "${language:-}"
printf 'form_language=%s\n' "${OMARCHY_FORM_LANGUAGE:-}"
printf 'keyboard=%s\n' "${keyboard:-}"
printf 'keyboard_label=%s\n' "${keyboard_label:-}"
printf 'keyboard_input_method=%s\n' "${keyboard_input_method:-}"
printf 'keyboard_xkb_layout=%s\n' "${keyboard_xkb_layout:-}"
printf 'username=%s\n' "${username:-}"
printf 'password=%s\n' "${password:-}"
printf 'password_confirmation=%s\n' "${password_confirmation:-}"
printf 'full_name=%s\n' "${full_name:-}"
printf 'email_address=%s\n' "${email_address:-}"
printf 'hostname=%s\n' "${hostname:-}"
printf 'timezone=%s\n' "${timezone:-}"
EOF

chmod +x "$tmp_dir/gum" "$tmp_dir/curl" "$tmp_dir/timedatectl" "$tmp_dir/driver"
export PATH="$tmp_dir:$PATH"
export GUM_DIR="$tmp_dir" GUM_SCRIPT="$tmp_dir/script" GUM_ARGS="$tmp_dir/args" GUM_COUNT="$tmp_dir/count"
export NOTICES="$tmp_dir/notices" MARKER="$tmp_dir/marker"

status=0

# run_prompt <function> <status:output>... — each response answers one gum screen
# The machine's own form defaults never reach these tests.
export OMARCHY_FORM_DEFAULTS="$tmp_dir/no-form-defaults"
# The form's strings come from this checkout's catalogs, not the machine's.
export OMARCHY_PATH="$ROOT"

run_prompt() {
  local prompt=$1
  shift

  printf '%s\n' "$@" >"$GUM_SCRIPT"
  printf '0' >"$GUM_COUNT"
  : >"$GUM_ARGS"
  : >"$NOTICES"
  : >"$MARKER"
  rm -f "$tmp_dir"/stdin.*

  PROMPT_FN="$prompt" "$tmp_dir/driver" >"$tmp_dir/out" 2>"$tmp_dir/err" && status=0 || status=$?
}

field() { sed -n "s/^$1=//p" "$tmp_dir/out"; }

assert_returned() {
  grep -qx returned "$MARKER" ||
    fail "$1" "$(printf 'the prompt never returned; the shell died inside it:\n%s' "$(<"$tmp_dir/err")")"
}

assert_status() {
  ((status == $1)) || fail "$2" "expected status: $1
actual status:   $status"
}

assert_notices() {
  local description=$1 expected=$2
  local actual
  actual=$(<"$NOTICES")
  [[ $actual == "$expected" ]] || fail "$description" "expected notices: $expected
actual notices:   $actual"
}

# The contract both callers read, and the ordering the shared list exists to keep
source "${SETUP_FORM_SOURCE:-$ROOT/install/provisioning/setup-form.sh}"

((OMARCHY_FORM_BACK == 1)) || fail "Esc reports status 1"
((OMARCHY_FORM_SIGNAL == 130)) || fail "Ctrl+C reports status 130"
[[ $(printf '%s\n' "$OMARCHY_KEYBOARD_LAYOUTS" | head -n 1) == "English (US)|us" ]] ||
  fail "English (US) leads the keyboard layouts so gum choose opens on the default"
pass "the form publishes the 0/1/130 status contract and leads with English (US)"

# Keyboard

run_prompt omarchy_prompt_keyboard "0:German"
assert_status 0 "keyboard prompt succeeds"
[[ $(field keyboard) == "de-latin1" ]] || fail "keyboard prompt resolves the label to a keymap"
[[ $(field keyboard_label) == "German" ]] || fail "keyboard prompt keeps the label for the summary"
[[ $(head -n 1 "$tmp_dir/stdin.1") == "English (US)" ]] || fail "keyboard prompt offers English (US) first"
grep -qF -- '--selected English (US)' "$GUM_ARGS" || fail "keyboard prompt preselects English (US)"
pass "keyboard prompt maps the chosen label to its keymap"

for selection in 'French|fr-latin1' 'French (Switzerland)|fr_CH-latin1'; do
  IFS='|' read -r label keymap <<< "$selection"
  run_prompt omarchy_prompt_keyboard "0:$label"
  assert_status 0 "$label can be selected at install"
  [[ $(field keyboard) == "$keymap" ]] || fail "$label loads the console map that types its accented letters"
done
pass "French takes the latin1 console maps that type its accented letters"

OMARCHY_FORM_KEYBOARD_DEFAULT="Chinese (Simplified, Pinyin)" run_prompt omarchy_prompt_keyboard "0:Chinese (Simplified, Pinyin)"
assert_status 0 "a preset keyboard prompt succeeds"
grep -qF -- '--selected Chinese (Simplified\, Pinyin)' "$GUM_ARGS" || fail "install media can preset the keyboard choice" "$(cat "$GUM_ARGS")"
[[ $(head -n 1 "$tmp_dir/stdin.1") == "English (US)" ]] || fail "a preset keeps the list in its usual order"
[[ $(field keyboard_input_method) == "pinyin" ]] || fail "the preset choice carries its input method"
pass "install media can preselect the keyboard, which stays a choice"

printf 'KEYBOARD=Chinese (Simplified, Pinyin)\nTIMEZONE=Asia/Shanghai\nOTHER=$(touch %s/NEVER)\n' "$tmp_dir" >"$tmp_dir/form-defaults"
OMARCHY_FORM_DEFAULTS="$tmp_dir/form-defaults" run_prompt omarchy_prompt_keyboard "0:Chinese (Simplified, Pinyin)"
grep -qF -- '--selected Chinese (Simplified\, Pinyin)' "$GUM_ARGS" || fail "a first-boot owner setup takes the media's keyboard default" "$(cat "$GUM_ARGS")"
OMARCHY_FORM_DEFAULTS="$tmp_dir/form-defaults" TZ_GUESS=Europe/Copenhagen run_prompt omarchy_prompt_timezone "0:Asia/Shanghai"
[[ $(head -n 1 "$tmp_dir/stdin.1") == "Asia/Shanghai" ]] || fail "a first-boot owner setup takes the media's timezone default" "$(cat "$tmp_dir/stdin.1")"
[[ ! -e $tmp_dir/NEVER ]] || fail "form defaults are read as data"
OMARCHY_FORM_DEFAULTS="$tmp_dir/form-defaults" OMARCHY_FORM_KEYBOARD_DEFAULT=Japanese run_prompt omarchy_prompt_keyboard "0:Japanese"
grep -qF -- '--selected Japanese' "$GUM_ARGS" || fail "the live installer's environment wins over the file"
pass "a first-boot owner setup reads the media's defaults as data"

for selection in 'Japanese|jp106|mozc|' 'Japanese (US keyboard)|us|mozc|' 'Korean|us|hangul|kr:kr104' 'Lao|us|none|la' 'Catalan|es|none|es:cat' 'Chinese (Simplified, Pinyin)|us|pinyin|' 'Taiwan (Zhuyin)|us|chewing|' 'Hong Kong (Cangjie)|us|cangjie5|'; do
  IFS='|' read -r label keymap method layout <<< "$selection"
  run_prompt omarchy_prompt_keyboard "0:$label"
  assert_status 0 "$label can be selected at install"
  [[ $(field keyboard) == "$keymap" && $(field keyboard_input_method) == "$method" && $(field keyboard_xkb_layout) == "$layout" ]] ||
    fail "$label carries a real console keymap and a separate input preference"
done
pass "language keyboard choices carry their keymap, input method, and desktop override"

keyboard_input_method=hangul keyboard_xkb_layout=kr omarchy_persist_input_selection "$tmp_dir/target"
[[ $(<"$tmp_dir/target/etc/omarchy/input-method") == $'INPUT_METHOD=hangul\nXKB_LAYOUT=kr' ]] || fail "first-boot setup persists the selection for user finalization"
keyboard_input_method=hangul keyboard_xkb_layout=kr:kr104 omarchy_persist_input_selection "$tmp_dir/target"
[[ $(<"$tmp_dir/target/etc/omarchy/input-method") == $'INPUT_METHOD=hangul\nXKB_LAYOUT=kr:kr104' ]] || fail "first-boot setup persists the Korean Right Alt variant"
keyboard_input_method=none keyboard_xkb_layout=es:cat omarchy_persist_input_selection "$tmp_dir/target"
[[ $(<"$tmp_dir/target/etc/omarchy/input-method") == $'INPUT_METHOD=none\nXKB_LAYOUT=es:cat' ]] || fail "first-boot setup persists the Catalan variant"
keyboard_input_method=hangul keyboard_xkb_layout=kr:dvorak omarchy_persist_input_selection "$tmp_dir/target" && fail "an unknown desktop variant is refused"
pass "first-boot setup persists the selection for user finalization"

run_prompt omarchy_prompt_keyboard "1:"
assert_status "$OMARCHY_FORM_BACK" "keyboard prompt reports Esc as back"
assert_returned "keyboard prompt survives Esc under set -e"

run_prompt omarchy_prompt_keyboard "130:"
assert_status "$OMARCHY_FORM_SIGNAL" "keyboard prompt reports Ctrl+C as the caller's signal"
assert_returned "keyboard prompt survives Ctrl+C under set -e"
pass "keyboard prompt propagates Esc and Ctrl+C without dying under set -e"

# Username

TAKEN_USERS=dhh run_prompt omarchy_prompt_username "0:Not A Username" "0:root" "0:cups-browsed" "0:dhh" "0:david"
assert_status 0 "username prompt accepts a valid name"
[[ $(field username) == "david" ]] || fail "username prompt keeps re-asking until the name is valid"
assert_notices "username prompt explains each rejection" "Username must be alphanumeric with no spaces
Username is reserved for system
Username is reserved for system
That username already exists on this machine"
pass "username prompt rejects malformed, reserved, and taken names"

run_prompt omarchy_prompt_username "1:"
assert_status "$OMARCHY_FORM_BACK" "username prompt reports Esc as back"
assert_returned "username prompt survives Esc under set -e"

run_prompt omarchy_prompt_username "130:"
assert_status "$OMARCHY_FORM_SIGNAL" "username prompt reports Ctrl+C as the caller's signal"
assert_returned "username prompt survives Ctrl+C under set -e"
pass "username prompt propagates Esc and Ctrl+C without dying under set -e"

# Password

run_prompt omarchy_prompt_password "0:one" "0:two" "0:" "0:" "0:s3cret" "0:s3cret"
assert_status 0 "password prompt accepts a confirmed password"
[[ $(field password) == "s3cret" ]] || fail "password prompt keeps the confirmed password"
assert_notices "password prompt explains each rejection" "Passwords didn't match!
Your password can't be blank!"
pass "password prompt rejects mismatched and blank passwords"

run_prompt omarchy_prompt_password "0:s3cret" "1:"
assert_status "$OMARCHY_FORM_BACK" "password prompt reports Esc on the confirmation as back"
assert_returned "password confirmation survives Esc under set -e"

run_prompt omarchy_prompt_password "0:s3cret" "130:"
assert_status "$OMARCHY_FORM_SIGNAL" "password prompt reports Ctrl+C on the confirmation as the caller's signal"
assert_returned "password confirmation survives Ctrl+C under set -e"
pass "password confirmation propagates Esc and Ctrl+C without dying under set -e"

# Identity — both fields are skippable, so empty is an answer and not a cancel

run_prompt omarchy_prompt_identity "0:" "0:"
assert_status 0 "identity prompt treats empty fields as answers"
[[ -z $(field full_name) && -z $(field email_address) ]] || fail "identity prompt leaves skipped fields empty"
pass "identity prompt accepts skipped fields"

run_prompt omarchy_prompt_identity "0:David" "1:"
assert_status "$OMARCHY_FORM_BACK" "identity prompt reports Esc on the email as back"
assert_returned "identity prompt survives Esc under set -e"
pass "identity prompt propagates Esc from its second field"

# Hostname

run_prompt omarchy_prompt_hostname "0:-nope-" "0:workshop"
assert_status 0 "hostname prompt accepts a valid hostname"
[[ $(field hostname) == "workshop" ]] || fail "hostname prompt keeps re-asking until the hostname is valid"
assert_notices "hostname prompt explains the rejection" "Hostname must be 1-63 letters, digits, or dashes, and cannot start or end with a dash"

run_prompt omarchy_prompt_hostname "0:"
assert_status 0 "hostname prompt accepts an empty hostname"
[[ $(field hostname) == "$OMARCHY_HOSTNAME_DEFAULT" ]] || fail "hostname prompt falls back to the default hostname"
pass "hostname prompt rejects malformed names and defaults an empty one"

run_prompt omarchy_prompt_hostname "1:"
assert_status "$OMARCHY_FORM_BACK" "hostname prompt reports Esc as back"
assert_returned "hostname prompt survives Esc under set -e"
pass "hostname prompt propagates Esc without dying under set -e"

# Language

catalogs="$tmp_dir/omarchy/default/i18n"
mkdir -p "$catalogs/en" "$catalogs/da"
jq '{"setupForm.usernamePrompt": .["setupForm.usernamePrompt"], "setupForm.usernameInvalid": .["setupForm.usernameInvalid"]}' "$ROOT/default/i18n/en/cli.json" >"$catalogs/en/cli.json"
printf '{"setupForm.usernamePrompt": "Brugernavn> "}\n' >"$catalogs/da/cli.json"
OMARCHY_PATH="$tmp_dir/omarchy" OMARCHY_FORM_LANGUAGE=da run_prompt omarchy_prompt_username "0:Bad Name" "0:dhh"
grep -qF -- '--prompt Brugernavn> ' "$GUM_ARGS" || fail "the form speaks the caller's language" "$(cat "$GUM_ARGS")"
assert_notices "a string the language lacks falls back to English" "Username must be alphanumeric with no spaces"
OMARCHY_PATH="$tmp_dir/omarchy" OMARCHY_FORM_LANGUAGE=../da run_prompt omarchy_prompt_username "0:dhh"
grep -qF -- '--prompt Username> ' "$GUM_ARGS" || fail "a language that is not a registry code means English" "$(cat "$GUM_ARGS")"
pass "the form's text comes from Omarchy's catalogs in the caller's language, English filling in"

# Timezone

TZ_GUESS=Europe/Copenhagen run_prompt omarchy_prompt_timezone "0:Europe/Copenhagen"
assert_status 0 "timezone prompt accepts the geo guess"
[[ $(field timezone) == "Europe/Copenhagen" ]] || fail "timezone prompt keeps the chosen timezone"
[[ $(head -n 1 "$GUM_ARGS") == filter* ]] || fail "timezone prompt can be searched with a guess" "$(cat "$GUM_ARGS")"
[[ $(head -n 1 "$tmp_dir/stdin.1") == "Europe/Copenhagen" ]] || fail "timezone prompt lists the geo guess first" "$(cat "$tmp_dir/stdin.1")"
[[ $(grep -cxF Europe/Copenhagen "$tmp_dir/stdin.1") == 1 ]] || fail "timezone prompt lists the geo guess once" "$(cat "$tmp_dir/stdin.1")"
# Typing must start a new search: --value would put the guess in front of
# what the user types, and --selected would return the guess after a search.
if grep -qE -- '--(value|selected)' "$GUM_ARGS"; then
  fail "timezone prompt leaves the search empty and the pick to the user" "$(cat "$GUM_ARGS")"
fi
grep -qF UTC "$tmp_dir/stdin.1" || fail "timezone prompt offers the system timezone list"
[[ $(sort -u "$tmp_dir/curl-urls") == "https://geo.omarchy.org/" ]] || fail "timezone prompt asks only geo.omarchy.org" "$(cat "$tmp_dir/curl-urls")"
pass "timezone prompt offers geo.omarchy.org's timezone first when it answers"

# An unnetworked first boot has no guess, and the fallback has to survive `set -e`
run_prompt omarchy_prompt_timezone "0:America/Chicago"
assert_status 0 "timezone prompt survives a failed geo guess"
[[ $(field timezone) == "America/Chicago" ]] || fail "timezone prompt keeps the filtered timezone"
[[ $(head -n 1 "$GUM_ARGS") == filter* ]] || fail "timezone prompt filters when there is no geo guess"
[[ $(head -n 1 "$tmp_dir/stdin.1") == "UTC" ]] || fail "timezone prompt keeps the system order without a guess" "$(cat "$tmp_dir/stdin.1")"
pass "timezone prompt falls back to filtering when the geo guess fails"

OMARCHY_FORM_TIMEZONE_DEFAULT=Asia/Shanghai TZ_GUESS=Europe/Copenhagen run_prompt omarchy_prompt_timezone "0:Asia/Shanghai"
assert_status 0 "a preset timezone prompt succeeds"
[[ $(head -n 1 "$tmp_dir/stdin.1") == "Asia/Shanghai" ]] || fail "install media can preset the timezone over the geo guess" "$(cat "$tmp_dir/stdin.1")"
pass "install media can put its timezone first, which stays a choice"

TZ_GUESS=Mars/Olympus run_prompt omarchy_prompt_timezone "0:UTC"
assert_status 0 "a timezone prompt with an unknown guess succeeds"
[[ $(head -n 1 "$tmp_dir/stdin.1") == "UTC" ]] || fail "timezone prompt keeps the system order for an unknown guess" "$(cat "$tmp_dir/stdin.1")"
! grep -qxF Mars/Olympus "$tmp_dir/stdin.1" || fail "timezone prompt never offers a guess that is not a timezone" "$(cat "$tmp_dir/stdin.1")"
OMARCHY_FORM_TIMEZONE_DEFAULT=$'Mars/Olympus\nUTC' run_prompt omarchy_prompt_timezone "0:UTC"
! grep -qxF Mars/Olympus "$tmp_dir/stdin.1" || fail "timezone prompt matches the guess as one whole timezone" "$(cat "$tmp_dir/stdin.1")"
OMARCHY_FORM_TIMEZONE_DEFAULT=$'Europe/Copenhagen\nAmerica/Chicago' run_prompt omarchy_prompt_timezone "0:UTC"
assert_status 0 "a multiline timezone guess does not stop setup"
[[ $(head -n 1 "$tmp_dir/stdin.1") == "UTC" ]] || fail "timezone prompt does not promote several zones as one guess" "$(cat "$tmp_dir/stdin.1")"
OMARCHY_FORM_TIMEZONE_DEFAULT=$'UTC\nEurope/Copenhagen\nAmerica/Chicago\nAsia/Shanghai\nEurope/Warsaw' run_prompt omarchy_prompt_timezone "0:UTC"
assert_status 0 "a guess containing the whole list does not stop setup"
assert_returned "timezone prompt survives a guess containing the whole list under set -e"
pass "timezone prompt offers only real timezones"

OMARCHY_FORM_TIMEZONE_FALLBACK=Europe/Warsaw run_prompt omarchy_prompt_timezone "0:Europe/Warsaw"
assert_status 0 "a timezone fallback prompt succeeds"
[[ $(head -n 1 "$GUM_ARGS") == filter* ]] || fail "timezone prompt can be searched with the caller's fallback" "$(cat "$GUM_ARGS")"
[[ $(head -n 1 "$tmp_dir/stdin.1") == "Europe/Warsaw" ]] || fail "the caller's fallback comes first when the geo guess fails" "$(cat "$tmp_dir/stdin.1")"
OMARCHY_FORM_TIMEZONE_FALLBACK=Europe/Warsaw TZ_GUESS=Europe/Copenhagen run_prompt omarchy_prompt_timezone "0:Europe/Copenhagen"
[[ $(head -n 1 "$tmp_dir/stdin.1") == "Europe/Copenhagen" ]] || fail "the geo guess beats the caller's fallback" "$(cat "$tmp_dir/stdin.1")"
pass "a caller's timezone fallback stands in only when the geo guess fails"

run_prompt omarchy_prompt_timezone "0:"
assert_status 0 "timezone prompt accepts an empty selection"
[[ $(field timezone) == "UTC" ]] || fail "timezone prompt falls back to UTC"
pass "timezone prompt falls back to UTC when nothing is selected"

run_prompt omarchy_prompt_timezone "1:"
assert_status "$OMARCHY_FORM_BACK" "timezone prompt reports Esc as back"
assert_returned "timezone prompt survives Esc under set -e"

TZ_GUESS=Europe/Copenhagen run_prompt omarchy_prompt_timezone "130:"
assert_status "$OMARCHY_FORM_SIGNAL" "timezone prompt reports Ctrl+C as the caller's signal"
assert_returned "timezone prompt survives Ctrl+C under set -e"
pass "timezone prompt propagates Esc and Ctrl+C without dying under set -e"

run_prompt omarchy_prompt_language '0:de'
assert_status 0 "language prompt accepts German"
[[ $(field language) == "de" && $(field form_language) == "de" ]] || fail "a drawn language sets the desktop and form language"
[[ $(head -n 1 "$tmp_dir/stdin.1") == $'English\ten' ]] || fail "English leads the language picker"
[[ $(cut -f2 "$tmp_dir/stdin.1" | sort) == "$(jq -r 'keys[]' "$ROOT/default/i18n/locales.json" | sort)" ]] ||
  fail "every registered language is offered exactly once"
grep -qxF $'Deutsch\tde' "$tmp_dir/stdin.1" || fail "a drawn language appears under its native name"
grep -qxF $'Japanese\tja' "$tmp_dir/stdin.1" || fail "an undrawn language appears under its English name"
pass "language picker offers the registry with English first and readable labels"

run_prompt omarchy_prompt_language '0:ja'
assert_status 0 "language prompt accepts Japanese"
[[ $(field language) == "ja" && $(field form_language) == "en" ]] || fail "an undrawn language keeps the form in English"
pass "language selection distinguishes the desktop language from the console language"

for cancel in 1 130; do
  INITIAL_LANGUAGE=de run_prompt omarchy_prompt_language "$cancel:ja"
  assert_status "$cancel" "language prompt propagates cancellation status $cancel"
  assert_returned "language cancellation returns under set -e"
  [[ $(<"$tmp_dir/language-returned") == "de" ]] || fail "cancellation leaves the language unchanged"
done
pass "language Esc and Ctrl+C preserve the previous selection"

(
  unset OMARCHY_FORM_KEYBOARD_DEFAULT OMARCHY_FORM_TIMEZONE_FALLBACK omarchy_form_keyboard_preset
  omarchy_form_use_language de
  [[ $language == "de" && $OMARCHY_FORM_KEYBOARD_DEFAULT == "German" && $OMARCHY_FORM_TIMEZONE_FALLBACK == "Europe/Berlin" ]] ||
    fail "German supplies its keyboard and offline timezone"
  omarchy_form_use_language sw
  [[ $OMARCHY_FORM_TIMEZONE_FALLBACK == "UTC" ]] || fail "a language without a country defaults to UTC"
  # A layout named before the form is loaded is a preset, the caller's ahead of the media's.
  printf 'KEYBOARD=English (US, Dvorak)\n' >"$tmp_dir/language-presets"
  unset OMARCHY_FORM_KEYBOARD_DEFAULT
  OMARCHY_FORM_DEFAULTS="$tmp_dir/language-presets" source "${SETUP_FORM_SOURCE:-$ROOT/install/provisioning/setup-form.sh}"
  omarchy_form_use_language de
  [[ $OMARCHY_FORM_KEYBOARD_DEFAULT == "English (US, Dvorak)" ]] || fail "the media keyboard preset beats the language default"
  OMARCHY_FORM_KEYBOARD_DEFAULT=Japanese
  OMARCHY_FORM_DEFAULTS="$tmp_dir/language-presets" source "${SETUP_FORM_SOURCE:-$ROOT/install/provisioning/setup-form.sh}"
  omarchy_form_use_language de
  [[ $OMARCHY_FORM_KEYBOARD_DEFAULT == "Japanese" ]] || fail "the caller's keyboard preset beats the media's and the language's" "$OMARCHY_FORM_KEYBOARD_DEFAULT"
)
pass "language defaults supply the keyboard and timezone while respecting the caller's and the media's preset"

for code in $OMARCHY_FORM_CONSOLE_LANGUAGES; do
  jq -e --arg code "$code" 'has($code)' "$ROOT/default/i18n/locales.json" >/dev/null || fail "console language $code is registered"
done
while IFS=$'\t' read -r code label; do
  jq -e --arg code "$code" 'has($code)' "$ROOT/default/i18n/locales.json" >/dev/null || fail "default language $code is registered"
  printf '%s\n' "$OMARCHY_KEYBOARD_LAYOUTS" | cut -d'|' -f1 | grep -qxF -- "$label" || fail "language $code has an offered keyboard label: $label"
done < <(jq -r 'to_entries[] | [.key, .value.keyboard] | @tsv' "$omarchy_form_language_defaults")
pass "console languages and language defaults refer to registered languages and offered keyboards"

[[ $(omarchy_form_text ownerSetup.keyboardRetry 'English (US, Dvorak)') == 'Could not set the English (US, Dvorak) keyboard layout. Choose it again.' ]] ||
  fail "form text fills a placeholder from its argument"
[[ $(omarchy_form_text missing.test.key ignored) == "missing.test.key" ]] || fail "an unknown form text key is printed as the fallback"
pass "form text fills arguments and preserves unknown keys"

for confirmation in 0 1 130; do
  run_prompt omarchy_form_review '0:' "$confirmation:"
  assert_status "$confirmation" "review returns gum confirm status $confirmation"
  grep -qxF $'Keyboard\tEnglish (US, Dvorak)' "$tmp_dir/stdin.1" || fail "review preserves a comma inside one keyboard cell"
  awk -F '\t' 'NF != 2 { exit 1 }' "$tmp_dir/stdin.1" || fail "review rows have two tab-separated cells"
  grep -qF -- $'table -s \t -p' "$GUM_ARGS" || fail "review tells gum to use tab-separated input"
done
pass "review uses tab-separated cells and propagates confirmation status"
