#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/install/helpers/brave-web-speech.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home/.config"

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
exit "${OMARCHY_SPEECH_PKG_ADD_STATUS:-0}"
SH
cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
if [[ $1 == "--user" && $2 == "enable" ]]; then
  exit "${OMARCHY_SPEECH_ENABLE_STATUS:-0}"
fi
exit 0
SH
chmod +x "$mock_bin"/*

flags="$test_tmp/home/.config/brave-flags.conf"
wants_link="$test_tmp/home/.config/systemd/user/sockets.target.wants/speech-dispatcher.socket"

run_helper() {
  HOME="$test_tmp/home" \
    PATH="$mock_bin:$PATH" \
    bash -euo pipefail -c "source \"$helper\"; omarchy_ensure_brave_web_speech \"$1\"" >/dev/null
}

cp "$ROOT/config/chromium-flags.conf" "$flags"
if OMARCHY_SPEECH_PKG_ADD_STATUS=1 run_helper "$flags" 2>/dev/null; then
  fail "the helper stops when the speech packages cannot be installed"
fi
if grep -qxF -- --enable-speech-dispatcher "$flags"; then
  fail "a failed package install still changed the Brave flags"
fi
[[ ! -e $wants_link ]] || fail "a failed package install still enabled the socket"
pass "the helper stops when the speech packages cannot be installed"

cp "$ROOT/config/chromium-flags.conf" "$flags"
run_helper "$flags"
grep -qxF -- --enable-speech-dispatcher "$flags" ||
  fail "Brave is started with speech-dispatcher enabled" "$(<"$flags")"
grep -qxF -- --ozone-platform=wayland "$flags" || fail "the existing Brave flags are kept"
pass "the helper turns on speech-dispatcher in the Brave flags"

printf -- '--ozone-platform=wayland' >"$flags"
run_helper "$flags"
[[ $(<"$flags") == $'--ozone-platform=wayland\n--enable-speech-dispatcher' ]] ||
  fail "the flag goes on its own line when the file lacks a trailing newline" "$(<"$flags")"
pass "the helper appends the flag on its own line"

rm -f "$flags"
run_helper "$flags"
[[ ! -e $flags ]] || fail "the helper does not create a Brave flags file the user removed"
pass "the helper leaves a missing Brave flags file alone"

cp "$ROOT/config/chromium-flags.conf" "$flags"
OMARCHY_SPEECH_ENABLE_STATUS=1 run_helper "$flags"
OMARCHY_SPEECH_ENABLE_STATUS=1 run_helper "$flags"
[[ $(readlink "$wants_link") == "/usr/lib/systemd/user/speech-dispatcher.socket" ]] ||
  fail "a TTY run still links the distro socket unit for the next login"
(( $(grep -cxF -- --enable-speech-dispatcher "$flags") == 1 )) ||
  fail "running again does not repeat the speech-dispatcher flag"
pass "the helper links the socket without a user manager and is idempotent"

rm -rf "$test_tmp/home/.config/systemd"
mkdir -p "$test_tmp/home/.config/systemd/user"
touch "$test_tmp/home/.config/systemd/user/sockets.target.wants"
if HOME="$test_tmp/home" PATH="$mock_bin:$PATH" OMARCHY_SPEECH_ENABLE_STATUS=1 \
  bash -euo pipefail -c "source \"$helper\"; omarchy_ensure_brave_web_speech \"$flags\" || exit 1" >/dev/null 2>&1; then
  fail "a socket fallback that cannot link fails the Brave install"
fi
pass "a socket fallback that cannot link fails the Brave install"
