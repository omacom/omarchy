#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

unset FONTCONFIG_FILE FONTCONFIG_PATH

if ! command -v fc-match >/dev/null || [[ $(fc-list : file) != *NotoSansCJK-Regular.ttc* ]]; then
  skip "fontconfig CJK variants need fc-match and noto-fonts-cjk"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

candidate="$ROOT/default/fontconfig/conf.avail/50-omarchy.conf"
{
  echo '<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig>'
  echo "<dir>/usr/share/fonts</dir><cachedir>$test_tmp/cache</cachedir>"
  placed=false
  for conf in /etc/fonts/conf.d/*.conf; do
    name=${conf##*/}
    [[ $name == "50-omarchy.conf" ]] && continue
    if ! $placed && [[ $name > "50-omarchy.conf" ]]; then
      echo "<include>$candidate</include>"
      placed=true
    fi
    echo "<include>$conf</include>"
  done
  $placed || echo "<include>$candidate</include>"
  echo '</fontconfig>'
} >"$test_tmp/fonts.conf"
export FONTCONFIG_FILE="$test_tmp/fonts.conf"
# The user's own conf.d would otherwise join the system rules under test.
export XDG_CONFIG_HOME="$test_tmp/config"
fc-cache >/dev/null

# Pango, Qt and Skia add lang as a string, which fc-match never does.
cat >"$test_tmp/string-lang.py" <<'PY'
import ctypes, sys
fc = ctypes.CDLL("libfontconfig.so.1")
fc.FcPatternCreate.restype = ctypes.c_void_p
fc.FcPatternAddString.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p]
fc.FcConfigSubstitute.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int]
fc.FcDefaultSubstitute.argtypes = [ctypes.c_void_p]
fc.FcPatternFormat.restype = ctypes.c_char_p
fc.FcPatternFormat.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
fc.FcCharSetCreate.restype = ctypes.c_void_p
fc.FcCharSetAddChar.argtypes = [ctypes.c_void_p, ctypes.c_uint32]
fc.FcPatternAddCharSet.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_void_p]
fc.FcFontMatch.restype = ctypes.c_void_p
fc.FcFontMatch.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.POINTER(ctypes.c_int)]
for line in sys.stdin:
  family, lang, char = line.split()
  pattern = fc.FcPatternCreate()
  fc.FcPatternAddString(pattern, b"family", family.encode())
  if lang != "-":
    for tag in lang.split("|"):
      fc.FcPatternAddString(pattern, b"lang", tag.encode())
  if char == "langs":
    fc.FcConfigSubstitute(None, pattern, 0)
    print(fc.FcPatternFormat(pattern, b"%{lang}").decode())
    continue
  if char == "families":
    fc.FcConfigSubstitute(None, pattern, 0)
    print(fc.FcPatternFormat(pattern, b"%{family}").decode())
    continue
  if char != "-":
    charset = fc.FcCharSetCreate()
    fc.FcCharSetAddChar(charset, int(char, 16))
    fc.FcPatternAddCharSet(pattern, b"charset", charset)
  fc.FcConfigSubstitute(None, pattern, 0)
  fc.FcDefaultSubstitute(pattern)
  result = ctypes.c_int()
  print(fc.FcPatternFormat(fc.FcFontMatch(None, pattern, ctypes.byref(result)), b"%{family[0]}").decode())
PY

# resolve <locale> <string|langset> reads "family lang char" lines
resolve() {
  if [[ $2 == "string" ]]; then
    env -u LC_ALL -u LC_CTYPE -u FC_LANG LANG=$1 python3 "$test_tmp/string-lang.py"
  else
    local family lang char query
    while read -r family lang char; do
      query=$family
      [[ $lang == "-" ]] || query+=":lang=$lang"
      if [[ $char == "langs" ]]; then
        env -u LC_ALL -u LC_CTYPE -u FC_LANG LANG=$1 fc-pattern -c -f '%{lang}\n' "$query"
        continue
      fi
      [[ $char == "-" ]] || query+=":charset=$char"
      env -u LC_ALL -u LC_CTYPE -u FC_LANG LANG=$1 fc-match -f '%{family[0]}\n' "$query"
    done
  fi
}

