#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d "${TMPDIR:-/var/tmp}/ttfx-test.XXXXXXXX")
printf 'Test fixtures: %s\n' "$tmp_dir"
fake_bin="$tmp_dir/bin"
options_file="$tmp_dir/options"
mkdir -p "$fake_bin"

cat >"$fake_bin/omarchy-plymouth-effect-set" <<'SH'
#!/bin/bash
[[ ${1:-} == current ]] || exit 2
printf '%s\n' "${TEST_CURRENT:-errorcorrect}"
SH
cat >"$fake_bin/omarchy-plymouth-effect-list" <<'SH'
#!/bin/bash
printf '%s\n' decrypt errorcorrect sweep
SH
cat >"$fake_bin/omarchy-menu-select" <<'SH'
#!/bin/bash
cat >"$TEST_OPTIONS_FILE"
printf 'Errorcorrect\n'
SH
chmod +x "$fake_bin"/*

selection=$(PATH="$fake_bin:$PATH" TEST_OPTIONS_FILE="$options_file" \
  "$ROOT/bin/omarchy-plymouth-effect-switcher")
[[ $selection == errorcorrect ]] || fail "effect switcher returns the selected key" "got: $selection"
pass "effect switcher returns the selected key"

first=$(sed -n '1p' "$options_file")
[[ $first == $'✓\tErrorcorrect' ]] ||
  fail "effect switcher puts the checked current effect first" "got: $first"
pass "effect switcher puts the checked current effect first"

[[ $(sed -n '2p' "$options_file") == $'·\tRandom' ]] ||
  fail "effect switcher keeps Random after the current effect"
! grep -F $'\tOff' "$options_file" >/dev/null || fail "effect switcher removes Off"
pass "effect switcher keeps alternatives without Off"

PATH="$fake_bin:$PATH" TEST_CURRENT=off TEST_OPTIONS_FILE="$options_file" \
  "$ROOT/bin/omarchy-plymouth-effect-switcher" >/dev/null
[[ $(sed -n '1p' "$options_file") == $'✓\tDecrypt' ]] ||
  fail "legacy Off state is presented as the Decrypt default"
! grep -F $'\tOff' "$options_file" >/dev/null || fail "legacy Off state does not restore Off"
pass "effect switcher defaults legacy Off state to Decrypt"
