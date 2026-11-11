#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-user-helper (behind a child's NOPASSWD grant) and omarchy-login-match
# (run by pam_exec as root) start as `bash -p`, so nothing in the caller's
# environment runs before their first command. An ordinary Bash launch must be
# refused before either reaches its library, even with a decoy -p argument.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

for entrypoint in omarchy-user-helper omarchy-login-match; do
  dir=$tmp/$entrypoint
  mkdir -p "$dir"
  cp "$ROOT/bin/$entrypoint" "$ROOT/bin/omarchy-security-functions" "$dir/"
  printf 'touch "%s/reached"\nreturn 0\n' "$dir" >"$dir/omarchy-user-functions"

  "$dir/$entrypoint" </dev/null >/dev/null 2>&1 || true
  [[ -e $dir/reached ]] || fail "$entrypoint started as bash -p reaches its library"
  rm -f "$dir/reached"

  for arguments in "-p" "-p list" ""; do
    # shellcheck disable=SC2086
    if /usr/bin/bash "$dir/$entrypoint" $arguments </dev/null >/dev/null 2>&1; then
      fail "an ordinary Bash launch of $entrypoint is refused" "arguments: $arguments"
    fi
    [[ ! -e $dir/reached ]] || fail "an ordinary Bash launch of $entrypoint stops before its library" "arguments: $arguments"
  done
  pass "$entrypoint refuses an ordinary Bash launch, decoy -p and all, before reaching its library"
done
