#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-sudo-authentication"
setup="$ROOT/bin/omarchy-setup-security-sudo-authentication"
remove="$ROOT/bin/omarchy-remove-security-sudo-authentication"

for command in "$helper" "$setup" "$remove"; do
  [[ -x $command ]] || fail "${command##*/} is executable"
done

for name in omarchy-dns omarchy-theme-browser omarchy-tzupdate; do
  grep -Fx "  $name" "$helper" >/dev/null ||
    fail "sudo authentication policy covers $name"
done

! grep -F '99-omarchy-nopasswd' "$helper" >/dev/null ||
  fail "sudo authentication policy leaves explicitly requested temporary grants alone"

grep -F 'PACKAGED_PATH=/usr/bin/omarchy-sudo-authentication' "$helper" >/dev/null ||
  fail "privileged policy changes re-exec the packaged command"

grep -Eq '^  export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin' "$helper" ||
  fail "policy helper pins root to trusted system paths"

pass "sudo authentication policy targets only the three shipped convenience rules"

if (( EUID == 0 )); then
  root_runner=()
elif unshare --user --map-root-user true 2>/dev/null; then
  root_runner=(unshare --user --map-root-user)
else
  pass "no unprivileged user namespace; skipping sudo authentication runtime checks"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
security_dir="$test_tmp/security"
sudoers_dir="$test_tmp/sudoers.d"
shipped_dir="$test_tmp/shipped-sudoers.d"
mkdir -p "$sudoers_dir" "$shipped_dir"

for name in omarchy-dns omarchy-theme-browser omarchy-tzupdate; do
  cp "$ROOT/etc/sudoers.d/$name" "$sudoers_dir/$name"
  cp "$ROOT/etc/sudoers.d/$name" "$shipped_dir/$name"
done
printf '%%wheel ALL=(root) NOPASSWD: /usr/bin/unrelated\n' >"$sudoers_dir/unrelated"

run_policy() {
  "${root_runner[@]}" env \
    OMARCHY_SECURITY_DIR="$security_dir" \
    OMARCHY_SHIPPED_SUDOERS_DIR="$shipped_dir" \
    OMARCHY_SUDOERS_DIR="$sudoers_dir" \
    bash "$helper" "$@"
}

run_policy enable >/dev/null || fail "enabling required sudo authentication succeeds"
[[ -f $security_dir/require-sudo-authentication ]] || fail "enable records the system policy marker"
[[ $(stat -c '%a' "$security_dir/require-sudo-authentication") == "644" ]] ||
  fail "policy marker is world-readable for unprivileged status checks"

for name in omarchy-dns omarchy-theme-browser omarchy-tzupdate; do
  [[ ! -e $sudoers_dir/$name ]] || fail "enable removes $name from the active sudoers directory"
  cmp "$ROOT/etc/sudoers.d/$name" "$security_dir/disabled-sudoers/$name" >/dev/null ||
    fail "enable preserves the exact $name rule for restoration"
done
[[ -f $sudoers_dir/unrelated ]] || fail "enable leaves unrelated sudoers files alone"
run_policy enabled || fail "enabled reports the active authentication policy"

run_policy apply >/dev/null || fail "applying an already active policy is idempotent"
pass "enable removes and preserves only Omarchy's three scoped rules"

cp "$ROOT/etc/sudoers.d/omarchy-dns" "$sudoers_dir/omarchy-dns"
printf '\n# upgraded\n' >>"$sudoers_dir/omarchy-dns"
run_policy apply >/dev/null || fail "policy reapplies after a package overwrite"
[[ ! -e $sudoers_dir/omarchy-dns ]] || fail "reapply removes a package-restored rule"
grep -Fx '# upgraded' "$security_dir/disabled-sudoers/omarchy-dns" >/dev/null ||
  fail "reapply preserves the newest packaged rule for restoration"
pass "apply re-disables rules restored by a settings package update"

rm -f "$shipped_dir/omarchy-tzupdate"
run_policy apply >/dev/null || fail "apply reconciles a rule retired by the settings package"
[[ ! -e $security_dir/disabled-sudoers/omarchy-tzupdate ]] ||
  fail "apply drops the preserved copy of a retired package rule"
pass "apply cannot later resurrect a passwordless rule retired by the package"

run_policy disable >/dev/null || fail "disabling required authentication succeeds"
[[ ! -e $security_dir/require-sudo-authentication ]] || fail "disable removes the policy marker"
for name in omarchy-dns omarchy-theme-browser; do
  [[ -f $sudoers_dir/$name ]] || fail "disable restores $name"
done
[[ ! -e $sudoers_dir/omarchy-tzupdate ]] || fail "disable does not restore a retired package rule"
grep -Fx '# upgraded' "$sudoers_dir/omarchy-dns" >/dev/null ||
  fail "disable restores the newest packaged rule"
[[ -f $sudoers_dir/unrelated ]] || fail "disable leaves unrelated sudoers files alone"
run_policy enabled && fail "enabled reports false after restoring default rules"
pass "disable restores the preserved package rules and clears the policy"

cp "$ROOT/etc/sudoers.d/omarchy-tzupdate" "$shipped_dir/omarchy-tzupdate"
cp "$ROOT/etc/sudoers.d/omarchy-tzupdate" "$sudoers_dir/omarchy-tzupdate"
run_policy enable >/dev/null
rm -f "$security_dir/disabled-sudoers/omarchy-theme-browser"
ln -s /etc/passwd "$security_dir/disabled-sudoers/omarchy-theme-browser"
if run_policy disable >"$test_tmp/unsafe.out" 2>&1; then
  fail "disable refuses a symlink planted in the preserved sudoers directory"
fi
[[ -f $security_dir/require-sudo-authentication ]] || fail "a failed restore keeps the policy marker"
[[ ! -e $sudoers_dir/omarchy-dns ]] || fail "a failed restore keeps rules inactive"
pass "unsafe restore input fails closed with the authentication policy enabled"

rm -f "$security_dir/disabled-sudoers/omarchy-theme-browser"
cp "$ROOT/etc/sudoers.d/omarchy-theme-browser" "$sudoers_dir/omarchy-theme-browser"
mkdir "$security_dir/disabled-sudoers/omarchy-theme-browser"
if run_policy apply >"$test_tmp/move-failure.out" 2>&1; then
  fail "apply reports a backup publication collision"
fi
[[ -f $sudoers_dir/omarchy-theme-browser ]] ||
  fail "a failed backup publication never deletes the active rule without preserving it"
[[ -f $security_dir/require-sudo-authentication ]] ||
  fail "a failed policy application keeps the policy marker"
pass "mutation failures propagate without losing the active or preserved rule"
