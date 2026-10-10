#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

root=$tmpdir/root
mkdir -p "$root/etc/pacman.d/hooks" "$root/usr/share/polkit-1/actions" "$root/opt/1Password" \
  "$root/usr/local/bin" "$root/usr/share/omarchy/default/libalpm/hooks" "$tmpdir/bin"
cp "$ROOT/default/libalpm/hooks/90-omarchy-1password-finish.hook" \
  "$root/usr/share/omarchy/default/libalpm/hooks/"

cat >"$root/etc/passwd" <<'EOF'
root:x:0:0:root:/root:/bin/bash
alice:x:1000:1000:Alice:/home/alice:/bin/bash
bob:x:1001:1001:Bob:/home/bob:/bin/bash
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
EOF

cat >"$root/usr/share/polkit-1/actions/com.1password.1Password.policy" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/software/polkit/policyconfig-1.dtd">
<policyconfig>
  <action id="com.1password.1Password.authorizeCLI">
    <annotate key="org.freedesktop.policykit.owner">unix-user:packager </annotate>
  </action>
  <action id="com.1password.1Password.authorizeSshAgent">
    <annotate key="org.freedesktop.policykit.owner">unix-user:packager </annotate>
  </action>
</policyconfig>
EOF

: >"$root/opt/1Password/1Password-BrowserSupport"
: >"$root/opt/1Password/1password-mcp"
chmod 755 "$root/opt/1Password/1Password-BrowserSupport" "$root/opt/1Password/1password-mcp"

cat >"$tmpdir/bin/sudo" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_SUDO_LOG"
cmd=$1
shift
# Drop bare "--" separators used by the helper.
filtered=()
for arg in "$@"; do
  [[ $arg == -- ]] && continue
  filtered+=("$arg")
done
set -- "${filtered[@]}"
case $cmd in
groupadd)
  printf '%s\n' "${@: -1}" >>"$OMARCHY_TEST_GROUPS"
  ;;
chgrp)
  printf '%s %s\n' "$1" "${@: -1}" >>"$OMARCHY_TEST_CHGRP"
  ;;
chmod)
  printf '%s %s\n' "$1" "${@: -1}" >>"$OMARCHY_TEST_CHMOD"
  ;;
install)
  src=${*: -2:1}
  dest=${*: -1}
  mkdir -p "$(dirname "$dest")"
  cp -- "$src" "$dest"
  ;;
ln)
  target=${*: -2:1}
  link=${*: -1}
  ln -sfn -- "$target" "$link"
  ;;
esac
SH
chmod +x "$tmpdir/bin/sudo"

cat >"$tmpdir/bin/getent" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$tmpdir/bin/getent"

helper=$tmpdir/bin/omarchy-1password-finish-install
sed \
  -e "s#^POLICY=.*#POLICY=$root/usr/share/polkit-1/actions/com.1password.1Password.policy#" \
  -e "s#^OPT_DIR=.*#OPT_DIR=$root/opt/1Password#" \
  -e "s#^OMARCHY_PATH=.*#OMARCHY_PATH=$root/usr/share/omarchy#" \
  -e "s#^HOOK_DST=.*#HOOK_DST=$root/etc/pacman.d/hooks/90-omarchy-1password-finish.hook#" \
  -e "s#/etc/passwd#$root/etc/passwd#g" \
  -e "s#/usr/local/bin#$root/usr/local/bin#g" \
  "$ROOT/bin/omarchy-1password-finish-install" >"$helper"
chmod +x "$helper"

sudo_log=$tmpdir/sudo.log
groups_log=$tmpdir/groups.log
chgrp_log=$tmpdir/chgrp.log
chmod_log=$tmpdir/chmod.log
: >"$sudo_log" >"$groups_log" >"$chgrp_log" >"$chmod_log"

PATH="$tmpdir/bin:/usr/bin:/bin" \
  OMARCHY_SUDO="$tmpdir/bin/sudo" \
  OMARCHY_TEST_SUDO_LOG="$sudo_log" \
  OMARCHY_TEST_GROUPS="$groups_log" \
  OMARCHY_TEST_CHGRP="$chgrp_log" \
  OMARCHY_TEST_CHMOD="$chmod_log" \
  bash "$helper"

policy=$(cat "$root/usr/share/polkit-1/actions/com.1password.1Password.policy")
grep -Fq 'unix-user:packager' <<<"$policy" &&
  fail "finish-install left the build-host polkit owner" "$policy"
