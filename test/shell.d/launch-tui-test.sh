#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

cat >"$tmp_dir/setsid" <<'SUB'
#!/bin/bash
printf '%s\0' "$@" >"$TEST_LOG"
SUB
chmod +x "$tmp_dir/setsid"

export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir:$ROOT/bin:$PATH"

assert_tui_launch() {
  local description=$1
  shift
  local expected=("$@")

  : >"$TEST_LOG"
  "$ROOT/bin/omarchy-launch-tui" "${input_args[@]}"

  mapfile -d '' -t actual <"$TEST_LOG"
  (( ${#actual[@]} == ${#expected[@]} )) ||
    fail "omarchy-launch-tui $description" "expected length ${#expected[@]}, got ${#actual[@]}\nexpected: ${expected[*]}\nactual: ${actual[*]}"

  for ((index = 0; index < ${#expected[@]}; index++)); do
    [[ ${actual[$index]} == "${expected[$index]}" ]] ||
      fail "omarchy-launch-tui $description" "mismatch at $index: expected '${expected[$index]}', got '${actual[$index]}'"
  done
  pass "omarchy-launch-tui $description"
}

input_args=(nvim)
assert_tui_launch "defaults app-id to command name without title" \
  uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.nvim -e nvim

input_args=(--app-id=org.omarchy.agent agy)
assert_tui_launch "accepts custom app-id" \
  uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.agent -e agy

# Execute the command handed to the terminal to check the actual OSC output,
# argv boundaries, subsequent title updates, and exit status.
cat >"$tmp_dir/agy" <<'SUB'
#!/bin/bash
: >"$COMMAND_LOG"
if (($#)); then
  printf '%s\0' "$@" >"$COMMAND_LOG"
fi
printf '\033]0;Renamed session\007'
exit "${COMMAND_STATUS:-0}"
SUB
chmod +x "$tmp_dir/agy"
ln -s agy "$tmp_dir/claude"
export COMMAND_LOG="$tmp_dir/command-log"

assert_titled_launch() {
  local description=$1 app_id=$2 title=$3
  shift 3
  local expected=("$@") actual=() command_args=()

  "$ROOT/bin/omarchy-launch-tui" "${input_args[@]}"
  mapfile -d '' -t actual <"$TEST_LOG"
  [[ ${actual[0]} == "uwsm-app" && ${actual[1]} == "--" &&
    ${actual[2]} == "xdg-terminal-exec" && ${actual[3]} == "--app-id=$app_id" &&
    ${actual[4]} == "-e" ]] || fail "$description: terminal options must allow title updates"

  local output status=0
  output=$("${actual[@]:5}") || status=$?
  (( status == ${COMMAND_STATUS:-0} )) || fail "$description: command exit status is preserved"
  [[ $output == $'\033]0;'"$title"$'\007\033]0;Renamed session\007' ]] ||
    fail "$description: initial and subsequent titles are emitted"
  mapfile -d '' -t command_args <"$COMMAND_LOG"
  (( ${#command_args[@]} == ${#expected[@]} )) || fail "$description: command argv length"
  for ((index = 0; index < ${#expected[@]}; index++)); do
    [[ ${command_args[index]} == "${expected[index]}" ]] || fail "$description: command argument $index"
  done
  pass "omarchy-launch-tui $description"
}

input_args=(--title="agy: my-proj" agy)
assert_titled_launch "accepts title without custom app-id" org.omarchy.agy "agy: my-proj"

input_args=(--app-id=org.omarchy.agent --title="agy: my-proj" agy --dangerously-skip-permissions)
assert_titled_launch "accepts both app-id and title with extra command arguments" org.omarchy.agent "agy: my-proj" --dangerously-skip-permissions

input_args=(--title="claude: test" --app-id=org.omarchy.agent claude --permission-mode auto)
assert_titled_launch "accepts title before app-id" org.omarchy.agent "claude: test" --permission-mode auto

literal_title=$'Review "quotes"; $(exit 99) `exit 98` \a\033\n café'
input_args=(--title="$literal_title" agy "two words" "" '--title=literal' '$HOME; exit 97')
COMMAND_STATUS=23 assert_titled_launch "keeps title and command text literal and preserves exit status" org.omarchy.agy \
  'Review "quotes"; $(exit 99) `exit 98`  café' "two words" "" '--title=literal' '$HOME; exit 97'
