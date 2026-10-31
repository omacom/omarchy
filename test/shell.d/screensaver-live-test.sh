#!/bin/bash

# The launcher hands the screensaver to omarchy-ambient when a live one is
# chosen, and execs the stock one otherwise.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin"

# The stock path execs the native screensaver, which is not stubbable at its
# absolute path; without a Wayland display it exits at once, so taking that
# path shows up as no omarchy-ambient call at all.
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/omarchy-toggle-enabled"
cat >"$tmpdir/bin/omarchy-ambient" <<'SH'
#!/bin/bash
if [[ $* == "screensaver --get" ]]; then
  cat "$TEST_DIR/selected"
else
  echo "ambient $*" >>"$TEST_DIR/calls"
fi
SH
chmod +x "$tmpdir/bin/"*

launch() {
  : >"$tmpdir/calls"
  env -u WAYLAND_DISPLAY XDG_RUNTIME_DIR="$tmpdir" PATH="$tmpdir/bin:$ROOT/bin:/usr/bin:/bin" TEST_DIR="$tmpdir" \
    timeout 10 "$ROOT/bin/omarchy-launch-screensaver" "$@" 2>/dev/null || true
  cat "$tmpdir/calls"
}

echo amiga >"$tmpdir/selected"
[[ $(launch) == "ambient screensaver" ]] || fail "a live screensaver runs through omarchy-ambient" "$(launch)"
pass "a live screensaver runs through omarchy-ambient"

[[ $(launch force) == "ambient screensaver" ]] || fail "Preview runs the live screensaver too" "$(launch force)"
pass "Preview runs the live screensaver too"

[[ -z $(launch force text) ]] || fail "force text still runs the stock screensaver" "$(launch force text)"
pass "force text still runs the stock screensaver"

echo text >"$tmpdir/selected"
[[ -z $(launch) ]] || fail "with Animated Text chosen the stock screensaver runs" "$(launch)"
pass "with Animated Text chosen the stock screensaver runs"

# The toggle still holds the live screensaver back, and Preview overrides it.
printf '#!/bin/bash\nexit 0\n' >"$tmpdir/bin/omarchy-toggle-enabled"
echo amiga >"$tmpdir/selected"
[[ -z $(launch) ]] || fail "a live screensaver stays off while the toggle is off" "$(launch)"
pass "a live screensaver stays off while the toggle is off"
[[ $(launch force) == "ambient screensaver" ]] || fail "force runs the live screensaver with the toggle off" "$(launch force)"
pass "force runs the live screensaver with the toggle off"
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/omarchy-toggle-enabled"

# Branding changes must switch back from Amiga only after the edit succeeds.
mkdir -p "$tmpdir/home/.config/omarchy/branding" "$tmpdir/omarchy"
printf 'logo\n' >"$tmpdir/omarchy/logo.txt"
printf '#!/bin/bash\necho preview >>"$TEST_DIR/calls"\n' >"$tmpdir/bin/omarchy-launch-screensaver"
printf '#!/bin/bash\nexit "${EDIT_RESULT:-0}"\n' >"$tmpdir/bin/omarchy-launch-editor"
printf '#!/bin/bash\necho image.png\n' >"$tmpdir/bin/omarchy-file-select"
printf '#!/bin/bash\nexit "${EDIT_RESULT:-0}"\n' >"$tmpdir/bin/omarchy-transcode-ascii"
printf '#!/bin/bash\necho pick-image\n' >"$tmpdir/bin/omarchy-i18n"
chmod +x "$tmpdir/bin/"*
brand() {
  : >"$tmpdir/calls"
  env HOME="$tmpdir/home" OMARCHY_PATH="$tmpdir/omarchy" TEST_DIR="$tmpdir" EDIT_RESULT="${2:-0}" \
    PATH="$tmpdir/bin:$ROOT/bin:/usr/bin:/bin" bash "$ROOT/bin/omarchy-branding-screensaver" "$1" || true
  cat "$tmpdir/calls"
}
for mode in text image reset; do
  [[ $(brand "$mode") == $'ambient screensaver --set text\npreview' ]] || fail "$mode selects text before preview" "$(brand "$mode")"
  pass "$mode selects text before preview"
done
for mode in text image; do
  [[ -z $(brand "$mode" 1) ]] || fail "cancelled $mode preserves the screensaver selection" "$(brand "$mode" 1)"
  pass "cancelled $mode preserves the screensaver selection"
done
# Picking even the already-selected theme image must end a live background.
mkdir -p "$tmpdir/home/.local/state/omarchy/current"
printf image >"$tmpdir/theme.png"
cat >"$tmpdir/bin/omarchy-shell" <<'SH'
#!/bin/bash
echo theme >>"$TEST_DIR/calls"
[[ $1 == shell && $2 == switchBackground ]] && echo ok
SH
chmod +x "$tmpdir/bin/omarchy-shell"
: >"$tmpdir/calls"
for repeat in 1 2; do
  env HOME="$tmpdir/home" TEST_DIR="$tmpdir" PATH="$tmpdir/bin:$ROOT/bin:/usr/bin:/bin" \
    bash "$ROOT/bin/omarchy-theme-bg-set" "$tmpdir/theme.png"
done
[[ $(cat "$tmpdir/calls") == $'ambient stop\ntheme\nambient stop\ntheme' ]] || fail "theme selection stops the live background every time" "$(cat "$tmpdir/calls")"
pass "theme selection stops the live background every time"
