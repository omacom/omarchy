#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command tar
require_command zstd

# Everything the commands touch lives under WORK: the fake homes, the stub bin
# directory, the call logs. The real HOME is never read or written.
WORK=$(mktemp -d)
trap 'chmod -R u+w "$WORK" 2>/dev/null || true; rm -rf "$WORK"' EXIT

unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME HYPRLAND_INSTANCE_SIGNATURE OMARCHY_TRANSFER_TMPDIR
export OMARCHY_PATH=$ROOT
export HOME=$WORK/nohome
export XDG_RUNTIME_DIR=$WORK/run
export STUB_DIR=$WORK/stubdata
export OMARCHY_TRANSFER_CONF=$WORK/transfer.conf
export OMARCHY_TRANSFER_NM_DIR=$WORK/nm
export OMARCHY_TRANSFER_IWD_DIR=$WORK/iwd
export EDITOR=true
STUBS=$WORK/stubs
mkdir -p "$HOME" "$XDG_RUNTIME_DIR" "$STUB_DIR" "$STUBS" "$WORK/out" "$OMARCHY_TRANSFER_NM_DIR" "$OMARCHY_TRANSFER_IWD_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
: >"$STUB_DIR/installed"

# The stubs record what they were asked to do and pretend to succeed. Package
# state lives in $STUB_DIR: official/aur (what the old machine had installed),
# repo (pacman -Slq), installed (what the new machine has), failpkgs (names
# whose install fails), backend (networkmanager|iwd|none).
cat >"$WORK/pkg-install" <<'SH'
#!/bin/bash
tool=$1
shift
echo "$*" >>"$STUB_DIR/$tool.log"
pkgs=()
for a in "$@"; do
  [[ $a == -* ]] || pkgs+=("$a")
done
for p in "${pkgs[@]}"; do
  if grep -qxF -- "$p" "$STUB_DIR/failpkgs" 2>/dev/null; then
    echo "error: target not installable: $p" >&2
    exit 1
  fi
