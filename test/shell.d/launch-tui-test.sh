#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A window opened by an agent's command doesn't inherit the agent's colorless,
# pagerless environment, and one opened by the user keeps what they set.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# The terminal launcher stands in for the rest of the launch chain and records
# the environment and arguments omarchy-launch-tui hands off.
mkdir -p "$test_tmp/bin" "$test_tmp/omarchy/bin"
cat >"$test_tmp/omarchy/bin/omarchy-launch-terminal" <<STUB
#!/bin/bash
printf 'NO_COLOR=%s PAGER=%s GIT_PAGER=%s args=%s\\n' "\${NO_COLOR-unset}" "\${PAGER-unset}" "\${GIT_PAGER-unset}" "\$*" >"$test_tmp/window"
STUB
chmod +x "$test_tmp/omarchy/bin/omarchy-launch-terminal"

launch() {
  rm -f "$test_tmp/window"
  env -u NO_COLOR -u PAGER -u GIT_PAGER "$@" \
    OMARCHY_PATH="$test_tmp/omarchy" \
    bash "$ROOT/bin/omarchy-launch-tui" --app-id=org.omarchy.test btop --utf-force
  cat "$test_tmp/window"
}

[[ $(launch NO_COLOR=1 PAGER=cat GIT_PAGER=cat) == "NO_COLOR=unset PAGER=unset GIT_PAGER=unset args=--dir=$PWD --app-id=org.omarchy.test -e btop --utf-force" ]] ||
  fail "a window opened from an agent's command gets its colors and pager back" "$(cat "$test_tmp/window")"
pass "a window opened from an agent's command gets its colors and pager back"

[[ $(launch NO_COLOR=1 PAGER=less) == "NO_COLOR=1 PAGER=less GIT_PAGER=unset args="* ]] ||
  fail "NO_COLOR the user set for themselves stays" "$(cat "$test_tmp/window")"
[[ $(launch PAGER=cat GIT_PAGER=delta) == "NO_COLOR=unset PAGER=cat GIT_PAGER=delta args="* ]] ||
  fail "a pager the user chose stays" "$(cat "$test_tmp/window")"
[[ $(launch) == "NO_COLOR=unset PAGER=unset GIT_PAGER=unset args="* ]] ||
  fail "a plain launch is unchanged" "$(cat "$test_tmp/window")"
pass "what the user set for themselves stays as it is"

# launch-or-focus and its TUI/webapp wrappers must pass arguments without eval
# splitting or shell-executing metacharacters such as & and $(...).
cat >"$test_tmp/bin/hyprctl" <<'STUB'
#!/bin/bash
printf '[]\n'
STUB
cat >"$test_tmp/bin/omarchy-launch-webapp" <<STUB
#!/bin/bash
printf '%s\0' "\$@" >"$test_tmp/webapp-argv"
STUB
cat >"$test_tmp/bin/omarchy-launch-tui" <<STUB
#!/bin/bash
printf '%s\0' "\$@" >"$test_tmp/tui-argv"
STUB
chmod +x "$test_tmp/bin/hyprctl" "$test_tmp/bin/omarchy-launch-webapp" "$test_tmp/bin/omarchy-launch-tui"

marker="$test_tmp/injected"
PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-launch-or-focus-webapp" Calendar "https://example.com/?a=1&b=\$(touch '$marker')"
[[ ! -e $marker ]] || fail "launch-or-focus-webapp does not execute shell metacharacters in URLs"
mapfile -d '' -t webapp_args <"$test_tmp/webapp-argv"
[[ ${#webapp_args[@]} == 1 && ${webapp_args[0]} == "https://example.com/?a=1&b=\$(touch '$marker')" ]] ||
  fail "launch-or-focus-webapp preserves URLs with & and \$()" "${webapp_args[*]}"
pass "launch-or-focus-webapp preserves URL metacharacters without eval"

PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-launch-or-focus-tui" nvim "my file; touch $marker"
[[ ! -e $marker ]] || fail "launch-or-focus-tui does not execute shell metacharacters in arguments"
mapfile -d '' -t tui_args <"$test_tmp/tui-argv"
[[ ${#tui_args[@]} == 2 && ${tui_args[0]} == "nvim" && ${tui_args[1]} == "my file; touch $marker" ]] ||
  fail "launch-or-focus-tui preserves spaces and metacharacters" "${tui_args[*]}"

# Legacy single-string command invocations (such as the menu extension example)
# still work via the legacy eval path while multi-arg calls bypass eval.
PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-launch-or-focus-tui" "zsh -c 'fastfetch; read -k 1'"
mapfile -d '' -t tui_args <"$test_tmp/tui-argv"
[[ ${#tui_args[@]} == 3 && ${tui_args[0]} == "zsh" && ${tui_args[1]} == "-c" && ${tui_args[2]} == "fastfetch; read -k 1" ]] ||
  fail "launch-or-focus-tui preserves legacy single-string commands" "${tui_args[*]}"
pass "launch-or-focus-tui preserves multi-arg spaces without eval and keeps legacy single-string commands"

cat >"$test_tmp/bin/uwsm-app" <<STUB
#!/bin/bash
printf '%s\0' "\$@" >"$test_tmp/uwsm-argv"
STUB
chmod +x "$test_tmp/bin/uwsm-app"

PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-launch-or-focus" "app;touch $marker"
[[ ! -e $marker ]] || fail "single-arg launch-or-focus does not eval the window pattern"
mapfile -d '' -t uwsm_args <"$test_tmp/uwsm-argv"
[[ ${#uwsm_args[@]} == 2 && ${uwsm_args[0]} == "--" && ${uwsm_args[1]} == "app;touch $marker" ]] ||
  fail "single-arg launch-or-focus passes the pattern as one argument" "${uwsm_args[*]}"
pass "single-arg launch-or-focus avoids eval"
