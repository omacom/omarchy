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

official_in_archive() {
  zstd -dc -- "$1" | tar -xO omarchy-transfer/packages-official.txt
}

pkg_calls() { # tool
  local n=0
  [[ -f $STUB_DIR/$1.log ]] && n=$(grep -c -- '-S' "$STUB_DIR/$1.log" || true)
  echo "$n"
}

reset_stubs() {
  rm -f "${STUB_DIR:?}"/*.log "${STUB_DIR:?}/failpkgs"
  : >"$STUB_DIR/installed"
  : >"$STUB_DIR/official"
  : >"$STUB_DIR/aur"
  : >"$STUB_DIR/repo"
}

echo "# export collects package lists"
reset_stubs
SRC=$WORK/src
mkdir -p "$SRC"
populate_home "$SRC"
printf 'foo\nbar\nbaz\nlinux-debug\nfoo-debug\n' >"$STUB_DIR/official"
printf 'aurpkg\naurpkg-debug\n' >"$STUB_DIR/aur"
write_conf yes no no
mkdir -p "$WORK/out/pk"
tx "$SRC" export "$WORK/out/pk"
rc_is 0 "export with packages succeeds"
ARCHIVE=$(newest_archive "$WORK/out/pk")
equal $'bar\nbaz\nfoo' "$(official_in_archive "$ARCHIVE" | sort)" "official packages are listed without -debug packages"
equal aurpkg "$(zstd -dc -- "$ARCHIVE" | tar -xO omarchy-transfer/packages-aur.txt)" "AUR packages are listed without -debug packages"

write_conf no no no
mkdir -p "$WORK/out/nopk"
tx "$SRC" export "$WORK/out/nopk"
rc_is 0 "export without packages succeeds"
if archive_list "$(newest_archive "$WORK/out/nopk")" | grep -q 'packages-'; then fail "packages = no leaves the package lists out"; fi
pass "packages = no leaves the package lists out"

# Import side: archives built by hand.
pkg_case() { # name official aur
  new_case "$1"
  echo x >"$T/f.txt"
  printf '%s' "$2" >"$M/omarchy-transfer/packages-official.txt"
  printf '%s' "$3" >"$M/omarchy-transfer/packages-aur.txt"
  mk_archive "$CASE/a.tar.zst"
  ARCHIVE=$CASE/a.tar.zst
  reset_stubs
}

echo "# filter"
pkg_case filter $'foo\nbar\nbaz\n' $'aurpkg\n'
printf 'foo\nbaz\n' >"$STUB_DIR/repo"
tx "$D" import "$ARCHIVE"
rc_is 0 "an unknown package does not fail the import"
equal 1 "$(pkg_calls pacman)" "official packages are installed in a single call"
grep -qw foo "$STUB_DIR/pacman.log" && grep -qw baz "$STUB_DIR/pacman.log" || fail "the packages in the repo are installed" "$(cat "$STUB_DIR/pacman.log" 2>&1)"
pass "the packages in the repo are installed"
if grep -qw bar "$STUB_DIR/pacman.log"; then fail "a package missing from the repo is not passed to pacman"; fi
pass "a package missing from the repo is not passed to pacman"
out_has 'bar' "the unknown package is reported"
grep -q -- '--noconfirm' "$STUB_DIR/pacman.log" || fail "pacman never prompts"
pass "pacman never prompts"
equal 1 "$(pkg_calls yay)" "AUR packages are installed in a single call"
grep -qw aurpkg "$STUB_DIR/yay.log" || fail "the AUR package goes to yay"
pass "the AUR package goes to yay"
is_file "$D/f.txt" "files are restored alongside the packages"

echo "# already installed and -debug"
pkg_case skipping $'foo\nbaz\nkeep-debug\n' ''
printf 'foo\nbaz\nkeep-debug\n' >"$STUB_DIR/repo"
echo foo >"$STUB_DIR/installed"
tx "$D" import "$ARCHIVE"
rc_is 0 "import with installed packages succeeds"
if grep -qw foo "$STUB_DIR/pacman.log"; then fail "an installed package is not passed to pacman again"; fi
pass "an installed package is not passed to pacman again"
grep -qw baz "$STUB_DIR/pacman.log" || fail "the missing package is installed"
pass "the missing package is installed"
if grep -q -- '-debug' "$STUB_DIR/pacman.log"; then fail "a -debug package is skipped"; fi
pass "a -debug package is skipped"

pkg_case allthere $'foo\n' ''
echo foo >"$STUB_DIR/repo"
echo foo >"$STUB_DIR/installed"
tx "$D" import "$ARCHIVE"
rc_is 0 "import with everything installed succeeds"
equal 0 "$(pkg_calls pacman)" "nothing is installed when nothing is missing"
equal 0 "$(pkg_calls yay)" "yay is not called without AUR packages"

echo "# dry run"
pkg_case dry $'foo\n' $'aurpkg\n'
echo foo >"$STUB_DIR/repo"
tx "$D" import --dry-run "$ARCHIVE"
rc_is 0 "import --dry-run succeeds"
equal 0 "$(pkg_calls pacman)" "--dry-run installs nothing"
equal 0 "$(pkg_calls yay)" "--dry-run installs nothing from the AUR"
out_has 'foo' "--dry-run lists the packages"

echo "# bisection"
pkg_case bisect $'foo\nbaz\nqux\nzed\n' ''
printf 'foo\nbaz\nqux\nzed\n' >"$STUB_DIR/repo"
echo qux >"$STUB_DIR/failpkgs"
tx "$D" import "$ARCHIVE"
rc_fails "a failing package makes the import fail"
for p in foo baz zed; do
  grep -qxF "$p" "$STUB_DIR/installed" || fail "$p is installed despite the failing package" "$(cat "$STUB_DIR/installed")"
  pass "$p is installed despite the failing package"
done
if grep -qxF qux "$STUB_DIR/installed"; then fail "the failing package is not installed"; fi
pass "the failing package is not installed"
out_has 'qux' "the failing package is named in the summary"
(( $(pkg_calls pacman) <= 9 )) || fail "bisection needs few calls" "$(pkg_calls pacman) calls: $(cat "$STUB_DIR/pacman.log")"
pass "bisection needs few calls"
out_lacks 'Install anyway|\[y/N\]' "no prompt per package"
is_file "$D/f.txt" "files are restored although a package failed"

echo "# AUR failure"
pkg_case aurfail $'foo\n' $'goodaur\nbadaur\n'
echo foo >"$STUB_DIR/repo"
echo badaur >"$STUB_DIR/failpkgs"
tx "$D" import "$ARCHIVE"
rc_fails "a failing AUR package makes the import fail"
grep -qxF foo "$STUB_DIR/installed" || fail "official packages are installed before the AUR step fails"
pass "official packages are installed before the AUR step fails"
grep -qxF goodaur "$STUB_DIR/installed" || fail "the good AUR package is installed"
pass "the good AUR package is installed"
out_has 'badaur' "the failing AUR package is named in the summary"

echo "# no package lists"
pkg_case none '' ''
rm -f "$M/omarchy-transfer/packages-"*
mk_archive "$ARCHIVE"
tx "$D" import "$ARCHIVE"
rc_is 0 "an archive without package lists imports cleanly"
equal 0 "$(pkg_calls pacman)" "no package lists means no pacman call"
