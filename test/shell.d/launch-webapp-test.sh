#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
fake_home="$test_tmp/home"
mkdir -p "$mock_bin" "$fake_home/.local/share/applications"

export HOME="$fake_home"

default_file="$test_tmp/default-browser"
allow_file="$test_tmp/allowed-commands"
launch_log="$test_tmp/launched"
notify_log="$test_tmp/notified"
export OMARCHY_TEST_DEFAULT_FILE="$default_file" OMARCHY_TEST_ALLOW_FILE="$allow_file" OMARCHY_TEST_LAUNCH_LOG="$launch_log" OMARCHY_TEST_NOTIFY_LOG="$notify_log"
: >"$allow_file"
: >"$notify_log"

cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
if [[ $1 == "get" ]]; then
  cat "$OMARCHY_TEST_DEFAULT_FILE"
fi
SH

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
grep -qx "$1" "$OMARCHY_TEST_ALLOW_FILE"
SH

cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$mock_bin/uwsm-app" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_LAUNCH_LOG"
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >>"$OMARCHY_TEST_NOTIFY_LOG"
SH

chmod +x "$mock_bin"/*

export PATH="$mock_bin:/usr/bin:/bin"

make_desktop() {
  local name="$1" exec="$2"
  printf '[Desktop Entry]\nExec=%s %%U\n' "$exec" >"$fake_home/.local/share/applications/$name"
}

make_fake_browser() {
  local name="$1"
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$name"
  chmod +x "$mock_bin/$name"
  printf '%s\n' "$name" >>"$allow_file"
}

launch_lines() {
  mapfile -t OMARCHY_TEST_LAUNCHED <"$launch_log"
}

# An unknown Chromium fork set as default is used as-is: no allowlist update needed.
make_fake_browser fake-fork
make_desktop "fake-fork.desktop" "fake-fork"
printf 'fake-fork.desktop\n' >"$default_file"
rm -f "$launch_log"
"$ROOT/bin/omarchy-launch-webapp" "https://example.com/"
launch_lines
[[ ${OMARCHY_TEST_LAUNCHED[1]:-} == "fake-fork" ]] || fail "unlisted Chromium default is used as-is" "${OMARCHY_TEST_LAUNCHED[*]:-empty}"
[[ ${OMARCHY_TEST_LAUNCHED[2]:-} == "--app=https://example.com/" ]] || fail "unlisted Chromium default gets --app mode" "${OMARCHY_TEST_LAUNCHED[*]:-empty}"
pass "unlisted Chromium default is used as-is"

# A Firefox-family default falls back to an installed Chromium browser.
make_fake_browser fake-helium
make_desktop "helium.desktop" "fake-helium"
printf 'firefox.desktop\n' >"$default_file"
rm -f "$launch_log"
"$ROOT/bin/omarchy-launch-webapp" "https://youtube.com/"
launch_lines
[[ ${OMARCHY_TEST_LAUNCHED[1]:-} == "fake-helium" ]] || fail "Gecko default falls back to installed Chromium browser" "${OMARCHY_TEST_LAUNCHED[*]:-empty}"
[[ ${OMARCHY_TEST_LAUNCHED[2]:-} == "--app=https://youtube.com/" ]] || fail "fallback browser gets --app mode" "${OMARCHY_TEST_LAUNCHED[*]:-empty}"
pass "Gecko default falls back to installed Chromium browser"

# A default whose desktop entry is gone (browser uninstalled) falls back too.
printf 'removed-browser.desktop\n' >"$default_file"
rm -f "$launch_log"
"$ROOT/bin/omarchy-launch-webapp" "https://youtube.com/"
launch_lines
[[ ${OMARCHY_TEST_LAUNCHED[1]:-} == "fake-helium" ]] || fail "missing default desktop entry falls back" "${OMARCHY_TEST_LAUNCHED[*]:-empty}"
pass "missing default desktop entry falls back"

# With nothing usable for the user, the host decides the expectation: fall
# back to a system browser when one is usable *as the script sees it* (same
# resolvability rules: stubbed command allowlist for bare names, -x for
# absolute paths), otherwise fail loudly instead of exec'ing an empty binary.
host_has_chromium_browser() {
  local candidate exec_path
  for candidate in chromium.desktop google-chrome.desktop brave-browser.desktop brave-origin.desktop microsoft-edge.desktop opera.desktop vivaldi-stable.desktop helium.desktop ungoogled-chromium.desktop; do
    [[ -f /usr/share/applications/$candidate ]] || continue
    exec_path=$(sed -n 's/^Exec=\([^ ]*\).*/\1/p' /usr/share/applications/$candidate 2>/dev/null | head -1)
    [[ -n $exec_path ]] || continue
    if [[ $exec_path == /* ]]; then
      [[ -x $exec_path ]] && return 0
    else
      grep -qx "$exec_path" "$allow_file" && return 0
    fi
  done
  return 1
}

rm -f "$fake_home/.local/share/applications/"*.desktop
rm -f "$launch_log"
: >"$notify_log"
if host_has_chromium_browser; then
  if "$ROOT/bin/omarchy-launch-webapp" "https://example.com/"; then
    [[ -f $launch_log ]] || fail "system fallback launches something" "no launch logged"
    pass "falls back to system browser when user has none"
  else
    fail "falls back to system browser when user has none" "exited non-zero"
  fi
else
  if "$ROOT/bin/omarchy-launch-webapp" "https://example.com/"; then
    fail "fails loudly with no usable browser" "exited zero"
  else
    [[ ! -f $launch_log ]] || fail "fails loudly with no usable browser" "launched with empty binary: $(cat "$launch_log")"
    [[ -s $notify_log ]] || fail "fails loudly with no usable browser" "no notification sent"
    pass "fails loudly with no usable browser"
  fi
fi
