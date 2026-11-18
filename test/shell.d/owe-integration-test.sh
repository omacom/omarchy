#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/home"
export TEST_CALLS="$work/calls"
for command in omarchy-hook-install omarchy-input-method systemctl; do
  cat >"$work/bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$TEST_CALLS"
case "$*" in
  'configure --defaults') [[ ${TEST_INPUT_FAIL:-0} == 0 ]] ;;
  *) exit 0 ;;
esac
SH
  chmod +x "$work/bin/$command"
done

: >"$TEST_CALLS"
HOME="$work/home" PATH="$work/bin:$PATH" bash "$ROOT/install/user/first-run/enable-user-units.sh"
grep -E '^systemctl --user enable --now .*owed.service' "$TEST_CALLS" >/dev/null
grep -Fx 'omarchy-hook-install theme-set /usr/share/owe/10-owe-sync' "$TEST_CALLS" >/dev/null
pass "fresh installs enable OWE and install the theme refresh hook"

: >"$TEST_CALLS"
HOME="$work/home" PATH="$work/bin:$PATH" TEST_INPUT_FAIL=1 bash "$ROOT/install/user/first-run/enable-user-units.sh"
grep -Fx 'omarchy-input-method configure --defaults' "$TEST_CALLS" >/dev/null
grep -E '^systemctl --user enable --now .*owed.service' "$TEST_CALLS" >/dev/null
pass "failed input defaults do not block enabling first-run services"

cat >"$work/bin/ffmpegthumbnailer" <<'SH'
#!/bin/bash
printf 'thumbnail\n' >>"$TEST_CALLS"
while (( $# )); do
  case "$1" in
    -o) output=$2; shift 2 ;;
    *) shift ;;
  esac
done
[[ ${TEST_POSTER_FAIL:-0} == 0 ]] || exit 1
printf 'poster\n' >"$output"
SH
chmod +x "$work/bin/ffmpegthumbnailer"
source_path="$work/video with 'quotes'.mp4"
printf 'source\n' >"$source_path"
poster() {
  PATH="$work/bin:$PATH" XDG_CACHE_HOME="$work/cache" bash "$ROOT/shell/plugins/lock/poster.sh" "$source_path"
}
: >"$TEST_CALLS"
first=$(poster)
[[ -s $first && $(poster) == "$first" ]]
[[ $(wc -l <"$TEST_CALLS") == 1 ]]
printf 'changed source\n' >>"$source_path"
second=$(poster)
[[ -s $second && $second != "$first" && ! -e $first ]]
pass "lock posters are cached, refreshed after source changes, and old frames are evicted"
printf 'broken source\n' >>"$source_path"
if TEST_POSTER_FAIL=1 poster; then fail "failed poster generation must fail"; fi
[[ -z $(find "$work/cache" -name '.poster-*.jpg' -print -quit) ]]
pass "failed poster generation never publishes a partial image"
