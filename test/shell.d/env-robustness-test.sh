#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-channel-current and omarchy-audio-tuning run under `set -u`, so a bare
# $OMARCHY_PATH dereference crashes with "unbound variable" when the variable is
# missing from the environment. Both now default it; run them with `env -i` to
# keep it that way.

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/home"

# A stub pacman sends channel detection to its package-backed "unknown" branch
# deterministically on any machine.
cat >"$tmp_dir/bin/pacman" <<'STUB'
#!/bin/bash
exit 1
STUB
chmod +x "$tmp_dir/bin/pacman"

bare_env() {
  env -i PATH="$tmp_dir/bin:/usr/bin:/bin" HOME="$tmp_dir/home" "$@"
}

out=$(bare_env "$ROOT/bin/omarchy-channel-current" 2>&1) || true
[[ $out != *"unbound variable"* ]] ||
  fail "omarchy-channel-current crashes on unset OMARCHY_PATH" "$out"
[[ $out == "unknown" ]] ||
  fail "omarchy-channel-current answers with the package-backed channel" "$out"
pass "omarchy-channel-current runs without OMARCHY_PATH in the environment"

out=$(bare_env "$ROOT/bin/omarchy-audio-tuning" status 2>&1) || true
[[ $out != *"unbound variable"* ]] ||
  fail "omarchy-audio-tuning crashes on unset OMARCHY_PATH" "$out"
[[ $out == *"Installed:    no"* ]] ||
  fail "omarchy-audio-tuning status reports its tuning state" "$out"
pass "omarchy-audio-tuning status runs without OMARCHY_PATH in the environment"
