#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command pacman-conf

t2_migration="$ROOT/migrations/1788163636.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Exercise the provenance migration with trusted absolute command paths mapped
# to deterministic stubs. Every scenario starts with unsafe T2 policy plus an
# unrelated administrator section.
stub_bin="$test_tmp/bin"
mkdir "$stub_bin"
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf 'AUTH %s\n' "$*" >>"${TEST_TRANSACTION_LOG:?}"
[[ $1 != "-N" ]] || shift
[[ $1 != "--" ]] || shift
exec "$@"
STUB
cat >"$stub_bin/install" <<'STUB'
#!/bin/bash
filtered=()
while (($#)); do
  case $1 in
    -o|-g) shift 2 ;;
    *) filtered+=("$1"); shift ;;
  esac
done
exec /usr/bin/install "${filtered[@]}"
STUB
cat >"$stub_bin/lspci" <<'STUB'
#!/bin/bash
[[ ${TEST_PCI_STATUS:-0} == 0 ]] || exit "$TEST_PCI_STATUS"
(( ${TEST_T2_HARDWARE:-0} == 1 )) || exit 0
printf '%s\n' '01:00.0 Bridge [0680]: Apple Inc. T2 Security Chip [106b:1801]'
STUB
cat >"$stub_bin/pacman-conf" <<'STUB'
#!/bin/bash
if [[ ${TEST_NATIVE_SIGLEVEL:-0} == 1 || " $* " == *" --repo arch-mact2 "* || " $* " == *" --repo-list "* ]]; then
  exec /usr/bin/pacman-conf "$@"
elif [[ " $* " == *" --repo omarchy "* ]]; then
  printf '%s\n' "${TEST_REPO_SIGLEVEL-${TEST_SIGLEVEL:-PackageRequired PackageTrustedOnly}}"
else
  printf '%s\n' "${TEST_GLOBAL_SIGLEVEL-${TEST_SIGLEVEL:-PackageRequired PackageTrustedOnly}}"
fi
STUB
cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash
case $1 in
  -Q) [[ $2 == linux-t2 ]] ;;
  -Qq)
    [[ ${TEST_PACKAGE_QUERY_STATUS:-0} == 0 ]] || exit "$TEST_PACKAGE_QUERY_STATUS"
    printf '%s\n' "${TEST_INSTALLED_PACKAGES-linux-t2}"
    ;;
  -Si)
    package=${2#omarchy/}
    repository=${TEST_REPOSITORY:-omarchy}
    [[ ${TEST_MISSING_PACKAGE:-} != "$package" ]] || repository=core
    printf 'Repository      : %s\n' "$repository"
    for ((line = 0; line < ${TEST_QUERY_PADDING_LINES:-0}; line++)); do
      printf 'Description     : metadata padding %s\n' "$line"
    done
    [[ ${TEST_QUERY_FAIL_PACKAGE:-} != "$package" ]] || exit 44
    ;;
  -S)
    printf 'TRANSACTION %s\n' "$*" >>"${TEST_TRANSACTION_LOG:?}"
    if [[ -n ${TEST_TX_GATE:-} ]]; then
      touch "$TEST_TX_GATE.entered"
      while [[ ! -e $TEST_TX_GATE.release ]]; do sleep 0.02; done
    fi
    exit "${TEST_TRANSACTION_STATUS:-0}"
    ;;
  *) exit 2 ;;
