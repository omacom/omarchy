#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1791787312.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

config="$test_dir/.config/hyprland-preview-share-picker/config.yaml"
mkdir -p "${config%/*}"

run_migration() {
  HOME="$test_dir" bash -euo pipefail "$migration" >/dev/null
}

grep -qxF "  command: slurp -f '%o@%X,%Y,%W,%H'" "$ROOT/config/hyprland-preview-share-picker/config.yaml" ||
  fail "the shipped region command asks slurp for output-relative coordinates"
pass "the shipped region command asks slurp for output-relative coordinates"

sed "s/'%o@%X,%Y,%W,%H'/'%o@%x,%y,%w,%h'/" "$ROOT/config/hyprland-preview-share-picker/config.yaml" >"$test_dir/old.yaml"
cp "$test_dir/old.yaml" "$config"
run_migration
cmp -s "$config" "$ROOT/config/hyprland-preview-share-picker/config.yaml" ||
  fail "the old shipped config becomes the new one" "$(diff "$test_dir/old.yaml" "$config")"
run_migration
cmp -s "$config" "$ROOT/config/hyprland-preview-share-picker/config.yaml" || fail "a second run changes nothing"
pass "the old shipped region command becomes output-relative, once"

# A region command of the user's own is kept.
sed "s/^  command: .*/  command: grim-region --pick/" "$test_dir/old.yaml" >"$config"
cp "$config" "$test_dir/custom.yaml"
run_migration
cmp -s "$config" "$test_dir/custom.yaml" || fail "a region command of the user's own is kept"
pass "a region command of the user's own is kept"

# A config a dotfile manager links in is left for it to manage.
mkdir -p "$test_dir/dotfiles"
cp "$test_dir/old.yaml" "$test_dir/dotfiles/config.yaml"
rm "$config"
ln -s "$test_dir/dotfiles/config.yaml" "$config"
run_migration
[[ -L $config ]] && cmp -s "$test_dir/dotfiles/config.yaml" "$test_dir/old.yaml" ||
  fail "a linked share picker config is left linked and unchanged"
pass "a linked share picker config is left alone"

# So is one inside a linked config directory.
rm "$config"
rmdir "${config%/*}"
mkdir -p "$test_dir/dotfiles/picker"
cp "$test_dir/old.yaml" "$test_dir/dotfiles/picker/config.yaml"
ln -s "$test_dir/dotfiles/picker" "${config%/*}"
run_migration
cmp -s "$test_dir/dotfiles/picker/config.yaml" "$test_dir/old.yaml" ||
  fail "a share picker config in a linked directory is left unchanged"
pass "a share picker config in a linked directory is left alone"

# No config is created where there was none.
rm -rf "$test_dir/.config"
run_migration
[[ ! -e $config ]] || fail "no share picker config is created"
pass "a missing config is left missing"
