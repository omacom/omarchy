#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fix="$ROOT/install/hardware/apple/fix-cirrus-speakers.sh"
migration="$ROOT/migrations/1788959623.sh"

grep -Fq 'snd-hda-macbookpro-dkms-git' "$fix" ||
  fail "Cirrus setup installs the out-of-tree codec DKMS package"
grep -Fq 'run_logged "$OMARCHY_INSTALL/hardware/apple/fix-cirrus-speakers.sh"' "$ROOT/install/hardware/all.sh" ||
  fail "Cirrus setup is dispatched from install/hardware/all.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
if (( ${T2_HARDWARE:-0} == 1 )); then
  echo '01:00.0 Bridge [0680]: Apple Inc. T2 Security Chip [106b:1801]'
fi
for _ in {1..4096}; do
  echo '02:00.0 Host bridge [0600]: Filler Device [ffff:0000]'
done
SH

cat >"$stub_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
(( ${DKMS_INSTALLED:-0} == 1 ))
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'omarchy-pkg-add\t%s\n' "$*" >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

run_migration() {
  : >"$calls"
  PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    OMARCHY_DMI_PRODUCT_NAME="$1" T2_HARDWARE="${2:-0}" DKMS_INSTALLED="${3:-0}" \
    bash -euo pipefail "$migration" >/dev/null
}

for model in MacBookPro13,2 MacBookPro13,3 MacBookPro14,2 MacBookPro14,3; do
  run_migration "$model"
  grep -Fq $'omarchy-pkg-add\tsnd-hda-macbookpro-dkms-git' "$calls" ||
    fail "Cirrus migration installs the codec fix on $model"
done

for model in MacBookPro13,1 MacBookPro14,1 MacBookPro15,2 "MacBookAir8,1" "Precision 5540"; do
  run_migration "$model"
  [[ ! -s $calls ]] || fail "Cirrus migration ignores $model" "$(cat "$calls")"
done

run_migration MacBookPro14,3 1
[[ ! -s $calls ]] || fail "Cirrus migration defers to fix-t2.sh on T2 hardware" "$(cat "$calls")"

run_migration MacBookPro14,3 0 1
[[ ! -s $calls ]] || fail "Cirrus migration is idempotent once the package is installed" "$(cat "$calls")"

pass "Cirrus CS8409 speaker fix targets only pre-T2 Touch Bar MacBooks"
