#!/bin/bash

# A private tr_TR.UTF-8 for the tests of commands that validate an ASCII name
# with a bracket range. A range follows the locale's collation, and under this
# one an unpinned `[a-z]` misses `i` and `I`, so a comparison pinned to
# C is told apart from one that is not. The locale is built into the caller's
# scratch directory: no root, no change to the host, nothing that outlives the
# test. turkish_locale returns 1 where it can't be built, or where this glibc
# matches ASCII under it anyway, and the caller skips its case; in_turkish
# then runs a command under it.
turkish_locale() {
  TURKISH_LOCPATH=$1
  command -v localedef >/dev/null || return 1
  mkdir -p "$TURKISH_LOCPATH"
  [[ -d $TURKISH_LOCPATH/tr_TR.UTF-8 ]] ||
    localedef -i tr_TR -f UTF-8 "$TURKISH_LOCPATH/tr_TR.UTF-8" 2>/dev/null || return 1
  ! LOCPATH=$TURKISH_LOCPATH LC_ALL=tr_TR.UTF-8 bash -c '[[ it =~ ^[a-z]+$ ]]'
}

# A subshell, so the exports reach only the command. bash looks a new LC_ALL
# up for itself as well, through the environment it started with, where this
# LOCPATH isn't, and warns; the shell's own locale is beside the point here,
# so that warning is dropped.
in_turkish() (
  export LOCPATH=$TURKISH_LOCPATH
  { export LC_ALL=tr_TR.UTF-8; } 2>/dev/null
  "$@"
)
