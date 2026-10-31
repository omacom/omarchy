#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-menu-select" <<'SH'
#!/bin/bash

cat
SH
chmod +x "$stub_bin/omarchy-menu-select"

export PATH="$stub_bin:$ROOT/bin:$PATH"

mkdir -p "$tmp_dir/storage/Videos/trip" "$tmp_dir/home" "$tmp_dir/elsewhere"
touch "$tmp_dir/storage/Videos/trip/clip.webm" "$tmp_dir/elsewhere/linked.webm"
ln -s "$tmp_dir/storage/Videos" "$tmp_dir/home/Videos"
ln -s "$tmp_dir/elsewhere" "$tmp_dir/storage/Videos/elsewhere"

files=$(omarchy-menu-file "Select video" "$tmp_dir/home/Videos" "webm")

[[ $files == "$tmp_dir/home/Videos/trip/clip.webm" ]] ||
  fail "menu file descends into a search path that is a symlink" "$files"
pass "menu file descends into a search path that is a symlink"
