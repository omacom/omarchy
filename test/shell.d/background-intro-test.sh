#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
runtime_dir="$test_tmp/runtime"
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls"
backgrounds="$test_home/.local/state/omarchy/current/theme/backgrounds"
user_intros="$test_home/.config/omarchy/backgrounds/catppuccin/intros"
mkdir -p "$backgrounds/intros" "$runtime_dir/owe" "$stub_bin" "$test_home/.local/state/omarchy/toggles/hypr"
echo catppuccin >"$test_home/.local/state/omarchy/current/theme.name"
: >"$backgrounds/1-totoro.webp"
: >"$backgrounds/2-waves.webp"
: >"$backgrounds/intros/1-totoro.mp4"
ln -nsf "$backgrounds/1-totoro.webp" "$test_home/.local/state/omarchy/current/background"
# The script waits for owed's socket, and only checks that the path is a socket.
python3 -c 'import socket, sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' "$runtime_dir/owe/owed.sock"

cat >"$stub_bin/owe" <<'EOF'
#!/bin/bash
echo "owe $*" >>"$CALLS"
exit "${OWE_STATUS:-0}"
EOF
cat >"$stub_bin/omarchy-shell" <<'EOF'
#!/bin/bash
echo "shell $* timeout=${OMARCHY_SHELL_IPC_TIMEOUT:-}" >>"$CALLS"
EOF
cat >"$stub_bin/systemctl" <<'EOF'
#!/bin/bash
[[ $* == "--user is-enabled --quiet owed.service" ]] && exit "${OWED_DISABLED:-0}"
exit 1
EOF
chmod +x "$stub_bin/owe" "$stub_bin/omarchy-shell" "$stub_bin/systemctl"

intro() {
  : >"$calls"
  HOME="$test_home" OMARCHY_PATH="$ROOT" XDG_RUNTIME_DIR="$runtime_dir" HYPRLAND_INSTANCE_SIGNATURE=test \
    CALLS="$calls" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-bg-intro" "$@"
}

# Playback runs on after the command returns.
wait_for_call() {
  local deadline=$((SECONDS + 5))
  until grep -q -- "$1" "$calls" || (( SECONDS > deadline )); do sleep 0.05; done
}

intro --check || fail "the current background's intro is found beside it"
intro --check "$backgrounds/2-waves.webp" && fail "a background without an intro has none to play"
pass "an intro is found in the intros folder beside its still"

mkdir -p "$user_intros"
: >"$user_intros/2-waves.webm"
intro --check "$backgrounds/2-waves.webp" || fail "a user intro gives a theme still an intro"
rm -rf "$user_intros"
pass "a user intro gives a theme still an intro"

: >"$backgrounds/intros/3-video.mp4"
: >"$backgrounds/3-video.mp4"
intro --check "$backgrounds/3-video.mp4" && fail "a video background plays no intro"
pass "a video background plays no intro"

: >"$test_home/.local/state/omarchy/toggles/hypr/no-animations.lua"
intro --check && fail "no-animations mode plays no intro"
rm "$test_home/.local/state/omarchy/toggles/hypr/no-animations.lua"
pass "no-animations mode plays no intro"

# OWE fades the intro in from the still on screen and back into it, so the
# shell only reveals the still as usual and hands the intro over.
intro || fail "a background with an intro plays it"
wait_for_call '^owe intro'
[[ $(<"$calls") == "owe intro $backgrounds/intros/1-totoro.mp4" ]] || fail "a background hands its intro to OWE" "$(<"$calls")"
pass "a background hands its intro to OWE"

# A switch waits for its still's reveal before the intro, and a background
# chosen meanwhile, as when cycling through them, does not get that intro.
intro "$backgrounds/1-totoro.webp" || fail "a background with an intro plays it"
ln -nsf "$backgrounds/2-waves.webp" "$test_home/.local/state/omarchy/current/background"
sleep 1
[[ ! -s $calls ]] || fail "a background switched away from plays no intro" "$(<"$calls")"
ln -nsf "$backgrounds/1-totoro.webp" "$test_home/.local/state/omarchy/current/background"
pass "a background switched away from plays no intro"

# The login's intro plays once per Hyprland session, and the first shell claims
# the session even when its background has no intro, so a later shell does not
# take an intro chosen afterwards for the login's.
ln -nsf "$backgrounds/2-waves.webp" "$test_home/.local/state/omarchy/current/background"
intro --login && fail "a login without an intro plays none"
ln -nsf "$backgrounds/1-totoro.webp" "$test_home/.local/state/omarchy/current/background"
intro --login && fail "a later shell does not replay the login intro"
rm "$runtime_dir/omarchy/background-intro-test"
intro --login || fail "a login plays the background's intro"
wait_for_call '^owe intro'
pass "a login plays its intro once per session"

# A login has no still on screen for the intro to fade in from, so it starts
# on the intro's first frame.
[[ $(<"$calls") == "owe intro --no-fade-in $backgrounds/intros/1-totoro.mp4" ]] || fail "a login starts its intro on the first frame" "$(<"$calls")"
pass "a login starts its intro on the first frame"

# The shell holds a login's still while its intro starts, so an intro that
# cannot play shows the still, and without owed there is nothing to hold for.
rm "$runtime_dir/omarchy/background-intro-test"
OWE_STATUS=1 intro --login || fail "a login hands its intro to OWE"
wait_for_call '^shell -q background refresh'
[[ $(<"$calls") == *"shell -q background refresh timeout=4s"* ]] || fail "a login intro that cannot play shows the still" "$(<"$calls")"
rm "$runtime_dir/omarchy/background-intro-test"
OWED_DISABLED=1 intro --login && fail "a login without owed holds no still"
pass "a login intro that cannot play shows the still"

# Intros sit one folder down, where no background list looks.
for command in omarchy-theme-bg-next omarchy-menu-images; do
  grep -q -- '-maxdepth 1' "$ROOT/bin/$command" || fail "$command lists only the top of a background folder"
done
pass "intros never appear as backgrounds"

run_node_test <<'JS'
const fs = require('fs')
const backgroundQml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')
const themeSet = fs.readFileSync(path.join(root, 'bin/omarchy-theme-set'), 'utf8')
const bgSet = fs.readFileSync(path.join(root, 'bin/omarchy-theme-bg-set'), 'utf8')

assert(
  /Component\.onCompleted: loginIntroProc\.running = true/.test(backgroundQml) &&
    /command: \["omarchy-theme-bg-intro", "--login"\]\s*onExited: function\(exitCode\) \{\s*if \(exitCode === 0\) loginIntroFallback\.start\(\)\s*else root\.refreshBackground\(\)/.test(backgroundQml) &&
    /id: loginIntroFallback[\s\S]*?onTriggered: root\.refreshBackground\(\)/.test(backgroundQml),
  'the starting shell holds its still only while a login intro starts'
)
assert(
  bgSet.indexOf('omarchy-theme-bg-intro "$BACKGROUND"') > bgSet.indexOf('omarchy-shell -q background set "$BACKGROUND"'),
  'a background switch reveals the still before its intro'
)
assert(
  themeSet.indexOf('omarchy-theme-bg-intro >/dev/null') > themeSet.indexOf('omarchy-hook theme-set "$THEME_NAME"'),
  'theme set starts the intro after the theme-set hooks, whose OWE refresh ends a playing intro'
)
assert(
  themeSet.includes('[[ $OMARCHY_THEME_SKIP_BACKGROUND == "1" ]] || omarchy-theme-bg-intro >/dev/null'),
  'a theme refresh, which keeps the background, plays no intro'
)
JS
