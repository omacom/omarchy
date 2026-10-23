#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

test_home="$test_dir/home"
stub_bin="$test_dir/bin"
factor_file="$test_dir/factor"
font_name_file="$test_dir/font-name"
mkdir -p "$test_home/.config/alacritty" "$stub_bin"

printf 'size = 9\n' >"$test_home/.config/alacritty/alacritty.toml"
printf "'Adwaita Sans 11'\n" >"$font_name_file"
printf '1.0\n' >"$factor_file"

for cmd in pkill omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$cmd"
done
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/pgrep"
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/omarchy-cmd-present"

cat >"$stub_bin/gsettings" <<'SH'
#!/bin/bash
case "$1" in
  get)
    if [[ $3 == "font-name" ]]; then
      cat "$OMARCHY_TEST_FONT_NAME_FILE"
    elif [[ $3 == "text-scaling-factor" ]]; then
      cat "$OMARCHY_TEST_FACTOR_FILE"
    fi
    ;;
  set)
    if [[ $3 == "text-scaling-factor" ]]; then
      printf '%s\n' "$4" >"$OMARCHY_TEST_FACTOR_FILE"
    fi
    ;;
  reset)
    if [[ $3 == "text-scaling-factor" ]]; then
      printf '1.0\n' >"$OMARCHY_TEST_FACTOR_FILE"
    fi
    ;;
esac
SH
chmod +x "$stub_bin/"*

run_text_size() {
  env HOME="$test_home" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_FACTOR_FILE="$factor_file" \
    OMARCHY_TEST_FONT_NAME_FILE="$font_name_file" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-display-text-size" "$@"
}

# At 16px, terminal is 12pt and Chromium/Electron body text at factor 1.0 is
# already ~12pt, so text-scaling-factor must land at 1.0000 rather than 1.3636.
run_text_size 16
[[ $(<"$factor_file") == "1.0000" ]] || fail "16px sets text-scaling-factor to 1.0000" "got: $(<"$factor_file")"
grep -qx 'size = 12' "$test_home/.config/alacritty/alacritty.toml" || fail "16px sets terminal font to 12pt"
grep -qx 'base-size = 16' "$test_home/.config/omarchy/shell.toml" || fail "16px sets shell base-size to 16"
pass "16px aligns GTK/Chromium text-scaling-factor (1.0000) with 12pt terminal"

# Quantization against an 11pt GTK font keeps GTK4 interface font on whole points.
run_text_size 14
[[ $(<"$factor_file") == "0.9091" ]] || fail "14px quantizes 11pt/12 against 11pt GTK font" "got: $(<"$factor_file")"
run_text_size 20
[[ $(<"$factor_file") == "1.2727" ]] || fail "20px quantizes 15pt/12 against 11pt GTK font" "got: $(<"$factor_file")"
pass "GTK text-scaling-factor stays quantized to whole GTK font points"

# With a 12pt GTK interface font, factor equals terminal_pt / 12 at every stop.
printf "'Adwaita Sans 12'\n" >"$font_name_file"
run_text_size 12
[[ $(<"$factor_file") == "0.7500" ]] || fail "12px sets factor 9/12 with 12pt GTK font" "got: $(<"$factor_file")"
run_text_size 16
[[ $(<"$factor_file") == "1.0000" ]] || fail "16px sets factor 12/12 with 12pt GTK font" "got: $(<"$factor_file")"
run_text_size 20
[[ $(<"$factor_file") == "1.2500" ]] || fail "20px sets factor 15/12 with 12pt GTK font" "got: $(<"$factor_file")"
pass "12pt GTK font yields exact terminal_pt / 12 scaling factors"

run_text_size reset
[[ $(<"$factor_file") == "1.0" ]] || fail "reset restores default text-scaling-factor"
grep -qx 'size = 9' "$test_home/.config/alacritty/alacritty.toml" || fail "reset restores 9pt terminal font"
! grep -q 'base-size' "$test_home/.config/omarchy/shell.toml" || fail "reset removes shell base-size override"
pass "reset restores shell, GTK, and terminal defaults"
