#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch/home" OMARCHY_PATH="$ROOT"
export PATH="$scratch/bin:$ROOT/bin:$PATH"
export FACTOR_FILE="$scratch/factor"
mkdir -p "$scratch/bin" "$HOME/.config/"{ghostty,foot,kitty,alacritty,omarchy}
cat >"$scratch/bin/gsettings" <<'STUB'
#!/bin/bash
case "$1:$3" in
  get:font-name) echo "'Sans ${GTK_FONT_PT:-11}'" ;;
  get:text-scaling-factor)
    [[ ${FAIL_READ:-0} == "1" ]] && exit 1
    cat "$FACTOR_FILE"
    ;;
  set:text-scaling-factor)
    [[ ${FAIL_WRITE:-0} == "1" ]] && exit 1
    printf '%s\n' "$4" >"$FACTOR_FILE"
    ;;
  reset:text-scaling-factor)
    [[ ${FAIL_WRITE:-0} == "1" ]] && exit 1
    echo 1.0 >"$FACTOR_FILE"
    ;;
esac
STUB
for command in pkill omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$scratch/bin/$command"
done
for command in pgrep omarchy-cmd-present; do
  printf '#!/bin/bash\nexit 1\n' >"$scratch/bin/$command"
done
chmod +x "$scratch/bin/"*
printf 'font-family = My Font\nfont-size = 9\nbackground = #123456\n' >"$HOME/.config/ghostty/config"
printf '[main]\nfont=My Font:size=9:weight=bold\n' >"$HOME/.config/foot/foot.ini"
printf 'font_size 9.0\n' >"$HOME/.config/kitty/kitty.conf"
printf '[font]\nsize = 9\n' >"$HOME/.config/alacritty/alacritty.toml"
printf '[font]\nfamily = "My Font"\n[bar]\nheight = 24\n' >"$HOME/.config/omarchy/shell.toml"
echo 1.0 >"$FACTOR_FILE"

run_size() {
  "$ROOT/bin/omarchy-display-text-size" "$@"
}

ghostty_size() {
  sed -n 's/^font-size = //p' "$HOME/.config/ghostty/config"
}

assert_apparent_size() {
  local expected=$1 actual factor
  actual=$(ghostty_size)
  factor=$(cat "$FACTOR_FILE")
  awk -v actual="$actual" -v factor="$factor" -v expected="$expected" \
    'BEGIN { error = actual * factor - expected; exit !(error > -0.001 && error < 0.001) }' ||
    fail "Ghostty renders the requested $expected pt" "configured=$actual GTK=$factor"
  local output
  output=$(run_size)
  [[ $output == *"terminal font: $expected pt"* ]] || fail "report shows Ghostty apparent size" "$output"
}

run_size 16
assert_apparent_size 12
grep -qx 'font=My Font:size=12:weight=bold' "$HOME/.config/foot/foot.ini" || fail "Foot retains its scaled size and font options"
grep -qx 'font_size 12.0' "$HOME/.config/kitty/kitty.conf" || fail "Kitty retains its scaled size"
grep -qx 'size = 12' "$HOME/.config/alacritty/alacritty.toml" || fail "Alacritty retains its scaled size"
grep -qx 'font-family = My Font' "$HOME/.config/ghostty/config" || fail "Ghostty family is preserved"
grep -qx 'background = #123456' "$HOME/.config/ghostty/config" || fail "Ghostty unrelated config is preserved"
grep -qx 'height = 24' "$HOME/.config/omarchy/shell.toml" || fail "shell unrelated config is preserved"
pass "16px scales Ghostty once and preserves other terminal behavior and customization"

for font in 9 11 12 10.5; do
  export GTK_FONT_PT="$font"
  for size in {9..20}; do
    run_size "$size"
    expected=$(awk -v s="$size" 'BEGIN { printf "%d", int(s * 9 / 12 + 0.5) }')
    assert_apparent_size "$expected"
    before=$(ghostty_size)
    run_size "$size"
    [[ $(ghostty_size) == "$before" ]] || fail "repeated size changes are idempotent"
  done
done
pass "all accepted sizes compensate for quantized GTK factors and are idempotent"

run_size reset
assert_apparent_size 9
[[ $(ghostty_size) == "9" ]] || fail "reset restores Ghostty's default config value"
! grep -q '^base-size' "$HOME/.config/omarchy/shell.toml" || fail "reset removes shell override"
pass "reset restores defaults"

echo 1.5 >"$FACTOR_FILE"
export FAIL_WRITE=1
run_size 16
assert_apparent_size 12
run_size reset
assert_apparent_size 9
unset FAIL_WRITE
pass "failed GTK set and reset compensate for the factor actually in use"

for factor in 0 invalid; do
  echo "$factor" >"$FACTOR_FILE"
  FAIL_WRITE=1 run_size 16
  [[ $(ghostty_size) == "12" ]] || fail "invalid GTK factor safely falls back to 1"
done
FAIL_READ=1 run_size 16
[[ $(ghostty_size) == "12" ]] || fail "unavailable GTK factor safely falls back to 1"
pass "invalid or unavailable GTK factors cannot produce invalid font sizes"

sed -i '/^font-size = /d' "$HOME/.config/ghostty/config"
output=$(run_size)
[[ $output == *"terminal font: n/a pt"* ]] || fail "missing Ghostty size does not become zero"
rm "$HOME/.config/ghostty/config"
run_size 16
[[ ! -e $HOME/.config/ghostty/config ]] || fail "absent Ghostty config remains absent"
output=$(run_size)
[[ $output == *"terminal font: 12 pt"* ]] || fail "other terminal reporting remains unchanged"
pass "missing Ghostty config and size retain existing behavior"
