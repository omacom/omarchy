#!/bin/bash

# Omarchy transfer: portable restore tool.
#
# This script is copied into every transfer archive (omarchy-transfer/restore.sh)
# and next to it (omarchy-transfer-restore.sh). It must run on ANY Linux, with
# or without Omarchy. Do not add dependencies on omarchy-* commands, $OMARCHY_PATH,
# gum or a sourced library. Needs: bash >= 4, GNU coreutils, tar, zstd, find,
# awk, grep, cmp; age only for encrypted archives; diff only for --mode=ask.
#
# Usage: bash omarchy-transfer-restore.sh [--dry-run] [--mode=keep|ask|overwrite|skip]
#          [--no-packages] [--wifi] [--extract-only <dir>] [--native|--portable]
#          [<archive>]

if (( BASH_VERSINFO[0] < 4 )); then
  echo "restore: bash 4 or newer is required" >&2
  exit 1
fi

set -euo pipefail

# Names are handled as raw bytes; the locale only matters for sort/awk.
export LC_ALL=C

info() { printf '==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'USAGE'
Usage: bash omarchy-transfer-restore.sh [options] [<archive>]

  --dry-run          show what would happen, change nothing
  --mode=MODE        what to do with files that differ (default keep)
                       keep       keep yours, put the archive version at <file>.transfer
                       ask        show a diff and ask for every file
                       overwrite  replace, keep the old file as <file>.bak.<time>
                       skip       never touch existing files
  --no-packages      do not install packages
  --wifi             restore saved Wi-Fi networks (needs sudo)
  --extract-only DIR only check and unpack the archive into DIR
  --native           hand over to omarchy-transfer-import (Omarchy only)
  --portable         never hand over to omarchy-transfer-import

Without <archive> the script looks for omarchy-transfer-*.tar.zst[.age]
next to itself.
USAGE
}

dry_run=false
mode=keep
no_packages=false
want_wifi=false
extract_only=""
handoff=auto
archive=""

while (( $# > 0 )); do
  case $1 in
    --dry-run) dry_run=true ;;
    --mode=*) mode=${1#--mode=} ;;
    --mode)
      (( $# > 1 )) || die "--mode needs a value"
      mode=$2
      shift
      ;;
    --no-packages) no_packages=true ;;
    --wifi) want_wifi=true ;;
    --extract-only)
      (( $# > 1 )) || die "--extract-only needs a folder"
      extract_only=$2
      shift
      ;;
    --extract-only=*) extract_only=${1#--extract-only=} ;;
    --native) handoff=native ;;
    --portable) handoff=portable ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*) die "Unknown option: $1 (try --help)" ;;
    *)
      [[ -z $archive ]] || die "Only one archive allowed"
      archive=$1
      ;;
  esac
  shift
done

case $mode in
  keep | ask | overwrite | skip) ;;
  *) die "Unknown mode '$mode' (use keep, ask, overwrite or skip)" ;;
esac

(( EUID != 0 )) || die "Run this as your normal user, not root (sudo is used where needed)"
[[ -n ${HOME:-} && -d $HOME ]] || die "HOME is not set to an existing folder"

has_tty() {
  { : </dev/tty; } 2>/dev/null
}

have() {
  command -v "$1" >/dev/null 2>&1
}

# ---------------------------------------------------------------- archive

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

find_archives() {
  local dir file
  for dir in "$script_dir" "$PWD"; do
    for file in "$dir"/omarchy-transfer-*.tar.zst*; do
      if [[ -f $file && $file != *.part ]]; then
        printf '%s\n' "$file"
      fi
    done
  done | sort -u
}

