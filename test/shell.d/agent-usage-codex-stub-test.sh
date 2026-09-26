#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

homes=()
cleanup() {
  rm -rf "${homes[@]}"
}
trap cleanup EXIT

new_home() {
  local home=$1
  homes+=("$home")
  mkdir -p "$home/bin" "$home/.local/bin" "$home/.local/share/mise/shims" "$home/real" "$home/.codex"
  cat >"$home/bin/mise" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"${MISE_LOG:?}"
if [[ $1 == which && $2 == codex && -n ${MISE_WHICH_PATH:-} ]]; then
  printf '%s\n' "$MISE_WHICH_PATH"
  exit 0
fi
exit 1
EOF
  chmod +x "$home/bin/mise"

  cat >"$home/real/codex" <<'EOF'
#!/bin/bash
if [[ -n ${CODEX_ARGS_FILE:-} ]]; then
  printf '%s\0' "$@" >"$CODEX_ARGS_FILE"
fi
while read -r request; do
  id=$(jq -r '.id // empty' <<<"$request")
  method=$(jq -r '.method // empty' <<<"$request")
  case "$method" in
    initialize) jq -cn --argjson id "$id" '{id: $id, result: {}}' ;;
    account/read) jq -cn --argjson id "$id" '{id: $id, result: {account: {}}}' ;;
    account/rateLimits/read) jq -cn --argjson id "$id" '{id: $id, result: {rateLimits: {}}}' ;;
  esac
done
EOF
  chmod +x "$home/real/codex"
}

write_launcher() {
  local home=$1
  cat >"$home/.local/bin/codex" <<'EOF'
#!/bin/bash
echo ran >>"${LAUNCHER_RAN:?}"
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g --quiet "codex" || exit 1
exec mise x "codex" -- "codex" "$@"
EOF
  chmod +x "$home/.local/bin/codex"
}

run_collector() {
  local home=$1
  HOME="$home" \
    CODEX_HOME="$home/.codex" \
    XDG_CACHE_HOME="$home/.cache" \
    XDG_DATA_HOME="$home/.local/share" \
    PATH="$home/bin:/usr/bin:/bin" \
    MISE_LOG="$home/mise.log" \
    LAUNCHER_RAN="$home/launcher-ran" \
    SHIM_RAN="$home/shim-ran" \
    CODEX_ARGS_FILE="$home/codex-args" \
    "$ROOT/bin/omarchy-agent-usage-codex"
}

# The launcher is the only codex on PATH, and mise has no install. The probe
# must report Codex missing without executing the launcher.
MISSING_HOME=$(mktemp -d)
new_home "$MISSING_HOME"
write_launcher "$MISSING_HOME"
result=$(run_collector "$MISSING_HOME")
[[ -f $MISSING_HOME/launcher-ran ]] && fail "Codex collector executed the mise launcher" "$(cat "$MISSING_HOME/launcher-ran")"
[[ $(jq -r '.usageStatusText' <<<"$result") == "Codex unavailable" ]] ||
  fail "Codex collector reports an uninstalled launcher as unavailable" "$result"
[[ $(jq -r '.authHelpText' <<<"$result") == "codex is not installed" ]] ||
  fail "Codex collector tells the panel the launcher is not an install" "$result"
pass "Codex collector does not run the mise launcher when Codex is not installed"

# mise which names the installed binary. The probe runs that binary and still
# does not run the launcher in front of it on PATH.
INSTALLED_HOME=$(mktemp -d)
new_home "$INSTALLED_HOME"
write_launcher "$INSTALLED_HOME"
result=$(MISE_WHICH_PATH="$INSTALLED_HOME/real/codex" run_collector "$INSTALLED_HOME")
[[ -f $INSTALLED_HOME/launcher-ran ]] && fail "Codex collector executed the launcher ahead of the installed binary" ""
[[ -f $INSTALLED_HOME/codex-args ]] || fail "Codex collector did not probe the installed binary" "$result"
mapfile -d '' -t codex_args <"$INSTALLED_HOME/codex-args"
expected_args=(-s read-only -a on-request app-server)
[[ ${codex_args[*]@Q} == "${expected_args[*]@Q}" ]] ||
  fail "Codex collector probes the installed binary with the app-server args" "${codex_args[*]@Q}"
pass "Codex collector probes the binary mise which reports"

# A symlink at the launcher path is the user's own install.
LINK_HOME=$(mktemp -d)
new_home "$LINK_HOME"
ln -s "$LINK_HOME/real/codex" "$LINK_HOME/.local/bin/codex"
result=$(run_collector "$LINK_HOME")
[[ -s $LINK_HOME/mise.log ]] && fail "Codex collector asked mise about a symlinked binary" "$(cat "$LINK_HOME/mise.log")"
[[ -f $LINK_HOME/codex-args ]] || fail "Codex collector did not probe the symlinked binary" "$result"
pass "Codex collector probes a symlink at the launcher path"

# A mise shim is a symlink to mise named for the tool. Running it installs.
SHIM_HOME=$(mktemp -d)
new_home "$SHIM_HOME"
cat >"$SHIM_HOME/.local/share/mise/shims/codex" <<'EOF'
#!/bin/bash
echo ran >>"${SHIM_RAN:?}"
exit 0
EOF
chmod +x "$SHIM_HOME/.local/share/mise/shims/codex"
result=$(run_collector "$SHIM_HOME")
[[ -f $SHIM_HOME/shim-ran ]] && fail "Codex collector executed a mise shim" "$(cat "$SHIM_HOME/shim-ran")"
[[ $(jq -r '.authHelpText' <<<"$result") == "codex is not installed" ]] ||
  fail "Codex collector treats a shim as not installed" "$result"
pass "Codex collector does not run a mise shim"
