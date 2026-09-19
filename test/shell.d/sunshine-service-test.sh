#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stubs="$tmp_dir/bin"
test_home="$tmp_dir/home"
calls="$tmp_dir/calls.log"
mkdir -p "$stubs" "$test_home"

write_stub() {
  local name="$1"
  local body="$2"

  printf '#!/bin/bash\n%s\n' "$body" >"$stubs/$name"
  chmod +x "$stubs/$name"
}

# Record external calls without changing packages, services, or firewall rules.
for command in omarchy-pkg-add omarchy-pkg-drop systemctl sudo omarchy-webapp-install omarchy-webapp-remove; do
  write_stub "$command" 'printf "%s %s\n" "${0##*/}" "$*" >>"$OMARCHY_TEST_CALLS"'
done

write_stub omarchy-cmd-missing 'exit 1' # UFW is available.
write_stub ip 'exit 1'                  # Tailscale is absent.
write_stub omarchy-launch-webapp 'exit 0'
write_stub sed 'exit 0'                # Avoid platform-specific sed -i behavior.

OMARCHY_PATH="$ROOT" OMARCHY_TEST_CALLS="$calls" HOME="$test_home" PATH="$stubs:$PATH" "$ROOT/bin/omarchy-install-service-sunshine" >/dev/null

grep -Fxq "omarchy-pkg-add sunshine" "$calls" ||
  fail "Sunshine installer installs the package"
grep -Fxq "systemctl --user enable --now app-dev.lizardbyte.app.Sunshine.service" "$calls" ||
  fail "Sunshine installer enables the canonical user service"
grep -Fq "omarchy-webapp-install Sunshine Admin https://localhost:47990" "$calls" ||
  fail "Sunshine installer continues to install the admin web app"
grep -Fq "sudo ufw allow in proto tcp from 10.0.0.0/8 to any port 47984 comment omarchy-sunshine" "$calls" ||
  fail "Sunshine installer continues to open firewall ports"
grep -Fxq 'o.launch_on_start("sunshine")' "$test_home/.config/hypr/autostart.lua" ||
  fail "Sunshine installer writes Hyprland autostart"
pass "Sunshine installer uses the canonical user service and completes setup"

: >"$calls"
OMARCHY_PATH="$ROOT" OMARCHY_TEST_CALLS="$calls" HOME="$test_home" PATH="$stubs:$PATH" "$ROOT/bin/omarchy-remove-service-sunshine" >/dev/null

grep -Fxq "systemctl --user disable --now app-dev.lizardbyte.app.Sunshine.service" "$calls" ||
  fail "Sunshine remover disables the canonical user service"
grep -Fxq "omarchy-pkg-drop sunshine" "$calls" ||
  fail "Sunshine remover removes the package"
grep -Fxq "omarchy-webapp-remove Sunshine Admin" "$calls" ||
  fail "Sunshine remover removes the admin web app"
pass "Sunshine remover uses the canonical user service"
