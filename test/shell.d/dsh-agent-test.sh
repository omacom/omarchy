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
dsh="$HOME/.local/bin/dsh"
package="npm:@deepseek-ai/dsh@0.2.0-rc.2"

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

apply_dsh() {
  case $1 in
    migration) source "$ROOT/migrations/1792033356.sh" >/dev/null ;;
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

apply_dsh migration
[[ -x $dsh && ! -L $dsh ]] || fail "DeepSeek Harness migration creates a missing wrapper"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "DeepSeek Harness migration installs the package before first launch"
cp "$dsh" "$test_tmp/wrapper"
apply_dsh migration
cmp -s "$dsh" "$test_tmp/wrapper" || fail "DeepSeek Harness migration is idempotent"
"$dsh" --prompt 'Review this project'
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "use -g --quiet $package x $package -- dsh --prompt Review this project" ]] ||
  fail "DeepSeek Harness migration wrapper installs the official package and forwards arguments"
pass "DeepSeek Harness migration creates a lazy, repeatable wrapper"

rm -f "$dsh"
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
apply_dsh migration
[[ ! -e $dsh ]] || fail "DeepSeek Harness migration respects removed preinstalls with a missing command"
rm "$HOME/.local/state/omarchy/preinstalls-removed"
pass "DeepSeek Harness migration respects the preinstall opt-out"

for operation in migration removal; do
  for kind in script binary symlink; do
    rm -f "$dsh"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed dsh\n' >"$dsh" ;;
      binary) cp /usr/bin/true "$dsh" ;;
      symlink) ln -s /usr/bin/true "$dsh" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$dsh"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$dsh" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_dsh "$operation"
      cmp -s "$dsh" "$test_tmp/saved-$kind" || fail "DeepSeek Harness $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $dsh && $(readlink "$dsh") == "/usr/bin/true" ]] ||
          fail "DeepSeek Harness $operation preserves the user's symlink"
      else
        [[ ! -L $dsh ]] || fail "DeepSeek Harness $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "DeepSeek Harness $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" dsh
apply_dsh removal
[[ ! -e $dsh ]] || fail "Remove Preinstalls removes Omarchy's DeepSeek Harness wrapper"
pass "Remove Preinstalls removes Omarchy's DeepSeek Harness wrapper"
