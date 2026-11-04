#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home" XDG_CONFIG_HOME="$test_tmp/config" OMARCHY_PATH="$ROOT"
export OMARCHY_TESSDATA="$test_tmp/tessdata"
mkdir -p "$test_tmp/bin" "$OMARCHY_TESSDATA" "$HOME"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

cat >"$test_tmp/bin/gum" <<'SH'
#!/bin/bash
printf '%s\n' "$GUM_CHOICE"
SH
chmod +x "$test_tmp/bin/gum"

[[ $(omarchy-capture-ocr-languages) == "eng" ]] || fail "capture text defaults to English"
pass "capture text defaults to English"

omarchy-capture-ocr-languages eng+chi_sim >/dev/null
[[ $(omarchy-capture-ocr-languages) == "eng+chi_sim" ]] || fail "a saved language list is what capture text will use"
pass "a saved language list is what capture text will use"

if omarchy-capture-ocr-languages 'eng;rm' >/dev/null 2>&1; then
  fail "a language list cannot carry a shell command"
fi
[[ $(omarchy-capture-ocr-languages) == "eng+chi_sim" ]] || fail "a rejected language list leaves the saved one in place"
pass "a language list cannot carry a shell command"

printf 'not langs\n' >"$XDG_CONFIG_HOME/omarchy/ocr-languages"
[[ $(omarchy-capture-ocr-languages) == "eng" ]] || fail "a broken language file falls back to English"
pass "a broken language file falls back to English"

for name in eng swe osd; do
  printf 'x\n' >"$OMARCHY_TESSDATA/$name.traineddata"
done
GUM_CHOICE=$'swe\neng' omarchy-capture-ocr-languages choose >/dev/null
[[ $(omarchy-capture-ocr-languages) == "swe+eng" ]] || fail "the picker saves the languages it was given and skips osd"
pass "the picker saves the languages it was given and skips osd"