if [[ -z $archive ]]; then
  mapfile -t found < <(find_archives)
  case ${#found[@]} in
    0) die "No omarchy-transfer-*.tar.zst[.age] found next to this script; pass the archive path" ;;
    1) archive=${found[0]} ;;
    *)
      has_tty || die "Several archives found and no terminal to choose one; pass the archive path:$(printf '\n  %s' "${found[@]}")"
      echo "Several archives found:"
      for i in "${!found[@]}"; do
        printf '  %d) %s\n' $((i + 1)) "${found[i]}"
      done
      while true; do
        read -r -p "Restore which one? [1-${#found[@]}] " choice </dev/tty || die "No archive chosen"
        if [[ $choice =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#found[@]} )); then
          archive=${found[choice - 1]}
          break
        fi
      done
      ;;
  esac
fi

# shellcheck disable=SC2088
case $archive in
  "~") archive=$HOME ;;
  "~/"*) archive=$HOME/${archive#"~/"} ;;
esac

[[ -f $archive && -r $archive ]] || die "Archive not found or not readable: $archive"
archive=$(cd -- "$(dirname -- "$archive")" && pwd)/$(basename -- "$archive")

encrypted=false
magic=$(head -c 21 -- "$archive" 2>/dev/null | tr -d '\0' || true)
if [[ $archive == *.age || $magic == "age-encryption.org/v1" ]]; then
  encrypted=true
fi

# ---------------------------------------------------------------- Omarchy

# Omarchy only counts when both its import command and its path are present.
on_omarchy() {
  [[ ${OMARCHY_TRANSFER_FORCE_PORTABLE:-} != 1 ]] && have omarchy-transfer-import && [[ -n ${OMARCHY_PATH:-} ]]
}

native_import() {
  local args=()
  [[ $dry_run == true ]] && args+=(--dry-run)
  [[ $want_wifi == true ]] && args+=(--wifi)
  case $mode in
    keep) ;;
    *) args+=("--mode=$mode") ;;
  esac
  exec omarchy-transfer-import "${args[@]}" "$archive"
}

if [[ $handoff == native ]]; then
  have omarchy-transfer-import || die "--native needs omarchy-transfer-import, which is only on Omarchy"
  [[ $no_packages == false && -z $extract_only ]] || die "--native cannot be combined with --no-packages or --extract-only"
  native_import
elif [[ $handoff == auto && -z $extract_only ]] && on_omarchy; then
  if [[ $no_packages == true ]]; then
    info "Omarchy found, but --no-packages is not supported by the native restore; restoring with this script"
  else
    use_native=true
    if has_tty; then
      read -r -p "Omarchy found. Use its native restore (recommended)? [Y/n] " ans </dev/tty || ans=n
      [[ $ans != [nN]* ]] || use_native=false
    fi
    if [[ $use_native == true ]]; then
      info "Handing over to omarchy-transfer-import"
      native_import
    fi
  fi
fi

parking=true
if on_omarchy; then
  parking=false
fi

# ---------------------------------------------------------------- tools

pkg_manager() {
  local pm
  for pm in pacman apt-get apt dnf zypper; do
    if have "$pm"; then
      echo "$pm"
      return 0
    fi
  done
  return 1
}

install_hint() { # packages...
  case $(pkg_manager || true) in
    pacman) echo "sudo pacman -S --needed $*" ;;
    apt-get | apt) echo "sudo apt install $*" ;;
    dnf) echo "sudo dnf install $*" ;;
    zypper) echo "sudo zypper install $*" ;;
    *) return 1 ;;
  esac
}

