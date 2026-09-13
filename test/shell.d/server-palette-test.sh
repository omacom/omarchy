#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

# The palette resolver is omarchy-theme-color's job and has its own coverage.
# Stubbing it keeps this suite on the translation: hex to escape, role to
# fallback, and the two degradation axes.
mkdir -p "$workdir/stub"
cat >"$workdir/stub/omarchy-theme-color" <<'STUB'
#!/bin/bash
printf 'accent\t#7aa2f7\n'
printf 'foreground\t#a9b1d6\n'
printf 'dark_foreground\t#565f89\n'
printf 'muted\t#414868\n'
printf 'bright_foreground\t#c0caf5\n'
printf 'bright_magenta\t#bb9af7\n'
printf 'yellow\t#e0af68\n'
printf 'green\t#9ece6a\n'
printf 'bright_yellow\t#ff9e64\n'
printf 'bright_cyan\t#0db9d7\n'
printf 'red\t#f7768e\n'
printf 'selection\t#292e42\n'
printf 'darker_background\t#0e0e14\n'
STUB
chmod +x "$workdir/stub/omarchy-theme-color"

export PATH="$workdir/stub:$ROOT/bin:$PATH"
export OMARCHY_EDITION_FILE="$workdir/omarchy-edition"

truecolor=$(omarchy-server-palette --truecolor)
ansi=$(omarchy-server-palette --ansi)

# Every role the front door draws with has to exist in both depths, or a
# renderer picks up an empty string and silently loses its color.
while IFS= read -r role; do
  grep -q "^OMARCHY_BBS_$role=" <<<"$truecolor" ||
    fail "every role is emitted at truecolor" "OMARCHY_BBS_$role is missing"
  grep -q "^OMARCHY_BBS_$role=" <<<"$ansi" ||
    fail "every role is emitted at 16 colors" "OMARCHY_BBS_$role is missing"
done < <(omarchy-server-palette --names)
pass "every role is emitted at both depths"

# #7aa2f7 is 122, 162, 247.
grep -qF "OMARCHY_BBS_ACCENT=\$'\\033[38;2;122;162;247m'" <<<"$truecolor" ||
  fail "hex is converted to a truecolor foreground" "$(grep '^OMARCHY_BBS_ACCENT=' <<<"$truecolor")"
grep -qF "OMARCHY_BBS_ACCENT_BG=\$'\\033[48;2;122;162;247m'" <<<"$truecolor" ||
  fail "background roles use the background layer" "$(grep '^OMARCHY_BBS_ACCENT_BG=' <<<"$truecolor")"
pass "hex converts to truecolor on the right layer"

grep -qF "OMARCHY_BBS_ACCENT=\$'\\033[34m'" <<<"$ansi" ||
  fail "16-color mode falls back to a plain SGR code" "$(grep '^OMARCHY_BBS_ACCENT=' <<<"$ansi")"
grep -qF "OMARCHY_BBS_ACCENT_BG=\$'\\033[44m'" <<<"$ansi" ||
  fail "16-color backgrounds fall back to a background SGR code"
pass "16-color mode falls back to plain SGR codes"

# A theme that defines nothing at all still has to produce a usable palette.
cat >"$workdir/stub/omarchy-theme-color" <<'STUB'
#!/bin/bash
printf 'accent\tnot-a-color\n'
STUB
chmod +x "$workdir/stub/omarchy-theme-color"
empty=$(omarchy-server-palette --truecolor)
grep -qF "OMARCHY_BBS_ACCENT=\$'\\033[34m'" <<<"$empty" ||
  fail "an unusable value falls back rather than emitting a broken escape" \
    "$(grep '^OMARCHY_BBS_ACCENT=' <<<"$empty")"
while IFS= read -r role; do
  grep -q "^OMARCHY_BBS_$role=\$'" <<<"$empty" ||
    fail "an empty palette still emits every role" "OMARCHY_BBS_$role is missing"
done < <(omarchy-server-palette --names)
pass "an unusable or missing color falls back instead of emitting a broken escape"

# Depth and glyphs degrade on their own detection, so a capable terminal that
# happens to lack box drawing keeps its colors, and TERM=linux gets the
# ASCII-and-16-colors floor the design calls for.
[[ $(TERM=linux COLORTERM= omarchy-server-palette | grep '^OMARCHY_BBS_UNICODE=') == "OMARCHY_BBS_UNICODE=0" ]] ||
  fail "a Linux console asks renderers for ASCII glyphs"
[[ $(TERM=xterm-256color COLORTERM=truecolor omarchy-server-palette | grep '^OMARCHY_BBS_UNICODE=') == "OMARCHY_BBS_UNICODE=1" ]] ||
  fail "a capable terminal asks renderers for box drawing"
[[ $(TERM=linux COLORTERM= omarchy-server-palette | grep '^OMARCHY_BBS_DEPTH=') == "OMARCHY_BBS_DEPTH=ansi" ]] ||
  fail "a Linux console drops to 16 colors"
