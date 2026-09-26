#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
for command in omarchy-hw-imac-cs4208 omarchy-pkg-add systemctl amixer; do
  printf '#!/bin/bash\nprintf "%%s\\n" "$0 $*" >> "$TEST_LOG"\n' >"$scratch/bin/$command"
done
# Use a synthetic mixer; every mixer command is logged by the stub.
printf '#!/bin/bash\necho "card 1: PCH device 0: CS4208 Analog"\n' >"$scratch/bin/aplay"
chmod +x "$scratch/bin/"*
export OMARCHY_PATH="$ROOT" OMARCHY_INSTALL="$ROOT/install"
export PATH="$scratch/bin:$PATH" TEST_LOG="$scratch/events"
export OMARCHY_MACBOOK12_AUDIO_MODEL=MacBook10,1
for variant in macbook imac; do
  export XDG_CONFIG_HOME="$scratch/$variant/config" XDG_STATE_HOME="$scratch/$variant/state"
  mkdir -p "$XDG_STATE_HOME/wireplumber"
  echo custom-route >"$XDG_STATE_HOME/wireplumber/default-routes"
  if [[ $variant == macbook ]]; then
    leaf="$ROOT/install/user/hardware/apple/fix-cs4208-audio.sh"
    name=51-macbook-cs4208-softvol.conf
  else
    leaf="$ROOT/install/user/hardware/apple/fix-imac-cs4208-speakers.sh"
    name=imac-cs4208-speakers.conf
  fi
  bash -euo pipefail -c 'source "$1"' bash "$leaf"
  [[ $(cat "$XDG_STATE_HOME/wireplumber/default-routes.pre-omarchy-cs4208") == custom-route ]] || fail "$variant routes are backed up"
  echo new-route >"$XDG_STATE_HOME/wireplumber/default-routes"
  bash -euo pipefail -c 'source "$1"' bash "$leaf"
  [[ $(cat "$XDG_STATE_HOME/wireplumber/default-routes") == new-route ]] || fail "$variant repeat setup preserves new routes"
  config="$XDG_CONFIG_HOME/wireplumber/wireplumber.conf.d/$name"
  echo '# custom' >>"$config"
  cp "$config" "$scratch/expected"
  if bash -euo pipefail -c 'source "$1"' bash "$leaf" 2>/dev/null; then fail "$variant custom config requires reconciliation"; fi
  cmp "$config" "$scratch/expected" || fail "$variant custom config survives"
  [[ $(cat "$XDG_STATE_HOME/wireplumber/default-routes") == new-route ]] || fail "$variant custom routes survive"
done
pass "both audio paths preserve custom configurations, back up routes, and leave repeat setup unchanged"

export OMARCHY_SYSTEMD_DIR="$scratch/systemd"
mkdir -p "$OMARCHY_SYSTEMD_DIR"
echo custom-service >"$OMARCHY_SYSTEMD_DIR/omarchy-cs4208-audio.service"
: >"$TEST_LOG"
if bash -euo pipefail -c 'source "$1"' bash "$ROOT/install/hardware/apple/fix-cs4208-audio.sh" 2>/dev/null; then fail "custom service requires reconciliation"; fi
[[ $(cat "$OMARCHY_SYSTEMD_DIR/omarchy-cs4208-audio.service") == custom-service && ! -s $TEST_LOG ]] || fail "custom service is preserved before package and system changes"
export XDG_CONFIG_HOME="$scratch/migration/config" XDG_STATE_HOME="$scratch/migration/state"
if bash -euo pipefail "$ROOT/migrations/1789869577.sh" 2>/dev/null; then fail "migration reports custom service"; fi
[[ ! -e $XDG_CONFIG_HOME && ! -s $TEST_LOG ]] || fail "migration preflight preserves all custom state"
pass "audio setup and migration preserve customized system services before making changes"
