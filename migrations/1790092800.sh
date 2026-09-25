echo "Remove leftover world-readable diagnostics files from /tmp"

# omarchy-debug and omarchy-upload-log used to write these under /tmp, where the
# default umask leaves them mode 0644. The scripts now stage with mktemp. Drop
# leftovers this user still owns.
#
# Only regular files, and never through a symlink. -f and -O both follow one, so
# a link at the name would otherwise be removed in place of a leftover.
# Overridable for tests.

tmp_root=${OMARCHY_LEGACY_DIAGNOSTICS_TMP:-/tmp}

remove_owned_legacy() {
  local path=$1

  [[ -L $path ]] && return 0
  [[ -f $path ]] || return 0
  [[ -O $path ]] || return 0
  rm -f -- "$path"
}

remove_owned_legacy "$tmp_root/omarchy-debug.log"
remove_owned_legacy "$tmp_root/upload-log.txt"
remove_owned_legacy "$tmp_root/system-info.txt"
