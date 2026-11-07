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

DEFAULT_CONF=$ROOT/default/omarchy/transfer.conf
LIB=$ROOT/bin/omarchy-transfer-functions

echo "# the library"
RC=0
OUT=$(bash "$LIB" 2>&1) || RC=$?
equal 64 "$RC" "executing the library directly exits 64"

source "$LIB"
equal 2 "$TRANSFER_FORMAT" "the archive format is 2"
equal "$OMARCHY_TRANSFER_CONF" "$TRANSFER_CONF" "OMARCHY_TRANSFER_CONF overrides the config path"

OUT=$( (transfer_warn "careful") 2>/dev/null)
equal "" "$OUT" "transfer_warn writes nothing to stdout"
OUT=$( (transfer_warn "careful") 2>&1)
grep -q careful <<<"$OUT" || fail "transfer_warn writes to stderr" "$OUT"
pass "transfer_warn writes to stderr"
RC=0
OUT=$( (transfer_die "boom") 2>&1) || RC=$?
equal 1 "$RC" "transfer_die exits 1"
grep -q boom <<<"$OUT" || fail "transfer_die prints its message to stderr" "$OUT"
pass "transfer_die prints its message to stderr"

echo "# the shipped default config"
is_file "$DEFAULT_CONF" "default/omarchy/transfer.conf exists"
for section in options include exclude; do
  grep -q "^\[$section\]" "$DEFAULT_CONF" || fail "the default has a [$section] section"
  pass "the default has a [$section] section"
done
for phrase in 'dry-run' 'Setup' 'passphrase|encrypt' 'sudo'; do
  grep -qiE "^#.*($phrase)" "$DEFAULT_CONF" || fail "the default explains: $phrase"
  pass "the default explains: $phrase"
