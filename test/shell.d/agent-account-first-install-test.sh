#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/home"
export INSTALL_LOG="$scratch/log" TEST_AGENT="$scratch/agent"
cat >"$scratch/bin/mise" <<'SH'
#!/bin/bash
printf '%s:%s\n' "$1" "${MISE_MINIMUM_RELEASE_AGE-unset}" >>"$INSTALL_LOG"
if [[ $1 == "which" ]]; then printf '%s\n' "$TEST_AGENT"; fi
SH
cat >"$scratch/bin/omarchy-mise-default-tools" <<'SH'
#!/bin/bash
[[ $TEST_DECLARED == "yes" ]]
SH
printf '#!/bin/bash\nprintf "agent:%%s\\n" "$GROK_HOME" >>"$INSTALL_LOG"\n' >"$TEST_AGENT"
chmod +x "$scratch/bin/"* "$TEST_AGENT"
for declared in yes no; do
  for age in unset 86400 0; do
    : >"$INSTALL_LOG"
    settings=(env -u MISE_MINIMUM_RELEASE_AGE HOME="$scratch/home" GROK_HOME="$scratch/account" TEST_DECLARED="$declared" PATH="$scratch/bin:/usr/bin:/bin")
    [[ $age == "unset" ]] || settings+=(MISE_MINIMUM_RELEASE_AGE="$age")
    "${settings[@]}" "$ROOT/bin/omarchy-agent-account-exec" grok || fail "first-run dispatch succeeds"
    if [[ $declared == "yes" ]]; then install=install; else install=use; fi
    grep -qx "$install:$age" "$INSTALL_LOG" && grep -qx "which:$age" "$INSTALL_LOG" || fail "install and resolution preserve the configured cooldown" "$(cat "$INSTALL_LOG")"
    grep -qx "agent:$scratch/account" "$INSTALL_LOG" || fail "the installed agent uses the chosen account"
  done
done
pass "both first-run paths preserve configured, unset and explicitly disabled release cooldowns"
