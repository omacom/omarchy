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
freebuff="$HOME/.local/bin/freebuff"
package="npm:freebuff"

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

apply_freebuff() {
  case $1 in
    migration) source "$ROOT/migrations/1792033907.sh" >/dev/null ;;
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

apply_freebuff migration
[[ -x $freebuff && ! -L $freebuff ]] || fail "Freebuff migration creates a missing wrapper"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Freebuff migration installs the package before first launch"
cp "$freebuff" "$test_tmp/wrapper"
apply_freebuff migration
cmp -s "$freebuff" "$test_tmp/wrapper" || fail "Freebuff migration is idempotent"
"$freebuff" --prompt 'Review this project'
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "use -g --quiet $package x $package -- freebuff --prompt Review this project" ]] ||
  fail "Freebuff migration wrapper installs the official package and forwards arguments"
pass "Freebuff migration creates a lazy, repeatable wrapper"

rm -f "$freebuff"
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
apply_freebuff migration
[[ ! -e $freebuff ]] || fail "Freebuff migration respects removed preinstalls with a missing command"
rm "$HOME/.local/state/omarchy/preinstalls-removed"
pass "Freebuff migration respects the preinstall opt-out"

for operation in migration removal; do
  for kind in script binary symlink; do
    rm -f "$freebuff"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed freebuff\n' >"$freebuff" ;;
      binary) cp /usr/bin/true "$freebuff" ;;
      symlink) ln -s /usr/bin/true "$freebuff" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$freebuff"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$freebuff" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_freebuff "$operation"
      cmp -s "$freebuff" "$test_tmp/saved-$kind" || fail "Freebuff $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $freebuff && $(readlink "$freebuff") == "/usr/bin/true" ]] ||
          fail "Freebuff $operation preserves the user's symlink"
      else
        [[ ! -L $freebuff ]] || fail "Freebuff $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "Freebuff $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" freebuff
apply_freebuff removal
[[ ! -e $freebuff ]] || fail "Remove Preinstalls removes Omarchy's Freebuff wrapper"
pass "Remove Preinstalls removes Omarchy's Freebuff wrapper"
