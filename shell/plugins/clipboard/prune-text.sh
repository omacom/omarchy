#!/bin/bash

# Deletes large-copy files clipboard history no longer uses.
#
#   prune-text.sh <text-dir> <history-path> [name ...]
#
# Only regular files directly in <text-dir> named <sha256>.txt are candidates,
# and only once they are a minute old: capture writes a file just before the
# overlay adds its entry. The names to keep come from the overlay's own history;
# no path read from a history file is ever deleted. While a rejected history sits
# next to <history-path>, nothing is deleted, since it may still use these files.

set -o pipefail

dir=${1:?usage: prune-text.sh <text-dir> <history-path> [name ...]}
history=${2:?usage: prune-text.sh <text-dir> <history-path> [name ...]}
shift 2

[[ -d $dir && ! -L $dir ]] || exit 0
compgen -G "$history.rejected-*" >/dev/null && exit 0

declare -A keep=()
for name in "$@"; do keep[$name]=1; done

while IFS= read -r -d '' file; do
  [[ -n ${keep[${file##*/}]:-} ]] || rm -f -- "$file"
done < <(find "$dir" -maxdepth 1 -type f -mmin +1 -regextype posix-extended -regex '.*/[0-9a-f]{64}\.txt' -print0)

# Temp files left by a capture that died between writing and renaming.
find "$dir" -maxdepth 1 -type f -name 'clipboard.*' -mmin +60 -delete
