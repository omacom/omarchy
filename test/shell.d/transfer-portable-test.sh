#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command tar
require_command zstd

RESTORE=$ROOT/default/transfer/restore.sh

# Everything lives under WORK. The real HOME is never read or written.
WORK=$(mktemp -d)
trap 'chmod -R u+w "$WORK" 2>/dev/null || true; rm -rf "$WORK"' EXIT

REAL_PATH=$PATH
unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME HYPRLAND_INSTANCE_SIGNATURE OMARCHY_TRANSFER_TMPDIR
export WORK
export STUB_DIR=$WORK/stubdata
export OMARCHY_TRANSFER_CONF=$WORK/transfer.conf
export OMARCHY_TRANSFER_NM_DIR=$WORK/nm
export OMARCHY_TRANSFER_IWD_DIR=$WORK/iwd
mkdir -p "$STUB_DIR" "$OMARCHY_TRANSFER_NM_DIR" "$OMARCHY_TRANSFER_IWD_DIR"
: >"$STUB_DIR/installed"

# The restore sees only these tools: symlinks to the real binaries, so a
# missing zstd or pacman can be simulated, and nothing from $ROOT/bin.
TOOLS=$WORK/tools
TOOLS_NOZSTD=$WORK/tools-nozstd
mkdir -p "$TOOLS" "$TOOLS_NOZSTD"
for t in bash sh env tar zstd find awk gawk mawk grep sed sort comm cmp diff cat head tail tr mkdir mv cp rm chmod stat df wc date mktemp mkfifo tee readlink basename dirname install sleep ln ls xargs; do
  if p=$(PATH=$REAL_PATH command -v "$t"); then
    ln -sf "$p" "$TOOLS/$t"
    [[ $t == zstd ]] || ln -sf "$p" "$TOOLS_NOZSTD/$t"
  fi
done

mkstub() { # dir name body
  mkdir -p "$1"
  printf '#!/bin/bash\n%s\n' "$3" >"$1/$2"
  chmod +x "$1/$2"
}

mkdir -p "$WORK/pkg"
cat >"$WORK/pkg/pkg-install" <<'SH'
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
chmod +x "$WORK/pkg/pkg-install"