declare -A latin=([sans-serif]="Liberation Sans" [serif]="Liberation Serif" [monospace]="JetBrainsMono Nerd Font")
declare -A cjk=([sans-serif]="Noto Sans CJK" [serif]="Noto Serif CJK" [monospace]="Noto Sans Mono CJK")
declare -A variant=(
  [zh]=SC [zh-cn]=SC [zh-sg]=SC [zh-hans]=SC [zh-hans-cn]=SC [zh-hans-hk]=SC
  [zh-tw]=TC [zh-hant]=TC [zh-hant-tw]=TC
  [zh-hk]=HK [zh-mo]=HK [zh-hant-hk]=HK [zh-hant-mo]=HK
  [yue]=HK [yue-hk]=HK [yue-hant]=HK [yue-hant-hk]=HK [yue-hant-cn]=HK
  [yue-hans]=SC [yue-hans-cn]=SC [yue-hans-hk]=SC [yue-cn]=SC
  [ja]=JP [ja-jp]=JP [ko]=KR [ko-kr]=KR
)

queries=() expected=()
for tag in "${!variant[@]}"; do
  for generic in sans-serif serif monospace; do
    queries+=("$generic $tag -") expected+=("${latin[$generic]}")
    queries+=("$generic $tag 9aa8") expected+=("${cjk[$generic]} ${variant[$tag]}")
  done
done
for generic in sans-serif serif monospace; do
  queries+=("$generic - -") expected+=("${latin[$generic]}")
done

locales=(C.UTF-8)
chinese_locale=false
if locale -a | grep -Eqi '^zh_CN\.(utf-?8)$'; then
  locales+=(zh_CN.UTF-8)
  chinese_locale=true
else
  skip "locale-derived Han fallback needs the zh_CN.UTF-8 locale"
fi

for locale in "${locales[@]}"; do
  for path in string langset; do
    mapfile -t actual < <(printf '%s\n' "${queries[@]}" | resolve "$locale" "$path")
    for i in "${!queries[@]}"; do
      [[ ${actual[i]} == "${expected[i]}" ]] ||
        fail "$locale $path lang: ${queries[i]} resolves to ${expected[i]}" "${actual[i]}"
    done
  done
  pass "$locale: tagged CJK keeps Omarchy's Latin families and sets Han in the tag's variant"
done

if $chinese_locale; then
  for path in string langset; do
    for generic in sans-serif serif monospace; do
      actual=$(echo "$generic - 9aa8" | resolve zh_CN.UTF-8 "$path")
      [[ $actual == "${cjk[$generic]} SC" ]] || fail "zh_CN $path: untagged Han in $generic is SC" "$actual"
    done
  done
  pass "a Chinese locale sets untagged Han in SC"
fi

untouched=$(echo "sans-serif en families" | resolve C.UTF-8 string)
[[ $(echo "sans-serif ja families" | resolve C.UTF-8 string) != "$untouched" ]] ||
  fail "lang=ja changes the family list, so the prefix check below can see a match"
for tag in jam jav kok koi; do
  actual=$(echo "sans-serif $tag families" | resolve C.UTF-8 string)
  [[ $actual == "$untouched" ]] || fail "string lang=$tag is not taken for Japanese or Korean" "$actual"
done
pass "languages that only share a prefix with ja or ko get no CJK variant"

for path in string langset; do
  for tag in zh zh-sg zh-hant-hk yue-hans-cn; do
    langs=$(echo "sans-serif $tag|ur langs" | resolve C.UTF-8 "$path")
    [[ $langs == *ur* ]] || fail "$path: normalizing $tag preserves Urdu in the language request" "$langs"
    actual=$(echo "sans-serif $tag|ur 067e" | resolve C.UTF-8 "$path")
    [[ $actual == "Noto Nastaliq Urdu" ]] || fail "$path: $tag with Urdu keeps its Nastaliq fallback" "$actual"
  done
done
pass "Chinese normalization preserves other requested languages and their fonts"

