#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

# omarchy-shell-config reads the shipped defaults from OMARCHY_PATH.
export OMARCHY_PATH="$ROOT"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home/.config/omarchy" "$tmp/dotfiles"

# Every commit refreshes the running shell; stand in for it.
printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/omarchy-shell"
chmod +x "$tmp/bin/omarchy-shell"

config="$tmp/home/.config/omarchy/shell.json"
tracked="$tmp/dotfiles/shell.json"

bar() {
  HOME="$tmp/home" PATH="$tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-bar" "$@"
}

install -m 644 "$ROOT/config/omarchy/shell.json" "$config"
bar position bottom >/dev/null
jq -e '.bar.position == "bottom"' "$config" >/dev/null || fail "position updates a plain config"
[[ $(stat -c %a "$config") == 644 ]] || fail "position keeps a plain config's mode" "$(stat -c %a "$config")"
pass "position keeps a plain config's mode"

rm -f "$config"
install -m 644 "$ROOT/config/omarchy/shell.json" "$tracked"
ln -s "$tracked" "$config"
bar position left >/dev/null
[[ -L $config ]] || fail "position keeps a symlinked config a symlink"
jq -e '.bar.position == "left"' "$tracked" >/dev/null || fail "position writes through to the tracked file"
[[ $(stat -c %a "$tracked") == 644 ]] || fail "position keeps the tracked file's mode" "$(stat -c %a "$tracked")"
pass "position writes through a dotfiles symlink"

[[ -z $(find "$tmp/dotfiles" -name '.shell.json.*') ]] || fail "no staging file is left beside the tracked file"
pass "no staging file is left beside the tracked file"

printf 'not json\n' >"$tracked"
! bar position top >/dev/null 2>&1 || fail "a broken config fails the update"
[[ $(cat "$tracked") == "not json" && -L $config ]] || fail "a failed update leaves the config alone"
[[ -z $(find "$tmp/dotfiles" -name '.shell.json.*') ]] || fail "a failed update removes its staging file"
pass "a failed update leaves the config alone"

rm -f "$config" "$tracked"
ln -s "$tracked" "$config"
bar position top >/dev/null
[[ -L $config && -f $tracked ]] || fail "position fills in a dangling symlink's target"
jq -e '.bar.position == "top"' "$tracked" >/dev/null || fail "position seeds a dangling target from the defaults"
pass "position fills in a dangling symlink's target"