grep -Fq 'unix-user:alice' <<<"$policy" ||
  fail "finish-install did not install local polkit owners" "$policy"
grep -Fq 'unix-user:bob' <<<"$policy" ||
  fail "finish-install omitted the second local polkit owner" "$policy"
pass "finish-install rewrites polkit owners to local human users"

grep -Fxq onepassword "$groups_log" || fail "finish-install creates the onepassword group"
grep -Fxq onepassword-mcp "$groups_log" || fail "finish-install creates the onepassword-mcp group"
pass "finish-install ensures helper groups"

grep -Fq "onepassword $root/opt/1Password/1Password-BrowserSupport" "$chgrp_log" ||
  fail "finish-install chgrps BrowserSupport" "$(cat "$chgrp_log")"
grep -Fq "onepassword-mcp $root/opt/1Password/1password-mcp" "$chgrp_log" ||
  fail "finish-install chgrps the MCP binary" "$(cat "$chgrp_log")"
grep -Fq "g+s $root/opt/1Password/1Password-BrowserSupport" "$chmod_log" ||
  fail "finish-install setgids BrowserSupport" "$(cat "$chmod_log")"
grep -Fq "g+s $root/opt/1Password/1password-mcp" "$chmod_log" ||
  fail "finish-install setgids the MCP binary" "$(cat "$chmod_log")"
pass "finish-install applies setgid helper ownership"

[[ -L $root/opt/1Password/onepassword-mcp ]] ||
  fail "finish-install links the legacy MCP name"
[[ -L $root/usr/local/bin/1password-mcp ]] ||
  fail "finish-install links MCP into /usr/local/bin"
pass "finish-install creates MCP convenience links"

[[ -f $root/etc/pacman.d/hooks/90-omarchy-1password-finish.hook ]] ||
  fail "finish-install installs a post-transaction repair hook"
grep -Fq 'Target = 1password' "$root/etc/pacman.d/hooks/90-omarchy-1password-finish.hook" ||
  fail "repair hook targets the 1password package"
grep -Fq 'omarchy-1password-finish-install' "$root/etc/pacman.d/hooks/90-omarchy-1password-finish.hook" ||
  fail "repair hook re-runs the finish helper"
pass "finish-install installs an alpm hook that survives package upgrades"

# A locally managed /usr/local/bin/1password-mcp must not be replaced.
# Remove the symlink first: on macOS, > through a symlink overwrites the target.
rm -f "$root/usr/local/bin/1password-mcp"
printf '#!/bin/bash\necho local-wrapper\n' >"$root/usr/local/bin/1password-mcp"
chmod 755 "$root/usr/local/bin/1password-mcp"
: >"$sudo_log" >"$groups_log" >"$chgrp_log" >"$chmod_log"
PATH="$tmpdir/bin:/usr/bin:/bin" \
  OMARCHY_SUDO="$tmpdir/bin/sudo" \
  OMARCHY_TEST_SUDO_LOG="$sudo_log" \
  OMARCHY_TEST_GROUPS="$groups_log" \
  OMARCHY_TEST_CHGRP="$chgrp_log" \
  OMARCHY_TEST_CHMOD="$chmod_log" \
  bash "$helper" >"$tmpdir/preserve.out" 2>&1
[[ -f $root/usr/local/bin/1password-mcp && ! -L $root/usr/local/bin/1password-mcp ]] ||
  fail "finish-install replaced a locally managed MCP command"
grep -Fq 'local-wrapper' "$root/usr/local/bin/1password-mcp" ||
  fail "finish-install altered the locally managed MCP command contents"
grep -Fq 'leaving' "$tmpdir/preserve.out" ||
  fail "finish-install should report when it leaves a local MCP command alone"
pass "finish-install preserves a locally managed MCP command"

# Install helper must call the finish step after packaging.
grep -Eq 'omarchy-1password-finish-install' "$ROOT/bin/omarchy-install-service-1password" ||
  fail "1password install does not run the finish helper"
pass "1password install runs the finish helper after pkg add"

[[ -f $ROOT/default/libalpm/hooks/90-omarchy-1password-finish.hook ]] ||
  fail "missing packaged hook source for 1password repair"
pass "1password repair hook source is present under default/libalpm/hooks"
