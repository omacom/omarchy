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

# A real export is the good archive every broken variant is derived from.
SRC=$WORK/src
mkdir -p "$SRC"
populate_home "$SRC"
write_conf no no no
mkdir -p "$WORK/out/good"
tx "$SRC" export "$WORK/out/good"
rc_is 0 "the reference export succeeds"
GOOD=$(newest_archive "$WORK/out/good")
is_file "$GOOD" "the reference archive exists"

DEST=$WORK/dest
mkdir -p "$DEST"
before=$(snapshot "$DEST")

rejected() { # description archive
  tx "$DEST" import "$2"
  rc_fails "$1: import fails"
  equal "$before" "$(snapshot "$DEST")" "$1: the home is untouched"
  out_lacks 'unbound variable|line [0-9]+:' "$1: no shell error leaks out"
  equal 0 "$(find "$DEST/.cache" -name 'transfer-stage.*' 2>/dev/null | wc -l)" "$1: no staging directory is left"
}

echo "# damaged archives"
size=$(stat -c %s "$GOOD")
head -c $(( size / 2 )) "$GOOD" >"$WORK/truncated.tar.zst"
rejected "a truncated archive" "$WORK/truncated.tar.zst"

head -c 4096 /dev/urandom >"$WORK/garbage.tar.zst"
rejected "a garbage archive" "$WORK/garbage.tar.zst"

: >"$WORK/empty.tar.zst"
rejected "an empty file" "$WORK/empty.tar.zst"

cp "$GOOD" "$WORK/flipped.tar.zst"
printf 'X' | dd of="$WORK/flipped.tar.zst" bs=1 seek=$(( size / 2 )) conv=notrunc 2>/dev/null
rejected "a flipped byte" "$WORK/flipped.tar.zst"

tx "$DEST" import "$WORK/does-not-exist.tar.zst"
rc_fails "a missing archive fails"
out_has 'not found|no such|does not exist|cannot' "a missing archive is reported in words"

echo "# hostile archives"
new_case hostile
echo ok >"$T/fine.txt"

mk_raw() { # out: pack M and T, then run the extra step given in $EXTRA
  tar -cf "$CASE/raw.tar" -C "$M" omarchy-transfer -C "$CASE/tree" home
  [[ -z ${EXTRA:-} ]] || eval "$EXTRA"
  zstd -q -3 -f --check -o "$1" "$CASE/raw.tar"
}

evil=$CASE/evil
mkdir -p "$evil"
echo pwned >"$evil/evil"

EXTRA='tar -rPf "$CASE/raw.tar" -C "$evil" --transform="s,^evil,home/../../escape-test," evil'
mk_raw "$WORK/traversal.tar.zst"
rejected "a .. member" "$WORK/traversal.tar.zst"
no_file "$WORK/escape-test" "the .. member wrote nothing outside the home"
no_file "$(dirname "$DEST")/escape-test" "the .. member wrote nothing beside the home"

EXTRA='tar -rPf "$CASE/raw.tar" -C "$evil" --transform="s,^evil,$WORK/abs-escape," evil'
mk_raw "$WORK/absolute.tar.zst"
rejected "an absolute member" "$WORK/absolute.tar.zst"
no_file "$WORK/abs-escape" "the absolute member wrote nothing"

EXTRA='tar -rPf "$CASE/raw.tar" -C "$evil" --transform="s,^evil,etc/evil," evil'
mk_raw "$WORK/toplevel.tar.zst"
rejected "a member outside home/ and omarchy-transfer/" "$WORK/toplevel.tar.zst"

mkdir -p "$CASE/outside"
ln -s "$CASE/outside" "$CASE/tree/home/link"
EXTRA='tar -rPf "$CASE/raw.tar" -C "$evil" --transform="s,^evil,home/link/evil," evil'
mk_raw "$WORK/symlink.tar.zst"
rejected "a member below a symlink" "$WORK/symlink.tar.zst"
no_file "$CASE/outside/evil" "nothing was written through the symlink"
rm -f "$CASE/tree/home/link"

mkfifo "$CASE/tree/home/fifo"
EXTRA=""
mk_raw "$WORK/fifo.tar.zst"
rejected "a special file" "$WORK/fifo.tar.zst"
rm -f "$CASE/tree/home/fifo"

sed -i 's/^format=.*/format=99/' "$M/omarchy-transfer/meta"
mk_raw "$WORK/format.tar.zst"
rejected "format=99" "$WORK/format.tar.zst"
sed -i 's/^format=.*/format=2/' "$M/omarchy-transfer/meta"

rm -rf "$CASE/meta2"
mkdir -p "$CASE/meta2"
tar -cf - -C "$CASE/tree" home | zstd -q -3 -f --check -o "$WORK/nometa.tar.zst"
rejected "an archive without metadata" "$WORK/nometa.tar.zst"

echo "# the good archive still works"
tx "$DEST" import "$GOOD"
rc_is 0 "the control import succeeds"
is_file "$DEST/.bashrc" "the control import restored files"

