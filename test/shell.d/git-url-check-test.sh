#!/bin/bash

set -euo pipefail

# omarchy-git-url-check decides which URLs omarchy-theme-install and
# omarchy-plugin-add are willing to hand to `git clone`. git resolves a remote
# helper -- a program it runs at clone time -- from exactly two URL shapes,
# `<helper>::<address>` and `<scheme>://<address>`, so those are the two shapes
# asserted here, alongside every legitimate form a user is likely to paste.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/locale-test.sh"

check() {
  "$ROOT/bin/omarchy-git-url-check" "$@" 2>&1
}

# `<helper>::<address>`, the shape that runs a program. `ext::` is the dangerous
# one: git runs the rest as a shell command once protocol.ext.allow permits it.
for url in "ext::sh -c id" "fd::0,1" "gcrypt::x" "a+b::x" "a.b::x" "a-b::x" "1::x"; do
  output=$(check "$url") &&
    fail "omarchy-git-url-check refuses the transport helper '$url'" "$output"
  grep -qF "names a git option or transport helper" <<<"$output" ||
    fail "omarchy-git-url-check names the helper rejection for '$url'" "$output"
done

pass "a <helper>::<address> URL is refused"

# `<scheme>://<address>`, the shape #8067 left open: git looks up
# git-remote-<scheme> for any scheme it does not implement itself, so an
# allowlist is the only form of this check that holds.
for url in "ext://sh -c id" "fd://17" "gcrypt://example.com/x" "zzz://a" "ZZZ://a" "HTTPS://github.com/a/b"; do
  output=$(check "$url") &&
    fail "omarchy-git-url-check refuses the '$url' transport" "$output"
  grep -qF "which Omarchy does not clone from" <<<"$output" ||
    fail "omarchy-git-url-check names the transport rejection for '$url'" "$output"
done

pass "a <scheme>://<address> URL outside git's own transports is refused"

# A leading dash is an option to git, not a URL.
for url in "-x" "--upload-pack=touch /tmp/pwned" "-oProxyCommand=x"; do
  output=$(check "$url") &&
    fail "omarchy-git-url-check refuses the option '$url'" "$output"
done

pass "a URL shaped like a git option is refused"

output=$(check "") && fail "omarchy-git-url-check refuses an empty URL" "$output"
output=$(check) && fail "omarchy-git-url-check refuses a missing URL" "$output"

pass "an empty URL is refused"

# Everything a user actually pastes. The scp-style forms carry a single colon,
# which git never reads as a helper, and the IPv6 host carries `::` inside
# brackets rather than at the start.
for url in \
  "https://github.com/acme/omarchy-weather.git" \
  "http://example.com/a/b.git" \
  "https://user:token@github.com/acme/repo.git" \
  "ssh://git@github.com/acme/repo.git" \
  "ssh://git@[2001:db8::1]:22/org/repo.git" \
  "git://example.com/repo.git" \
  "git+ssh://git@example.com/acme/repo.git" \
  "ssh+git://git@example.com/acme/repo.git" \
  "ftp://example.com/repo.git" \
  "ftps://example.com/repo.git" \
  "file:///home/me/repo" \
  "git@github.com:acme/repo.git" \
  "git@[2001:db8::1]:org/repo.git" \
  "host:-s/foo.git" \
  "/home/me/repo" \
  "./repo" \
  "../repo" \
  "repo"; do
  output=$(check "$url") ||
    fail "omarchy-git-url-check accepts the legitimate URL '$url'" "$output"
done

pass "the URL forms a user pastes are accepted"

# The two shapes are read with POSIX classes, not bracket ranges, because a range
# follows the locale's collation: under tr_TR.UTF-8 an unpinned `[A-Za-z0-9]`
# misses `i` and `I`, so a scheme or helper spelled with one matched neither
# shape and passed as a path, the transport allowlist never consulted.
locales=$(mktemp -d)
trap 'rm -rf "$locales"' EXIT
if turkish_locale "$locales"; then
  for url in "zzi://a" "hi::x"; do
    output=$(in_turkish check "$url") &&
      fail "omarchy-git-url-check refuses '$url' under tr_TR.UTF-8" "$output"
  done
  for url in "git://example.com/repo.git" "file:///home/me/repo"; do
    output=$(in_turkish check "$url") ||
      fail "omarchy-git-url-check accepts '$url' under tr_TR.UTF-8" "$output"
  done
  pass "the URL shapes are read the same under tr_TR.UTF-8"
else
  skip "no tr_TR.UTF-8 locale that misses i in [a-z] can be built here; skipping the locale-pinning check"
fi
