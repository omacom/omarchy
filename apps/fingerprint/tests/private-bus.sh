#!/bin/bash
set -eu
here=$(cd "$(dirname "$0")" && pwd)
sandbox=$(mktemp -d)
export DBUS_SYSTEM_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS
export HOME="$sandbox" XDG_DATA_HOME="$sandbox/data" XDG_CONFIG_HOME="$sandbox/config" XDG_STATE_HOME="$sandbox/state"
export OMARCHY_PATH=$(cd "$here/../../.." && pwd)
export QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=none QT_QUICK_BACKEND=software
mkdir "$sandbox/bin" "$sandbox/pam"
echo disabled >"$sandbox/sudo-state"
cat >"$sandbox/bin/omarchy-shell" <<'SH'
#!/bin/bash
echo '{"fingerprintPreferenceSupported":true}'
SH
cat >"$sandbox/bin/sudo-status" <<'SH'
#!/bin/bash
cat "$HOME/sudo-state"
SH
cat >"$sandbox/bin/elevate" <<'SH'
#!/bin/bash
[[ $2 == enable || $2 == disable ]] || exit 2
[[ ! -f $HOME/decline ]] || exit 126
echo "$2"d >"$HOME/sudo-state"
SH
chmod +x "$sandbox/bin/"*
export PATH="$sandbox/bin:$PATH"
/usr/bin/python3 "$here/service.py" "$sandbox/ready" &
peer=$!
trap 'kill "$peer" 2>/dev/null || true; wait "$peer" 2>/dev/null || true; rm -rf -- "$sandbox"' EXIT
for ((i = 0; i < 100; ++i)); do
  [[ -f $sandbox/ready ]] && break
  kill -0 "$peer"
  sleep .05
done
[[ -f $sandbox/ready ]]
"$@"
