#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
sleep 60 >/dev/null 2>&1 &
window_pid=$!
trap 'kill "$window_pid" 2>/dev/null || true; rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

printf '#!/bin/bash\nexit 1\n' >"$mock_bin/pgrep"
chmod +x "$mock_bin/pgrep"

export HOME="$test_tmp/home"
export PATH="$mock_bin:$PATH"

write_hyprctl() {
  local class=$1
  cat >"$mock_bin/hyprctl" <<SH
#!/bin/bash
case \$1 in
  clients) echo '[{"address":"0x1","class":"$class","title":"App","pid":$window_pid,"workspace":{"name":"2"}}]' ;;
  monitors) echo '[{"name":"DP-1","focused":true,"activeWorkspace":{"name":"2"}}]' ;;
esac
SH
  chmod +x "$mock_bin/hyprctl"
}

saved_command() {
  jq -r --arg class "$1" '.launches[] | select(.class == $class) | .command' "$HOME/.local/state/omarchy/session/windows.json"
}

write_hyprctl "Percent App"
# omarchy-webapp-install writes the URL's % as %% in Exec.
bash "$ROOT/bin/omarchy-webapp-install" 'Percent App' 'https://example.com/a%20b' someicon >/dev/null
bash "$ROOT/bin/omarchy-session-save" --always

command=$(saved_command "Percent App")
eval "argv=($command)"
if [[ ${argv[*]} == "omarchy-launch-webapp https://example.com/a%20b" ]]; then
  pass "a web app reopens at its URL with the desktop entry's %% decoded"
else
  fail "a web app reopens at its URL with the desktop entry's %% decoded" "saved command: $command"
fi

# Two installed apps whose classes collide if StartupWMClass is matched as a regex:
# the '.' in /v1.0 also matches the 'x' in /v1x0. The wrong file sorts first.
mkdir -p "$HOME/.local/share/applications"
cat >"$HOME/.local/share/applications/A Wrong.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Wrong
Exec=omarchy-launch-webapp https://example.com/v1x0
StartupWMClass=chrome-example.com__v1x0-Default
DESKTOP
cat >"$HOME/.local/share/applications/B Right.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Right
Exec=omarchy-launch-webapp https://example.com/v1.0
StartupWMClass=chrome-example.com__v1.0-Default
DESKTOP

write_hyprctl "chrome-example.com__v1.0-Default"
bash "$ROOT/bin/omarchy-session-save" --always

command=$(saved_command "chrome-example.com__v1.0-Default")
eval "argv=($command)"
if [[ ${argv[*]} == "omarchy-launch-webapp https://example.com/v1.0" ]]; then
  pass "a web app launcher is matched by its exact window class, not as a regex"
else
  fail "a web app launcher is matched by its exact window class, not as a regex" "saved command: $command"
fi

# No matching .desktop file: keep the running browser and the profile named in the class.
write_hyprctl "brave-example.com__page-Work"
bash "$ROOT/bin/omarchy-session-save" --always

command=$(saved_command "brave-example.com__page-Work")
exe=$(readlink -f "/proc/$window_pid/exe")
expected="$(printf '%q' "$exe") --profile-directory=Work --app=https://example.com/page"
if [[ $command == "$expected" ]]; then
  pass "a web app without a launcher keeps its browser and profile"
else
  fail "a web app without a launcher keeps its browser and profile" "saved command: $command"
fi
