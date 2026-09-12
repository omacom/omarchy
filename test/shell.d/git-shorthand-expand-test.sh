#!/bin/bash

set -euo pipefail

# omarchy-git-shorthand-expand lets omarchy-plugin-add and omarchy-theme-install
# take a bare GitHub `owner/repo` instead of a full clone URL. It only ever
# expands that one shape; anything already url-shaped (scheme://, scp-style
# user@host:path) or not owner/repo-shaped at all (a bare word, a local path, a
# second slash) must come back unchanged so the existing git-url-check /
# git-clone path keeps handling it exactly as it does today.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

expand() {
  "$ROOT/bin/omarchy-git-shorthand-expand" "$@"
}

# The one shape this command exists to handle.
for pair in \
  "acme/omarchy-weather:https://github.com/acme/omarchy-weather.git" \
  "some-org/some.repo_name:https://github.com/some-org/some.repo_name.git" \
  "a/b:https://github.com/a/b.git" \
  "under-score/dot.repo_name:https://github.com/under-score/dot.repo_name.git"; do
  shorthand="${pair%%:*}"
  expected="${pair#*:}"
  output=$(expand "$shorthand") || fail "omarchy-git-shorthand-expand expands '$shorthand'" "$output"
  [[ $output == "$expected" ]] ||
    fail "omarchy-git-shorthand-expand expands '$shorthand' to the right URL" "got: $output"
done

pass "a bare owner/repo expands to its GitHub clone URL"

# Already url-shaped: every one of these has to pass through byte-for-byte, the
# same set omarchy-git-url-check and the theme/plugin install tests already
# treat as legitimate.
for url in \
  "https://github.com/acme/omarchy-weather.git" \
  "http://example.com/a/b.git" \
  "ssh://git@github.com/acme/repo.git" \
  "git@github.com:acme/repo.git" \
  "git@[2001:db8::1]:org/repo.git" \
  "host:-s/foo.git" \
  "/srv/git:mirrors/omarchy-blue-theme.git" \
  "file:///home/me/repo"; do
  output=$(expand "$url") || fail "omarchy-git-shorthand-expand accepts '$url'" "$output"
  [[ $output == "$url" ]] ||
    fail "omarchy-git-shorthand-expand leaves an already-url-shaped argument untouched: $url" "got: $output"
done

pass "a URL, scp-style or otherwise, passes through unchanged"

# Not owner/repo-shaped at all: a bare word, a local path, two slashes, an
# empty repo, or a leading dash where an owner belongs. None of these should be
# rewritten -- they fall through to git-url-check / git clone exactly as they
# do today, dash included, so the existing option-shaped-URL guard still sees
# a leading dash it needs to refuse.
for arg in "repo" "/home/me/repo" "./repo" "../repo" "owner/repo/extra" "owner/" "-owner/repo"; do
  output=$(expand "$arg") || fail "omarchy-git-shorthand-expand accepts '$arg'" "$output"
  [[ $output == "$arg" ]] ||
    fail "omarchy-git-shorthand-expand leaves a non-shorthand argument untouched: $arg" "got: $output"
done

pass "anything that is not owner/repo-shaped passes through unchanged"

output=$(expand "") && fail "omarchy-git-shorthand-expand refuses an empty argument" "$output"
output=$(expand) && fail "omarchy-git-shorthand-expand refuses a missing argument" "$output"

pass "an empty or missing argument is refused"

# The owner/repo match is a bracket range, and a range follows the locale's
# collation rather than ASCII -- see the same concern in
# theme-install-guards-test.sh. Under en_US.UTF-8 an unpinned range takes in
# non-ASCII letters, which would make a café-named path expand into a GitHub
# URL that never existed.
if locale -a 2>/dev/null | grep -qix 'en_US.utf-\?8'; then
  for locale_name in C en_US.UTF-8; do
    output=$(LC_ALL=$locale_name expand "café/repo") ||
      fail "omarchy-git-shorthand-expand accepts 'café/repo' under LC_ALL=$locale_name" "$output"
    [[ $output == "café/repo" ]] ||
      fail "omarchy-git-shorthand-expand does not expand a non-ASCII path under LC_ALL=$locale_name" "got: $output"
  done

  pass "the owner/repo match does not move with the desktop's locale"
else
  pass "no en_US.UTF-8 locale; skipping the locale-pinning check"
fi
