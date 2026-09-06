#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

hooks_dir="$ROOT/default/systemd/system-sleep"

# systemd-sleep only runs executable files from system-sleep directories, so a
# hook shipped without the bit is dead on arrival wherever it is copied with -p.
for hook in keyboard-backlight force-igpu unmount-fuse; do
  [[ -x $hooks_dir/$hook ]] || fail "$hook is executable in the repo"
  bash -n "$hooks_dir/$hook" || fail "$hook parses"
  pass "$hook is an executable, parseable sleep hook"
done

# The installers must set the mode themselves rather than trust the source file.
for script in omarchy-hibernation-setup omarchy-toggle-hybrid-gpu; do
  if grep -q 'cp -p .*system-sleep' "$ROOT/bin/$script"; then
    fail "$script installs sleep hooks with install -m755, not cp -p"
  fi
  pass "$script installs sleep hooks with an explicit mode"
done

# The migration repairs copies that earlier releases left without the bit, and
# leaves everything else alone.
mkdir -p "$tmp_dir/system-sleep"
install -m644 "$hooks_dir/keyboard-backlight" "$tmp_dir/system-sleep/keyboard-backlight"
install -m644 /dev/null "$tmp_dir/system-sleep/unrelated"

OMARCHY_SYSTEM_SLEEP_DIR="$tmp_dir/system-sleep" bash -euo pipefail "$ROOT/migrations/1788695343.sh" >/dev/null ||
  fail "migration completes on a 644 hook"
[[ -x $tmp_dir/system-sleep/keyboard-backlight ]] || fail "migration makes keyboard-backlight executable"
[[ ! -x $tmp_dir/system-sleep/unrelated ]] || fail "migration leaves other files alone"
pass "migration makes an existing 644 keyboard-backlight hook executable"

OMARCHY_SYSTEM_SLEEP_DIR="$tmp_dir/system-sleep" bash -euo pipefail "$ROOT/migrations/1788695343.sh" >/dev/null ||
  fail "migration is idempotent"
pass "migration is a no-op the second time"

rm -rf "$tmp_dir/system-sleep"
OMARCHY_SYSTEM_SLEEP_DIR="$tmp_dir/system-sleep" bash -euo pipefail "$ROOT/migrations/1788695343.sh" >/dev/null ||
  fail "migration completes with no hooks installed"
pass "migration completes with no hooks installed"
