#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

shipped_migration="$ROOT/migrations/1792608528.sh"
[[ -f $shipped_migration ]] || fail "plymouth theme ownership migration exists at $shipped_migration"

mapfile -t plymouth_owner_migrations < <(grep -RIlF '/usr/share/plymouth/themes/omarchy' "$ROOT/migrations")
(( ${#plymouth_owner_migrations[@]} == 1 )) && [[ ${plymouth_owner_migrations[0]} == "$shipped_migration" ]] ||
  fail "one migration exclusively reclaims the Plymouth theme directory" "${plymouth_owner_migrations[*]}"
pass "one migration exclusively reclaims the Plymouth theme directory"

grep -Fq '/usr/share/sddm/themes/omarchy' "$shipped_migration" ||
  fail "the migration also reclaims the SDDM theme directory"
grep -Fq 'chown root:root' "$shipped_migration" ||
  fail "the migration restores root ownership"
grep -Fq 'chmod 755' "$shipped_migration" ||
  fail "the migration restores a non-writable mode"
grep -Fq 'symlink' "$shipped_migration" ||
  fail "the migration refuses to chown through a symlink"
pass "migration reclaims ownership without following symlinks"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

export CALLS="$test_dir/calls"
: >"$CALLS"

mkdir -p "$test_dir/bin" "$test_dir/usr/share/plymouth/themes" "$test_dir/usr/share/sddm/themes"
plymouth="$test_dir/usr/share/plymouth/themes/omarchy"
sddm="$test_dir/usr/share/sddm/themes/omarchy"

cat >"$test_dir/bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALLS"
exec "$@"
STUB

cat >"$test_dir/bin/chown" <<'STUB'
#!/bin/bash
printf 'chown %s\n' "$*" >>"$CALLS"
STUB

cat >"$test_dir/bin/chmod" <<'STUB'
#!/bin/bash
printf 'chmod %s\n' "$*" >>"$CALLS"
# Do not invoke the platform chmod: GNU migrations pass -- which BSD chmod
# rejects, and the assertions only care that the migration requested 755.
STUB

cat >"$test_dir/bin/install" <<'STUB'
#!/bin/bash
printf 'install %s\n' "$*" >>"$CALLS"
cp -f -- "${@: -2:1}" "${@: -1}"
STUB

cat >"$test_dir/bin/stat" <<STUB
#!/bin/bash
path=\${@: -1}
if [[ \$1 == "-c" && \$2 == "%u" && ( \$path == "$plymouth" || \$path == "$sddm" ) ]]; then
  if grep -qF "chown root:root -- \$path" "\$CALLS" 2>/dev/null; then
    echo 0
  else
    echo 1000
  fi
  exit 0
fi
if [[ \$1 == "-c" && \$2 == "%a" ]]; then
  # GNU-style mode bits; macOS /usr/bin/stat does not support -c.
  if [[ -d \$path ]]; then
    python3 -c "import os,stat as s; print(oct(s.S_IMODE(os.stat('\$path').st_mode))[2:])"
  else
    echo 755
  fi
  exit 0
fi
exec /usr/bin/stat "\$@"
STUB

chmod +x "$test_dir/bin/"*

migration="$test_dir/migration.sh"
sed \
  -e "s|/usr/share/plymouth/themes/omarchy|$plymouth|g" \
  -e "s|/usr/share/sddm/themes/omarchy|$sddm|g" \
  "$shipped_migration" >"$migration"

: >"$CALLS"
PATH="$test_dir/bin:/usr/bin:/bin" bash -euo pipefail "$migration"
[[ ! -s $CALLS ]] || fail "missing theme directories do not escalate" "$(cat "$CALLS")"
pass "missing theme directories are a no-op"

mkdir -m 0700 "$plymouth" "$sddm"
echo "user script" >"$plymouth/omarchy.script"
: >"$CALLS"
PATH="$test_dir/bin:/usr/bin:/bin" bash -euo pipefail "$migration"
grep -qxF "sudo chown root:root -- $plymouth" "$CALLS" ||
  fail "migration chowns the Plymouth theme dir" "$(cat "$CALLS")"
grep -qxF "sudo chown root:root -- $sddm" "$CALLS" ||
  fail "migration chowns the SDDM theme dir" "$(cat "$CALLS")"
grep -qxF "sudo chmod 755 -- $plymouth" "$CALLS" ||
  fail "migration chmods the Plymouth theme dir" "$(cat "$CALLS")"
grep -qxF "sudo chmod 755 -- $sddm" "$CALLS" ||
  fail "migration chmods the SDDM theme dir" "$(cat "$CALLS")"
pass "user-owned theme directories are reclaimed"

grep -qE "^sudo install -o root -g root -m 0644 -T -- $plymouth/omarchy.script $plymouth/\.omarchy\.script\.omarchy-new\.[A-Za-z0-9]+\$" "$CALLS" ||
  fail "migration copies a user-owned file to a root-owned replacement" "$(cat "$CALLS")"
grep -qE "^sudo mv -fT -- $plymouth/\.omarchy\.script\.omarchy-new\.[A-Za-z0-9]+ $plymouth/omarchy.script\$" "$CALLS" ||
  fail "migration moves the replacement over the user-owned file" "$(cat "$CALLS")"
[[ $(cat "$plymouth/omarchy.script") == "user script" ]] ||
  fail "the replaced file keeps its contents"
! grep -q "chown .*omarchy.script" "$CALLS" || fail "migration replaces files rather than chowning them" "$(cat "$CALLS")"
pass "user-owned files in a reclaimed theme directory are replaced"

cat >"$test_dir/bin/stat" <<'STUB'
#!/bin/bash
path=${@: -1}
if [[ $1 == "-c" && $2 == "%u" ]]; then
  echo 0
  exit 0
fi
if [[ $1 == "-c" && $2 == "%a" ]]; then
  python3 -c "import os,stat as s,sys; print(oct(s.S_IMODE(os.stat(sys.argv[1]).st_mode))[2:])" "$path"
  exit 0
fi
exec /usr/bin/stat "$@"
STUB
chmod +x "$test_dir/bin/stat"
rm -f -- "$plymouth/omarchy.script"
# Use the platform chmod via env -PATH so the stub is not selected.
env PATH=/usr/bin:/bin chmod 755 "$plymouth" "$sddm" 2>/dev/null || env PATH=/bin:/usr/bin chmod 755 "$plymouth" "$sddm"
: >"$CALLS"
PATH="$test_dir/bin:/usr/bin:/bin" bash -euo pipefail "$migration"
[[ ! -s $CALLS ]] || fail "root-owned theme directories are left alone" "$(cat "$CALLS")"
pass "root-owned theme directories are left alone"

# A run interrupted between the chown and the chmod leaves a root-owned 0700 directory.
env PATH=/usr/bin:/bin chmod 700 "$plymouth"
: >"$CALLS"
PATH="$test_dir/bin:/usr/bin:/bin" bash -euo pipefail "$migration"
grep -qxF "sudo chmod 755 -- $plymouth" "$CALLS" ||
  fail "a root-owned 0700 theme dir is opened back up" "$(cat "$CALLS")"
env PATH=/usr/bin:/bin chmod 755 "$plymouth"
pass "a root-owned 0700 theme dir is opened back up"

# A run interrupted after the directory was reclaimed leaves user-owned files in a root-owned one.
echo "user logo" >"$plymouth/logo.png"
: >"$CALLS"
PATH="$test_dir/bin:/usr/bin:/bin" bash -euo pipefail "$migration"
grep -qE "^sudo install -o root -g root -m 0644 -T -- $plymouth/logo.png " "$CALLS" ||
  fail "user-owned files in a root-owned theme dir are still replaced" "$(cat "$CALLS")"
! grep -qE "chown|chmod" "$CALLS" || fail "a root-owned 0755 theme dir is not touched again" "$(cat "$CALLS")"
rm -f -- "$plymouth/logo.png"
pass "user-owned files in a root-owned theme dir are still replaced"

cat >"$test_dir/bin/find" <<'STUB'
#!/bin/bash
exit 1
STUB
chmod +x "$test_dir/bin/find"
if PATH="$test_dir/bin:/usr/bin:/bin" bash -euo pipefail "$migration" >/dev/null 2>&1; then
  fail "a failed file scan fails the migration"
fi
rm -f -- "$test_dir/bin/find"
pass "a failed file scan fails the migration"

rm -rf "$plymouth" "$sddm"
mkdir -p "$test_dir/elsewhere"
mkdir -m 0700 "$test_dir/elsewhere/omarchy"
ln -s "$test_dir/elsewhere/omarchy" "$plymouth"
: >"$CALLS"
PATH="$test_dir/bin:/usr/bin:/bin" bash -euo pipefail "$migration"
! grep -q chown "$CALLS" || fail "migration does not chown through a symlink" "$(cat "$CALLS")"
pass "symlink theme directories are left alone"
