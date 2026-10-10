#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
mkdir -p "$test_home/.config" "$test_dir/bin"

# Every terminal's stock config is present, as on an ISO install, each with a
# different size so the report shows which one it read.
for terminal in alacritty foot ghostty kitty; do
  cp -r "$ROOT/config/$terminal" "$test_home/.config/"
done
sed -i -E 's/^size = .*/size = 10/' "$test_home/.config/alacritty/alacritty.toml"
sed -i -E 's/(:size=)[0-9.]+/\19.5/' "$test_home/.config/foot/foot.ini"
sed -i -E 's/^font-size = .*/font-size = 11/' "$test_home/.config/ghostty/config"
printf 'font_size 13\n' >>"$test_home/.config/kitty/kitty.conf"

printf '#!/bin/bash\necho 1.0\n' >"$test_dir/bin/gsettings"
cat >"$test_dir/bin/xdg-terminal-exec" <<'SH'
#!/bin/bash
[[ $1 == "--print-id" ]] && echo "$TEST_TERMINAL_ID"
SH
chmod +x "$test_dir/bin/"*

reported_pt() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" TEST_TERMINAL_ID="$1" \
    "$ROOT/bin/omarchy-display-text-size" | sed -n 's/^terminal font: \(.*\) pt$/\1/p'
}

[[ $(reported_pt Alacritty.desktop) == "10" ]] || fail "reports the Alacritty size when Alacritty is the default"
[[ $(reported_pt foot.desktop) == "9.5" ]] || fail "reports the Foot size when Foot is the default"
[[ $(reported_pt com.mitchellh.ghostty.desktop) == "11" ]] || fail "reports the Ghostty size when Ghostty is the default"
[[ $(reported_pt kitty.desktop) == "13" ]] || fail "reports the Kitty size when Kitty is the default"
pass "size report reads the default terminal's config, not the first one found"
