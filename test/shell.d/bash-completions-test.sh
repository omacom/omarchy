#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$ROOT/default/bash/completions"
export PATH="$ROOT/bin:$PATH"

shopt -s nullglob
COMP_WORDS=(omarchy th)
COMP_CWORD=1
_omarchy_complete
(( ${#COMPREPLY[@]} > 0 )) || fail "_omarchy_complete exercised completion candidates"
shopt -q nullglob || fail "_omarchy_complete preserves enabled nullglob"
pass "_omarchy_complete preserves enabled nullglob"

shopt -u nullglob
COMP_WORDS=(omarchy th)
COMP_CWORD=1
_omarchy_complete
(( ${#COMPREPLY[@]} > 0 )) || fail "_omarchy_complete exercised completion candidates"
! shopt -q nullglob || fail "_omarchy_complete keeps disabled nullglob unset"
pass "_omarchy_complete keeps disabled nullglob unset"
