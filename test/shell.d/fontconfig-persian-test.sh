#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v fc-match >/dev/null || ! command -v python3 >/dev/null; then
  skip "Persian fallback needs fontconfig and python3"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# A staged package can be tested without installing it on the host.
export XDG_CONFIG_HOME="$test_tmp/config" XDG_DATA_HOME="$test_tmp/data"
unset FONTCONFIG_FILE FONTCONFIG_PATH
{
  echo '<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig>'
  echo "<dir>/usr/share/fonts</dir><cachedir>$test_tmp/cache</cachedir>"
  if [[ -n ${OMARCHY_TEST_FONT_DIR:-} ]]; then
    printf '<dir>%s</dir>\n' "$OMARCHY_TEST_FONT_DIR"
  fi
  placed=false
  for conf in /etc/fonts/conf.d/*.conf; do
    name=${conf##*/}
    [[ $name == "50-omarchy.conf" ]] && continue
    if ! $placed && [[ $name > "50-omarchy.conf" ]]; then
      echo "<include>$ROOT/default/fontconfig/conf.avail/50-omarchy.conf</include>"
      placed=true
    fi
    echo "<include>$conf</include>"
  done
  $placed || echo "<include>$ROOT/default/fontconfig/conf.avail/50-omarchy.conf</include>"
  echo '</fontconfig>'
} >"$test_tmp/fonts.conf"
export FONTCONFIG_FILE="$test_tmp/fonts.conf"

for family in "Vazirmatn NL" "Noto Naskh Arabic" "Noto Nastaliq Urdu"; do
  if [[ $(fc-match -f '%{family[0]}' "$family") != "$family" ]]; then
    skip "Persian fallback needs ttf-vazirmatn-nl and noto-fonts ($family missing)"
    exit 0
  fi
done

# Exercise strings (Pango/Qt), langsets (fc-match), and Chromium's family-less
# FcFontSort + character-coverage fallback. User fonts and rules are excluded.
env -u LC_ALL -u LC_CTYPE -u FC_LANG LANG=C.UTF-8 python3 - <<'PY'
import ctypes as c

fc = c.CDLL("libfontconfig.so.1")
p = c.c_void_p

class FontSet(c.Structure):
  _fields_ = [("nfont", c.c_int), ("sfont", c.c_int), ("fonts", c.POINTER(p))]

def bind(name, result, *args):
  fn = getattr(fc, name)
  fn.restype = result
  fn.argtypes = args
  return fn

create = bind("FcPatternCreate", p)
add = bind("FcPatternAddString", c.c_int, p, c.c_char_p, c.c_char_p)
langset_create = bind("FcLangSetCreate", p)
langset_add = bind("FcLangSetAdd", c.c_int, p, c.c_char_p)
add_langset = bind("FcPatternAddLangSet", c.c_int, p, c.c_char_p, p)
langset_destroy = bind("FcLangSetDestroy", None, p)
substitute = bind("FcConfigSubstitute", c.c_int, p, p, c.c_int)
defaults = bind("FcDefaultSubstitute", None, p)
delete = bind("FcPatternDel", c.c_int, p, c.c_char_p)
sort = bind("FcFontSort", c.POINTER(FontSet), p, p, c.c_int, p, c.POINTER(c.c_int))
get_charset = bind("FcPatternGetCharSet", c.c_int, p, c.c_char_p, c.c_int, c.POINTER(p))
has_char = bind("FcCharSetHasChar", c.c_int, p, c.c_uint32)
get_string = bind("FcPatternGetString", c.c_int, p, c.c_char_p, c.c_int, c.POINTER(c.c_char_p))
destroy = bind("FcPatternDestroy", None, p)
destroy_fonts = bind("FcFontSetDestroy", None, c.POINTER(FontSet))

