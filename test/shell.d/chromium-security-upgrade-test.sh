#!/bin/bash

set -euo pipefail

# Chromium on stable can lag a frozen Omarchy mirror (#10732). Keep a helper
# that lifts installed builds to the CVE-2026-85046 floor from available repos.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-pkg-upgrade-chromium-security"
[[ -x $helper ]] || fail "omarchy-pkg-upgrade-chromium-security is executable"

grep -q '152.0.7977.82-1' "$helper" ||
  fail "helper pins Chromium 152.0.7977.82-1 as the security floor"

grep -q 'pacman -Si chromium' "$helper" ||
  fail "helper compares against the chromium version available in repos"

grep -q 'vercmp' "$helper" ||
  fail "helper compares installed vs floor with vercmp"

grep -q 'omarchy:requires-sudo=true' "$helper" ||
  fail "helper declares that it needs sudo"

grep -Eq 'exit 1' "$helper" ||
  fail "helper must fail when the floor is still unmet so migrations stay pending"

pass "Chromium security upgrade helper pins the CVE floor against available repos"

migration="$ROOT/migrations/1789400400.sh"
[[ -f $migration ]] || fail "a migration upgrades installed Chromium past the security floor"
grep -q 'omarchy-pkg-upgrade-chromium-security' "$migration" ||
  fail "migration calls the Chromium security upgrade helper"
[[ ! -x $migration ]] || fail "migration must be mode 0644, not executable"

pass "migration upgrades installed Chromium past the CVE floor"

# Exercise the behind-with-no-adequate-package case with PATH stubs.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
cat >"$tmp/bin/pacman" <<'EOF'
#!/bin/bash
set -euo pipefail
if [[ $1 == "-Q" && $2 == "chromium" ]]; then
  echo "chromium 151.0.0.0-1"
  exit 0
fi
if [[ $1 == "-Si" && $2 == "chromium" ]]; then
  echo "Version         : 151.0.0.0-1"
  exit 0
fi
echo "unexpected pacman: $*" >&2
exit 99
EOF
cat >"$tmp/bin/vercmp" <<'EOF'
#!/bin/bash
# Minimal vercmp: equal -> 0, otherwise compare as strings via sort -V.
python3 - "$1" "$2" <<'PY'
import sys
from functools import cmp_to_key

def dec(v):
  out = []
  for part in v.replace("-", ".").split("."):
    out.append(int(part) if part.isdigit() else part)
  return out

a, b = dec(sys.argv[1]), dec(sys.argv[2])
print(0 if a == b else (1 if a > b else -1))
PY
EOF
cat >"$tmp/bin/sudo" <<'EOF'
#!/bin/bash
echo "sudo should not run when repos lack a floor build" >&2
exit 97
EOF
chmod +x "$tmp/bin/pacman" "$tmp/bin/vercmp" "$tmp/bin/sudo"

status=0
PATH="$tmp/bin:/usr/bin:/bin" bash "$helper" >"$tmp/out" 2>&1 || status=$?
(( status == 1 )) || fail "helper exits 1 when repos lack a floor build" "status=$status out=$(cat "$tmp/out")"
grep -q 'Will retry' "$tmp/out" || fail "helper warns that it will retry" "$(cat "$tmp/out")"
pass "helper leaves the floor unmet when repos only offer an older chromium"
