#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

packages="$ROOT/install/omarchy-base.packages"
first_run_units="$ROOT/install/user/first-run/enable-user-units.sh"
installer="$ROOT/bin/omarchy-install-browser"
helper="$ROOT/install/helpers/brave-web-speech.sh"
migration=$(grep -rl 'Install a local speech backend so Web Speech works in Brave' "$ROOT/migrations" | head -n 1 || true)

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

[[ -n $migration ]] || fail "speech backend migration exists"
pass "speech backend migration exists"

# A user speechd.conf would mask the packaged one, including module auto-detect
# and Orca dictionaries. The distro default is enough once espeak-ng is present.
[[ ! -e $ROOT/config/speech-dispatcher/speechd.conf ]] ||
  fail "Omarchy does not ship a user speechd.conf that masks the packaged default"
pass "Omarchy does not ship a user speechd.conf"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home"

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'omarchy-pkg-add\t%s\n' "$*" >>"$OMARCHY_SPEECH_TEST_LOG"
exit "${OMARCHY_SPEECH_PKG_ADD_STATUS:-0}"
SH
cat >"$mock_bin/omarchy-pkg-missing" <<'SH'
#!/bin/bash
for pkg in "$@"; do
  case " $OMARCHY_SPEECH_PRESENT_PKGS " in
    *" $pkg "*) exit 1 ;;
  esac
done
exit 0
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
touch "$log"

run_migration() {
  : >"$log"
  HOME="$test_tmp/home" \
    PATH="$mock_bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_SPEECH_TEST_LOG="$log" \
    OMARCHY_SPEECH_PRESENT_PKGS="${OMARCHY_SPEECH_PRESENT_PKGS-}" \
    bash -euo pipefail "$migration" >/dev/null
}

run_helper() {
  : >"$log"
  HOME="$test_tmp/home" \
    PATH="$mock_bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_SPEECH_TEST_LOG="$log" \
    bash -euo pipefail -c "source \"$helper\"; omarchy_ensure_brave_web_speech" >/dev/null
}

OMARCHY_SPEECH_PRESENT_PKGS= run_migration
[[ ! -s $log ]] || fail "the migration is a no-op without Brave installed" "$(<"$log")"
pass "the migration skips machines without Brave"

if OMARCHY_SPEECH_PRESENT_PKGS=brave-bin OMARCHY_SPEECH_PKG_ADD_STATUS=1 run_migration 2>/dev/null; then
  fail "the migration continues when package installation fails"
fi
grep -qxF $'omarchy-pkg-add\tspeech-dispatcher espeak-ng' "$log" ||
  fail "a failed package install still attempted omarchy-pkg-add"
! grep -q $'systemctl\t' "$log" ||
  fail "a failed package install still enabled the socket"
pass "the migration stops when the speech packages cannot be installed"

OMARCHY_SPEECH_PRESENT_PKGS=brave-bin run_migration
grep -qxF $'omarchy-pkg-add\tspeech-dispatcher espeak-ng' "$log" ||
  fail "the migration installs speech-dispatcher and espeak-ng when Brave is present"
grep -qxF $'systemctl\t--user daemon-reload' "$log" ||
  fail "the migration reloads user units after installing the package"
grep -qxF $'systemctl\t--user enable --now speech-dispatcher.socket' "$log" ||
  fail "the migration enables the speech dispatcher socket"
[[ ! -e $test_tmp/home/.config/systemd/user/sockets.target.wants/speech-dispatcher.socket ]] ||
  fail "a live user manager does not also write a fallback symlink"
pass "the migration installs the packages and enables the socket for existing Brave installs"

OMARCHY_SPEECH_PRESENT_PKGS=brave-origin-bin OMARCHY_SPEECH_ENABLE_STATUS=1 run_migration
[[ -L $test_tmp/home/.config/systemd/user/sockets.target.wants/speech-dispatcher.socket ]] ||
  fail "a TTY update still enables the socket for the next login"
[[ $(readlink "$test_tmp/home/.config/systemd/user/sockets.target.wants/speech-dispatcher.socket") == /usr/lib/systemd/user/speech-dispatcher.socket ]] ||
  fail "the fallback symlink points at the distro socket unit"
pass "the migration writes the socket wants symlink when systemctl cannot enable"

OMARCHY_SPEECH_PRESENT_PKGS=brave-origin-bin OMARCHY_SPEECH_ENABLE_STATUS=1 run_migration
pass "the migration is idempotent when the socket is already linked"

run_helper
grep -qxF $'omarchy-pkg-add\tspeech-dispatcher espeak-ng' "$log" ||
  fail "the Brave install helper installs speech-dispatcher and espeak-ng"
grep -qxF $'systemctl\t--user enable --now speech-dispatcher.socket' "$log" ||
  fail "the Brave install helper enables the speech dispatcher socket"
pass "the Brave install helper installs the packages and enables the socket"
