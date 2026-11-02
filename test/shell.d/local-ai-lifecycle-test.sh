#!/bin/bash
# Legacy container names survive upgrades; new deployments cannot collide across users.
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
export OMARCHY_PATH=$ROOT
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
sed '/^paths "\$HOME"$/,$d' "${BACKEND:-$ROOT/bin/omarchy-local-ai}" >"$TMP/functions"
source "$TMP/functions"
ALLOCATION_LOCK=$TMP/docker.pid
: >"$ALLOCATION_LOCK"
paths "$TMP/home"
mkdir -p "$STATE/deploy/test"
echo '{}' >"$STATE/deploy/test/config.json"
[[ $(engine test) == omarchy-local-ai-test-engine ]]
for owner in 1000 1001; do
  printf '{"containerUid":%s}\n' "$owner" >"$STATE/deploy/test/config.json"
  export PKEXEC_UID=$owner
  [[ $(engine test) == "omarchy-local-ai-$owner-test-engine" && $(gateway test) == "omarchy-local-ai-$owner-test-gateway" && $(network test) == "omarchy-local-ai-$owner-test" ]] || exit 1
done
unset PKEXEC_UID
echo '{}' >"$STATE/deploy/test/config.json"
echo 'ok - legacy names persist and two users have different container and network names'
# A card can become allocated after the UI's check or while images download.
RECIPES=$TMP/recipes.json
echo '{"hardware":{"test":{"match":{"backend":"nvidia"}}},"gateway":{"image":"gateway"}}' >"$RECIPES"
recipe() { echo '{"hw":"test","cards":1,"image":"engine"}'; }
policy() { echo ok; }
nvidia_ready() { return 0; }
cdi_stale() { :; }
owned() { :; }
gpus() {
  if [[ -f $TMP/removed ]]; then
    echo '[{"key":"nvidia:0","hw":"test","held":true,"usedMiB":1}]'
  else
    echo '[{"key":"nvidia:0","hw":"test","held":false,"usedMiB":1}]'
  fi
}
remove() { touch "$TMP/removed"; }
docker() { case $1 in image) :;; info) echo NVIDIA;; *) touch "$TMP/launched"; return 99;; esac; }
if (phase_start test 12434 nvidia:0) >"$TMP/output" 2>&1; then exit 1; fi
grep -q 'nvidia:0 is in use by another program' "$TMP/output"
[[ ! -f $TMP/launched ]]
echo 'ok - launch rechecks allocations after downloads and before creating containers'

# A failed unshare must never expose a later model on this deployment's old URL.
echo '{"id":"test","port":12434,"shared":true}' >"$STATE/deploy/test/config.json"
echo '{"state":"ready"}' >"$STATE/deploy/test/status.json"
cmd_share() { return 1; }
elevate() { [[ $1 == stop && $3 == engine ]] && touch "$TMP/stopped"; }
if (cmd_stop test) >"$TMP/stop-output" 2>&1; then exit 1; fi
[[ -f $TMP/stopped && $(jq -r .port "$STATE/deploy/test/config.json") == 12434 ]]
cmd_share() { return 0; }
elevate() { [[ $1 == stop && -z $3 ]]; }
cmd_stop test
[[ ! -d $STATE/deploy/test ]]
echo 'ok - failed unsharing retains the stopped port until a successful retry'

# A failed privileged unshare retries against the retained gateway, not user-supplied port state.
source "$TMP/functions"
ALLOCATION_LOCK=$TMP/docker.pid
: >"$ALLOCATION_LOCK"
paths "$TMP/home"
mkdir -p "$STATE/deploy/test"
echo '{"port":12434,"shared":true}' >"$STATE/deploy/test/config.json"
echo '{"state":"ready"}' >"$STATE/deploy/test/status.json"
ours() { [[ $1 == *gateway || ! -f $TMP/engine-stopped ]]; }
docker() {
  case $1 in
    info) : ;;
    port) [[ ! -f $TMP/gateway-removed ]] && echo '12434/tcp -> 127.0.0.1:12434' ;;
    rm) [[ $* == *gateway* ]] && touch "$TMP/gateway-removed" || touch "$TMP/engine-stopped" ;;
    network) : ;;
    *) return 1 ;;
  esac
}
serve() { [[ -f $TMP/allow-unshare ]]; }
asroot() { "phase_$1" "${@:2}"; }
elevate() { "phase_$1" "${@:2}"; }
if (cmd_stop test) >"$TMP/retry-output" 2>&1; then exit 1; fi
[[ -f $TMP/engine-stopped && ! -f $TMP/gateway-removed && -d $STATE/deploy/test ]]
touch "$TMP/allow-unshare"
cmd_stop test
[[ -f $TMP/gateway-removed && ! -d $STATE/deploy/test ]]
echo 'ok - privileged Stop retry keeps gateway ownership and port evidence until unsharing succeeds'

# Separate users have separate state locks, but must serialize the shared GPU check and creation.
source "$TMP/functions"
ALLOCATION_LOCK=$TMP/docker.pid
: >"$ALLOCATION_LOCK"
paths "$TMP/home"
RECIPES=$TMP/recipes.json
recipe() { echo '{"hw":"test","cards":1,"image":"engine","weights":[],"launch":{"port":8080,"environment":{},"arguments":[]}}'; }
policy() { echo ok; }
cdi_stale() { :; }
owned() { :; }
remove() { :; }
gpus() { printf '[{"key":"nvidia:0","hw":"test","held":%s,"usedMiB":1}]\n' "$([[ -f $TMP/allocated ]] && echo true || echo false)"; }
docker() {
  case $1 in
    info) echo NVIDIA ;;
    run) if [[ $* == *-engine* ]]; then sleep 1; echo "$PKEXEC_UID" >>"$TMP/starts"; touch "$TMP/allocated"; fi ;;
  esac
}
rundir() { echo "$TMP/run/$1"; }
(export PKEXEC_UID=1000; phase_start first 12434 nvidia:0) >"$TMP/first" 2>&1 & first=$!
(export PKEXEC_UID=1001; phase_start second 12435 nvidia:0) >"$TMP/second" 2>&1 & second=$!
rc1=0; wait "$first" || rc1=$?
rc2=0; wait "$second" || rc2=$?
[[ $((rc1 + rc2)) == 1 && $(wc -l <"$TMP/starts") == 1 ]]
grep -q 'nvidia:0 is in use' "$TMP/first" "$TMP/second"
echo 'ok - simultaneous users start only one engine on the same GPU'
