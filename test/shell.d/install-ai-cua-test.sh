#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/home"

export TEST_LOG="$tmp_dir/log"
export HOME="$tmp_dir/home"

# The channel's answer for the plugin comes from TEST_PLUGIN_PIN: empty means
# the channel does not carry it. The machine's own Hyprland is TEST_HYPRLAND.
# Every answer names the installed build where it is not a dependency, and a
# later repository carries a plugin that does pin it: only the dependencies of
# the first record are what pacman installs. Field names follow the locale.
cat >"$tmp_dir/bin/pacman" <<'SCRIPT'
#!/bin/bash
case "$1 $2" in
  "-Q hyprland") echo "hyprland $TEST_HYPRLAND" ;;
  "-Si cua-hyprland-plugin")
    [[ -n ${TEST_PLUGIN_PIN-} ]] || exit 1
    if [[ ${LC_ALL-} == C ]]; then depends="Depends On      "; else depends="Hängt ab von    "; fi
    printf 'Repository      : omarchy\nName            : cua-hyprland-plugin\nDescription     : Cua plugin for hyprland=%s\nProvides        : cua-hyprland=%s\n%s: %s  aquamarine=0.16.0-1  hyprlang=0.6.8-5\n\n' "$TEST_HYPRLAND" "$TEST_HYPRLAND" "$depends" "$TEST_PLUGIN_PIN"
    printf 'Repository      : extra\nName            : cua-hyprland-plugin\n%s: hyprland=%s\n' "$depends" "$TEST_HYPRLAND"
    ;;
  *)
    printf 'pacman:%s\n' "$*" >>"$TEST_LOG"
    exit 1
    ;;
esac
SCRIPT

cat >"$tmp_dir/bin/omarchy-pkg-add" <<'SCRIPT'
#!/bin/bash
printf 'add:%s\n' "$*" >>"$TEST_LOG"
[[ " ${TEST_FAILING_PKGS-} " != *" $1 "* ]]
SCRIPT

for stub in systemctl dbus-update-activation-environment; do
  printf '#!/bin/bash\n' >"$tmp_dir/bin/$stub"
done
chmod +x "$tmp_dir/bin"/*

export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"

install_cua() {
  : >"$TEST_LOG"
  OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-install-ai-cua" </dev/null 2>&1
}

output=$(TEST_HYPRLAND=0.57.2-2 TEST_PLUGIN_PIN=hyprland=0.57.2-2 install_cua)
[[ $(cat "$TEST_LOG") == $'add:cua-driver-bin\nadd:cua-hyprland-plugin' ]] ||
  fail "Cua install adds the plugin built for the installed Hyprland" "$(cat "$TEST_LOG")"
pass "Cua install adds the plugin built for the installed Hyprland"

# pacman would meet either pin by replacing the installed Hyprland with a
# build from another repository, which is never the plugin's call to make.
for pin in hyprland=0.57.2-1 hyprland=0.57.2-3 hyprland=0.57.2-2.1 hyprland=0.57.2-21 hyprland; do
  output=$(TEST_HYPRLAND=0.57.2-2 TEST_PLUGIN_PIN=$pin install_cua) ||
    fail "Cua install skips a plugin built for another Hyprland build ($pin)" "the driver install failed with it"
  [[ $(cat "$TEST_LOG") == "add:cua-driver-bin" ]] ||
    fail "Cua install skips a plugin built for another Hyprland build ($pin)" "$(cat "$TEST_LOG")"
  [[ $output == *"this machine has hyprland=0.57.2-2; skipping it"* ]] ||
    fail "Cua install skips a plugin built for another Hyprland build ($pin)" "$output"
  pass "Cua install skips a plugin built for another Hyprland build ($pin)"
done
[[ $output == *"built for another Hyprland build and"* ]] ||
  fail "Cua install says so when the plugin names no Hyprland build" "$output"
pass "Cua install says so when the plugin names no Hyprland build"

output=$(TEST_HYPRLAND=0.57.2-2 install_cua) ||
  fail "Cua install carries on without a plugin the channel lacks" "the driver install failed with it"
[[ $(cat "$TEST_LOG") == "add:cua-driver-bin" && $output == *"not available in your package channel"* ]] ||
  fail "Cua install carries on without a plugin the channel lacks" "$output"
pass "Cua install carries on without a plugin the channel lacks"

output=$(TEST_HYPRLAND=0.57.2-2 TEST_PLUGIN_PIN=hyprland=0.57.2-2 TEST_FAILING_PKGS=cua-hyprland-plugin install_cua) ||
  fail "Cua install keeps the driver when the plugin does not install" "exited nonzero"
[[ $output == *"Cua Driver has been installed."* && $output != *"Cua Input"* ]] ||
  fail "Cua install keeps the driver when the plugin does not install" "$output"
pass "Cua install keeps the driver when the plugin does not install"

if TEST_HYPRLAND=0.57.2-2 TEST_PLUGIN_PIN=hyprland=0.57.2-2 TEST_FAILING_PKGS=cua-driver-bin install_cua >/dev/null; then
  fail "Cua install stops when the driver does not install"
fi
[[ $(cat "$TEST_LOG") == "add:cua-driver-bin" ]] ||
  fail "Cua install stops when the driver does not install" "$(cat "$TEST_LOG")"
pass "Cua install stops when the driver does not install"