esac
STUB
chmod +x "$stub_bin"/*

mapped_migration_template="$test_tmp/t2-migration.template.sh"
sed -e "s#/usr/bin/pacman-conf#$stub_bin/pacman-conf#g" \
  -e "s#/usr/bin/pacman#$stub_bin/pacman#g" \
  -e "s#/usr/bin/install#$stub_bin/install#g" \
  -e "s#/usr/bin/sudo#$stub_bin/sudo#g" \
  -e 's/EUID == 0/${TEST_MACHINE_EUID:-0} == 0/' \
  -e "s#/usr/bin/lspci#$stub_bin/lspci#g" "$t2_migration" >"$mapped_migration_template"

run_t2_scenario() {
  local name="$1" policy="$2" repository="$3"
  local repo_policy="${4-$policy}" global_policy="${5-$policy}"
  local missing_package="${6:-}" transaction_status="${7:-0}"
  local padding_lines="${8:-0}"
  local query_fail_package="${9:-}" query_padding_lines="${10:-0}"
  local dir="$test_tmp/$name"
  mkdir "$dir"
  cat >"$dir/pacman.conf" <<CONF
[options]
SigLevel = ${TEST_LEGACY_GLOBAL_POLICY:-Required DatabaseOptional}
[arch-mact2]
Server = https://unsafe.invalid/
${TEST_LEGACY_POLICY-SigLevel = Never}
[administrator]
Server = file:///srv/admin
SigLevel = Required
[omarchy]
Server = https://pkgs.omarchy.org/
SigLevel = PackageRequired PackageTrustedOnly DatabaseOptional
CONF
  if (( padding_lines > 0 )); then
    /usr/bin/awk -v padding_lines="$padding_lines" '
      /^\[arch-mact2\]$/ {
        for (line = 0; line < padding_lines; line++) print "# pipeline-truncation-padding"
      }
      { print }
    ' "$dir/pacman.conf" >"$dir/pacman.conf.padded"
    /usr/bin/mv "$dir/pacman.conf.padded" "$dir/pacman.conf"
  fi
  : >"$dir/transactions"
  sed \
    -e "s|^pacman_conf=/etc/pacman.conf$|pacman_conf=$dir/pacman.conf|" \
    -e "s|^repair_marker=/var/lib/omarchy/t2-package-provenance-repaired$|repair_marker=$dir/marker|" \
    -e "s|/run/omarchy-t2-package-provenance.lock|$dir/machine.lock|" \
    -e "s|/usr/share/omarchy/migrations/1788163636.sh|$dir/t2-migration.sh|" \
    "$mapped_migration_template" >"$dir/t2-migration.sh"
  HOME="$dir" PATH="$stub_bin:$PATH" TEST_REPO_SIGLEVEL="$repo_policy" \
    TEST_GLOBAL_SIGLEVEL="$global_policy" TEST_REPOSITORY="$repository" \
    TEST_MISSING_PACKAGE="$missing_package" TEST_TRANSACTION_STATUS="$transaction_status" \
    TEST_QUERY_FAIL_PACKAGE="$query_fail_package" TEST_QUERY_PADDING_LINES="$query_padding_lines" \
    TEST_TRANSACTION_LOG="$dir/transactions" bash -euo pipefail "$dir/t2-migration.sh" >"$dir/output" 2>&1
}

check_legacy_policy() {
  local name="$1" policy="$2" expected="$3" global_policy="${4:-Required DatabaseOptional}"
  TEST_NATIVE_SIGLEVEL=1 TEST_LEGACY_POLICY="$policy" TEST_LEGACY_GLOBAL_POLICY="$global_policy" \
    run_t2_scenario "$name" 'PackageRequired PackageTrustedOnly' omarchy
  [[ -f $test_tmp/$name/marker ]] || fail "legacy policy case $name did not finish replacement"
  if [[ $expected == "preserve" ]]; then
    grep -q '^\[arch-mact2\]$' "$test_tmp/$name/pacman.conf" ||
      fail "secure legacy package policy $name was removed"
    [[ -z $(find "$test_tmp/$name" -name 'arch-mact2.omarchy-disabled.*.txt' -print -quit) ]] ||
      fail "secure legacy package policy $name was backed up as unsafe"
  else
    ! grep -q '^\[arch-mact2\]$' "$test_tmp/$name/pacman.conf" ||
      fail "unsafe legacy package policy $name was retained"
    [[ -n $(find "$test_tmp/$name" -name 'arch-mact2.omarchy-disabled.*.txt' -print -quit) ]] ||
      fail "unsafe legacy package policy $name has no recovery backup"
  fi
}

check_legacy_policy database-optional 'SigLevel = PackageRequired DatabaseOptional PackageTrustedOnly' preserve
check_legacy_policy database-never 'SigLevel = PackageRequired DatabaseNever PackageTrustedOnly' preserve
check_legacy_policy database-trust-all 'SigLevel = PackageRequired DatabaseTrustAll PackageTrustedOnly' preserve
check_legacy_policy package-override 'SigLevel = Optional PackageRequired TrustedOnly' preserve
check_legacy_policy inherited-secure '' preserve
check_legacy_policy package-optional 'SigLevel = PackageOptional DatabaseRequired PackageTrustedOnly' remove
check_legacy_policy package-trust-all 'SigLevel = PackageRequired PackageTrustAll' remove
check_legacy_policy inherited-unsafe '' remove Never
printf '%s\n' 'SigLevel = PackageRequired DatabaseOptional PackageTrustedOnly' >"$test_tmp/included-policy.conf"
check_legacy_policy included-secure "Include = $test_tmp/included-policy.conf" preserve
printf '%s\n' 'SigLevel = PackageOptional DatabaseRequired PackageTrustedOnly' >"$test_tmp/included-policy.conf"
check_legacy_policy included-unsafe "Include = $test_tmp/included-policy.conf" remove
pass "native policy resolution preserves secure database exceptions and disables inherited or included unsafe package policy"

if TEST_LEGACY_POLICY='SigLevel = InvalidPolicy' \
  run_t2_scenario invalid-policy 'PackageRequired PackageTrustedOnly' omarchy; then
  fail "unresolvable legacy signature policy reaches replacement"
fi
[[ ! -s $test_tmp/invalid-policy/transactions && ! -e $test_tmp/invalid-policy/marker ]] ||
  fail "unresolvable legacy policy publishes a package transaction or completion"
grep -q '^\[arch-mact2\]$' "$test_tmp/invalid-policy/pacman.conf" ||
  fail "unresolvable legacy policy rewrites administrator configuration"
pass "unresolvable legacy signature policy remains pending without mutation"

if run_t2_scenario insecure 'PackageOptional PackageTrustAll' omarchy; then
  fail "T2 migration accepts insecure effective package policy"
fi
! grep -q '^TRANSACTION' "$test_tmp/insecure/transactions" || fail "insecure T2 policy reaches pacman transaction"
! grep -q '^\[arch-mact2\]' "$test_tmp/insecure/pacman.conf" || fail "unsafe T2 repo survives failed migration"
grep -q '^\[administrator\]' "$test_tmp/insecure/pacman.conf" || fail "administrator repo was removed"
backup=$(find "$test_tmp/insecure" -name 'arch-mact2.omarchy-disabled.*.txt' -print -quit)
[[ -n $backup && $(stat -c '%a' "$backup") == 600 ]] || fail "unsafe T2 section was not privately backed up"

if run_t2_scenario unavailable 'PackageRequired PackageTrustedOnly' core; then
  fail "T2 migration accepts unavailable signed replacements"
fi
! grep -q '^TRANSACTION' "$test_tmp/unavailable/transactions" || fail "missing T2 artifacts reach pacman transaction"

if run_t2_scenario partial 'PackageRequired PackageTrustedOnly' omarchy \
  'PackageRequired PackageTrustedOnly' 'PackageRequired PackageTrustedOnly' t2fanrd; then
  fail "T2 migration accepts a partial signed replacement set"
fi
! grep -q '^TRANSACTION' "$test_tmp/partial/transactions" || fail "partial T2 artifacts reach pacman transaction"

# A real unavailable package makes `pacman -Si` nonzero. Emit more than a pipe
# buffer in a successful query too: the old early-exiting parser converted its
# producer into status 141 under pipefail.
run_t2_scenario large-query 'PackageRequired PackageTrustedOnly' omarchy \
  'PackageRequired PackageTrustedOnly' 'PackageRequired PackageTrustedOnly' '' 0 0 '' 20000
[[ -f $test_tmp/large-query/marker ]] || fail "large T2 repository metadata aborts a valid replacement"

# On a nonzero query, production errexit used to skip the promised recovery
# text. Combining both conditions proves failure is captured before parsing.
if run_t2_scenario query-failure 'PackageRequired PackageTrustedOnly' omarchy \
  'PackageRequired PackageTrustedOnly' 'PackageRequired PackageTrustedOnly' '' 0 0 linux-t2 20000; then
  fail "T2 migration accepts a failed repository query"
fi
grep -q "Authenticated replacement 'linux-t2' is unavailable" "$test_tmp/query-failure/output" ||
  fail "failed T2 repository query skips its recovery guidance"
grep -q 'Publish all signed T2 artifacts, then retry this migration' "$test_tmp/query-failure/output" ||
  fail "failed T2 repository query omits retry guidance"
! grep -q '^TRANSACTION' "$test_tmp/query-failure/transactions" ||
  fail "failed T2 repository query reaches a package transaction"
! grep -q '^\[arch-mact2\]' "$test_tmp/query-failure/pacman.conf" ||
  fail "failed T2 repository query leaves the unsafe repository enabled"
[[ ! -e $test_tmp/query-failure/marker ]] || fail "failed T2 repository query publishes completion"
HOME="$test_tmp/query-failure" PATH="$stub_bin:$PATH" \
  TEST_REPO_SIGLEVEL='PackageRequired PackageTrustedOnly' \
  TEST_GLOBAL_SIGLEVEL='PackageRequired PackageTrustedOnly' TEST_REPOSITORY=omarchy \
  TEST_TRANSACTION_LOG="$test_tmp/query-failure/transactions" \
  bash -euo pipefail "$test_tmp/query-failure/t2-migration.sh" >/dev/null
[[ -f $test_tmp/query-failure/marker ]] || fail "T2 repository query failure is not retryable"
pass "failed and large T2 repository queries fail with guidance and retry cleanly"

if run_t2_scenario reinstall-failure 'PackageRequired PackageTrustedOnly' omarchy \
  'PackageRequired PackageTrustedOnly' 'PackageRequired PackageTrustedOnly' '' 33; then
  fail "T2 migration accepts a failed authenticated reinstall"
fi
[[ ! -e $test_tmp/reinstall-failure/marker ]] || fail "failed T2 reinstall publishes a completion marker"

run_t2_scenario signed 'PackageRequired PackageTrustedOnly' omarchy
transaction=$(<"$test_tmp/signed/transactions")
[[ $transaction == *'omarchy/linux-t2 omarchy/linux-t2-headers omarchy/apple-t2-audio-config omarchy/apple-bcm-firmware omarchy/t2fanrd'* ]] ||
  fail "T2 migration does not reinstall every replacement together"
(( $(grep -c '^AUTH ' "$test_tmp/signed/transactions") == 1 )) ||
  fail "T2 repair does not use a single authorized machine phase"
[[ $transaction != *'--needed'* ]] || fail "T2 migration trusts bytes installed under SigLevel=Never"
[[ -f $test_tmp/signed/marker ]] || fail "successful authenticated T2 replacement is not recorded"
: >"$test_tmp/signed/transactions"
HOME="$test_tmp/signed" PATH="$stub_bin:$PATH" \
  TEST_REPO_SIGLEVEL='PackageRequired PackageTrustedOnly' \
  TEST_GLOBAL_SIGLEVEL='PackageRequired PackageTrustedOnly' TEST_REPOSITORY=omarchy \
  TEST_TRANSACTION_LOG="$test_tmp/signed/transactions" bash "$test_tmp/signed/t2-migration.sh" >/dev/null
[[ ! -s $test_tmp/signed/transactions ]] || fail "completed T2 repair prompts or reinstalls packages again"
run_t2_scenario inherited '' omarchy '' 'PackageRequired PackageTrustedOnly'
[[ -f $test_tmp/inherited/marker ]] || fail "T2 migration rejects a secure inherited global package policy"
run_t2_scenario large 'PackageRequired PackageTrustedOnly' omarchy \
  'PackageRequired PackageTrustedOnly' 'PackageRequired PackageTrustedOnly' '' 0 20000
grep -q '^\[omarchy\]$' "$test_tmp/large/pacman.conf" ||
  fail "T2 migration truncated a pacman.conf larger than the pipe buffer"
[[ -z $(find "$test_tmp/large" -maxdepth 1 -name '.pacman.conf.omarchy-t2.*' -print -quit) ]] ||
  fail "T2 migration left its root-owned pacman.conf stage behind"
pass "T2 migration disables unsafe policy first and fails closed until all signed replacements exist"

# The lock is the real util-linux implementation, but all filesystem effects
# remain in the fixture and every privileged command is mapped above.
gate="$test_tmp/two-users-gate"
TEST_TX_GATE="$gate" run_t2_scenario two-users 'PackageRequired PackageTrustedOnly' omarchy &
first_user=$!
for ((attempt = 0; attempt < 250; attempt++)); do
  [[ ! -e $gate.entered ]] || break
  sleep 0.02
done
[[ -e $gate.entered ]] || fail "first user's machine transaction did not start"
TEST_TRANSACTION_LOG="$test_tmp/two-users/transactions" \
  bash -euo pipefail "$test_tmp/two-users/t2-migration.sh" >"$test_tmp/two-users/second-output" 2>&1 &
second_user=$!
for ((attempt = 0; attempt < 250; attempt++)); do
  (( $(grep -c '^AUTH ' "$test_tmp/two-users/transactions") < 2 )) || break
  sleep 0.02
done
(( $(grep -c '^AUTH ' "$test_tmp/two-users/transactions") == 2 )) ||
  fail "second user did not reach the shared repair lock"
(( $(grep -c '^TRANSACTION ' "$test_tmp/two-users/transactions") == 1 )) ||
  fail "second user entered the transaction before the first finished"
printf '# administrator edit during replacement\n' >>"$test_tmp/two-users/pacman.conf"
touch "$gate.release"
wait "$first_user"
wait "$second_user"
(( $(grep -c '^TRANSACTION ' "$test_tmp/two-users/transactions") == 1 )) ||
  fail "two users ran overlapping T2 replacement transactions"
grep -q '^# administrator edit during replacement$' "$test_tmp/two-users/pacman.conf" ||
  fail "waiting migration overwrote the current administrator config"
pass "two users serialize the machine repair and recheck completion under the lock"

# The native parser discovers repositories whose entire section is included.
# An unsafe custom layout needs administrator repair, never silent completion.
included="$test_tmp/included-repository.conf"
printf '[arch-mact2]\nSigLevel = Never\nServer = https://unsafe.invalid/\n' >"$included"
printf '[options]\nSigLevel = Required DatabaseOptional\nInclude = %s\n[omarchy]\nSigLevel = Required DatabaseOptional\nServer = https://pkgs.omarchy.org/\n' "$included" >"$test_tmp/signed/pacman.conf"
rm "$test_tmp/signed/marker"
if TEST_TRANSACTION_LOG="$test_tmp/signed/transactions" \
  bash -euo pipefail "$test_tmp/signed/t2-migration.sh" >"$test_tmp/included-repository.output" 2>&1; then
  fail "unsafe repository in a custom include was silently accepted"
fi
grep -q 'defined in an included file' "$test_tmp/included-repository.output" ||
  fail "custom included repository lacks recovery guidance"
[[ ! -e $test_tmp/signed/marker ]] || fail "unresolved included repository published completion"
pass "custom included unsafe repository fails with repair guidance"

printf '[options]\nSigLevel = Required DatabaseOptional\n' >"$test_tmp/signed/pacman.conf"
: >"$test_tmp/signed/transactions"
TEST_INSTALLED_PACKAGES='' TEST_TRANSACTION_LOG="$test_tmp/signed/transactions" \
  bash -euo pipefail "$test_tmp/signed/t2-migration.sh" >/dev/null
[[ ! -s $test_tmp/signed/transactions ]] || fail "unaffected machine requires authorization"
if TEST_PACKAGE_QUERY_STATUS=45 TEST_TRANSACTION_LOG="$test_tmp/signed/transactions" \
  bash -euo pipefail "$test_tmp/signed/t2-migration.sh" >/dev/null 2>&1; then
  fail "package discovery failure was treated as an unaffected machine"
fi
if TEST_INSTALLED_PACKAGES='' TEST_PCI_STATUS=46 TEST_TRANSACTION_LOG="$test_tmp/signed/transactions" \
  bash -euo pipefail "$test_tmp/signed/t2-migration.sh" >/dev/null 2>&1; then
  fail "PCI discovery failure was treated as an unaffected machine"
fi
[[ ! -s $test_tmp/signed/transactions ]] || fail "failed discovery reaches authorization"
pass "unaffected machines skip authorization and discovery failures remain pending"

: >"$test_tmp/database-optional/transactions"
TEST_TRANSACTION_LOG="$test_tmp/database-optional/transactions" \
  bash -euo pipefail "$test_tmp/database-optional/t2-migration.sh" >/dev/null
[[ ! -s $test_tmp/database-optional/transactions ]] || fail "completed machine with safe custom repository prompts again"
pass "completed machines preserve safe custom policy without another prompt"

# Fresh installation cannot recreate the unsigned repository path.
! rg -n 'SigLevel[[:space:]]*=[[:space:]]*(Never|Optional)|TrustAll|arch-mact2-mirror' \
  "$ROOT/install/hardware/pacman.sh" "$ROOT/install/post-install/pacman.sh" >/dev/null ||
  fail "fresh installer retains unauthenticated T2 repository configuration"
grep -F '/usr/bin/pacman-conf --repo omarchy SigLevel' "$ROOT/install/hardware/apple/fix-t2.sh" >/dev/null

mapped_fresh_setup="$test_tmp/fix-t2.mapped.sh"
sed -e "s#/usr/bin/pacman-conf#$stub_bin/pacman-conf#g" \
  -e "s#/usr/bin/pacman#$stub_bin/pacman#g" \
  -e "s#/usr/bin/lspci#$stub_bin/lspci#g" \
  "$ROOT/install/hardware/apple/fix-t2.sh" >"$mapped_fresh_setup"
if TEST_T2_HARDWARE=1 TEST_REPO_SIGLEVEL='PackageRequired PackageTrustedOnly' \
  TEST_GLOBAL_SIGLEVEL='PackageRequired PackageTrustedOnly' TEST_REPOSITORY=omarchy \
  TEST_QUERY_FAIL_PACKAGE=linux-t2 TEST_QUERY_PADDING_LINES=20000 \
  PATH="$stub_bin:$PATH" bash -euo pipefail -c 'source "$1"' bash "$mapped_fresh_setup" \
  >"$test_tmp/fresh-query-failure.output" 2>&1; then
  fail "fresh T2 setup accepts a failed repository query"
fi
grep -q "Authenticated T2 package 'linux-t2' is unavailable" "$test_tmp/fresh-query-failure.output" ||
  fail "fresh T2 repository query skips its recovery guidance"
grep -q 'cannot continue until all support packages are published' "$test_tmp/fresh-query-failure.output" ||
  fail "fresh T2 repository query omits release guidance"
pass "fresh T2 setup independently enforces policy and reports failed large queries"

mkdir -p "$test_tmp/fresh-system/etc"
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$stub_bin/systemctl"
sed "s|/etc/|$test_tmp/fresh-system/etc/|g" "$mapped_fresh_setup" >"$test_tmp/fresh-setup.sh"
TEST_T2_HARDWARE=1 TEST_TRANSACTION_LOG="$test_tmp/fresh-transactions" PATH="$stub_bin:$PATH" \
  bash -euo pipefail -c 'source "$1"' bash "$test_tmp/fresh-setup.sh" >/dev/null
grep -Fq 'TRANSACTION -S --noconfirm omarchy/linux-t2 omarchy/linux-t2-headers omarchy/apple-t2-audio-config omarchy/apple-bcm-firmware omarchy/t2fanrd' "$test_tmp/fresh-transactions" ||
  fail "fresh setup transaction is not bound to the signed Omarchy repository"
pass "fresh setup pins every transaction target to the verified repository"
if TEST_PCI_STATUS=46 PATH="$stub_bin:$PATH" \
  bash -euo pipefail -c 'source "$1"' bash "$test_tmp/fresh-setup.sh" >"$test_tmp/fresh-pci-failure.output" 2>&1; then
  fail "fresh T2 setup silently ignores PCI discovery failure"
fi
grep -q 'Could not inspect PCI devices' "$test_tmp/fresh-pci-failure.output" ||
  fail "fresh PCI discovery failure lacks guidance"
pass "fresh setup reports PCI discovery failure instead of skipping T2 support"

# A minimal unsigned local package under the final policy must be rejected by
# real pacman. DatabaseOptional permits the unsigned database, never a package.
if command -v repo-add >/dev/null && command -v bsdtar >/dev/null && command -v zstd >/dev/null &&
  unshare --user --map-root-user true 2>/dev/null; then
  repo="$test_tmp/repo"
  root="$test_tmp/pacman-root"
  mkdir -p "$repo/pkg" "$root/var/lib/pacman" "$root/var/cache/pacman/pkg" "$root/etc/pacman.d/gnupg"
  cat >"$repo/pkg/.PKGINFO" <<'PKG'
pkgname = omarchy-audit-unsigned
pkgver = 1-1
pkgdesc = isolated unsigned audit fixture
builddate = 1
packager = Omarchy test
size = 0
arch = any
PKG
  bsdtar -C "$repo/pkg" -cf - .PKGINFO | zstd -q -o "$repo/omarchy-audit-unsigned-1-1-any.pkg.tar.zst"
  repo-add -q "$repo/omarchy.db.tar.gz" "$repo/omarchy-audit-unsigned-1-1-any.pkg.tar.zst"
  cat >"$test_tmp/pacman-test.conf" <<CONF
[options]
Architecture = auto
SigLevel = Required DatabaseOptional
[omarchy]
SigLevel = Required DatabaseOptional
Server = file://$repo
CONF
  if ! unshare --user --map-root-user bash -euo pipefail -c '
    pacman --config "$1" --root "$2" --dbpath "$2/var/lib/pacman" \
      --cachedir "$2/var/cache/pacman/pkg" -Sy --noconfirm >/dev/null
    if pacman --config "$1" --root "$2" --dbpath "$2/var/lib/pacman" \
      --cachedir "$2/var/cache/pacman/pkg" -S --noconfirm omarchy-audit-unsigned >"$3" 2>&1; then
      exit 90
    fi
  ' _ "$test_tmp/pacman-test.conf" "$root" "$test_tmp/pacman.out"; then
    fail "isolated pacman did not enforce the final signature policy" "$(cat "$test_tmp/pacman.out" 2>/dev/null || true)"
  fi
  [[ ! -e $root/usr ]] || fail "unsigned package modified isolated pacman root"
  pass "real pacman rejects unsigned packages under final Omarchy policy"
else
  pass "package construction tools unavailable; static signature-policy checks completed"
fi
