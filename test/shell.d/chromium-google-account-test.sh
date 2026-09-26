#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

export OMARCHY_PATH="$ROOT"

TEST_ROOT=""
HOME_BACKUP=${HOME:-}
PATH_BACKUP=$PATH

cleanup() {
  PATH=$PATH_BACKUP
  HOME=$HOME_BACKUP
  if [[ -n ${TEST_ROOT:-} && -d $TEST_ROOT ]]; then
    rm -rf "$TEST_ROOT"
  fi
}
trap cleanup EXIT

TEST_ROOT=$(mktemp -d)
export HOME="$TEST_ROOT"
export TMPDIR="$TEST_ROOT"
mkdir -p "$HOME/.config" "$TEST_ROOT/stub-bin"

cat >"$TEST_ROOT/stub-bin/omarchy-pkg-present" <<'EOF'
#!/bin/bash
[[ ${STUB_GOOGLE_CHROME_PRESENT:-0} == 1 ]]
EOF

cat >"$TEST_ROOT/stub-bin/omarchy-install-browser" <<'EOF'
#!/bin/bash
printf 'stub-install-browser %s\n' "$*" >>"$HOME/actions.log"
EOF

chmod 755 "$TEST_ROOT/stub-bin/omarchy-pkg-present" "$TEST_ROOT/stub-bin/omarchy-install-browser"
export PATH="$TEST_ROOT/stub-bin:$ROOT/bin:$PATH"

export STUB_GOOGLE_CHROME_PRESENT=0
cat >"$HOME/.config/chromium-flags.conf" <<'EOF'
--ozone-platform=wayland
--oauth2-client-id=77185425430.apps.googleusercontent.com
--oauth2-client-secret=OTJgUOQcT7lO7GsGZq2G4IlT
--password-store=gnome-libsecret
EOF

output=$(omarchy-install-chromium-google-account)

grep -qE -- '^--oauth2-client-(id|secret)=' "$HOME/.config/chromium-flags.conf" &&
  fail "installer removes oauth2 workaround flags" "$output"
grep -qxF -- '--ozone-platform=wayland' "$HOME/.config/chromium-flags.conf" ||
  fail "installer keeps unrelated Chromium flags" "$(cat "$HOME/.config/chromium-flags.conf")"
grep -qxF -- '--password-store=gnome-libsecret' "$HOME/.config/chromium-flags.conf" ||
  fail "installer keeps unrelated Chromium flags" "$(cat "$HOME/.config/chromium-flags.conf")"
[[ -f $HOME/actions.log ]] && grep -qxF 'stub-install-browser chrome' "$HOME/actions.log" ||
  fail "installer installs Chrome when it is missing" "$(cat "$HOME/actions.log" 2>/dev/null)"
pass "installer removes oauth2 workaround flags and installs Chrome when missing"

rm -f "$HOME/actions.log"
export STUB_GOOGLE_CHROME_PRESENT=1
cat >"$HOME/.config/chromium-flags.conf" <<'EOF'
--ozone-platform=wayland
EOF

output=$(omarchy-install-chromium-google-account)
[[ ! -f $HOME/actions.log ]] ||
  fail "installer skips Chrome when it is already present" "$(cat "$HOME/actions.log")"
grep -qxF -- '--ozone-platform=wayland' "$HOME/.config/chromium-flags.conf" ||
  fail "installer leaves a clean flags file alone" "$(cat "$HOME/.config/chromium-flags.conf")"
pass "installer skips Chrome when it is already present"
