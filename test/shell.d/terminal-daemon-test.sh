#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin" "$TMPDIR/home"
SYSTEMCTL_LOG="$TMPDIR/systemctl-log"
NOTIFY_LOG="$TMPDIR/notify-log"

cat >"$TMPDIR/bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
SH

cat >"$TMPDIR/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFY_LOG"
SH

chmod +x "$TMPDIR/bin/systemctl" "$TMPDIR/bin/omarchy-notification-send"

apps="$TMPDIR/home/.local/share/applications"
flags="$TMPDIR/home/.local/state/omarchy/toggles"
unit_dir="$TMPDIR/home/.config/systemd/user"

run_toggle() {
  PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  HOME="$TMPDIR/home" \
  XDG_DATA_HOME="$TMPDIR/home/.local/share" \
  XDG_CONFIG_HOME="$TMPDIR/home/.config" \
  OMARCHY_PATH="$ROOT" \
  SYSTEMCTL_LOG="$SYSTEMCTL_LOG" \
  NOTIFY_LOG="$NOTIFY_LOG" \
    "$ROOT/bin/$1" "${@:2}"
}

check() {
  local terminal=$1 desktop=$2 on=$3 off=$4
  : >"$SYSTEMCTL_LOG"
  run_toggle "omarchy-toggle-$terminal-daemon" on
  grep -qx "$on" "$apps/$desktop" || fail "$terminal on sets $on"
  grep -Fqx -- "--user enable --now omarchy-$terminal-server.service" "$SYSTEMCTL_LOG" ||
    fail "$terminal on starts the server"
  grep -Fqx -- "-g  ${terminal^} single-instance mode enabled" "$NOTIFY_LOG" ||
    fail "$terminal notification names the terminal" "$(cat "$NOTIFY_LOG")"
  [[ -L $unit_dir/omarchy-$terminal-server.service ]] || fail "$terminal unit is linked"
  [[ -f $flags/terminal-daemon-$terminal ]] || fail "$terminal flag is set"

  : >"$SYSTEMCTL_LOG"
  run_toggle "omarchy-toggle-$terminal-daemon" off
  grep -qx "$off" "$apps/$desktop" || fail "$terminal off restores $off"
  grep -Fqx -- "--user disable --now omarchy-$terminal-server.service" "$SYSTEMCTL_LOG" ||
    fail "$terminal off stops the server"
  grep -Fqx -- "-g  ${terminal^} single-instance mode disabled" "$NOTIFY_LOG" ||
    fail "$terminal off notification names the terminal"
  [[ ! -f $flags/terminal-daemon-$terminal ]] || fail "$terminal flag is cleared"
  pass "$terminal single-instance toggles"
}

check foot foot.desktop 'Exec=footclient' 'Exec=foot'

if [[ -f /usr/share/applications/kitty.desktop ]]; then
  check kitty kitty.desktop 'Exec=kitty --single-instance' 'Exec=kitty'
else
  skip "kitty single-instance toggles"
fi

check alacritty Alacritty.desktop 'Exec=alacritty msg create-window' 'Exec=alacritty'

if grep -E 'omarchy-(foot|kitty|alacritty)-server\.service' "$ROOT/install/user/first-run/enable-user-units.sh"; then
  fail "terminal servers are started for every new login"
fi
pass "terminal servers stay off until the toggle"
