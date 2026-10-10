#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1791115667.sh"
shipped="$ROOT/default/alsa-card-profile/mixer/paths"

[[ -f $migration ]] || fail "the ASUS ROG mixer path migration exists at $migration"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"

cat >"$test_dir/bin/omarchy-hw-asus-rog" <<'STUB'
#!/bin/bash

[[ ${ROG:-1} == 1 ]]
STUB

cat >"$test_dir/bin/systemctl" <<'STUB'
#!/bin/bash

printf 'systemctl %s\n' "$*" >>"$CALLS"
STUB

# An HDMI card ahead of the Realtek one, as on machines with a discrete GPU.
# CODEC= (empty) leaves only the HDMI card.
cat >"$test_dir/bin/aplay" <<'STUB'
#!/bin/bash

echo "card 0: NVidia [HDA NVidia], device 3: HDMI 0 [HDMI 0]"
if [[ -n ${CODEC-ALC294} ]]; then
  echo "card 2: Generic_1 [HD-Audio Generic], device 0: ${CODEC-ALC294} Analog [${CODEC-ALC294} Analog]"
fi
STUB

cat >"$test_dir/bin/amixer" <<'STUB'
#!/bin/bash

printf 'amixer %s\n' "$*" >>"$CALLS"
if [[ $* == *"sget Master"* ]]; then
  echo "Simple mixer control 'Master',0"
  echo "  Mono: Playback ${MASTER:-87 [100%] [0.00dB] [on]}"
fi
STUB

chmod +x "$test_dir/bin/"*

run_migration() {
  local home="$1"
  shift

  env HOME="$home" OMARCHY_PATH="$ROOT" CALLS="$home/calls" PATH="$test_dir/bin:$PATH" "$@" \
    bash -euo pipefail "$migration" >/dev/null
}

soft_mixer_home() {
  local home="$test_dir/$1"

  mkdir -p "$home/.config/wireplumber/wireplumber.conf.d"
  touch "$home/.config/wireplumber/wireplumber.conf.d/alsa-soft-mixer.conf"
  printf '%s\n' "$home"
}

home=$(soft_mixer_home rog)
mkdir -p "$home/.local/state/wireplumber"
echo "routes" >"$home/.local/state/wireplumber/default-routes"
run_migration "$home" || fail "migration succeeds on a ROG soft-mixer install"

installed="$home/.config/alsa-card-profile/mixer/paths"
for path in analog-output-speaker analog-output-headphones; do
  cmp -s "$shipped/$path.conf" "$installed/$path.conf" || fail "migration installs the $path override"
done
[[ $(readlink "$installed/analog-output.conf.common") == "/usr/share/alsa-card-profile/mixer/paths/analog-output.conf.common" ]] ||
  fail "migration links the common path beside the overrides"
grep -qx 'systemctl --user try-restart wireplumber.service' "$home/calls" || fail "migration restarts a running WirePlumber"
[[ $(cat "$home/.local/state/wireplumber/default-routes") == "routes" ]] || fail "migration keeps the user's saved routes"
pass "migration installs the override paths and reloads WirePlumber"

run_migration "$home" || fail "migration can run again"
for path in analog-output-speaker analog-output-headphones; do
  cmp -s "$shipped/$path.conf" "$installed/$path.conf" || fail "a second run keeps the $path override"
done
pass "migration is repeatable"

home=$(soft_mixer_home custom)
installed="$home/.config/alsa-card-profile/mixer/paths"
mkdir -p "$installed"
echo "custom" >"$installed/analog-output-speaker.conf"
ln -s /nonexistent/common "$installed/analog-output.conf.common"
run_migration "$home" || fail "migration succeeds beside user overrides"
[[ $(cat "$installed/analog-output-speaker.conf") == "custom" ]] || fail "migration keeps a user's own path override"
[[ $(readlink "$installed/analog-output.conf.common") == "/nonexistent/common" ]] || fail "migration keeps a user's own common path link"
cmp -s "$shipped/analog-output-headphones.conf" "$installed/analog-output-headphones.conf" ||
  fail "migration still installs the path the user did not override"
pass "migration leaves the user's own overrides alone"

home=$(soft_mixer_home muted-master)
run_migration "$home" MASTER='0 [0%] [-65.25dB] [off]' || fail "migration succeeds with Master muted"
grep -qx 'amixer -c 2 set Master 80% unmute' "$home/calls" || fail "migration unmutes Master on the Realtek card" "$(cat "$home/calls")"
pass "migration unmutes a Master that a fresh install would have unmuted"

home=$(soft_mixer_home working-master)
run_migration "$home" || fail "migration succeeds with Master on"
! grep -q 'set Master' "$home/calls" || fail "migration leaves a working Master level alone" "$(cat "$home/calls")"
pass "migration leaves a working Master level alone"

home=$(soft_mixer_home no-realtek)
run_migration "$home" CODEC= || fail "migration succeeds without a Realtek card"
! grep -q '^amixer' "$home/calls" || fail "migration skips Master without a Realtek card" "$(cat "$home/calls")"
pass "migration skips Master without a Realtek card"

home="$test_dir/no-soft-mixer"
mkdir -p "$home"
run_migration "$home" || fail "migration succeeds without the soft mixer"
[[ ! -e $home/.config/alsa-card-profile && ! -e $home/calls ]] || fail "migration skips installs without the soft mixer"
pass "migration skips installs without the soft mixer"

home=$(soft_mixer_home other)
run_migration "$home" ROG=0 || fail "migration succeeds on other machines"
[[ ! -e $home/.config/alsa-card-profile && ! -e $home/calls ]] || fail "migration leaves other machines alone"
pass "migration leaves other machines alone"