for path in string langset; do
  for tag in "${!variant[@]}"; do
    actual=$(echo "sans-serif $tag|en 9aa8" | resolve C.UTF-8 "$path")
    [[ $actual == "Noto Sans CJK ${variant[$tag]}" ]] || fail "$path: $tag with English keeps its CJK variant" "$actual"
  done
done
pass "Chinese and CJK tags keep their variant in multi-language requests"

if [[ $(fc-list : file) == *NotoSansTamil* ]]; then
  for path in string langset; do
    for query in "sans-serif ta -" "sans-serif ta 0baa" "sans-serif ta|en 0bb5"; do
      actual=$(echo "$query" | resolve C.UTF-8 "$path")
      [[ $actual == "Noto Sans Tamil" ]] || fail "$path: $query resolves to Noto Sans Tamil" "$actual"
    done
    actual=$(echo "sans-serif - 0baa" | resolve C.UTF-8 "$path")
    [[ $actual == "Noto Sans Tamil" ]] || fail "$path: a bare Tamil codepoint falls back to Noto Sans Tamil, not Grantha" "$actual"
    actual=$(echo "sans-serif - 0627" | resolve C.UTF-8 "$path")
    [[ $actual == "Noto Naskh Arabic" ]] || fail "$path: the Tamil rules leave Arabic codepoints on Naskh" "$actual"
    actual=$(echo "sans-serif en -" | resolve C.UTF-8 "$path")
    [[ $actual == "Liberation Sans" ]] || fail "$path: the Tamil rules leave English on Liberation Sans" "$actual"
  done
  pass "Tamil resolves to Noto Sans Tamil in tagged requests and bare-codepoint fallback, without disturbing Arabic or Latin"
else
  skip "Tamil fallback needs Noto Sans Tamil from noto-fonts"
fi

if $chinese_locale; then
  for path in string langset; do
    for override in LC_ALL=C.UTF-8 LC_CTYPE=C.UTF-8 FC_LANG=ja; do
      actual=$(echo "sans-serif - 9aa8" | (
        export "$override"
        resolve zh_CN.UTF-8 "$path"
      ))
      [[ $actual == "Noto Sans CJK SC" ]] || fail "$path: $override cannot override the test locale" "$actual"
    done
  done
  pass "both font matching paths ignore inherited locale overrides"
fi

# Chromium and Electron resolve a character that the page's fonts lack by
# sorting every font for the content locale and taking the first that has it
# (ui/gfx/font_fallback_linux.cc), with no family on the pattern at all.
cat >"$test_tmp/chromium-fallback.py" <<'PY'
import ctypes, sys
fc = ctypes.CDLL("libfontconfig.so.1")
pointer = ctypes.c_void_p
class FontSet(ctypes.Structure):
  _fields_ = [("nfont", ctypes.c_int), ("sfont", ctypes.c_int), ("fonts", ctypes.POINTER(pointer))]
fc.FcPatternCreate.restype = pointer
fc.FcPatternAddString.argtypes = [pointer, ctypes.c_char_p, ctypes.c_char_p]
fc.FcPatternAddBool.argtypes = [pointer, ctypes.c_char_p, ctypes.c_int]
fc.FcConfigSubstitute.argtypes = [pointer, pointer, ctypes.c_int]
fc.FcDefaultSubstitute.argtypes = [pointer]
fc.FcPatternDel.argtypes = [pointer, ctypes.c_char_p]
fc.FcFontSort.restype = ctypes.POINTER(FontSet)
fc.FcFontSort.argtypes = [pointer, pointer, ctypes.c_int, pointer, ctypes.POINTER(ctypes.c_int)]
fc.FcPatternGetCharSet.argtypes = [pointer, ctypes.c_char_p, ctypes.c_int, ctypes.POINTER(pointer)]
fc.FcCharSetHasChar.argtypes = [pointer, ctypes.c_uint32]
fc.FcPatternFormat.restype = ctypes.c_char_p
fc.FcPatternFormat.argtypes = [pointer, ctypes.c_char_p]
for line in sys.stdin:
  locale, char = line.split()
  pattern = fc.FcPatternCreate()
  if locale != "-":
    fc.FcPatternAddString(pattern, b"lang", locale.encode())
  fc.FcPatternAddBool(pattern, b"scalable", 1)
  fc.FcConfigSubstitute(None, pattern, 0)
  fc.FcDefaultSubstitute(pattern)
  if locale == "-":
    fc.FcPatternDel(pattern, b"lang")
  fonts = fc.FcFontSort(None, pattern, 0, None, ctypes.byref(ctypes.c_int())).contents
  found = "none"
  for index in range(fonts.nfont):
    charset = pointer()
    if fc.FcPatternGetCharSet(fonts.fonts[index], b"charset", 0, ctypes.byref(charset)) == 0 and fc.FcCharSetHasChar(charset, int(char, 16)):
      found = fc.FcPatternFormat(fonts.fonts[index], b"%{family[0]}").decode()
      break
  print(found)