done
# Every group of entries starts under a comment line.
prev=""
while IFS= read -r line; do
  if [[ -n $line && $line != \#* && $line != \[* ]]; then
    [[ -n $prev && $prev != \[* ]] || fail "every entry in the default has a comment above it" "no comment above: $line"
  fi
  prev=$line
done <"$DEFAULT_CONF"
pass "every group of entries in the default has a comment above it"

rm -f "$OMARCHY_TRANSFER_CONF"
transfer_load_conf
equal yes "$OPT_PACKAGES" "the default installs packages: packages = yes"
equal yes "$OPT_ENCRYPT" "the default encrypts, so secrets are included"
equal no "$OPT_WIFI" "the default leaves Wi-Fi off"
for want in .config .local/share/fonts .bashrc .gitconfig .ssh .gnupg Documents Pictures Dev; do
  printf '%s\n' "${INCLUDES[@]}" | grep -qxF -- "$want" || fail "the default includes $want" "${INCLUDES[*]}"
  pass "the default includes $want"
done
for want in .cache node_modules .local/share/Trash; do
  printf '%s\n' "${EXCLUDES[@]}" | grep -qxF -- "$want" || fail "the default excludes $want" "${EXCLUDES[*]}"
  pass "the default excludes $want"
done

echo "# ensure"
NESTED=$WORK/deep/er/transfer.conf
TRANSFER_CONF=$NESTED transfer_ensure_conf
is_file "$NESTED" "transfer_ensure_conf creates missing parent directories and the file"
cmp -s "$NESTED" "$DEFAULT_CONF" || fail "the created config is a copy of the default"
pass "the created config is a copy of the default"
echo "# mine" >>"$NESTED"
TRANSFER_CONF=$NESTED transfer_ensure_conf
grep -qx '# mine' "$NESTED" || fail "transfer_ensure_conf keeps an existing config"
pass "transfer_ensure_conf keeps an existing config"

echo "# parser"
mkdir -p "$WORK/globdir/x"
cat >"$OMARCHY_TRANSFER_CONF" <<'CONF'
# top comment
[OPTIONS]
packages = off
Wifi = true
encrypt = 1

[Include]
# comment text
Documents/
dir#x
My Docs
#Disabled
# not an entry
a&b
x|y
back\slash

[EXCLUDE]
*/cache2
# comment
.cache
CONF
# Run from a directory where the exclude pattern would match something.
cd "$WORK/globdir"
transfer_load_conf
cd "$WORK"
equal no "$OPT_PACKAGES" "options are read case-insensitively: off is no"
equal yes "$OPT_WIFI" "options are read case-insensitively: true is yes"
equal yes "$OPT_ENCRYPT" "options accept 1"
expected=$'Documents\ndir#x\nMy Docs\na&b\nx|y\nback\\slash'
equal "$expected" "$(printf '%s\n' "${INCLUDES[@]}")" "includes: trailing / stripped, # inside a name kept, spaces kept, disabled entries skipped"
equal $'*/cache2\n.cache' "$(printf '%s\n' "${EXCLUDES[@]}")" "excludes keep glob patterns literal"

for bad in '/etc/passwd' '../outside' 'a/../../b'; do
  printf '[include]\n%s\n' "$bad" >"$OMARCHY_TRANSFER_CONF"
  RC=0
  ( transfer_load_conf ) >/dev/null 2>&1 || RC=$?
  (( RC != 0 )) || fail "an include of '$bad' is rejected"
  pass "an include of '$bad' is rejected"
done

echo "# entries and toggles"
cat >"$OMARCHY_TRANSFER_CONF" <<'CONF'
# header

[options]
# Install packages.
packages = yes
# Wi-Fi.
wifi = no
encrypt = no

[include]
# Config.
.config
.config2
Dev
Dev/sub
#Pictures
# Plain comment
dir#x
with space
a&b
x|y
back\slash

[exclude]
.cache
CONF
cp "$OMARCHY_TRANSFER_CONF" "$WORK/conf.orig"

expected=$'on\t.config\non\t.config2\non\tDev\non\tDev/sub\noff\tPictures\non\tdir#x\non\twith space\non\ta&b\non\tx|y\non\tback\\slash'
equal "$expected" "$(transfer_conf_entries)" "entries list every include in file order with its state"

changed_lines() { diff "$WORK/conf.orig" "$OMARCHY_TRANSFER_CONF" | grep -c '^>' || true; }

transfer_conf_set_include Dev off
equal 1 "$(changed_lines)" "disabling Dev changes exactly one line"
grep -qx '#Dev' "$OMARCHY_TRANSFER_CONF" || fail "a disabled entry is the path behind a # without a space"
pass "a disabled entry is the path behind a # without a space"
grep -qx 'Dev/sub' "$OMARCHY_TRANSFER_CONF" || fail "disabling Dev leaves Dev/sub on"
pass "disabling Dev leaves Dev/sub on"
grep -qx '.config2' "$OMARCHY_TRANSFER_CONF" || fail "disabling is exact, not a prefix match"
pass "disabling is exact, not a prefix match"
transfer_conf_set_include Dev on
cmp -s "$WORK/conf.orig" "$OMARCHY_TRANSFER_CONF" || fail "off then on restores the file byte for byte" "$(diff "$WORK/conf.orig" "$OMARCHY_TRANSFER_CONF")"
pass "off then on restores the file byte for byte"

transfer_conf_set_include Pictures on
grep -qx 'Pictures' "$OMARCHY_TRANSFER_CONF" || fail "enabling removes the # before the path"
pass "enabling removes the # before the path"
equal 1 "$(grep -c 'Pictures' "$OMARCHY_TRANSFER_CONF")" "enabling does not duplicate the entry"
transfer_conf_set_include Pictures off
cmp -s "$WORK/conf.orig" "$OMARCHY_TRANSFER_CONF" || fail "on then off restores the file byte for byte"
pass "on then off restores the file byte for byte"

for odd in 'dir#x' 'with space' 'a&b' 'x|y' 'back\slash'; do
  transfer_conf_set_include "$odd" off
  grep -qxF -- "#$odd" "$OMARCHY_TRANSFER_CONF" || fail "'$odd' is disabled" "$(cat "$OMARCHY_TRANSFER_CONF")"
  equal 1 "$(changed_lines)" "disabling '$odd' changes exactly one line"
  transfer_conf_set_include "$odd" on
  cmp -s "$WORK/conf.orig" "$OMARCHY_TRANSFER_CONF" || fail "'$odd' toggles back byte for byte" "$(diff "$WORK/conf.orig" "$OMARCHY_TRANSFER_CONF")"
  pass "'$odd' survives a toggle round trip"
done

transfer_conf_set_include NewFolder on
sections=$(awk '/^\[/ { s = $0 } $0 == "NewFolder" { print s }' "$OMARCHY_TRANSFER_CONF")
equal "[include]" "$sections" "a new entry is added to [include]"
transfer_load_conf
printf '%s\n' "${INCLUDES[@]}" | grep -qxF NewFolder || fail "the new entry is loaded"
pass "the new entry is loaded"
cp "$WORK/conf.orig" "$OMARCHY_TRANSFER_CONF"

transfer_conf_set_option packages no
equal 1 "$(changed_lines)" "setting an option changes exactly one line"
transfer_load_conf
equal no "$OPT_PACKAGES" "the option change is read back"
grep -qx '# Install packages.' "$OMARCHY_TRANSFER_CONF" || fail "the comment above the option is kept"
pass "the comment above the option is kept"
transfer_conf_set_option encrypt yes
transfer_load_conf
equal yes "$OPT_ENCRYPT" "a second option can be set"
equal no "$OPT_PACKAGES" "setting one option leaves the others"
equal 0 "$(find "$(dirname "$OMARCHY_TRANSFER_CONF")" -maxdepth 1 -name 'transfer.conf?*' | wc -l)" "the atomic write leaves no temp file"
cp "$WORK/conf.orig" "$OMARCHY_TRANSFER_CONF"

echo "# helpers"
for secret in .ssh .ssh/id_ed25519 .gnupg .gnupg/private-keys-v1.d/x .password-store .local/share/keyrings .local/share/keyrings/login.keyring; do
  transfer_is_secret "$secret" || fail "$secret is a secret"
  pass "$secret is a secret"
done
for plain in .config .sshx .ssh_config Documents .local/share/fonts; do
  if transfer_is_secret "$plain"; then fail "$plain is not a secret"; fi
  pass "$plain is not a secret"
done

human=$(transfer_human 0)
[[ $human == 0* ]] || fail "transfer_human 0" "$human"
pass "transfer_human 0 starts with 0"
human=$(transfer_human 1048576)
grep -qE '^1([.,]0+)? ?(M|MiB|MB)' <<<"$human" || fail "transfer_human 1048576 reads as 1 MiB" "$human"
pass "transfer_human 1048576 reads as 1 MiB"
human=$(transfer_human 5368709120)
grep -qE '^5([.,]0+)? ?(G|GiB|GB)' <<<"$human" || fail "transfer_human 5368709120 reads as 5 GiB" "$human"
pass "transfer_human 5368709120 reads as 5 GiB"

echo networkmanager >"$STUB_DIR/backend"
equal networkmanager "$(transfer_wifi_backend)" "NetworkManager is detected"
echo iwd >"$STUB_DIR/backend"
equal iwd "$(transfer_wifi_backend)" "iwd is detected"
echo none >"$STUB_DIR/backend"
equal none "$(transfer_wifi_backend)" "no backend is reported as none"

if [[ -e /etc/skel/.bashrc ]]; then
  equal /etc/skel/.bashrc "$(transfer_default_source .bashrc)" "a dotfile maps to /etc/skel"
fi
RC=0
transfer_default_source .no-such-default-zz >/dev/null 2>&1 || RC=$?
(( RC != 0 )) || fail "a file without a shipped default has no default source"
pass "a file without a shipped default has no default source"
sample=$(find "$ROOT/config" -maxdepth 1 -mindepth 1 | head -n1)
name=$(basename "$sample")
if [[ -e /etc/skel/.config/$name ]]; then
  equal "/etc/skel/.config/$name" "$(transfer_default_source ".config/$name")" "a .config path maps to /etc/skel first"
else
  equal "$ROOT/config/$name" "$(transfer_default_source ".config/$name")" "a .config path maps to config/ in the checkout"
fi

echo "# cleanup"
victim=$WORK/victim
mkdir -p "$victim/ro/deeper"
echo x >"$victim/ro/deeper/f"
chmod 555 "$victim/ro/deeper" "$victim/ro"
( transfer_cleanup_register "$victim"; exit 0 )
no_file "$victim" "a registered read-only directory is removed on exit"
( transfer_cleanup_register "$WORK/never-existed"; exit 0 )
pass "registering a missing directory does not fail the exit"
victim2=$WORK/victim2
mkdir -p "$victim2"
( transfer_cleanup_register "$victim2"; kill -TERM "$BASHPID"; sleep 5 ) || true
no_file "$victim2" "a registered directory is removed on SIGTERM"

echo "# transfer-config"
rm -f "$OMARCHY_TRANSFER_CONF" "$STUB_DIR/omarchy-launch-config-editor.log"
tx "$WORK/nohome" config
rc_is 0 "omarchy-transfer-config succeeds"
is_file "$OMARCHY_TRANSFER_CONF" "omarchy-transfer-config creates the missing config"
cmp -s "$OMARCHY_TRANSFER_CONF" "$DEFAULT_CONF" || fail "the created config is the default"
pass "the created config is the default"
grep -qF "$OMARCHY_TRANSFER_CONF" "$STUB_DIR/omarchy-launch-config-editor.log" || fail "the config opens in the editor"
pass "the config opens in the editor"
echo "# mine" >>"$OMARCHY_TRANSFER_CONF"
tx "$WORK/nohome" config
grep -qx '# mine' "$OMARCHY_TRANSFER_CONF" || fail "an existing config is not overwritten"
pass "an existing config is not overwritten"

echo "# export validates the config"
write_conf no no no ../etc
mkdir -p "$WORK/out/val"
tx "$WORK/nohome" export --dry-run "$WORK/out/val"
rc_fails "an include with .. is rejected by the export"
write_conf no no no /etc/passwd
tx "$WORK/nohome" export --dry-run "$WORK/out/val"
rc_fails "an absolute include is rejected by the export"
equal 0 "$(find "$WORK/out/val" -mindepth 1 | wc -l)" "a rejected config writes nothing"
