#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
PYTHONDONTWRITEBYTECODE=1 python3 "$ROOT/test/shell.d/fixtures/session/test_session.py"
pass 'session save, restore, desktop identities and shutdown snapshot behavior'

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin" "$fixture/home" "$fixture/data/applications" "$fixture/runtime"
cat > "$fixture/bin/systemctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >> "$SESSION_TEST_LOG"
exit 0
STUB
cat > "$fixture/bin/hyprctl" <<'STUB'
#!/bin/bash
printf 'snapshot\n' >> "$SESSION_TEST_LOG"
echo '[]'
STUB
chmod +x "$fixture/bin"/*
export SESSION_TEST_LOG="$fixture/calls"
export HOME="$fixture/home" XDG_STATE_HOME="$fixture/home/.local/state" XDG_CONFIG_HOME="$fixture/home/.config"
export XDG_DATA_HOME="$fixture/data" XDG_DATA_DIRS="$fixture/data" XDG_RUNTIME_DIR="$fixture/runtime"
export OMARCHY_PATH="$ROOT" PATH="$fixture/bin:$ROOT/bin:$PATH"
omarchy-setup-session --enable >/dev/null
[[ -L $XDG_CONFIG_HOME/systemd/user/omarchy-session.service ]] || fail 'opt-in setup links the shipped unit'
[[ $(readlink "$XDG_CONFIG_HOME/systemd/user/omarchy-session.service") == "$ROOT/default/session/omarchy-session.service" ]] || fail 'unit follows the package-owned default'
[[ $(sed -n '2p' "$fixture/calls") == snapshot ]] || fail 'setup snapshots before enabling restoration'
omarchy-setup-session --disable >/dev/null
grep -qxF -- '--user disable --now omarchy-session.service' "$fixture/calls" || fail 'disable stops future restores'
[[ -f $XDG_STATE_HOME/omarchy/session/last.json ]] || fail 'disable preserves the saved session'
pass 'session setup is opt-in, seeds before activation, and preserves state on disable'
