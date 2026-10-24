#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

launch_or_focus="$ROOT/bin/omarchy-launch-or-focus"

grep -F 'launch_command_is_safe "$LAUNCH_COMMAND"' "$launch_or_focus" >/dev/null ||
  fail "the launch path validates the launch command before parsing"
grep -E '^eval[[:space:]]' "$launch_or_focus" >/dev/null &&
  fail "the launch path does not eval the launch command directly"
pass "the launch path guards the launch command parse"

sandbox_dir=$(mktemp -d)
trap 'rm -rf "$sandbox_dir"' EXIT

mkdir -p "$sandbox_dir/bin"
printf '#!/bin/bash\nif [[ $1 == clients ]]; then echo [] ; fi\n' >"$sandbox_dir/bin/hyprctl"
printf '#!/bin/bash\nprintf '"'"'[%%s] '"'"' "$@"\necho\n' >"$sandbox_dir/bin/setsid"
chmod +x "$sandbox_dir/bin/hyprctl" "$sandbox_dir/bin/setsid"

launch_args_of() {
  PATH="$sandbox_dir/bin:$PATH" "$launch_or_focus" pattern "$@"
}

assertEqual() {
  local actual="$1"
  local expected="$2"
  local description="$3"

  actual=${actual% }
  if [[ $actual == "$expected" ]]; then
    pass "$description"
  else
    fail "$description" "expected: $expected
actual:   $actual"
  fi
}

assert_args() {
  local launch_command="$1"
  local expected="$2"

  local actual
  actual=$(launch_args_of "$launch_command")
  assertEqual "$actual" "$expected" "launch command splits as expected: $launch_command"
}

assert_refused() {
  local launch_command="$1"

  if launch_args_of "$launch_command" >/dev/null 2>&1; then
    fail "the launch path refuses to launch: $launch_command"
  fi
  pass "the launch path refuses to launch: $launch_command"
}

assert_args "uwsm-app -- foot" "[uwsm-app] [--] [foot]"
assert_args "omarchy-launch-tui zsh -c 'fastfetch; read -k 1'" "[omarchy-launch-tui] [zsh] [-c] [fastfetch; read -k 1]"
assert_args "uwsm-app -- 'my app'" "[uwsm-app] [--] [my app]"
assert_args "uwsm-app -- 'it'\\''s'" "[uwsm-app] [--] [it's]"
assert_args 'nautilus "$HOME/Documents"' "[nautilus] [$HOME/Documents]"
assert_args "foo ~/Documents" "[foo] [$HOME/Documents]"
assert_args '"a\"b"' '[a"b]'
assert_args "printf '%s' '\$(date)'" "[printf] [%s] [\$(date)]"
assert_args "omarchy-launch-webapp 'https://example.com/#section'" "[omarchy-launch-webapp] [https://example.com/#section]"
assert_args "foo#bar" "[foo#bar]"
assert_args 'nautilus /tmp/My\ #Folder' "[nautilus] [/tmp/My #Folder]"
assert_args $'foo\\\n#bar' "[foo#bar]"

assert_refused "foot; touch $sandbox_dir/pwned"
assert_refused "foot && touch $sandbox_dir/pwned"
assert_refused 'foot $(touch /tmp/pwned)'
assert_refused 'foot `touch /tmp/pwned`'
assert_refused 'foot | tee /tmp/pwned'
assert_refused '${HOME}'
assert_refused "cmd valid-arg 'unterminated"
assert_refused "printf '\\'; touch /tmp/pwned # "
assert_refused $'printf # \'\nprintf INJECTED # \''
assert_refused $'foo \\\n# \'\nprintf INJECTED # \''

[[ ! -e $sandbox_dir/pwned ]] || fail "a refused launch command never runs"
pass "refused launch commands execute nothing"
