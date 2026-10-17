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
zeroclaw="$HOME/.local/bin/zeroclaw"
package="github:zeroclaw-labs/zeroclaw"

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

apply_zeroclaw() {
  case $1 in
    migration) source "$ROOT/migrations/1792034058.sh" >/dev/null ;;
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

apply_zeroclaw migration
[[ -x $zeroclaw && ! -L $zeroclaw ]] || fail "ZeroClaw migration creates a missing wrapper"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "ZeroClaw migration installs the package before first launch"
cp "$zeroclaw" "$test_tmp/wrapper"
apply_zeroclaw migration
cmp -s "$zeroclaw" "$test_tmp/wrapper" || fail "ZeroClaw migration is idempotent"
"$zeroclaw" --prompt 'Review this project'
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "use -g --quiet $package x $package -- zeroclaw --prompt Review this project" ]] ||
  fail "ZeroClaw migration wrapper installs the official package and forwards arguments"
pass "ZeroClaw migration creates a lazy, repeatable wrapper"

rm -f "$zeroclaw"
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
apply_zeroclaw migration
[[ ! -e $zeroclaw ]] || fail "ZeroClaw migration respects removed preinstalls with a missing command"
rm "$HOME/.local/state/omarchy/preinstalls-removed"
pass "ZeroClaw migration respects the preinstall opt-out"

for operation in migration removal; do
  for kind in script binary symlink; do
    rm -f "$zeroclaw"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed zeroclaw\n' >"$zeroclaw" ;;
      binary) cp /usr/bin/true "$zeroclaw" ;;
      symlink) ln -s /usr/bin/true "$zeroclaw" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$zeroclaw"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$zeroclaw" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_zeroclaw "$operation"
      cmp -s "$zeroclaw" "$test_tmp/saved-$kind" || fail "ZeroClaw $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $zeroclaw && $(readlink "$zeroclaw") == "/usr/bin/true" ]] ||
          fail "ZeroClaw $operation preserves the user's symlink"
      else
        [[ ! -L $zeroclaw ]] || fail "ZeroClaw $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "ZeroClaw $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" zeroclaw
apply_zeroclaw removal
[[ ! -e $zeroclaw ]] || fail "Remove Preinstalls removes Omarchy's ZeroClaw wrapper"
pass "Remove Preinstalls removes Omarchy's ZeroClaw wrapper"
