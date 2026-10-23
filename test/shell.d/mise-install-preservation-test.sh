#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home"
mkdir -p "$HOME/.local/bin"
launcher="$HOME/.local/bin/tool"
printf '#!/bin/bash\nexport MY_TOKEN=private\nexec custom-tool "$@"\n' >"$launcher"
chmod 700 "$launcher"
cp -p "$launcher" "$test_tmp/original"

"$ROOT/bin/omarchy-mise-install" tool 2>"$test_tmp/notice"
cmp -s "$launcher" "$test_tmp/original" || fail "custom launcher stays active"
[[ $(stat -c %a "$launcher") == "700" ]] || fail "custom launcher keeps private permissions"
grep -Fq 'Keeping existing launcher' "$test_tmp/notice" || fail "skip is reported"
pass "custom launchers remain active"

ln -s "$test_tmp/original" "$HOME/.local/bin/linked"
"$ROOT/bin/omarchy-mise-install" tool linked 2>/dev/null
[[ -L $HOME/.local/bin/linked ]] || fail "absolute symlink remains active"
[[ $(readlink "$HOME/.local/bin/linked") == "$test_tmp/original" ]] || fail "absolute symlink target is unchanged"
ln -s tool "$HOME/.local/bin/relative"
"$ROOT/bin/omarchy-mise-install" tool relative 2>/dev/null
[[ -L $HOME/.local/bin/relative && $(readlink "$HOME/.local/bin/relative") == "tool" ]] || fail "relative symlink remains valid"
ln -s "$test_tmp/missing" "$HOME/.local/bin/dangling"
"$ROOT/bin/omarchy-mise-install" tool dangling 2>/dev/null
[[ -L $HOME/.local/bin/dangling && ! -e $test_tmp/missing ]] || fail "dangling symlink remains unchanged"
pass "symlinks remain active without moving their targets"

printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "tool" || exit 1\nexec mise x "tool" -- "tool" "$@"\n' >"$launcher"
chmod 600 "$launcher"
"$ROOT/bin/omarchy-mise-install" tool >/dev/null
[[ $(stat -c %a "$launcher") == "700" && -x $launcher ]] || fail "generated private wrapper becomes runnable without exposing its contents"
pass "generated private wrappers retain restrictive permissions"

cp -p "$launcher" "$test_tmp/generated"
"$ROOT/bin/omarchy-mise-install" tool >/dev/null
cmp -s "$launcher" "$test_tmp/generated" || fail "identical reinstall leaves generated wrapper intact"
pass "reinstalling a generated wrapper is safe"

printf '\0' >>"$launcher"
cp -p "$launcher" "$test_tmp/with-nul"
"$ROOT/bin/omarchy-mise-install" tool 2>/dev/null
cmp -s "$launcher" "$test_tmp/with-nul" || fail "generated-looking file with a NUL byte stays active"
[[ -z $(find "$HOME/.local/bin" -name '.mise-wrapper.*' -print) ]] || fail "staged wrapper is cleaned up"
pass "modified generated-looking files are not replaced"

for form in cooldown-export bail-on-failure mise-exec bare-exec; do
  case $form in
    cooldown-export) printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g "legacy" || exit 1\nexec mise x "legacy" -- "legacy" "$@"\n' ;;
    bail-on-failure) printf '#!/bin/bash\nmise use -g "legacy" || exit 1\nexec mise x "legacy" -- "legacy" "$@"\n' ;;
    mise-exec) printf '#!/bin/bash\nmise use -g "legacy"\nexec mise exec "legacy" -- "legacy" "$@"\n' ;;
    bare-exec) printf '#!/bin/bash\nmise use -g "legacy"\nexec "legacy" "$@"\n' ;;
  esac >"$HOME/.local/bin/legacy"
  "$ROOT/bin/omarchy-mise-install" legacy >/dev/null
  grep -Fq 'mise use -g --quiet "legacy"' "$HOME/.local/bin/legacy" || fail "generated $form wrapper is refreshed"
done
pass "every historical generated wrapper refreshes"

printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "old-package" || exit 1\nexec mise x "old-package" -- "tool" "$@"\n' >"$launcher"
cp "$launcher" "$test_tmp/old-package"
"$ROOT/bin/omarchy-mise-install" new-package tool 2>/dev/null
cmp -s "$launcher" "$test_tmp/old-package" || fail "a package edit is kept even when the file looks generated"
pass "package choices in existing launchers remain active"

PATH="$ROOT/bin:$PATH" bash -euo pipefail "$ROOT/migrations/1787573629.sh" >/dev/null
[[ -z $(find "$HOME/.local/bin" -name '*.bak.*' -print) ]] || fail "migration creates no backup on PATH"
pass "the quiet-wrapper migration does not replace custom launchers"
