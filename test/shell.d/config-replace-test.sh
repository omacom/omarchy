#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
case_root=$(mktemp -d)
trap 'chmod -R u+w "$case_root"; rm -rf "$case_root"' EXIT
mkdir -p "$case_root/bin" "$case_root/dotfiles"
export TEST_CONTENT="$case_root/content" TEST_TARGET="$case_root/dotfiles/config"
printf 'new content\n' >"$TEST_CONTENT"
printf 'original content\n' >"$TEST_TARGET"
chmod 640 "$TEST_TARGET"
ln -s "$TEST_TARGET" "$case_root/config-link"
metadata=$(stat -c '%u:%g:%a' "$TEST_TARGET")

bash "$ROOT/bin/omarchy-config-replace" "$TEST_CONTENT" "$case_root/config-link"
[[ -L $case_root/config-link ]] || fail "atomic replacement preserves the symlink"
cmp -s "$TEST_CONTENT" "$TEST_TARGET" || fail "atomic replacement publishes complete content"
[[ $(stat -c '%u:%g:%a' "$TEST_TARGET") == "$metadata" ]] || fail "replacement preserves owner/group/mode"
pass "atomic replacement updates the symlink target with its original metadata"

# Metadata must survive inode replacement, not just the content and mode.
if python3 -c 'import os,sys; os.setxattr(sys.argv[1], "user.omarchy-test", b"keep")' "$TEST_TARGET" >/dev/null 2>&1; then
  bash "$ROOT/bin/omarchy-config-replace" "$TEST_CONTENT" "$case_root/config-link"
  python3 -c 'import os,sys; assert os.getxattr(sys.argv[1], "user.omarchy-test") == b"keep"' "$TEST_TARGET" || fail "extended attribute survives replacement"
  pass "atomic replacement retains extended attributes"
elif command -v xattr >/dev/null && xattr -w user.omarchy-test keep "$TEST_TARGET" 2>/dev/null; then
  bash "$ROOT/bin/omarchy-config-replace" "$TEST_CONTENT" "$case_root/config-link"
  [[ $(xattr -p user.omarchy-test "$TEST_TARGET") == keep ]] || fail "extended attribute survives replacement"
  pass "atomic replacement retains extended attributes"
else
  printf 'ok - extended attributes unavailable on the test filesystem # SKIP\n'
fi

# Atomic publication needs a writable directory even if the file is writable.
# Refuse safely instead of falling back to truncating the live file.
if (( EUID != 0 )); then
  cp "$TEST_TARGET" "$case_root/before"
  chmod 500 "$case_root/dotfiles"
  status=0
  bash "$ROOT/bin/omarchy-config-replace" "$TEST_CONTENT" "$case_root/config-link" >"$case_root/output" 2>&1 || status=$?
  chmod 700 "$case_root/dotfiles"
  (( status != 0 )) || fail "restricted directory must refuse atomic replacement"
  cmp -s "$TEST_TARGET" "$case_root/before" || fail "restricted directory preserves original content"
  pass "restricted directory refuses safely without truncating the live config"
else
  printf 'ok - restricted directory permission test requires a non-root user # SKIP\n'
fi

for failure in copy metadata rename; do
  printf 'original content\n' >"$TEST_TARGET"
  cp "$TEST_TARGET" "$case_root/before"
  case "$failure" in
    copy)
      cat >"$case_root/bin/cat" <<'STUB'
#!/bin/bash
[[ $1 == -- ]] || exit 99
printf 'partial content'
echo simulated-full-disk >&2
exit 17
STUB
      command=cat
      ;;
    metadata)
      printf '#!/bin/bash\necho metadata-failed >&2\nexit 17\n' >"$case_root/bin/cp"
      command=cp
      ;;
    rename)
      printf '#!/bin/bash\necho rename-failed >&2\nexit 17\n' >"$case_root/bin/mv"
      command=mv
      ;;
  esac
  chmod +x "$case_root/bin/$command"
  status=0
  PATH="$case_root/bin:$PATH" bash "$ROOT/bin/omarchy-config-replace" "$TEST_CONTENT" "$case_root/config-link" >"$case_root/output" 2>&1 || status=$?
  (( status != 0 )) || fail "$failure must fail replacement"
  [[ -L $case_root/config-link ]] || fail "$failure preserves symlink"
  cmp -s "$TEST_TARGET" "$case_root/before" || fail "$failure preserves complete original content"
  [[ $(stat -c '%u:%g:%a' "$TEST_TARGET") == "$metadata" ]] || fail "$failure preserves metadata"
  [[ -z $(find "$case_root/dotfiles" -name '.omarchy-config.*' -print -quit) ]] || fail "$failure cleans staging"
  rm "$case_root/bin/$command"
  pass "$failure failure preserves the original and removes staged output"
done

# Exercise the reviewed migration at the failing copy boundary, not just the
# helper. It must retain the original and fail rather than complete the update.
home="$case_root/home"
mkdir -p "$home/.config/omarchy" "$case_root/tmp"
config="$home/.config/omarchy/shell.json"
printf '{"bar":{"layout":{"center":[{"id":"omarchy.clock","formatAlt":"dd MMMM '\''W'\''ww yyyy"}]}}}\n' >"$config"
cp "$config" "$case_root/before"
cat >"$case_root/bin/cat" <<'STUB'
#!/bin/bash
printf 'partial content'
echo simulated-full-disk >&2
exit 17
STUB
chmod +x "$case_root/bin/cat"
status=0
HOME="$home" TMPDIR="$case_root/tmp" PATH="$case_root/bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$ROOT/migrations/1780294774.sh" >"$case_root/output" 2>&1 || status=$?
(( status != 0 )) || fail "partial migration write stays pending"
cmp -s "$config" "$case_root/before" || fail "partial migration write preserves live config"
[[ -z $(find "$case_root/tmp" "$home" -name '.omarchy-config.*' -print -quit) ]] || fail "migration cleans atomic staging"
[[ -z $(find "$case_root/tmp" -mindepth 1 -print -quit) ]] || fail "migration cleans transform staging"
pass "migration retains complete config after a partial staging write"
