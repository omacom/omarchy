#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
export HOME="$test_tmp/home with spaces"
export PATH="$mock_bin:$HOME/.local/bin:$ROOT/bin:/usr/local/bin:/usr/bin"
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_MISE_LOG="$test_tmp/mise-log"
mkdir -p "$mock_bin" "$HOME/.local/bin"
commandcode="$HOME/.local/bin/commandcode"
package="npm:command-code"

cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_MISE_LOG"
SH
cat >"$mock_bin/noop" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin/mise" "$mock_bin/noop"
for command in gum hyprctl omarchy-webapp-remove-all omarchy-tui-remove-all omarchy-pkg-drop; do
  ln -s noop "$mock_bin/$command"
done

apply_commandcode() {
  case $1 in
    migration) source "$ROOT/migrations/1792034306.sh" >/dev/null ;;
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

apply_commandcode migration
[[ -x $commandcode && ! -L $commandcode ]] || fail "Command Code migration creates a missing wrapper"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Command Code migration installs the package before first launch"
cp "$commandcode" "$test_tmp/wrapper"
apply_commandcode migration
cmp -s "$commandcode" "$test_tmp/wrapper" || fail "Command Code migration is idempotent"
"$commandcode" --prompt 'Review this project'
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "use -g --quiet $package x $package -- commandcode --prompt Review this project" ]] ||
  fail "Command Code migration wrapper installs the official package and forwards arguments"
pass "Command Code migration creates a lazy, repeatable wrapper"

rm -f "$commandcode"
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
apply_commandcode migration
[[ ! -e $commandcode ]] || fail "Command Code migration respects removed preinstalls with a missing command"
rm "$HOME/.local/state/omarchy/preinstalls-removed"
pass "Command Code migration respects the preinstall opt-out"

for operation in migration removal; do
  for kind in script binary symlink; do
    rm -f "$commandcode"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed commandcode\n' >"$commandcode" ;;
      binary) cp /usr/bin/true "$commandcode" ;;
      symlink) ln -s /usr/bin/true "$commandcode" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$commandcode"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$commandcode" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_commandcode "$operation"
      cmp -s "$commandcode" "$test_tmp/saved-$kind" || fail "Command Code $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $commandcode && $(readlink "$commandcode") == "/usr/bin/true" ]] ||
          fail "Command Code $operation preserves the user's symlink"
      else
        [[ ! -L $commandcode ]] || fail "Command Code $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "Command Code $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" commandcode
apply_commandcode removal
[[ ! -e $commandcode ]] || fail "Remove Preinstalls removes Omarchy's Command Code wrapper"
pass "Remove Preinstalls removes Omarchy's Command Code wrapper"
