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
pass "deployment rejects writable package ancestry and remains idempotent across users"
