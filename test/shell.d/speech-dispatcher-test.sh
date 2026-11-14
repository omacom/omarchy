#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

packages="$ROOT/install/omarchy-base.packages"
first_run_units="$ROOT/install/user/first-run/enable-user-units.sh"
installer="$ROOT/bin/omarchy-install-browser"
helper="$ROOT/install/helpers/brave-web-speech.sh"

! grep -qxF espeak-ng "$packages" || fail "espeak-ng stays out of the base package set"
! grep -qxF speech-dispatcher "$packages" || fail "speech-dispatcher stays out of the base package set"
pass "the base install does not ship a local speech backend"

! grep -F 'speech-dispatcher.socket' "$first_run_units" >/dev/null ||
  fail "first-run does not enable the speech dispatcher socket"
pass "first-run does not enable the speech dispatcher socket"

grep -F 'source "$OMARCHY_PATH/install/helpers/brave-web-speech.sh"' "$installer" >/dev/null ||
  fail "the browser installer sources the Brave web speech helper"
grep -F 'omarchy_ensure_brave_web_speech' "$installer" >/dev/null ||
  fail "the browser installer installs the Brave web speech backend"
pass "Brave install wires up the local speech backend"

# A user speechd.conf would mask the packaged one, including module auto-detect
# and Orca dictionaries. The distro default is enough once espeak-ng is present.
[[ ! -e $ROOT/config/speech-dispatcher/speechd.conf ]] ||
  fail "Omarchy does not ship a user speechd.conf that masks the packaged default"
pass "Omarchy does not ship a user speechd.conf"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home/.config"

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'omarchy-pkg-add\t%s\n' "$*" >>"$OMARCHY_SPEECH_TEST_LOG"
exit "${OMARCHY_SPEECH_PKG_ADD_STATUS:-0}"
SH
cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl\t%s\n' "$*" >>"$OMARCHY_SPEECH_TEST_LOG"
if [[ $1 == "--user" && $2 == "enable" ]]; then
  exit "${OMARCHY_SPEECH_ENABLE_STATUS:-0}"
fi
exit 0
SH
chmod +x "$mock_bin"/*

log="$test_tmp/actions.log"
flags="$test_tmp/home/.config/brave-flags.conf"
wants_link="$test_tmp/home/.config/systemd/user/sockets.target.wants/speech-dispatcher.socket"

run_helper() {
  : >"$log"
  HOME="$test_tmp/home" \
    PATH="$mock_bin:$PATH" \
    OMARCHY_SPEECH_TEST_LOG="$log" \
    bash -euo pipefail -c "source \"$helper\"; omarchy_ensure_brave_web_speech \"$1\"" >/dev/null
}

cp "$ROOT/config/chromium-flags.conf" "$flags"
if OMARCHY_SPEECH_PKG_ADD_STATUS=1 run_helper "$flags" 2>/dev/null; then
  fail "the helper continues when package installation fails"
fi
! grep -q $'systemctl\t' "$log" || fail "a failed package install still enabled the socket"
! grep -qxF -- --enable-speech-dispatcher "$flags" || fail "a failed package install still changed the Brave flags"
pass "the helper stops when the speech packages cannot be installed"

run_helper "$flags"
grep -qxF $'omarchy-pkg-add\tspeech-dispatcher espeak-ng' "$log" ||
  fail "the helper installs speech-dispatcher and espeak-ng"
grep -qxF $'systemctl\t--user daemon-reload' "$log" ||
  fail "the helper reloads user units after installing the packages"
grep -qxF $'systemctl\t--user enable --now speech-dispatcher.socket' "$log" ||
  fail "the helper enables the speech dispatcher socket"
[[ ! -e $wants_link ]] || fail "a live user manager does not also write a fallback symlink"
pass "the helper installs the packages and enables the socket"

grep -qxF -- --enable-speech-dispatcher "$flags" ||
  fail "Brave is started with speech-dispatcher enabled" "$(<"$flags")"
grep -qxF -- --ozone-platform=wayland "$flags" || fail "the existing Brave flags are kept"
pass "the helper turns on speech-dispatcher in the Brave flags"

OMARCHY_SPEECH_ENABLE_STATUS=1 run_helper "$flags"
OMARCHY_SPEECH_ENABLE_STATUS=1 run_helper "$flags"
[[ $(readlink "$wants_link") == /usr/lib/systemd/user/speech-dispatcher.socket ]] ||
  fail "a TTY run still links the distro socket unit for the next login"
(( $(grep -cxF -- --enable-speech-dispatcher "$flags") == 1 )) ||
  fail "running again does not repeat the speech-dispatcher flag"
pass "the helper links the socket without a user manager and is idempotent"

rm -rf "$test_tmp/home/.config/systemd"
mkdir -p "$test_tmp/home/.config/systemd/user"
touch "$test_tmp/home/.config/systemd/user/sockets.target.wants"
: >"$log"
# The installer calls the helper as `... || exit 1`, which turns off errexit inside it.
if HOME="$test_tmp/home" PATH="$mock_bin:$PATH" OMARCHY_SPEECH_TEST_LOG="$log" OMARCHY_SPEECH_ENABLE_STATUS=1 \
  bash -euo pipefail -c "source \"$helper\"; omarchy_ensure_brave_web_speech \"$flags\" || exit 1" >/dev/null 2>&1; then
  fail "a socket fallback that cannot link fails the Brave install"
fi
rm -rf "$test_tmp/home/.config/systemd"
pass "a socket fallback that cannot link fails the Brave install"

printf -- '--ozone-platform=wayland' >"$flags"
run_helper "$flags"
[[ $(<"$flags") == $'--ozone-platform=wayland\n--enable-speech-dispatcher' ]] ||
  fail "the flag goes on its own line when the file lacks a trailing newline" "$(<"$flags")"
pass "the helper appends the flag on its own line"

rm -f "$flags"
run_helper "$flags"
[[ ! -e $flags ]] || fail "the helper does not create a Brave flags file the user removed"
pass "the helper leaves a missing Brave flags file alone"
