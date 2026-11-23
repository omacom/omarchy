#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command xdg-terminal-exec
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
systemctl_log="$test_tmp/systemctl.log"
host_path=$PATH
mkdir -p "$mock_bin" "$test_home/.config"

cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_SYSTEMCTL_LOG"
[[ $2 == is-active ]] && exit "${OMARCHY_TEST_SOCKET_ACTIVE:-1}"
exit 0
SH

chmod +x "$mock_bin"/*

export HOME="$test_home"
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_SYSTEMCTL_LOG="$systemctl_log"
export PATH="$mock_bin:$ROOT/bin:$host_path"

data_home="$test_tmp/xdg-data"
config_home="$test_tmp/xdg-config"
mkdir -p "$data_home/applications" "$config_home"
cp "$ROOT/applications/footclient.desktop" "$data_home/applications/"
printf '%s\n' "footclient.desktop" >"$config_home/xdg-terminals.list"
cmd=$(
  PATH="$ROOT/bin:$host_path" \
    XDG_DATA_HOME="$data_home" \
    XDG_CONFIG_HOME="$config_home" \
    XDG_DATA_DIRS=/usr/share \
    xdg-terminal-exec --print-cmd --app-id=org.omarchy.btop --title=btop -e btop
)
[[ $cmd == *"--app-id=org.omarchy.btop"* ]] || fail "Omarchy footclient desktop passes --app-id" "$cmd"
[[ $cmd == *"omarchy-launch-foot"* ]] || fail "resolved command is the Foot wrapper" "$cmd"
pass "xdg-terminal-exec keeps org.omarchy app-ids through footclient"

wrapper_bin="$test_tmp/wrapper-bin"
mkdir -p "$wrapper_bin"
cat >"$wrapper_bin/footclient" <<'SH'
#!/bin/bash
printf 'footclient:%s\n' "$*"
SH
cat >"$wrapper_bin/foot" <<'SH'
#!/bin/bash
printf 'foot:%s\n' "$*"
SH
chmod +x "$wrapper_bin/footclient" "$wrapper_bin/foot"

: >"$systemctl_log"
got=$(
  PATH="$wrapper_bin:$mock_bin:$ROOT/bin:$host_path" \
    HOME="$test_tmp/bare-home" \
    XDG_RUNTIME_DIR="$test_tmp/empty-runtime" \
    WAYLAND_DISPLAY=wayland-test \
    omarchy-launch-foot --app-id=org.omarchy.btop -e btop
)
[[ $got == "foot:--app-id=org.omarchy.btop -e btop" ]] ||
  fail "wrapper falls back to standalone foot without a server socket" "$got"
grep -Fxq -- '--user start foot-server.socket' "$systemctl_log" ||
  fail "wrapper tries to start the server socket for this session" "$(cat "$systemctl_log")"
pass "wrapper falls back to standalone foot when the server socket cannot start"

: >"$systemctl_log"
got=$(
  PATH="$wrapper_bin:$mock_bin:$ROOT/bin:$host_path" \
    HOME="$test_tmp/bare-home" \
    XDG_RUNTIME_DIR="$test_tmp/empty-runtime" \
    WAYLAND_DISPLAY=wayland-test \
    OMARCHY_TEST_SOCKET_ACTIVE=0 \
    omarchy-launch-foot --app-id=org.omarchy.btop -e btop
)
# Each window gets a fresh tag, set on the window and in its shell's environment.
tags=$(grep -oE 'omarchy-foot-[0-9a-f-]{36}' <<<"$got" | sort -u)
(( $(wc -l <<<"$tags") == 1 )) && [[ -n $tags ]] || fail "wrapper tags the window and its shell with one tag" "$got"
got=${got//$tags/TAG}
[[ $got == "footclient:--toplevel-tag=TAG --override=environment.OMARCHY_FOOT_WINDOW=TAG --app-id=org.omarchy.btop -e btop" ]] ||
  fail "wrapper uses footclient when the systemd socket is listening" "$got"
! grep -Fq 'start' "$systemctl_log" || fail "wrapper does not restart a listening socket" "$(cat "$systemctl_log")"
pass "wrapper uses footclient when the systemd socket is listening"

theme_home="$test_tmp/theme-home"
mkdir -p "$theme_home/.config/foot" "$theme_home/.local/state/omarchy/current/theme"
printf '%s\n' "font=TestFont:size=12" >"$theme_home/.config/foot/foot.ini"
printf '%s\n' "[colors-dark]" "background=000000" >"$theme_home/.local/state/omarchy/current/theme/foot.ini"
got=$(
  PATH="$wrapper_bin:$mock_bin:$ROOT/bin:$host_path" \
    HOME="$theme_home" \
    WAYLAND_DISPLAY=wayland-test \
    OMARCHY_TEST_SOCKET_ACTIVE=0 \
    omarchy-launch-foot --app-id=org.omarchy.btop -e btop
)
got=$(sed -E 's/omarchy-foot-[0-9a-f-]{36}/TAG/g' <<<"$got")
[[ $got == "footclient:--override=include=$theme_home/.local/state/omarchy/current/theme/foot.ini --override=font=TestFont:size=12 --toplevel-tag=TAG --override=environment.OMARCHY_FOOT_WINDOW=TAG --app-id=org.omarchy.btop -e btop" ]] ||
  fail "wrapper re-applies the live theme include and font" "$got"
pass "wrapper re-applies the live theme include and font"
