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
  echo "chromium $(cat "$TEST_INSTALLED_FILE")"
  exit 0
fi
if [[ $1 == "-Si" && $2 == "chromium" ]]; then
  if [[ ${TEST_NO_PACKAGE:-0} == 1 ]]; then exit 1; fi
  if [[ ${LC_ALL:-} == C ]]; then
    echo "Version         : ${TEST_AVAILABLE:-151.0.0.0-1}"
  else
    echo "Versión         : 151.0.0.0-1"
  fi
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
if [[ ${TEST_UPGRADE_ALLOWED:-0} != 1 ]]; then
  echo "sudo should not run when repos lack a floor build" >&2
  exit 97
fi
[[ $* == "pacman -S --noconfirm chromium" ]] || exit 98
printf '%s\n' "$*" >>"$TEST_UPGRADE_LOG"
printf '%s\n' "${TEST_AFTER_UPGRADE:-152.0.7977.82-1}" >"$TEST_INSTALLED_FILE"
EOF
chmod +x "$tmp/bin/pacman" "$tmp/bin/vercmp" "$tmp/bin/sudo"

export TEST_INSTALLED_FILE="$tmp/installed" TEST_UPGRADE_LOG="$tmp/upgrades"
printf '%s\n' '151.0.0.0-1' >"$TEST_INSTALLED_FILE"
status=0
PATH="$tmp/bin:/usr/bin:/bin" bash "$helper" >"$tmp/out" 2>&1 || status=$?
(( status == 1 )) || fail "helper exits 1 when repos lack a floor build" "status=$status out=$(cat "$tmp/out")"
grep -q 'Will retry' "$tmp/out" || fail "helper warns that it will retry" "$(cat "$tmp/out")"
pass "helper leaves the floor unmet when repos only offer an older chromium"

status=0
TEST_NO_PACKAGE=1 PATH="$tmp/bin:/usr/bin:/bin" bash "$helper" >"$tmp/out" 2>&1 || status=$?
(( status == 1 )) || fail "missing package keeps the migration pending"
grep -q 'no chromium package is available' "$tmp/out" || fail "missing package reports an actionable error" "$(cat "$tmp/out")"
pass "missing package reports the expected error"

status=0
OMARCHY_CHROMIUM_MIN_VERSION=1 PATH="$tmp/bin:/usr/bin:/bin" bash "$helper" >"$tmp/out" 2>&1 || status=$?
(( status == 1 )) || fail "an inherited override cannot lower the security floor" "$(cat "$tmp/out")"
pass "inherited environment cannot bypass the fixed floor"

TEST_AVAILABLE=152.0.7977.82-1 TEST_UPGRADE_ALLOWED=1 PATH="$tmp/bin:/usr/bin:/bin" \
  bash "$helper" >"$tmp/out" 2>&1 || fail "available fixed package upgrades successfully" "$(cat "$tmp/out")"
[[ $(cat "$TEST_INSTALLED_FILE") == "152.0.7977.82-1" ]] || fail "fixed package became installed"
(( $(wc -l <"$TEST_UPGRADE_LOG") == 1 )) || fail "upgrade invokes package install once"
PATH="$tmp/bin:/usr/bin:/bin" bash "$helper" >"$tmp/out" 2>&1 || fail "fixed installation needs no upgrade"
(( $(wc -l <"$TEST_UPGRADE_LOG") == 1 )) || fail "fixed installation does not install twice"
pass "successful upgrade rechecks the installed version and is idempotent"

printf '%s\n' '151.0.0.0-1' >"$TEST_INSTALLED_FILE"
status=0
TEST_AVAILABLE=152.0.7977.82-1 TEST_UPGRADE_ALLOWED=1 TEST_AFTER_UPGRADE=151.0.0.0-1 \
  PATH="$tmp/bin:/usr/bin:/bin" bash "$helper" >"$tmp/out" 2>&1 || status=$?
(( status == 1 )) || fail "a successful package command cannot hide an unmet floor"
grep -q 'after upgrade' "$tmp/out" || fail "failed installed-version recheck is reported"
pass "post-upgrade verification rejects an unchanged vulnerable package"
