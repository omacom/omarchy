#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"

# Exercise the production trust predicate without installing or invoking sudo.
sed -n '/^trusted_path() {$/,/^}$/p' "$ROOT/install/helpers/battery-guard.sh" >"$tmp_dir/trust.sh"
cat >"$tmp_dir/bin/realpath" <<'SH'
#!/bin/bash
printf '/usr/share/package/file\n'
SH
cat >"$tmp_dir/bin/stat" <<'SH'
#!/bin/bash
if [[ $* == *"/fixture" ]]; then
  printf '%s %s\n' "$OWNER" "$MODE"
else
  printf '0 755\n'
fi
SH
chmod +x "$tmp_dir/bin/"*
PATH="$tmp_dir/bin:$PATH" OWNER=0 MODE=755 bash -c 'source "$1"; trusted_path /fixture' _ "$tmp_dir/trust.sh" || fail "root-owned package accepted"
if PATH="$tmp_dir/bin:$PATH" OWNER=1000 MODE=755 bash -c 'source "$1"; trusted_path /fixture' _ "$tmp_dir/trust.sh"; then
  fail "user-owned ancestor rejected"
fi
if PATH="$tmp_dir/bin:$PATH" OWNER=0 MODE=775 bash -c 'source "$1"; trusted_path /fixture' _ "$tmp_dir/trust.sh"; then
  fail "group-writable ancestor rejected"
fi
for migration in 1790872998; do
  grep -F 'source_path=/usr/share/omarchy/install/helpers/battery-guard.sh' "$ROOT/migrations/$migration.sh" >/dev/null || fail "migration validates fixed packaged installer"
  grep -F '8#$mode & 0022' "$ROOT/migrations/$migration.sh" >/dev/null || fail "migration checks trust before root execution"
done
cat >"$tmp_dir/bin/cmp" <<'SH'
#!/bin/bash
[[ -e $DEPLOYED ]]
SH
cat >"$tmp_dir/bin/systemctl" <<'SH'
#!/bin/bash
[[ -e $DEPLOYED ]]
SH
cat >"$tmp_dir/bin/sha256sum" <<'SH'
#!/bin/bash
[[ -e $DEPLOYED ]]
SH
cat >"$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo\n' >>"$DEPLOY_LOG"
touch "$DEPLOYED"
SH
chmod +x "$tmp_dir/bin/"*
export DEPLOYED="$tmp_dir/deployed" DEPLOY_LOG="$tmp_dir/deploy-log"
for migration in 1790872998 1790872998; do
  PATH="$tmp_dir/bin:$PATH" bash -euo pipefail "$ROOT/migrations/$migration.sh" >/dev/null
done
[[ $(wc -l <"$DEPLOY_LOG") == 1 ]] || fail "repeated deployment and second user do not prompt again"

