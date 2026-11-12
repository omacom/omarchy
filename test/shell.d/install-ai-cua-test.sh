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
# the first record are what pacman installs. Field names follow the locale, and
# an exported COLUMNS wraps the field, as pacman does even when its output is captured.
cat >"$tmp_dir/bin/pacman" <<'SCRIPT'
#!/bin/bash
case "$1 $2" in
  "-Q hyprland") echo "hyprland $TEST_HYPRLAND" ;;
  "-Si cua-hyprland-plugin")
    [[ -n ${TEST_PLUGIN_PIN-} ]] || exit 1
    if [[ ${LC_ALL-} == C ]]; then depends="Depends On      "; else depends="Hängt ab von    "; fi
    if [[ -n ${COLUMNS-} ]]; then wrap=$'\n                  '; else wrap="  "; fi
    printf 'Repository      : omarchy\nName            : cua-hyprland-plugin\nDescription     : Cua plugin for hyprland=%s\nProvides        : cua-hyprland=%s\n%s: %s  hyprlang=0.6.8-5\n\n' "$TEST_HYPRLAND" "$TEST_HYPRLAND" "$depends" "${TEST_DEPENDS_BEFORE_PIN:+$TEST_DEPENDS_BEFORE_PIN$wrap}$TEST_PLUGIN_PIN"
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

# Everything that could take the driver's Wayland switch for the running session, logged by receiver.
export TEST_ENV_LOG="$tmp_dir/env-log"
for stub in systemctl dbus-update-activation-environment hyprctl; do
  cat >"$tmp_dir/bin/$stub" <<SCRIPT
#!/bin/bash
printf '$stub:%s\n' "\$*" >>"\$TEST_ENV_LOG"
SCRIPT
done
chmod +x "$tmp_dir/bin"/*

export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"
export COLUMNS=80

install_cua() {
  : >"$TEST_LOG"
  : >"$TEST_ENV_LOG"
  OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-install-ai-cua" </dev/null 2>&1
}

# The pin is found wherever it sits among the dependencies: first, as the package lists it, or after others.
for before in "" aquamarine=0.16.0-1; do
  output=$(TEST_HYPRLAND=0.57.2-2 TEST_PLUGIN_PIN=hyprland=0.57.2-2 TEST_DEPENDS_BEFORE_PIN=$before install_cua)
  [[ $(cat "$TEST_LOG") == $'add:cua-driver-bin\nadd:cua-hyprland-plugin' ]] ||
    fail "Cua install adds the plugin built for the installed Hyprland (after '$before')" "$(cat "$TEST_LOG")"
  pass "Cua install adds the plugin built for the installed Hyprland (after '$before')"
done

# The switch goes to Hyprland, whose environment a terminal opened from a
# keybinding inherits, and nowhere that outlives the session: a variable set in
# systemd's user manager survives the logout, and the driver's removal, whenever the manager does.
[[ $(cat "$TEST_ENV_LOG") == 'hyprctl:eval hl.env("CUA_DRIVER_RS_ENABLE_WAYLAND", "1")' ]] ||
  fail "Cua install sets the driver's Wayland switch in the running Hyprland and nowhere else" "$(cat "$TEST_ENV_LOG")"
pass "Cua install sets the driver's Wayland switch in the running Hyprland and nowhere else"

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
