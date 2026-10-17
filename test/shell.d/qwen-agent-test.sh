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
qwen="$HOME/.local/bin/qwen"
package="npm:@qwen-code/qwen-code"

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

apply_qwen() {
  case $1 in
    migration) source "$ROOT/migrations/1792032538.sh" >/dev/null ;;
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

apply_qwen migration
[[ -x $qwen && ! -L $qwen ]] || fail "Qwen Code migration creates a missing wrapper"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Qwen Code migration installs the package before first launch"
cp "$qwen" "$test_tmp/wrapper"
apply_qwen migration
cmp -s "$qwen" "$test_tmp/wrapper" || fail "Qwen Code migration is idempotent"
"$qwen" --prompt 'Review this project'
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "use -g --quiet $package x $package -- qwen --prompt Review this project" ]] ||
  fail "Qwen Code migration wrapper installs the official package and forwards arguments"
pass "Qwen Code migration creates a lazy, repeatable wrapper"

rm -f "$qwen"
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
apply_qwen migration
[[ ! -e $qwen ]] || fail "Qwen Code migration respects removed preinstalls with a missing command"
rm "$HOME/.local/state/omarchy/preinstalls-removed"
pass "Qwen Code migration respects the preinstall opt-out"

for operation in migration removal; do
  for kind in script binary symlink; do
    rm -f "$qwen"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed qwen\n' >"$qwen" ;;
      binary) cp /usr/bin/true "$qwen" ;;
      symlink) ln -s /usr/bin/true "$qwen" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$qwen"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$qwen" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_qwen "$operation"
      cmp -s "$qwen" "$test_tmp/saved-$kind" || fail "Qwen Code $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $qwen && $(readlink "$qwen") == "/usr/bin/true" ]] ||
          fail "Qwen Code $operation preserves the user's symlink"
      else
        [[ ! -L $qwen ]] || fail "Qwen Code $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "Qwen Code $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" qwen
apply_qwen removal
[[ ! -e $qwen ]] || fail "Remove Preinstalls removes Omarchy's Qwen Code wrapper"
pass "Remove Preinstalls removes Omarchy's Qwen Code wrapper"
