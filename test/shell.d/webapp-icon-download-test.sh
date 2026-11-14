#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source <(sed -n '/^download_icon() {$/,/^}$/p' "$ROOT/bin/omarchy-webapp-install")
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/icons"
export ICON_DOWNLOAD_SOURCE="$scratch/download"
cat >"$scratch/bin/curl" <<'SH'
#!/bin/bash
while (($#)); do
  if [[ $1 == "-o" ]]; then cp "$ICON_DOWNLOAD_SOURCE" "$2"; break; fi
  shift
done
exit "${ICON_DOWNLOAD_STATUS:-0}"
SH
chmod +x "$scratch/bin/curl"
export PATH="$scratch/bin:$PATH"
icon="$scratch/icons/example.png"
printf 'existing icon' >"$icon"
for status in 0 18; do
  printf '<html>failed download</html>' >"$ICON_DOWNLOAD_SOURCE"
  if ICON_DOWNLOAD_STATUS=$status download_icon https://example.test/icon "$icon"; then fail "an invalid icon download fails"; fi
  [[ $(cat "$icon") == 'existing icon' ]] || fail "failed or non-image downloads preserve an existing icon"
  [[ $(find "$scratch/icons" -type f | wc -l) == 1 ]] || fail "failed downloads leave no staging files"
done
pass "partial and non-image responses cannot replace an installed icon"
printf 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/l9sAAAAASUVORK5CYII=' | base64 -d >"$ICON_DOWNLOAD_SOURCE"
download_icon https://example.test/icon "$icon" || fail "a complete image installs"
cmp -s "$ICON_DOWNLOAD_SOURCE" "$icon" || fail "the installed icon matches the validated image"
[[ $(find "$scratch/icons" -type f | wc -l) == 1 ]] || fail "a successful download leaves no staging files"
pass "a validated image replaces the old icon and leaves no staging file"
printf 'keep private target' >"$scratch/victim"
rm "$icon"
ln -s "$scratch/victim" "$icon"
download_icon https://example.test/icon "$icon" || fail "a validated image replaces an icon symlink"
[[ ! -L $icon && $(cat "$scratch/victim") == 'keep private target' ]] || fail "publishing an icon never writes through its old symlink"
pass "an icon symlink is replaced without changing its target"
