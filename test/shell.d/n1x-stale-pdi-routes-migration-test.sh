#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1792634594.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/proc/asound"

# The card's live routes live in one file per control; a missing directory is
# a missing card, and the kernel's /proc/asound link to it dangles.
ln -s ../../mixer "$test_tmp/proc/asound/mt8901soundwire"

cat >"$test_tmp/bin/amixer" <<'SH'
#!/bin/bash
[[ $1 == "-q" ]] && shift
[[ $1 == "-c" && $2 == "mt8901soundwire" && -d $MIXER && ${NO_SEAT:-0} == 0 ]] || exit 1
case $3 in
  info) ;;
  sget) printf "Simple mixer control '%s',0\n  Item0: '%s'\n" "$4" "$(cat "$MIXER/$4")" ;;
  cset) name=${4#name=}; printf '%s\n' "$5" >"$MIXER/$name"; printf '%s=%s\n' "$name" "$5" >>"$LOG" ;;
esac
SH

# alsactl store writes the live routes in asound.state's layout, unless the
# password prompt is cancelled.
cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
[[ ${SUDO_FAIL:-0} == 1 ]] && exit 1
printf 'sudo %s\n' "$*" >>"$LOG"
if [[ $* == "alsactl store mt8901soundwire" ]]; then
  {
    echo "state.mt8901soundwire {"
    for control in "$MIXER"/*; do
      printf "\tcontrol.1 {\n\t\tiface MIXER\n\t\tname '%s'\n\t\tvalue %s\n\t}\n" "${control##*/}" "$(cat "$control")"
    done
    echo "}"
  } >"$ALSA_STATE"
fi
SH

cat >"$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$LOG"
SH

cat >"$test_tmp/bin/omarchy-hw-aarch64-n1x" <<'SH'
#!/bin/bash
[[ $N1X == 1 ]]
SH

chmod +x "$test_tmp/bin/"*

# Sets the live routes and saves the same ones, as a boot's alsactl restore leaves them.
set_routes() {
  rm -rf "$test_tmp/mixer"
  mkdir -p "$test_tmp/mixer"
  local route
  for route in "$@"; do
    printf '%s\n' "${route#*=}" >"$test_tmp/mixer/${route%%=*}"
  done
  : >"$test_tmp/log"
  MIXER="$test_tmp/mixer" LOG="$test_tmp/log" ALSA_STATE="$test_tmp/asound.state" \
    "$test_tmp/bin/sudo" alsactl store mt8901soundwire
}

route() {
  cat "$test_tmp/mixer/$1"
}

saved() {
  grep -A1 -F "name '$1'" "$test_tmp/asound.state" | sed -n 's/^\t\tvalue //p'
}

run_migration() {
  : >"$test_tmp/log"
  N1X=${N1X:-1} MIXER="$test_tmp/mixer" LOG="$test_tmp/log" ALSA_STATE="$test_tmp/asound.state" \
    OMARCHY_ALSA_STATE="$test_tmp/asound.state" OMARCHY_PROC_ROOT="$test_tmp/proc" PATH="$test_tmp/bin:$PATH" \
    bash -euo pipefail "$migration" >/dev/null
}

# ASUS ProArt P14: the retired profile routed PDI2 to DP3 and PDI7/PDI8 to DP8/DP7.
proart_leftovers=("PDI2 Demux=DP3" "PDI3 Demux=DP3" "PDI7 Mux=DP8" "PDI8 Mux=DP7" "PDI13 Mux=DP7")

set_routes "${proart_leftovers[@]}"
run_migration
[[ $(route "PDI2 Demux") == "None" && $(route "PDI7 Mux") == "None" && $(route "PDI8 Mux") == "None" ]] ||
  fail "the migration clears the ProArt P14 leftovers" "$(cat "$test_tmp/log")"
[[ $(route "PDI3 Demux") == "DP3" && $(route "PDI13 Mux") == "DP7" ]] ||
  fail "the migration keeps the routes the current profile sets"
[[ $(saved "PDI2 Demux") == "None" && $(saved "PDI7 Mux") == "None" && $(saved "PDI8 Mux") == "None" ]] ||
  fail "the migration saves the cleared routes" "$(cat "$test_tmp/asound.state")"
grep -qxF "systemctl --user try-restart wireplumber.service" "$test_tmp/log" ||
  fail "the migration has WirePlumber probe the card again" "$(cat "$test_tmp/log")"
pass "the migration clears the ProArt P14 leftovers, saves them and reprobes the card"

run_migration
[[ ! -s $test_tmp/log ]] || fail "the migration does nothing on a second run" "$(cat "$test_tmp/log")"
pass "the migration does nothing once the routes are clean"

# A cancelled password prompt fails the run after the live routes are cleared;
# the retry still has to save them and reprobe the card.
set_routes "${proart_leftovers[@]}"
if SUDO_FAIL=1 run_migration 2>/dev/null; then
  fail "the migration fails when the save fails"
fi
[[ $(route "PDI2 Demux") == "None" && $(saved "PDI2 Demux") == "DP3" ]] ||
  fail "the failed run leaves the live routes cleared and the saved ones stale"
run_migration
[[ $(saved "PDI2 Demux") == "None" && $(saved "PDI7 Mux") == "None" && $(saved "PDI8 Mux") == "None" ]] ||
  fail "the retry saves the routes the failed run cleared" "$(cat "$test_tmp/asound.state")"
grep -qxF "systemctl --user try-restart wireplumber.service" "$test_tmp/log" ||
  fail "the retry has WirePlumber probe the card again" "$(cat "$test_tmp/log")"
pass "the migration stays pending until the cleared routes are saved"

# Dell XPS 16: the retired profile routed PDI7/PDI8 to DP12/DP13; PDI2 to DP2 is
# still what the current profile sets.
set_routes "PDI2 Demux=DP2" "PDI7 Mux=DP12" "PDI8 Mux=DP13" "PDI13 Mux=DP13"
run_migration
[[ $(route "PDI7 Mux") == "None" && $(route "PDI8 Mux") == "None" ]] ||
  fail "the migration clears the XPS 16 leftovers" "$(cat "$test_tmp/log")"
[[ $(route "PDI2 Demux") == "DP2" && $(route "PDI13 Mux") == "DP13" ]] ||
  fail "the migration keeps the XPS 16's current routes"
pass "the migration clears the XPS 16 leftovers and keeps its current routes"

set_routes "${proart_leftovers[@]}"
N1X=0 run_migration
[[ ! -s $test_tmp/log && $(route "PDI2 Demux") == "DP3" ]] ||
  fail "the migration leaves other machines alone" "$(cat "$test_tmp/log")"
pass "the migration leaves other machines alone"

# Without the seat's ACL (an update over SSH) amixer can't open the card; the
# run must fail and stay pending rather than complete with the routes stale.
set_routes "${proart_leftovers[@]}"
if NO_SEAT=1 run_migration 2>/dev/null; then
  fail "the migration fails when it can't open a present card"
fi
[[ ! -s $test_tmp/log && $(saved "PDI2 Demux") == "DP3" ]] ||
  fail "the migration changes nothing when it can't open the card" "$(cat "$test_tmp/log")"
pass "the migration stays pending when it can't open the card"

rm -rf "$test_tmp/mixer"
run_migration
[[ ! -s $test_tmp/log ]] || fail "the migration skips a missing card" "$(cat "$test_tmp/log")"
pass "the migration skips a missing card"
