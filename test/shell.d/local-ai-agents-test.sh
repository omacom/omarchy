#!/bin/bash
# Agent settings and updater routing, without touching installed agents.
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
export OMARCHY_PATH=$ROOT
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
sed '/^paths "\$HOME"$/,$d' "${BACKEND:-$ROOT/bin/omarchy-local-ai}" >"$TMP/functions"
source "$TMP/functions"
paths "$TMP/home"
mkdir -p "$STATE/deploy/test"
printf '{"agent":"pi"}\n' >"$STATE/settings.json"
printf '{"agent":"pi"}\n' >"$STATE/deploy/test/config.json"
cmd_set agent claude test
[[ $(jq -r .agent "$STATE/settings.json") == pi ]] || { echo 'not ok - model selection changed the default'; exit 1; }
[[ $(jq -r .agent "$STATE/deploy/test/config.json") == claude ]] || exit 1
cmd_set agent codex
[[ $(jq -r .agent "$STATE/settings.json") == codex && $(jq -r .agent "$STATE/deploy/test/config.json") == claude ]] || exit 1
echo 'ok - model agent and default are explicit independent choices'
# The external commands are functions so their argv is captured without network or installation.
export UPDATE_ARGS=$TMP/args
bin() { echo "$1"; }
omarchy-cmd-present() { [[ $1 == mise ]]; }
mise() {
  if [[ $1 == ls ]]; then
    [[ $* == *oh-my-pi* ]] && echo '[]' || echo '[{"installed":true}]'
  else printf '%s\n' "$*" >>"$UPDATE_ARGS"; fi
}
timeout() { shift; "$@"; }
omp() { printf 'omp %s\n' "$*" >>"$UPDATE_ARGS"; }
for a in pi claude codex opencode omp crush grok copilot hermes; do cmd_update "$a"; done
grep -qx -- '--yes upgrade --bump pi' "$UPDATE_ARGS"
grep -qx -- '--yes upgrade --bump npm:@xai-official/grok' "$UPDATE_ARGS"
grep -qx -- '--yes upgrade --bump pipx:hermes-agent\[extras=all\]' "$UPDATE_ARGS"
grep -qx -- 'omp update' "$UPDATE_ARGS"
[[ $(wc -l <"$UPDATE_ARGS") == 9 ]]
if (cmd_update 'pi;touch bad') >/dev/null 2>&1; then echo 'not ok - unknown updater accepted'; exit 1; fi
mise() { [[ $1 == ls ]] && echo '[{"installed":true}]' || return 1; }
if (cmd_update pi) >/dev/null 2>&1; then echo 'not ok - updater failure reported success'; exit 1; fi
echo 'ok - all nine update routes are scoped and updater failures stay failures'
