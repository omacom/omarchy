#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

SYNC_TEST=$(mktemp -d)
trap 'rm -rf "$SYNC_TEST"' EXIT
export SYNC_TEST

local_home="$SYNC_TEST/home"
stub_bin="$SYNC_TEST/bin"
remote_bin="$SYNC_TEST/remote-bin"
mkdir -p "$local_home/.local/state/omarchy/current" "$stub_bin" "$remote_bin" "$SYNC_TEST/run"

# herdr lists one unreachable machine first, this machine, and a disabled one.
cat >"$stub_bin/herdr" <<'EOF'
#!/bin/bash
printf '%s\t%s\t%s\t%s\t%s\n' \
  1 down down default enabled \
  2 alpha alpha default enabled \
  3 beta beta default enabled \
  4 gamma gamma default enabled \
  5 local-box local-box default enabled \
  6 retired retired default disabled
EOF

cat >"$stub_bin/hostname" <<'EOF'
#!/bin/bash
echo local-box
EOF

# ssh runs the script it receives against a fake home for that machine, as the remote would.
cat >"$stub_bin/ssh" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" >>"$SYNC_TEST/ssh-options"
while [[ $1 == "-o" ]]; do
  shift 2
done
target=$1
echo "$target" >>"$SYNC_TEST/ssh-calls"
remote="$SYNC_TEST/remotes/$target"
if [[ ! -d $remote ]]; then
  echo "ssh: connect to host $target port 22: Connection refused" >&2
  exit 255
fi
HOME="$remote" PATH="$SYNC_TEST/remote-bin:/usr/bin:/bin" bash -s
EOF

cat >"$remote_bin/omarchy" <<'EOF'
#!/bin/bash
echo "$* from=$OMARCHY_THEME_SYNC_FROM session=$WAYLAND_DISPLAY" >>"$HOME/set.log"
EOF

cat >"$remote_bin/hyprctl" <<'EOF'
#!/bin/bash
echo '[{"instance":"old","time":1,"wl_socket":"wayland-0"},{"instance":"live","time":2,"wl_socket":"wayland-1"}]'
EOF

