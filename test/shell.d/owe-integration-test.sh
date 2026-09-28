#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/home"
export TEST_CALLS="$work/calls"
for command in omarchy-pkg-add omarchy-hook-install systemctl; do
  cat >"$work/bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$TEST_CALLS"
case "$*" in
  '--user enable owed.service') [[ ${TEST_TTY:-0} == 0 ]] ;;
  '--user is-active --quiet graphical-session.target') [[ ${TEST_TTY:-0} == 0 ]] ;;
  '--user start owed.service') [[ ${TEST_START_FAIL:-0} == 0 ]] ;;
  *) exit 0 ;;
esac
SH
  chmod +x "$work/bin/$command"
done

migration="$ROOT/migrations/1789764927.sh"
run_migration() {
  HOME="$work/home" PATH="$work/bin:$PATH" bash -euo pipefail "$migration"
}
run_migration
run_migration
grep -Fx 'omarchy-pkg-add owe owe-lockfeed' "$TEST_CALLS" >/dev/null
grep -Fx 'omarchy-hook-install theme-set /usr/share/owe/10-owe-sync' "$TEST_CALLS" >/dev/null
grep -Fx 'systemctl --user start owed.service' "$TEST_CALLS" >/dev/null
pass "migration installs OWE, its theme refresh hook, and starts the graphical session service"

: >"$TEST_CALLS"
TEST_TTY=1 run_migration
TEST_TTY=1 run_migration
[[ $(readlink "$work/home/.config/systemd/user/graphical-session.target.wants/owed.service") == /usr/lib/systemd/user/owed.service ]]
if grep -F 'systemctl --user start' "$TEST_CALLS" >/dev/null; then
  fail "TTY migration must not start the renderer"
fi
pass "TTY migrations enable the next login without starting a renderer"

: >"$TEST_CALLS"
OMARCHY_UPGRADE_TO_QUATTRO_LIVE=1 run_migration
if grep -F 'systemctl --user start' "$TEST_CALLS" >/dev/null; then
  fail "Quattro upgrade must defer OWE until the new graphical session"
fi
pass "Quattro upgrade enables OWE without starting it in the old shell"

if TEST_START_FAIL=1 run_migration; then
  fail "a failed live service start leaves the migration pending"
fi
pass "a failed live service start fails the migration"

: >"$TEST_CALLS"
HOME="$work/home" PATH="$work/bin:$PATH" bash "$ROOT/install/user/first-run/enable-user-units.sh"
grep -E '^systemctl --user enable --now .*owed.service' "$TEST_CALLS" >/dev/null
grep -Fx 'omarchy-hook-install theme-set /usr/share/owe/10-owe-sync' "$TEST_CALLS" >/dev/null
pass "fresh installs enable OWE and install the theme refresh hook"

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
