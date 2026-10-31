#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
foot_config="$test_home/.config/foot/foot.ini"
mkdir -p "$(dirname "$foot_config")" "$test_dir/bin"

# Exercise the real font commands without changing the running desktop.
for command in pkill omarchy-restart-shell omarchy-hook omarchy-notification-send gsettings; do
  printf '#!/bin/bash\nexit 0\n' >"$test_dir/bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$test_dir/bin/pgrep"
printf '#!/bin/bash\nprintf "Test Font\\n"\n' >"$test_dir/bin/fc-list"
chmod +x "$test_dir/bin/"*

run_command() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" "$ROOT/bin/$@"
}

cp "$ROOT/config/foot/foot.ini" "$foot_config"
run_command omarchy-display-text-size 16
grep -qx 'font=JetBrainsMono Nerd Font:size=12' "$foot_config" || fail "size command scales Foot"
run_command omarchy-font-set 'Test Font'
grep -qx 'font=Test Font:size=12' "$foot_config" || fail "font command keeps Foot's size" "$(grep '^font=' "$foot_config")"
pass "changing the font family keeps the size set by the text size command"

sed -i 's/^font=.*/font=Old Font:size=11:weight=medium/' "$foot_config"
run_command omarchy-font-set 'Test Font'
grep -qx 'font=Test Font:size=11:weight=medium' "$foot_config" || fail "font command keeps Foot's font options" "$(grep '^font=' "$foot_config")"
pass "changing the font family keeps Foot's other font options"