def resolve(family, tags, char, kind, prgname=None):
  pattern = create()
  if prgname:
    add(pattern, b"prgname", prgname.encode())
  if family:
    add(pattern, b"family", family.encode())
  if tags:
    if kind == "string":
      for tag in tags.split("|"):
        add(pattern, b"lang", tag.encode())
    else:
      langs = langset_create()
      for tag in tags.split("|"):
        langset_add(langs, tag.encode())
      add_langset(pattern, b"lang", langs)
      langset_destroy(langs)
  substitute(None, pattern, 0)
  defaults(pattern)
  if tags is None:
    delete(pattern, b"lang")
  fonts = sort(None, pattern, 0, None, c.byref(c.c_int()))
  found = None
  for i in range(fonts.contents.nfont):
    font = fonts.contents.fonts[i]
    charset = p()
    if get_charset(font, b"charset", 0, c.byref(charset)) == 0 and has_char(charset, char):
      value = c.c_char_p()
      get_string(font, b"family", 0, c.byref(value))
      found = value.value.decode()
      break
  destroy_fonts(fonts)
  destroy(pattern)
  return found

checks = 0
def expect(family, tags, char, expected, kind, prgname=None):
  global checks
  actual = resolve(family, tags, char, kind, prgname)
  assert actual == expected, (kind, family, tags, prgname, hex(char), expected, actual)
  checks += 1

for kind in ("string", "langset"):
  for family in (None, "sans-serif", "serif", "monospace", "Liberation Sans", "JetBrainsMono Nerd Font"):
    for tag in (None, "en", "fa", "fa-ir", "fa-af", "zh-cn|fa"):
      for char in (0x0628, 0x067E, 0x0686, 0x0698, 0x06A9, 0x06AF, 0x06CC, 0x06F1):
        expect(family, tag, char, "Vazirmatn NL", kind)
    for tag, expected in (("ar", "Noto Naskh Arabic"), ("ar-sa", "Noto Naskh Arabic"), ("ur", "Noto Nastaliq Urdu"), ("ur-pk", "Noto Nastaliq Urdu"), ("zh-cn|ur", "Noto Nastaliq Urdu")):
      expect(family, tag, 0x067E, expected, kind)

  # Keep an explicitly requested Arabic-script font ahead of untagged fallback.
  expect("Noto Naskh Arabic", "en", 0x067E, "Noto Naskh Arabic", kind)
  expect("Noto Nastaliq Urdu", None, 0x067E, "Noto Nastaliq Urdu", kind)
  expect("Noto Naskh Arabic", "fat", 0x067E, "Noto Naskh Arabic", kind)

  for tag in (None, "en", "fa", "fa-ir", "ar", "ur", "fat"):
    for family, expected in (("sans-serif", "Liberation Sans"), ("serif", "Liberation Serif"), ("monospace", "JetBrainsMono Nerd Font")):
      expect(family, tag, 0x0041, expected, kind)
      # The existing Arabic prepend rule also selects Naskh's Western digits.
      expect(family, tag, 0x0031, "Noto Naskh Arabic" if tag == "ar" else expected, kind)
      expect(family, tag, 0x1F600, "Noto Color Emoji", kind)
    expect("monospace", tag, 0xE0B0, "JetBrainsMono Nerd Font", kind)

  # Match the working Nautilus preference even when Pango labels Persian ar.
  # This app-wide exception also changes actual Arabic and Urdu text there.
  for family in (None, "sans-serif", "monospace"):
    for tag in (None, "fa", "ar", "ur"):
      expect(family, tag, 0x067E, "Vazirmatn NL", kind, "org.gnome.Nautilus")
  for family, expected in (("sans-serif", "Liberation Sans"), ("monospace", "JetBrainsMono Nerd Font")):
    expect(family, "ar", 0x0041, expected, kind, "org.gnome.Nautilus")
  for tag, expected in (("ar", "Noto Naskh Arabic"), ("ur", "Noto Nastaliq Urdu")):
    expect("sans-serif", tag, 0x067E, expected, kind, "org.example.OtherApp")

print(f"ok - {checks} Persian, Nautilus, Arabic, Urdu, Latin, digit, emoji and Nerd Font fallback checks")
PY