chmod +x "$stub_bin"/* "$remote_bin"/*

reset_remotes() {
  rm -rf "$SYNC_TEST/remotes" "$SYNC_TEST/ssh-calls" "$SYNC_TEST/ssh-options"
  local machine
  for machine in alpha beta gamma local-box; do
    mkdir -p "$SYNC_TEST/remotes/$machine/.local/state/omarchy/current"
    echo "tokyo-night" >"$SYNC_TEST/remotes/$machine/.local/state/omarchy/current/theme.name"
    mkdir -p "$SYNC_TEST/remotes/$machine/.local/state/omarchy/toggles"
    touch "$SYNC_TEST/remotes/$machine/.local/state/omarchy/toggles/herdr-theme-sync"
  done
}

local_toggle="$local_home/.local/state/omarchy/toggles/herdr-theme-sync"

set_local_theme() {
  echo "$1" >"$local_home/.local/state/omarchy/current/theme.name"
}

run_sync() {
  HOME="$local_home" XDG_RUNTIME_DIR="$SYNC_TEST/run" PATH="$stub_bin:$ROOT/bin:$PATH" omarchy-theme-set-herdr-machines "$@"
}

set_log() {
  cat "$SYNC_TEST/remotes/$1/set.log" 2>/dev/null || true
}

# Sync is off until it is turned on.
reset_remotes
set_local_theme lumon
run_sync >/dev/null
[[ ! -e $SYNC_TEST/ssh-calls ]] || fail "theme sync is off by default"
pass "theme sync is off by default"
mkdir -p "${local_toggle%/*}"
touch "$local_toggle"

# Syncs every enabled machine except this one, skipping machines already on the theme.
reset_remotes
set_local_theme lumon
echo "lumon" >"$SYNC_TEST/remotes/beta/.local/state/omarchy/current/theme.name"
echo "lumon" >"$SYNC_TEST/remotes/local-box/.local/state/omarchy/current/theme.name"
output=$(run_sync)
[[ $(set_log alpha) == "theme set lumon from=local-box session=wayland-1" ]] || fail "sets the theme inside the newest Hyprland session"
pass "sets the theme inside the newest Hyprland session"
[[ -z $(set_log beta) && $output == *"beta: already on lumon"* ]] || fail "skips a machine already on the theme"
pass "skips a machine already on the theme"
! grep -qx retired "$SYNC_TEST/ssh-calls" || fail "skips disabled machines"
pass "skips disabled machines"
[[ -z $(set_log local-box) && $output == *"local-box: already on lumon"* ]] || fail "leaves this machine alone when it is listed"
pass "leaves this machine alone when it is listed"
[[ $output == *"down: ssh: connect to host down"* ]] || fail "logs an unreachable machine"
pass "logs an unreachable machine"

# Keep reusable connections in a directory only this user can access.
grep -qx 'ControlMaster=auto' "$SYNC_TEST/ssh-options" || fail "reuses authenticated SSH connections"
grep -qx 'ControlPersist=600' "$SYNC_TEST/ssh-options" || fail "keeps connections for ten idle minutes"
grep -qxF "ControlPath=$SYNC_TEST/run/omarchy-theme-sync/%C" "$SYNC_TEST/ssh-options" || fail "keeps separate control sockets for each SSH destination"
[[ $(stat -c %a "$SYNC_TEST/run/omarchy-theme-sync") == "700" ]] || fail "control socket directory is private"
pass "reuses SSH connections for ten idle minutes in a private runtime directory"

# Connects one machine at a time.
[[ $(paste -sd ' ' "$SYNC_TEST/ssh-calls") == "down alpha beta gamma local-box" ]] || fail "connects to machines one at a time in order"
pass "connects to machines one at a time in order"

# A machine with the toggle off refuses themes from other machines.
reset_remotes
rm "$SYNC_TEST/remotes/gamma/.local/state/omarchy/toggles/herdr-theme-sync"
output=$(run_sync)
[[ -z $(set_log gamma) && $output == *"gamma: theme sync is off"* ]] || fail "a remote with theme sync off keeps its theme"
pass "a remote with theme sync off keeps its theme"

# A machine with the toggle off sends nothing.
reset_remotes
rm "$local_toggle"
run_sync >/dev/null
[[ ! -e $SYNC_TEST/ssh-calls ]] || fail "theme sync off stops sending"
pass "theme sync off stops sending"
touch "$local_toggle"

# Turning sync off also stops a run that is still waiting for an earlier one to finish.
reset_remotes
exec 8>"$SYNC_TEST/run/omarchy-theme-set-herdr-machines.lock"
flock 8
run_sync >/dev/null &
queued=$!
sleep 0.5
rm "$local_toggle"
flock -u 8
wait $queued
[[ ! -e $SYNC_TEST/ssh-calls ]] || fail "turning sync off stops a queued run"
pass "turning sync off stops a queued run"
touch "$local_toggle"

# A theme that arrived from another machine is never sent on.
reset_remotes
OMARCHY_THEME_SYNC_FROM=elsewhere run_sync >/dev/null
[[ ! -e $SYNC_TEST/ssh-calls ]] || fail "a mirrored theme change is not mirrored again"
pass "a mirrored theme change is not mirrored again"

# The theme name reaches the remote as data, never as shell code.
reset_remotes
set_local_theme 'demo$(touch "$HOME/injected")'
run_sync >/dev/null
[[ ! -e $SYNC_TEST/remotes/alpha/injected ]] || fail "a theme name cannot run commands on the remote"
[[ $(set_log alpha) == 'theme set demo$(touch "$HOME/injected") from=local-box session=wayland-1' ]] || fail "a theme name reaches the remote verbatim"
pass "a theme name reaches the remote verbatim without running commands"

# The menu shows Herdr Theme Sync whenever herdr has an enabled machine, with sync on or off,
# so the toggle is there to turn it on.
rm "$local_toggle"
run_sync --available || fail "an enabled herdr machine makes theme sync available"
pass "an enabled herdr machine makes theme sync available while it is off"
printf '#!/bin/bash\nprintf "1\\tretired\\tretired\\tdefault\\tdisabled\\n"\n' >"$stub_bin/herdr"
! run_sync --available || fail "only disabled herdr machines make theme sync unavailable"
pass "only disabled herdr machines make theme sync unavailable"
