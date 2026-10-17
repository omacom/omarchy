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
kilo="$HOME/.local/bin/kilo"
package="npm:@kilocode/cli"

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

apply_kilo() {
  case $1 in
    migration) source "$ROOT/migrations/1792034151.sh" >/dev/null ;;
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

apply_kilo migration
[[ -x $kilo && ! -L $kilo ]] || fail "Kilo migration creates a missing wrapper"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Kilo migration installs the package before first launch"
cp "$kilo" "$test_tmp/wrapper"
apply_kilo migration
cmp -s "$kilo" "$test_tmp/wrapper" || fail "Kilo migration is idempotent"
"$kilo" --prompt 'Review this project'
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "use -g --quiet $package x $package -- kilo --prompt Review this project" ]] ||
  fail "Kilo migration wrapper installs the official package and forwards arguments"
pass "Kilo migration creates a lazy, repeatable wrapper"

rm -f "$kilo"
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
apply_kilo migration
[[ ! -e $kilo ]] || fail "Kilo migration respects removed preinstalls with a missing command"
rm "$HOME/.local/state/omarchy/preinstalls-removed"
pass "Kilo migration respects the preinstall opt-out"

for operation in migration removal; do
  for kind in script binary symlink; do
    rm -f "$kilo"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed kilo\n' >"$kilo" ;;
      binary) cp /usr/bin/true "$kilo" ;;
      symlink) ln -s /usr/bin/true "$kilo" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$kilo"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$kilo" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_kilo "$operation"
      cmp -s "$kilo" "$test_tmp/saved-$kind" || fail "Kilo $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $kilo && $(readlink "$kilo") == "/usr/bin/true" ]] ||
          fail "Kilo $operation preserves the user's symlink"
      else
        [[ ! -L $kilo ]] || fail "Kilo $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "Kilo $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" kilo
apply_kilo removal
[[ ! -e $kilo ]] || fail "Remove Preinstalls removes Omarchy's Kilo wrapper"
pass "Remove Preinstalls removes Omarchy's Kilo wrapper"
