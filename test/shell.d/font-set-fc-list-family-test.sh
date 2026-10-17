#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home/.config/foot"
printf 'font=Old Font:size=9\n' >"$test_tmp/home/.config/foot/foot.ini"

# Decode the actual query with fontconfig itself and print it as fc-list does,
# escaped unless a format is asked for. Only an exact installed family is
# returned, so a full dump, an unescaped pattern or escaped output cannot pass.
cat >"$test_tmp/bin/fc-list" <<'MOCK'
#!/bin/bash
format='%{=fclist}\n'
[[ ${1-} == -f ]] && format=$2 && shift 2
[[ $# == 1 && $1 == :family=* ]] || exit 1
[[ $(fc-pattern -f '%{family}' "$1") == "$TEST_FONT_FAMILY" ]] || exit 1
fc-pattern -f "$format" "$1"
MOCK
for stub in omarchy-restart-shell omarchy-hook; do
  printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/$stub"
done
for stub in pgrep omarchy-cmd-present; do
  printf '#!/bin/bash\nexit 1\n' >"$test_tmp/bin/$stub"
done
chmod +x "$test_tmp/bin"/*

for family in "Test Mono" "Test-Mono" "Test, Mono" "Test: Mono" "Test, Mono: Style"; do
  HOME="$test_tmp/home" PATH="$test_tmp/bin:$PATH" OMARCHY_PATH="$ROOT" \
    TEST_FONT_FAMILY="$family" "$ROOT/bin/omarchy-font-set" "$family"
  grep -Fq "<string>$family</string>" "$test_tmp/home/.config/fontconfig/fonts.conf" ||
    fail "font-set writes the literal family after its filtered lookup" "$family"
  foot_font=$(sed -n 's/^font=//p' "$test_tmp/home/.config/foot/foot.ini")
  [[ $(fc-pattern -f '%{family}' "$foot_font") == "$family" ]] ||
    fail "font-set writes a foot pattern that names the family" "$foot_font"
  pass "font-set looks up the exact family: $family"
done

if HOME="$test_tmp/home" PATH="$test_tmp/bin:$PATH" OMARCHY_PATH="$ROOT" \
  TEST_FONT_FAMILY="Test Mono" "$ROOT/bin/omarchy-font-set" "Missing Mono"; then
  fail "font-set rejects a family not returned by its filtered lookup"
fi
pass "font-set rejects an uninstalled family"
