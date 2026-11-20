#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The reset asks its question as root, after sudo has dropped OMARCHY_PATH from
# the environment. Every line of the question comes from omarchy-i18n, a child
# process, so the path the reset falls back to has to reach it. The real top
# level of the reset runs as root without OMARCHY_PATH, its fallback pointed at
# this checkout rather than the packaged tree, and stops once it has asked.
require_command jq

if ! unshare -Ur true >/dev/null 2>&1; then
  skip "user namespaces unavailable; the reset asks its question as root"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"

reset=$ROOT/bin/omarchy-system-factory-reset
[[ $(tail -n 1 "$reset") == 'main "$@"' ]] || fail "factory reset ends by calling main"
sed \
  -e "s|^PACKAGED_PATH=.*|PACKAGED_PATH=\"$tmp/reset\"|" \
  -e "/^\(export \)\?OMARCHY_PATH=/s|:-/usr/share/omarchy}|:-$ROOT}|" \
  -e "s|^TOP_MNT=.*|TOP_MNT=\"$tmp/top\"|" \
  -e 's|^main "\$@"$|confirm_reset|' \
  "$reset" >"$tmp/reset"
chmod +x "$tmp/reset"
grep -Fq "OMARCHY_PATH:-$ROOT}" "$tmp/reset" || fail "factory reset defaults OMARCHY_PATH to the packaged tree"

# gum records each line it would draw, then types the confirmation.
cat >"$tmp/bin/gum" <<'SH'
#!/bin/bash
case $1 in
  style)
    printf '%s\n' "${!#}" >>"$SCREEN"
    ;;
  input)
    while (( $# )); do
      if [[ $1 == "--placeholder" ]]; then
        printf '%s\n' "$2" >>"$SCREEN"
      fi
      shift
    done
    echo reset
    ;;
esac
SH
chmod +x "$tmp/bin/gum"

status=0
unshare -Ur env -i PATH="$tmp/bin:/usr/bin:/bin" HOME="$tmp" \
  OMARCHY_LANGUAGE_FILE="$OMARCHY_LANGUAGE_FILE" SCREEN="$tmp/screen" \
  "$tmp/reset" >/dev/null 2>"$tmp/errors" || status=$?
(( status == 0 )) || fail "factory reset accepts the typed confirmation" "$(cat "$tmp/errors")"
[[ ! -s $tmp/errors ]] || fail "factory reset asks its question without errors" "$(cat "$tmp/errors")"

catalog=$ROOT/default/i18n/en/cli.json
mapfile -t screen <"$tmp/screen"
(( ${#screen[@]} > 0 )) || fail "factory reset draws its question"
for line in "${screen[@]}"; do
  [[ -n ${line#  • } ]] || fail "factory reset draws every line of its question" "$(cat "$tmp/screen")"
done
[[ ${screen[0]} == "$(jq -r '."reset.question"' "$catalog")" ]] ||
  fail "factory reset asks its question in English" "$(cat "$tmp/screen")"
[[ ${screen[-1]} == "Type 'reset' to continue" ]] ||
  fail "factory reset says what to type" "$(cat "$tmp/screen")"
pass "factory reset asks its question as root without OMARCHY_PATH in the environment"