PY

# chromium_fallback <query...> fills actual with one font per query, or fails.
chromium_fallback() {
  local output
  output=$(printf '%s\n' "$@" | env -u LC_ALL -u LC_CTYPE -u FC_LANG LANG=C.UTF-8 python3 "$test_tmp/chromium-fallback.py") || fail "the Chromium fallback replica runs"
  mapfile -t actual <<<"$output"
  (( ${#actual[@]} == $# )) || fail "the Chromium fallback replica answers every query" "${actual[*]}"
}

# Han, then the ideographic comma and corner bracket, which Noto Sans
# Mongolian also carries and wins for an English page without a preference.
for variant in jp kr sc tc hk; do
  OMARCHY_PATH=$ROOT python3 "$ROOT/default/input-methods/configure.py" font "$variant"
  chromium_fallback "en 9aa8" "en 3001" "en 300c" "- 9aa8" "- 3001"
  for found in "${actual[@]}"; do
    [[ $found == "Noto Sans CJK ${variant^^}" ]] || fail "Chromium fallback with the $variant preference uses Noto Sans CJK ${variant^^}" "${actual[*]}"
  done
  for generic in sans-serif serif monospace; do
    actual=$(echo "$generic - 9aa8" | resolve C.UTF-8 string)
    [[ $actual == "${cjk[$generic]} ${variant^^}" ]] || fail "$generic Han with the $variant preference" "$actual"
    actual=$(env -u LC_ALL -u LC_CTYPE -u FC_LANG LANG=C.UTF-8 fc-match -f '%{family[0]}' "$generic")
    [[ $actual == "${latin[$generic]}" ]] || fail "the $variant preference leaves $generic on its Latin family" "$actual"
  done
done
pass "a CJK preference sets untagged Han and CJK punctuation everywhere, Chromium included, and keeps the Latin families"

OMARCHY_PATH=$ROOT python3 "$ROOT/default/input-methods/configure.py" font default
! grep -q 'CJK' "$XDG_CONFIG_HOME/fontconfig/conf.d/50-omarchy-input-method.conf" || fail "the default preference names no CJK forms"
pass "the default CJK preference leaves the system's choice"

# With no preference, untagged Han takes Japanese forms in every app, and an
# English page's CJK punctuation stays out of Noto Sans Mongolian.
chromium_fallback "en 9aa8" "en 3001" "en 300c" "en ff01" "- 3001"
for found in "${actual[@]}"; do
  [[ $found == "Noto Sans CJK JP" ]] || fail "Chromium fallback with no preference uses Noto Sans CJK JP" "${actual[*]}"
done
for generic in sans-serif serif monospace; do
  actual=$(echo "$generic - 9aa8" | resolve C.UTF-8 string)
  [[ $actual == "${cjk[$generic]} JP" ]] || fail "$generic Han with no preference is JP" "$actual"
  actual=$(env -u LC_ALL -u LC_CTYPE -u FC_LANG LANG=C.UTF-8 fc-match -f '%{family[0]}' "$generic")
  [[ $actual == "${latin[$generic]}" ]] || fail "the Japanese default leaves $generic on its Latin family" "$actual"
done
pass "with no preference, Han and CJK punctuation take Japanese forms everywhere"
