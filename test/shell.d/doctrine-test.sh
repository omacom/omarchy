#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command fzf

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/home" "$scratch/state"
export HOME="$scratch/home"
export OMARCHY_PATH="$ROOT"
export OMARCHY_DOCTRINE_STATE="$scratch/state"
export DOCTRINE_BROWSER_LOG="$scratch/urls"
export PATH="$scratch/bin:$PATH"
echo index > "$OMARCHY_DOCTRINE_STATE/mode"

cat > "$scratch/bin/omarchy-launch-browser" <<'STUB'
#!/bin/bash
printf '%s\n' "$1" >> "$DOCTRINE_BROWSER_LOG"
STUB
chmod +x "$scratch/bin/omarchy-launch-browser"

assert_equal() {
  local actual=$1 expected=$2 description=$3
  [[ $actual == "$expected" ]] || fail "$description" "Expected: $expected; actual: $actual"
  pass "$description"
}

assert_contains() {
  local actual=$1 expected=$2 description=$3
  [[ $actual == *"$expected"* ]] || fail "$description" "Missing: $expected"
  pass "$description"
}

doctrine() {
  "$ROOT/bin/omarchy" doctrine "$@" </dev/null
}

action() {
  bash "$ROOT/default/omarchy/doctrine-reader.sh" action "$@"
}

short=$(doctrine)
full=$(doctrine --full)
mapfile -t titles < <(sed -n 's/^## //p' "$ROOT/default/omarchy/doctrine.md")
assert_equal "${#titles[@]}" 10 "plain output works without a terminal"
normalized_full=$(printf '%s\n' "$full" | awk '{$1=$1; printf "%s ", $0}')
for index in "${!titles[@]}"; do
  title=${titles[index]}
  body=$(awk -v number="$((index + 1))" '
    /^## / { section++; next }
    section == number && NF { $1=$1; printf "%s ", $0 }
  ' "$ROOT/default/omarchy/doctrine.md")
  [[ $short == *"$title"* && $normalized_full == *"$body"* ]] || fail "plain views preserve $title"
  pass "plain views preserve $title"
done
[[ $short$full != *$'\033'* ]] || fail "plain output has no terminal escapes"
pass "plain output has no terminal escapes"
assert_equal "$(doctrine --plain)" "$short" "the explicit plain alias matches default output"
assert_contains "$(doctrine 10)" "https://omarchy.org/doctrine/#youre-somebody-now" "direct principle output preserves its website anchor"

assert_rejected() {
  local status=0
  doctrine "$@" > "$scratch/stdout" 2> "$scratch/stderr" || status=$?
  (( status == 2 )) && [[ ! -s $scratch/stdout ]] || fail "invalid or non-terminal invocation is rejected: $*"
  pass "invalid or non-terminal invocation is rejected: $*"
}
for argument in --invalid 0 11 --interactive; do
  assert_rejected "$argument"
done
assert_rejected --full extra

doctrine --web
assert_equal "$(cat "$DOCTRINE_BROWSER_LOG")" "https://omarchy.org/doctrine/" "--web uses the default browser launcher"
action read >/dev/null
assert_equal "$(cat "$OMARCHY_DOCTRINE_STATE/mode")" "read" "focused reading enters reading mode"
assert_equal "$(action down)" "preview-down" "focused reading switches arrows to scrolling"
action full 03 >/dev/null
assert_contains "$(action back 11)" "pos(3)" "leaving the full doctrine restores the previous principle"
assert_equal "$(action previous 01)" "pos(10)" "previous wraps to the last principle"
assert_equal "$(action next 10)" "pos(1)" "next wraps to the first principle"
FZF_CLICK_HEADER_WORD=Website action header 10 >/dev/null
assert_equal "$(tail -n 1 "$DOCTRINE_BROWSER_LOG")" "https://omarchy.org/doctrine/#youre-somebody-now" "clicking Website opens the selected section"
FZF_CLICK_FOOTER_LINE=1 action footer 11 >/dev/null
assert_equal "$(tail -n 1 "$DOCTRINE_BROWSER_LOG")" "https://omarchy.org/doctrine/" "clicking the footer in the full view opens the whole doctrine"
FZF_CLICK_HEADER_WORD=Full action header 03 >/dev/null
assert_equal "$(cat "$OMARCHY_DOCTRINE_STATE/mode")" "read" "the Full header control enters reading mode"
FZF_CLICK_HEADER_WORD=Index action header 11 >/dev/null
assert_equal "$(cat "$OMARCHY_DOCTRINE_STATE/mode")" "index" "the Index header control returns to navigation"

for width in 30 48 80 120; do
  preview=$(FZF_PREVIEW_COLUMNS="$width" bash "$ROOT/default/omarchy/doctrine-reader.sh" preview 03)
  [[ $preview == *"Have some fun"* && $preview == *"#have-some-fun"* ]] || fail "the preview renders at $width columns"
  pass "the preview renders at $width columns"
done

# A separate PTY test drives real fzf input, resizing, and terminal cleanup.
python3 "$SHELL_TEST_DIR/doctrine-terminal-test.py"
