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
vibe="$HOME/.local/bin/vibe"
package="github:mistralai/mistral-vibe[matching=vibe-linux]"

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

apply_vibe() {
  case $1 in
    migration) source "$ROOT/migrations/1792033880.sh" >/dev/null ;;
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

apply_vibe migration
[[ -x $vibe && ! -L $vibe ]] || fail "Mistral Vibe migration creates a missing wrapper"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Mistral Vibe migration installs the package before first launch"
cp "$vibe" "$test_tmp/wrapper"
apply_vibe migration
cmp -s "$vibe" "$test_tmp/wrapper" || fail "Mistral Vibe migration is idempotent"
"$vibe" --prompt 'Review this project'
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "use -g --quiet $package x $package -- vibe --prompt Review this project" ]] ||
  fail "Mistral Vibe migration wrapper installs the official package and forwards arguments"
pass "Mistral Vibe migration creates a lazy, repeatable wrapper"

rm -f "$vibe"
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
apply_vibe migration
[[ ! -e $vibe ]] || fail "Mistral Vibe migration respects removed preinstalls with a missing command"
rm "$HOME/.local/state/omarchy/preinstalls-removed"
pass "Mistral Vibe migration respects the preinstall opt-out"

for operation in migration removal; do
  for kind in script binary symlink; do
    rm -f "$vibe"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed vibe\n' >"$vibe" ;;
      binary) cp /usr/bin/true "$vibe" ;;
      symlink) ln -s /usr/bin/true "$vibe" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$vibe"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$vibe" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_vibe "$operation"
      cmp -s "$vibe" "$test_tmp/saved-$kind" || fail "Mistral Vibe $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $vibe && $(readlink "$vibe") == "/usr/bin/true" ]] ||
          fail "Mistral Vibe $operation preserves the user's symlink"
      else
        [[ ! -L $vibe ]] || fail "Mistral Vibe $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "Mistral Vibe $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" vibe
apply_vibe removal
[[ ! -e $vibe ]] || fail "Remove Preinstalls removes Omarchy's Mistral Vibe wrapper"
pass "Remove Preinstalls removes Omarchy's Mistral Vibe wrapper"
