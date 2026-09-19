#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
migration="$ROOT/migrations/1787494718.sh"
grep -qx 'authfile=/etc/fido2/fido2' "$migration" || fail "FIDO2 authfile is not fixed"
grep -Fq '/usr/share/omarchy/migrations/1787494718.sh --machine' "$migration" || fail "FIDO2 migration lacks fixed machine phase"
grep -Fq '/usr/bin/install -T -m 644 -o root -g root "$authfile" "$stage"' "$migration" || fail "FIDO2 repair does not replace ownership atomically"
grep -Fq '/usr/bin/mv -Tf "$stage" "$authfile"' "$migration" || fail "FIDO2 repair does not publish atomically"
pass "FIDO2 repair uses a fixed target and atomic packaged machine phase"
