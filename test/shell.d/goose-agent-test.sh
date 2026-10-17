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
goose="$HOME/.local/bin/goose"
package="aqua:aaif-goose/goose"

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

apply_goose() {
  case $1 in
    migration) source "$ROOT/migrations/1792033725.sh" >/dev/null ;;
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

apply_goose migration
[[ -x $goose && ! -L $goose ]] || fail "Goose migration creates a missing wrapper"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Goose migration installs the package before first launch"
cp "$goose" "$test_tmp/wrapper"
apply_goose migration
cmp -s "$goose" "$test_tmp/wrapper" || fail "Goose migration is idempotent"
"$goose" --prompt 'Review this project'
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "use -g --quiet $package x $package -- goose --prompt Review this project" ]] ||
  fail "Goose migration wrapper installs the official package and forwards arguments"
pass "Goose migration creates a lazy, repeatable wrapper"

rm -f "$goose"
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
apply_goose migration
[[ ! -e $goose ]] || fail "Goose migration respects removed preinstalls with a missing command"
rm "$HOME/.local/state/omarchy/preinstalls-removed"
pass "Goose migration respects the preinstall opt-out"

for operation in migration removal; do
  for kind in script binary symlink; do
    rm -f "$goose"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed goose\n' >"$goose" ;;
      binary) cp /usr/bin/true "$goose" ;;
      symlink) ln -s /usr/bin/true "$goose" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$goose"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$goose" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_goose "$operation"
      cmp -s "$goose" "$test_tmp/saved-$kind" || fail "Goose $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $goose && $(readlink "$goose") == "/usr/bin/true" ]] ||
          fail "Goose $operation preserves the user's symlink"
      else
        [[ ! -L $goose ]] || fail "Goose $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "Goose $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" goose
apply_goose removal
[[ ! -e $goose ]] || fail "Remove Preinstalls removes Omarchy's Goose wrapper"
pass "Remove Preinstalls removes Omarchy's Goose wrapper"
