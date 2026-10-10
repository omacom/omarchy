#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/bin"

cat >"$tmpdir/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_DIR/calls"
case "$*" in
  'monitors -j')
    printf '[{"name":"DP-1","specialWorkspace":{"name":""}}]\n'
    ;;
  'clients -j')
    printf '[]\n'
    ;;
esac
SH
# The screensaver window opens as soon as the launcher starts listening, so it never waits out its deadline.
printf '#!/bin/bash\nprintf "openwindow>>1,1,org.omarchy.screensaver,wezterm\\n"\n' >"$tmpdir/bin/socat"
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/pgrep"
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/omarchy-toggle-enabled"
printf '#!/bin/bash\necho DP-1\n' >"$tmpdir/bin/omarchy-hyprland-monitor-focused"
printf '#!/bin/bash\necho org.wezfurlong.wezterm.desktop\n' >"$tmpdir/bin/xdg-terminal-exec"
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"$TEST_DIR/notifications"\n' >"$tmpdir/bin/omarchy-notification-send"
chmod +x "$tmpdir/bin/"*

: >"$tmpdir/calls"
: >"$tmpdir/notifications"

PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test OMARCHY_PATH="$ROOT" \
  timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force || true

[[ -s $tmpdir/notifications ]] && fail "the screensaver runs when WezTerm is the default terminal" "$(<"$tmpdir/notifications")"
spawn=$(grep exec_cmd "$tmpdir/calls") || fail "the screensaver runs when WezTerm is the default terminal" "$(<"$tmpdir/calls")"
pass "the screensaver runs when WezTerm is the default terminal"

# A WezTerm that is already running would otherwise take the request and open the window under its own class.
[[ $spawn == *"wezterm "*" start --always-new-process "* ]] ||
  fail "WezTerm opens the screensaver in a process of its own" "$spawn"
pass "WezTerm opens the screensaver in a process of its own"

[[ $spawn == *"--class=org.omarchy.screensaver "* ]] ||
  fail "the WezTerm screensaver carries the class its window rules match" "$spawn"
pass "the WezTerm screensaver carries the class its window rules match"

[[ $spawn == *"--config-file $ROOT/default/wezterm/screensaver.lua "* ]] ||
  fail "the WezTerm screensaver loads its own config instead of the user's" "$spawn"
pass "the WezTerm screensaver loads its own config instead of the user's"

# The config is a plain table, so it loads without WezTerm; a syntax error would leave WezTerm on its defaults.
config=$(CONFIG="$ROOT/default/wezterm/screensaver.lua" \
  lua -e 'local c = dofile(os.getenv("CONFIG")); print(c.enable_tab_bar, c.window_padding.left, c.colors.background)') ||
  fail "the WezTerm screensaver config loads" "$config"
[[ $config == $'false\t0\t#000000' ]] ||
  fail "the WezTerm screensaver draws on a bare black canvas" "$config"
pass "the WezTerm screensaver draws on a bare black canvas"
