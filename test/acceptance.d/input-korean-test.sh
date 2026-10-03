#!/bin/bash

# Exercises the one-step Korean input setup end to end: the command installs
# fcitx5-hangul and registers the engine, then a terminal receives Hangul
# composed from Dubeolsik keystrokes.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

result_file=/tmp/omarchy-acceptance-korean-input
reader_script=/tmp/omarchy-acceptance-korean-reader
previous_input_method=""

# Later tests type Latin into the shell's own surfaces, so hand the input
# method back rather than leave the session composing Hangul.
cleanup() {
  close_windows '^org\.omarchy\.ime-test$'
  rm -f "$result_file" "$reader_script"
  [[ -n $previous_input_method ]] && fcitx5-remote -s "$previous_input_method" >/dev/null 2>&1 || true
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

# The package install underneath is the only step that needs sudo. Once the
# engine is on the machine the command is a plain user-level rerun.
if pacman -Q fcitx5-hangul >/dev/null 2>&1; then
  omarchy-setup-input-hangul >"$ARTIFACTS/setup-input-hangul.log" 2>&1 ||
    fail "omarchy-setup-input-hangul completes on a machine with the engine installed" "$(tail -5 "$ARTIFACTS/setup-input-hangul.log")"
elif [[ -n ${OMARCHY_ACCEPTANCE_SUDO_PASSWORD:-} ]] && sudo_available; then
  # sudo keys its cached credential on the calling terminal, so validate the
  # password on a pseudo-terminal that the setup command's own sudo shares,
  # the way the sshd hardening exercise does.
  if ! OMARCHY_ACCEPTANCE_SUDO_PASSWORD="$OMARCHY_ACCEPTANCE_SUDO_PASSWORD" SHELL=/bin/bash \
    script -qec 'printf "%s\n" "$OMARCHY_ACCEPTANCE_SUDO_PASSWORD" | sudo -S -v 2>/dev/null &&
      omarchy-setup-input-hangul' /dev/null \
    </dev/null >"$ARTIFACTS/setup-input-hangul.log" 2>&1; then
    fail "omarchy-setup-input-hangul completes unattended" "$(tail -5 "$ARTIFACTS/setup-input-hangul.log")"
  fi
else
  pass "Korean input exercise skipped: set OMARCHY_ACCEPTANCE_SUDO_PASSWORD to install fcitx5-hangul"
  exit 0
fi
pass "omarchy-setup-input-hangul completes"

pacman -Q fcitx5-hangul >/dev/null || fail "fcitx5-hangul is installed"
pass "fcitx5-hangul is installed"

group=$(fcitx5-remote -q)
group_info=$(busctl --user --json=short call \
  org.fcitx.Fcitx5 \
  /controller \
  org.fcitx.Fcitx.Controller1 \
  InputMethodGroupInfo \
  s "$group")
jq -e '.data[1] | any(.[0] == "hangul")' <<<"$group_info" >/dev/null || fail "hangul is registered with fcitx5"
pass "hangul is registered with fcitx5"

cat >"$reader_script" <<'EOF'
#!/bin/bash
IFS= read -r value
printf '%s' "$value" >/tmp/omarchy-acceptance-korean-input
sleep 5
EOF
chmod +x "$reader_script"

launch_app "foot --app-id=org.omarchy.ime-test $reader_script"
wait_until "Korean input test terminal opens" 15 window_present '^org\.omarchy\.ime-test$'
sleep 1

# Switch to hangul by name rather than by toggling: a user who added another
# engine first would land there instead.
previous_input_method=$(fcitx5-remote -n)
fcitx5-remote -s hangul
wait_until "fcitx5 switches to hangul" 15 bash -c '[[ $(fcitx5-remote -n) == "hangul" ]]'

# Dubeolsik: g k s -> ㅎ ㅏ ㄴ -> 한. Return commits the syllable and passes
# through, so the reader gets its line.
wtype "gks"
sleep 1
screenshot "success-input-korean-composition"
wtype -k Return

wait_until "hangul composes 한 from gks" 15 grep -Fxq "한" "$result_file"

trap - EXIT
cleanup
