#!/bin/bash
#
# The Spotify video migration and installer must install the default flags
# only when the user has none, and otherwise add the video decode switch next
# to the user's own flags without duplicating it.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/home" "$test_dir/usr/bin"

# The migration only acts when the packaged launcher exists, so point its guard
# at a stand-in instead of the real /usr/bin/spotify.
sed "s|/usr/bin/spotify|$test_dir/usr/bin/spotify|g" "$ROOT/migrations/1791036944.sh" >"$test_dir/migration.sh"
flags="$test_dir/home/.config/spotify-flags.conf"

run_migration() {
  HOME="$test_dir/home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$test_dir/migration.sh" >/dev/null
}

run_migration
[[ ! -e $flags ]] || fail "migration leaves users without Spotify alone"
pass "migration leaves users without Spotify alone"

printf '#!/bin/bash\n' >"$test_dir/usr/bin/spotify"
chmod +x "$test_dir/usr/bin/spotify"

run_migration
cmp -s "$ROOT/config/spotify-flags.conf" "$flags" || fail "migration installs the default Spotify flags"
pass "migration installs the default Spotify flags"

run_migration
cmp -s "$ROOT/config/spotify-flags.conf" "$flags" || fail "migration can be rerun"
pass "migration can be rerun"

printf -- '--force-device-scale-factor=1.5' >"$flags"
run_migration
[[ $(cat "$flags") == $'--force-device-scale-factor=1.5\n--disable-accelerated-video-decode' ]] || fail "migration appends the decode switch to the user's flags" "$(cat "$flags")"
pass "migration appends the decode switch to the user's flags"

printf -- '# --disable-accelerated-video-decode\n' >"$flags"
run_migration
grep -Fxq -- '--disable-accelerated-video-decode' "$flags" || fail "migration ignores a commented-out decode switch" "$(cat "$flags")"
pass "migration ignores a commented-out decode switch"

# The installer runs for people who add Spotify after the migration already
# ran, so it must add the switch to an existing flags file the same way.
mkdir -p "$test_dir/bin"
for stub in omarchy-pkg-add setsid uwsm-app; do
  printf '#!/bin/bash\n' >"$test_dir/bin/$stub"
  chmod +x "$test_dir/bin/$stub"
done

run_installer() {
  HOME="$test_dir/home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$PATH" bash "$ROOT/bin/omarchy-install-service-spotify" >/dev/null
}

rm -f "$flags"
run_installer
cmp -s "$ROOT/config/spotify-flags.conf" "$flags" || fail "installer installs the default Spotify flags"
pass "installer installs the default Spotify flags"

printf -- '--force-device-scale-factor=1.5' >"$flags"
run_installer
[[ $(cat "$flags") == $'--force-device-scale-factor=1.5\n--disable-accelerated-video-decode' ]] || fail "installer appends the decode switch to the user's flags" "$(cat "$flags")"
pass "installer appends the decode switch to the user's flags"

run_installer
[[ $(grep -cx -- '--disable-accelerated-video-decode' "$flags") == 1 ]] || fail "installer does not duplicate the decode switch" "$(cat "$flags")"
pass "installer does not duplicate the decode switch"
