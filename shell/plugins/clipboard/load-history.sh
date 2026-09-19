#!/bin/bash

# Hands clipboard history to the overlay without ever reading more than a fixed
# number of bytes, following a symlink, or blocking on a special file.
#
#   load-history.sh <path> <max-bytes>
#
# Prints the history and exits 0; an absent file prints []. A file the overlay
# could not have written itself -- a symlink, a FIFO or other non-regular file,
# anything over the ceiling, invalid JSON, or JSON that is not an array -- is
# renamed to <path>.rejected-<time> and prints [], so its bytes stay with the
# user and are never saved over. Exit 3 means history exists but could not be
# read or renamed: the overlay must not write over it.

set -o pipefail

path=${1:?usage: load-history.sh <path> <max-bytes>}
ceiling=${2:?usage: load-history.sh <path> <max-bytes>}

tmp=$(mktemp) || exit 3
trap 'rm -f "$tmp"' EXIT

reject() {
  mv -- "$path" "$path.rejected-$(date +%Y%m%d-%H%M%S-%N)" || exit 3
  printf '[]'
  exit 0
}

if [[ ! -e $path && ! -L $path ]]; then
  printf '[]'
  exit 0
fi

[[ -L $path || ! -f $path ]] && reject

size=$(stat -c %s -- "$path") || exit 3
(( size <= ceiling )) || reject
[[ -r $path ]] || exit 3

# Bounded and time-limited even if the path is swapped between the checks and here.
timeout 5 head -c $((ceiling + 1)) -- "$path" >"$tmp" || exit 3
(( $(stat -c %s -- "$tmp") <= ceiling )) || reject
jq -e 'type == "array"' "$tmp" >/dev/null 2>&1 || reject

cat -- "$tmp"
