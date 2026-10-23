#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home"
mkdir -p "$HOME/.local/bin" "$test_tmp/bin"
wrapper="$HOME/.local/bin/grok"
export OMARCHY_TEST_MISE_LOG="$test_tmp/mise.log"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

cat >"$test_tmp/bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_MISE_LOG"
if [[ $1 == "ls" ]]; then
  printf '%s\n' 'npm:@xai-official/grok  1.0.44'
fi
SH
cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "mise" ]]
SH
cat >"$test_tmp/bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ $1 == "grok" ]]
SH
chmod +x "$test_tmp/bin"/*

run_migration() {
  bash -euo pipefail "$ROOT/migrations/1790863209.sh" >/dev/null
}

printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "npm:@xai-official/grok" || exit 1\nexec mise x "npm:@xai-official/grok" -- "grok" "$@"\n' >"$wrapper"
chmod +x "$wrapper"
cp "$wrapper" "$test_tmp/old-wrapper"
cat >"$test_tmp/bin/omarchy-mise-install" <<'SH'
#!/bin/bash
exit 37
SH
chmod +x "$test_tmp/bin/omarchy-mise-install"
if run_migration; then
  fail "Grok migration reports a failed first-party launcher install"
fi
cmp -s "$wrapper" "$test_tmp/old-wrapper" || fail "Grok migration restores the old wrapper after install failure"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Grok migration keeps the old npm tool after install failure"
[[ -z $(find "$HOME/.local/bin" -name '.grok-wrapper.*' -print) ]] || fail "Grok migration cleans up the temporary backup after restoration"
rm "$test_tmp/bin/omarchy-mise-install"
pass "Grok migration restores the old wrapper when installation fails"

run_migration
grep -Fx 'mise use -g --quiet "grok" || exit 1' "$wrapper" >/dev/null ||
  fail "Grok migration replaces the old generated wrapper with the first-party package"
grep -Fx 'unuse -y -g npm:@xai-official/grok' "$OMARCHY_TEST_MISE_LOG" >/dev/null ||
  fail "Grok migration removes the old npm tool after installing the new wrapper"
[[ -z $(find "$HOME/.local/bin" -name '.grok-wrapper.*' -print) ]] || fail "Grok migration removes the temporary backup after installation"
pass "Grok migration replaces its generated npm wrapper"

printf '#!/bin/bash\nmise use -g "npm:@xai-official/grok" || exit 1\nexec mise x "npm:@xai-official/grok" -- "grok" "$@"\n' >"$wrapper"
run_migration
grep -Fx 'mise use -g --quiet "grok" || exit 1' "$wrapper" >/dev/null ||
  fail "Grok migration replaces an older generated wrapper"
pass "Grok migration recognizes the older generated wrapper"

printf '#!/bin/bash\n# My launcher uses npm:@xai-official/grok\nexec mise x "npm:@xai-official/grok" -- "grok" "$@"\n' >"$wrapper"
cp "$wrapper" "$test_tmp/custom"
: >"$OMARCHY_TEST_MISE_LOG"
run_migration
cmp -s "$wrapper" "$test_tmp/custom" || fail "Grok migration changes a custom launcher"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Grok migration removes a tool used by a custom launcher"
pass "Grok migration leaves a custom npm launcher and its tool in place"

printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "npm:@xai-official/grok" || exit 1\nexec mise x "npm:@xai-official/grok" -- "grok" "$@"\n\0' >"$wrapper"
cp "$wrapper" "$test_tmp/modified"
run_migration
cmp -s "$wrapper" "$test_tmp/modified" || fail "Grok migration replaces a modified generated-looking launcher"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Grok migration removes the tool used by a modified launcher"
pass "Grok migration preserves a modified generated-looking launcher"
