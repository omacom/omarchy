#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'chmod u+w "$test_tmp/dotfiles with spaces" 2>/dev/null || true; rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home"
export OMARCHY_TEST_DESKTOP_LOG="$test_tmp/desktop.log"
mkdir -p "$HOME/.config/omarchy" "$test_tmp/bin" "$test_tmp/dotfiles with spaces"
export TMPDIR="$test_tmp/staging"
mkdir -p "$TMPDIR"

cat >"$test_tmp/bin/gsettings" <<'SH'
#!/bin/bash
if [[ $1 == "get" && $3 == "font-name" ]]; then
  echo "'Adwaita Sans 11'"
else
  printf '%s\n' "$*" >>"$OMARCHY_TEST_DESKTOP_LOG"
fi
SH
cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$test_tmp/bin/cp" <<'SH'
#!/bin/bash
if [[ ${OMARCHY_TEST_FAIL_STAGE:-} == "attributes" && $1 == "--attributes-only" ]]; then
  exit 71
fi
command -p cp "$@"
SH
for command in awk mv; do
  cat >"$test_tmp/bin/$command" <<'SH'
#!/bin/bash
command_name=${0##*/}
if [[ ${*: -1} == "$OMARCHY_TEST_SETTINGS_TARGET" &&
  ( $command_name == "awk" && ${OMARCHY_TEST_FAIL_STAGE:-} == "transform" ||
    $command_name == "mv" && ${OMARCHY_TEST_FAIL_STAGE:-} == "publish" ) ]]; then
  exit 72
fi
command -p "$command_name" "$@"
SH
done
chmod +x "$test_tmp/bin"/*
export PATH="$test_tmp/bin:$PATH"

settings="$HOME/.config/omarchy/shell.toml"
target="$test_tmp/dotfiles with spaces/shell.toml"
export OMARCHY_TEST_SETTINGS_TARGET="$target"
printf '[font]\nbase-size = 12\nfamily = "keep-me"\n[bar]\nheight = 30\n' >"$target"
chmod 640 "$target"
expected_mode=640
expected_owner=$(stat -c '%u:%g' "$target")
relative_target=$(realpath --relative-to="$(dirname "$settings")" "$target")
ln -s "$relative_target" "$settings"

assert_config_preserved() {
  [[ -L $settings && $(readlink "$settings") == "$relative_target" ]] || fail "text sizing preserves the settings symlink"
  [[ $(stat -c '%a' "$target") == "$expected_mode" ]] || fail "text sizing preserves file modes"
  [[ $(stat -c '%u:%g' "$target") == "$expected_owner" ]] || fail "text sizing preserves file ownership"
  grep -Fxq 'family = "keep-me"' "$target" || fail "text sizing preserves other font settings"
  grep -Fxq 'height = 30' "$target" || fail "text sizing preserves other sections"
}

"$ROOT/bin/omarchy-display-text-size" 16
assert_config_preserved
grep -Fxq 'base-size = 16' "$target" || fail "text sizing updates the settings referent"
pass "setting text size preserves the symlink, access metadata and unrelated settings"

"$ROOT/bin/omarchy-display-text-size" reset
assert_config_preserved
if grep -q 'base-size' "$target"; then fail "reset removes the size override from the referent"; fi
pass "resetting text size preserves the symlink and access metadata"

cp "$target" "$test_tmp/original"
for action in 16 reset; do
  for stage in transform attributes publish; do
    : >"$OMARCHY_TEST_DESKTOP_LOG"
    if OMARCHY_TEST_FAIL_STAGE="$stage" "$ROOT/bin/omarchy-display-text-size" "$action" >"$test_tmp/output" 2>&1; then
      fail "text sizing must propagate a failure during $stage"
    fi
    cmp -s "$target" "$test_tmp/original" || fail "failed text sizing preserves the original settings"
    assert_config_preserved
    [[ ! -s $OMARCHY_TEST_DESKTOP_LOG ]] || fail "failed config publication must stop GTK changes"
    for candidate in "$target".* "$TMPDIR"/*; do
      [[ ! -e $candidate ]] || fail "failed text sizing leaves no temporary config files" "$candidate"
    done
  done
done
pass "failed settings publication leaves the original intact and stops desktop changes"

# Keep optional metadata checks separate: the core symlink and mode tests above
# must run even when the host has no ACL tools or the filesystem lacks xattrs.
if command -v setfacl >/dev/null && command -v getfacl >/dev/null &&
  setfacl -m u:65534:r "$target" 2>/dev/null; then
  acl_supported=true
  expected_acl=$(getfacl -cpn "$target")
  for action in 16 reset; do
    "$ROOT/bin/omarchy-display-text-size" "$action"
    assert_config_preserved
    [[ $(getfacl -cpn "$target") == "$expected_acl" ]] || fail "text sizing preserves named ACL entries"
  done
  pass "setting and resetting text size preserve named ACL entries"
else
  acl_supported=false
  skip "ACL preservation needs ACL tools and filesystem support"
fi

if command -v python3 >/dev/null && python3 - "$target" 2>/dev/null <<'PY'
import os, sys
os.setxattr(sys.argv[1], 'user.omarchy-test', b'keep-me')
PY
then
  xattr_supported=true
  for action in 16 reset; do
    "$ROOT/bin/omarchy-display-text-size" "$action"
    assert_config_preserved
    python3 - "$target" <<'PY'
import os, sys
assert os.getxattr(sys.argv[1], 'user.omarchy-test') == b'keep-me'
PY
  done
  pass "setting and resetting text size preserve extended attributes"
else
  xattr_supported=false
  skip "extended attribute preservation needs Python and filesystem support"
fi

alternate_group=""
for group in $(id -G); do
  if [[ $group != "$(id -g)" ]]; then
    alternate_group=$group
    break
  fi
done
if [[ -n $alternate_group ]]; then
  chgrp "$alternate_group" "$target"
  expected_owner=$(stat -c '%u:%g' "$target")
  for action in 16 reset; do
    "$ROOT/bin/omarchy-display-text-size" "$action"
    assert_config_preserved
  done
  pass "setting and resetting text size preserve supplemental-group ownership"
else
  skip "supplemental-group preservation needs membership in a second group"
fi

# Map another UID in a disposable user namespace without sudo or creating an
# account. Back in the test process the file is owned by that UID and writable
# through the caller's group, reproducing shared dotfiles owned by another user.
shared_fixtures=false
if (( EUID != 0 )) && command -v unshare >/dev/null; then
  probe=$(mktemp "$test_tmp/dotfiles with spaces/ownership-probe.XXXXXX")
  if unshare --user --map-auto --map-root-user chown 1:0 "$probe" 2>/dev/null &&
    unshare --user --map-auto --map-root-user chown 0:1 "$probe" 2>/dev/null; then
    shared_fixtures=true
  fi
  rm -f "$probe"
fi
if $shared_fixtures; then
  rm "$target"
  printf '[font]\nbase-size = 12\nfamily = "keep-me"\n[bar]\nheight = 30\n' >"$target"
  chmod 660 "$target"
  chgrp "$(id -g)" "$target"
  expected_mode=660
  if $acl_supported; then
    setfacl -m u:65534:r,g::rw "$target"
    shared_acl=$(getfacl -cpn "$target")
  fi
  if $xattr_supported; then
    python3 - "$target" <<'PY'
import os, sys
os.setxattr(sys.argv[1], 'user.omarchy-test', b'keep-me')
PY
  fi
  for ownership in 1:0 0:1; do
    unshare --user --map-auto --map-root-user chown "$ownership" "$target"
    [[ -w $target ]] || fail "shared-file fixture is writable"
    expected_owner=$(stat -c '%u:%g' "$target")
    expected_inode=$(stat -c '%d:%i' "$target")
    cp "$target" "$test_tmp/shared-original"
    if [[ $ownership == "1:0" ]]; then
      [[ ! -O $target ]] || fail "shared-file fixture has a different owner"
    else
      [[ " $(id -G) " != *" $(stat -c '%g' "$target") "* ]] || fail "shared-file fixture has a group the caller cannot assign"
    fi
    for action in 16 reset; do
      : >"$OMARCHY_TEST_DESKTOP_LOG"
      if "$ROOT/bin/omarchy-display-text-size" "$action" >"$test_tmp/output" 2>&1; then
        fail "text sizing must refuse an update that cannot preserve ownership"
      fi
      assert_config_preserved
      cmp -s "$target" "$test_tmp/shared-original" || fail "a refused update preserves the original content"
      grep -Fq 'Cannot preserve owner/group' "$test_tmp/output" || fail "a refused update explains the ownership constraint"
      [[ ! -s $OMARCHY_TEST_DESKTOP_LOG ]] || fail "a refused update stops GTK changes"
      [[ $(stat -c '%d:%i' "$target") == "$expected_inode" ]] || fail "text sizing preserves the shared file's inode"
      if $acl_supported; then
        [[ $(getfacl -cpn "$target") == "$shared_acl" ]] || fail "shared config retains its ACL"
      fi
      if $xattr_supported; then
        python3 - "$target" <<'PY'
import os, sys
assert os.getxattr(sys.argv[1], 'user.omarchy-test') == b'keep-me'
PY
      fi
      for candidate in "$target".*; do
        [[ ! -e $candidate ]] || fail "refused ownership updates leave no temporary files"
      done
    done
  done
  pass "setting and resetting text size refuse inaccessible ownership without changing shared configs"

  chmod 550 "$(dirname "$target")"
  for action in 16 reset; do
    : >"$OMARCHY_TEST_DESKTOP_LOG"
    if "$ROOT/bin/omarchy-display-text-size" "$action" >"$test_tmp/output" 2>&1; then
      fail "text sizing must refuse publication in a read-only directory"
    fi
    assert_config_preserved
    cmp -s "$target" "$test_tmp/shared-original" || fail "a refused publication preserves the original content"
    grep -Fq 'Cannot stage a text-size update' "$test_tmp/output" || fail "a refused publication explains the directory constraint"
    [[ ! -s $OMARCHY_TEST_DESKTOP_LOG ]] || fail "a refused publication stops GTK changes"
    [[ $(stat -c '%d:%i' "$target") == "$expected_inode" ]] || fail "text sizing preserves an inode in a read-only directory"
    for candidate in "$TMPDIR"/*; do
      [[ ! -e $candidate ]] || fail "shared config updates leave no temporary files"
    done
  done
  chmod 700 "$(dirname "$target")"
  pass "setting and resetting text size refuse read-only directories without changing the config"
else
  skip "shared ownership fixtures need an unprivileged caller and user namespace UID mapping"
fi

rm "$settings"
for mode in 600 640 644 664; do
  printf '[font]\nbase-size = 12\n' >"$settings"
  chmod "$mode" "$settings"
  "$ROOT/bin/omarchy-display-text-size" 16
  [[ $(stat -c '%a' "$settings") == "$mode" ]] || fail "text sizing preserves a regular file's mode"
  "$ROOT/bin/omarchy-display-text-size" reset
  [[ $(stat -c '%a' "$settings") == "$mode" ]] || fail "text size reset preserves a regular file's mode"
done
pass "setting and resetting text size preserve regular config file modes"

rm "$settings"
"$ROOT/bin/omarchy-display-text-size" 16
grep -Fxq 'base-size = 16' "$settings" || fail "text sizing still creates a missing config"
pass "setting text size still creates a missing config"
