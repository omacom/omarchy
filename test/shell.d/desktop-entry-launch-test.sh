#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" "$test_home"

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
exit "${OMARCHY_TEST_PKG_STATUS:-0}"
SH

cat >"$mock_bin/omarchy-font-set" <<'SH'
#!/bin/bash
printf 'font:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
SH

for command in omarchy-pkg-aur-add omarchy-install-emacs omazed omarchy-theme-set-vscode omarchy-install-gaming-gpu-lib32 omarchy-lifecycle-dispatch; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
exit 0
SH
done

cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
printf 'launch:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
SH

cat >"$mock_bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >"$OMARCHY_TEST_PRESENTATION"
SH

chmod +x "$mock_bin"/*

export HOME="$test_home"
export OMARCHY_TEST_LOG="$test_tmp/launch.log"
export OMARCHY_TEST_PRESENTATION="$test_tmp/presentation"
export PATH="$mock_bin:$PATH"

wait_for_launch() {
  local expected="$1"

  for ((attempt = 0; attempt < 100; attempt++)); do
    grep -Fxq "$expected" "$OMARCHY_TEST_LOG" && return 0
    sleep 0.01
  done

  return 1
}

assert_detached_installer_launch() {
  local script="$1"
  local desktop_id="$2"

  : >"$OMARCHY_TEST_LOG"
  bash "$ROOT/bin/$script"

  wait_for_launch "launch:-f uwsm-app -- gtk-launch $desktop_id" ||
    fail "$script launches its desktop entry through setsid and gtk-launch in a UWSM scope"
  pass "$script detaches its scoped desktop-entry launch"
}

assert_detached_installer_launch omarchy-install-editor-emacs emacsclient
assert_detached_installer_launch omarchy-install-editor-vscode code
assert_detached_installer_launch omarchy-install-editor-zed dev.zed.Zed
assert_detached_installer_launch omarchy-install-gaming-heroic heroic
assert_detached_installer_launch omarchy-install-gaming-steam steam

bash "$ROOT/bin/omarchy-install-and-launch" "Example App" "alpha beta" "Disk Usage"
presentation_command=$(<"$OMARCHY_TEST_PRESENTATION")

[[ $presentation_command == *'echo Installing\ Example\ App...;'* ]] ||
  fail "generic installer shell-quotes the display name" "$presentation_command"
[[ $presentation_command == *'omarchy-pkg-add alpha beta && omarchy-launch-after-done uwsm-app -- gtk-launch Disk\ Usage'* ]] ||
  fail "generic installer waits for packages and detaches only the scoped launch" "$presentation_command"
pass "generic installer waits for packages and detaches only the scoped launch"

: >"$OMARCHY_TEST_LOG"
bash -c "$presentation_command"
grep -Fxq 'pkg:alpha beta' "$OMARCHY_TEST_LOG" ||
  fail "generic installer passes every package to the package helper"
wait_for_launch 'launch:-f uwsm-app -- gtk-launch Disk Usage' ||
  fail "generic installer preserves a desktop ID containing spaces"
pass "generic installer preserves a desktop ID containing spaces"

: >"$OMARCHY_TEST_LOG"
if OMARCHY_TEST_PKG_STATUS=1 bash -c "$presentation_command"; then
  fail "generic installer propagates package installation failure"
fi
if grep -q '^launch:' "$OMARCHY_TEST_LOG"; then
  fail "generic installer does not launch after package installation failure"
fi
pass "generic installer does not launch after package installation failure"

run_presentation() {
  bash -c "sleep() { :; }; $(<"$OMARCHY_TEST_PRESENTATION")"
}

bash "$ROOT/bin/omarchy-install-app" "LM Studio" "lmstudio-bin"
presentation_command=$(<"$OMARCHY_TEST_PRESENTATION")
[[ $presentation_command == *'echo Installing\ LM\ Studio...;'* ]] ||
  fail "install-app shell-quotes the display name" "$presentation_command"
[[ $presentation_command == *'omarchy-pkg-add lmstudio-bin'* ]] ||
  fail "install-app still passes the package list through" "$presentation_command"
pass "install-app shell-quotes the display name"

bash "$ROOT/bin/omarchy-install-app" "Example App" "alpha beta"
presentation_command=$(<"$OMARCHY_TEST_PRESENTATION")
[[ $presentation_command == 'echo Installing\ Example\ App...; omarchy-pkg-add alpha beta' ]] ||
  fail "install-app builds the presentation command with no stray argument" "$presentation_command"
: >"$OMARCHY_TEST_LOG"
run_presentation
grep -Fxq 'pkg:alpha beta' "$OMARCHY_TEST_LOG" ||
  fail "install-app passes every package to the package helper"
pass "install-app passes every package to the package helper"

bash "$ROOT/bin/omarchy-install-app" "Foo's App" "alpha"
presentation_command=$(<"$OMARCHY_TEST_PRESENTATION")
quoted_app_message="echo $(printf '%q' "Installing Foo's App...");"
[[ $presentation_command == "$quoted_app_message"* ]] ||
  fail "install-app shell-quotes an apostrophe in the display name" "$presentation_command"
: >"$OMARCHY_TEST_LOG"
run_presentation >"$test_tmp/app-apostrophe.out"
grep -Fxq 'pkg:alpha' "$OMARCHY_TEST_LOG" ||
  fail "install-app still installs when the display name has an apostrophe"
pass "install-app still installs when the display name has an apostrophe"

bash "$ROOT/bin/omarchy-install-app" "a'; echo PWNED; echo '" "alpha"
: >"$OMARCHY_TEST_LOG"
run_presentation >"$test_tmp/app-inject.out"
if grep -Fxq 'PWNED' "$test_tmp/app-inject.out"; then
  fail "install-app does not run extra commands from a quote in the display name" "$(<"$test_tmp/app-inject.out")"
fi
grep -Fxq 'pkg:alpha' "$OMARCHY_TEST_LOG" ||
  fail "install-app still installs after quoting a hostile display name"
pass "install-app does not run extra commands from a quote in the display name"

bash "$ROOT/bin/omarchy-install-font" "Cascadia Mono" "ttf-cascadia-mono-nerd" "CaskaydiaMono Nerd Font"
presentation_command=$(<"$OMARCHY_TEST_PRESENTATION")
[[ $presentation_command == *'echo Installing\ Cascadia\ Mono...;'* ]] ||
  fail "install-font shell-quotes the display name" "$presentation_command"
[[ $presentation_command == *'omarchy-font-set CaskaydiaMono\ Nerd\ Font'* ]] ||
  fail "install-font shell-quotes a font family with spaces" "$presentation_command"
: >"$OMARCHY_TEST_LOG"
run_presentation
grep -Fxq 'pkg:ttf-cascadia-mono-nerd' "$OMARCHY_TEST_LOG" ||
  fail "install-font installs the font package"
grep -Fxq 'font:CaskaydiaMono Nerd Font' "$OMARCHY_TEST_LOG" ||
  fail "install-font passes the family name through as one argument"
pass "install-font shell-quotes the display name and family"

bash "$ROOT/bin/omarchy-install-font" "Foo's App" "alpha" "Foo's Font"
: >"$OMARCHY_TEST_LOG"
run_presentation >"$test_tmp/font-apostrophe.out"
grep -Fxq 'pkg:alpha' "$OMARCHY_TEST_LOG" ||
  fail "install-font still installs when the display name has an apostrophe"
grep -Fxq "font:Foo's Font" "$OMARCHY_TEST_LOG" ||
  fail "install-font still sets the family when it has an apostrophe"
pass "install-font still installs when the name or family has an apostrophe"

bash "$ROOT/bin/omarchy-install-font" "a'; echo PWNED; echo '" "alpha" "a'; echo PWNED; echo '"
: >"$OMARCHY_TEST_LOG"
run_presentation >"$test_tmp/font-inject.out"
if grep -Fxq 'PWNED' "$test_tmp/font-inject.out"; then
  fail "install-font does not run extra commands from a quote in the name or family" "$(<"$test_tmp/font-inject.out")"
fi
grep -Fxq 'pkg:alpha' "$OMARCHY_TEST_LOG" ||
  fail "install-font still installs after quoting a hostile display name"
pass "install-font does not run extra commands from a quote in the name or family"

bash "$ROOT/bin/omarchy-install-app" "Example App" "alpha; echo PWNED"
: >"$OMARCHY_TEST_LOG"
run_presentation >"$test_tmp/app-pkg-inject.out"
if grep -Fxq 'PWNED' "$test_tmp/app-pkg-inject.out"; then
  fail "install-app does not run extra commands from a package list" "$(<"$test_tmp/app-pkg-inject.out")"
fi
grep -Fxq 'pkg:alpha; echo PWNED' "$OMARCHY_TEST_LOG" ||
  fail "install-app hands a hostile package list to the package helper as arguments" "$(<"$OMARCHY_TEST_LOG")"
pass "install-app does not run extra commands from a package list"

bash "$ROOT/bin/omarchy-install-app" "Example App" "$(printf 'alpha\nbeta')"
: >"$OMARCHY_TEST_LOG"
run_presentation
grep -Fxq 'pkg:alpha beta' "$OMARCHY_TEST_LOG" ||
  fail "install-app keeps every package when the list is newline-separated" "$(<"$OMARCHY_TEST_LOG")"
pass "install-app keeps every package when the list is newline-separated"

env SHELLOPTS=errexit bash "$ROOT/bin/omarchy-install-app" "Example App" "alpha beta" ||
  fail "install-app builds its command under an inherited errexit"
[[ $(<"$OMARCHY_TEST_PRESENTATION") == 'echo Installing\ Example\ App...; omarchy-pkg-add alpha beta' ]] ||
  fail "install-app builds the same command under an inherited errexit" "$(<"$OMARCHY_TEST_PRESENTATION")"
env SHELLOPTS=errexit bash "$ROOT/bin/omarchy-install-and-launch" "Example App" "alpha beta" "Disk Usage" ||
  fail "install-and-launch builds its command under an inherited errexit"
grep -Fq 'omarchy-pkg-add alpha beta' "$OMARCHY_TEST_PRESENTATION" ||
  fail "install-and-launch keeps its package list under an inherited errexit" "$(<"$OMARCHY_TEST_PRESENTATION")"
pass "the installers build their command under an inherited errexit"

bash "$ROOT/bin/omarchy-install-font" "Example Font" "alpha; echo PWNED" "Example Family"
: >"$OMARCHY_TEST_LOG"
run_presentation >"$test_tmp/font-pkg-inject.out"
if grep -Fxq 'PWNED' "$test_tmp/font-pkg-inject.out"; then
  fail "install-font does not run extra commands from its package" "$(<"$test_tmp/font-pkg-inject.out")"
fi
grep -Fxq 'pkg:alpha; echo PWNED' "$OMARCHY_TEST_LOG" ||
  fail "install-font hands a hostile package to the package helper as one argument" "$(<"$OMARCHY_TEST_LOG")"
pass "install-font does not run extra commands from its package"

bash "$ROOT/bin/omarchy-install-font" "Example Font" "alpha" "Example Family"
: >"$OMARCHY_TEST_LOG"
if OMARCHY_TEST_PKG_STATUS=1 run_presentation; then
  fail "install-font propagates package installation failure"
fi
if grep -q '^font:' "$OMARCHY_TEST_LOG"; then
  fail "install-font does not set the family after package installation failure" "$(<"$OMARCHY_TEST_LOG")"
fi
pass "install-font does not set the family after package installation failure"

bash "$ROOT/bin/omarchy-install-and-launch" "Example App" "alpha; echo PWNED" "Disk Usage"
: >"$OMARCHY_TEST_LOG"
run_presentation >"$test_tmp/launch-pkg-inject.out"
if grep -Fxq 'PWNED' "$test_tmp/launch-pkg-inject.out"; then
  fail "install-and-launch does not run extra commands from a package list" "$(<"$test_tmp/launch-pkg-inject.out")"
fi
grep -Fxq 'pkg:alpha; echo PWNED' "$OMARCHY_TEST_LOG" ||
  fail "install-and-launch hands a hostile package list to the package helper as arguments" "$(<"$OMARCHY_TEST_LOG")"
pass "install-and-launch does not run extra commands from a package list"

# The real presentation, its terminal replaced by running the script here. A
# window that opens while the Done prompt waits takes the key meant for it.
presentation_bin="$test_tmp/presentation-bin"
mkdir -p "$presentation_bin" "$test_home/.openclaw"
touch "$test_home/.openclaw/openclaw.json"
ln -s "$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" "$presentation_bin/"
cat >"$presentation_bin/setsid" <<'SH'
#!/bin/bash
if [[ $* == *' xdg-terminal-exec '* ]]; then
  exec bash -c "${!#}"
fi
printf 'launch:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
SH
# Long enough for a launch started before the prompt to be logged first.
cat >"$presentation_bin/omarchy-show-done" <<'SH'
#!/bin/bash
sleep 0.1
printf 'done:%s\n' "$1" >>"$OMARCHY_TEST_LOG"
SH
cat >"$presentation_bin/omarchy-setup-slack" <<'SH'
#!/bin/bash
exit "${OMARCHY_TEST_SLACK_SETUP_STATUS:-0}"
SH
cat >"$presentation_bin/omarchy-hw-x86" <<'SH'
#!/bin/bash
exit "${OMARCHY_TEST_X86_STATUS:-0}"
SH
for command in omarchy-show-logo omarchy-restart-gum; do
  printf '#!/bin/bash\n' >"$presentation_bin/$command"
done
for command in omarchy-install-openclaw-cli omarchy-install-hermes-cli omarchy-webapp-install omarchy-cmd-missing sudo curl; do
  printf '#!/bin/bash\nexit 0\n' >"$presentation_bin/$command"
done
chmod +x "$presentation_bin"/*

assert_opens_after_done() {
  local name="$1" expected="$2"
  shift 2

  : >"$OMARCHY_TEST_LOG"
  PATH="$presentation_bin:$PATH" "$@" >"$test_tmp/presentation.out" 2>&1 || true
  [[ $(grep -E '^(done|launch):' "$OMARCHY_TEST_LOG" | cut -d' ' -f1 | paste -sd ' ') == "$expected" ]] ||
    fail "$name opens its app only once the Done prompt has its key" "$(cat "$OMARCHY_TEST_LOG" "$test_tmp/presentation.out")"
}

for installer in omarchy-install-service-slack omarchy-install-ai-chatgpt omarchy-install-ai-claude omarchy-install-ai-hermes \
  omarchy-install-ai-openclaw omarchy-install-editor-vscode omarchy-install-editor-zed omarchy-install-editor-emacs \
  omarchy-install-service-1password omarchy-install-service-signal \
  omarchy-install-gaming-steam omarchy-install-gaming-heroic omarchy-install-gaming-lutris omarchy-install-gaming-retroarch \
  omarchy-install-gaming-xbox-cloud; do
  assert_opens_after_done "$installer" "done:0 launch:-f" omarchy-launch-floating-terminal-with-presentation "$installer"
done
OMARCHY_TEST_SLACK_SETUP_STATUS=1 assert_opens_after_done "Slack after a failed theme setup" "done:0 launch:-f" \
  omarchy-launch-floating-terminal-with-presentation omarchy-install-service-slack
# Battle.net's setup runs from the presentation's shell, not the installer's.
assert_opens_after_done "Battle.net's setup" "done:0 launch:-f" \
  omarchy-launch-floating-terminal-with-presentation omarchy-install-gaming-battlenet
grep -Fq "launch:-f env WINEPREFIX=$test_home/Games/battlenet PROTONPATH=GE-Proton GAMEID=umu-battlenet PROTON_VERB=run " "$OMARCHY_TEST_LOG" ||
  fail "Battle.net's setup keeps its Wine prefix and Proton settings once the Done prompt has its key" "$(<"$OMARCHY_TEST_LOG")"
assert_opens_after_done omarchy-install-and-launch "done:0 launch:-f" omarchy-install-and-launch "Example App" "alpha beta" "Disk Usage"
assert_opens_after_done "a failed command" "done:1 launch:-f" \
  omarchy-launch-floating-terminal-with-presentation 'omarchy-launch-after-done uwsm-app -- gtk-launch code; false'
assert_opens_after_done "Ctrl-C" "launch:-f" \
  omarchy-launch-floating-terminal-with-presentation 'omarchy-launch-after-done uwsm-app -- gtk-launch code; (exit 130)'
pass "installers in the presentation open their app only once the Done prompt has its key"
