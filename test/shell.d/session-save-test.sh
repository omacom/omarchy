#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
sleep 60 &
window_pid=$!
trap 'kill "$window_pid" 2>/dev/null || true; rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/hyprctl" <<SH
#!/bin/bash
case \$1 in
  clients) echo '[{"address":"0x1","class":"Percent App","title":"Percent","pid":$window_pid,"workspace":{"name":"2"}}]' ;;
  monitors) echo '[{"name":"DP-1","focused":true,"activeWorkspace":{"name":"2"}}]' ;;
esac
SH
printf '#!/bin/bash\nexit 1\n' >"$mock_bin/pgrep"
chmod +x "$mock_bin"/*

export HOME="$test_tmp/home"
export PATH="$mock_bin:$PATH"

# omarchy-webapp-install writes the URL's % as %% in Exec.
bash "$ROOT/bin/omarchy-webapp-install" 'Percent App' 'https://example.com/a%20b' someicon >/dev/null
bash "$ROOT/bin/omarchy-session-save" --always

command=$(jq -r '.launches[] | select(.class == "Percent App") | .command' "$HOME/.local/state/omarchy/session/windows.json")
eval "argv=($command)"
if [[ ${argv[*]} == "omarchy-launch-webapp https://example.com/a%20b" ]]; then
  pass "a web app reopens at its URL with the desktop entry's %% decoded"
else
  fail "a web app reopens at its URL with the desktop entry's %% decoded" "saved command: $command"
fi
