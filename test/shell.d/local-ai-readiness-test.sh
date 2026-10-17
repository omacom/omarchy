#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
# Exercise the actual worker with no GPU, network, privileges or waiting.
eval "$(sed -n '/^worker_run() {/,/^cmd_run() {/p' "$ROOT/bin/omarchy-local-ai" | sed '$d')"
recipe() { echo '{"name":"Test","sizeGb":1,"weights":[]}'; }
dir_of() { echo "$TMP/deploy"; }
status() { echo "$2" >"$TMP/state"; }
notify() { echo 0; }
gpus() { echo '[]'; }
elevate() { echo "$1" >>"$TMP/phases"; }
omarchy-sudo-docker() { return 1; }
fail() { elevate stop; echo "$*" >"$TMP/error"; exit 1; }
date() {
  if [[ $1 == +%s%3N ]]; then
    if [[ -f $TMP/clock ]]; then echo 70000; else touch "$TMP/clock"; echo 0; fi
  else command date "$@"; fi
}
curl() {
  if [[ $* == *chat/completions* ]]; then
    echo "$REPLY_FIXTURE"
  elif [[ $* == *http_code* ]]; then
    echo '{"data":[{"id":"test"}]}' >"$TMP/deploy/models.json"
    printf 200
  else return 22; fi
}
HOME_DIR=$TMP/home
STATE=$TMP/state-dir
KEY=$STATE/gateway.key
AUTH=$STATE/gateway.auth
mkdir -p "$HOME_DIR" "$STATE" "$TMP/deploy"
head -c 32 /dev/urandom >"$KEY"
echo '{"port":12434}' >"$TMP/deploy/config.json"
REPLY_FIXTURE='{"choices":[{"message":{"content":"1, 2, 3"}}],"usage":{"completion_tokens":200}}'
(worker_run test nvidia:0)
[[ $(cat "$TMP/state") == ready && $(cat "$TMP/phases") == start ]]
pass "local-ai a cold successful completion reaches ready without a throughput gate"
REPLY_FIXTURE='{"choices":[{"message":{"content":null,"reasoning":"The user wants 1 to 60."},"finish_reason":"length"}],"usage":{"completion_tokens":200}}'
echo starting >"$TMP/state"
(worker_run test nvidia:0)
[[ $(cat "$TMP/state") == ready && $(tail -1 "$TMP/phases") == start ]]
pass "local-ai an answer that is all thinking, in vLLM's reasoning field, counts as an answer"
REPLY_FIXTURE='{}'
# Preserve errexit inside the subshell rather than putting the worker in an if condition.
set +e
(set -e; worker_run test nvidia:0)
rc=$?
set -e
[[ $rc != 0 && $(cat "$TMP/error") == "the model returned no answer" && $(tail -1 "$TMP/phases") == stop ]]
pass "local-ai an empty completion fails readiness and stops the containers"

# Reuse the backend matcher against the bundled recipe instead of restating its rules.
eval "$(sed -n '/^MATCH=/,/^$/p' "$ROOT/bin/omarchy-local-ai")"
jq -ne --slurpfile rec "$ROOT/shell/plugins/panels/local-ai/recipes.json" "$MATCH"'
  [{backend:"amd-rocm",index:0,product:"AMD Radeon RX 9070 XT",totalMiB:16368}]
  | match($rec[0]) | .[0].hw == "rx-9070-xt-16gb"' >/dev/null
pass "local-ai AMD detection matches bundled Vulkan recipes"
