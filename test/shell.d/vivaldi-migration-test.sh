#!/bin/bash

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1789981149.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin" "$test_dir/omarchy/default/vivaldi" "$test_dir/home"

cat >"$test_dir/bin/omarchy-pkg-present" <<'STUB'
#!/bin/bash
[[ ${VIVALDI_INSTALLED:-0} == 1 ]]
STUB

cat >"$test_dir/bin/omarchy-hook-install" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$HOOK_INSTALL_LOG"
STUB

cat >"$test_dir/omarchy/default/vivaldi/vivaldi-post-update" <<'STUB'
#!/bin/bash
printf 'ran\n' >"$POST_UPDATE_LOG"
exit "${POST_UPDATE_STATUS:-0}"
STUB

chmod +x "$test_dir/bin"/* "$test_dir/omarchy/default/vivaldi/vivaldi-post-update"

run_migration() {
  HOME="$test_dir/home" OMARCHY_PATH="$test_dir/omarchy" \
    PATH="$test_dir/bin:$PATH" HOOK_INSTALL_LOG="$test_dir/hook-install" \
    POST_UPDATE_LOG="$test_dir/post-update" \
    VIVALDI_INSTALLED="$1" POST_UPDATE_STATUS="${2:-0}" \
    bash -euo pipefail "$migration"
}

run_migration 0 || fail "migration succeeds without Vivaldi installed"
[[ ! -e $test_dir/hook-install && ! -e $test_dir/post-update ]] ||
  fail "migration leaves installs without Vivaldi alone"

run_migration 1 || fail "migration succeeds with Vivaldi installed"
[[ $(cat "$test_dir/hook-install" 2>/dev/null) == \
  "post-update $test_dir/omarchy/default/vivaldi/vivaldi-post-update" ]] ||
  fail "migration installs the post-update hook"
[[ -f $test_dir/post-update ]] || fail "migration re-injects the loader once"

# A failed repaint must not abort the migration queue or skip the marker.
rm -f "$test_dir/post-update"
run_migration 1 1 || fail "migration tolerates a failed Vivaldi repaint"
[[ -f $test_dir/post-update ]] ||
  fail "migration still runs the loader injection when the repaint fails"

pass "Vivaldi migration adopts existing installs"