check_tools() {
  local c missing=() pkgs=() other=() hint ans
  for c in tar zstd; do
    have "$c" || { missing+=("$c"); pkgs+=("$c"); }
  done
  if [[ $encrypted == true ]] && ! have age; then
    missing+=(age)
    pkgs+=(age)
  fi
  for c in cmp awk find grep sort mktemp mkfifo tee; do
    have "$c" || { missing+=("$c"); other+=("$c"); }
  done
  if [[ $mode == ask ]] && ! have diff; then
    missing+=(diff)
    other+=(diff)
  fi
  (( ${#missing[@]} > 0 )) || return 0

  warn "Missing required commands: ${missing[*]}"
  if (( ${#other[@]} > 0 )); then
    die "Install ${other[*]} (GNU coreutils, findutils, diffutils, grep, gawk or mawk) and run again"
  fi
  for c in "${pkgs[@]}"; do
    case $c in
      tar) info "  tar   unpacks the archive" ;;
      zstd) info "  zstd  decompresses the archive" ;;
      age) info "  age   decrypts your encrypted archive" ;;
    esac
  done
  if hint=$(install_hint "${pkgs[@]}"); then
    if has_tty; then
      echo "Install command:  $hint" >&2
      read -r -p "Install ${pkgs[*]} now? [Y/n] " ans </dev/tty || ans=n
      if [[ $ans != [nN]* ]]; then
        bash -c "$hint" || die "The installation failed"
        for c in "${pkgs[@]}"; do
          have "$c" || die "$c is still missing"
        done
        return 0
      fi
    else
      echo "Install them with:  $hint" >&2
    fi
  else
    echo "Install ${pkgs[*]} with your package manager." >&2
  fi
  exit 1
}

check_tools

# ---------------------------------------------------------------- stage

base=${OMARCHY_TRANSFER_TMPDIR:-$HOME/.cache/omarchy-transfer}
mkdir -p "$base"
chmod 700 "$base" 2>/dev/null || true
tmp=$(mktemp -d "$base/stage.XXXXXX")
chmod 700 "$tmp"

cleanup() {
  trap - EXIT INT TERM HUP
  if [[ -n ${tmp:-} && -d $tmp ]]; then
    chmod -R u+w -- "$tmp" 2>/dev/null || true
    rm -rf -- "$tmp" 2>/dev/null || true
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

stage=$tmp/stage
work=$tmp/work
mkdir -m 700 "$stage" "$work"

human() {
  awk -v b="$1" 'BEGIN { split("B KiB MiB GiB TiB", u, " "); i = 1; while (b >= 1024 && i < 5) { b /= 1024; i++ } printf (i == 1 ? "%d %s" : "%.1f %s"), b, u[i] }'
}

archive_size=$(stat -c %s -- "$archive")
free=$(df -B1 --output=avail -- "$base" 2>/dev/null | tail -n 1 | tr -d ' ' || true)
if [[ ${free:-} =~ ^[0-9]+$ ]] && (( free < archive_size * 2 )); then
  warn "Low disk space for staging: $(human "$free") free, archive is $(human "$archive_size") (about 2x needed)"
fi

archive_stream() {
  if [[ $encrypted == true ]]; then
    age -d <"$archive" | zstd -dc -q
  else
    zstd -dc -q <"$archive"
  fi
}

# Checks the tar listing: only home/, omarchy-transfer/ (or the older .omarchy-transfer/) and wifi/, only files,
# folders and symlinks, no absolute paths, no "..", nothing below a symlink.
awk_check=$(cat <<'AWK'
function bad_(m) { print m > badf; nbad++ }
{
  if (!match($0, /^[^ ]+ +[^ ]+ +[0-9]+ +[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] +[0-9:]+ /)) {
    bad_("unreadable member: " $0)
    next
  }
  rest = substr($0, RLENGTH + 1)
  type = substr($0, 1, 1)
  name = rest
  if (type == "h") { bad_("hard link member: " rest); next }
  if (type != "-" && type != "d" && type != "l") { bad_("unsupported member type '" type "': " rest); next }
  if (type == "l") {
    i = index(rest, " -> ")
    if (i > 0) name = substr(rest, 1, i - 1)
  }
  sub(/^(\.\/)+/, "", name)
  sub(/\/+$/, "", name)
  if (name == "" || name == ".") next
  if (name ~ /^\// || name ~ /(^|\/)\.\.(\/|$)/) { bad_("unsafe path: " name); next }
  n = split(name, c, "/")
  top = c[1]
  if (top != "home" && top != "omarchy-transfer" && top != ".omarchy-transfer" && top != "wifi") { bad_("unexpected member: " name); next }
  if (n == 1 && type != "d") { bad_("top-level member is not a directory: " name); next }
  if ((top == "omarchy-transfer" || top == ".omarchy-transfer") && type == "l") { bad_("symlink among metadata: " name); next }
  if (top == "wifi") {
    if (type == "l") { bad_("symlink among Wi-Fi data: " name); next }
    if (n >= 2 && c[2] != "networkmanager" && c[2] != "iwd") { bad_("unexpected Wi-Fi member: " name); next }
  }
  names[++cnt] = name
  if (type == "l") links[name] = 1
}
END {
  for (k = 1; k <= cnt; k++) {
    parts = split(names[k], seg, "/")
    p = ""
    for (j = 1; j < parts; j++) {
      p = (j == 1) ? seg[j] : p "/" seg[j]
      if (p in links) { bad_("member below symlink: " names[k]); break }
    }
  }
}
AWK
)

info "Reading $(basename -- "$archive") ($(human "$archive_size"))"

mkfifo "$work/list.fifo"
tar -tvf - --numeric-owner --quoting-style=escape <"$work/list.fifo" >"$work/list.txt" 2>"$work/list.err" &
list_pid=$!

extract=(tar -C "$stage" -xpf - --no-same-owner --xattrs '--xattrs-include=user.*')

# Keep reading after tar stops so the whole stream (and its checksum) is verified.
extract_drain() {
  local rc=0
  "${extract[@]}" 2>"$work/extract.err" || rc=$?
  cat >/dev/null
  return "$rc"
}

set +e
archive_stream | tee "$work/list.fifo" | extract_drain
rcs=("${PIPESTATUS[@]}")
wait "$list_pid"
list_rc=$?
set -e

if (( rcs[0] != 0 )); then
  if [[ $encrypted == true ]]; then
    die "Could not read the archive (wrong passphrase, or it is corrupt or truncated); nothing was changed"
  fi
  die "Could not read the archive (corrupt or truncated); nothing was changed"
fi

: >"$work/bad.txt"
awk -v badf="$work/bad.txt" "$awk_check" "$work/list.txt"
if [[ -s $work/bad.txt ]]; then
  head -n 5 "$work/bad.txt" >&2
  die "Archive contains unsafe or unsupported members; refusing to restore"
fi
if (( rcs[2] != 0 )); then
  head -n 5 "$work/extract.err" >&2
  die "Could not unpack the archive; nothing was changed"
fi
if (( list_rc != 0 )); then
  head -n 5 "$work/list.err" >&2
  die "Not a valid archive; nothing was changed"
fi

# New archives use omarchy-transfer/, older ones .omarchy-transfer/.
metadir=$stage/omarchy-transfer
[[ -d $metadir ]] || metadir=$stage/.omarchy-transfer
meta=$metadir/meta
if [[ ! -f $meta || -L $meta ]]; then
  die "Not an Omarchy transfer archive (metadata is missing)"
fi
meta_get() {
  sed -n "s/^$1=//;T;p;q" "$meta"
}
format=$(meta_get format)
[[ $format == 2 ]] || die "Unsupported archive format: ${format:-unknown} (expected 2)"

# Folders must be writable to be moved; no setuid or setgid bits.
find "$stage" -type d ! -perm -u+rwx -exec chmod u+rwx {} \; 2>/dev/null || true
find "$stage" ! -type l -perm /6000 -exec chmod ug-s {} + 2>/dev/null || true

meta_home=$(meta_get home)
info "Archive from $(meta_get host) ($(meta_get date)), Omarchy $(meta_get omarchy_version)"
if [[ -n $meta_home && $meta_home != "$HOME" ]]; then
  warn "Archive was made in $meta_home, restoring into $HOME: absolute symlinks and configs may still point to the old path"
fi

# ---------------------------------------------------------------- extract only

if [[ -n $extract_only ]]; then
  # shellcheck disable=SC2088
  case $extract_only in
    "~/"*) extract_only=$HOME/${extract_only#"~/"} ;;
  esac
  if [[ $dry_run == true ]]; then
    info "Dry run: would unpack into $extract_only"
    exit 0
  fi
  mkdir -p -- "$extract_only"
  if [[ -n $(find "$extract_only" -mindepth 1 -maxdepth 1 -print -quit) ]]; then
    die "$extract_only is not empty; use an empty folder"
  fi
  find "$stage" -mindepth 1 -maxdepth 1 -exec mv -- {} "$extract_only"/ \; || die "Could not move the files into $extract_only"
  info "Unpacked into $extract_only (home/, omarchy-transfer/, wifi/)"
  exit 0
fi

# ---------------------------------------------------------------- restore files

if [[ $dry_run == true ]]; then
  info "Dry run: nothing will be changed"
fi

epoch=$(date +%s)
park_root=$HOME/omarchy-transfer-configs
n_add=0 n_same=0 n_over=0 n_kept=0 n_blocked=0 n_parked=0
failures=0
conflicts=()
overwritten=()
blocked=()
parked=()
ask_all=""
ASK_RESULT=""
listed=0
list_cap=200

fail() {
  warn "$1"
  failures=$((failures + 1))
}

dry_list() {
  if (( listed < list_cap )); then
    printf '  %-10s %s\n' "$1" "$2"
  elif (( listed == list_cap )); then
    echo "  ... more entries not shown"
  fi
  listed=$((listed + 1))
}

count_files() { # path in stage
  if [[ -d $1 && ! -L $1 ]]; then
    find "$1" ! -type d | wc -l
  else
    echo 1
  fi
}

# Omarchy-specific configs: they would break the shell or desktop elsewhere.
park_prefixes=(hypr omarchy waybar walker mako uwsm swayosd elephant quickshell)
declare -A park_files=()
declare -A park_anc=()

if [[ $parking == true && -d $stage/home ]]; then
  while IFS= read -r -d '' f; do
    rel=${f#"$stage/home/"}
    [[ $rel == .* ]] && park_files[$rel]=1
  done < <(cd "$stage/home" && grep -rlIZ -e '/usr/share/omarchy' -e 'OMARCHY_PATH' -e '.local/share/omarchy' -e 'omarchy-' -- . 2>/dev/null | sed -z 's,^\./,,' || true)
fi

# Folders that hold something to park must be walked, not moved as a whole.
if [[ $parking == true ]]; then
  park_anc[.config]=1
  for rel in "${!park_files[@]}"; do
    d=$rel
    while [[ $d == */* ]]; do
      d=${d%/*}
      park_anc[$d]=1
    done
  done
fi

park_match() {
  local rel=$1 p
  if [[ -n ${park_files[$rel]:-} ]]; then
    return 0
  fi
  for p in "${park_prefixes[@]}"; do
    [[ $rel == ".config/$p" || $rel == ".config/$p/"* ]] && return 0
  done
  return 1
}

do_park() {
  local rel=$1 ty=$2 dest=$park_root/$1
  if [[ $ty == d ]]; then
    [[ $dry_run == true ]] || mkdir -p -- "$dest"
    return 0
  fi
  if [[ -e $dest || -L $dest ]]; then
    if { [[ -L $stage/home/$rel ]] && [[ -L $dest && $(readlink -- "$stage/home/$rel") == "$(readlink -- "$dest")" ]]; } ||
      { [[ ! -L $stage/home/$rel && -f $dest ]] && cmp -s -- "$stage/home/$rel" "$dest"; }; then
      return 0
    fi
  fi
  n_parked=$((n_parked + 1))
  parked+=("$rel")
  if [[ $dry_run == true ]]; then
    dry_list park "$rel"
    return 0
  fi
  mkdir -p -- "${dest%/*}"
  if [[ -e $dest || -L $dest ]]; then
    mv -- "$dest" "$dest.bak.$epoch" || { fail "Could not move aside the parked $rel"; return 0; }
  fi
  mv -- "$stage/home/$rel" "$dest" || fail "Could not park $rel"
}

is_secret() {
  case $1 in
    .ssh | .ssh/* | .gnupg | .gnupg/* | .password-store | .password-store/* | .local/share/keyrings | .local/share/keyrings/*) return 0 ;;
  esac
  return 1
}

show_diff() {
  local rel=$1
  if is_secret "$rel"; then
    echo "  (secret file differs, content hidden)" >&2
  elif [[ -f $HOME/$rel && -f $stage/home/$rel && ! -L $stage/home/$rel ]]; then
    diff -u --label "current/$rel" --label "archive/$rel" -- "$HOME/$rel" "$stage/home/$rel" 2>&1 | head -n 80 >&2 || true
  else
    echo "  (file type differs)" >&2
  fi
}

ask_decide() {
  local rel=$1 ans
  if [[ -n $ask_all ]]; then
    ASK_RESULT=$ask_all
    return 0
  fi
  show_diff "$rel"
  while true; do
    printf '%s: [o]verwrite (keeps .bak) / [s]kip / [A]ll overwrite / [N]one? ' "$rel" >&2
    IFS= read -r -n1 ans </dev/tty || die "Cannot read an answer from the terminal"
    echo >&2
    case $ans in
      o) ASK_RESULT=overwrite; return 0 ;;
      s) ASK_RESULT=skip; return 0 ;;
      A) ask_all=overwrite; ASK_RESULT=overwrite; return 0 ;;
      N) ask_all=skip; ASK_RESULT=skip; return 0 ;;
    esac
  done
}

do_overwrite() {
  local rel=$1 bak=$HOME/$1.bak.$epoch n=0
  while [[ -e $bak || -L $bak ]]; do
    n=$((n + 1))
    bak=$HOME/$rel.bak.$epoch.$n
  done
  if ! mv -- "$HOME/$rel" "$bak"; then
    fail "Could not back up $rel"
    return 0
  fi
  if mv -- "$stage/home/$rel" "$HOME/$rel"; then
    overwritten+=("$rel")
    n_over=$((n_over + 1))
  else
    mv -- "$bak" "$HOME/$rel" || true
    fail "Could not replace $rel"
  fi
}

write_transfer() {
  local rel=$1
  if mv -f -- "$stage/home/$rel" "$HOME/$rel.transfer"; then
    conflicts+=("$rel")
  else
    fail "Could not write $rel.transfer"
  fi
}

handle_differs() {
  local rel=$1 decision=conflict
  case $mode in
    skip) n_kept=$((n_kept + 1)); return 0 ;;
    overwrite) decision=overwrite ;;
    ask)
      ask_decide "$rel"
      decision=$ASK_RESULT
      ;;
  esac
  case $decision in
    overwrite) do_overwrite "$rel" ;;
    skip) n_kept=$((n_kept + 1)) ;;
    *) write_transfer "$rel" ;;
  esac
}

same_as_home() { # rel
  local s=$stage/home/$1 h=$HOME/$1
  if [[ -L $s ]]; then
    [[ -L $h && $(readlink -- "$s") == "$(readlink -- "$h")" ]]
  else
    [[ -f $h ]] && cmp -s -- "$s" "$h"
  fi
}

if [[ $mode == ask && $dry_run == false ]] && ! has_tty; then
  die "Mode 'ask' needs a terminal; use --mode=keep, overwrite or skip"
fi

restore_files() {
  local ty rel skip="" h n
  [[ -d $stage/home ]] || return 0
  # Pre-order: a folder always comes before what is inside it.
  while IFS= read -r -d '' ty && IFS= read -r -d '' rel; do
    if [[ -n $skip && ( $rel == "$skip" || $rel == "$skip"/* ) ]]; then
      continue
    fi
    skip=""
    h=$HOME/$rel

    if [[ $parking == true ]] && park_match "$rel"; then
      do_park "$rel" "$ty"
      continue
    fi

    if [[ ! -e $h && ! -L $h ]]; then
      if [[ $ty == d && -n ${park_anc[$rel]:-} ]]; then
        if [[ $dry_run == true ]]; then
          dry_list add "$rel/"
        else
          if mkdir -p -- "$h"; then
            chmod --reference="$stage/home/$rel" -- "$h" || true
          else
            fail "Could not create $rel"
          fi
        fi
        continue
      fi
      if [[ $ty == d ]]; then
        n=$(count_files "$stage/home/$rel")
        n_add=$((n_add + n))
        skip=$rel
      else
        n_add=$((n_add + 1))
      fi
      if [[ $dry_run == true ]]; then
        dry_list add "$rel$([[ $ty == d ]] && echo /)"
      elif ! mv -- "$stage/home/$rel" "$h"; then
        fail "Could not install $rel"
      fi
      continue
    fi

    if [[ $ty == d ]]; then
      if [[ ! -d $h ]]; then
        n_blocked=$((n_blocked + 1))
        blocked+=("$rel")
        skip=$rel
        warn "Skipping $rel: a file is in the way of a folder"
      fi
      continue
    fi

    if [[ -d $h ]]; then
      n_blocked=$((n_blocked + 1))
      blocked+=("$rel")
      warn "Skipping $rel: a folder is in the way of a file"
      continue
    fi

    if same_as_home "$rel"; then
      n_same=$((n_same + 1))
      continue
    fi

    if [[ $dry_run == true ]]; then
      dry_list differs "$rel"
      case $mode in
        skip) n_kept=$((n_kept + 1)) ;;
        overwrite) n_over=$((n_over + 1)) ;;
        *) conflicts+=("$rel") ;;
      esac
    else
      handle_differs "$rel"
    fi
  done < <(find "$stage/home" -mindepth 1 -printf '%y\0%P\0')
}

info "Comparing files"
restore_files

# ---------------------------------------------------------------- packages

missing_pkgs=()
failed_pkgs=()
pkg_note=""

clean_names() {
  [[ -f $1 && ! -L $1 ]] || return 0
  { grep -E '^[A-Za-z0-9@._+][A-Za-z0-9@._+-]*$' "$1" | grep -Ev -- '-debug$' | sort -u; } || true
}

lines() {
  if (( $# > 0 )); then
    printf '%s\n' "$@"
  fi
}

pk_official() { sudo pacman -S --needed "$@"; }
pk_aur() { "$aur_helper" -S --needed "$@"; }

install_pkgs() {
  local fn=$1 half
  shift
  (( $# > 0 )) || return 0
  if "$fn" "$@"; then
    return 0
  fi
  if (( $# == 1 )); then
    failed_pkgs+=("$1")
    return 0
  fi
  half=$(( $# / 2 ))
  install_pkgs "$fn" "${@:1:half}"
  install_pkgs "$fn" "${@:half+1}"
}

restore_packages_arch() {
  local official=$metadir/packages-official.txt aur=$metadir/packages-aur.txt
  local installed avail aur_helper=""
  local -a want missing todo unknown

  installed=$(pacman -Qq 2>/dev/null | sort -u || true)

  mapfile -t want < <(clean_names "$official")
  if (( ${#want[@]} > 0 )); then
    mapfile -t missing < <(comm -23 <(lines "${want[@]}") <(printf '%s\n' "$installed"))
    if (( ${#missing[@]} == 0 )); then
      info "All official packages are already installed"
    elif avail=$(pacman -Slq 2>/dev/null | sort -u) && [[ -n $avail ]]; then
      mapfile -t todo < <(comm -12 <(lines "${missing[@]}") <(printf '%s\n' "$avail"))
      mapfile -t unknown < <(comm -23 <(lines "${missing[@]}") <(printf '%s\n' "$avail"))
      if (( ${#unknown[@]} > 0 )); then
        missing_pkgs+=("${unknown[@]}")
        warn "Not in the repositories of this system, skipped (${#unknown[@]}): ${unknown[*]}"
      fi
      if (( ${#todo[@]} > 0 )); then
        if [[ $dry_run == true ]]; then
          info "Would install ${#todo[@]} official packages: ${todo[*]}"
        else
          info "Installing ${#todo[@]} official packages"
          install_pkgs pk_official "${todo[@]}"
        fi
      fi
    else
      warn "Cannot read the package databases; official packages were not installed"
      failed_pkgs+=("${missing[@]}")
    fi
  fi

  mapfile -t want < <(clean_names "$aur")
  if (( ${#want[@]} > 0 )); then
    installed=$(pacman -Qq 2>/dev/null | sort -u || true)
    mapfile -t missing < <(comm -23 <(lines "${want[@]}") <(printf '%s\n' "$installed"))
    if (( ${#missing[@]} == 0 )); then
      info "All AUR packages are already installed"
    else
      if have yay; then aur_helper=yay; elif have paru; then aur_helper=paru; fi
      if [[ -z $aur_helper ]]; then
        warn "Neither yay nor paru is installed; AUR packages are only listed: ${missing[*]}"
        missing_pkgs+=("${missing[@]}")
      elif [[ $dry_run == true ]]; then
        info "Would install ${#missing[@]} AUR packages with $aur_helper: ${missing[*]}"
      else
        info "Installing ${#missing[@]} AUR packages with $aur_helper"
        install_pkgs pk_aur "${missing[@]}"
      fi
    fi
  fi
}

write_package_list() {
  local out=$HOME/omarchy-transfer-packages.txt
  local official=$metadir/packages-official.txt aur=$metadir/packages-aur.txt
  if [[ $dry_run == true ]]; then
    info "Would write the package list to $out"
    return 0
  fi
  {
    echo "# Packages of the old Omarchy (Arch Linux) system."
    echo "# They were not installed: this is not an Arch-based system."
    echo "# Names are Arch names and may differ on your distribution."
    echo
    echo "## Official repositories"
    clean_names "$official"
    echo
    echo "## AUR (Arch User Repository)"
    clean_names "$aur"
  } >"$out"
  pkg_note="Package list written to $out (this is not an Arch-based system)"
}

restore_packages() {
  [[ $no_packages == false ]] || return 0
  [[ -s $metadir/packages-official.txt || -s $metadir/packages-aur.txt ]] || return 0
  if have pacman; then
    restore_packages_arch
  else
    write_package_list
  fi
}

restore_packages

# ---------------------------------------------------------------- Wi-Fi

wifi_restored=0
wifi_note=""

wifi_backend() {
  have systemctl || { echo none; return 0; }
  if systemctl is-active --quiet NetworkManager 2>/dev/null; then
    echo networkmanager
  elif systemctl is-active --quiet iwd 2>/dev/null; then
    echo iwd
  else
    echo none
  fi
}

wifi_count() { # backend (or empty for any)
  find "$stage/wifi/${1:-}" -type f 2>/dev/null | wc -l || true
}

wifi_fallback() {
  local out=$HOME/omarchy-transfer-wifi
  if [[ $dry_run == true ]]; then
    info "Would copy the Wi-Fi files to $out"
    return 0
  fi
  mkdir -p -- "$out"
  chmod 700 "$out"
  if cp -a -- "$stage/wifi/." "$out/"; then
    chmod -R go-rwx "$out"
    wifi_note="Wi-Fi files saved in $out (0700); copy them to your network manager's folder by hand"
    warn "$wifi_note"
  else
    fail "Could not save the Wi-Fi files to $out"
  fi
}

restore_wifi_networks() {
  local backend dest src f rel total
  total=$(wifi_count "")
  if (( total == 0 )); then
    if [[ $want_wifi == true ]]; then
      warn "--wifi given but the archive contains no Wi-Fi data (it needs wifi=yes and encryption at export)"
    fi
    return 0
  fi
  if [[ $want_wifi == false ]]; then
    info "The archive contains Wi-Fi networks; run again with --wifi to restore them"
    return 0
  fi

  backend=$(wifi_backend)
  case $backend in
    networkmanager) dest=${OMARCHY_TRANSFER_NM_DIR:-/etc/NetworkManager/system-connections} ;;
    iwd) dest=${OMARCHY_TRANSFER_IWD_DIR:-/var/lib/iwd} ;;
    *)
      warn "No running NetworkManager or iwd found"
      wifi_fallback
      return 0
      ;;
  esac
  src=$stage/wifi/$backend
  if (( $(wifi_count "$backend") == 0 )); then
    warn "The archive has no Wi-Fi data for $backend (this system uses $backend)"
    wifi_fallback
    return 0
  fi
  if [[ $dry_run == true ]]; then
    info "Would restore $(wifi_count "$backend") Wi-Fi files into $dest"
    return 0
  fi

  info "Restoring Wi-Fi networks into $dest"
  if ! sudo mkdir -p -- "$dest"; then
    fail "Could not create $dest"
    return 0
  fi
  while IFS= read -r -d '' f; do
    rel=${f#"$src/"}
    if [[ $rel == */* ]] && ! sudo mkdir -p -- "$dest/${rel%/*}"; then
      fail "Could not create $dest/${rel%/*}"
      continue
    fi
    if sudo install -m 600 -- "$f" "$dest/$rel"; then
      wifi_restored=$((wifi_restored + 1))
    else
      fail "Could not restore Wi-Fi file $rel"
    fi
  done < <(find "$src" -type f -print0)

  case $backend in
    networkmanager) sudo nmcli connection reload || warn "Could not reload NetworkManager connections" ;;
    iwd) sudo systemctl restart iwd || warn "Could not restart iwd" ;;
  esac
}

restore_wifi_networks

# ---------------------------------------------------------------- summary

if (( ${#failed_pkgs[@]} > 0 )); then
  fail "Packages not installed (${#failed_pkgs[@]}): ${failed_pkgs[*]}"
fi

echo
if [[ $dry_run == true ]]; then
  info "Dry run finished, nothing was changed"
  echo "  would add:    $n_add"
  echo "  unchanged:    $n_same"
  echo "  differing:    ${#conflicts[@]} (mode $mode)"
  echo "  blocked:      $n_blocked"
  echo "  parked:       $n_parked"
else
  info "Summary"
  echo "  added:        $n_add"
  echo "  kept:         ${#conflicts[@]} (archive version saved as <name>.transfer)"
  echo "  overwritten:  $n_over (originals saved as <name>.bak.$epoch)"
  echo "  skipped:      $n_kept (mode skip or your choice)"
  echo "  unchanged:    $n_same"
  echo "  parked:       $n_parked (in $park_root)"
  echo "  blocked:      $n_blocked"
  if (( wifi_restored > 0 )); then
    echo "  wi-fi files:  $wifi_restored"
  fi
  echo "  missing pkgs: ${#missing_pkgs[@]}"
  echo "  failed:       $failures"
  if (( ${#conflicts[@]} > 0 )); then
    echo
    echo "Your current version was kept; the archive version sits next to it as <name>.transfer:"
    printf '  %s\n' "${conflicts[@]}"
  fi
  if (( ${#parked[@]} > 0 )); then
    echo
    echo "Parked in $park_root, not activated: these Omarchy configs would break your"
    echo "shell or desktop on a system without Omarchy. Copy over what you need:"
    printf '  %s\n' "${parked[@]}"
  fi
  if (( n_blocked > 0 )); then
    echo
    echo "Skipped because something of another type is in the way:"
    printf '  %s\n' "${blocked[@]}"
  fi
  if (( ${#missing_pkgs[@]} > 0 )); then
    echo
    echo "Packages not available here (install them by hand if you need them):"
    printf '  %s\n' "${missing_pkgs[@]}"
  fi
  [[ -z $pkg_note ]] || { echo; echo "$pkg_note"; }
  [[ -z $wifi_note ]] || { echo; echo "$wifi_note"; }
fi

if (( failures > 0 )); then
  exit 1
fi