done
printf '%s\n' "${pkgs[@]}" >>"$STUB_DIR/installed"
SH
cat >"$STUBS/pacman" <<'SH'
#!/bin/bash
case ${1:-} in
  -Qqen) cat "$STUB_DIR/official" 2>/dev/null || true ;;
  -Qqem) cat "$STUB_DIR/aur" 2>/dev/null || true ;;
  -Slq) cat "$STUB_DIR/repo" 2>/dev/null || true ;;
  -S*) exec "$WORK/pkg-install" pacman "$@" ;;
  -Q*)
    pkgs=()
    for a in "${@:2}"; do
      [[ $a == -* ]] || pkgs+=("$a")
    done
    if (( ${#pkgs[@]} == 0 )); then
      cat "$STUB_DIR/installed" 2>/dev/null || true
      exit 0
    fi
    for p in "${pkgs[@]}"; do
      grep -qxF -- "$p" "$STUB_DIR/installed" 2>/dev/null || exit 1
    done
    ;;
esac
exit 0
SH
cat >"$STUBS/yay" <<'SH'
#!/bin/bash
exec "$WORK/pkg-install" yay "$@"
SH
cat >"$STUBS/sudo" <<'SH'
#!/bin/bash
while [[ ${1:-} == -* ]]; do shift; done
(( $# > 0 )) || exit 0
echo "$*" >>"$STUB_DIR/sudo.log"
case $1 in
  chown) exit 0 ;;
esac
exec "$@"
SH
cat >"$STUBS/systemctl" <<'SH'
#!/bin/bash
echo "$*" >>"$STUB_DIR/systemctl.log"
backend=$(cat "$STUB_DIR/backend" 2>/dev/null || echo none)
if [[ $* == *is-active* ]]; then
  [[ $* == *NetworkManager* && $backend == networkmanager ]] && { echo active; exit 0; }
  [[ $* == *iwd* && $backend == iwd ]] && { echo active; exit 0; }
  echo inactive
  exit 3
fi
exit 0
SH
for s in hyprctl nmcli omarchy-notification-send omarchy-launch-config-editor; do
  cat >"$STUBS/$s" <<SH
#!/bin/bash
echo "\$*" >>"\$STUB_DIR/$s.log"
SH
done
# Nothing may prompt: a stray gum call fails the command instead of hanging.
cat >"$STUBS/gum" <<'SH'
#!/bin/bash
echo "$*" >>"$STUB_DIR/gum.log"
exit 1
SH
chmod +x "$WORK/pkg-install" "$STUBS"/*
export WORK
export PATH=$STUBS:$ROOT/bin:$PATH

OUT=""
RC=0

# tx <home> <command> [args...]: run omarchy-transfer-<command> with HOME=<home>
# and no terminal; sets OUT (stdout+stderr) and RC.
tx() {
  local home=$1 cmd=$2
  shift 2
  RC=0
  OUT=$(env HOME="$home" timeout 120 "$ROOT/bin/omarchy-transfer-$cmd" "$@" 2>&1 </dev/null) || RC=$?
}

rc_is() {
  (( RC == $1 )) || fail "$2" "expected exit $1, got $RC: $(head -c 1200 <<<"$OUT")"
  pass "$2"
}

rc_fails() {
  (( RC != 0 )) || fail "$1" "expected a non-zero exit: $(head -c 1200 <<<"$OUT")"
  pass "$1"
}

out_has() {
  grep -qiE -- "$1" <<<"$OUT" || fail "$2" "output lacks /$1/: $(head -c 1200 <<<"$OUT")"
  pass "$2"
}

out_lacks() {
  if grep -qiE -- "$1" <<<"$OUT"; then
    fail "$2" "output unexpectedly matches /$1/: $(head -c 1200 <<<"$OUT")"
  fi
  pass "$2"
}

is_file() {
  [[ -e $1 || -L $1 ]] || fail "$2" "missing $1"
  pass "$2"
}

no_file() {
  [[ ! -e $1 && ! -L $1 ]] || fail "$2" "unexpected $1"
  pass "$2"
}

content_is() { # path expected description
  local got=""
  [[ -f $1 ]] && got=$(<"$1")
  [[ $got == "$2" ]] || fail "$3" "$1: expected '$2', got '$got'"
  pass "$3"
}

equal() { # expected actual description
  [[ $1 == "$2" ]] || fail "$3" "expected '$1', got '$2'"
  pass "$3"
}

# Type, size, mode and link target of everything below a home, minus the cache
# directory the commands stage in. Detects any change to what a failed command
# should have left alone.
snapshot() {
  (cd "$1" && find . -mindepth 1 -path ./.cache -prune -o -printf '%p|%y|%s|%m|%l\n' | sort)
}

# A sample home: config with cache and node_modules to exclude, a secret, an
# executable, a symlink, odd file names. Pictures is intentionally absent.
populate_home() {
  local h=$1
  mkdir -p "$h/.config/app/.cache" "$h/.config/app/node_modules" "$h/.ssh" "$h/Documents/proj/node_modules" "$h/Documents/private"
  echo "key=value" >"$h/.config/app/settings.conf"
  chmod 600 "$h/.config/app/settings.conf"
  echo junk >"$h/.config/app/.cache/junk"
  echo mod >"$h/.config/app/node_modules/m.js"
  echo "export A=1" >"$h/.bashrc"
  echo doc >"$h/Documents/a.txt"
  echo spaced >"$h/Documents/with space & ümlaut.txt"
  printf '#!/bin/bash\necho hi\n' >"$h/Documents/run.sh"
  chmod 755 "$h/Documents/run.sh"
  echo nm >"$h/Documents/proj/node_modules/x"
  echo hidden >"$h/Documents/private/secret.txt"
  echo SECRETKEY >"$h/.ssh/id_test"
  chmod 600 "$h/.ssh/id_test"
  ln -s settings.conf "$h/.config/app/link"
}

# Write the config the export reads: write_conf <packages> <wifi> <encrypt> [extra include lines...]
write_conf() {
  local packages=$1 wifi=$2 encrypt=$3
  shift 3
  {
    echo "[options]"
    echo "packages = $packages"
    echo "wifi = $wifi"
    echo "encrypt = $encrypt"
    echo
    echo "[include]"
    printf '%s\n' .config .ssh .bashrc Documents Pictures
    (( $# == 0 )) || printf '%s\n' "$@"
    echo
    echo "[exclude]"
    printf '%s\n' .cache '*/.cache' node_modules '*/node_modules' .local/share/Trash
  } >"$OMARCHY_TRANSFER_CONF"
}

# Newest archive in a directory.
newest_archive() {
  find "$1" -maxdepth 1 -name 'omarchy-transfer-*.tar.zst*' ! -name '.*' | sort | tail -n1
}

# Member list of an unencrypted archive.
archive_list() {
  zstd -dc -- "$1" | tar -t
}

# A hand-built archive for the import side. new_case makes a meta tree M, a
# home tree T (the archive's home/ members) and a destination home D.
new_case() {
  CASE=$WORK/case.$1
  rm -rf "$CASE"
  M=$CASE/meta
  T=$CASE/tree/home
  D=$CASE/dest
  mkdir -p "$M/omarchy-transfer" "$T" "$D"
  printf 'format=2\nomarchy_version=test\ndate=2026-01-01T00:00:00+00:00\nhost=testhost\nuser=tester\nhome=%s\nencrypted=no\nwifi=none\n' "$D" >"$M/omarchy-transfer/meta"
  : >"$M/omarchy-transfer/pristine.list"
  : >"$M/omarchy-transfer/transfer.conf"
}

# mk_archive <out>: pack M and T into a format-2 archive.
mk_archive() {
  tar -cf - -C "$M" omarchy-transfer -C "$CASE/tree" home | zstd -q -3 -f --check -o "$1"
}

# pty_run <input-text> <cmd...>: run in a pseudo terminal, one input line per second.
pty_run() {
  local input=$1 cmdline line
  shift
  command -v script >/dev/null || return 1
  printf -v cmdline '%q ' "$@"
  PTY_OUT=$WORK/pty-out.$RANDOM
  RC=0
  {
    while IFS= read -r line; do
      sleep 1
      printf '%s\n' "$line"
    done <<<"$input"
    sleep 1
  } | timeout 90 script -qec "$cmdline" /dev/null >"$PTY_OUT" 2>&1 || RC=${PIPESTATUS[1]}
  OUT=$(tr -d '\r' <"$PTY_OUT")
}

SRC=$WORK/src
mkdir -p "$SRC"
populate_home "$SRC"
XATTR=no
if command -v setfattr >/dev/null && setfattr -n user.omt -v hello "$SRC/.config/app/settings.conf" 2>/dev/null; then
  XATTR=yes
fi
# A read-only directory must not break staging cleanup.
mkdir -p "$SRC/Documents/ro"
echo ro >"$SRC/Documents/ro/file"
chmod 555 "$SRC/Documents/ro"

# Export without any config creates it from the shipped default.
rm -f "$OMARCHY_TRANSFER_CONF"
mkdir -p "$WORK/out/noconf"
tx "$SRC" export --dry-run "$WORK/out/noconf"
rc_is 0 "export --dry-run works without a user config"
is_file "$OMARCHY_TRANSFER_CONF" "the missing config is created from the default"
grep -q '^\[include\]' "$OMARCHY_TRANSFER_CONF" || fail "the created config has an [include] section"
pass "the created config has an [include] section"
equal 0 "$(find "$WORK/out/noconf" -mindepth 1 | wc -l)" "a dry run writes nothing to the target"
out_has 'omarchy-transfer-restore\.sh' "the dry run lists the restore companion"
out_has 'omarchy-transfer-README\.txt' "the dry run lists the README companion"

sed -i 's/^encrypt = yes/encrypt = no/' "$OMARCHY_TRANSFER_CONF"
tx "$SRC" export "$WORK/out/noconf"
rc_is 0 "export works with the default config"
is_file "$(newest_archive "$WORK/out/noconf")" "the default config produces an archive"

write_conf no no no

echo "# export"
TARGET=$WORK/out/plain
mkdir -p "$TARGET"
tx "$SRC" export "$TARGET"
rc_is 0 "export succeeds"
ARCHIVE=$(newest_archive "$TARGET")
is_file "$ARCHIVE" "the archive is created"
[[ $ARCHIVE == *.tar.zst ]] || fail "an unencrypted archive ends in .tar.zst" "$ARCHIVE"
pass "an unencrypted archive ends in .tar.zst"
equal 0 "$(find "$TARGET" -mindepth 1 -name '.*' | wc -l)" "no .part file is left behind"
out_has '\.ssh' "the export warns that .ssh is skipped without encryption"
out_has 'Pictures' "the export notes the missing Pictures folder"

zstd -t -q "$ARCHIVE" || fail "the archive is a valid zstd stream with a checksum"
pass "the archive is a valid zstd stream with a checksum"
members=$(archive_list "$ARCHIVE")
for m in omarchy-transfer/meta omarchy-transfer/transfer.conf home/.bashrc home/Documents/a.txt home/.config/app/settings.conf; do
  grep -qx "$m" <<<"$members" || fail "member $m" "$members"
  pass "member $m"
done
if grep -q '^\.omarchy-transfer' <<<"$members"; then fail "new archives use the visible omarchy-transfer/ directory" "$members"; fi
pass "new archives use the visible omarchy-transfer/ directory"
if grep -qE '^home/\.ssh(/|$)' <<<"$members"; then fail "secrets stay out of an unencrypted archive"; fi
pass "secrets stay out of an unencrypted archive"
if grep -qE '(^|/)(\.cache|node_modules)(/|$)' <<<"$members"; then fail "excluded names are absent from the archive" "$members"; fi
pass "excluded names are absent from the archive"
for m in omarchy-transfer/restore.sh omarchy-transfer/README.txt; do
  grep -qx "$m" <<<"$members" || fail "member $m" "$members"
  pass "member $m"
done
echo "# companion files"
is_file "$TARGET/omarchy-transfer-restore.sh" "the restore companion is written"
is_file "$TARGET/omarchy-transfer-README.txt" "the README companion is written"
[[ -x $TARGET/omarchy-transfer-restore.sh ]] || fail "the restore companion is executable"
pass "the restore companion is executable"
equal 755 "$(stat -c %a "$TARGET/omarchy-transfer-restore.sh")" "the restore companion has mode 0755"
cmp -s "$ROOT/default/transfer/restore.sh" "$TARGET/omarchy-transfer-restore.sh" || fail "the restore companion matches the shipped restore.sh"
pass "the restore companion matches the shipped restore.sh"
cmp -s <(zstd -dc -- "$ARCHIVE" | tar -xO omarchy-transfer/restore.sh) "$TARGET/omarchy-transfer-restore.sh" || fail "the restore.sh member is byte-identical to the companion"
pass "the restore.sh member is byte-identical to the companion"
cmp -s <(zstd -dc -- "$ARCHIVE" | tar -xO omarchy-transfer/README.txt) "$TARGET/omarchy-transfer-README.txt" || fail "the README.txt member is byte-identical to the companion"
pass "the README.txt member is byte-identical to the companion"
meta=$(zstd -dc -- "$ARCHIVE" | tar -xO omarchy-transfer/meta)
grep -qx 'format=2' <<<"$meta" || fail "meta says format=2" "$meta"
pass "meta says format=2"
grep -qx 'encrypted=no' <<<"$meta" || fail "meta says encrypted=no" "$meta"
pass "meta says encrypted=no"
grep -qx "home=$SRC" <<<"$meta" || fail "meta records the home directory" "$meta"
pass "meta records the home directory"
[[ -s $STUB_DIR/omarchy-notification-send.log ]] || fail "the export sends a notification"
pass "the export sends a notification"

echo "# missing restore sources"
mkdir -p "$WORK/out/nosrc" "$WORK/emptyomarchy"
RC=0
OUT=$(env HOME="$SRC" OMARCHY_PATH="$WORK/emptyomarchy" timeout 120 "$ROOT/bin/omarchy-transfer-export" "$WORK/out/nosrc" 2>&1 </dev/null) || RC=$?
rc_is 0 "export works without the restore sources"
out_has 'restore\.sh not found' "a missing restore.sh is reported"
no_file "$WORK/out/nosrc/omarchy-transfer-restore.sh" "no companion is written without a source"
if archive_list "$(newest_archive "$WORK/out/nosrc")" | grep -q '^omarchy-transfer/restore\.sh$'; then fail "no restore.sh member without a source"; fi
pass "no restore.sh member without a source"

echo "# excludes in both forms"
{
  sed '/^\[exclude\]/,$d' "$OMARCHY_TRANSFER_CONF"
  printf '[exclude]\n.cache\nnode_modules\nDocuments/private\n./Documents/proj\n'
} >"$WORK/conf.new"
mv "$WORK/conf.new" "$OMARCHY_TRANSFER_CONF"
mkdir -p "$WORK/out/excl"
tx "$SRC" export "$WORK/out/excl"
rc_is 0 "export with path excludes succeeds"
members=$(archive_list "$(newest_archive "$WORK/out/excl")")
if grep -q 'Documents/private' <<<"$members"; then fail "an exclude written as Documents/private applies" "$members"; fi
pass "an exclude written as Documents/private applies"
if grep -q 'Documents/proj' <<<"$members"; then fail "an exclude written as ./Documents/proj applies" "$members"; fi
pass "an exclude written as ./Documents/proj applies"
grep -q 'home/Documents/a.txt' <<<"$members" || fail "files next to excluded paths are kept"
pass "files next to excluded paths are kept"
write_conf no no no

echo "# import into an empty home"
DEST=$WORK/dest
mkdir -p "$DEST"
before=$(snapshot "$DEST")
tx "$DEST" import --dry-run "$ARCHIVE"
rc_is 0 "import --dry-run succeeds"
equal "$before" "$(snapshot "$DEST")" "import --dry-run leaves the home alone"

export HYPRLAND_INSTANCE_SIGNATURE=test
tx "$DEST" import "$ARCHIVE"
unset HYPRLAND_INSTANCE_SIGNATURE
rc_is 0 "import succeeds"
for p in .config .bashrc Documents; do
  if ! diff -r -x .cache -x node_modules -x private -x proj "$SRC/$p" "$DEST/$p" >/dev/null 2>&1; then
    fail "diff -r $p matches" "$(diff -r -x .cache -x node_modules "$SRC/$p" "$DEST/$p" 2>&1 | head -5)"
  fi
  pass "diff -r $p matches"
done
no_file "$DEST/.config/app/.cache" "excluded .cache is not restored"
no_file "$DEST/.config/app/node_modules" "excluded node_modules is not restored"
no_file "$DEST/.ssh" "secrets are not restored from an unencrypted archive"
no_file "$DEST/Pictures" "a missing folder stays missing"
equal 600 "$(stat -c %a "$DEST/.config/app/settings.conf")" "mode 600 is kept"
equal 755 "$(stat -c %a "$DEST/Documents/run.sh")" "mode 755 is kept"
equal settings.conf "$(readlink "$DEST/.config/app/link")" "the symlink is kept"
content_is "$DEST/Documents/with space & ümlaut.txt" spaced "odd file names survive"
if [[ $XATTR == yes ]]; then
  equal hello "$(getfattr -n user.omt --only-values "$DEST/.config/app/settings.conf" 2>/dev/null)" "extended attributes are preserved"
else
  skip "extended attributes: setfattr or filesystem support is missing"
fi
equal 0 "$(find "$DEST/.cache" -name 'transfer-stage.*' 2>/dev/null | wc -l)" "the staging directory is removed, read-only folders included"
[[ -s $STUB_DIR/hyprctl.log ]] && grep -q reload "$STUB_DIR/hyprctl.log" || fail "the import reloads Hyprland"
pass "the import reloads Hyprland"
is_file "$ARCHIVE" "the archive is kept after import"
no_file "$DEST/omarchy-transfer" "the metadata members are not installed"
equal 0 "$(find "$DEST" -name restore.sh -o -name README.txt -o -name 'omarchy-transfer-*' | wc -l)" "restore.sh and README.txt are never installed into the home"

echo "# a second import changes nothing"
before=$(snapshot "$DEST")
tx "$DEST" import "$ARCHIVE"
rc_is 0 "a repeated import succeeds"
equal "$before" "$(snapshot "$DEST")" "a repeated import changes nothing"
equal 0 "$(find "$DEST" -name '*.bak.*' -o -name '*.transfer' | wc -l)" "a repeated import creates no backup or conflict files"

echo "# ~ in the archive path"
DEST2=$WORK/dest2
mkdir -p "$DEST2"
cp "$ARCHIVE" "$DEST2/moved.tar.zst"
# shellcheck disable=SC2088
tx "$DEST2" import '~/moved.tar.zst'
rc_is 0 "a leading ~ in the archive path is expanded"
content_is "$DEST2/.bashrc" "export A=1" "the archive named with ~ was restored"

echo "# the target may be inside the home"
INC=$WORK/inc
mkdir -p "$INC"
populate_home "$INC"
mkdir -p "$INC/Documents/bk"
write_conf no no no
tx "$INC" export "$INC/Documents/bk"
rc_is 0 "export into an included folder"
sleep 1
tx "$INC" export "$INC/Documents/bk"
rc_is 0 "a second export into the same folder"
newest=$(newest_archive "$INC/Documents/bk")
if archive_list "$newest" | grep -q 'omarchy-transfer-'; then fail "earlier archives are not packed again"; fi
pass "earlier archives are not packed again"
equal 2 "$(find "$INC/Documents/bk" -maxdepth 1 -name 'omarchy-transfer-*.tar.zst' | wc -l)" "both archives exist"

tx "$INC" export "$INC/Documents"
rc_is 0 "export straight into an included folder"
if archive_list "$(newest_archive "$INC/Documents")" | grep -qE 'omarchy-transfer-(restore|README)'; then fail "companion files are not packed into the archive"; fi
pass "companion files are not packed into the archive"
if archive_list "$(newest_archive "$INC/Documents")" | grep -q 'omarchy-transfer-'; then fail "an archive never contains itself"; fi
pass "an archive never contains itself"
