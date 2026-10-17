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

# A shipped default the new system can be compared with: the first small file
# under config/ that the library maps to a default source.
source "$ROOT/bin/omarchy-transfer-functions"
DEF_REL="" DEF_SRC=""
while IFS= read -r -d '' f; do
  rel=.config/${f#"$ROOT/config/"}
  if src=$(transfer_default_source "$rel") && [[ -f $src ]]; then
    DEF_REL=$rel DEF_SRC=$src
    break
  fi
done < <(find "$ROOT/config" -type f -size -8k -print0 | sort -z)

# The common archive: one file per decision rule.
build_policy_case() {
  new_case "$1"
  mkdir -p "$T/blocked" "$T/dir"
  echo "from archive" >"$T/new.txt"
  echo "same" >"$T/same.txt"
  echo "old default" >"$T/pristine.txt"
  echo "from archive" >"$T/modified.txt"
  echo "from archive" >"$T/stow.txt"
  echo "from archive" >"$T/blocked/file.txt"
  echo "from archive" >"$T/dir/in-dir.txt"
  echo 'k=1' >"$T/exec.sh"
  chmod 750 "$T/exec.sh"
  ln -s same.txt "$T/newlink"
  ln -s same.txt "$T/samelink"
  printf 'pristine.txt\n' >"$M/omarchy-transfer/pristine.list"
  if [[ -n $DEF_REL ]]; then
    mkdir -p "$T/$(dirname "$DEF_REL")"
    echo "customized on the old machine" >"$T/$DEF_REL"
  fi
  mk_archive "$CASE/a.tar.zst"
  # The new system.
  echo "same" >"$D/same.txt"
  echo "new default" >"$D/pristine.txt"
  echo "changed on the new machine" >"$D/modified.txt"
  mkdir -p "$CASE/dots"
  echo "from archive" >"$CASE/dots/stow.txt"
  ln -s "$CASE/dots/stow.txt" "$D/stow.txt"
  ln -s same.txt "$D/samelink"
  if [[ -n $DEF_REL ]]; then
    mkdir -p "$D/$(dirname "$DEF_REL")"
    cp -- "$DEF_SRC" "$D/$DEF_REL"
  fi
  ARCHIVE=$CASE/a.tar.zst
}

echo "# smart mode"
build_policy_case smart
tx "$D" import --dry-run "$ARCHIVE"
rc_is 0 "smart --dry-run succeeds"
no_file "$D/new.txt" "--dry-run adds nothing"
no_file "$D/modified.txt.transfer" "--dry-run writes no conflict file"
tx "$D" import --mode=smart "$ARCHIVE"
rc_is 0 "smart import succeeds even with conflicts"
content_is "$D/new.txt" "from archive" "rule 1: a missing target is added"
equal 750 "$(stat -c %a "$D/exec.sh")" "an added file keeps its mode"
equal same.txt "$(readlink "$D/newlink")" "a missing symlink is added as a symlink"
content_is "$D/same.txt" "same" "rule 2: an identical file stays"
equal same.txt "$(readlink "$D/samelink")" "rule 2: an identical symlink stays"
[[ -L $D/stow.txt ]] || fail "rule 2: a symlink to identical content stays a symlink"
pass "rule 2: a symlink to identical content stays a symlink"
content_is "$CASE/dots/stow.txt" "from archive" "rule 2: the stow target is untouched"
no_file "$D/stow.txt.transfer" "rule 2: a symlink to identical content is no conflict"
content_is "$D/pristine.txt" "new default" "rule 3: an old unmodified default does not replace the new default"
no_file "$D/pristine.txt.transfer" "rule 3: no conflict file for an old default"
equal 0 "$(find "$D" -name 'pristine.txt.bak.*' | wc -l)" "rule 3: no backup for an old default"
content_is "$D/modified.txt" "changed on the new machine" "rule 5: a file changed on the new system is kept"
content_is "$D/modified.txt.transfer" "from archive" "rule 5: the archive version is saved as .transfer"
out_has 'conflict' "rule 5: the summary mentions conflicts"
out_has 'modified\.txt' "rule 5: the summary lists the conflicting file"
if [[ -n $DEF_REL ]]; then
  content_is "$D/$DEF_REL" "customized on the old machine" "rule 4: an untouched new default is replaced by the old customization"
  bak=$(find "$D/$(dirname "$DEF_REL")" -maxdepth 1 -name "$(basename "$DEF_REL").bak.*" | head -n1)
  [[ -n $bak ]] || fail "rule 4: the replaced default is saved as .bak.<epoch>"
  cmp -s "$bak" "$DEF_SRC" || fail "rule 4: the .bak holds the original default"
  pass "rule 4: the replaced default is saved as .bak.<epoch>"
else
  skip "rule 4: no shipped default found under config/"
fi
content_is "$D/dir/in-dir.txt" "from archive" "files in new directories are added"

echo "# second smart run is stable"
tx "$D" import "$ARCHIVE"
rc_is 0 "a repeated smart import succeeds"
content_is "$D/modified.txt" "changed on the new machine" "the repeated import still keeps the changed file"
if [[ -n $DEF_REL ]]; then
  content_is "$D/$DEF_REL" "customized on the old machine" "the repeated import leaves the restored file"
  equal 1 "$(find "$D/$(dirname "$DEF_REL")" -maxdepth 1 -name "$(basename "$DEF_REL").bak.*" | wc -l)" "the repeated import makes no second backup"
fi

echo "# rule 6: blocked paths"
build_policy_case blocked
echo "i am a file" >"$D/blocked"
tx "$D" import "$ARCHIVE"
content_is "$D/blocked" "i am a file" "rule 6: a file in the way of a directory is untouched"
out_has 'blocked' "rule 6: the summary reports the blocked path"
out_lacks '^tar:' "rule 6: no raw tar errors"
content_is "$D/new.txt" "from archive" "rule 6: other files are still restored"

echo "# overwrite"
build_policy_case overwrite
tx "$D" import --mode=overwrite "$ARCHIVE"
rc_is 0 "overwrite import succeeds"
content_is "$D/modified.txt" "from archive" "overwrite replaces a changed file"
bak=$(find "$D" -maxdepth 1 -name 'modified.txt.bak.*' | head -n1)
[[ -n $bak ]] || fail "overwrite saves the old file as .bak.<epoch>"
content_is "$bak" "changed on the new machine" "overwrite saves the old file as .bak.<epoch>"
content_is "$D/pristine.txt" "old default" "overwrite also replaces a file that was an old default"
equal 0 "$(find "$D" -maxdepth 1 -name 'same.txt.bak.*' | wc -l)" "overwrite leaves identical files alone"
no_file "$D/modified.txt.transfer" "overwrite writes no .transfer file"

echo "# skip"
build_policy_case skip
tx "$D" import --mode=skip "$ARCHIVE"
rc_is 0 "skip import succeeds"
content_is "$D/modified.txt" "changed on the new machine" "skip never touches an existing file"
content_is "$D/pristine.txt" "new default" "skip keeps the old default case as well"
no_file "$D/modified.txt.transfer" "skip writes no .transfer file"
equal 0 "$(find "$D" -name '*.bak.*' | wc -l)" "skip writes no backups"
content_is "$D/new.txt" "from archive" "skip still adds missing files"

echo "# ask"
build_policy_case ask
tx "$D" import --mode=ask "$ARCHIVE"
rc_fails "ask refuses to run without a terminal"
content_is "$D/modified.txt" "changed on the new machine" "ask without a terminal leaves existing files alone"

if ! command -v script >/dev/null; then
  skip "ask prompts: script(1) is missing"
else
  ask_case() { # name
    new_case "ask-$1"
    echo "from archive" >"$T/a.txt"
    echo "from archive" >"$T/b.txt"
    mk_archive "$CASE/a.tar.zst"
    echo "local a" >"$D/a.txt"
    echo "local b" >"$D/b.txt"
    ARCHIVE=$CASE/a.tar.zst
  }

  ask_case o
  pty_run "o" env HOME="$D" "$ROOT/bin/omarchy-transfer-import" --mode=ask "$ARCHIVE"
  out_has 'local a' "ask shows a diff of the conflicting file"
  content_is "$D/a.txt" "from archive" "ask: o replaces the file"
  bak=$(find "$D" -maxdepth 1 -name 'a.txt.bak.*' | head -n1)
  [[ -n $bak ]] && content_is "$bak" "local a" "ask: o keeps the old file as .bak.<epoch>"

  ask_case s
  pty_run "s
s" env HOME="$D" "$ROOT/bin/omarchy-transfer-import" --mode=ask "$ARCHIVE"
  content_is "$D/a.txt" "local a" "ask: s keeps the file"
  equal 0 "$(find "$D" -name '*.bak.*' | wc -l)" "ask: s writes no backup"

  ask_case A
  pty_run "A" env HOME="$D" "$ROOT/bin/omarchy-transfer-import" --mode=ask "$ARCHIVE"
  content_is "$D/a.txt" "from archive" "ask: A replaces the first file"
  content_is "$D/b.txt" "from archive" "ask: A replaces the rest without asking"

  ask_case N
  pty_run "N" env HOME="$D" "$ROOT/bin/omarchy-transfer-import" --mode=ask "$ARCHIVE"
  content_is "$D/a.txt" "local a" "ask: N keeps the first file"
  content_is "$D/b.txt" "local b" "ask: N keeps the rest without asking"

  new_case ask-secret
  mkdir -p "$T/.ssh"
  echo "NEWSECRETVALUE" >"$T/.ssh/id_x"
  mk_archive "$CASE/a.tar.zst"
  mkdir -p "$D/.ssh"
  echo "OLDSECRETVALUE" >"$D/.ssh/id_x"
  pty_run "s" env HOME="$D" "$ROOT/bin/omarchy-transfer-import" --mode=ask "$CASE/a.tar.zst"
  out_lacks 'SECRETVALUE' "ask never prints secrets in a diff"
  content_is "$D/.ssh/id_x" "OLDSECRETVALUE" "ask: a secret that was kept stays"
fi

echo "# mode validation"
new_case modes
echo x >"$T/plain.txt"
mk_archive "$CASE/a.tar.zst"
tx "$D" import --mode=bogus "$CASE/a.tar.zst"
rc_fails "an unknown --mode is rejected"
no_file "$D/plain.txt" "a rejected --mode restores nothing"
