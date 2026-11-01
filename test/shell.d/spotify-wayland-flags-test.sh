#!/bin/bash
#
# The Spotify installer must install the default flags only when the user has
# none, and otherwise add --ozone-platform=wayland only when the user hasn't
# chosen a platform themselves.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/home" "$test_dir/bin"
flags="$test_dir/home/.config/spotify-flags.conf"

for stub in omarchy-hw-x86 omarchy-pkg-add setsid uwsm-app; do
  printf '#!/bin/bash\n' >"$test_dir/bin/$stub"
  chmod +x "$test_dir/bin/$stub"
done

run_installer() {
  HOME="$test_dir/home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$PATH" bash "$ROOT/bin/omarchy-install-service-spotify" >/dev/null
}

run_installer
cmp -s "$ROOT/config/spotify-flags.conf" "$flags" || fail "installer installs the default Spotify flags"
pass "installer installs the default Spotify flags"

run_installer
cmp -s "$ROOT/config/spotify-flags.conf" "$flags" || fail "installer can be rerun"
pass "installer can be rerun"

printf -- '--force-device-scale-factor=1.5\n' >"$flags"
run_installer
[[ $(cat "$flags") == $'--force-device-scale-factor=1.5\n--ozone-platform=wayland' ]] || fail "installer appends the Wayland switch to the user's flags" "$(cat "$flags")"
pass "installer appends the Wayland switch to the user's flags"

printf -- '--force-device-scale-factor=1.5' >"$flags"
run_installer
printf -- '--force-device-scale-factor=1.5\n--ozone-platform=wayland\n' >"$test_dir/expected"
cmp -s "$test_dir/expected" "$flags" || fail "installer adds a missing newline before appending" "$(cat "$flags")"
pass "installer adds a missing newline before appending"

run_installer
[[ $(grep -cx -- '--ozone-platform=wayland' "$flags") == 1 ]] || fail "installer does not duplicate the Wayland switch" "$(cat "$flags")"
pass "installer does not duplicate the Wayland switch"

printf -- '--ozone-platform=x11\n' >"$flags"
run_installer
[[ $(cat "$flags") == '--ozone-platform=x11' ]] || fail "installer keeps a platform the user chose" "$(cat "$flags")"
pass "installer keeps a platform the user chose"

printf -- '# --ozone-platform=wayland\n' >"$flags"
run_installer
grep -Fxq -- '--ozone-platform=wayland' "$flags" || fail "installer ignores a commented-out platform line" "$(cat "$flags")"
pass "installer ignores a commented-out platform line"

: >"$flags"
run_installer
[[ $(cat "$flags") == '--ozone-platform=wayland' ]] || fail "installer fills an empty flags file" "$(cat "$flags")"
pass "installer fills an empty flags file"