PM_DIR=$WORK/pm
mkstub "$PM_DIR" pacman '
case ${1:-} in
  -Qqen) cat "$STUB_DIR/official" 2>/dev/null || true ;;
  -Qqem) cat "$STUB_DIR/aur" 2>/dev/null || true ;;
  -Slq) cat "$STUB_DIR/repo" 2>/dev/null || true ;;
  -S*) exec "$WORK/pkg/pkg-install" pacman "$@" ;;
  -Q*)
    pkgs=()
    for a in "${@:2}"; do [[ $a == -* ]] || pkgs+=("$a"); done
    if (( ${#pkgs[@]} == 0 )); then cat "$STUB_DIR/installed" 2>/dev/null || true; exit 0; fi
    for p in "${pkgs[@]}"; do grep -qxF -- "$p" "$STUB_DIR/installed" 2>/dev/null || exit 1; done
    ;;
esac
exit 0'
YAY_DIR=$WORK/yay
mkstub "$YAY_DIR" yay 'exec "$WORK/pkg/pkg-install" yay "$@"'
PARU_DIR=$WORK/paru
mkstub "$PARU_DIR" paru 'exec "$WORK/pkg/pkg-install" paru "$@"'
APT_DIR=$WORK/apt
mkstub "$APT_DIR" apt-get 'exit 0'

SYS_DIR=$WORK/sys
mkstub "$SYS_DIR" sudo '
while [[ ${1:-} == -* ]]; do shift; done
(( $# > 0 )) || exit 0
echo "$*" >>"$STUB_DIR/sudo.log"
exec "$@"'
mkstub "$SYS_DIR" systemctl '
echo "$*" >>"$STUB_DIR/systemctl.log"
backend=$(cat "$STUB_DIR/backend" 2>/dev/null || echo none)
if [[ $* == *is-active* ]]; then
  [[ $* == *NetworkManager* && $backend == networkmanager ]] && exit 0
  [[ $* == *iwd* && $backend == iwd ]] && exit 0
  exit 3
fi
exit 0'
mkstub "$SYS_DIR" nmcli 'echo "$*" >>"$STUB_DIR/nmcli.log"'

NATIVE_DIR=$WORK/native
mkstub "$NATIVE_DIR" omarchy-transfer-import 'echo "$*" >>"$STUB_DIR/native.log"; exit 0'

# Tools the export needs on top of the system PATH.
mkstub "$WORK/exportstubs" omarchy-notification-send 'exit 0'

OUT=""
RC=0
EXTRA_PATH=""   # directories placed in front of the tool directory
TOOLDIR=$TOOLS
EXTRA_ENV=()

# rs <home> [args...]: run restore.sh as a plain bash script with a stripped
# environment. Sets OUT (stdout+stderr) and RC.
rs() {
  local home=$1
  shift
  RC=0
  OUT=$(env -i HOME="$home" PATH="${EXTRA_PATH:+$EXTRA_PATH:}$SYS_DIR:$TOOLDIR" \
    STUB_DIR="$STUB_DIR" WORK="$WORK" \
    OMARCHY_TRANSFER_NM_DIR="$OMARCHY_TRANSFER_NM_DIR" OMARCHY_TRANSFER_IWD_DIR="$OMARCHY_TRANSFER_IWD_DIR" \
    OMARCHY_TRANSFER_FORCE_PORTABLE=1 "${EXTRA_ENV[@]}" \
    "$TOOLS/bash" "${SCRIPT:-$RESTORE}" "$@" 2>&1 </dev/null) || RC=$?
}

rc_is() { (( RC == $1 )) || fail "$2" "expected exit $1, got $RC: $(head -c 1500 <<<"$OUT")"; pass "$2"; }
rc_fails() { (( RC != 0 )) || fail "$1" "expected a non-zero exit: $(head -c 1500 <<<"$OUT")"; pass "$1"; }
out_has() { grep -qiE -- "$1" <<<"$OUT" || fail "$2" "output lacks /$1/: $(head -c 1500 <<<"$OUT")"; pass "$2"; }
out_lacks() { if grep -qiE -- "$1" <<<"$OUT"; then fail "$2" "output matches /$1/: $(head -c 1500 <<<"$OUT")"; fi; pass "$2"; }
is_file() { [[ -e $1 || -L $1 ]] || fail "$2" "missing $1"; pass "$2"; }
no_file() { [[ ! -e $1 && ! -L $1 ]] || fail "$2" "unexpected $1"; pass "$2"; }
equal() { [[ $1 == "$2" ]] || fail "$3" "expected '$1', got '$2'"; pass "$3"; }
content_is() {
  local got=""
  [[ -f $1 ]] && got=$(<"$1")
  [[ $got == "$2" ]] || fail "$3" "$1: expected '$2', got '$got'"
  pass "$3"
}
snapshot() {
  (cd "$1" && find . -mindepth 1 -path ./.cache -prune -o -printf '%p|%y|%s|%m|%l\n' | sort)
}
stage_count() { find "$1/.cache/omarchy-transfer" -name 'stage.*' 2>/dev/null | wc -l; }
new_home() { local h=$WORK/home.$1; rm -rf "$h"; mkdir -p "$h"; echo "$h"; }

# The restore must not see any Omarchy command.
PATH=$SYS_DIR:$TOOLS command -v omarchy-transfer-import >/dev/null && fail "the restore PATH has no Omarchy commands"
pass "the restore PATH has no Omarchy commands"

# ----------------------------------------------------------- source and export
SRC=$WORK/src
mkdir -p "$SRC/.config/app" "$SRC/.config/hypr" "$SRC/Documents/sub"
echo "key=value" >"$SRC/.config/app/settings.conf"
ln -s settings.conf "$SRC/.config/app/link"
echo "monitor=,preferred,auto,1" >"$SRC/.config/hypr/hyprland.conf"
printf 'source ~/.local/share/omarchy/default/bash/rc\nexport A=1\n' >"$SRC/.bashrc"
echo "alias ll='ls -l'" >"$SRC/.zshrc"
echo doc >"$SRC/Documents/a.txt"
echo spaced >"$SRC/Documents/with space & ümlaut.txt"
printf '#!/bin/bash\necho hi\n' >"$SRC/Documents/run.sh"
chmod 755 "$SRC/Documents/run.sh"
echo deep >"$SRC/Documents/sub/b.txt"

printf '%s\n' a b c d >"$STUB_DIR/official"
printf '%s\n' x >"$STUB_DIR/aur"

write_conf() { # packages
  {
    echo "[options]"
    echo "packages = $1"
    echo "wifi = no"
    echo "encrypt = no"
    echo "[include]"
    printf '%s\n' .config .bashrc .zshrc Documents
    echo "[exclude]"
    printf '%s\n' .cache
  } >"$OMARCHY_TRANSFER_CONF"
}

export_home() { # home outdir
  mkdir -p "$2"
  RC=0
  OUT=$(env HOME="$1" OMARCHY_PATH="$ROOT" PATH="$WORK/exportstubs:$PM_DIR:$SYS_DIR:$ROOT/bin:$REAL_PATH" \
    "$ROOT/bin/omarchy-transfer-export" "$2" 2>&1 </dev/null) || RC=$?
}

write_conf yes
OUTDIR=$WORK/out
export_home "$SRC" "$OUTDIR"
rc_is 0 "the reference export succeeds"
ARCHIVE=$(find "$OUTDIR" -maxdepth 1 -name 'omarchy-transfer-*.tar.zst' | head -n1)
is_file "$ARCHIVE" "the reference archive exists"

echo "# companion files from the export"
if [[ -x $OUTDIR/omarchy-transfer-restore.sh && -f $OUTDIR/omarchy-transfer-README.txt ]]; then
  pass "the export writes the restore script and README next to the archive"
  member=$(zstd -dc -- "$ARCHIVE" | tar -xOf - omarchy-transfer/restore.sh)
  [[ $member == "$(<"$OUTDIR/omarchy-transfer-restore.sh")" ]] || fail "the embedded restore.sh equals the companion file"
  pass "the embedded restore.sh equals the companion file"
else
  skip "the export does not write companion files yet"
  cp "$RESTORE" "$OUTDIR/omarchy-transfer-restore.sh"
fi
SCRIPT=$OUTDIR/omarchy-transfer-restore.sh

echo "# round trip: finds the archive next to the script"
D=$(new_home rt)
echo "my own zshrc" >"$D/.zshrc"
mkdir -p "$D/Documents"
rs "$D" --no-packages
rc_is 0 "restore from the archive folder succeeds without arguments"
equal 0 "$(stage_count "$D")" "no staging folder is left"
content_is "$D/Documents/a.txt" doc "a missing file is added"
content_is "$D/Documents/with space & ümlaut.txt" spaced "odd file names survive"
[[ -x $D/Documents/run.sh ]] || fail "the executable bit survives"
pass "the executable bit survives"
diff -r "$SRC/Documents" "$D/Documents" >/dev/null || fail "Documents is identical to the source"
pass "Documents is identical to the source"
diff -r "$SRC/.config/app" "$D/.config/app" >/dev/null || fail ".config/app is identical to the source"
pass ".config/app is identical to the source"
content_is "$D/.zshrc" "my own zshrc" "a differing file keeps the current version"
content_is "$D/.zshrc.transfer" "alias ll='ls -l'" "the archive version is saved as .transfer"
no_file "$D/.config/hypr" "hypr is not activated"
content_is "$D/omarchy-transfer-configs/.config/hypr/hyprland.conf" "monitor=,preferred,auto,1" "hypr is parked"
no_file "$D/.bashrc" "a .bashrc that loads Omarchy is not activated"
is_file "$D/omarchy-transfer-configs/.bashrc" "a .bashrc that loads Omarchy is parked"
out_has 'parked' "the summary reports parked configs"
out_has '\.zshrc' "the summary lists the conflict"

echo "# second run changes nothing"
before=$(snapshot "$D")
rs "$D" --no-packages
rc_is 0 "a second restore succeeds"
equal "$before" "$(snapshot "$D")" "a second restore changes nothing"

echo "# dry run"
D=$(new_home dry)
before=$(snapshot "$D")
rs "$D" --dry-run
rc_is 0 "a dry run succeeds"
equal "$before" "$(snapshot "$D")" "a dry run changes nothing"
equal 0 "$(stage_count "$D")" "a dry run leaves no staging folder"
out_has 'would add|dry run' "a dry run says what it would do"

echo "# modes"
D=$(new_home over)
echo old >"$D/.zshrc"
mkdir -p "$D/Documents"
echo olddoc >"$D/Documents/a.txt"
rs "$D" --no-packages --mode=overwrite
rc_is 0 "mode overwrite succeeds"
content_is "$D/Documents/a.txt" doc "overwrite replaces the file"
equal 1 "$(find "$D/Documents" -name 'a.txt.bak.*' | wc -l)" "overwrite keeps a .bak copy"
no_file "$D/Documents/a.txt.transfer" "overwrite writes no .transfer file"

D=$(new_home skip)
mkdir -p "$D/Documents"
echo olddoc >"$D/Documents/a.txt"
rs "$D" --no-packages --mode=skip
rc_is 0 "mode skip succeeds"
content_is "$D/Documents/a.txt" olddoc "skip never touches an existing file"
no_file "$D/Documents/a.txt.transfer" "skip writes no .transfer file"
content_is "$D/Documents/sub/b.txt" deep "skip still adds missing files"

D=$(new_home blocked)
echo "i am a file" >"$D/Documents"
rs "$D" --no-packages
rc_is 0 "a file blocking a folder is not an error"
content_is "$D/Documents" "i am a file" "the blocking file is left alone"
out_has 'blocked:[[:space:]]+[1-9]' "the blocked entry is reported"

rs "$D" --mode=bogus
rc_fails "an unknown mode is rejected"
rs "$D" --bogus
rc_fails "an unknown option is rejected"

echo "# --extract-only"
D=$(new_home ex)
before=$(snapshot "$D")
rs "$D" --extract-only "$WORK/extracted"
rc_is 0 "--extract-only succeeds"
is_file "$WORK/extracted/home/Documents/a.txt" "extract-only unpacks home/"
is_file "$WORK/extracted/omarchy-transfer/meta" "extract-only unpacks the metadata"
is_file "$WORK/extracted/home/.config/hypr/hyprland.conf" "extract-only keeps Omarchy configs where they are"
equal "$before" "$(snapshot "$D")" "extract-only leaves HOME untouched"
rs "$D" --extract-only "$WORK/extracted"
rc_fails "extract-only refuses a folder that is not empty"

echo "# packages"
D=$(new_home pk)
printf '%s\n' a b c >"$STUB_DIR/repo"
: >"$STUB_DIR/installed"
echo b >"$STUB_DIR/failpkgs"
rm -f "$STUB_DIR"/pacman.log "$STUB_DIR"/yay.log "$STUB_DIR"/paru.log
EXTRA_PATH=$PM_DIR:$YAY_DIR
rs "$D"
rc_fails "a failing package makes the restore fail"
grep -q 'a b c' "$STUB_DIR/pacman.log" || fail "the official packages are installed in one batch"
pass "the official packages are installed in one batch"
equal 5 "$(wc -l <"$STUB_DIR/pacman.log")" "the failed batch is bisected"
grep -qxF a "$STUB_DIR/installed" && grep -qxF c "$STUB_DIR/installed" || fail "bisection installs the good packages"
pass "bisection installs the good packages"
grep -qxF b "$STUB_DIR/installed" && fail "the failing package is not installed"
pass "the failing package is not installed"
out_has 'not installed.*b' "the failing package is reported"
out_has 'not in the repositories.*d' "a package missing from the repositories is reported"
grep -q 'x' "$STUB_DIR/yay.log" || fail "AUR packages go through yay"
pass "AUR packages go through yay"

: >"$STUB_DIR/installed"
: >"$STUB_DIR/failpkgs"
rm -f "$STUB_DIR"/pacman.log "$STUB_DIR"/yay.log "$STUB_DIR"/paru.log
EXTRA_PATH=$PM_DIR:$PARU_DIR
D=$(new_home pk2)
rs "$D"
rc_is 0 "packages without failures succeed"
grep -q 'x' "$STUB_DIR/paru.log" || fail "AUR packages go through paru when yay is missing"
pass "AUR packages go through paru when yay is missing"

: >"$STUB_DIR/installed"
rm -f "$STUB_DIR"/pacman.log
EXTRA_PATH=$PM_DIR
D=$(new_home pk3)
rs "$D"
out_has 'neither yay nor paru' "a missing AUR helper is reported"
rm -f "$STUB_DIR/pacman.log"
rs "$D" --no-packages
[[ ! -e $STUB_DIR/pacman.log ]] || fail "--no-packages installs nothing"
pass "--no-packages installs nothing"

EXTRA_PATH=""
rm -f "$STUB_DIR/pacman.log"
D=$(new_home pk4)
rs "$D"
rc_is 0 "a system without pacman restores"
is_file "$D/omarchy-transfer-packages.txt" "a system without pacman gets a package list"
grep -qxF a "$D/omarchy-transfer-packages.txt" && grep -qxF x "$D/omarchy-transfer-packages.txt" || fail "the list has official and AUR names"
pass "the list has official and AUR names"
[[ ! -e $STUB_DIR/pacman.log ]] || fail "nothing is installed without pacman"
pass "nothing is installed without pacman"

echo "# missing tools"
TOOLDIR=$TOOLS_NOZSTD
EXTRA_PATH=$APT_DIR
D=$(new_home nozstd)
before=$(snapshot "$D")
rs "$D"
rc_fails "a missing zstd fails"
out_has 'sudo apt install zstd' "a missing zstd shows the install command for the package manager"
equal "$before" "$(snapshot "$D")" "a missing tool changes nothing"
EXTRA_PATH=""
TOOLDIR=$TOOLS

echo "# Omarchy hand-over"
D=$(new_home nat)
rm -f "$STUB_DIR/native.log"
EXTRA_PATH=$NATIVE_DIR
rs "$D" --native --dry-run --wifi --mode=ask
rc_is 0 "--native hands over"
grep -q -- "--dry-run --wifi --mode=ask .*omarchy-transfer-.*tar.zst" "$STUB_DIR/native.log" || fail "--native passes the options and the archive on" "$(cat "$STUB_DIR/native.log" 2>/dev/null)"
pass "--native passes the options and the archive on"
no_file "$D/Documents" "the hand-over restores nothing itself"

rm -f "$STUB_DIR/native.log"
EXTRA_ENV=(OMARCHY_PATH="$ROOT" OMARCHY_TRANSFER_FORCE_PORTABLE=0)
rs "$D" --portable --no-packages
rc_is 0 "--portable restores itself"
[[ ! -e $STUB_DIR/native.log ]] || fail "--portable does not hand over"
pass "--portable does not hand over"
is_file "$D/Documents/a.txt" "--portable restores the files"
no_file "$D/omarchy-transfer-configs" "nothing is parked when Omarchy is present"
is_file "$D/.config/hypr/hyprland.conf" "Omarchy configs are restored directly on Omarchy"

rm -f "$STUB_DIR/native.log"
D=$(new_home nat2)
EXTRA_ENV=(OMARCHY_PATH="$ROOT" OMARCHY_TRANSFER_FORCE_PORTABLE=0)
rs "$D"
rc_is 0 "Omarchy is detected without a flag"
grep -q 'omarchy-transfer-' "$STUB_DIR/native.log" || fail "Omarchy is detected and handed over to"
pass "Omarchy is detected and handed over to"
EXTRA_ENV=()
EXTRA_PATH=""

echo "# Wi-Fi"
W=$WORK/wifi-case
rm -rf "$W"
mkdir -p "$W/meta/omarchy-transfer" "$W/tree/home" "$W/tree/wifi/networkmanager" "$W/out"
printf 'format=2\nomarchy_version=test\ndate=2026-01-01\nhost=t\nuser=u\nhome=/x\nencrypted=no\nwifi=networkmanager\n' >"$W/meta/omarchy-transfer/meta"
echo hi >"$W/tree/home/f.txt"
echo "secret-psk" >"$W/tree/wifi/networkmanager/home.nmconnection"
chmod 600 "$W/tree/wifi/networkmanager/home.nmconnection"
tar -cf - -C "$W/meta" omarchy-transfer -C "$W/tree" home wifi | zstd -q -3 -f --check -o "$W/out/omarchy-transfer-wifi-1.tar.zst"
WA=$W/out/omarchy-transfer-wifi-1.tar.zst

D=$(new_home wifi0)
rs "$D" "$WA"
rc_is 0 "a restore without --wifi succeeds"
no_file "$OMARCHY_TRANSFER_NM_DIR/home.nmconnection" "Wi-Fi is not restored without --wifi"
out_has 'run again with --wifi' "the archive's Wi-Fi data is mentioned"

echo networkmanager >"$STUB_DIR/backend"
rm -f "$STUB_DIR/nmcli.log"
D=$(new_home wifi1)
rs "$D" --wifi "$WA"
rc_is 0 "--wifi with NetworkManager succeeds"
content_is "$OMARCHY_TRANSFER_NM_DIR/home.nmconnection" "secret-psk" "the NetworkManager profile is restored"
equal 600 "$(stat -c %a "$OMARCHY_TRANSFER_NM_DIR/home.nmconnection")" "the profile has mode 600"
grep -q 'connection reload' "$STUB_DIR/nmcli.log" || fail "NetworkManager is told to reload"
pass "NetworkManager is told to reload"

echo none >"$STUB_DIR/backend"
D=$(new_home wifi2)
rs "$D" --wifi "$WA"
rc_is 0 "--wifi without a backend only warns"
content_is "$D/omarchy-transfer-wifi/networkmanager/home.nmconnection" "secret-psk" "the Wi-Fi files are saved in ~/omarchy-transfer-wifi"
equal 700 "$(stat -c %a "$D/omarchy-transfer-wifi")" "the fallback folder has mode 700"

echo "# old archives with the hidden .omarchy-transfer/ directory"
OLD=$W/out/omarchy-transfer-old-1.tar.zst
tar -cf - --transform='s,^omarchy-transfer,.omarchy-transfer,' -C "$W/meta" omarchy-transfer -C "$W/tree" home | zstd -q -3 -f --check -o "$OLD"
zstd -dc -- "$OLD" | tar -t | grep -q '^\.omarchy-transfer/meta$' || fail "the old-style fixture has a hidden metadata directory"
pass "the old-style fixture has a hidden metadata directory"
D=$(new_home old1)
rs "$D" --extract-only "$WORK/old-extracted" "$OLD"
rc_is 0 "--extract-only accepts an old-style archive"
is_file "$WORK/old-extracted/.omarchy-transfer/meta" "extract-only unpacks the old metadata directory"
D=$(new_home old2)
rs "$D" --no-packages "$OLD"
rc_is 0 "a restore of an old-style archive succeeds"
content_is "$D/f.txt" hi "the old-style archive restores its files"

echo "# integrity"
new_case() {
  CASE=$WORK/case.$1
  rm -rf "$CASE"
  M=$CASE/meta
  T=$CASE/tree/home
  mkdir -p "$M/omarchy-transfer" "$T" "$CASE/out"
  printf 'format=2\nomarchy_version=test\ndate=2026-01-01\nhost=t\nuser=u\nhome=/x\nencrypted=no\nwifi=none\n' >"$M/omarchy-transfer/meta"
  echo ok >"$T/fine.txt"
}
mk_raw() { # out; EXTRA runs on the raw tar
  tar -cf "$CASE/raw.tar" -C "$M" omarchy-transfer -C "$CASE/tree" home
  [[ -z ${EXTRA:-} ]] || eval "$EXTRA"
  zstd -q -3 -f --check -o "$1" "$CASE/raw.tar"
}
rejected() { # description archive
  local d
  d=$(new_home rej)
  local snap
  snap=$(snapshot "$d")
  rs "$d" --no-packages "$2"
  rc_fails "$1: restore fails"
  equal "$snap" "$(snapshot "$d")" "$1: HOME is untouched"
  equal 0 "$(stage_count "$d")" "$1: no staging folder is left"
  out_lacks 'unbound variable|line [0-9]+:' "$1: no shell error leaks out"
}

new_case evil
evil=$CASE/evil
mkdir -p "$evil"
echo pwned >"$evil/evil"

EXTRA='tar -rPf "$CASE/raw.tar" -C "$evil" --transform="s,^evil,home/../../escape-test," evil'
mk_raw "$CASE/out/traversal.tar.zst"
rejected "a .. member" "$CASE/out/traversal.tar.zst"
no_file "$WORK/escape-test" "the .. member wrote nothing outside"

EXTRA='tar -rPf "$CASE/raw.tar" -C "$evil" --transform="s,^evil,$WORK/abs-escape," evil'
mk_raw "$CASE/out/absolute.tar.zst"
rejected "an absolute member" "$CASE/out/absolute.tar.zst"
no_file "$WORK/abs-escape" "the absolute member wrote nothing"

EXTRA='tar -rPf "$CASE/raw.tar" -C "$evil" --transform="s,^evil,etc/evil," evil'
mk_raw "$CASE/out/toplevel.tar.zst"
rejected "a member outside the allowed folders" "$CASE/out/toplevel.tar.zst"

mkdir -p "$CASE/outside"
ln -s "$CASE/outside" "$CASE/tree/home/link"
EXTRA='tar -rPf "$CASE/raw.tar" -C "$evil" --transform="s,^evil,home/link/evil," evil'
mk_raw "$CASE/out/symlink.tar.zst"
rejected "a member below a symlink" "$CASE/out/symlink.tar.zst"
no_file "$CASE/outside/evil" "nothing was written through the symlink"
rm -f "$CASE/tree/home/link"

EXTRA=""
sed -i 's/^format=.*/format=99/' "$M/omarchy-transfer/meta"
mk_raw "$CASE/out/format.tar.zst"
rejected "format=99" "$CASE/out/format.tar.zst"

head -c 4096 /dev/urandom >"$CASE/out/garbage.tar.zst"
rejected "a garbage archive" "$CASE/out/garbage.tar.zst"
size=$(stat -c %s "$ARCHIVE")
head -c $((size / 2)) "$ARCHIVE" >"$CASE/out/truncated.tar.zst"
rejected "a truncated archive" "$CASE/out/truncated.tar.zst"

D=$(new_home missing)
rs "$D" "$WORK/nope.tar.zst"
rc_fails "a missing archive fails"
out_has 'not found' "a missing archive is reported in words"

echo "# non-root and no archive"
SCRIPT=$WORK/lonely/omarchy-transfer-restore.sh
mkdir -p "$WORK/lonely"
cp "$RESTORE" "$SCRIPT"
rs "$(new_home none)"
rc_fails "no archive next to the script fails"
out_has 'no omarchy-transfer' "a missing archive next to the script is explained"
SCRIPT=$OUTDIR/omarchy-transfer-restore.sh

echo "# static checks"
if command -v shellcheck >/dev/null; then
  shellcheck "$RESTORE" || fail "shellcheck is clean"
  pass "shellcheck is clean"
fi
if grep -nE 'omarchy-(cmd|pkg|notification|transfer-functions|version)|source omarchy|\bgum\b|OMARCHY_PATH=|\$OMARCHY_PATH|\$\{OMARCHY_PATH:' "$RESTORE" | grep -vE '^[0-9]+:\s*#' | grep -vE 'on_omarchy|\[\[ -n \$\{OMARCHY_PATH' >/dev/null; then
  fail "restore.sh has no Omarchy dependency" "$(grep -nE 'omarchy-(cmd|pkg|notification|transfer-functions|version)|\bgum\b' "$RESTORE")"
fi
pass "restore.sh has no Omarchy dependency"
[[ -x $RESTORE ]] || fail "restore.sh is executable"
pass "restore.sh is executable"
awk 'length > 80 { bad = 1 } END { exit bad }' "$ROOT/default/transfer/README.txt" || fail "README.txt fits in 80 columns"
pass "README.txt fits in 80 columns"
