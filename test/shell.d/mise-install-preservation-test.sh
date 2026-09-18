#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home"
mkdir -p "$HOME/.local/bin" "$test_tmp/bin"
launcher="$HOME/.local/bin/tool"
printf '#!/bin/bash\nexport MY_TOKEN=private\nexec custom-tool "$@"\n' >"$launcher"
chmod 700 "$launcher"
cp -p "$launcher" "$test_tmp/original"

"$ROOT/bin/omarchy-mise-install" tool >/dev/null
backups=("$launcher".bak.*)
(( ${#backups[@]} == 1 )) || fail "one backup is created"
cmp -s "${backups[0]}" "$test_tmp/original" || fail "custom launcher is preserved verbatim"
[[ $(stat -c %a "${backups[0]}") == "700" ]] || fail "backup retains private permissions"
[[ -x $launcher ]] || fail "replacement wrapper is executable"
grep -Fq 'mise use -g --quiet "tool"' "$launcher" || fail "replacement is the requested wrapper"
pass "custom launchers are backed up with their permissions"

"$ROOT/bin/omarchy-mise-install" tool >/dev/null
backups=("$launcher".bak.*)
(( ${#backups[@]} == 1 )) || fail "identical reinstalls do not accumulate backups"
pass "reinstalling the same wrapper creates no extra backup"

ln -s "$test_tmp/original" "$HOME/.local/bin/linked"
"$ROOT/bin/omarchy-mise-install" tool linked >/dev/null
links=("$HOME/.local/bin/linked".bak.*)
[[ -L ${links[0]} && ! -L $HOME/.local/bin/linked ]] || fail "symlink itself is saved"
cmp -s "$test_tmp/original" "${backups[0]}" || fail "symlink target is untouched"
ln -s "$test_tmp/missing" "$HOME/.local/bin/dangling"
"$ROOT/bin/omarchy-mise-install" tool dangling >/dev/null
links=("$HOME/.local/bin/dangling".bak.*)
[[ -L ${links[0]} && ! -e $test_tmp/missing ]] || fail "dangling link is backed up without creating its target"
pass "symlinks are replaced without changing their targets"

cp "$test_tmp/original" "$launcher"
cat >"$test_tmp/bin/cp" <<'STUB'
#!/bin/bash
exit 1
STUB
chmod +x "$test_tmp/bin/cp"
if PATH="$test_tmp/bin:$PATH" "$ROOT/bin/omarchy-mise-install" tool; then
  fail "backup failure aborts installation"
fi
cmp -s "$launcher" "$test_tmp/original" || fail "backup failure leaves the original launcher intact"
[[ -z $(find "$HOME/.local/bin" -name '.mise-wrapper.*' -print) ]] || fail "staged wrapper is cleaned up"
pass "failed backups leave the original launcher intact"
