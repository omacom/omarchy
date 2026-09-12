#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
stub="$tmpdir/bin"
mkdir -p "$home/.local/state/omarchy/current/theme/backgrounds" "$stub"

printf 'tokyo-night\n' >"$home/.local/state/omarchy/current/theme.name"
for name in a-one.png b-two.png c-three.png; do
  printf 'img-%s' "$name" >"$home/.local/state/omarchy/current/theme/backgrounds/$name"
done

ln -s "$home/.local/state/omarchy/current/theme/backgrounds/b-two.png" \
  "$home/.local/state/omarchy/current/background"

cat >"$stub/omarchy-theme-bg-set" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >"$BG_SET_LOG"
SH
cat >"$stub/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$NOTIFY_LOG"
SH
chmod +x "$stub/omarchy-theme-bg-set" "$stub/omarchy-notification-send"

HOME="$home" PATH="$stub:$PATH" BG_SET_LOG="$tmpdir/set" \
  "$BASH" "$ROOT/bin/omarchy-theme-bg-prev"

[[ $(<"$tmpdir/set") == "$home/.local/state/omarchy/current/theme/backgrounds/a-one.png" ]] ||
  fail "theme-bg-prev selects the previous background in sort order" "$(cat "$tmpdir/set")"
pass "theme-bg-prev selects the previous background"

ln -sfn "$home/.local/state/omarchy/current/theme/backgrounds/a-one.png" \
  "$home/.local/state/omarchy/current/background"

HOME="$home" PATH="$stub:$PATH" BG_SET_LOG="$tmpdir/set" \
  "$BASH" "$ROOT/bin/omarchy-theme-bg-prev"

[[ $(<"$tmpdir/set") == "$home/.local/state/omarchy/current/theme/backgrounds/c-three.png" ]] ||
  fail "theme-bg-prev wraps from the first background to the last" "$(cat "$tmpdir/set")"
pass "theme-bg-prev wraps around to the last background"

rm -f "$home/.local/state/omarchy/current/background"
HOME="$home" PATH="$stub:$PATH" BG_SET_LOG="$tmpdir/set" \
  "$BASH" "$ROOT/bin/omarchy-theme-bg-prev"

[[ $(<"$tmpdir/set") == "$home/.local/state/omarchy/current/theme/backgrounds/c-three.png" ]] ||
  fail "theme-bg-prev starts at the last background when none is current" "$(cat "$tmpdir/set")"
pass "theme-bg-prev starts at the last background when none is set"

rm -rf "$home/.local/state/omarchy/current/theme/backgrounds"
mkdir -p "$home/.local/state/omarchy/current/theme/backgrounds"
HOME="$home" PATH="$stub:$PATH" NOTIFY_LOG="$tmpdir/notify" \
  "$BASH" "$ROOT/bin/omarchy-theme-bg-prev"

grep -Fq 'No background was found for theme' "$tmpdir/notify" ||
  fail "theme-bg-prev notifies when the theme has no backgrounds" "$(cat "$tmpdir/notify")"
pass "theme-bg-prev notifies when there is nothing to cycle"

# The current background is stored by its resolved path, while candidates can
# be reached through a symlinked user background directory.
user_backgrounds="$home/.config/omarchy/backgrounds/tokyo-night"
real_backgrounds="$tmpdir/backgrounds with spaces"
mkdir -p "$(dirname "$user_backgrounds")" "$real_backgrounds"
ln -s "$real_backgrounds" "$user_backgrounds"
for name in a.png b.png c.png; do
  printf 'image' >"$real_backgrounds/$name"
done

for current in c b a; do
  case "$current" in
    c) previous=b ;;
    b) previous=a ;;
    a) previous=c ;;
  esac
  ln -sfn "$real_backgrounds/$current.png" "$home/.local/state/omarchy/current/background"
  HOME="$home" PATH="$stub:$PATH" BG_SET_LOG="$tmpdir/set" \
    "$BASH" "$ROOT/bin/omarchy-theme-bg-prev"
  [[ $(<"$tmpdir/set") == "$user_backgrounds/$previous.png" ]] ||
    fail "theme-bg-prev cycles symlinked backgrounds from $current to $previous" "$(cat "$tmpdir/set")"
done
pass "theme-bg-prev cycles every background and wraps through a symlinked directory"

ln -sfn "../../../../../backgrounds with spaces/b.png" "$home/.local/state/omarchy/current/background"
HOME="$home" PATH="$stub:$PATH" BG_SET_LOG="$tmpdir/set" \
  "$BASH" "$ROOT/bin/omarchy-theme-bg-prev"
[[ $(<"$tmpdir/set") == "$user_backgrounds/a.png" ]] ||
  fail "theme-bg-prev resolves a relative current background link" "$(cat "$tmpdir/set")"
pass "theme-bg-prev resolves a relative current background link"
