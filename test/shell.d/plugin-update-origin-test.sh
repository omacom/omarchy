#!/bin/bash

set -euo pipefail

# An installed plugin keeps its fetch URL in .git/config. Tightening only the
# add path would leave existing plaintext origins able to bypass the policy on
# the next update, before their QML is reloaded into the shell.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
plugin="$home/.config/omarchy/plugins/acme.transport"
mock_bin="$test_tmp/bin"
fetch_marker="$test_tmp/fetch-reached"
mkdir -p "$plugin" "$mock_bin"

real_git=$(command -v git)
"$real_git" -C "$plugin" init -q
"$real_git" -C "$plugin" remote add origin https://example.com/acme/plugin.git

cat >"$mock_bin/git" <<'SH'
#!/bin/bash
for arg in "$@"; do
  if [[ $arg == "fetch" ]]; then
    touch "$OMARCHY_TEST_FETCH_MARKER"
    exit 70
  fi
done
exec "$OMARCHY_TEST_REAL_GIT" "$@"
SH

cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$mock_bin"/*

update_plugin() {
  HOME="$home" PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_FETCH_MARKER="$fetch_marker" OMARCHY_TEST_REAL_GIT="$real_git" \
    bash "$ROOT/bin/omarchy-plugin-update" acme.transport --yes >"$test_tmp/out" 2>&1
}

for url in \
  "git://example.com/acme/plugin.git" \
  "http://example.com/acme/plugin.git" \
  "ftp://example.com/acme/plugin.git"; do
  "$real_git" -C "$plugin" remote set-url origin "$url"
  rm -f "$fetch_marker"

  if update_plugin; then
    fail "plugin update refuses the stored unauthenticated origin '$url'"
  fi
  [[ ! -e $fetch_marker ]] ||
    fail "plugin update refuses '$url' before git fetch"
  grep -qF "remote set-url origin URL" "$test_tmp/out" ||
    fail "plugin update gives an origin migration command for '$url'" "$(cat "$test_tmp/out")"
done

pass "plugin update blocks every stored unauthenticated network origin before fetch"

for url in \
  "https://example.com/acme/plugin.git" \
  "ssh://git@example.com/acme/plugin.git" \
  "git+ssh://git@example.com/acme/plugin.git" \
  "ssh+git://git@example.com/acme/plugin.git" \
  "ftps://example.com/acme/plugin.git" \
  "file://$test_tmp/plugin.git" \
  "git@example.com:acme/plugin.git" \
  "$test_tmp/plugin.git"; do
  "$real_git" -C "$plugin" remote set-url origin "$url"
  rm -f "$fetch_marker"

  update_plugin && fail "the fetch stub makes the update fail after accepting '$url'"
  [[ -e $fetch_marker ]] ||
    fail "plugin update lets the authenticated or local origin reach fetch: $url" "$(cat "$test_tmp/out")"
done

pass "plugin update preserves authenticated network and local origins"

# git expands url.*.insteadOf before reporting the effective fetch URL. A
# secure-looking alias must not smuggle a plaintext target past the stored
# origin check.
"$real_git" -C "$plugin" remote set-url origin shorthand:acme/plugin.git
"$real_git" config --file "$home/.gitconfig" url.git://example.com/.insteadOf shorthand:
rm -f "$fetch_marker"

if update_plugin; then
  fail "plugin update refuses an origin rewritten to an unauthenticated URL"
fi
[[ ! -e $fetch_marker ]] ||
  fail "plugin update checks the expanded origin before fetch"

pass "plugin update checks the effective URL after Git origin rewriting"
