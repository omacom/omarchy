#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

log="$test_tmp/hyprctl.log"
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$HYPRCTL_LOG"
echo ok
exit "${HYPRCTL_EXIT:-0}"
SH
chmod +x "$test_tmp/bin/hyprctl"

reload() {
  : >"$log"
  env PATH="$test_tmp/bin:$PATH" HYPRCTL_LOG="$log" "$@" "$ROOT/bin/omarchy-restart-hyprctl"
}

reload env HYPRLAND_INSTANCE_SIGNATURE=abc_1_1
[[ $(<"$log") == "reload" ]] || fail "reloads the session's own instance" "$(<"$log")"
pass "reloads the session's own instance"

# The background switch reads this command's stdout as its lock handshake.
[[ -z $(reload env HYPRLAND_INSTANCE_SIGNATURE=abc_1_1 2>/dev/null) ]] || fail "keeps hyprctl's answer off stdout"
pass "keeps hyprctl's answer off stdout"

reload env -u HYPRLAND_INSTANCE_SIGNATURE
[[ $(<"$log") == "--instance 0 reload" ]] || fail "reaches Hyprland outside the session" "$(<"$log")"
pass "reaches the running Hyprland outside the session"

# Migrations save config from outside the session, sometimes with no Hyprland running.
reload env -u HYPRLAND_INSTANCE_SIGNATURE HYPRCTL_EXIT=1 || fail "no running Hyprland does not fail the caller"
pass "no running Hyprland does not fail the caller"

# A Lua syntax error in a personal override is reported on stderr while still reloading.
broken_home="$test_tmp/broken-home"
mkdir -p "$broken_home/.config/hypr"
printf 'this is not lua {{{\n' >"$broken_home/.config/hypr/bindings.lua"
err_log="$test_tmp/reload.err"
reload env HOME="$broken_home" HYPRLAND_INSTANCE_SIGNATURE=abc_1_1 2>"$err_log"
grep -Fq 'bindings.lua' "$err_log" || fail "reports syntax errors in user overrides on stderr" "$(<"$err_log")"
[[ $(<"$log") == "reload" ]] || fail "still reloads Hyprland after reporting a broken override" "$(<"$log")"
pass "reports Lua syntax errors in user overrides and still reloads"
