#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home"
mkdir -p "$HOME/.local/bin" "$test_tmp/bin"
shopt -s nullglob
backup_dir="$HOME/.local/state/omarchy/mise-backups"
launcher="$HOME/.local/bin/tool"
printf '#!/bin/bash\nexport MY_TOKEN=private\nexec custom-tool "$@"\n' >"$launcher"
chmod 700 "$launcher"
cp -p "$launcher" "$test_tmp/original"

"$ROOT/bin/omarchy-mise-install" tool >/dev/null
backups=("$backup_dir"/tool.*)
(( ${#backups[@]} == 1 )) || fail "one backup is created"
cmp -s "${backups[0]}" "$test_tmp/original" || fail "custom launcher is preserved verbatim"
[[ $(stat -c %a "${backups[0]}") == "700" ]] || fail "backup retains private permissions"
[[ -x $launcher ]] || fail "replacement wrapper is executable"
grep -Fq 'mise use -g --quiet "tool"' "$launcher" || fail "replacement is the requested wrapper"
pass "custom launchers are backed up with their permissions"

"$ROOT/bin/omarchy-mise-install" tool >/dev/null
backups=("$backup_dir"/tool.*)
(( ${#backups[@]} == 1 )) || fail "identical reinstalls do not accumulate backups"
pass "reinstalling the same wrapper creates no extra backup"

ln -s "$test_tmp/original" "$HOME/.local/bin/linked"
"$ROOT/bin/omarchy-mise-install" tool linked >/dev/null
links=("$backup_dir"/linked.*)
[[ -L ${links[0]} && ! -L $HOME/.local/bin/linked ]] || fail "symlink itself is saved"
[[ $(readlink "${links[0]}") == "$test_tmp/original" ]] || fail "saved symlink retains its target"
cmp -s "$test_tmp/original" "${backups[0]}" || fail "symlink target is untouched"
ln -s "$test_tmp/missing" "$HOME/.local/bin/dangling"
"$ROOT/bin/omarchy-mise-install" tool dangling >/dev/null
links=("$backup_dir"/dangling.*)
[[ -L ${links[0]} && ! -e $test_tmp/missing ]] || fail "dangling link is backed up without creating its target"
[[ $(readlink "${links[0]}") == "$test_tmp/missing" ]] || fail "saved dangling symlink retains its target"
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

for form in cooldown-export bail-on-failure mise-exec bare-exec; do
  case $form in
    cooldown-export) printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g "legacy" || exit 1\nexec mise x "legacy" -- "legacy" "$@"\n' ;;
    bail-on-failure) printf '#!/bin/bash\nmise use -g "legacy" || exit 1\nexec mise x "legacy" -- "legacy" "$@"\n' ;;
    mise-exec) printf '#!/bin/bash\nmise use -g "legacy"\nexec mise exec "legacy" -- "legacy" "$@"\n' ;;
    bare-exec) printf '#!/bin/bash\nmise use -g "legacy"\nexec "legacy" "$@"\n' ;;
  esac >"$HOME/.local/bin/legacy"
  "$ROOT/bin/omarchy-mise-install" legacy >/dev/null
  backups=("$backup_dir"/legacy.*)
  (( ${#backups[@]} == 0 )) || fail "generated $form wrappers do not create backups"
done
pass "every historical generated wrapper refreshes without a backup"

PATH="$ROOT/bin:$PATH" bash -euo pipefail "$ROOT/migrations/1787573629.sh" >/dev/null
[[ -z $(find "$HOME/.local/bin" -name '*.bak.*' -print) ]] || fail "backups are never exposed on PATH"
pass "the quiet-wrapper migration cannot regenerate saved launchers"
