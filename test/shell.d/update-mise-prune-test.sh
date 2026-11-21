#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_bin="$tmpdir/bin"
log="$tmpdir/mise.log"
tools_config="$tmpdir/omarchy-tools.toml"
mkdir -p "$stub_bin"

cat >"$tools_config" <<'TOML'
[tools]
claude = { version = "latest", lazy = true, auto_update = "4h", minimum_release_age = "0s" }
"npm:cf" = { version = "latest", lazy = true, lazy_bins = ["cf"], minimum_release_age = "0s" }
TOML

# Records each call with the cooldown it saw, and fails whichever step it is
# told to, so each failure can be checked to reach the update's result.
cat >"$stub_bin/mise" <<'SH'
#!/bin/bash

echo "MISE_MINIMUM_RELEASE_AGE=${MISE_MINIMUM_RELEASE_AGE:-unset} $*" >>"$OMARCHY_MISE_TEST_LOG"
[[ $1 == "${OMARCHY_MISE_TEST_FAIL:-}" ]] && exit 3
exit 0
SH
chmod +x "$stub_bin/mise"

run_update() {
  : >"$log"
  OMARCHY_MISE_TEST_LOG="$log" OMARCHY_MISE_CONFIG_PATH="$tools_config" PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-update-mise" >/dev/null
}

run_update ||
  fail "a successful tool update exits zero"
[[ $(cat "$log") == $'MISE_MINIMUM_RELEASE_AGE=0 up\nMISE_MINIMUM_RELEASE_AGE=unset prune --tools --yes claude npm:cf' ]] ||
  fail "the update upgrades past the cooldown, then prunes only Omarchy's tools without prompting: $(cat "$log")"

status=0
OMARCHY_MISE_TEST_FAIL=up run_update || status=$?
(( status == 3 )) ||
  fail "a failed upgrade is reported as the update's result, got $status"
grep -q ' prune --tools --yes claude npm:cf$' "$log" ||
  fail "a failed upgrade still prunes the versions already left behind"

status=0
OMARCHY_MISE_TEST_FAIL=prune run_update || status=$?
(( status == 3 )) ||
  fail "a failed prune after a successful upgrade is reported, got $status"

# With nothing declared, naming no tools would make mise prune every tool.
: >"$tools_config"
run_update ||
  fail "an update with no declared tools exits zero"
! grep -q ' prune' "$log" ||
  fail "an update with no declared tools prunes nothing: $(cat "$log")"

pass "omarchy-update-mise prunes Omarchy's unused tool versions after upgrading"
