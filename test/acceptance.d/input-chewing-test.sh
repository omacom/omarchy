#!/bin/bash

# Exercises the one-step Traditional Chinese input setup end to end: the setup
# command installs fcitx5-chewing and registers the engine with the running
# fcitx5, then a terminal receives Han characters composed from Bopomofo
# keystrokes.
#
# The package install needs root, so the install half only runs when
# OMARCHY_ACCEPTANCE_SUDO_PASSWORD is set, which omarchy-iso-test does for its
# throwaway VMs. On a machine that already has the engine the command is a
# plain user-level rerun and always runs.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

result_file=/tmp/omarchy-acceptance-chewing-input
reader_script=/tmp/omarchy-acceptance-chewing-reader
window_class='^org\.omarchy\.ime-test$'
previous_input_method=""
previous_input_state=""

# Later tests type Latin into the shell's own surfaces, so hand the input
# method back rather than leave the session composing Bopomofo.
cleanup() {
  close_windows "$window_class"
  rm -f "$result_file" "$reader_script"

  if [[ -n $previous_input_method ]]; then
    fcitx5-remote -s "$previous_input_method" >/dev/null 2>&1 || true
  fi

  if [[ $previous_input_state == "2" ]]; then
    fcitx5-remote -o >/dev/null 2>&1 || true
  else
    fcitx5-remote -c >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

sudo_available() {
  if sudo -n true 2>/dev/null; then
    return 0
  fi

  if [[ -n ${OMARCHY_ACCEPTANCE_SUDO_PASSWORD:-} ]]; then
    printf '%s\n' "$OMARCHY_ACCEPTANCE_SUDO_PASSWORD" | sudo -S -v 2>/dev/null
    return $?
  fi

  return 1
}

# Bopomofo reaches Han through a candidate list whose order comes from
# chewing's phrase dictionary and adapts to what the user has picked before.
# Unlike Hangul, which is an alphabet that composes deterministically, no exact
# string is guaranteed, so assert that Han arrived rather than which characters
# did.
han_committed() {
  [[ -s $result_file ]] && grep -qP '^\p{Han}+$' "$result_file"
}

chewing_active() {
  [[ $(fcitx5-remote -n) == "chewing" ]] && [[ $(fcitx5-remote) == "2" ]]
}

if window_present "$window_class" >/dev/null 2>&1; then
  fail "Traditional Chinese input test starts with no pre-existing window" "a window matching $window_class is already open"
fi

if omarchy-pkg-present fcitx5-chewing; then
  omarchy-setup-input-chewing >"$ARTIFACTS/setup-input-chewing.log" 2>&1 ||
    fail "omarchy-setup-input-chewing completes" "$(tail -5 "$ARTIFACTS/setup-input-chewing.log")"
elif [[ -n ${OMARCHY_ACCEPTANCE_SUDO_PASSWORD:-} ]] && sudo_available; then
  # sudo keys its cached credential on the calling terminal, so a validated
  # password never reaches the setup command's own sudo when the suite runs
  # without a terminal (omarchy-iso-test drives it over ssh with no pty). Give
  # the exercise a pseudo-terminal and validate the password on it first, so
  # the sudo underneath shares that terminal's credential.
  if ! OMARCHY_ACCEPTANCE_SUDO_PASSWORD="$OMARCHY_ACCEPTANCE_SUDO_PASSWORD" SHELL=/bin/bash \
    script -qec 'printf "%s\n" "$OMARCHY_ACCEPTANCE_SUDO_PASSWORD" | sudo -S -v 2>/dev/null &&
      omarchy-setup-input-chewing' /dev/null \
    </dev/null >"$ARTIFACTS/setup-input-chewing.log" 2>&1; then
    fail "omarchy-setup-input-chewing completes" "$(tail -5 "$ARTIFACTS/setup-input-chewing.log")"
  fi
else
  pass "Traditional Chinese input exercise skipped: set OMARCHY_ACCEPTANCE_SUDO_PASSWORD to install fcitx5-chewing"
  exit 0
fi
pass "omarchy-setup-input-chewing completes"

omarchy-pkg-present fcitx5-chewing || fail "fcitx5-chewing is installed"
pass "fcitx5-chewing is installed"

group=$(fcitx5-remote -q)
group_info=$(busctl --user --json=short call \
  org.fcitx.Fcitx5 \
  /controller \
  org.fcitx.Fcitx.Controller1 \
  InputMethodGroupInfo \
  s "$group")
jq -e '.data[1] | any(.[0] == "chewing")' <<<"$group_info" >/dev/null ||
  fail "chewing is registered with fcitx5" "$group_info"
pass "chewing is registered with fcitx5"

cat >"$reader_script" <<'EOF'
#!/bin/bash
IFS= read -r value
printf '%s' "$value" >/tmp/omarchy-acceptance-chewing-input
sleep 5
EOF
chmod +x "$reader_script"

launch_app "foot --app-id=org.omarchy.ime-test $reader_script"
wait_until "Traditional Chinese input test terminal opens" 15 window_present "$window_class"
sleep 1

# Select chewing by name rather than by toggling: a session that had a Japanese
# or Korean engine added earlier would toggle to that one instead. A group
# whose first entry is a plain keyboard layout also starts out passthrough, so
# activate the input method as well as select it.
previous_input_method=$(fcitx5-remote -n)
previous_input_state=$(fcitx5-remote)
fcitx5-remote -o
fcitx5-remote -s chewing
wait_until "fcitx5 activates chewing" 15 chewing_active

# Standard (Dai Chien) Bopomofo arrangement: s u 3 is ㄋㄧˇ and c l 3 is ㄏㄠˇ.
wtype "su3cl3"
sleep 1
screenshot "success-input-chewing-preedit"

# The first Return commits the phrase out of chewing's pre-edit buffer, where
# it is consumed; the second reaches the shell and ends the reader's line.
wtype -k Return
sleep 1
screenshot "success-input-chewing-committed"
wtype -k Return

wait_until "chewing commits Han characters from Bopomofo keystrokes" 15 han_committed
pass "chewing composed $(cat "$result_file")"

trap - EXIT
cleanup
