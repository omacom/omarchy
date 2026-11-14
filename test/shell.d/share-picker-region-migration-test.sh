#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1787582797.sh"
shipped="$ROOT/config/hyprland-preview-share-picker/config.yaml"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

config="$test_dir/.config/hyprland-preview-share-picker/config.yaml"
mkdir -p "${config%/*}"

run_migration() {
  HOME="$test_dir" bash -euo pipefail "$migration" >/dev/null
}

grep -qxF "  command: slurp -f '%o@%X,%Y,%W,%H'" "$shipped" ||
  fail "the shipped region command asks slurp for output-relative coordinates"
pass "the shipped region command asks slurp for output-relative coordinates"

sed "s/'%o@%X,%Y,%W,%H'/'%o@%x,%y,%w,%h'/" "$shipped" >"$test_dir/old.yaml"
cp "$test_dir/old.yaml" "$config"
run_migration
cmp -s "$config" "$shipped" || fail "the old shipped config becomes the new one" "$(diff "$test_dir/old.yaml" "$config")"
run_migration
cmp -s "$config" "$shipped" || fail "a second run changes nothing"
pass "the old shipped region command becomes output-relative, once"

# Only the region command changes; the user's other settings survive.
sed "s/^hide_token_restore: true$/hide_token_restore: false/" "$test_dir/old.yaml" >"$config"
sed "s/^hide_token_restore: true$/hide_token_restore: false/" "$shipped" >"$test_dir/expected.yaml"
cmp -s "$config" "$test_dir/old.yaml" && fail "the fixture changes an unrelated setting"
run_migration
cmp -s "$config" "$test_dir/expected.yaml" || fail "other settings survive the rewrite" "$(diff "$test_dir/expected.yaml" "$config")"
pass "other settings survive the rewrite"

# A region command of the user's own is kept.
sed "s/^  command: slurp .*/  command: grim-region --pick/" "$test_dir/old.yaml" >"$config"
cp "$config" "$test_dir/custom.yaml"
run_migration
cmp -s "$config" "$test_dir/custom.yaml" || fail "a region command of the user's own is kept"
pass "a region command of the user's own is kept"

# A config a dotfile manager links in stays linked, and its target is fixed.
mkdir -p "$test_dir/dotfiles"
cp "$test_dir/old.yaml" "$test_dir/dotfiles/config.yaml"
rm "$config"
ln -s "$test_dir/dotfiles/config.yaml" "$config"
run_migration
[[ $(readlink "$config") == "$test_dir/dotfiles/config.yaml" ]] || fail "a linked share picker config is left a link to its target"
cmp -s "$test_dir/dotfiles/config.yaml" "$shipped" || fail "a linked share picker config has its target fixed"
pass "a linked share picker config stays linked and its target is fixed"

# So does one inside a linked config directory.
rm "$config"
rmdir "${config%/*}"
mkdir -p "$test_dir/dotfiles/picker"
cp "$test_dir/old.yaml" "$test_dir/dotfiles/picker/config.yaml"
ln -s "$test_dir/dotfiles/picker" "${config%/*}"
run_migration
[[ $(readlink "${config%/*}") == "$test_dir/dotfiles/picker" ]] || fail "a linked share picker config directory is left a link to its target"
cmp -s "$test_dir/dotfiles/picker/config.yaml" "$shipped" || fail "a share picker config in a linked directory is fixed"
pass "a share picker config in a linked directory is fixed"

# No config is created where there was none.
rm -rf "$test_dir/.config"
run_migration
[[ ! -e $config ]] || fail "no share picker config is created"
pass "a missing config is left missing"
