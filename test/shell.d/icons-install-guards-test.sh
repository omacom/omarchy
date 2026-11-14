#!/bin/bash

set -euo pipefail

# omarchy-icons-install feeds a pasted URL to git and a name derived from it to
# rm, as omarchy-theme-install does, and shares its guards. They are exercised
# here with git stubbed, so a guard that stopped working shows up as a clone
# that should never have been reached.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/git" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_GIT_CALLS"
[[ $1 == "clone" ]] && mkdir -p "${*: -1}"
exit 0
SH

cat >"$mock_bin/gum" <<'SH'
#!/bin/bash
exit 1
SH

printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"$OMARCHY_TEST_SET_CALLS"\nexit 0\n' >"$mock_bin/omarchy-icons-set"
chmod +x "$mock_bin"/*

git_calls="$test_tmp/git-calls"
set_calls="$test_tmp/set-calls"

install_icons() {
  : >"$git_calls"
  : >"$set_calls"

  HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_GIT_CALLS="$git_calls" OMARCHY_TEST_SET_CALLS="$set_calls" \
    bash "$ROOT/bin/omarchy-icons-install" "$1" >"$test_tmp/out" 2>&1 || return $?
}

for url in "-x" "--upload-pack=touch /tmp/pwned" "ext::sh -c id" "ext://sh -c id"; do
  if install_icons "$url"; then
    fail "omarchy-icons-install refuses the URL '$url'"
  fi

  [[ ! -s $git_calls ]] || fail "omarchy-icons-install refuses '$url' before running git" "$(cat "$git_calls")"
done

pass "a URL that names a git option or a transport helper never reaches git"

# The derived name is joined into the path that is removed before the clone,
# and Original always means no icon set at all.
for url in \
  "https://example.com/..git" \
  "https://example.com/.git" \
  "https://example.com/omarchy-a';id;'b-icons.git" \
  'https://example.com/a$(id).git' \
  "https://example.com/a b.git" \
  "https://example.com/-a.git" \
  "https://example.com/omarchy-original-icons.git"; do
  if install_icons "$url"; then
    fail "omarchy-icons-install refuses the derived name from '$url'"
  fi

  [[ ! -s $git_calls ]] || fail "omarchy-icons-install refuses '$url' before running git" "$(cat "$git_calls")"
done

pass "a URL whose name would climb out, be shell syntax or shadow Original never reaches git"

install_icons "https://github.com/example/omarchy-cool-icons.git" || fail "omarchy-icons-install clones a normal URL"
grep -Fq -- "-- https://github.com/example/omarchy-cool-icons.git" "$git_calls" || fail "omarchy-icons-install passes the URL after --" "$(cat "$git_calls")"
grep -Fq "/.config/omarchy/icons/cool" "$git_calls" || fail "omarchy-icons-install derives the icon set name" "$(cat "$git_calls")"
grep -Fxq "cool" "$set_calls" || fail "omarchy-icons-install applies the icon set it installed" "$(cat "$set_calls")"

install_icons "git@example.com:omarchy-blue-icons.git" || fail "omarchy-icons-install accepts a home-relative scp-style URL"
grep -Fq "/icons/blue" "$git_calls" || fail "omarchy-icons-install names the set after the repo, not the whole URL" "$(cat "$git_calls")"

pass "an ordinary icon set URL still clones and applies"
