#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/apple/fix-thunderbolt-suspend.sh"

bash -n "$setup" || fail "MacBookPro14,1 Thunderbolt setup has valid syntax"
bash -n "$ROOT/migrations/1788921301.sh" || fail "MacBookPro14,1 Thunderbolt migration has valid syntax"
grep -Fxq 'run_logged "$OMARCHY_INSTALL/hardware/apple/fix-thunderbolt-suspend.sh"' "$ROOT/install/hardware/all.sh" ||
  fail "MacBookPro14,1 Thunderbolt setup runs with the other hardware scripts"

# The installer is offline, so the ISO's mirror must carry what the setup adds.
packages=$(sed -n 's/^ *omarchy-pkg-add //p' "$setup")
[[ -n $packages ]] || fail "MacBookPro14,1 Thunderbolt setup adds its packages"
for package in $packages; do
  grep -Fxq "$package" "$ROOT/install/omarchy-other.packages" ||
    fail "the ISO can supply $package offline"
done

pass "MacBookPro14,1 Thunderbolt setup installs only what the offline ISO carries"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# Chatty like real lspci: keep writing past the pipe buffer after the match, so
# a grep -q gate would kill it with SIGPIPE and pipefail would skip the fix.
cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
echo '06:00.0 0604: 8086:1578 (rev 06)'
for _ in {1..4096}; do
  echo '02:00.0 0600: ffff:0000'
done
SH

for stub in omarchy-pkg-add sudo limine-mkinitcpio; do
  printf '#!/bin/bash\necho "%s $*" >>"$TEST_LOG"\n' "$stub" >"$stub_bin/$stub"
done
printf '#!/bin/bash\n[[ $1 == "MacBookPro14,1" ]]\n' >"$stub_bin/omarchy-hw-match"
chmod +x "$stub_bin"/*

# omarchy-migrate runs every migration with bash -euo pipefail.
TEST_LOG="$test_tmp/calls.log" PATH="$stub_bin:$PATH" \
  bash -euo pipefail "$ROOT/migrations/1788921301.sh" </dev/null >/dev/null
grep -Fxq 'omarchy-pkg-add linux-headers tb-ar-shim-dkms' "$test_tmp/calls.log" ||
  fail "the migration fixes a MacBookPro14,1 under the runner's pipefail" "$(cat "$test_tmp/calls.log" 2>&1)"
pass "the migration fixes a MacBookPro14,1 under the runner's pipefail"
