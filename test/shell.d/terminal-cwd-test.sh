#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
runtime_dir="$test_tmp/runtime"
work_dir="$test_tmp/work"
calls="$test_tmp/calls"
active_window="$test_tmp/active-window.json"
mkdir -p "$mock_bin" "$test_home" "$runtime_dir" "$work_dir"
: >"$calls"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
cat "$OMARCHY_TEST_ACTIVE_WINDOW"
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
printf 'pgrep %s\n' "$*" >>"$OMARCHY_TEST_CALLS"
printf '4242\n'
SH

cat >"$mock_bin/readlink" <<'SH'
#!/bin/bash
case "$*" in
  */cwd) printf '%s\n' "$OMARCHY_TEST_CWD" ;;
  */exe) printf '/bin/bash\n' ;;
  *) exit 1 ;;
esac
SH

cat >"$mock_bin/grep" <<'SH'
#!/bin/bash
if [[ ${!#} == /etc/shells ]]; then
  exit 0
fi
exec /usr/bin/grep "$@"
SH

chmod +x "$mock_bin"/*

run_cwd() {
  HOME="$test_home" \
    XDG_RUNTIME_DIR="$runtime_dir" \
    PATH="$mock_bin:$PATH" \
    OMARCHY_TEST_ACTIVE_WINDOW="$active_window" \
    OMARCHY_TEST_CALLS="$calls" \
    OMARCHY_TEST_CWD="$work_dir" \
    bash "$ROOT/bin/omarchy-cmd-terminal-cwd"
}

# A non-terminal app may own a child shell (for example, a browser download
# helper). That shell must not make SUPER+ENTER inherit its working directory.
printf '%s\n' '{"pid":101,"class":"microsoft-edge","tags":[]}' >"$active_window"
: >"$calls"
result=$(run_cwd)
[[ $result == "$test_home" ]] || fail "terminal cwd falls back to HOME for non-terminal focused windows" "expected: $test_home\nactual:   $result"
[[ ! -s $calls ]] || fail "terminal cwd does not inspect child processes of non-terminal windows" "$(cat "$calls")"
pass "terminal cwd ignores helper shells owned by non-terminal windows"

# Omarchy's terminal tag is the source of truth used by the Hyprland bindings.
# Dynamic tags are reported with a trailing '*', so both forms must work.
printf '%s\n' '{"pid":202,"class":"kitty","tags":["terminal*"]}' >"$active_window"
: >"$calls"
result=$(run_cwd)
[[ $result == "$work_dir" ]] || fail "terminal cwd is inherited from a dynamically tagged terminal" "expected: $work_dir\nactual:   $result"
grep -q '^pgrep -P 202$' "$calls" || fail "terminal cwd inspects the tagged terminal process"
pass "terminal cwd inherits cwd from dynamically tagged terminals"

printf '%s\n' '{"pid":303,"class":"kitty","tags":["terminal"]}' >"$active_window"
: >"$calls"
result=$(run_cwd)
[[ $result == "$work_dir" ]] || fail "terminal cwd is inherited from a tagged terminal" "expected: $work_dir\nactual:   $result"
pass "terminal cwd inherits cwd from tagged terminals"

# Preserve cwd inheritance for WezTerm installations whose canonical Wayland
# app_id has not yet been covered by the terminal tagging rule.
printf '%s\n' '{"pid":404,"class":"org.wezfurlong.wezterm","tags":[]}' >"$active_window"
: >"$calls"
result=$(run_cwd)
[[ $result == "$work_dir" ]] || fail "terminal cwd is inherited from WezTerm's canonical app_id" "expected: $work_dir\nactual:   $result"
grep -q '^pgrep -P 404$' "$calls" || fail "terminal cwd inspects the WezTerm process"
pass "terminal cwd preserves WezTerm cwd inheritance before its terminal tag is present"