echo "# old archives with the hidden .omarchy-transfer/ directory"
new_case old
echo oldfile >"$T/old.txt"
tar -cf - --transform='s,^omarchy-transfer,.omarchy-transfer,' -C "$M" omarchy-transfer -C "$CASE/tree" home | zstd -q -3 -f --check -o "$WORK/old-style.tar.zst"
tx "$D" import --dry-run "$WORK/old-style.tar.zst"
rc_is 0 "a dry run accepts an old-style archive"
tx "$D" import "$WORK/old-style.tar.zst"
rc_is 0 "an old-style archive imports"
content_is "$D/old.txt" oldfile "an old-style archive restores its files"

echo "# encryption"
if ! command -v age >/dev/null || ! command -v script >/dev/null; then
  skip "encryption: age or script(1) is missing"
  exit 0
fi

write_conf no yes yes
echo "wifi-secret" >"$OMARCHY_TRANSFER_NM_DIR/home.nmconnection"
chmod 600 "$OMARCHY_TRANSFER_NM_DIR/home.nmconnection"
echo networkmanager >"$STUB_DIR/backend"
ENC=$WORK/out/enc
mkdir -p "$ENC"

tx "$SRC" export "$ENC"
rc_fails "an encrypted export without a terminal fails up front"
equal 0 "$(find "$ENC" -mindepth 1 | wc -l)" "a refused encrypted export leaves nothing behind"

tx "$SRC" export --dry-run "$ENC"
out_has 'networkmanager' "the dry run reports the real Wi-Fi backend"

pty_run "$(printf 'testpass\ntestpass')" env HOME="$SRC" "$ROOT/bin/omarchy-transfer-export" "$ENC"
rc_is 0 "an encrypted export succeeds"
ARCHIVE=$(newest_archive "$ENC")
[[ $ARCHIVE == *.tar.zst.age ]] || fail "an encrypted archive ends in .tar.zst.age" "$ARCHIVE"
pass "an encrypted archive ends in .tar.zst.age"
equal 0 "$(find "$ENC" -mindepth 1 ! -name '*.age' ! -name omarchy-transfer-restore.sh ! -name omarchy-transfer-README.txt | wc -l)" "no plaintext archive or temp file is left"
if grep -q testpass "$PTY_OUT"; then fail "the passphrase is not echoed"; fi
pass "the passphrase is not echoed"
if grep -q SECRETKEY "$ARCHIVE"; then fail "the archive is opaque"; fi
pass "the archive is opaque"

NEWHOME=$WORK/enc-dest
mkdir -p "$NEWHOME"
before_enc=$(snapshot "$NEWHOME")
pty_run "wrongpass" env HOME="$NEWHOME" "$ROOT/bin/omarchy-transfer-import" --wifi "$ARCHIVE"
rc_fails "a wrong passphrase fails"
equal "$before_enc" "$(snapshot "$NEWHOME")" "a wrong passphrase leaves the home untouched"
equal 0 "$(find "$OMARCHY_TRANSFER_NM_DIR" -type f -newer "$ARCHIVE" | wc -l)" "a wrong passphrase leaves Wi-Fi alone"
out_lacks 'unbound variable|line [0-9]+:' "a wrong passphrase shows no shell error"

# Import without --wifi never touches the Wi-Fi directory.
rm -f "$OMARCHY_TRANSFER_NM_DIR/home.nmconnection"
pty_run "testpass" env HOME="$NEWHOME" "$ROOT/bin/omarchy-transfer-import" "$ARCHIVE"
rc_is 0 "the right passphrase restores the files"
content_is "$NEWHOME/.ssh/id_test" SECRETKEY "secrets are restored from an encrypted archive"
equal 600 "$(stat -c %a "$NEWHOME/.ssh/id_test")" "secret files keep mode 600"
no_file "$OMARCHY_TRANSFER_NM_DIR/home.nmconnection" "Wi-Fi is not restored without --wifi"

echo "# Wi-Fi restore"
WIFIHOME=$WORK/wifi-dest
mkdir -p "$WIFIHOME"
pty_run "testpass" env HOME="$WIFIHOME" "$ROOT/bin/omarchy-transfer-import" --wifi "$ARCHIVE"
rc_is 0 "import --wifi succeeds"
content_is "$OMARCHY_TRANSFER_NM_DIR/home.nmconnection" wifi-secret "the NetworkManager profile is restored"
equal 600 "$(stat -c %a "$OMARCHY_TRANSFER_NM_DIR/home.nmconnection")" "the profile has mode 600"
grep -q 'connection reload' "$STUB_DIR/nmcli.log" 2>/dev/null || fail "NetworkManager is told to reload its connections"
pass "NetworkManager is told to reload its connections"

echo iwd >"$STUB_DIR/backend"
rm -f "$OMARCHY_TRANSFER_NM_DIR/home.nmconnection"
WIFIHOME2=$WORK/wifi-dest2
mkdir -p "$WIFIHOME2"
pty_run "testpass" env HOME="$WIFIHOME2" "$ROOT/bin/omarchy-transfer-import" --wifi "$ARCHIVE"
out_has 'iwd' "import --wifi names the backend when the archive has no data for it"
no_file "$OMARCHY_TRANSFER_NM_DIR/home.nmconnection" "a NetworkManager profile is not written on an iwd system"
