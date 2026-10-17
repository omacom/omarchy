#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791835872.sh"
shipped="$ROOT/config/owe/config.toml"

work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$work/bin"

cat >"$work/bin/owe" <<EOF
#!/bin/bash
printf '%s\n' "\$*" >>"$work/owe.log"
EOF
chmod +x "$work/bin/owe"

# owe's parser: the last battery_mode under [pause] wins, defaulting to play.
battery_mode() {
  awk '
    /^[[:space:]]*\[/ { section = $0; gsub(/[][[:space:]]/, "", section); next }
    section == "pause" && /^[[:space:]]*battery_mode[[:space:]]*=/ {
      sub(/^[^=]*=[[:space:]]*/, ""); sub(/[[:space:]]*(#.*)?$/, ""); gsub(/"/, ""); mode = $0
    }
    END { print mode == "" ? "play" : mode }
  ' "$1"
}

run_migration() {
  env -u XDG_CONFIG_HOME HOME="$1" OMARCHY_PATH="$ROOT" PATH="$work/bin:$PATH" "${@:2}" bash -euo pipefail "$migration" >/dev/null
}

[[ $(battery_mode "$shipped") == "pause" ]] || fail "the shipped owe config pauses video wallpapers on battery"
pass "the shipped owe config pauses video wallpapers on battery"

fresh="$work/fresh"
mkdir -p "$fresh"
run_migration "$fresh"
[[ -f $fresh/.config/owe/config.toml ]] || fail "a user without an owe config gets Omarchy's"
cmp -s "$shipped" "$fresh/.config/owe/config.toml" || fail "the installed owe config is the shipped one"
[[ $(<"$work/owe.log") == "reload-config" ]] || fail "the running owe daemon reloads the new config" "$(<"$work/owe.log")"
pass "a user without an owe config gets one that pauses on battery, and owe reloads it"

: >"$work/owe.log"
custom="$work/custom"
mkdir -p "$custom/.config/owe"
printf '[pause]\nbattery_mode = "play"\noccupied_workspace = true\n' >"$custom/.config/owe/config.toml"
before=$(<"$custom/.config/owe/config.toml")
run_migration "$custom"
[[ $(<"$custom/.config/owe/config.toml") == "$before" ]] || fail "an existing owe config is left alone"
[[ ! -s $work/owe.log ]] || fail "an existing owe config is not reloaded"
pass "an existing owe config is left alone"

printf '#!/bin/bash\nexit 1\n' >"$work/bin/owe"
nodaemon="$work/nodaemon"
mkdir -p "$nodaemon"
run_migration "$nodaemon" || fail "the migration succeeds when owe cannot be reached"
[[ -f $nodaemon/.config/owe/config.toml ]] || fail "the config is installed even when owe cannot be reached"
pass "the migration succeeds when owe cannot be reached"

xdg="$work/xdg"
mkdir -p "$xdg/home"
run_migration "$xdg/home" XDG_CONFIG_HOME="$xdg/config"
cmp -s "$shipped" "$xdg/config/owe/config.toml" || fail "a moved XDG config home gets the config where owe reads it"
[[ ! -e $xdg/home/.config/owe/config.toml ]] || fail "a moved XDG config home gets no stray copy under ~/.config"
pass "a moved XDG config home gets the config where owe reads it"

dangling="$work/dangling"
mkdir -p "$dangling/.config/owe"
ln -s "$work/dotfiles/owe.toml" "$dangling/.config/owe/config.toml"
run_migration "$dangling"
[[ -L $dangling/.config/owe/config.toml && $(readlink "$dangling/.config/owe/config.toml") == "$work/dotfiles/owe.toml" ]] ||
  fail "a symlinked owe config whose target is missing is left alone"
pass "a symlinked owe config whose target is missing is left alone"