[[ $(TERM=dumb COLORTERM=truecolor omarchy-server-palette | grep '^OMARCHY_BBS_DEPTH=') == "OMARCHY_BBS_DEPTH=ansi" ]] ||
  fail "a dumb terminal drops to 16 colors"
pass "color depth and glyph set degrade independently"

# omarchy-theme-set calls the issue renderer unconditionally, so it has to be
# silent and successful on a desktop.
printf 'desktop\n' >"$OMARCHY_EDITION_FILE"
export OMARCHY_ISSUE_FILE="$workdir/issue"
printf 'Arch Linux \\r (\\l)\n' >"$OMARCHY_ISSUE_FILE"
stock=$(cat "$OMARCHY_ISSUE_FILE")

output=$(omarchy-server-issue) || fail "the issue renderer succeeds on the desktop edition"
[[ -z $output ]] || fail "the issue renderer prints nothing on the desktop edition" "$output"
[[ $(cat "$OMARCHY_ISSUE_FILE") == "$stock" ]] ||
  fail "the issue renderer leaves the desktop banner alone"
[[ ! -e $OMARCHY_ISSUE_FILE.omarchy-orig ]] ||
  fail "the issue renderer keeps no backup it never needed"
pass "the issue renderer is a silent no-op on the desktop edition"

printf 'server\n' >"$OMARCHY_EDITION_FILE"
omarchy-server-issue || fail "the issue renderer writes on the server edition"
[[ -s $OMARCHY_ISSUE_FILE ]] || fail "the issue file is written and not empty"

# agetty expands these every time it draws the banner, which is why nothing has
# to regenerate the file when the hostname or address changes.
for escape in '\n' '\4' '\l'; do
  grep -qF -- "$escape" "$OMARCHY_ISSUE_FILE" ||
    fail "the banner leaves agetty's escapes for it to expand" "$escape is missing"
done
grep -q "OMARCHY SERVER" "$OMARCHY_ISSUE_FILE" || fail "the banner names the edition"
pass "the banner is written with agetty's own escapes intact"

# A console font without box drawing substitutes characters and wrecks the
# alignment, so the banner stays inside ASCII.
LC_ALL=C grep -q '[^[:print:][:space:]'$'\033'']' "$OMARCHY_ISSUE_FILE" &&
  fail "the banner stays inside ASCII for the console"
pass "the banner stays inside ASCII"

# The edition marker is writable, so a machine can stop being a server. One that
# was one long enough to get a banner must not keep greeting people as one.
[[ -e $OMARCHY_ISSUE_FILE.omarchy-orig ]] ||
  fail "the stock banner is kept before the server banner overwrites it"
[[ $(cat "$OMARCHY_ISSUE_FILE.omarchy-orig") == "$stock" ]] ||
  fail "the kept banner is the one that was there"

omarchy-server-issue || fail "writing the banner twice is safe"
[[ $(cat "$OMARCHY_ISSUE_FILE.omarchy-orig") == "$stock" ]] ||
  fail "a second write does not overwrite the kept banner with the server one"
pass "the stock banner is kept, once, before being replaced"

printf 'desktop\n' >"$OMARCHY_EDITION_FILE"
omarchy-server-issue || fail "the issue renderer succeeds when the edition changes back"
[[ $(cat "$OMARCHY_ISSUE_FILE") == "$stock" ]] ||
  fail "going back to the desktop edition restores the stock banner" \
    "$(cat "$OMARCHY_ISSUE_FILE")"
[[ ! -e $OMARCHY_ISSUE_FILE.omarchy-orig ]] ||
  fail "the restored backup is cleaned up"
pass "going back to the desktop edition restores the stock banner"

cat >"$workdir/stub/omarchy-theme-color" <<'STUB'
#!/bin/bash
printf 'color0\t#1a1b26\n'
printf 'color4\t#7aa2f7\n'
printf 'color15\t#c0caf5\n'
STUB
chmod +x "$workdir/stub/omarchy-theme-color"
console=$(TERM=linux omarchy-server-palette --ansi)
grep -qF "OMARCHY_BBS_CONSOLE_PALETTE=\$'\\033]P01a1b26\\033]P47aa2f7\\033]Pfc0caf5'" <<<"$console" ||
  fail "the console palette programs each shipped colorN slot" \
    "$(grep '^OMARCHY_BBS_CONSOLE_PALETTE=' <<<"$console")"
pass "the console palette maps colorN onto the VT slots"

grep -qF "OMARCHY_BBS_CONSOLE_PALETTE=\$''" <<<"$(TERM=xterm-256color omarchy-server-palette --ansi)" ||
  fail "the palette program stays off terminals that are not the console"
pass "no palette program leaks to a non-console terminal"

grep -qF "\\033]P01a1b26" <<<"$(TERM=xterm-256color omarchy-server-palette --truecolor --console)" ||
  fail "--console forces the program for output that renders on a VT later"
pass "--console forces the palette program regardless of TERM"
