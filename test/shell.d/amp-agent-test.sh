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
amp="$HOME/.local/bin/amp"
package="amp"

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

apply_amp() {
  case $1 in
    migration) source "$ROOT/migrations/1792034243.sh" >/dev/null ;;
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

apply_amp migration
[[ -x $amp && ! -L $amp ]] || fail "Amp migration creates a missing wrapper"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Amp migration installs the package before first launch"
cp "$amp" "$test_tmp/wrapper"
apply_amp migration
cmp -s "$amp" "$test_tmp/wrapper" || fail "Amp migration is idempotent"
"$amp" --prompt 'Review this project'
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "use -g --quiet $package x $package -- amp --prompt Review this project" ]] ||
  fail "Amp migration wrapper installs the official package and forwards arguments"
pass "Amp migration creates a lazy, repeatable wrapper"

rm -f "$amp"
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
apply_amp migration
[[ ! -e $amp ]] || fail "Amp migration respects removed preinstalls with a missing command"
rm "$HOME/.local/state/omarchy/preinstalls-removed"
pass "Amp migration respects the preinstall opt-out"

for operation in migration removal; do
  for kind in script binary symlink; do
    rm -f "$amp"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed amp\n' >"$amp" ;;
      binary) cp /usr/bin/true "$amp" ;;
      symlink) ln -s /usr/bin/true "$amp" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$amp"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$amp" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_amp "$operation"
      cmp -s "$amp" "$test_tmp/saved-$kind" || fail "Amp $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $amp && $(readlink "$amp") == "/usr/bin/true" ]] ||
          fail "Amp $operation preserves the user's symlink"
      else
        [[ ! -L $amp ]] || fail "Amp $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "Amp $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" amp
apply_amp removal
[[ ! -e $amp ]] || fail "Remove Preinstalls removes Omarchy's Amp wrapper"
pass "Remove Preinstalls removes Omarchy's Amp wrapper"