# Run the migration's real trust predicate against fixture paths. The sudo stub
# replaces the packaged installer path, the privileged deploy line, and
# optionally stat's result for one path (STAT_PATH, default every path; "fail"
# makes stat fail), and refuses to run unless every replacement took, so no
# real installer runs.
rm -f "$DEPLOYED"
cat >"$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
[[ $1 == "/bin/bash" && $2 == "-c" ]] || exit 1
source_fixture=$(printf '%q' "$SOURCE_FIXTURE")
script=${3//\/usr\/share\/omarchy\/install\/helpers\/battery-guard.sh/"$source_fixture"}
script=${script//'/bin/bash "$source_path" --restart'/'exit "$DEPLOY_STATUS"'}
if [[ -n ${STAT_FIXTURE:-} ]]; then
  read -r -d '' fixture_stat <<'FN' || true
fixture_stat() {
  if [[ -n ${STAT_PATH:-} && $1 != "$STAT_PATH" ]]; then
    printf '0 755\n'
  elif [[ $STAT_FIXTURE != "fail" ]]; then
    printf '%s\n' "$STAT_FIXTURE"
  else
    return 1
  fi
}
FN
  script="$fixture_stat"$'\n'"${script//'stat -c "%u %a" -- "$path"'/'fixture_stat "$path"'}"
  [[ $script == *'fixture_stat "$path"'* ]] || exit 99
fi
[[ $script == *"$source_fixture"* && $script == *'exit "$DEPLOY_STATUS"'* ]] || exit 99
[[ $script != *"/usr/share/omarchy"* && $script != *"--restart"* ]] || exit 99
shift 3
exec /bin/bash -c "$script" "$@"
SH
mkdir -p "$tmp_dir/fixture" "$tmp_dir/statbin"
printf '#!/bin/bash\n' >"$tmp_dir/fixture/file.sh"
ln -s "$tmp_dir/fixture/file.sh" "$tmp_dir/fixture/link.sh"
run_migration() {
  local status=0
  PATH="$tmp_dir/bin:$PATH" SOURCE_FIXTURE="$1" DEPLOY_STATUS="${2:-0}" STAT_FIXTURE="${3:-}" \
    bash -euo pipefail "$ROOT/migrations/1790872998.sh" >/dev/null 2>"$tmp_dir/err" || status=$?
  printf '%s\n' "$status"
}
expect_skip() {
  [[ $(run_migration "$1" 0 "$2") == "0" ]] || fail "$3 skips instead of blocking later migrations"
  grep -F "Skipping battery protection" "$tmp_dir/err" >/dev/null || fail "$3 explains the skip"
  grep -F "$4" "$tmp_dir/err" >/dev/null || fail "$3 names the reason"
}
[[ $(run_migration "$tmp_dir/fixture/file.sh" 0 "0 755") == "0" ]] || fail "a root-owned package deploys the guard"
! grep -F "Skipping" "$tmp_dir/err" >/dev/null || fail "a root-owned package does not report a skip"
[[ $(run_migration /usr/bin/bash) == "0" ]] || fail "a real root-owned package file is trusted"
expect_skip /dev/null "" "a real world-writable package file" "root-owned"
expect_skip "$tmp_dir/fixture/link.sh" "0 755" "a symlinked package file" "not symlinks"
expect_skip "$tmp_dir/fixture/file.sh" "1000 755" "a user-owned package file" "root-owned"
expect_skip "$tmp_dir/fixture/file.sh" "0 775" "a group-writable package file" "root-owned"
expect_skip "$tmp_dir/fixture/file.sh" "0 757" "a world-writable package file" "root-owned"
STAT_PATH="$tmp_dir/fixture" expect_skip "$tmp_dir/fixture/file.sh" "1000 755" "a user-owned package directory" "root-owned"
STAT_PATH="${tmp_dir%/*}" expect_skip "$tmp_dir/fixture/file.sh" "0 777" "a writable package ancestor" "root-owned"
expect_skip "$tmp_dir/fixture/file.sh" fail "an uninspectable package file" "cannot inspect"
[[ $(run_migration "$tmp_dir/missing/battery-guard.sh") == "1" ]] || fail "a package without the guard stays pending"
grep -F "does not include battery protection yet" "$tmp_dir/err" >/dev/null || fail "a package without the guard says it will retry"
[[ $(run_migration "$tmp_dir/fixture/file.sh" 78 "0 755") == "0" ]] || fail "an untrusted package reported by the installer skips"
grep -F "Skipping battery protection" "$tmp_dir/err" >/dev/null || fail "an untrusted package reported by the installer explains the skip"
[[ $(run_migration "$tmp_dir/fixture/file.sh" 1 "0 755") == "1" ]] || fail "a failed service start stays pending"
cat >"$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
exit 1
SH
[[ $(run_migration "$tmp_dir/fixture/file.sh" 0 "0 755") == "1" ]] || fail "a declined prompt stays pending"

# The installer leaves missing package files pending and skips untrusted ones.
{
  sed -n '/^trusted_path() {$/,/^}$/p' "$ROOT/install/helpers/battery-guard.sh"
  sed -n '/^untrusted=78$/,/^done$/p' "$ROOT/install/helpers/battery-guard.sh"
} >"$tmp_dir/sources.sh"
grep -F 'for source in "$guard" "$helper" "$unit"; do' "$tmp_dir/sources.sh" >/dev/null || fail "installer source checks extracted"
cat >"$tmp_dir/statbin/stat" <<'SH'
#!/bin/bash
if [[ -n ${STAT_PATH:-} && ${!#} != "$STAT_PATH" ]]; then
  printf '0 755\n'
else
  printf '%s\n' "$STAT_FIXTURE"
fi
SH
chmod +x "$tmp_dir/statbin/stat"
check_sources_ancestor() {
  local status=0
  PATH="$tmp_dir/statbin:$PATH" STAT_FIXTURE="1000 755" STAT_PATH="$tmp_dir/fixture" guard="$tmp_dir/fixture/file.sh" helper="$tmp_dir/fixture/file.sh" unit="$tmp_dir/fixture/file.sh" \
    bash -euo pipefail -c 'source "$1"' _ "$tmp_dir/sources.sh" 2>/dev/null || status=$?
  printf '%s\n' "$status"
}
check_sources() {
  local status=0
  PATH="$tmp_dir/statbin:$PATH" STAT_FIXTURE="$2" guard="$tmp_dir/fixture/file.sh" helper="$tmp_dir/fixture/file.sh" unit="$1" \
    bash -euo pipefail -c 'source "$1"' _ "$tmp_dir/sources.sh" 2>/dev/null || status=$?
  printf '%s\n' "$status"
}
[[ $(check_sources "$tmp_dir/fixture/file.sh" "0 755") == "0" ]] || fail "installer accepts root-owned package files"
[[ $(check_sources "$tmp_dir/missing/unit" "0 755") == "1" ]] || fail "installer leaves a missing package file pending"
[[ $(check_sources "$tmp_dir/fixture/link.sh" "0 755") == "78" ]] || fail "installer reports a symlinked package file as untrusted"
[[ $(check_sources "$tmp_dir/fixture/file.sh" "1000 755") == "78" ]] || fail "installer reports a user-owned package file as untrusted"
[[ $(check_sources "$tmp_dir/fixture/file.sh" "0 775") == "78" ]] || fail "installer reports a group-writable package file as untrusted"
[[ $(check_sources_ancestor) == "78" ]] || fail "installer reports a user-owned package directory as untrusted"
pass "deployment trusts only root-owned packages, retries missing or failed deployments, and skips untrusted packages"
