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
phantombot="$HOME/.local/bin/phantombot"
package="github:phantomyard/phantombot"

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

apply_phantombot() {
  case $1 in
    migration) source "$ROOT/migrations/1792034353.sh" >/dev/null ;;
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

apply_phantombot migration
[[ -x $phantombot && ! -L $phantombot ]] || fail "Phantombot migration creates a missing wrapper"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Phantombot migration installs the package before first launch"
cp "$phantombot" "$test_tmp/wrapper"
apply_phantombot migration
cmp -s "$phantombot" "$test_tmp/wrapper" || fail "Phantombot migration is idempotent"
"$phantombot" --prompt 'Review this project'
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "use -g --quiet $package x $package -- phantombot --prompt Review this project" ]] ||
  fail "Phantombot migration wrapper installs the official package and forwards arguments"
pass "Phantombot migration creates a lazy, repeatable wrapper"

rm -f "$phantombot"
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
apply_phantombot migration
[[ ! -e $phantombot ]] || fail "Phantombot migration respects removed preinstalls with a missing command"
rm "$HOME/.local/state/omarchy/preinstalls-removed"
pass "Phantombot migration respects the preinstall opt-out"

for operation in migration removal; do
  for kind in script binary symlink; do
    rm -f "$phantombot"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed phantombot\n' >"$phantombot" ;;
      binary) cp /usr/bin/true "$phantombot" ;;
      symlink) ln -s /usr/bin/true "$phantombot" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$phantombot"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$phantombot" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_phantombot "$operation"
      cmp -s "$phantombot" "$test_tmp/saved-$kind" || fail "Phantombot $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $phantombot && $(readlink "$phantombot") == "/usr/bin/true" ]] ||
          fail "Phantombot $operation preserves the user's symlink"
      else
        [[ ! -L $phantombot ]] || fail "Phantombot $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "Phantombot $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" phantombot
apply_phantombot removal
[[ ! -e $phantombot ]] || fail "Remove Preinstalls removes Omarchy's Phantombot wrapper"
pass "Remove Preinstalls removes Omarchy's Phantombot wrapper"
